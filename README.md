# FenixTrace for Salesforce

Salesforce package that registers Product2 records on the **IOTA L1** blockchain via the FenixTrace Integration Kit. Includes Apex classes, a Lightning Web Component, scheduled batch sync, and custom fields.

> Built by [Fenix Software Labs](https://www.fenixsoftwarelabs.com)

## How It Works

```
Salesforce Product2 → Apex JSON payload → Integration Kit → IPFS + IOTA L1 → FenixTrace Scanner
```

## Requirements

- Salesforce Enterprise Edition or higher
- [FenixTrace Integration Kit](https://github.com/SantoBaldassarre/FenixTrace-IOTA-auto-add-product-Integration-Kit) running
- Remote Site Setting for the Integration Kit URL
- Active FenixTrace subscription

## Installation

### Option 1: SFDX (recommended)

```bash
git clone https://github.com/SantoBaldassarre/FenixTrace-Plugin-Salesforce.git
cd FenixTrace-Plugin-Salesforce
sfdx force:source:deploy -p force-app -u YourOrg
```

### Option 2: Change Sets

Copy Apex classes, LWC, custom fields, and custom metadata to your Salesforce org via Change Sets.

## Configuration

1. **Remote Site Setting**: Setup → Security → Remote Site Settings → New
   - Name: `FenixTrace_Kit`
   - URL: `http://your-kit-server:3005`

2. **Custom Metadata**: Setup → Custom Metadata Types → FenixTrace Settings → Manage Records
   - Kit URL: `http://your-kit-server:3005`
   - Template: `generic` (or agro, pharma, fashion, etc.)
   - Auto Sync: `true/false`

3. **LWC on Record Page**: Edit Product2 Lightning Record Page → drag "fenixTracePanel" component

## Usage

### Single Product (LWC)
Open any Product record → "FenixTrace Blockchain" card → click **"Send to FenixTrace"**

### Batch Sync (Apex)
```apex
List<Id> ids = new List<Id>{ '01tXXXXXXXXXXXX', '01tYYYYYYYYYYYYY' };
FenixTraceService.syncProductsBatch(ids);
```

### Scheduled Sync
```apex
// Run every hour
System.schedule('FenixTrace Hourly Sync', '0 0 * * * ?', new FenixTraceScheduler());
```

## Custom Fields on Product2

| Field | Type | Description |
|---|---|---|
| `FenixTrace_State__c` | Picklist | Draft / Queued / Synced / Error |
| `FenixTrace_TX_Hash__c` | Text(255) | IOTA transaction hash |
| `FenixTrace_Notarization_TX__c` | Text(255) | Notarization transaction hash |
| `FenixTrace_IPFS_Hash__c` | Text(255) | IPFS content hash |
| `FenixTrace_Last_Sync__c` | DateTime | Last successful sync |
| `FenixTrace_Last_Error__c` | LongTextArea | Error message |

## Other Plugins

| Plugin | Platform | Repository |
|---|---|---|
| **FenixTrace for Odoo** | Odoo 16/17 | [GitHub](https://github.com/SantoBaldassarre/FenixTrace-IOTA-Plugin-Odoo) |
| **FenixTrace for WooCommerce** | WordPress + WooCommerce | [GitHub](https://github.com/SantoBaldassarre/FenixTrace-IOTA-Plugin-WooCommerce) |
| **FenixTrace for PrestaShop** | PrestaShop 1.7/8.x | [GitHub](https://github.com/SantoBaldassarre/FenixTrace-IOTA-Plugin-PrestaShop) |
| **FenixTrace for WordPress** | WordPress (no shop) | [GitHub](https://github.com/SantoBaldassarre/FenixTrace-Plugin-Wordpress) |

## Links

- [FenixTrace Platform](https://fenixtrace.com)
- [FenixTrace Integration Docs](https://fenixtrace.com/docs/integration-gateway)
- [Integration Kit](https://github.com/SantoBaldassarre/FenixTrace-IOTA-auto-add-product-Integration-Kit)
- [Fenix Software Labs](https://www.fenixsoftwarelabs.com)

## License

MIT — [Fenix Software Labs](https://www.fenixsoftwarelabs.com)
