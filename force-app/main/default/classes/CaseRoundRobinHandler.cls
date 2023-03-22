public without sharing class CaseRoundRobinHandler {
    public static Boolean stopRecursionHandler = true; 
    public static void roundRobinAssignment(List<Case> caseList){
        List<Case> inputList = new List<Case>();
        for(Case caseRecord : caseList){
            if(caseRecord.ParentId == null && caseRecord.Work_Job__c == null){
                inputList.add(caseRecord);
            }
        }
        if(inputList.size() != 0){
        userAssignment(inputList);
        }
    }


    private static void userAssignment(List<Case> onboardingCaseList){
        System.debug('Case Size:::::'+ onboardingCaseList.size());
         Set<Id> userIdSet = new Set<Id>();
         Map<String, String> userAndProfileMap = new Map<String, String>();  
         Map<String, String> caseAndProfileMap = new Map<String, String>();     
         Map<String, List<Case>> profileAndCaseMap = new Map<String, List<Case>>();

        Map<String, Case_Round_Robin__c> caseRoundRobinMap = new Map<String, Case_Round_Robin__c>();

        //updateDate: 22 March,2023
        //@author: Vishal
        List<Case> roundRobinCaseList = new List<Case>();
        List<Case> defaultCaseList = new List<Case>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> notCaseIdSet = new Set<Id>();


        for(Case caseRecord : onboardingCaseList){
            System.debug('Case Record:::::'+ caseRecord);
            userIdSet.add(caseRecord.CreatedById);
            if(caseRecord.Opportunity__c != null){
                oppIdSet.add(caseRecord.Opportunity__c);
            }
            notCaseIdSet.add(caseRecord.Id);

        }

        Map<String, List<Case>> accountCaseMap = generateAccountAndListOfCaseMap(onboardingCaseList, oppIdSet);
        Map<String, Case> accountOnboardingCaseMap = checkCaseExistingOnboardingCase(onboardingCaseList, oppIdSet, notCaseIdSet);

        System.debug('Check Case Map::::'+ accountOnboardingCaseMap);

       for(String accountId : accountCaseMap.keySet()){
        if(accountOnboardingCaseMap.containsKey(accountId)){
            for(Case caseRecord : accountCaseMap.get(accountId)){
                 System.debug('Account Id:::::'+ caseRecord.Id);
                 Case newCase = new Case();
                 newCase.Id = caseRecord.Id;
                 System.debug('Owner Id:::::'+ accountOnboardingCaseMap.get(accountId).OwnerId);
                 newCase.OwnerId = accountOnboardingCaseMap.get(accountId).OwnerId;
                 defaultCaseList.add(newCase);
            }
        }else{
                for(Case caseRecord : accountCaseMap.get(accountId)){
                    roundRobinCaseList.add(caseRecord);
                }
            }
        }
       
        


        for(Case_Round_Robin__c roundRobin : [Select Id, Name, Is_Active__c, Previous_Active_User__c, ProfileName__c From Case_Round_Robin__c Where Is_Active__c = true]){
            caseRoundRobinMap.put(roundRobin.ProfileName__c, roundRobin);
        }

        System.debug('User Map:::::'+ caseRoundRobinMap);

       

        for(User userRecord : [Select Id, ProfileId, Profile.Name From User Where Id IN: userIdSet]){
            userAndProfileMap.put(userRecord.Id, userRecord.Profile.Name);
        }  

        /*****************************************Upadete Date : 22 March, 2023**************************************************/
        // for(Case caseRecord : onboardingCaseList){
            for(Case caseRecord : roundRobinCaseList){
            System.debug('Profile Name::'+userAndProfileMap.get(caseRecord.CreatedById));
            caseAndProfileMap.put(caseRecord.Id, userAndProfileMap.get(caseRecord.CreatedById));
        }

        // for(Case caseRecord : onboardingCaseList){
            for(Case caseRecord : roundRobinCaseList){
            Integer count = 0;
            for(String profileKey : caseRoundRobinMap.keySet()){
                  if(!profileKey.contains(';')){
                    System.debug('Without Semicolon Passed:::::');

                    if(profileKey == caseAndProfileMap.get(caseRecord.Id)){

                        if(!profileAndCaseMap.containsKey(profileKey)){
                            List<Case> tempCaseList = new List<Case>();
                            tempCaseList.add(caseRecord);
                            profileAndCaseMap.put(profileKey, tempCaseList);
                        }else{
                            profileAndCaseMap.get(profileKey).add(caseRecord);
                        }
                        break;
                    }
                  }else{
                    List<String> tempStringList = profileKey.split(';');
                    if(tempStringList.contains(caseAndProfileMap.get(caseRecord.Id))){
                        if(!profileAndCaseMap.containsKey(profileKey)){
                            List<Case> tempCaseList = new List<Case>();
                            tempCaseList.add(caseRecord);
                            profileAndCaseMap.put(profileKey, tempCaseList);
                        }else{
                            profileAndCaseMap.get(profileKey).add(caseRecord);
                        }
                        break;
                    }
                      
                  }
                  System.debug('Count Data:::::'+ count);
                  count++;
            }

            if(count == caseRoundRobinMap.size()){
                if(!profileAndCaseMap.containsKey('Other')){
                            List<Case> tempCaseList = new List<Case>();
                            tempCaseList.add(caseRecord);
                            profileAndCaseMap.put('Other',tempCaseList);
                        }else {
                            profileAndCaseMap.get('Other').add(caseRecord);
                        }

            }

          
        }

        List<Case> rrCaseList = CaseRoundRobinController.getCaseWithRoundRobinOwner(profileAndCaseMap);
  /*************************************************** UpdatedDate : 22 March, 2023 *******************************************************/      
        System.debug('New Mapp::::'+ rrCaseList);
        if(defaultCaseList.size() != 0){
            rrCaseList.addAll(defaultCaseList);
        }
        //stopRecursionHandler = false;
        System.debug('Final List::::::'+ rrCaseList.size());
        for(Case caseRecord : rrCaseList){
            System.debug('Case Number:::::'+ caseRecord.CaseNumber);
            System.debug('Case Record:::::'+ caseRecord.OwnerId);
        }
        //CaseTriggerHandler.stopRecursion = false;
        //Update defaultCaseList;
        List<Database.SaveResult> finalResult = Database.update(rrCaseList);
       // System.debug('DML Operation:::'+ finalResult.i);
        System.debug('finalResult::::'+ rrCaseList);
    }



    /***
     * @description: generate Onboarding case w.r.t their Opportunity
     *               one opportunity has only one onboarding case
     * @parameter: case of list in trigger
     * @return: map of opportunity id and case record
     */
    private static Map<String, Case> checkCaseExistingOnboardingCase(List<Case> caseList, Set<Id> oppIdSet, Set<Id> notCaseIdSet){
        System.debug('Check Case Onboarding::::::'+caseList[0].Opportunity__c);
        System.debug('Opportunity Id Set::::'+ oppIdSet);
        Set<String> accountIdSet = new Set<String>();
        Map<String, Opportunity> accountOpportunityMap = new Map<String, Opportunity>();
        Map<String, Case> accountCaseMap = new Map<String, Case>();

       

        for(Opportunity oppRecord : [Select Id, AccountId, Account.MID__c From Opportunity Where Id IN: oppIdSet]){
            accountOpportunityMap.put(oppRecord.Id, oppRecord);
            System.debug('Mid Value::::'+ oppRecord.Account.MID__c);
            accountIdSet.add(oppRecord.Account.MID__c);
        }
        System.debug('Onboarding Case::::::::'+ accountIdSet+' '+oppIdSet);
        for(Case caseRecord : [Select Id,Opportunity__c,CaseNumber,Subject, Opportunity__r.AccountId, OwnerId From Case Where
                                Is_Parent__c = true 
                               AND Opportunity__r.Account.MID__c IN: accountIdSet 
                               AND Id NOT IN: notCaseIdSet
                               Order By CreatedDate ]){
                                // AND Id NOT IN: notCaseIdSet
            System.debug('Case Id::::'+ caseRecord.CaseNumber);
            if(caseRecord.Subject.toLowerCase().contains('onboarding')){
                accountCaseMap.put(caseRecord.Opportunity__r.AccountId , caseRecord);
            }
        }
        System.debug('Map data::::'+ accountCaseMap);
        return accountCaseMap;
    }



    private static Map<String, List<Case>> generateAccountAndListOfCaseMap(List<Case> caseList, Set<Id> opportunityIdSet){
         Map<String, String> oppAccountIdMap = new Map<String, String>();
         Map<String, List<Case>> accountIdWithListOfCaseMap = new Map<String, List<Case>>();
         for(Opportunity oppRecord : [Select Id,AccountId From Opportunity Where Id IN: opportunityIdSet]){
            if(!String.isBlank(oppRecord.AccountId)){
                oppAccountIdMap.put(oppRecord.Id, oppRecord.AccountId);
            }
         } 

         for(Case caseRecord : caseList){
            String key = oppAccountIdMap.get(caseRecord.Opportunity__c);
            if(!accountIdWithListOfCaseMap.containsKey(oppAccountIdMap.get(caseRecord.Opportunity__c))){
                accountIdWithListOfCaseMap.put(key, new List<Case>{caseRecord});
            }else{
                accountIdWithListOfCaseMap.get(key).add(caseRecord);
            }
         }
         return accountIdWithListOfCaseMap;
    }
}