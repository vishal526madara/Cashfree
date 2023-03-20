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

        for(Case_Round_Robin__c roundRobin : [Select Id, Name, Is_Active__c, Previous_Active_User__c, ProfileName__c From Case_Round_Robin__c Where Is_Active__c = true]){
            caseRoundRobinMap.put(roundRobin.ProfileName__c, roundRobin);
        }

        System.debug('User Map:::::'+ caseRoundRobinMap);

        for(Case caseRecord : onboardingCaseList){
            System.debug('Case Record:::::'+ caseRecord);
            userIdSet.add(caseRecord.CreatedById);
        }

        for(User userRecord : [Select Id, ProfileId, Profile.Name From User Where Id IN: userIdSet]){
            userAndProfileMap.put(userRecord.Id, userRecord.Profile.Name);
        }  

        for(Case caseRecord : onboardingCaseList){
            System.debug('Profile Name::'+userAndProfileMap.get(caseRecord.CreatedById));
            caseAndProfileMap.put(caseRecord.Id, userAndProfileMap.get(caseRecord.CreatedById));
        }

        for(Case caseRecord : onboardingCaseList){
            // if(caseRoundRobinMap.containsKey(caseAndProfileMap.get(caseRecord.Id))){
                
            //     if(!profileAndCaseMap.containsKey(caseAndProfileMap.get(caseRecord.Id))){
            //         List<Case> tempCaseList = new List<Case>();
            //         tempCaseList.add(caseRecord);
            //         profileAndCaseMap.put(caseAndProfileMap.get(caseRecord.Id), tempCaseList);
            //     }else{
            //         profileAndCaseMap.get(caseAndProfileMap.get(caseRecord.Id)).add(caseRecord);
            //     }
            // }else{
            //     if(!profileAndCaseMap.containsKey('Other')){
            //         List<Case> tempCaseList = new List<Case>();
            //         tempCaseList.add(caseRecord);
            //         profileAndCaseMap.put('Other',tempCaseList);
            //     }else {
            //         profileAndCaseMap.get('Other').add(caseRecord);
            //     }
            // }


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
        System.debug('New Mapp::::'+ rrCaseList);
        //stopRecursionHandler = false;
        List<Database.SaveResult> finalResult = Database.update(rrCaseList);
       // System.debug('DML Operation:::'+ finalResult.i);
        System.debug('finalResult::::'+ rrCaseList);
        

    }
}