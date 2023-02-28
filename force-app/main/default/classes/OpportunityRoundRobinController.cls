public with sharing class OpportunityRoundRobinController {
  public static List<Opportunity> getOpportunityListWithRoundRobinOwner(
    Map<Id, List<Opportunity>> mapOfRoundRobinIdVsOpportunityList
  ) {
    List<Opportunity> opportunityListWithRoundRobinOwner = new List<Opportunity>();
    if (mapOfRoundRobinIdVsOpportunityList.size() > 0) {
      List<System_Administrator_Holder__mdt> systemAdministratorHolderList = [
        SELECT Id, DeveloperName, MasterLabel, Admin_User_Id__c
        FROM System_Administrator_Holder__mdt
      ];
      Map<Id, Opportunity_Round_Robin__c> roundRobinMap = new Map<Id, Opportunity_Round_Robin__c>(
        [
          SELECT Id, Previous_Active_User__c
          FROM Opportunity_Round_Robin__c
          WHERE Id = :mapOfRoundRobinIdVsOpportunityList.keySet()
        ]
      );
      List<Opportunity_Round_Robin_Assignee__c> roundRobinAssigneeList = [
        SELECT
          Id,
          Opportunity_Round_Robin__c,
          Is_Active__c,
          Order_Number__c,
          User__c
        FROM Opportunity_Round_Robin_Assignee__c
        WHERE
          Opportunity_Round_Robin__c = :roundRobinMap.keySet()
          AND Is_Active__c = TRUE
        ORDER BY Order_Number__c ASC
      ];
      Map<Id, List<Opportunity_Round_Robin_Assignee__c>> roundRobinIdVsAssigneeId = new Map<Id, List<Opportunity_Round_Robin_Assignee__c>>();
      for (
        Opportunity_Round_Robin_Assignee__c roundRobinAssigneeVar : roundRobinAssigneeList
      ) {
        if (
          roundRobinIdVsAssigneeId.containsKey(
            roundRobinAssigneeVar.Opportunity_Round_Robin__c
          )
        ) {
          List<Opportunity_Round_Robin_Assignee__c> existedList = roundRobinIdVsAssigneeId.get(
            roundRobinAssigneeVar.Opportunity_Round_Robin__c
          );
          existedList.add(roundRobinAssigneeVar);
          roundRobinIdVsAssigneeId.put(
            roundRobinAssigneeVar.Opportunity_Round_Robin__c,
            existedList
          );
        } else {
          List<Opportunity_Round_Robin_Assignee__c> sampleList = new List<Opportunity_Round_Robin_Assignee__c>();
          sampleList.add(roundRobinAssigneeVar);
          roundRobinIdVsAssigneeId.put(
            roundRobinAssigneeVar.Opportunity_Round_Robin__c,
            sampleList
          );
        }
      }
      List<Opportunity_Round_Robin__c> roundRobinList = new List<Opportunity_Round_Robin__c>();
      for (Id roundRobinVar : mapOfRoundRobinIdVsOpportunityList.keySet()) {
        if (mapOfRoundRobinIdVsOpportunityList.containsKey(roundRobinVar)) {
          List<Opportunity> tempOpportunityList = mapOfRoundRobinIdVsOpportunityList.get(
            roundRobinVar
          );
          if (roundRobinIdVsAssigneeId.containsKey(roundRobinVar)) {
            List<Opportunity_Round_Robin_Assignee__c> tempRoundRobinAssigneeList = roundRobinIdVsAssigneeId.get(
              roundRobinVar
            );
            if (roundRobinMap.containsKey(roundRobinVar)) {
              Integer countCheck = roundRobinMap.get(roundRobinVar)
                  .Previous_Active_User__c == null
                ? 1
                : Integer.ValueOf(
                      roundRobinMap.get(roundRobinVar).Previous_Active_User__c
                    ) == tempRoundRobinAssigneeList.size()
                    ? 1
                    : Integer.ValueOf(
                        roundRobinMap.get(roundRobinVar).Previous_Active_User__c
                      ) + 1;
              Integer countCheckOpportunityList = 1;
              for (Opportunity opportunityVar : tempOpportunityList) {
                if (tempRoundRobinAssigneeList.size() >= countCheck) {
                  opportunityVar.OwnerId = tempRoundRobinAssigneeList[
                      countCheck - 1
                    ]
                    .User__c;
                  if (tempOpportunityList.size() == countCheckOpportunityList) {
                    Opportunity_Round_Robin__c roundRobinObject = new Opportunity_Round_Robin__c();
                    roundRobinObject.Id = roundRobinVar;
                    roundRobinObject.Previous_Active_User__c = String.valueOf(
                      countCheck
                    );
                    roundRobinList.add(roundRobinObject);
                    countCheckOpportunityList = 0;
                  }
                  if (tempRoundRobinAssigneeList.size() == countCheck) {
                    countCheck = 0;
                  }
                }
                countCheck++;
                countCheckOpportunityList++;
              }
            }
          } else {
            if (systemAdministratorHolderList.size() > 0) {
              for (Opportunity oppVar : tempOpportunityList) {
                oppVar.OwnerId = systemAdministratorHolderList[0]
                  .Admin_User_Id__c;
              }
            }
          }
          opportunityListWithRoundRobinOwner.addAll(tempOpportunityList);
        }
      }
      update roundRobinList;
    }
    return opportunityListWithRoundRobinOwner;
  }
}
