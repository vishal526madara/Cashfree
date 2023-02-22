public with sharing class OpportunityRoundRobinAssigneeHandler {
    
    public static Boolean stopRecursion = true;
    public static void beforeInsert(List<Opportunity_Round_Robin_Assignee__c> newList){
    //  List<Round_Robin_Assignee__c> inputList = new List<Round_Robin_Assignee__c>();
    //  for(Round_Robin_Assignee__c roundRobinAssignee : newList){
    //     if(roundRobinAssignee.Active__c == true){
    //         inputList.add(roundRobinAssignee);
    //     }
    List<Opportunity_Round_Robin_Assignee__c> inputList = new List<Opportunity_Round_Robin_Assignee__c>();
    for(Opportunity_Round_Robin_Assignee__c assignee : newList){
      if(assignee.Is_Active__c == true && assignee.Opportunity_Round_Robin__c != null){
      inputList.add(assignee);
      }
    }

    if(inputList.size() != 0){
     indexingOfRoundRobinAssignee(newList);
    }
     }

     public static void indexingOfRoundRobinAssignee(List<Opportunity_Round_Robin_Assignee__c> newList){
       Map<Id,List<Opportunity_Round_Robin_Assignee__c>> roundRobinAssigneeMap = new Map<Id,List<Opportunity_Round_Robin_Assignee__c>>();
       Map<Id,List<Opportunity_Round_Robin_Assignee__c>> mainRoundRobinAssigneeMap = new Map<Id,List<Opportunity_Round_Robin_Assignee__c>>();
       Set<Id> roundRobinIdSet = new Set<Id>();
       for(Opportunity_Round_Robin_Assignee__c assignee : newList){
        if(assignee.Is_Active__c == true){
          roundRobinIdSet.add(assignee.Opportunity_Round_Robin__c);
        }
       }
  
       for(Opportunity_Round_Robin__c roundRobin : [Select Id,
                                       (Select Id,Order_Number__c From 
                                        Opportunity_Teams__r 
                                        Where Is_Active__c = true Order By Order_Number__c) 
                                        From Opportunity_Round_Robin__c
                                        Where Id IN: roundRobinIdSet]){
        roundRobinAssigneeMap.put(roundRobin.Id,roundRobin.Opportunity_Teams__r);
       }

       for(Opportunity_Round_Robin_Assignee__c assignee : newList){
          if(!mainRoundRobinAssigneeMap.containsKey(assignee.Opportunity_Round_Robin__c)){
            List<Opportunity_Round_Robin_Assignee__c> tempList = new List<Opportunity_Round_Robin_Assignee__c>();
            tempList.add(assignee);
            mainRoundRobinAssigneeMap.put(assignee.Opportunity_Round_Robin__c,tempList);
          }
          else{
            mainRoundRobinAssigneeMap.get(assignee.Opportunity_Round_Robin__c).add(assignee);
          }
       }

       for(Id key : mainRoundRobinAssigneeMap.keySet()){
        Integer tempNum = 0; 
        for(Opportunity_Round_Robin_Assignee__c assignee : mainRoundRobinAssigneeMap.get(key)){
            if(tempNum == 0 && roundRobinAssigneeMap.get(key).size() != 0){
              tempNum = roundRobinAssigneeMap.get(key).size();
              tempNum++;
              assignee.Order_Number__c = tempNum;
            }else if(tempNum == 0 && roundRobinAssigneeMap.get(key).size() == 0){
              tempNum++;
              assignee.Order_Number__c = tempNum;
            }else{
              tempNum++;
              assignee.Order_Number__c = tempNum;
            }
        }
       }
     }
    

    public static void afterUpdate(List<Opportunity_Round_Robin_Assignee__c> newList, Map<Id,Opportunity_Round_Robin_Assignee__c> oldMap){
        System.debug('Function Called:::');
      List<Opportunity_Round_Robin_Assignee__c> inputList = new List<Opportunity_Round_Robin_Assignee__c>();
      for(Opportunity_Round_Robin_Assignee__c assignee : newList){
        if((assignee.Is_Active__c == true && oldMap.get(assignee.Id).Is_Active__c == false) ||
           (assignee.Is_Active__c == false && oldMap.get(assignee.Id).Is_Active__c == true)){
            inputList.add(assignee);
           }
      }
      System.debug('List Size::'+ inputList.size());
      if(inputList.size() != 0){
        recalculateIndex(inputList);
      }
    }

    public static void recalculateIndex(List<Opportunity_Round_Robin_Assignee__c> assigneeList){
      Set<Id> roundRobinIdSet = new Set<Id>();
      Map<Id,List<Opportunity_Round_Robin_Assignee__c>> tempMap = new Map<Id,List<Opportunity_Round_Robin_Assignee__c>>();
      List<Opportunity_Round_Robin_Assignee__c> updateList = new List<Opportunity_Round_Robin_Assignee__c>();
      for(Opportunity_Round_Robin_Assignee__c assignee : assigneeList){
        roundRobinIdSet.add(assignee.Opportunity_Round_Robin__c);
      }

      for(Opportunity_Round_Robin__c roundRobin : [Select Id,(Select Name,Id,Order_Number__c,Is_Active__c 
                                      From Opportunity_Teams__r 
                                      Order By Order_Number__c  )
                                      From Opportunity_Round_Robin__c Where Id IN: roundRobinIdSet]){
       List<Opportunity_Round_Robin_Assignee__c> list1 = new List<Opportunity_Round_Robin_Assignee__c>();
       List<Opportunity_Round_Robin_Assignee__c> list2 = new List<Opportunity_Round_Robin_Assignee__c>();
       for(Opportunity_Round_Robin_Assignee__c assignee : roundRobin.Opportunity_Teams__r){
         if(assignee.Is_Active__c == true){
           if(assignee.Order_Number__c != null){
            list1.add(assignee);
           }else{
            list2.add(assignee);
           }
          }else{
            list2.add(assignee);
          }
       }
       list1.addAll(list2);
       tempMap.put(roundRobin.Id,list1);
      }
      for(Id key : tempMap.keySet()){
        Integer tempNumber = 0;
        for(Opportunity_Round_Robin_Assignee__c assignee : tempMap.get(key)){
           System.debug('Asssignee Value::::'+ assignee.Is_Active__c);
           Opportunity_Round_Robin_Assignee__c tempAssignee = new Opportunity_Round_Robin_Assignee__c();
          tempAssignee.Id = assignee.Id;
          if(assignee.Is_Active__c == true){
          tempNumber++;
          System.debug('Order Number:::'+ tempNumber);
          tempAssignee.Order_Number__c = tempNumber;
          updateList.add(tempAssignee);
          }else{
            tempAssignee.Order_Number__c = null;
            updateList.add(tempAssignee);
          }
        }
      }
      if(updateList.size() != 0){
        stopRecursion = false;
        Update updateList;
      }
    }
}