@IsTest
public class ImportPartControllerTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '[{"_id":"619683d69402c24f000237e9","Part Name":"Population Sensor","Total Quantity Shipped":350000}]';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @IsTest
    static void InboundEmailHandlerTest() {
        Test.setMock(HttpCalloutMock.class, new RestMock()); 
        
        Test.startTest();
        Part_Settings__mdt setting = new Part_Settings__mdt();
        setting.Api_Key__c = 'ap1002';
        setting.Content_Type__c = 'test';
        
        ImportPartController.SyncParts();
        Test.StopTest();
    }
}