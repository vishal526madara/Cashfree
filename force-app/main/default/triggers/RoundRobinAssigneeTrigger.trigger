trigger RoundRobinAssigneeTrigger on Round_Robin_Assignee__c (before insert, after update) {
 if(Trigger.isBefore){
    if(Trigger.isInsert ){
      RoundRobinAssigneeTriggerHandler.beforeInsert(trigger.new);
    }
 }

 if(Trigger.isAfter){
    if(Trigger.isupdate && RoundRobinAssigneeTriggerHandler.stopRecursion){
      RoundRobinAssigneeTriggerHandler.afterUpdate(trigger.new,trigger.oldMap);
    }
 }
}