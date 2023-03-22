public without sharing class CaseRoundRobinController {
   

    public static List<Case> getCaseWithRoundRobinOwner(Map<String, List<Case>> profileAndCaseMap){
        System.debug('Profile Map:::::'+ profileAndCaseMap);
        System.debug('Map Size:::::'+ profileAndCaseMap.size());

        Map<Id, List<Case>> mapOfRoundRobinIdVsCaseList = new Map<Id, List<Case>>();

        for(Case_Round_Robin__c caseRoundRobin : [Select Id, ProfileName__c From Case_Round_Robin__c Where ProfileName__c IN: profileAndCaseMap.keySet()]){
            System.debug('Case Round Robin::::'+ caseRoundRobin);
            mapOfRoundRobinIdVsCaseList.put(caseRoundRobin.Id, profileAndCaseMap.get(caseRoundRobin.ProfileName__c));
        }

        List<Case> caseListWithRoundRobinOwner = new List<Case>();
        if(mapOfRoundRobinIdVsCaseList.size()>0){
            
            Map<Id, Case_Round_Robin__c> roundRobinMap = new Map<Id, Case_Round_Robin__c>([SELECT Id, Previous_Active_User__c 
            FROM Case_Round_Robin__c WHERE Id =: mapOfRoundRobinIdVsCaseList.keySet()]);
            List<Case_RoundRobin_Asignee__c> roundRobinAssigneeList = [SELECT Id, Case_Round_Robin__c, Is_Active__c, Order_Number__c, 
            User__c FROM Case_RoundRobin_Asignee__c WHERE Case_Round_Robin__c =: roundRobinMap.keySet() AND Is_Active__c = true 
            ORDER BY Order_Number__c ASC];
            Map<Id, List<Case_RoundRobin_Asignee__c>> roundRobinIdVsAssigneeId = new Map<Id, List<Case_RoundRobin_Asignee__c>>();
            for(Case_RoundRobin_Asignee__c roundRobinAssigneeVar : roundRobinAssigneeList){
                if(roundRobinIdVsAssigneeId.containsKey(roundRobinAssigneeVar.Case_Round_Robin__c)){
                    List<Case_RoundRobin_Asignee__c> existedList = roundRobinIdVsAssigneeId.get(roundRobinAssigneeVar.Case_Round_Robin__c);
                    existedList.add(roundRobinAssigneeVar);
                    roundRobinIdVsAssigneeId.put(roundRobinAssigneeVar.Case_Round_Robin__c, existedList);
                }else{
                    List<Case_RoundRobin_Asignee__c> sampleList = new List<Case_RoundRobin_Asignee__c>();
                    sampleList.add(roundRobinAssigneeVar);
                    roundRobinIdVsAssigneeId.put(roundRobinAssigneeVar.Case_Round_Robin__c,sampleList);
                }
            }
            List<Case_Round_Robin__c> roundRobinList = new List<Case_Round_Robin__c>();
            for(Id roundRobinVar: mapOfRoundRobinIdVsCaseList.keySet()){
                if(mapOfRoundRobinIdVsCaseList.containsKey(roundRobinVar)){
                    List<Case> tempCaseList = mapOfRoundRobinIdVsCaseList.get(roundRobinVar);
                    List<Case> finalTempCaseList = new List<Case>();
                    if(roundRobinIdVsAssigneeId.containsKey(roundRobinVar)){
                        List<Case_RoundRobin_Asignee__c> tempRoundRobinAssigneeList = roundRobinIdVsAssigneeId.get(roundRobinVar);
                        if(roundRobinMap.containsKey(roundRobinVar)){
                            Integer countCheck = roundRobinMap.get(roundRobinVar).Previous_Active_User__c == null ? 1: Integer.ValueOf(roundRobinMap.get(roundRobinVar).Previous_Active_User__c) == tempRoundRobinAssigneeList.size() ? 1 : Integer.ValueOf(roundRobinMap.get(roundRobinVar).Previous_Active_User__c)+1;
                            Integer countCheckOpportunityList = 1;
                            for(Case caseVar : tempCaseList){
                                if(tempRoundRobinAssigneeList.size() >= countCheck){
                                    Case tempCase = new Case();
                                    tempCase.Id = caseVar.Id;
                                    tempCase.OwnerId = tempRoundRobinAssigneeList[countCheck-1].User__c;
                                    system.debug('tempCase.OwnerId::'+tempCase.OwnerId);
                                    finalTempCaseList.add(tempCase);
                                    //caseVar.OwnerId = tempRoundRobinAssigneeList[countCheck-1].User__c;
                                     if(tempCaseList.size() == countCheckOpportunityList){
                                        Case_Round_Robin__c roundRobinObject = new Case_Round_Robin__c();
                                        roundRobinObject.Id = roundRobinVar;
                                        roundRobinObject.Previous_Active_User__c = String.valueOf(countCheck);
                                        roundRobinList.add(roundRobinObject);
                                        countCheckOpportunityList = 0;
                                    }
                                    if(tempRoundRobinAssigneeList.size() == countCheck){
                                        countCheck = 0;
                                    }
                                }
                                countCheck++;
                                countCheckOpportunityList++;
                            }
                        }
                    }else{
                        // if(systemAdministratorHolderList.size()>0){
                        //     for(Opportunity oppVar : tempOpportunityList){
                        //         oppVar.OwnerId = systemAdministratorHolderList[0].Admin_User_Id__c;
                        //     }
                        // }
                    }
                    //caseListWithRoundRobinOwner.addAll(tempCaseList);
                    caseListWithRoundRobinOwner.addAll(finalTempCaseList);
                }
            }
            update roundRobinList;
            
        }
        return caseListWithRoundRobinOwner;
    }
}