/***
 * @description: handler class to assign owner according to opportunity round robin order
 * @date: NA
 * @updateDate: 21 Nov, 2022
 * @author: Vishal Hembrom
 * ******/
public with sharing class OpportunityTriggerHandler {
  public static Boolean stopRecursion = true;
  public static void beforeInsert(List<Opportunity> oppList) {
    List<Opportunity> inputList = new List<Opportunity>();
    for (Opportunity opp : oppList) {
      if (opp.Converted_from_Lead__c == true) {
        inputList.add(opp);
      }
    }
    if (inputList.size() != 0) {
      roundRobinAssignment(oppList);
    }
  }

  public static void roundRobinAssignment(List<Opportunity> oppList) {
    List<String> opportunityFieldList = new List<String>();
    List<String> roundRobinFieldList = new List<String>();
    Map<Id, List<Opportunity>> oppRoundRobinMap = new Map<Id, List<Opportunity>>();

    Map<Id, List<String>> roundRobinFieldListMap = new Map<Id, List<String>>();
    Map<Id, Opportunity_Round_Robin__c> roundRobinRecordMap = new Map<Id, Opportunity_Round_Robin__c>();
    Map<String, String> metaDataFieldMap = new Map<String, String>();

    //Create Meta Data Round Robin Field Map
    Map<String, Opportunity_Field_Mapping__mdt> fieldMappingMetaDataMap = new Map<String, Opportunity_Field_Mapping__mdt>();

    Map<String, List<Round_Robin__c>> roundRobinMap = new Map<String, List<Round_Robin__c>>();

    String dynamicQuery;

    List<Opportunity_Field_Mapping__mdt> fieldMappingList = [
      SELECT Id, Opportunity_Field_API__c, Round_Robin_Field_API__c
      FROM Opportunity_Field_Mapping__mdt
      WHERE Active__c = TRUE
      ORDER BY Index__c
    ];
    for (Opportunity_Field_Mapping__mdt fieldMapping : fieldMappingList) {
      fieldMappingMetaDataMap.put(
        fieldMapping.Round_Robin_Field_API__c,
        fieldMapping
      );
      opportunityFieldList.add(fieldMapping.Opportunity_Field_API__c);
      roundRobinFieldList.add(fieldMapping.Round_Robin_Field_API__c);

      //Updated 26 Oct,2022
      metaDataFieldMap.put(
        fieldMapping.Round_Robin_Field_API__c,
        fieldMapping.Opportunity_Field_API__c
      );
      /********************************************************************************************* */
    }
    System.debug('Lead Field List::::' + opportunityFieldList);
    System.debug('Round Robin List::::' + roundRobinFieldList);

    if (roundRobinFieldList.size() != 0) {
      if (roundRobinFieldList.size() == 1) {
        dynamicQuery = roundRobinFieldList[0];
      } else {
        for (Integer i = 0; i < roundRobinFieldList.size(); i++) {
          if (i == 0) {
            dynamicQuery = roundRobinFieldList[i] + ', ';
          } else if (i == roundRobinFieldList.size() - 1) {
            dynamicQuery = dynamicQuery + roundRobinFieldList[i];
          } else {
            dynamicQuery = dynamicQuery + roundRobinFieldList[i] + ', ';
          }
        }
      }
    }

    String finalQuery =
      'Select Id,Active_Field__c, ' +
      dynamicQuery +
      ' From Opportunity_Round_Robin__c Where Is_Active__c = true';
    System.debug('Query Value::::' + finalQuery);

    // Updated on 26 Oct,2022
    roundRobinFieldListMap = generateRoundRobinFieldList(finalQuery);
    roundRobinRecordMap = generateRoundRobinRecordMap(finalQuery);

    System.debug('Meta Data Map::::' + metaDataFieldMap);
    System.debug('Custom Map::::' + roundRobinFieldListMap);
    System.debug('Custom Map::::' + roundRobinRecordMap);
    //****************************************************************** */

    for (Opportunity oppRecord : oppList) {
      Integer count = 0;

      for (String oppFieldAPI : metaDataFieldMap.values()) {
        System.debug(
          'Field Count+++' + oppRecord.get(oppFieldAPI) + ' ' + oppFieldAPI
        );
        if (oppRecord.get(oppFieldAPI) != null) {
          count++;
        }
      }

      if (count != 0) {
        for (Id roundRobinId : roundRobinFieldListMap.keySet()) {
          if (roundRobinFieldListMap.get(roundRobinId).size() != 0) {
            Integer tempCount = 0;
            for (String fieldApi : roundRobinFieldListMap.get(roundRobinId)) {
              System.debug(
                'Value::::' +
                roundRobinRecordMap.get(roundRobinId).get(fieldApi)
              );
              String oppFieldApi = metaDataFieldMap.get(fieldApi);
              List<String> tempFieldValueList = createListOfFieldValue(
                roundRobinRecordMap.get(roundRobinId),
                fieldApi
              );
              for (String roundRobinRecordValue : tempFieldValueList) {
                if (roundRobinRecordValue == oppRecord.get(oppFieldApi)) {
                  tempCount++;
                  break;
                }
              }
            }
            System.debug('Temp Count::::' + tempCount);
            if (tempCount == roundRobinFieldListMap.get(roundRobinId).size()) {
              //  if(roundRobinRecordMap.get(roundRobinId).Active_Time__c == true){

              //      if(RoundRobinController.isInTimeZone(roundRobinRecordMap.get(roundRobinId))){

              //          if(!leadRoundRobinMap.containsKey(roundRobinId)){
              //              List<Lead> tempLeadList = new List<Lead>();
              //              tempLeadList.add(oppRecord);
              //              leadRoundRobinMap.put(roundRobinId,tempLeadList);
              //          }else{
              //              leadRoundRobinMap.get(roundRobinId).add(oppRecord);
              //          }
              //          break;
              //      }
              //  }
              //  else{
              if (!oppRoundRobinMap.containsKey(roundRobinId)) {
                List<Opportunity> tempLeadList = new List<Opportunity>();
                tempLeadList.add(oppRecord);
                oppRoundRobinMap.put(roundRobinId, tempLeadList);
              } else {
                oppRoundRobinMap.get(roundRobinId).add(oppRecord);
              }
              break;
              //  }
            }
          }
        }
      }
    }

    List<Opportunity> finalOppList = OpportunityRoundRobinController.getOpportunityListWithRoundRobinOwner(
      oppRoundRobinMap
    );
    System.debug('Final Opportunity List::::' + finalOppList);
  }

  /**
   * @description: method used to create List of field api value according to field data
   *               type if field is picklist it will create list of single string list
   *               and if datatype is picklist and contains multiple value then it will
   *               create multiple value of list
   *@parameter:  Round Robin's Record and Field API Name of Round Robin's Object
   *@result: List of API Field values
   *************/
  private static List<String> createListOfFieldValue(
    Opportunity_Round_Robin__c roundRobin,
    String fieldApi
  ) {
    List<String> result = new List<String>();
    Map<String, String> fieldDataTypeMap = generateRoundRobinFieldDataType();
    if (fieldDataTypeMap.get(fieldApi.toLowerCase()) == 'PICKLIST') {
      String tempVal = String.valueOf(roundRobin.get(fieldApi));
      result.add(tempVal);
    } else if (
      fieldDataTypeMap.get(fieldApi.toLowerCase()) == 'MULTIPICKLIST'
    ) {
      result = generateListofString(String.valueOf(roundRobin.get(fieldApi)));
    }
    return result;
  }

  /**
   * @description: functionality is used to generate Map of all field which is related to Round
   *               Robin Object
   * @parameter : NA
   * @return Map of field API and Data Type of the field
   */
  private static Map<String, String> generateRoundRobinFieldDataType() {
    Map<String, String> result = new Map<String, String>();
    Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe()
      .get('Opportunity_Round_Robin__c')
      .getDescribe()
      .fields.getMap();
    for (String objectApiName : objectFields.keySet()) {
      Schema.DescribeFieldResult dataFieldLabel = objectFields.get(
          objectApiName
        )
        .getDescribe();
      Schema.DisplayType sObjectdataType = dataFieldLabel.getType();
      String dataType = String.valueOf(sObjectdataType);
      result.put(objectApiName, dataType);
    }
    return result;
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
  private static List<String> generateListofString(String fieldValue) {
    System.debug('Temporay Field :::' + fieldValue);
    if (fieldValue.contains(';')) {
      return fieldValue.split(';');
    } else {
      List<String> tempList = new List<String>();
      tempList.add(fieldValue);
      return tempList;
    }
  }

  /**
       * @description: generate map of round robin id with respect to round robin active field
       *               (Round_Robin__c : Active_Field__c) and field contain comma separated field
       *               API of Round Robin's Field 
       * @parameter: create a query by using meta data record of "Field Mapping" Object 
       *             eg: "Select Id,Active_Time__c,On_Duty__c,Off_Duty__c,Active_Field__c, Lead_Source__c, 
                           Lead_Type__c From Round_Robin__c Where Is_Active__c = true" 
       * @return: Map of Id with list of 
       */
  private static Map<Id, List<String>> generateRoundRobinFieldList(
    String dynamicQuery
  ) {
    Map<Id, List<String>> result = new Map<Id, List<String>>();
    for (
      Opportunity_Round_Robin__c roundRobinRecord : Database.query(dynamicQuery)
    ) {
      if (roundRobinRecord.Active_Field__c != null) {
        if (roundRobinRecord.Active_Field__c.contains(',')) {
          result.put(
            roundRobinRecord.Id,
            roundRobinRecord.Active_Field__c.split(',')
          );
        } else {
          List<String> tempList = new List<String>();
          tempList.add(roundRobinRecord.Active_Field__c);
          result.put(roundRobinRecord.Id, tempList);
        }
      }
    }
    return result;
  }

  /** 
       * @description: generate a map to Round Robin Record with respect to the Id
       * @parameter: create a query by using meta data record of "Field Mapping" Object 
       *             eg: "Select Id,Active_Time__c,On_Duty__c,Off_Duty__c,Active_Field__c, Lead_Source__c, 
                           Lead_Type__c From Round_Robin__c Where Is_Active__c = true" 
       * @return: map of round robin record with respect to record id
       */
  private static Map<Id, Opportunity_Round_Robin__c> generateRoundRobinRecordMap(
    String dynamicQuery
  ) {
    Map<Id, Opportunity_Round_Robin__c> result = new Map<Id, Opportunity_Round_Robin__c>();
    for (Opportunity_Round_Robin__c roundRobin : Database.query(dynamicQuery)) {
      result.put(roundRobin.Id, roundRobin);
    }
    return result;
  }
}
