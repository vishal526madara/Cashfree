public without sharing class WorkOrderTriggerHandler {
  public static void afterUpdate(
    Map<Id, WorkOrder> newWorkOrderMap,
    Map<Id, WorkOrder> oldWorkOrderMap
  ) {
    Map<Id, WorkOrder> interestedWorkOrderMap = new Map<Id, WorkOrder>(
      getPartialInterestedWordOrderMap(newWorkOrderMap, oldWorkOrderMap)
    );
    //createChildCase(interestedWorkOrderMap);
  }

  public static void afterInsert(Map<Id, WorkOrder> newWorkOrderMap) {
    Map<Id, WorkOrder> interestedWorkOrderMap = new Map<Id, WorkOrder>(
      getPartialInterestedWordOrderMapInsert(newWorkOrderMap)
    );
    //createChildCase(interestedWorkOrderMap);
  }

  public static Map<Id, WorkOrder> getPartialInterestedWordOrderMapInsert(
    Map<Id, WorkOrder> newWorkOrderMap
  ) {
    Map<Id, WorkOrder> interestedWorkOrderMap = new Map<Id, WorkOrder>();
    for (Id newWorkOrderIdVar : newWorkOrderMap.keySet()) {
      if (
        (newWorkOrderMap.get(newWorkOrderIdVar).Status ==
        'Action Required Internal') &&
        (newWorkOrderMap.get(newWorkOrderIdVar).Case_For__c != null) &&
        (newWorkOrderMap.get(newWorkOrderIdVar).Discrepancy__c != null)
      ) {
        interestedWorkOrderMap.put(
          newWorkOrderIdVar,
          newWorkOrderMap.get(newWorkOrderIdVar)
        );
      }
    }
    return interestedWorkOrderMap;
  }

  public static Map<Id, WorkOrder> getPartialInterestedWordOrderMap(
    Map<Id, WorkOrder> newWorkOrderMap,
    Map<Id, WorkOrder> oldWorkOrderMap
  ) {
    Map<Id, WorkOrder> interestedWorkOrderMap = new Map<Id, WorkOrder>();
    for (Id newWorkOrderIdVar : newWorkOrderMap.keySet()) {
      if (
        (newWorkOrderMap.get(newWorkOrderIdVar).Status !=
        oldWorkOrderMap.get(newWorkOrderIdVar).Status) &&
        (newWorkOrderMap.get(newWorkOrderIdVar).Status ==
        'Action Required Internal') &&
        (newWorkOrderMap.get(newWorkOrderIdVar).Case_For__c != null) &&
        (newWorkOrderMap.get(newWorkOrderIdVar).Discrepancy__c != null)
      ) {
        interestedWorkOrderMap.put(
          newWorkOrderIdVar,
          newWorkOrderMap.get(newWorkOrderIdVar)
        );
      }
    }
    return interestedWorkOrderMap;
  }

  /**
   * @functionality: Whenever Work Order Status Changes to 'Action Required Internal' State then a new Case will be
   *                 generated Where Case will be child of this current work order.
   *@updatedDate : 22 August, 2022
   *@updatedLine: MID(Merchantsite Identifier) Mapping of Work Order's Case(Parent Case: Onboarding) MID Field
   **/

  public static void createChildCase(
    Map<Id, WorkOrder> interestedWorkOrderMap
  ) {
    Set<Id> caseIdSet = new Set<Id>();
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
    Map<String, Team_Queue_Record_Type__mdt> pickvalVsMetaDataMap = new Map<String, Team_Queue_Record_Type__mdt>();
    for (
      Team_Queue_Record_Type__mdt teamQueueRecordTypeVar : teamQueueRecordTypeList
    ) {
      pickvalVsMetaDataMap.put(
        teamQueueRecordTypeVar.Picklist_Value__c,
        teamQueueRecordTypeVar
      );
    }
    List<Case> caseListToInsert = new List<Case>();
    for (WorkOrder workOrderValue : interestedWorkOrderMap.values()) {
      caseIdSet.add(workOrderValue.CaseId);
    }

    Map<Id, Case> caseMap = new Map<Id, Case>(
      [
        SELECT Id, Sales_Manager__c, MID__c
        FROM Case
        WHERE Id = :caseIdSet
      ]
    );

    for (WorkOrder workOrderVar : interestedWorkOrderMap.values()) {
      Case caseObject = new Case();

      caseObject.MID__c = caseMap.get(workOrderVar.CaseId).MID__c;
      caseObject.Case_For__c = workOrderVar.Case_For__c;
      caseObject.Description = workOrderVar.Discrepancy__c;
      caseObject.Subject =
        'Discrepancy - ' +
        workOrderVar.WorkOrderNumber +
        ' - ' +
        workOrderVar.Case_For__c;
      caseObject.Work_Job__c = workOrderVar.Id;
      caseObject.AccountId = workOrderVar.AccountId;
      caseObject.ParentId = workOrderVar.CaseId;
      caseObject.RecordTypeId = pickvalVsMetaDataMap.get(
          workOrderVar.Case_For__c
        )
        .Record_Type_Id__c;
      caseObject.OwnerId = pickvalVsMetaDataMap.get(workOrderVar.Case_For__c)
        .Queue_Id__c;
      caseObject.Commercial__c = workOrderVar.Commercial__c != null
        ? workOrderVar.Commercial__c
        : null;
      caseObject.Sales_Manager__c = caseMap.get(workOrderVar.CaseId)
          .Sales_Manager__c != null
        ? caseMap.get(workOrderVar.CaseId).Sales_Manager__c
        : null;
      caseListToInsert.add(caseObject);
    }
    if (caseListToInsert.size() > 0) {
      insert caseListToInsert;
    }
  }
}
