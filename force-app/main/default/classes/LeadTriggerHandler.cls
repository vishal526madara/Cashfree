public class LeadTriggerHandler {
    public static Boolean checkStatus = true;
    public static void afterInsert(List<Lead> newList){
        campaignAssigment(newList);
    }
    
    public static void beforeInsert(List<Lead> newList){
        updateExternalEmail(newList,null);
        roundRobinAssignment(newList);
    }
    
    public static void beforeUpdate(List<Lead> newList,Map<Id,Lead> oldMap){
        updateExternalEmail(newList,oldMap);
        roundRobinAssignment(newList);
    }
    
    
    public static void updateExternalEmail(List<Lead> newList,Map<Id,Lead> oldMap){
        
        for(Lead ld : newList){
            
            if(ld.email!=NULL && (oldMap ==NULL || ld.Email != oldMap.get(ld.Id).Email)){
                ld.Email_External_Id__c  = ld.Email;
            }
            
        }
    }
    
    
    public static void campaignAssigment(List<Lead> leadList){
        try{
            System.debug('Value::'+ leadList);
        List<Lead> updateList = new List<Lead>();
        Set<String> campaignId = new Set<String>();
        Map<String,Campaign> campaignMap = new Map<String,Campaign>();
        for(Lead lead : leadList){
            campaignId.add(lead.External_Campaign_ID__c);
        }
        
        for(Campaign campaign : [Select Id,Name,Campaign_ID__c From Campaign Where Campaign_ID__c IN: campaignId]){
            campaignMap.put(campaign.Campaign_ID__c,campaign);
        }
        for(Lead lead : leadList){
            if(campaignMap.containsKey(lead.External_Campaign_ID__c)){
                Lead newLead = new Lead();
                newLead.Id = lead.Id;
                newLead.Campaign__c = campaignMap.get(lead.External_Campaign_ID__c).Id;
                updateList.add(newLead);
            }
        }
            if(updateList.size() != 0){
                System.debug('Value::'+ updateList);
                checkStatus = false;
                Update updateList;
            }
        }
        catch(Exception e){
            System.debug('Error:::'+ e.getMessage());
            System.debug('Value::'+ e.getLineNumber());
        }
        
    }

    private static void roundRobinAssignment(List<Lead> leadList){
     List<String> leadFieldList = new List<String>();
     List<String> roundRobinFieldList = new List<String>();

     //Create Meta Data Round Robin Field Map
     Map<String,Field_Mapping__mdt> fieldMappingMetaDataMap =  new Map<String,Field_Mapping__mdt>();

     Map<String,Round_Robin__c> roundRobinMap = new Map<String,Round_Robin__c>();

     String dynamicQuery;

     List<Field_Mapping__mdt> fieldMappingList = [Select Id,Lead_Field_API_Name__c,Round_Robin_Field_API__c,Data_Type__c From Field_Mapping__mdt Where Active__c = true Order By Index__c];
     for(Field_Mapping__mdt fieldMapping : fieldMappingList){
        fieldMappingMetaDataMap.put(fieldMapping.Round_Robin_Field_API__c, fieldMapping);
        leadFieldList.add(fieldMapping.Lead_Field_API_Name__c);
        roundRobinFieldList.add(fieldMapping.Round_Robin_Field_API__c);
     }

     System.debug('Lead Field List::::'+ leadFieldList);
     System.debug('Round Robin List::::'+ roundRobinFieldList);

     if(roundRobinFieldList.size() != 0){
        if(roundRobinFieldList.size() == 1){
            dynamicQuery = roundRobinFieldList[0];
        }

        for(Integer i=0; i<roundRobinFieldList.size(); i++){
            if(i == 0){
                dynamicQuery = roundRobinFieldList[i]+', ';
            }else if(i == roundRobinFieldList.size() - 1){
                dynamicQuery = dynamicQuery + roundRobinFieldList[i];
            }else{
                dynamicQuery = dynamicQuery + roundRobinFieldList[i] + ', ';
            }
        }
     }

     
    String finalQuery = 'Select Id, '+ dynamicQuery + ' From Round_Robin__c Where Is_Active__c = true';
    System.debug('Query Value::::'+ finalQuery);


    List<String> superKeyList = new List<String>();
    Map<String, String> roundRobinFieldDataTypeMap = generateRoundRobinFieldDataType();
    for(String keyValue : roundRobinFieldDataTypeMap.keySet()){
        System.debug('Key Fiel::'+ keyValue);
    }
     System.debug('Map Value::::'+ roundRobinFieldDataTypeMap);
    List<Round_Robin__c> roundRobinList = Database.query(finalQuery);
     for(Round_Robin__c roundRobinRecord : roundRobinList){
        System.debug('Value:::'+ roundRobinRecord);
       // List<String> mainKeyList = new List<String>();
        String tempKey='';

        for(String fieldName : roundRobinFieldList){
            System.debug('Field Name::::'+ fieldName);
            List<String> mainKeyList = new List<String>();
            System.debug('Data Type::::'+ roundRobinFieldDataTypeMap.get(fieldName.toLowerCase()));
            if(roundRobinFieldDataTypeMap.get(fieldName.toLowerCase()) == 'PICKLIST'){
                System.debug('If Condition Passed::');

              if(superKeyList.size() != 0){
                for(String picklistValue : superKeyList){
                    superKeyList.add(picklistValue + roundRobinRecord.get(fieldName));
                }
              }else{
                superKeyList.add(String.valueOf(roundRobinRecord.get(fieldName)));
              }
              mainKeyList = superKeyList.clone();

            }
            else if(roundRobinFieldDataTypeMap.get(fieldName.toLowerCase()) == 'MULTIPICKLIST'){
           
            System.debug('Else Condition Passed::::');
             List<String> picklistValue = String.valueOf(roundRobinRecord.get(fieldName)).split(';');
             System.debug('List Data Type:::'+ picklistValue);
             System.debug('Size::::'+ mainKeyList.size());
            //  if(superKeyList.size() == 0){
            //    for(String fieldKeyValue : picklistValue){
            //     superKeyList.add(fieldKeyValue);
            //    }
            //  }
            //   else{
             for(Integer i=0; i<mainKeyList.size(); i++){
                System.debug('Milti Picklist Value:::'+ mainKeyList[i]);
                List<String> tempKeyList = new List<String>();
                for(Integer j=0; j<picklistValue.size(); j++){
                    tempKeyList.add(mainKeyList[i] + picklistValue[j]);
                }
                System.debug('Temporary Key List::::'+ tempKeyList);
             }
             superKeyList.clear();
             superKeyList = mainKeyList.clone();
             mainKeyList.clear();
            // }
            }
        }

        for(String filedName : roundRobinFieldList){
            tempKey = tempKey + roundRobinRecord.get(filedName);
        }
        if(!roundRobinMap.containsKey(tempKey)){
           roundRobinMap.put(tempKey, roundRobinRecord);
        }
     }

     System.debug('Map Value::::'+ roundRobinMap);
     System.debug('Key List::::'+ superKeyList);

     for(Lead leadRecord : leadList){
        String tempLeadKey = '';
        for(String leadField : leadFieldList){
            tempLeadKey = tempLeadKey + leadRecord.get(leadField);
        }
        System.debug('Custom Key::::'+ tempLeadKey);
        leadRecord.Temp_Round_Robin_Id__c = roundRobinMap.get(tempLeadKey).Id;
     }

    }

    private static Map<String,String> generateRoundRobinFieldDataType(){
        Map<String,String> result = new Map<String,String>();
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Round_Robin__c').getDescribe().fields.getMap();
        for(String objectApiName : objectFields.keySet()){
            Schema.DescribeFieldResult  dataFieldLabel = objectFields.get(objectApiName).getDescribe();
            Schema.DisplayType sObjectdataType = dataFieldLabel.getType();
            String dataType = String.valueOf(sObjectdataType);
            result.put(objectApiName, dataType);
        }
        return result;
    }
}