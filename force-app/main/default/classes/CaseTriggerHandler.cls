/**
* @description       : 
* @author            : 
* @group             : 
* @last modified on  : 16-01-2023
* @last modified by  : Saurav Kashyap
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   11-01-2023   Saurav Kashyap   Initial Version
**/
public without sharing class CaseTriggerHandler {
    public static Boolean booleanvalue = false;
    public static Boolean stopRecursion = true;

    public static void beforeInsert(List<Case> caseList){

        updateWorkOrderStatus(caseList);
        assignAccountowner(caselist); 
        //CaseRoundRobinHandler.roundRobinAssignment(caseList);
    }

    public static void afterInsert(List<Case> caseList){
        assignRecordTypeId(caseList);
        CaseRoundRobinHandler.roundRobinAssignment(caseList);

    }

    public static void afterUpdate(List<Case> caseList,Map<id,Case> oldMap){
        //stopRecursion = false;
        System.debug('inside after update ');
        System.debug('caseListId::'+caseList[0].Id);
        changeStatusToPendencyCleared(caseList,oldMap);
        system.debug('caseList::'+caseList[0].OwnerId);
        System.debug('inside after update booleanvalue '+booleanvalue);
        // if(booleanvalue){
        //     System.debug('inside if  >> after update booleanvalue '+booleanvalue);
        //     booleanvalue = CaseTriggerHelper.caseRoundRobinMaster(caseList,oldMap);
        // }
    }

    public static Boolean assignRecordTypeId(List<Case> caseList){
        Boolean returnedValue = false;
        System.debug('inside assign record type id');
        List<Case> updateList = new List<Case>();
        Map<String,RecordType> caseRecordMap = new Map<String,RecordType>();
        for(RecordType recType : [SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                    FROM RecordType 
                                    Where SObjectType = 'Case' AND IsActive = true]){
                                        System.debug('recType: '+recType);
                                        caseRecordMap.put(recType.DeveloperName,recType);
                                    }
        system.debug('caseRecordMap recordtype::result12 ::' +caseRecordMap);
        // List<Group> queue = [SELECT Id, Name, DeveloperName, Type
        //                      FROM Group
        //                      WHERE Type = 'Queue' AND DeveloperName = 'Onboarding_Team'
        //                      LIMIT 1];

        // Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        // system.debug('profile'+p);

        set<id> useridset = new set<id>();

        for(Case caseitm : caseList){
            useridset.add(caseitm.CreatedById);
        }
        List<user> userquery= [select user.id,user.FirstName,user.LastName,user.profile.name FROM user where id IN: useridset ];
        system.debug('userquery'+userquery);

        List<string> queuenameList = new List<string>();
        Map<Id,String> maplist = new Map<Id,String>();

        for(case_assign_owner__mdt item : [SELECT Id, DeveloperName, User_Profile_Name__c, Queue_Name__c FROM case_assign_owner__mdt]){
            for(user useritm : userquery){
                if(item.User_Profile_Name__c.contains(useritm.profile.name)){
                    queuenameList.add(item.Queue_Name__c);
                    maplist.put(useritm.id,item.Queue_Name__c);
                }
            }
        }
        Map<String,Id> queuemap = new  Map<String,Id>();
        system.debug('queuenameList'+queuenameList);
        List<Group> queuequery = [SELECT Id, Name, DeveloperName, Type
                                    FROM Group
                                    WHERE Type = 'Queue' AND ( DeveloperName =:queuenameList OR DeveloperName='Onboarding_Team')];

        for(Group groupitem : queuequery){
            queuemap.put(groupitem.DeveloperName,groupitem.id);
        }

        system.debug('queuequery'+queuequery);

        for(Case caseRecord : caseList){
            System.debug('caseRecord: '+caseRecord);
            if( caseRecord.Case_For__c != null){
                Case tempCase = new Case();
                tempCase.Id = caseRecord.Id;
                System.debug('case for: '+caseRecord.Case_For__c);
                if(caseRecord.Case_For__c == 'Onboarding Team'){
                    tempCase.RecordTypeId = caseRecordMap.get('Onboarding_Team').Id;
                    System.debug('inside onboarding team');
                    System.debug('caseRecord RecordTypeId:'+caseRecord.RecordTypeId);
                    System.debug('caseRecord after update:'+tempCase.RecordTypeId);
                    //******** functionality to update ownerId if it is a parent Case   <<<<<  START >>>>> *********************************************************************/
                    // if(caseRecord.ParentId==null && caseRecord.Work_Job__c==null){
                    //     if(maplist.containsKey(caseRecord.CreatedById)){
                    //         string userid = maplist.get(caseRecord.CreatedById);
                    //         if(queuemap.containsKey(userid)){
                    //             tempCase.OwnerId = queuemap.get(userid);
                    //         }
                    //     }else{
                    //         System.debug('inside queuemap.get team:::result::'+queuemap.get('Onboarding_Team'));
                    //         tempCase.OwnerId = queuemap.get('Onboarding_Team');
                    //     }
                    // } 
                    //******** functionality to update ownerId if it is a parent Case  <<<<<  END >>>>>  *********************************************************************/  
                }
                else if(caseRecord.Case_For__c == 'Bank Ops Team'){
                    tempCase.RecordTypeId = caseRecordMap.get('Bank_Ops').Id;
                    System.debug('inside bank ops');
                    System.debug('Risk Team:result12 :::'+ caseRecordMap.get('Bank_Ops').Id);
                }
                else if(caseRecord.Case_For__c == 'Risk Team'){
                    System.debug('inside bank ops:result12 :::'+ caseRecordMap.get('Risk_Team').Id);
                    tempCase.RecordTypeId = caseRecordMap.get('Risk_Team').Id;
                }
                else if(caseRecord.Case_For__c == 'Send to Account Manager'){
                    System.debug('SC:result12 :::'+caseRecordMap.get('Send_to_Account_Manager').Id);
                    tempCase.RecordTypeId = caseRecordMap.get('Send_to_Account_Manager').Id;
                }
                updateList.add(tempCase);
            }
        }
        if(updateList.size() != 0){
            System.debug('stopRecursion:'+stopRecursion);
            stopRecursion = false;
            System.debug('stopRecursion:'+stopRecursion);
            System.debug('updateList:'+updateList);
            update updateList;
            // System.debug('updateList1:1'+[Select Id,OwnerId,owner.name FROM Case WHERE Id=:caseList[0].id]);
            returnedValue = true;
            System.debug('returnedValue '+returnedValue);
            return returnedValue;
        } 
        // System.debug('updateList1:2'+[Select Id,OwnerId,owner.name FROM Case WHERE Id=:caseList[0].id]);
        return returnedValue;
    }


    public static void changeStatusToPendencyCleared(List<Case> caseList,Map<Id,Case> oldMap){
        Set<Id> caseIdSet = new Set<id>();
        for(Case cas : caseList){
            
            if(cas.parentId !=NULL && cas.isClosed == true && cas.status != oldMap.get(cas.Id).status){
                
                caseIdSet.add(cas.ParentId);
            }
            
        }

        if(caseIdSet.size()>0){
            
            List<Case> parentCaseList =  [Select Id,OwnerId,(Select id,OwnerId,status from Cases where isClosed = false)
                                            FROM Case WHERE Id IN :caseIdSet AND status = 'Pending'];
            
            Map<String,List<Task>> caseWithTaskMap = new Map<String,List<Task>>();
            for(Task tsk : [SELECT Id,WhatId FROM Task where Status != 'Completed' AND WhatId IN :caseIdSet]){
                
                if(!caseWithTaskMap.containsKey(tsk.WhatId))
                    caseWithTaskMap.put(tsk.WhatId,new List<Task>());
                caseWithTaskMap.get(tsk.WhatId).add(tsk);         
                
            }
            
            List<case> caseToUpdateList = new List<Case>();
            for(Case cs : parentCaseList){
                
                if(cs.cases.size()>0)
                    continue;
                
                if(caseWithTaskMap.containsKey(cs.Id) && caseWithTaskMap.get(cs.Id).size()>0)
                    continue;
                
                cs.status = 'Pendency Cleared';
                caseToUpdateList.add(cs);
                
            }
            System.debug('updateList1:'+[Select Id,OwnerId,owner.name FROM Case WHERE Id=:caseList[0].id]);                          
            
            if(caseToUpdateList.size()>0)
                System.debug('caseToUpdateList:result::'+caseToUpdateList);
            update caseToUpdateList;                            
        }
        System.debug('Final Case List::'+caseList[0].Id+caseList[0].OwnerId);
    }    

    public static void updateWorkOrderStatus(List<Case> caseList){

        Set<Id> workOrderIds=new set<Id>();
        List<Case> caseList1=new List<Case>();

            for(Case Cas:caseList){     
                if(Cas.Work_Job__c!=Null || Cas.Work_Job__c!=''){  
                workOrderIds.add(Cas.Work_Job__c);
                caseList1.add(Cas);
                }
            }

            if(workOrderIds.size()>0){
            List<WorkOrder> workOrderList=[select Id,Status from WorkOrder where Id in: workOrderIds];

            Map<Id,List<Case>> caseMap=new Map<Id,List<case>>();
            Map<Id,WorkOrder> workMap=new Map<Id,WorkOrder>();
            for(WorkOrder work:workOrderList){
                for(case cas:caseList1){
                if(work.Id==cas.Work_Job__c){
                    if(!casemap.containsKey(work.Id)){
                        casemap.put(work.Id,new List<Case>());
                        caseMap.get(work.Id).add(cas);
                    }
                    else{
                        caseMap.get(work.Id).add(cas);
                    }
                }
                }
                workMap.put(work.Id,work);
            }

            for(Id work:caseMap.Keyset()){
                for(case cas1:caseMap.get(work)){
                cas1.Work_Order_Status__c=workMap.get(work).Status;
                }
            }
            }
    }


    /* @Name : - assignAccountowner()
    * author      :  Ankita
    * @Description: - 
    * @Params     : - (List<Case> caselist
    * @ReturnType : - Void
    *@updatedDate : 17 March,2023
    *@updatedBy : Vishal 
    */
    public static void assignAccountowner(List<Case> caselist){

        Map<String,String> recordTypeNameVsIdMap = new Map<String,String>();

        List<Case> caseRecordList = new List<Case>();
        List<Case> parentCaseRecordList = new List<Case>();

        Map<String, String> caseAccountRecordIdMap = new Map<String, String>();
         //Set<Id> workorderId =  new Set<Id>();
        //WHERE Name = 'Send to Account Manager' 
        List<RecordType> rectyplist = [SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                        FROM RecordType
                                        WHERE SobjectType = 'Case'];
        System.debug('rectyplist:>> '+rectyplist);

        for(RecordType rt : rectyplist){
            recordTypeNameVsIdMap.put(rt.Name,rt.Id);
        }
        System.debug('recordTypeNameVsIdMap:>> '+recordTypeNameVsIdMap);

        Map<String,Case> workOrderIdVsCaseMap = new Map<String,Case>();

        Set<Id> workOrderIdSet = new Set<Id>();
        Set<Id> parentCaseIdSet = new Set<Id>();
        for(Case csrec : caselist){
            if(csrec.Work_Job__c != null){
                caseRecordList.add(csrec);
                workOrderIdSet.add(csrec.Work_Job__c);
            } 
            if(csrec.ParentId != null){
                parentCaseRecordList.add(csrec);
                parentCaseIdSet.add(csrec.ParentId);
            } 
        }
        //SELECT Id, AccountId,Account.OwnerId, ParentId,Parent.AccountId FROM Case
        System.debug('caseRecordList:>> '+caseRecordList);
        System.debug('parentCaseRecordList:>> '+parentCaseRecordList);
        
        //Parent Case Data Query
        Map<String,String> parentCaseIdVsParentCaseOwnerIdMap = new Map<String,String>();
        List<Case> CaseQueriedList = [SELECT Id, AccountId,Account.OwnerId, 
                                        ParentId,Parent.AccountId 
                                        FROM Case 
                                        WHERE Id IN :parentCaseIdSet];
        System.debug('CaseQueriedList:>> '+CaseQueriedList); 

        //Mapping the ParentCase Id With It's owner Id
        for(Case cseRecD : CaseQueriedList){
            parentCaseIdVsParentCaseOwnerIdMap.put(cseRecD.Id,cseRecD.Account.OwnerId);
            caseAccountRecordIdMap.put(cseRecD.Id, cseRecD.AccountId);
        } 
        System.debug('parentCaseIdVsParentCaseOwnerIdMap:>> '+parentCaseIdVsParentCaseOwnerIdMap);  

        // Work Order child case Record Logic       
        Map<String,String> workOrderIdVsWorkOrderOwnerIdMap = new Map<String,String>();
        Map<String,String> workOrderCaseAccountMap = new Map<String,String>();
        List<WorkOrder> workOrderlist = [SELECT Id, Account.OwnerId ,AccountId 
                                        FROM WorkOrder WHERE Id IN :workOrderIdSet];
        System.debug('workOrderlist:>> '+workOrderlist); 

        for(WorkOrder wo : workOrderlist){
            workOrderIdVsWorkOrderOwnerIdMap.put(wo.Id,wo.Account.OwnerId);
            workOrderCaseAccountMap.put(wo.Id, wo.AccountId);
        } 
        System.debug('workOrderIdVsWorkOrderOwnerIdMap:>> '+workOrderIdVsWorkOrderOwnerIdMap);  

        for(Case caserec : caseRecordList){
            if(recordTypeNameVsIdMap.containsKey(caserec.Case_For__c)){
                System.debug('Case Record Id::::'+ caserec.Id);
                caserec.RecordTypeId = recordTypeNameVsIdMap.get(caserec.Case_For__c); 
                caserec.OwnerId = workOrderIdVsWorkOrderOwnerIdMap.get(caserec.Work_Job__c);
                caserec.AccountId = workOrderCaseAccountMap.get(caserec.Work_Job__c);
            }  
        }

        System.debug('CaseAnd Account::::'+ caseAccountRecordIdMap);

        //onboarding case Child Case creation
        for(Case casRecData : parentCaseRecordList){
            if(recordTypeNameVsIdMap.containsKey(casRecData.Case_For__c)){
                System.debug('Case Record Id:::'+ casRecData.Id);
                casRecData.RecordTypeId = recordTypeNameVsIdMap.get(casRecData.Case_For__c); 
                casRecData.OwnerId = parentCaseIdVsParentCaseOwnerIdMap.get(casRecData.ParentId);
                casRecData.AccountId = caseAccountRecordIdMap.get(casRecData.ParentId);
                
            }  
        }
        System.debug('caseRecordList:>> '+caseRecordList); 
    }
}