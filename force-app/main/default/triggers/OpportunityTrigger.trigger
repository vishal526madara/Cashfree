trigger OpportunityTrigger on Opportunity(before insert) {
  if (Trigger.isBefore && Trigger.isInsert) {
    OpportunityTriggerHandler.beforeInsert(Trigger.new);
  }
}
