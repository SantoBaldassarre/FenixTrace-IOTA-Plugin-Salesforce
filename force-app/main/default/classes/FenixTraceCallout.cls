/**
 * FenixTrace Callout — HTTP communication with the Integration Kit.
 * Uses Named Credential 'FenixTrace_Kit' for secure endpoint management.
 */
public with sharing class FenixTraceCallout {

    private static String getBaseUrl() {
        String url = FenixTraceConfig.getKitUrl();
        return url.removeEnd('/');
    }

    public static Map<String, Object> sendToKit(String filename, String jsonBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getBaseUrl() + '/process/' + EncodingUtil.urlEncode(filename, 'UTF-8'));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);
        req.setTimeout(60000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() >= 400) {
            return new Map<String, Object>{ 'success' => false, 'error' => 'HTTP ' + res.getStatusCode() + ': ' + res.getBody() };
        }

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> result = body.containsKey('result') ? (Map<String, Object>) body.get('result') : body;

        return new Map<String, Object>{
            'success' => true,
            'txHash' => (String) result.get('txHash'),
            'notarizationTxHash' => (String) result.get('notarizationTxHash'),
            'ipfsHash' => (String) result.get('ipfsHash')
        };
    }

    public static Map<String, Object> checkStatus() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getBaseUrl() + '/status');
        req.setMethod('GET');
        req.setTimeout(10000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            return new Map<String, Object>{ 'connected' => false, 'error' => 'HTTP ' + res.getStatusCode() };
        }
        return new Map<String, Object>{ 'connected' => true, 'data' => JSON.deserializeUntyped(res.getBody()) };
    }

    public static Map<String, Object> checkBalance(Integer files) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getBaseUrl() + '/balance?files=' + files);
        req.setMethod('GET');
        req.setTimeout(10000);

        Http http = new Http();
        HttpResponse res = http.send(req);
        return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    }
}
