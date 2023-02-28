/**
 * @description       :
 * @author            : Saurav Kashyap
 * @group             : Appstrail
 * @last modified on  : 11-18-2022
 **/
public with sharing class RaiseCaseController {
  /* @Name : - getDiscrepancy()
   * @Description: - During ConnectedCallback(Query Discrepancy__c Records)
   * @Params     : - N/A
   * @ReturnType : - List<Discrepancy__c> Records !!!!
   */
  @AuraEnabled
  public static List<DiscrepancyWrapper> getDiscrepancy() {
    List<DiscrepancyWrapper> discrepList = new List<DiscrepancyWrapper>();
    List<Discrepancy__c> discrepancyRecList = new List<Discrepancy__c>();

    discrepancyRecList = [
      SELECT Id, Discrepancy_Values__c, Index__c, Status__c, Name
      FROM Discrepancy__c
    ];
    System.debug('discrepancyRecList o/p >>' + discrepancyRecList);
    System.debug(
      'discrepancyRecList for size checck >>' + discrepancyRecList.size()
    );

    if (discrepancyRecList.size() > 0) {
      for (Discrepancy__c discrep : discrepancyRecList) {
        DiscrepancyWrapper disWrap = new DiscrepancyWrapper();

        disWrap.discrepValue = discrep.Discrepancy_Values__c;
        discrepList.add(disWrap);
        System.debug('disWrap o/p >>' + disWrap);
        System.debug('discrepList o/p >>' + discrepList);
      }
    }
    System.debug('discrepList o/p >>' + discrepList);
    return discrepList;
  }

  /* @Name : - insertCases()
   * @Description: - Inserting Cases against WorkOrder
   * @Params     : - Current WorkOrder recordId from JS.
   * @ReturnType : - Boolean retuens True when process is done else returns False!!!!
   */
  @AuraEnabled
  public static Boolean insertCases(
    string recordId,
    list<DiscrepancyWrapper> casevalueList
  ) {
    System.debug('recordId o/p >>    ' + recordId);
    System.debug('casevalueList o/p >>   ' + casevalueList);
    WorkOrder wOrderRec = new WorkOrder();
    wOrderRec = [
      SELECT
        Id,
        OwnerId,
        WorkOrderNumber,
        AccountId,
        ContactId,
        CaseId,
        Description,
        Case_For__c,
        Commercial__c,
        Discrepancy__c,
        MID__c,
        Work_Order_SF_Id__c
      FROM WorkOrder
      WHERE Id = :recordId
      LIMIT 1
    ];
    System.debug('wOrderRec o/p >>' + wOrderRec);

    List<Case> caseListToInsert = new List<Case>();
    // Getting Values from the Metadata....
    List<Team_Queue_Record_Type__mdt> teamQueueRecordTypeList = [
      SELECT
        Id,
        DeveloperName,
        Picklist_Value__c,
        Record_Type_Id__c,
        Queue_Id__c,
        Label,
        MasterLabel
      FROM Team_Queue_Record_Type__mdt
    ];
    System.debug('teamQueueRecordTypeList o/p >>' + teamQueueRecordTypeList);
    // mapping the picklist value of metadata record to the metadata record ....
    Map<String, Team_Queue_Record_Type__mdt> pickvalVsMetaDataMap = new Map<String, Team_Queue_Record_Type__mdt>();
    for (
      Team_Queue_Record_Type__mdt teamQueueRecordTypeVar : teamQueueRecordTypeList
    ) {
      pickvalVsMetaDataMap.put(
        teamQueueRecordTypeVar.Picklist_Value__c,
        teamQueueRecordTypeVar
      );
    }
    System.debug('pickvalVsMetaDataMap o/p >>' + pickvalVsMetaDataMap);

    if (wOrderRec != null) {
      for (DiscrepancyWrapper caseValue : casevalueList) {
        Case caseObject = new Case();

        caseObject.MID__c = wOrderRec.MID__c;
        caseObject.Case_For__c = caseValue.caseForValue;
        caseObject.Description = caseValue.discrepValue;
        caseObject.Subject =
          'Discrepancy - ' +
          wOrderRec.WorkOrderNumber +
          ' - ' +
          caseValue.caseForValue;
        caseObject.Work_Job__c = wOrderRec.Id;
        caseObject.AccountId = wOrderRec.AccountId;
        caseObject.ParentId = wOrderRec.CaseId;
        caseObject.RecordTypeId = pickvalVsMetaDataMap.get(
            caseValue.caseForValue
          )
          .Record_Type_Id__c;
        caseObject.OwnerId = pickvalVsMetaDataMap.get(caseValue.caseForValue)
          .Queue_Id__c;
        caseObject.Commercial__c = null;
        caseObject.Sales_Manager__c = null;
        caseListToInsert.add(caseObject);
      }
      if (caseListToInsert.size() > 0) {
        insert caseListToInsert;
        return true;
      }
    }

    return false;
  }

  @AuraEnabled
  public static List<OptionsWrapper> getFieldPicklistValue(
    String objectName,
    String fieldName
  ) {
    return fieldPicklistValue(objectName, fieldName, true);
  }

  public static List<OptionsWrapper> fieldPicklistValue(
    String objectName,
    String fieldName,
    Boolean noneValue
  ) {
    List<OptionsWrapper> optionsWrapperList = new List<OptionsWrapper>();
    Schema.SObjectType sObjectTypeVar = Schema.getGlobalDescribe()
      .get(objectName);
    Schema.DescribeSObjectResult resultVar = sObjectTypeVar.getDescribe();
    Map<String, Schema.SObjectField> sObjectFieldVar = resultVar.fields.getMap();
    Schema.DescribeFieldResult fieldResult = sObjectFieldVar.get(fieldName)
      .getDescribe();
    List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
    if (noneValue) {
      OptionsWrapper optionsWrapperObject = new OptionsWrapper();
      optionsWrapperObject.label = '';
      optionsWrapperObject.value = null;
      optionsWrapperList.add(optionsWrapperObject);
    }
    for (Schema.PicklistEntry pickListVal : picklistEntryList) {
      OptionsWrapper optionsWrapperObject = new OptionsWrapper();
      optionsWrapperObject.label = pickListVal.getLabel();
      optionsWrapperObject.value = pickListVal.getValue();
      optionsWrapperList.add(optionsWrapperObject);
    }
    return optionsWrapperList;
  }

  public class OptionsWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
  }

  public class DiscrepancyWrapper {
    @AuraEnabled
    public String discrepValue { get; set; }
    @AuraEnabled
    public String uniqueId { get; set; }
    @AuraEnabled
    public String checkedValue { get; set; }
    @AuraEnabled
    public String caseForValue { get; set; }
  }
}
