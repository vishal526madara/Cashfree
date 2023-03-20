trigger CaseTrigger on Case (before insert, after insert,after update) {
     system.debug('In trigger');
     if(Trigger.isBefore && Trigger.isInsert){
         
        CaseTriggerHandler.beforeInsert(trigger.new);
     }

    if(Trigger.isAfter && Trigger.isInsert && CaseTriggerHandler.stopRecursion){
        CaseTriggerHandler.afterInsert(Trigger.new);
        //CaseEntitlementHandler.manageEntitlement(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate && CaseTriggerHandler.stopRecursion){
        system.debug('Insie Trigger Update');
        CaseTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        //CaseEntitlementHandler.manageEntitlement(Trigger.new);
    }
}