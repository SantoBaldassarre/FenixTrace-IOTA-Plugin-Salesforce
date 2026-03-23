/**
 * FenixTrace Config — helper to read custom metadata settings.
 */
public with sharing class FenixTraceConfig {

    private static final String DEFAULT_KIT_URL = 'http://localhost:3005';
    private static final String DEFAULT_TEMPLATE = 'generic';

    public static String getKitUrl() {
        try {
            FenixTrace_Settings__mdt settings = [
                SELECT Kit_URL__c FROM FenixTrace_Settings__mdt
                WHERE DeveloperName = 'FenixTrace_Default' LIMIT 1
            ];
            return String.isNotBlank(settings.Kit_URL__c) ? settings.Kit_URL__c : DEFAULT_KIT_URL;
        } catch (Exception e) {
            return DEFAULT_KIT_URL;
        }
    }

    public static String getTemplate() {
        try {
            FenixTrace_Settings__mdt settings = [
                SELECT Template__c FROM FenixTrace_Settings__mdt
                WHERE DeveloperName = 'FenixTrace_Default' LIMIT 1
            ];
            return String.isNotBlank(settings.Template__c) ? settings.Template__c : DEFAULT_TEMPLATE;
        } catch (Exception e) {
            return DEFAULT_TEMPLATE;
        }
    }

    public static Boolean isAutoSyncEnabled() {
        try {
            FenixTrace_Settings__mdt settings = [
                SELECT Auto_Sync__c FROM FenixTrace_Settings__mdt
                WHERE DeveloperName = 'FenixTrace_Default' LIMIT 1
            ];
            return settings.Auto_Sync__c == true;
        } catch (Exception e) {
            return false;
        }
    }
}
