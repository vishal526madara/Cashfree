trigger OpportunityRoundRobinAssigneeTrigger on Opportunity_Round_Robin_Assignee__c (before insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert ){
            OpportunityRoundRobinAssigneeHandler.beforeInsert(trigger.new);
        }
     }
    
     if(Trigger.isAfter){
        System.debug('Function Called:::');
        if(Trigger.isupdate && OpportunityRoundRobinAssigneeHandler.stopRecursion){
            OpportunityRoundRobinAssigneeHandler.afterUpdate(trigger.new,trigger.oldMap);
        }
     }
}