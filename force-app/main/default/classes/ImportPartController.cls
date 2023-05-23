// this Class will get response from external system and sync with the parts.
public class ImportPartController {
    
    // this method will get response from external system and sync with the parts.
    @AuraEnabled
    public Static String SyncParts(){
        String message = '';
        try{
            List<Part_Settings__mdt> partSetting = [ SELECT Api_Key__c,
                                                    Content_Type__c,
                                                    End_Point__c
                                                    FROM Part_Settings__mdt
                                                    WHERE DeveloperName = 'Part_Settings'];
            
            
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setHeader('Content-type',partSetting[0].Content_Type__c);
            request.setHeader('x-api-key',partSetting[0].Api_Key__c);
            request.setEndpoint(partSetting[0].End_Point__c);
            
            HTTP http = new HTTP();
            HTTPResponse response =  http.send(request);
            string partsListFromResponse = response.getBody();
            if(partsListFromResponse.contains('_id')){
                partsListFromResponse = partsListFromResponse.replace('_id', 'id');    
            }
            if(partsListFromResponse.contains('Part Name')){
                partsListFromResponse = partsListFromResponse.replace('Part Name', 'PartName');    
            }
            if(partsListFromResponse.contains('Total Quantity Shipped')){
                partsListFromResponse = partsListFromResponse.replace('Total Quantity Shipped', 'TotalQuantityShipped');    
            }
            List<PartsWraper> wrapperClassList = (List<PartsWraper>)JSON.deserialize(partsListFromResponse, List<PartsWraper>.class);
            
            Set<String> partIdListFromResponse = new Set<String>();
            
            if(!wrapperClassList.isEmpty()){
                for(PartsWraper WC : wrapperClassList){
                    partIdListFromResponse.add(WC.id);
                }
            }
            List<SQX_Part__c> partsList = new List<SQX_Part__c>();

            // Account with name High Volume
            List<Account> highVolumeAccountList = [select Id, Name from Account where name = 'High Volume' Limit 1];
            // Account with name Low Volume
            List<Account> lowVolumeAccountList = [select Id, Name from Account where name = 'Low Volume' Limit 1];
            
            if(!partIdListFromResponse.isEmpty()){
                partsList = [select id,Name,Active__c,Part_Number__c from SQX_Part__c where Part_Number__c IN: partIdListFromResponse];
            }
            Map<String,String> partmap = new Map<String,String>();
            if(!partsList.isEmpty()){
                for(SQX_Part__c pr : partsList){
                    partmap.put(pr.Part_Number__c,pr.id);
                }
            }
            
            List<SQX_Part__c> newPartsList = new List<SQX_Part__c>();
            
            if(!wrapperClassList.isEmpty()){
                for(PartsWraper wrapper : wrapperClassList){
                    SQX_Part__c part = new SQX_Part__c();
                    if(partmap.get(wrapper.id) != null){
                        part.id = partmap.get(wrapper.id);
                    }
                    part.Name = wrapper.PartName;
                    part.Part_Number__c = wrapper.id;
                    
                    part.Active__c = true;
                    if(wrapper.TotalQuantityShipped < 99){
                        if(!highVolumeAccountList.isEmpty()){
                            part.Related_Account__c	= highVolumeAccountList[0].Id;
                        }
                    }else if(wrapper.TotalQuantityShipped >= 99){
                        if(!lowVolumeAccountList.isEmpty()){
                            part.Related_Account__c	= lowVolumeAccountList[0].Id;
                        }
                    }
                    newPartsList.add(part);
                }
            }
            
            if(!newPartsList.isEmpty()){
                upsert newPartsList;
            }
            message = 'Success';
            return message;
        }
        catch(exception ex){
            message = ex.getMessage();
           return message;
        }
        
    }
    
    // This wrapper class wil store data form the response.
    public class PartsWraper {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String PartName {get; set;}
        @AuraEnabled public Integer TotalQuantityShipped {get; set;}
    }
}