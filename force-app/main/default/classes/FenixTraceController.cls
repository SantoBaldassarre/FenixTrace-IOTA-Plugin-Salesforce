/**
 * FenixTrace Controller — @AuraEnabled methods for the Lightning Web Component.
 */
public with sharing class FenixTraceController {

    @AuraEnabled
    public static Map<String, Object> syncProduct(Id productId) {
        return FenixTraceService.syncProduct(productId);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProductStatus(Id productId) {
        Product2 p = [
            SELECT FenixTrace_State__c, FenixTrace_TX_Hash__c,
                   FenixTrace_Notarization_TX__c, FenixTrace_IPFS_Hash__c,
                   FenixTrace_Last_Sync__c, FenixTrace_Last_Error__c
            FROM Product2 WHERE Id = :productId LIMIT 1
        ];
        return new Map<String, Object>{
            'state' => p.FenixTrace_State__c,
            'txHash' => p.FenixTrace_TX_Hash__c,
            'notarizationTxHash' => p.FenixTrace_Notarization_TX__c,
            'ipfsHash' => p.FenixTrace_IPFS_Hash__c,
            'lastSync' => p.FenixTrace_Last_Sync__c,
            'lastError' => p.FenixTrace_Last_Error__c
        };
    }

    @AuraEnabled
    public static Map<String, Object> getKitStatus() {
        return FenixTraceCallout.checkStatus();
    }
}
