trigger CaseTrigger on Case (after insert) {
    if(Trigger.isAfter && Trigger.isInsert && CaseTriggerHandler.stopRecursion){
        CaseTriggerHandler.afterInsert(Trigger.new);
        //CaseEntitlementHandler.manageEntitlement(Trigger.new);
    }
}