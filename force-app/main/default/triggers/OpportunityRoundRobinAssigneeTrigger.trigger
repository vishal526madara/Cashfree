trigger OpportunityRoundRobinAssigneeTrigger on Opportunity_Round_Robin_Assignee__c(
  before insert,
  after update
) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      OpportunityRoundRobinAssigneeHandler.beforeInsert(Trigger.new);
    }
  }

  if (Trigger.isAfter) {
    System.debug('Function Called:::');
    if (
      Trigger.isupdate && OpportunityRoundRobinAssigneeHandler.stopRecursion
    ) {
      OpportunityRoundRobinAssigneeHandler.afterUpdate(
        Trigger.new,
        Trigger.oldMap
      );
    }
  }
}
