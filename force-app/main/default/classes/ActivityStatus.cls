public without sharing class ActivityStatus {
  public static Map<Id, String> checkAllActivity(List<Id> caseIdList) {
    Map<Id, String> result = new Map<Id, String>();
    Set<Id> parentCaseId = new Set<Id>();
    Set<Id> workOrderIdSet = new Set<Id>();
    Set<Id> caseIdSet = new Set<Id>();
    Map<Id, List<Id>> caseAndWorkOrderMap = new Map<Id, List<Id>>();

    for (Id idValue : caseIdList) {
      caseIdSet.add(idValue);
    }
    for (WorkOrder workOrderRecord : [
      SELECT Id, CaseId
      FROM WorkOrder
      WHERE Id IN :caseIdSet
    ]) {
      if (!caseAndWorkOrderMap.containsKey(workOrderRecord.CaseId)) {
        List<Id> tempList = new List<Id>();
        tempList.add(workOrderRecord.Id);
        caseAndWorkOrderMap.put(workOrderRecord.CaseId, tempList);
      } else {
        caseAndWorkOrderMap.get(workOrderRecord.CaseId).add(workOrderRecord.Id);
      }
    }

    for (Id caseId : caseAndWorkOrderMap.keySet()) {
      for (Id workOrderId : caseAndWorkOrderMap.get(caseId)) {
        workOrderIdSet.add(workOrderId);
      }
    }

    return result;
  }
}
