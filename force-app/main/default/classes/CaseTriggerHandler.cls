public class CaseTriggerHandler {
  public static Boolean stopRecursion = true;
  public static void afterInsert(List<Case> caseList) {
    System.debug('inside before insert');
    assignRecordTypeId(caseList);
  }

  public static void afterUpdate(List<Case> caseList, Map<id, Case> oldMap) {
    System.debug('inside before insert');
    changeStatusToPendencyCleared(caseList, oldMap);
  }

  public static void assignRecordTypeId(List<Case> caseList) {
    System.debug('inside assign record type id');
    List<Case> updateList = new List<Case>();
    Map<String, RecordType> caseRecordMap = new Map<String, RecordType>();
    for (RecordType recType : [
      SELECT Id, Name, DeveloperName, SobjectType, IsActive
      FROM RecordType
      WHERE SObjectType = 'Case' AND IsActive = TRUE
    ]) {
      System.debug('recType: ' + recType);
      caseRecordMap.put(recType.DeveloperName, recType);
    }

    List<Group> queue = [
      SELECT Id, Name, DeveloperName, Type
      FROM Group
      WHERE Type = 'Queue' AND DeveloperName = 'Onboarding_Team'
      LIMIT 1
    ];

    for (Case caseRecord : caseList) {
      System.debug('caseRecord: ' + caseRecord);
      if (caseRecord.Case_For__c != null) {
        Case tempCase = new Case();
        tempCase.Id = caseRecord.Id;
        System.debug('case for: ' + caseRecord.Case_For__c);
        if (caseRecord.Case_For__c == 'Onboarding Team') {
          tempCase.RecordTypeId = caseRecordMap.get('Onboarding_Team').Id;
          System.debug('inside onboarding team');
          System.debug('caseRecord RecordTypeId:' + caseRecord.RecordTypeId);
          System.debug('caseRecord after update:' + caseRecord);
          tempCase.OwnerId = queue[0].Id;
        } else if (caseRecord.Case_For__c == 'Bank Ops Team') {
          tempCase.RecordTypeId = caseRecordMap.get('Bank_Ops').Id;
          System.debug('inside bank ops');
        } else if (caseRecord.Case_For__c == 'Risk Team') {
          tempCase.RecordTypeId = caseRecordMap.get('Risk_Team').Id;
        } else if (caseRecord.Case_For__c == 'SC') {
          tempCase.RecordTypeId = caseRecordMap.get('Sales_Coordinator').Id;
        }
        updateList.add(tempCase);
      }
    }
    if (updateList.size() != 0) {
      stopRecursion = false;
      update updateList;
    }
  }

  public static void changeStatusToPendencyCleared(
    List<Case> caseList,
    Map<Id, Case> oldMap
  ) {
    Set<Id> caseIdSet = new Set<id>();
    for (Case cas : caseList) {
      if (
        cas.parentId != null &&
        cas.isClosed == true &&
        cas.status != oldMap.get(cas.Id).status
      ) {
        caseIdSet.add(cas.ParentId);
      }
    }

    if (caseIdSet.size() > 0) {
      List<Case> parentCaseList = [
        SELECT Id, (SELECT id, status FROM Cases WHERE isClosed = FALSE)
        FROM Case
        WHERE Id IN :caseIdSet AND status = 'Pending'
      ];

      Map<String, List<Task>> caseWithTaskMap = new Map<String, List<Task>>();
      for (Task tsk : [
        SELECT Id, WhatId
        FROM Task
        WHERE Status != 'Completed' AND WhatId IN :caseIdSet
      ]) {
        if (!caseWithTaskMap.containsKey(tsk.WhatId))
          caseWithTaskMap.put(tsk.WhatId, new List<Task>());
        caseWithTaskMap.get(tsk.WhatId).add(tsk);
      }

      List<case> caseToUpdateList = new List<Case>();
      for (Case cs : parentCaseList) {
        if (cs.cases.size() > 0)
          continue;

        if (
          caseWithTaskMap.containsKey(cs.Id) &&
          caseWithTaskMap.get(cs.Id).size() > 0
        )
          continue;

        cs.status = 'Pendency Cleared';
        caseToUpdateList.add(cs);
      }

      if (caseToUpdateList.size() > 0)
        update caseToUpdateList;
    }
  }
}
