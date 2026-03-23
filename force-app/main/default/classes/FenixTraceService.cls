/**
 * FenixTrace Service — core logic for syncing Salesforce products to IOTA L1.
 * Builds JSON payloads, calls the Integration Kit, and updates Product2 fields.
 */
public with sharing class FenixTraceService {

    public static Map<String, Object> syncProduct(Id productId) {
        Product2 product = [
            SELECT Id, Name, ProductCode, Family, Description, IsActive,
                   FenixTrace_State__c, FenixTrace_TX_Hash__c,
                   FenixTrace_Notarization_TX__c, FenixTrace_IPFS_Hash__c
            FROM Product2 WHERE Id = :productId LIMIT 1
        ];

        String payload = buildPayload(product);
        String filename = generateFilename(product);

        product.FenixTrace_State__c = 'Queued';
        product.FenixTrace_Last_Error__c = '';
        update product;

        Map<String, Object> result = FenixTraceCallout.sendToKit(filename, payload);

        if ((Boolean) result.get('success')) {
            product.FenixTrace_State__c = 'Synced';
            product.FenixTrace_TX_Hash__c = (String) result.get('txHash');
            product.FenixTrace_Notarization_TX__c = (String) result.get('notarizationTxHash');
            product.FenixTrace_IPFS_Hash__c = (String) result.get('ipfsHash');
            product.FenixTrace_Last_Sync__c = Datetime.now();
            product.FenixTrace_Last_Error__c = '';
        } else {
            product.FenixTrace_State__c = 'Error';
            product.FenixTrace_Last_Error__c = (String) result.get('error');
        }
        update product;
        return result;
    }

    public static List<Map<String, Object>> syncProductsBatch(List<Id> productIds) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Id pid : productIds) {
            try {
                results.add(syncProduct(pid));
            } catch (Exception e) {
                Product2 p = new Product2(Id = pid);
                p.FenixTrace_State__c = 'Error';
                p.FenixTrace_Last_Error__c = e.getMessage();
                update p;
                results.add(new Map<String, Object>{ 'success' => false, 'error' => e.getMessage() });
            }
        }
        return results;
    }

    public static String buildPayload(Product2 product) {
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('name', product.Name);
        payload.put('company', UserInfo.getOrganizationName());
        payload.put('template', FenixTraceConfig.getTemplate());

        Map<String, Object> productData = new Map<String, Object>();
        productData.put('name', product.Name);
        productData.put('productCode', product.ProductCode);
        productData.put('family', product.Family);
        productData.put('description', product.Description);
        productData.put('isActive', product.IsActive);
        payload.put('product', productData);

        payload.put('source', 'salesforce_plugin');
        payload.put('createdAt', Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));

        Map<String, Object> sfData = new Map<String, Object>();
        sfData.put('recordId', product.Id);
        sfData.put('orgId', UserInfo.getOrganizationId());
        sfData.put('orgName', UserInfo.getOrganizationName());
        payload.put('salesforce', sfData);

        return JSON.serialize(payload);
    }

    public static String generateFilename(Product2 product) {
        String slug = String.isNotBlank(product.ProductCode) ? product.ProductCode : product.Name;
        slug = slug.replaceAll('[^a-zA-Z0-9_-]', '_').toLowerCase();
        if (String.isBlank(slug)) slug = 'product_' + product.Id;
        String stamp = Datetime.now().formatGmt('yyyyMMddHHmmss');
        return slug + '_' + product.Id + '_' + stamp + '.json';
    }
}
