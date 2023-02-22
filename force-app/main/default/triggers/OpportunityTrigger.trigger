trigger OpportunityTrigger on Opportunity (before insert) {

    if(trigger.isBefore && trigger.isInsert){
    OpportunityTriggerHandler.beforeInsert(Trigger.new);
    }
}