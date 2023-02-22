public class TaskTriggerHandler {
    
    
    public static void afterUpdate(List<Task> newList,Map<Id,Task> oldMap){
        changeCaseStatusToPendencyCleared(newList,oldMap);
    }
    
    
    public static void changeCaseStatusToPendencyCleared(List<Task> newList,Map<Id,Task> oldMap){
        
        
         Set<Id> caseIdSet = new Set<id>();
         for(Task tsk : newList){
            
            if(tsk.WhatId !=NULL && tsk.status == 'Completed' && tsk.status != oldMap.get(tsk.Id).status 
               && tsk.WhatId.getsObjectType() == Case.sObjectType){
                
                caseIdSet.add(tsk.WhatId);
            }
                      
         }
        
        if(caseIdSet.size()>0){
            
            List<Case> parentCaseList =  [Select Id,(Select id,status from Cases where isClosed = false)
                                          FROM Case WHERE Id IN :caseIdSet AND status = 'Pending'];
            
            Map<String,List<Task>> caseWithTaskMap = new Map<String,List<Task>>();
            for(Task tsk : [SELECT Id,WhatId FROM Task where Status != 'Completed' AND WhatId IN :caseIdSet]){
                
                if(!caseWithTaskMap.containsKey(tsk.WhatId))
                    caseWithTaskMap.put(tsk.WhatId,new List<Task>());
                caseWithTaskMap.get(tsk.WhatId).add(tsk);         
                
            }
            system.debug('caseWithTaskMap'+caseWithTaskMap);
            
            List<case> caseToUpdateList = new List<Case>();
            for(Case cs : parentCaseList){
                
                if(cs.cases.size()>0)
                    continue;
                
                if(caseWithTaskMap.containsKey(cs.Id) && caseWithTaskMap.get(cs.Id).size()>0)
                    continue;
                
                cs.status = 'Pendency Cleared';
                caseToUpdateList.add(cs);
                
            }
            
            if(caseToUpdateList.size()>0)
                update caseToUpdateList;                            
        }
        
    }

}