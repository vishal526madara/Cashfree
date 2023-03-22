/*******************************************************
 * @date:
 * @updateDate: 22 March, 2023
 * @author: Vishal
 **********************************************************/

trigger CaseTrigger on Case(before insert, after insert, after update) {
  if (Trigger.isBefore && Trigger.isInsert) {
    CaseTriggerHandler.beforeInsert(Trigger.new);
  }

  if (Trigger.isAfter && Trigger.isInsert && CaseTriggerHandler.stopRecursion) {
    CaseTriggerHandler.afterInsert(Trigger.new);
    //CaseEntitlementHandler.manageEntitlement(Trigger.new);
  }

  if (Trigger.isAfter && Trigger.isUpdate && CaseTriggerHandler.stopRecursion) {
    system.debug('Insie Trigger Update');
    CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    //CaseEntitlementHandler.manageEntitlement(Trigger.new);
  }
}
