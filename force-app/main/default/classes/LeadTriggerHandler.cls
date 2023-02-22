/**
 * @author: Vishal Hembrom
 * @description: handler class is used in Lead Trigger, Class is reponsible for assignment of
 *               user according to Round Robin wise user List
 * @date: 13 Oct,2022
 * @updatedDate: 26 Oct,2022
 *
 */
public without sharing class LeadTriggerHandler {
  public static Boolean checkStatus = true;
  public static void afterInsert(List<Lead> newList) {
    campaignAssigment(newList);
  }

  public static void beforeInsert(List<Lead> newList) {
    updateExternalEmail(newList, null);
    roundRobinAssignmentFiltering(newList);
    controlLeadScore(checkUTMCampaignValue(newList));
    updateNurtureInsert(newList);
    //roundRobinAssignment(newList);
  }

  public static void beforeUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
    updateExternalEmail(newMap.values(), oldMap);
    roundRobinAssignmentUpdateFiltering(newMap, oldMap);
    controlLeadScore(checkUTMCampaignValue(newMap.values()));
    updateNurtureUpdate(newMap.values(), oldMap);
    //roundRobinAssignment(newList);
  }

  public static void afterUpdate(List<Lead> leadList) {
    opportunityOwnerUpdate(leadList);
    merchantIdUpdateAPICallout(leadList);
  }
  /**
   * @author: Rahul Joshi
   * @description: method to Update Nutured field when lead Status is Nutured during Insertion
   * @date: 30 Jan,2023
   * @updatedDate: 30 Jan,2023
   *
   */
  public static void updateNurtureInsert(List<Lead> newList) {
    for (Lead leadList : newList) {
      if (leadList.LeadSource == 'Inbound' && leadList.Status == 'Nurtured') {
        leadList.Nurtured__c = true;
      } else {
        leadList.Nurtured__c = false;
      }
    }
  }

  /**
   * @author: Rahul Joshi
   * @description: method to Update Nutured field when lead Status is Nutured during Updation
   * @date: 30 Jan,2023
   * @updatedDate: 30 Jan,2023
   *
   */

  public static void updateNurtureUpdate(
    List<Lead> newList,
    Map<Id, Lead> oldMap
  ) {
    for (Lead leadList : newList) {
      if (
        (oldMap.get(leadList.Id).Status != 'Nurtured' &&
        leadList.Status == 'Nurtured') && leadList.LeadSource == 'Inbound'
      ) {
        leadList.Nurtured__c = true;
      } else if (leadList.LeadSource != 'Inbound') {
        leadList.Nurtured__c = false;
      }
    }
  }

  /**
   * @description
   * @author Saurav Kashyap | 15-12-2022
   * @param List<Lead> leadList
   **/
  public static void merchantIdUpdateAPICallout(List<Lead> leadList) {
    if (leadList.size() > 0) {
      for (Lead leadObject : leadList) {
        system.debug('LEAD VALUE  --> ' + leadObject);
        if (
          leadObject.LastName != null &&
          leadObject.Email != null &&
          leadObject.MobilePhone != null
        ) {
          System.debug(
            'leadObject.LastName && leadObject.Email && leadObject.MobilePhone' +
              leadObject.LastName +
              ' ' +
              leadObject.Email +
              ' ' +
              leadObject.Email
          );

          if (leadObject.IsConverted) {
            System.debug('lead IsConverted >>> ' + leadObject.IsConverted);
            System.debug(
              'lead ConvertedAccountId >>> ' + leadObject.ConvertedAccountId
            );

            if (!Test.isRunningTest()) {
              PostAddMerchantQueueableClass queueableCalloutClassObject = new PostAddMerchantQueueableClass(
                leadObject.LastName,
                leadObject.Email,
                String.valueOf(leadObject.MobilePhone),
                leadObject.ConvertedAccountId
              );
              System.debug(
                'queueableCalloutClassObject enqueue >>> ' +
                queueableCalloutClassObject
              );

              ID jobID = System.enqueueJob(queueableCalloutClassObject);
              System.debug('jobID enqueue >>> ' + jobID);
              //PostAddMerchantAPIClass.insert_OR_Method_Callout(leadObject.LastName , leadObject.Email , String.valueOf(leadObject.MobilePhone), leadObject.ConvertedAccountId);
            }
          } else {
            system.debug(
              'EMPTY leadObject.IsConverted --> ' + leadObject.IsConverted
            );
          }
        } else {
          System.debug(
            'ERROR::Some Empty Value ' +
              'leadObject.LastName && leadObject.Email && leadObject.MobilePhone' +
              leadObject.LastName +
              ' ' +
              leadObject.Email +
              ' ' +
              leadObject.MobilePhone
          );
        }
      }
    }
  }
  /**
   * @description
   * @author Saurav Kashyap | 20-12-2022
   * @param String Name
   * @param String Email
   * @param String MobilePhone
   * @param String AccountId
   **/
  // @future(callout = true)
  // public static void futureMerchantIdUpdate(String Name,String Email,String MobilePhone,String AccountId){
  //     PostAddMerchantAPIClass.insert_OR_Method_Callout(Name , Email , MobilePhone, AccountId);
  // }

  public static void updateExternalEmail(
    List<Lead> newList,
    Map<Id, Lead> oldMap
  ) {
    for (Lead ld : newList) {
      if (
        ld.email != null &&
        (oldMap == null ||
        ld.Email != oldMap.get(ld.Id).Email)
      ) {
        ld.Email_External_Id__c = ld.Email;
      }
    }
  }

  public static void campaignAssigment(List<Lead> leadList) {
    try {
      System.debug('Value::' + leadList);
      List<Lead> updateList = new List<Lead>();
      Set<String> campaignId = new Set<String>();
      Map<String, Campaign> campaignMap = new Map<String, Campaign>();
      for (Lead lead : leadList) {
        campaignId.add(lead.External_Campaign_ID__c);
      }

      for (Campaign campaign : [
        SELECT Id, Name, Campaign_ID__c
        FROM Campaign
        WHERE Campaign_ID__c IN :campaignId
      ]) {
        campaignMap.put(campaign.Campaign_ID__c, campaign);
      }
      for (Lead lead : leadList) {
        if (campaignMap.containsKey(lead.External_Campaign_ID__c)) {
          Lead newLead = new Lead();
          newLead.Id = lead.Id;
          newLead.Campaign__c = campaignMap.get(lead.External_Campaign_ID__c)
            .Id;
          updateList.add(newLead);
        }
      }
      if (updateList.size() != 0) {
        System.debug('Value::' + updateList);
        checkStatus = false;
        update updateList;
      }
    } catch (Exception e) {
      System.debug('Error:::' + e.getMessage());
      System.debug('Value::' + e.getLineNumber());
    }
  }

  private static void roundRobinAssignmentUpdateFiltering(
    Map<Id, Lead> newMap,
    Map<Id, Lead> oldMap
  ) {
    List<System_Administrator_Holder__mdt> systemAdministratorHolderList = [
      SELECT Id, DeveloperName, MasterLabel, Admin_User_Id__c
      FROM System_Administrator_Holder__mdt
    ];
    List<Lead> filteredLeadList = new List<Lead>();
    for (Lead leadVar : newMap.values()) {
      System.debug(
        'Lead Owner:::' +
          leadVar.OwnerId +
          '  ' +
          systemAdministratorHolderList[0].Admin_User_Id__c
      );
      if (leadVar.Consider_Round_Robin_Owner_Assignment__c) {
        if (systemAdministratorHolderList.size() > 0) {
          if (
            ((leadVar.Phone != null &&
            oldMap.get(leadVar.Id).Phone == null &&
            oldMap.get(leadVar.Id).MobilePhone == null) ||
            (leadVar.MobilePhone != null &&
            oldMap.get(leadVar.Id).MobilePhone == null &&
            oldMap.get(leadVar.Id).Phone == null)) &&
            (leadVar.OwnerId ==
            systemAdministratorHolderList[0].Admin_User_Id__c ||
            leadVar.CreatedById ==
            systemAdministratorHolderList[0].Admin_User_Id__c)
          ) {
            filteredLeadList.add(leadVar);
          }
        }
      }
    }
    if (filteredLeadList.size() != 0) {
      roundRobinAssignment(filteredLeadList);
    }
  }

  private static void roundRobinAssignmentFiltering(List<Lead> leadList) {
    List<System_Administrator_Holder__mdt> systemAdministratorHolderList = [
      SELECT Id, DeveloperName, MasterLabel, Admin_User_Id__c
      FROM System_Administrator_Holder__mdt
    ];
    List<Lead> filteredLeadList = new List<Lead>();
    for (Lead leadVar : leadList) {
      if (leadVar.Consider_Round_Robin_Owner_Assignment__c) {
        if (leadVar.Phone == null && leadVar.MobilePhone == null) {
          if (systemAdministratorHolderList.size() > 0) {
            leadVar.OwnerId = systemAdministratorHolderList[0].Admin_User_Id__c;
          }
        } else {
          filteredLeadList.add(leadVar);
        }
      }
    }
    roundRobinAssignment(filteredLeadList);
  }

  private static void roundRobinAssignment(List<Lead> leadList) {
    List<String> leadFieldList = new List<String>();
    List<String> roundRobinFieldList = new List<String>();
    Map<Id, List<Lead>> leadRoundRobinMap = new Map<Id, List<Lead>>();

    Map<Id, List<String>> roundRobinFieldListMap = new Map<Id, List<String>>();
    Map<Id, Round_Robin__c> roundRobinRecordMap = new Map<Id, Round_Robin__c>();
    Map<String, String> metaDataFieldMap = new Map<String, String>();

    //Create Meta Data Round Robin Field Map
    Map<String, Field_Mapping__mdt> fieldMappingMetaDataMap = new Map<String, Field_Mapping__mdt>();

    Map<String, List<Round_Robin__c>> roundRobinMap = new Map<String, List<Round_Robin__c>>();

    String dynamicQuery;

    List<Field_Mapping__mdt> fieldMappingList = [
      SELECT Id, Lead_Field_API_Name__c, Round_Robin_Field_API__c
      FROM Field_Mapping__mdt
      WHERE Active__c = TRUE
      ORDER BY Index__c
    ];
    for (Field_Mapping__mdt fieldMapping : fieldMappingList) {
      fieldMappingMetaDataMap.put(
        fieldMapping.Round_Robin_Field_API__c,
        fieldMapping
      );
      leadFieldList.add(fieldMapping.Lead_Field_API_Name__c);
      roundRobinFieldList.add(fieldMapping.Round_Robin_Field_API__c);

      //Updated 26 Oct,2022
      metaDataFieldMap.put(
        fieldMapping.Round_Robin_Field_API__c,
        fieldMapping.Lead_Field_API_Name__c
      );
      /********************************************************************************************* */
    }
    System.debug('Lead Field List::::' + leadFieldList);
    System.debug('Round Robin List::::' + roundRobinFieldList);

    if (roundRobinFieldList.size() != 0) {
      if (roundRobinFieldList.size() == 1) {
        dynamicQuery = roundRobinFieldList[0];
      }

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

    String finalQuery =
      'Select Id,Active_Time__c,On_Duty__c,Off_Duty__c,Active_Field__c, ' +
      dynamicQuery +
      ' From Round_Robin__c Where Is_Active__c = true ORDER BY CreatedDate ASC';
    System.debug('Query Value::::' + finalQuery);

    // Updated on 26 Oct,2022
    roundRobinFieldListMap = generateRoundRobinFieldList(finalQuery);
    roundRobinRecordMap = generateRoundRobinRecordMap(finalQuery);

    System.debug('Meta Data Map::::' + metaDataFieldMap);
    System.debug('Custom Map::::' + roundRobinFieldListMap);
    System.debug('Custom Map::::' + roundRobinRecordMap);
    //****************************************************************** */

    List<System_Administrator_Holder__mdt> systemAdministratorHolderList = [
      SELECT Id, DeveloperName, MasterLabel, Admin_User_Id__c
      FROM System_Administrator_Holder__mdt
    ];

    for (Lead leadRecord : leadList) {
      Integer conditionSatisfactionFieldSize = 0;
      Integer conditionSatisfaction = 0;
      for (Id roundRobinId : roundRobinFieldListMap.keySet()) {
        if (roundRobinFieldListMap.get(roundRobinId).size() != 0) {
          Integer tempCount = 0;
          for (String fieldApi : roundRobinFieldListMap.get(roundRobinId)) {
            System.debug(
              'Value::::' + roundRobinRecordMap.get(roundRobinId).get(fieldApi)
            );
            String leadFieldApi = metaDataFieldMap.get(fieldApi);
            List<String> tempFieldValueList = createListOfFieldValue(
              roundRobinRecordMap.get(roundRobinId),
              fieldApi
            );
            for (String roundRobinRecordValue : tempFieldValueList) {
              if (roundRobinRecordValue == leadRecord.get(leadFieldApi)) {
                tempCount++;
                break;
              }
            }
          }
          System.debug('Temp Count::::' + tempCount);
          if (tempCount == roundRobinFieldListMap.get(roundRobinId).size()) {
            if (roundRobinRecordMap.get(roundRobinId).Active_Time__c == true) {
              if (
                RoundRobinController.isInTimeZone(
                  roundRobinRecordMap.get(roundRobinId)
                )
              ) {
                if (!leadRoundRobinMap.containsKey(roundRobinId)) {
                  List<Lead> tempLeadList = new List<Lead>();
                  tempLeadList.add(leadRecord);
                  leadRoundRobinMap.put(roundRobinId, tempLeadList);
                } else {
                  leadRoundRobinMap.get(roundRobinId).add(leadRecord);
                }
                break;
              } else {
                leadRecord.OwnerId = systemAdministratorHolderList[0]
                  .Admin_User_Id__c;
              }
            } else {
              if (!leadRoundRobinMap.containsKey(roundRobinId)) {
                List<Lead> tempLeadList = new List<Lead>();
                tempLeadList.add(leadRecord);
                leadRoundRobinMap.put(roundRobinId, tempLeadList);
              } else {
                leadRoundRobinMap.get(roundRobinId).add(leadRecord);
              }
              break;
            }
          } else {
            conditionSatisfaction++;
          }
        } else {
          conditionSatisfactionFieldSize++;
        }
      }
      Integer conditionSatisfactionTotalSum =
        conditionSatisfaction + conditionSatisfactionFieldSize;
      if (
        roundRobinFieldListMap.size() == conditionSatisfaction ||
        roundRobinFieldListMap.size() == conditionSatisfactionFieldSize ||
        roundRobinFieldListMap.size() == conditionSatisfactionTotalSum
      ) {
        if (systemAdministratorHolderList.size() > 0) {
          leadRecord.OwnerId = systemAdministratorHolderList[0]
            .Admin_User_Id__c;
        }
      }
    }

    List<Lead> finalLeadList = RoundRobinController.getLeadListWithRoundRobinOwner(
      leadRoundRobinMap
    );
    System.debug('Final Lead List::::' + finalLeadList);
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
    Round_Robin__c roundRobin,
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
      .get('Round_Robin__c')
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
    for (Round_Robin__c roundRobinRecord : Database.query(dynamicQuery)) {
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
  private static Map<Id, Round_Robin__c> generateRoundRobinRecordMap(
    String dynamicQuery
  ) {
    Map<Id, Round_Robin__c> result = new Map<Id, Round_Robin__c>();
    for (Round_Robin__c roundRobin : Database.query(dynamicQuery)) {
      result.put(roundRobin.Id, roundRobin);
    }
    return result;
  }

  private static void controlLeadScore(List<Lead> leadList) {
    //Metadata For Field 1
    List<Lead_Source__mdt> leadSourceMdt = [
      SELECT
        DeveloperName,
        MasterLabel,
        Id,
        NamespacePrefix,
        Label,
        Weightage__c,
        Score__c
      FROM Lead_Source__mdt
    ];
    System.debug('Lead Source Mdt ::: ' + leadSourceMdt);
    Map<String, Lead_Source__mdt> leadSourceMap = new Map<String, Lead_Source__mdt>();
    for (Lead_Source__mdt lsRec : leadSourceMdt) {
      leadSourceMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('Lead Source Mdt (Map) ::: ' + leadSourceMap);

    //Metadata For Field 2
    List<Campaign_Type__mdt> campaignTypeMdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Score__c,
        Weightage__c
      FROM Campaign_Type__mdt
    ];
    System.debug('Campaign Type Mdt ::: ' + campaignTypeMdt);

    Map<String, Campaign_Type__mdt> campaignTypeMap = new Map<String, Campaign_Type__mdt>();
    for (Campaign_Type__mdt lsRec : campaignTypeMdt) {
      campaignTypeMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('Campaign Type Mdt (Map) ::: ' + campaignTypeMap);

    //Metadata For Field 3
    List<Campaign_Subtype__mdt> campaignSubTypeMdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Weightage__c,
        Score__c
      FROM Campaign_Subtype__mdt
    ];
    System.debug('campaign SubType Mdt ::: ' + campaignSubTypeMdt);

    Map<String, Campaign_Subtype__mdt> campaignSubTypeMap = new Map<String, Campaign_Subtype__mdt>();
    for (Campaign_Subtype__mdt lsRec : campaignSubTypeMdt) {
      campaignSubTypeMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('Campaign SubType Mdt (Map) ::: ' + campaignSubTypeMap);

    //Metadata For Field 4
    List<Action_Type__mdt> actionTypeMdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Weightage__c,
        Score__c
      FROM Action_Type__mdt
    ];
    System.debug('Action Type Mdt ::: ' + actionTypeMdt);

    Map<String, Action_Type__mdt> actionTypeMap = new Map<String, Action_Type__mdt>();
    for (Action_Type__mdt lsRec : actionTypeMdt) {
      actionTypeMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('Action Type Mdt (Map) ::: ' + actionTypeMap);

    //metadata for field 5
    List<Lead_Scoring_Website_Check__mdt> leadScoringWebsiteCheckmdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Weightage__c,
        Score__c
      FROM Lead_Scoring_Website_Check__mdt
    ];
    System.debug('leadScoringWebsiteCheckmdt >> ' + leadScoringWebsiteCheckmdt);

    Map<String, Lead_Scoring_Website_Check__mdt> leadScoringWebsiteCheckMap = new Map<String, Lead_Scoring_Website_Check__mdt>();
    for (Lead_Scoring_Website_Check__mdt lsRec : leadScoringWebsiteCheckmdt) {
      leadScoringWebsiteCheckMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('leadScoringWebsiteCheckMap >> ' + leadScoringWebsiteCheckMap);

    for (Lead leadVar : leadList) {
      List<ChildWrapper> leadChildWrapper = new List<ChildWrapper>();
      ChildWrapper websiteW = new ChildWrapper();
      ChildWrapper leadSourceW = new ChildWrapper();
      ChildWrapper actiontypeW = new ChildWrapper();
      ChildWrapper campaignTypeW = new ChildWrapper();
      ChildWrapper campaignSubTypeW = new ChildWrapper();
      if (leadVar.Website != null) {
        Boolean bool = false;
        String str = string.valueof(leadVar.Website);
        System.debug('str ' + str);
        bool = validateWebsite(str);
        System.debug('bool ' + bool);
        if (bool == false) {
          if (leadScoringWebsiteCheckMap.containsKey('Valid')) {
            Lead_Scoring_Website_Check__mdt lswc_MDT = new Lead_Scoring_Website_Check__mdt();
            lswc_MDT = leadScoringWebsiteCheckMap.get('Valid');
            websiteW.field = 'Website';
            websiteW.points = Integer.ValueOf(lswc_MDT.Score__c);
            websiteW.weightage = Integer.ValueOf(lswc_MDT.Weightage__c);
            System.debug('websiteW.points Valid >> ' + websiteW.points);
            System.debug('websiteW.weightage Valid >> ' + websiteW.weightage);
          } else {
            websiteW.points = 0;
            websiteW.weightage = 45;
            websiteW.field = 'Website';
            System.debug('websiteW >> ' + websiteW);
          }
        } else {
          if (leadScoringWebsiteCheckMap.containsKey('Default')) {
            Lead_Scoring_Website_Check__mdt lswc_MDT = new Lead_Scoring_Website_Check__mdt();
            lswc_MDT = leadScoringWebsiteCheckMap.get('Default');
            websiteW.field = 'Website';
            websiteW.points = Integer.ValueOf(lswc_MDT.Score__c);
            websiteW.weightage = Integer.ValueOf(lswc_MDT.Weightage__c);
            System.debug('websiteW.points Default >> ' + websiteW.points);
            System.debug('websiteW.weightage Default >> ' + websiteW.weightage);
          } else {
            websiteW.points = 0;
            websiteW.weightage = 45;
            websiteW.field = 'Website';
            System.debug('websiteW >> ' + websiteW);
          }
        }
        leadChildWrapper.add(websiteW);
      } else {
        if (leadScoringWebsiteCheckMap.containsKey('Default')) {
          Lead_Scoring_Website_Check__mdt lswc_MDT = new Lead_Scoring_Website_Check__mdt();
          lswc_MDT = leadScoringWebsiteCheckMap.get('Default');
          websiteW.field = 'Website';
          websiteW.points = Integer.ValueOf(lswc_MDT.Score__c);
          websiteW.weightage = Integer.ValueOf(lswc_MDT.Weightage__c);
          System.debug('websiteW.points Default >> ' + websiteW.points);
          System.debug('websiteW.weightage Default >> ' + websiteW.weightage);
        } else {
          websiteW.points = 0;
          websiteW.weightage = 45;
          websiteW.field = 'Website';
          System.debug('websiteW >> ' + websiteW);
        }
        leadChildWrapper.add(websiteW);
        System.debug('websiteW >> ' + websiteW);
      }

      if (leadVar.Lead_Type__c != null) {
        System.debug(
          'leadSourceMap.containsKey(leadVar.LeadSource) >> ' +
          leadSourceMap.containsKey(leadVar.Lead_Type__c)
        );
        System.debug('Print KK :: ' + leadSourceMap.keySet());
        System.debug('Print KK 2 :: ' + leadVar.Lead_Type__c);
        //if(leadSourceMap.containsKey(leadVar.LeadSource)){
        if (leadSourceMap.containsKey(leadVar.Lead_Type__c)) {
          Lead_Source__mdt ls_MDT = new Lead_Source__mdt();
          //ls_MDT =leadSourceMap.get(leadVar.LeadSource);
          ls_MDT = leadSourceMap.get(leadVar.Lead_Type__c);
          //leadSourceW.field = 'LeadSource';
          leadSourceW.field = 'Lead_Type__c';
          leadSourceW.points = Integer.ValueOf(ls_MDT.Score__c);
          leadSourceW.weightage = Integer.ValueOf(ls_MDT.Weightage__c);
          System.debug('leadSourceW.points >> ' + leadSourceW.points);
          System.debug('leadSourceW.weightage >> ' + leadSourceW.weightage);
        } else {
          if (leadSourceMap.containsKey('Default')) {
            Lead_Source__mdt ls_MDT = new Lead_Source__mdt();
            ls_MDT = leadSourceMap.get('Default');
            leadSourceW.field = 'Lead_Type__c';
            leadSourceW.points = Integer.ValueOf(ls_MDT.Score__c);
            leadSourceW.weightage = Integer.ValueOf(ls_MDT.Weightage__c);
            System.debug('leadSourceW.points default >> ' + leadSourceW.points);
            System.debug(
              'leadSourceW.weightage default >> ' + leadSourceW.weightage
            );
          } else {
            leadSourceW.points = 0;
            leadSourceW.weightage = 20;
            //leadSourceW.field = 'LeadSource';
            leadSourceW.field = 'Lead_Type__c';
            System.debug('leadSourceW >> ' + leadSourceW);
          }
        }
        leadChildWrapper.add(leadSourceW);
        System.debug('leadSourceW >> ' + leadSourceW);
      } else {
        if (leadSourceMap.containsKey('Default')) {
          Lead_Source__mdt ls_MDT = new Lead_Source__mdt();
          ls_MDT = leadSourceMap.get('Default');
          leadSourceW.field = 'Lead_Type__c';
          leadSourceW.points = Integer.ValueOf(ls_MDT.Score__c);
          leadSourceW.weightage = Integer.ValueOf(ls_MDT.Weightage__c);
          System.debug('leadSourceW.points default >> ' + leadSourceW.points);
          System.debug(
            'leadSourceW.weightage default >> ' + leadSourceW.weightage
          );
        } else {
          leadSourceW.points = 0;
          leadSourceW.weightage = 20;
          //leadSourceW.field = 'LeadSource';
          leadSourceW.field = 'Lead_Type__c';
          System.debug('leadSourceW >> ' + leadSourceW);
        }
        leadChildWrapper.add(leadSourceW);
        System.debug('leadSourceW >> ' + leadSourceW);
      }

      if (leadVar.Action_Type__c != null) {
        System.debug(
          'actionTypeMap.containsKey(leadVar.Action_Type__c) >> ' +
          actionTypeMap.containsKey(leadVar.Action_Type__c)
        );
        if (actionTypeMap.containsKey(leadVar.Action_Type__c)) {
          Action_Type__mdt at_MDT = new Action_Type__mdt();

          at_MDT = actionTypeMap.get(leadVar.Action_Type__c);

          actiontypeW.field = 'Action_Type__c';
          actiontypeW.points = Integer.ValueOf(at_MDT.Score__c);
          actiontypeW.weightage = Integer.ValueOf(at_MDT.Weightage__c);

          System.debug('actiontypeW.points >> ' + actiontypeW.points);
          System.debug('actiontypeW.weightage >> ' + actiontypeW.weightage);
        } else {
          if (actionTypeMap.containsKey('Default')) {
            Action_Type__mdt at_MDT = new Action_Type__mdt();

            at_MDT = actionTypeMap.get('Default');

            actiontypeW.field = 'Action_Type__c';
            actiontypeW.points = Integer.ValueOf(at_MDT.Score__c);
            actiontypeW.weightage = Integer.ValueOf(at_MDT.Weightage__c);

            System.debug('actiontypeW.points >> ' + actiontypeW.points);
            System.debug('actiontypeW.weightage >> ' + actiontypeW.weightage);
          } else {
            actiontypeW.points = 0;
            actiontypeW.weightage = 10;
            actiontypeW.field = 'Action_Type__c';
            System.debug('actiontypeW >> ' + actiontypeW);
          }
        }
        leadChildWrapper.add(actiontypeW);
        System.debug('actiontypeW >> ' + actiontypeW);
      } else {
        if (actionTypeMap.containsKey('Default')) {
          Action_Type__mdt at_MDT = new Action_Type__mdt();

          at_MDT = actionTypeMap.get('Default');

          actiontypeW.field = 'Action_Type__c';
          actiontypeW.points = Integer.ValueOf(at_MDT.Score__c);
          actiontypeW.weightage = Integer.ValueOf(at_MDT.Weightage__c);

          System.debug('actiontypeW.points >> ' + actiontypeW.points);
          System.debug('actiontypeW.weightage >> ' + actiontypeW.weightage);
        } else {
          actiontypeW.points = 0;
          actiontypeW.weightage = 10;
          actiontypeW.field = 'Action_Type__c';
        }
        leadChildWrapper.add(actiontypeW);
        System.debug('actiontypeW >> ' + actiontypeW);
      }

      if (leadVar.Campaign_Type__c != null) {
        System.debug(
          'actionTypeMap.containsKey(leadVar.Campaign_Type__c) >> ' +
          actionTypeMap.containsKey(leadVar.Campaign_Type__c)
        );
        if (campaignTypeMap.containsKey(leadVar.Campaign_Type__c)) {
          Campaign_Type__mdt ct_MDT = new Campaign_Type__mdt();
          ct_MDT = campaignTypeMap.get(leadVar.Campaign_Type__c);
          campaignTypeW.field = 'Campaign_Type__c';
          campaignTypeW.points = Integer.ValueOf(ct_MDT.Score__c);
          campaignTypeW.weightage = Integer.ValueOf(ct_MDT.Weightage__c);
          System.debug('campaignTypeW.points >> ' + campaignTypeW.points);
          System.debug('campaignTypeW.weightage >> ' + campaignTypeW.weightage);
        } else {
          if (campaignTypeMap.containsKey('Default')) {
            Campaign_Type__mdt ct_MDT = new Campaign_Type__mdt();
            ct_MDT = campaignTypeMap.get('Default');
            campaignTypeW.field = 'Campaign_Type__c';
            campaignTypeW.points = Integer.ValueOf(ct_MDT.Score__c);
            campaignTypeW.weightage = Integer.ValueOf(ct_MDT.Weightage__c);
            System.debug('campaignTypeW.points >> ' + campaignTypeW.points);
            System.debug(
              'campaignTypeW.weightage >> ' + campaignTypeW.weightage
            );
          } else {
            campaignTypeW.points = 0;
            campaignTypeW.weightage = 20;
            campaignTypeW.field = 'Campaign_Type__c';
            System.debug('campaignTypeW >> ' + campaignTypeW);
          }
        }
        leadChildWrapper.add(campaignTypeW);
        System.debug('campaignTypeW >> ' + campaignTypeW);
      } else {
        if (campaignTypeMap.containsKey('Default')) {
          Campaign_Type__mdt ct_MDT = new Campaign_Type__mdt();
          ct_MDT = campaignTypeMap.get('Default');
          campaignTypeW.field = 'Campaign_Type__c';
          campaignTypeW.points = Integer.ValueOf(ct_MDT.Score__c);
          campaignTypeW.weightage = Integer.ValueOf(ct_MDT.Weightage__c);
          System.debug('campaignTypeW.points >> ' + campaignTypeW.points);
          System.debug('campaignTypeW.weightage >> ' + campaignTypeW.weightage);
        } else {
          campaignTypeW.points = 0;
          campaignTypeW.weightage = 20;
          campaignTypeW.field = 'Campaign_Type__c';
          System.debug('campaignTypeW >> ' + campaignTypeW);
        }
        leadChildWrapper.add(campaignTypeW);
        System.debug('campaignTypeW >> ' + campaignTypeW);
      }

      if (leadVar.Campaign_Sub_type__c != null) {
        System.debug(
          'campaignSubTypeMap.containsKey(leadVar.Campaign_Sub_type__c) >> ' +
          campaignSubTypeMap.containsKey(leadVar.Campaign_Sub_type__c)
        );
        if (campaignSubTypeMap.containsKey(leadVar.Campaign_Sub_type__c)) {
          Campaign_Subtype__mdt cst_MDT = new Campaign_Subtype__mdt();
          cst_MDT = campaignSubTypeMap.get(leadVar.Campaign_Sub_type__c);

          campaignSubTypeW.field = 'Campaign_Sub_type__c';
          campaignSubTypeW.points = Integer.ValueOf(cst_MDT.Score__c);
          campaignSubTypeW.weightage = Integer.ValueOf(cst_MDT.Weightage__c);
          System.debug('campaignSubTypeW.points >> ' + campaignSubTypeW.points);
          System.debug(
            'campaignSubTypeW.weightage >> ' + campaignSubTypeW.weightage
          );
        } else {
          if (campaignSubTypeMap.containsKey('Default')) {
            Campaign_Subtype__mdt cst_MDT = new Campaign_Subtype__mdt();
            cst_MDT = campaignSubTypeMap.get('Default');

            campaignSubTypeW.field = 'Campaign_Sub_type__c';
            campaignSubTypeW.points = Integer.ValueOf(cst_MDT.Score__c);
            campaignSubTypeW.weightage = Integer.ValueOf(cst_MDT.Weightage__c);
            System.debug(
              'campaignSubTypeW.points >> ' + campaignSubTypeW.points
            );
            System.debug(
              'campaignSubTypeW.weightage >> ' + campaignSubTypeW.weightage
            );
          } else {
            campaignSubTypeW.points = 0;
            campaignSubTypeW.weightage = 5;
            campaignSubTypeW.field = 'Campaign_Sub_type__c';
            System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
          }
        }
        leadChildWrapper.add(campaignSubTypeW);
        System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
      } else {
        if (campaignSubTypeMap.containsKey('Default')) {
          Campaign_Subtype__mdt cst_MDT = new Campaign_Subtype__mdt();
          cst_MDT = campaignSubTypeMap.get('Default');

          campaignSubTypeW.field = 'Campaign_Sub_type__c';
          campaignSubTypeW.points = Integer.ValueOf(cst_MDT.Score__c);
          campaignSubTypeW.weightage = Integer.ValueOf(cst_MDT.Weightage__c);
          System.debug('campaignSubTypeW.points >> ' + campaignSubTypeW.points);
          System.debug(
            'campaignSubTypeW.weightage >> ' + campaignSubTypeW.weightage
          );
        } else {
          campaignSubTypeW.points = 0;
          campaignSubTypeW.weightage = 5;
          campaignSubTypeW.field = 'Campaign_Sub_type__c';
          System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
        }
        leadChildWrapper.add(campaignSubTypeW);
        System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
      }

      Decimal sumPoint = 0.0;
      Integer sumWeightage = 0;
      for (ChildWrapper chldWrap : leadChildWrapper) {
        System.debug('chldWrap where it is breaking::::: >  >> ' + chldWrap);
        sumPoint += (chldWrap.points * Integer.ValueOf(chldWrap.weightage));
        sumWeightage += Integer.ValueOf(chldWrap.weightage);
        System.debug('sumPoint >> ' + sumPoint);
        System.debug('sumWeightage >> ' + sumWeightage);
      }
      leadVar.Lead_Score__c = sumPoint / 100;
      System.debug('leadWrapperRec.totalPoints >> ' + leadVar.Lead_Score__c);
    }
  }

  public static Boolean validateWebsite(String Website) {
    Boolean result;
    //^ ((https?|ftp|smtp)://)?(www.)?  at starting
    // +(/[a-zA-Z0-9#])+/? *$at last
    String WebsiteREGEX = '[a-z0-9]+.[a-z]';
    // Create a new Pattern object "yourPattern" with Regex for Website
    Pattern yourPattern = Pattern.compile(WebsiteREGEX);
    // Create a new Pattern object "Mymatcher" with Regex for Website
    Matcher Mymatcher = yourPattern.matcher(Website);
    //Verify the match (Returns "true" if matches otherwise "false")
    result = Mymatcher.matches();
    return result;
  }

  /**
   * @description: method used to check what is the field value of UTM Campaign
   *               if value gets matched with UTM Sub Campaign then UTM Sub Campaign
   *               field gets update otherwise it remains same
   * @parameter: List of Leads
   * @return: List Of Lead
   */
  private static List<Lead> checkUTMCampaignValue(List<Lead> leadList) {
    Map<String, String> campaignSubTypeMap = new Map<String, String>();
    Schema.DescribeFieldResult fieldList = Lead.Campaign_Sub_type__c.getDescribe();
    List<Schema.PicklistEntry> picklistEntry = fieldList.getPicklistValues();

    for (Schema.PicklistEntry pickVal : picklistEntry) {
      campaignSubTypeMap.put(pickVal.getLabel(), pickVal.getValue());
    }

    for (Lead leadRecord : leadList) {
      if (
        leadRecord.UTM_Campaign__c != null &&
        campaignSubTypeMap.containsKey(leadRecord.UTM_Campaign__c)
      ) {
        leadRecord.Campaign_Sub_type__c = campaignSubTypeMap.get(
          leadRecord.UTM_Campaign__c
        );
      } else {
        leadRecord.Campaign_Sub_type__c = null;
      }
    }
    return leadList;
  }

  private static void opportunityOwnerUpdate(List<Lead> leadList) {
    List<Account> updateAccountList = new List<Account>();
    List<Contact> updateContactList = new List<Contact>();
    Set<Id> oppIdSet = new Set<Id>();
    for (Lead leadRecord : leadList) {
      if (leadRecord.IsConverted) {
        oppIdSet.add(leadRecord.ConvertedOpportunityId);
      }
    }
    if (AccountTriggerHandler.isCreated) {
      Map<Id, Id> oppWithOwnerIdMap = new Map<Id, Id>();
      for (Opportunity opp : [
        SELECT Id, OwnerId
        FROM Opportunity
        WHERE Id IN :oppIdSet
      ]) {
        oppWithOwnerIdMap.put(opp.Id, opp.OwnerId);
      }

      for (Lead leadRecord : leadList) {
        if (oppWithOwnerIdMap.containsKey(leadRecord.ConvertedOpportunityId)) {
          Account acc = new Account();
          acc.Id = leadRecord.ConvertedAccountId;
          acc.OwnerId = oppWithOwnerIdMap.get(
            leadRecord.ConvertedOpportunityId
          );
          updateAccountList.add(acc);

          Contact con = new Contact();
          con.Id = leadRecord.ConvertedContactId;
          con.OwnerId = oppWithOwnerIdMap.get(
            leadRecord.ConvertedOpportunityId
          );
          updateContactList.add(con);
        }
      }

      System.debug('Update Account List::::' + updateAccountList);
      if (updateAccountList.size() != 0) {
        update updateAccountList;
      }

      if (updateContactList.size() != 0) {
        update updateContactList;
      }
    } else {
      Set<Id> accIdSet = new Set<Id>();
      Map<Id, Id> accountOwnerMap = new Map<Id, Id>();
      List<Opportunity> updateOppList = new List<Opportunity>();

      for (Lead leadRecord : leadList) {
        accIdSet.add(leadRecord.ConvertedAccountId);
      }

      for (Account acc : [
        SELECT Id, OwnerId
        FROM Account
        WHERE Id IN :accIdSet
      ]) {
        accountOwnerMap.put(acc.Id, acc.OwnerId);
      }

      for (Lead leadRecord : leadList) {
        if (leadRecord.IsConverted) {
          Contact con = new Contact();
          con.Id = leadRecord.ConvertedContactId;
          con.OwnerId = accountOwnerMap.get(leadRecord.ConvertedAccountId);
          updateContactList.add(con);

          Opportunity opp = new Opportunity();
          opp.Id = leadRecord.ConvertedOpportunityId;
          opp.OwnerId = accountOwnerMap.get(leadRecord.ConvertedAccountId);
          updateOppList.add(opp);
        }
      }

      if (updateContactList.size() != 0) {
        update updateContactList;
      }

      if (updateOppList.size() != 0) {
        update updateOppList;
      }
    }
  }

  public class ChildWrapper {
    @AuraEnabled
    public Integer points { get; set; }
    @AuraEnabled
    public Integer weightage { get; set; }
    @AuraEnabled
    public String field { get; set; }
  }
}
