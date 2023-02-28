public without sharing class TaskListButtonController  {


    @AuraEnabled
    public static List<TaskTypePickListWrapper> fetchTaskType(){
        List<TaskTypePickListWrapper> picklistVal = new List<TaskTypePickListWrapper>();
        Schema.DescribeFieldResult  fieldResult = Task.Task_Type__c.getDescribe(); //Activity.Task_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistValue : picklistValues){
            TaskTypePickListWrapper tempWrapper = new TaskTypePickListWrapper();
            tempWrapper.label = picklistValue.getValue();
            tempWrapper.value = picklistValue.getValue();
            picklistVal.add(tempWrapper);
        }
        return picklistVal;
    }

    @AuraEnabled 
    public static  List<TaskTypePickListWrapper> fetchSubTypePicklist(String parentPicklist){
        List<TaskTypePickListWrapper> subTypePicklistValue = new List<TaskTypePickListWrapper>();
        Map<String, List<String>> functionSubTaskList =  FunctionUtils.getDependentPicklistValues(Task.Task_Sub_Type__c);
        system.debug('functionSubTaskList::'+functionSubTaskList);
         if(functionSubTaskList.containsKey(parentPicklist)){
           for(String subPicklistValue : functionSubTaskList.get(parentPicklist)){
            TaskTypePickListWrapper tempSubTask = new TaskTypePickListWrapper();
            tempSubTask.label = subPicklistValue;
            tempSubTask.value = subPicklistValue;
            subTypePicklistValue.add(tempSubTask);
           }
           return subTypePicklistValue;
         }else{
            return subTypePicklistValue;
         }
    }


    @AuraEnabled 
    public static String  insertTaskRecord(String jsonInput){
        try{
            String result = null;
            TaskRecordCreationWraper taskRecord = (TaskRecordCreationWraper) JSON.deserialize(jsonInput, TaskRecordCreationWraper.class);
            System.debug('Event Creation Boolean:::'+ taskRecord.eventCreation);
            Task newTask = new Task();
            newTask.Subject = taskRecord.taskSubject;
            newTask.Task_Type__c = taskRecord.taskType;
            newTask.Task_Sub_Type__c = taskRecord.taskSubType;
            newTask.ActivityDate =  Date.valueOf(taskRecord.dueDate);
            newTask.Priority = taskRecord.priority;
            newTask.Status = taskRecord.status;
            newTask.OwnerId = taskRecord.assigneeRecordId;
            newTask.Start_Date_Time__c =  taskRecord.startDate != null ? DateTime.ValueofGmt(taskRecord.startDate.replace('T', ' ')): null;
            newTask.End_Date_Time__c = taskRecord.endDate != null ? DateTime.ValueofGmt(taskRecord.endDate.replace('T', ' ')) : null;
            newTask.Add_To_Calendar__c = taskRecord.eventCreation == true ? true : false;
            // if(taskRecord.startDate != null){
            //     Date newDate = Date.valueOf(taskRecord.startDate);
                
            //     Integer year = newDate.year();
            //     Integer month = newDate.month();
            //     Integer day = newDate.day();
            //     DateTime newDateTime = DateTime.newInstance(year, month, day, 0,0,0);
            //     System.debug('Start DAte::'+newDateTime);
            //     newTask.Start_Date_Time__c = newDateTime;
            // }
            // if(taskRecord.endDate != null){
            //     Date newDate = Date.valueOf(taskRecord.endDate);
            //     Integer year = newDate.year();
            //     Integer month = newDate.month();
            //     Integer day = newDate.day();
            //     DateTime newDateTime = DateTime.newInstance(year, month, day, 0,0,0);
            //     newTask.End_Date_Time__c = newDateTime;
            // }

            if(taskRecord.relatedToId != null){
               if(generateObjectPrefix('Lead') == String.valueOf(taskRecord.relatedToId).substring(0,3)){
                  newTask.WhoId = taskRecord.relatedToId; 
               }else{
                newTask.WhatId = taskRecord.relatedToId; 
               } 
            }
            newTask.Contact__c = taskRecord.contactRecordId;
            /***************************
             * Task Reminder Creation ********************************************/
            System.debug('Task Reminder:::'+ taskRecord.taskReminder);
            if(taskRecord.taskReminder == true){
             Date reminderDate = Date.valueOf(taskRecord.dueDate);
             Integer reminderYear = reminderDate.year();
             Integer reminderMonth = reminderDate.month();
             Integer reminderDay = reminderDate.day();
             newTask.ReminderDateTime = DateTime.newInstance(reminderYear, reminderMonth, reminderDay,10,0,0);
             newTask.IsReminderSet = true;
            }
             
            /***********************************************************************/


            //newTask.End_Date_Time__c = DateTime.valueOf(taskRecord.endDate);
            Savepoint sp = Database.setSavepoint();
            Database.SaveResult taskResult = Database.insert(newTask, false);
           
                 if(!taskResult.isSuccess()){
                    System.debug('Error :::::'+ taskResult.getErrors());
                    Database.Error errorResult = taskResult.getErrors().get(0);
                    System.debug('Error Message:::::'+ errorResult.getMessage());
                    throw  new AuraHandledException(errorResult.getMessage());
                  }//else{
                //     System.debug('Event Boolean Data:::'+ taskRecord.eventCreation);
                //     if(taskRecord.eventCreation){
                //     Event newEvent = new Event();
                //     newEvent.Subject = taskRecord.taskSubject;
                //     newEvent.StartDateTime =  taskRecord.startDate != null ? DateTime.ValueofGmt(taskRecord.startDate.replace('T', ' ')): null;
                //     newEvent.EndDateTime = taskRecord.endDate != null ? DateTime.ValueofGmt(taskRecord.endDate.replace('T', ' ')): null;
                //     newEvent.OwnerId = taskRecord.assigneeRecordId;
                //    // newEvent.DurationInMinutes = 840;

                    
                //     Database.SaveResult newEventInsertion = Database.insert(newEvent);
                //     System.debug('Call Log::::'+ newEventInsertion.getId());
                       
                //     if(!newEventInsertion.isSuccess()){
                //     Database.Error errorResult = newEventInsertion.getErrors().get(0);
                //     System.debug('Error Message:::::'+ errorResult.getMessage());
                //     Database.rollback(sp);
                //     throw  new AuraHandledException(errorResult.getMessage());
                //     }
                //     }
                //  }
                

            // }else{
            //     Map<String, Object> errorResult = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(taskResult.getErrors()));
            //     for(String key : errorResult.keySet()){
            //         System.debug('Key Value:::'+ key);
            //     }
            //     System.debug('Printed:::');
            //     System.debug('Error:::::+taskResult'+taskResult.getErrors());
               
            //     //throw new CustomException(taskResult.getErrors());
            //    return null;
            // }

            return taskResult.getId();
        }catch(Exception e){
            System.debug('Line Number::'+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }

    }



    @AuraEnabled 
    public static Void bulkUploadAttachment(String taskId, List<String> jsonAttachmentList){
        system.debug('TaskId::'+taskId);
        try{
      //  Map<String,Object> attachmentMap = (Map<String,Object>) JSON.deserializeUntyped(jsonAttachmentList);
        List<ContentDocumentLink> insertContentDocumentList = new List<ContentDocumentLink>();
        // for(String key : attachmentMap.keySet()){
        //     Map<String, Object> tempMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(attachmentMap.get(key)));
        //     ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
        //     newContentDocumentLink.ContentDocumentId = String.valueOf(tempMap.get('documentId'));
        //     newContentDocumentLink.LinkedEntityId = taskId;
        //     newContentDocumentLink.ShareType = 'V';
        //     insertContentDocumentList.add(newContentDocumentLink);
        // }

        for(String documentIdList : jsonAttachmentList){
            ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
            newContentDocumentLink.ContentDocumentId = documentIdList;
            newContentDocumentLink.LinkedEntityId = taskId;
            newContentDocumentLink.ShareType = 'V';
            insertContentDocumentList.add(newContentDocumentLink);
        }
        
        Insert insertContentDocumentList;
    
    }catch(Exception e){
     throw new AuraHandledException(e.getMessage());
    }

    }

   



    /***********************************************************
     * @used to return Prefix of Particular
     */
    public static String generateObjectPrefix(String objectName){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }


        public class TaskTypePickListWrapper{
            @AuraEnabled public String label{get;set;}
            @AuraEnabled public String value{get;set;}
            @AuraEnabled public String icon_name = null;
        }

        public class TaskRecordCreationWraper{
            @AuraEnabled public String taskType{get;set;}
            @AuraEnabled public String taskSubType{get;set;} 
            @AuraEnabled public String taskSubject{get;set;}
            @AuraEnabled public Date dueDate{get;set;}
            @AuraEnabled public String priority{get;set;}
            @AuraEnabled public String status{get;set;}
            @AuraEnabled public String startDate{get;set;}
            @AuraEnabled public String endDate{get;set;}
            @AuraEnabled public String relatedToId{get;set;}
            @AuraEnabled public String contactRecordId{get;set;}
            @AuraEnabled public String assigneeRecordId{get;set;}
            @AuraEnabled public Boolean taskReminder{get;set;}
            @AuraEnabled public Boolean eventCreation{get;Set;}
        }

       
}