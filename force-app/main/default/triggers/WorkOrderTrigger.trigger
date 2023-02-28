trigger WorkOrderTrigger on WorkOrder(
  before insert,
  after insert,
  after update
) {
  // if(Trigger.isBefore && Trigger.isInsert){
  //     OrderEntitlementHandler.manageEntitlement(Trigger.new);
  // }

  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      OrderEntitlementHandler.manageEntitlement(Trigger.new);
    }
  }

  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      WorkOrderTriggerHandler.afterInsert(Trigger.newMap);
    }
    if (Trigger.isUpdate) {
      WorkOrderTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
  }
}
