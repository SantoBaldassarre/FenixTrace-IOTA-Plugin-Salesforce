import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getProductStatus from '@salesforce/apex/FenixTraceController.getProductStatus';
import syncProduct from '@salesforce/apex/FenixTraceController.syncProduct';

export default class FenixTracePanel extends LightningElement {
    @api recordId;
    status;
    isSyncing = false;
    _wiredResult;

    @wire(getProductStatus, { productId: '$recordId' })
    wiredStatus(result) {
        this._wiredResult = result;
        if (result.data) {
            this.status = result.data;
        }
    }

    get stateBadgeClass() {
        if (!this.status) return '';
        const map = { Synced: 'slds-theme_success', Queued: 'slds-theme_warning', Error: 'slds-theme_error' };
        return map[this.status.state] || '';
    }

    get formattedLastSync() {
        return this.status?.lastSync ? new Date(this.status.lastSync).toLocaleString() : '—';
    }

    get showError() {
        return this.status?.state === 'Error' && this.status?.lastError;
    }

    get buttonLabel() {
        if (this.isSyncing) return 'Syncing...';
        return this.status?.state === 'Error' ? 'Retry FenixTrace' : 'Send to FenixTrace';
    }

    async handleSync() {
        this.isSyncing = true;
        try {
            const result = await syncProduct({ productId: this.recordId });
            this.dispatchEvent(new ShowToastEvent({
                title: 'FenixTrace',
                message: result.success ? 'Product synced successfully!' : ('Sync failed: ' + (result.error || 'Unknown')),
                variant: result.success ? 'success' : 'error'
            }));
            await refreshApex(this._wiredResult);
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'FenixTrace Error',
                message: error.body?.message || 'Connection failed',
                variant: 'error'
            }));
        } finally {
            this.isSyncing = false;
        }
    }
}
