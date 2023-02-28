public with sharing class uploadCSVController {
  @AuraEnabled
  public static String insertWorkOrder(
    List<WorkOrder> workOrderList,
    String recordId
  ) {
    System.debug('prospectingVehicleList::' + workOrderList);
    System.debug('RecordId:' + recordId);
    for (WorkOrder wOrder : workOrderList) {
      //if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Project__c'){
      system.debug('inside::' + wOrder);
      //invoiceVar.Project__c = recordId;
      //}
      // if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
      //     prospectingVehicleVar.Opportunity__c = recordId;
      // }
    }
    if (workOrderList.size() > 0) {
      upsert workOrderList;
    }
    return 'success';
  }
  @AuraEnabled
  public static String getTemplateApiNames() {
    SObject sObj = (SObject) (Type.forName('Schema.WorkOrder').newInstance());
    List<Schema.FieldSetMember> vehicleImportFSMember = sObj.getSObjectType()
      .getDescribe()
      .fieldSets.getMap()
      .get('Work_Order_Import_Template')
      .getFields();
    System.debug('Field Members Basic Information :: ' + vehicleImportFSMember);
    Set<String> apiNameSetFromFieldSet = new Set<String>();
    for (Schema.FieldSetMember fieldSetMemberVar : vehicleImportFSMember) {
      apiNameSetFromFieldSet.add(fieldSetMemberVar.getFieldPath());
    }
    System.debug('Api Name Set :: ' + apiNameSetFromFieldSet);
    return JSON.serialize(apiNameSetFromFieldSet);
  }
}
