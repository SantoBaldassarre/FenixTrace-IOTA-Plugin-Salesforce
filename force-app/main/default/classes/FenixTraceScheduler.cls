/**
 * FenixTrace Scheduler — scheduled batch sync for products in draft/error state.
 * Schedule: System.schedule('FenixTrace Hourly Sync', '0 0 * * * ?', new FenixTraceScheduler());
 */
public with sharing class FenixTraceScheduler implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new FenixTraceScheduler(), 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Product2
            WHERE FenixTrace_State__c IN ('Draft', 'Error')
            AND IsActive = true
            ORDER BY LastModifiedDate DESC
            LIMIT 200
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        List<Id> ids = new List<Id>();
        for (Product2 p : scope) {
            ids.add(p.Id);
        }
        FenixTraceService.syncProductsBatch(ids);
    }

    public void finish(Database.BatchableContext bc) {
        // Optional: send notification email
    }
}
