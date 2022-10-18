/**
 * @author: Vishal Hembrom
 * @createdDate: 13 Oct,2022
 *
 */
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
        //roundRobinAssignment(newList);
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
     Map<Id,List<Lead>> leadRoundRobinMap = new Map<Id,List<Lead>>();

     //Create Meta Data Round Robin Field Map
     Map<String,Field_Mapping__mdt> fieldMappingMetaDataMap =  new Map<String,Field_Mapping__mdt>();

     Map<String,List<Round_Robin__c>> roundRobinMap = new Map<String,List<Round_Robin__c>>();

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

     
    String finalQuery = 'Select Id,Start_Time__c,End_Time__c, '+ dynamicQuery + ' From Round_Robin__c Where Is_Active__c = true';
    System.debug('Query Value::::'+ finalQuery);


    List<String> superKeyList = new List<String>();
    Map<String, String> roundRobinFieldDataTypeMap = generateRoundRobinFieldDataType();
    for(String keyValue : roundRobinFieldDataTypeMap.keySet()){
        System.debug('Key Fiel::'+ keyValue);
    }
     System.debug('Map Value::::'+ roundRobinFieldDataTypeMap);
    List<Round_Robin__c> roundRobinList = Database.query(finalQuery);
    System.debug('Length::::'+ roundRobinList.size());
     for(Round_Robin__c roundRobinRecord : roundRobinList){
        List<String> generateKeyList = generateAllKey(roundRobinRecord, roundRobinFieldList);
        for(String roundRobinKey : generateKeyList){
            if(!roundRobinMap.containsKey(roundRobinKey)){
                List<Round_Robin__c> tempList = new List<Round_Robin__c>();
                tempList.add(roundRobinRecord);
                roundRobinMap.put(roundRobinKey,tempList);
            }
            else{
                roundRobinMap.get(roundRobinKey).add(roundRobinRecord);
            }
            
        }
      
     }

     System.debug('Map Record Value::::'+ roundRobinMap);
    for(Lead leadRecord : leadList){
        String tempKey='';
        for(String leadKey : leadFieldList){
           tempKey = tempKey + leadRecord.get(leadKey);
        }
        System.debug('Temporary Key:::::'+ tempKey);
        for(Round_Robin__c  roundRobinRecord : roundRobinMap.get(tempKey)){
            Integer startTime = generateTimeNumber(roundRobinRecord.Start_Time__c);
            Integer endTime = generateTimeNumber(roundRobinRecord.End_Time__c);
            Integer leadRecordTime = generateTimeNumber(generateCurrentTime());
            if(startTime<= leadRecordTime && leadRecordTime <= endTime){
                if(!leadRoundRobinMap.containsKey(roundRobinRecord.Id)){
                    List<Lead> tempLead = new List<Lead>();
                    tempLead.add(leadRecord);
                    leadRoundRobinMap.put(roundRobinRecord.Id, tempLead);
                    //lead record id assignment 
                    leadRecord.Temp_Round_Robin_Id__c = roundRobinRecord.Id;
                }else{
                    leadRoundRobinMap.get(roundRobinRecord.Id).add(leadRecord);
                    leadRecord.Temp_Round_Robin_Id__c = roundRobinRecord.Id;
                }
            }
        }
    }

    List<Lead> finalLeadList = RoundRobinController.getLeadListWithRoundRobinOwner(leadRoundRobinMap);
    System.debug('Final Lead List::::'+ finalLeadList);

    }

    /**
     * @description: functionality is used to generate Map of all field which is related to Round
     *               Robin Object 
     * @parameter : NA
     * @return Map of field API and Data Type of the field
     */
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

    private static List<String> generateAllKey(Round_Robin__c roundRobinRecord, List<String> roundRobinKeyList){
        System.debug('Round Robin List:::::'+ roundRobinKeyList);
        Map<String,List<String>> generateKeyMap = new Map<String,List<String>>();
        Map<String,String> fieldDataTypeMap = generateRoundRobinFieldDataType();
        for(String key : fieldDataTypeMap.keySet()){
            System.debug('Key Value::::'+ key);
            System.debug('Value Set::::'+ fieldDataTypeMap.get(key));
        }
       for(String keyFieldAPI : roundRobinKeyList){
        if(!fieldDataTypeMap.containsKey(keyFieldAPI)){
            System.debug('Data Type:::'+ fieldDataTypeMap.get(keyFieldAPI.toLowerCase()));
           if(fieldDataTypeMap.get(keyFieldAPI.toLowerCase()) == 'PICKLIST'){
            List<String> normalStringList = new List<String>();
            normalStringList.add(String.valueOf(roundRobinRecord.get(keyFieldAPI)));
            generateKeyMap.put(keyFieldAPI, normalStringList);
           }else if(fieldDataTypeMap.get(keyFieldAPI.toLowerCase()) == 'MULTIPICKLIST'){
             List<String> multiValueList = generateListofString(String.valueOf(roundRobinRecord.get(keyFieldAPI)));
             generateKeyMap.put(keyFieldAPI, multiValueList);
           }
        }
        // else{
        //     fieldDataTypeMap.get
        // }
       }
        System.debug('Generate Map Data::::'+ generateKeyMap);
       List<String> resultedStringList = new List<String>();
       for(String keyFieldAPI : roundRobinKeyList){
           System.debug('Key Value:::::'+ keyFieldAPI);
           System.debug('Record:::::'+ generateKeyMap.get(keyFieldAPI).size());
          if(resultedStringList.size() == 0){
            for(Integer i=0; i<generateKeyMap.get(keyFieldAPI).size(); i++){
                resultedStringList.add(generateKeyMap.get(keyFieldAPI).get(i));
            }
        }

            else{
                System.debug('Else Field:::'+ generateKeyMap.get(keyFieldAPI).size());
                List<String> tempList = resultedStringList;
                System.debug('List Data:::'+ tempList);
                System.debug('List Data:::'+ resultedStringList);
                resultedStringList = new List<String>();
                for(Integer j=0; j<tempList.size(); j++){
                    for(Integer k=0; k<generateKeyMap.get(keyFieldAPI).size(); k++){
                        System.debug('Field Value::::'+ tempList[j]);
                        System.debug('Field Value:::'+ generateKeyMap.get(keyFieldAPI).get(k));
                        String tempString = tempList[j]+generateKeyMap.get(keyFieldAPI).get(k);
                        System.debug('List Data:::'+ resultedStringList);
                        resultedStringList.add(tempString);
                    }
                }
            }

       }
       return resultedStringList;
    }


    /**
     * @description: functionlaity is used to create list of string
     * @parameter: String in semicolon format 
     *             eg: Inbound;Web (Due to Multipicklist)
     * @return: List of String 
     *          eg: --------
     *              Inbound
     *              ---------
     *                Web
     *              ---------
     */
    private static List<String> generateListofString(String fieldValue){
       return  fieldValue.split(';');
    }


    /**
     * @description: Generate time in 12hrs format using system time
     *               eg: first one be like 5:05 PM
     *                   second one will be :5:05
     * @parameter : NA
     * @return String of Time in AM or PM
     */
    private static String generateCurrentTime(){
        DateTime dtDateTime = system.now();
        String sTime = dtDateTime.format('h:mm a');
        String sTime1 = dtDateTime.format('h:mm');
        return sTime;
    }

    private static Integer generateTimeNumber(String timeFormat){
        Integer result;
       List<String> timeList = timeFormat.split(':');
       if(timeList[1].contains('PM')){
        result = Integer.valueOf(timeList[0]) + 12;
       }else{
        result = Integer.valueOf(timeList[0]);
       }
       return result;
    }
}