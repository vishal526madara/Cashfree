public without sharing class OnBoardingController {
  //Global Variable for Queue
 


  @AuraEnabled
  public static OpportunityDataWrapper currentOpportunityRec(String recordId) {
    Opportunity oppRec = [
      SELECT
        Id,
        AccountId,
        Account.Division__c,
        Account.Ownership,
        Account.Name,
        Account.Owner.Name,
        Owner.Name,
        Bank_Ops_Approval__c,
        Sales_Approval__c,
        Risk_Approval__c,
        Finance_Approval__c,
        Price_Deviation_Approval__c,
        Account.CIN__c,
        Account.GST__c,
        Account.PAN__c,
        Account.Industry,
        Account.SUB_LOB__c,
        Account.Phone,
        Account.Support_Email__c,
        Account.Registered_Name__c,
        Account.Merchant_Site_Url__c,
        Account.Account_Holder_Name__c,
        Account.Owner_Director_PAN_Number__c,
        Account.Website
      FROM Opportunity
      WHERE Id = :recordId
      LIMIT 1
    ];
    List<OpportunityContactRole> oppPrimaryContList = [
      SELECT Id, ContactId, Contact.Name
      FROM OpportunityContactRole
      WHERE OpportunityId = :recordId
      LIMIT 1
    ];

    Onboarding_Display_Information__mdt displayInfoRec = [
      SELECT Deals_Handoff_Notes__c, Desired_Outcomes__c
      FROM Onboarding_Display_Information__mdt
      WHERE Active__c = TRUE
      LIMIT 1
    ];

    //List<Project_Milestone__c> onboardingList=[SELECT Id,Name,Type__c FROM Project_Milestone__c];
    List<Project_Milestone__c> onboardingList = [
      SELECT Id, Name, Type__c
      FROM Project_Milestone__c
      WHERE Name = 'Kick Off Onboarding'
    ];

    User currentUser = [
      SELECT Id, Name
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];

    OpportunityDataWrapper OpportunityData = new OpportunityDataWrapper();
    OpportunityData.oppRec = oppRec;
    if (oppPrimaryContList.size() > 0) {
      OpportunityData.oppPrimaryContact = oppPrimaryContList[0];
    }
    OpportunityData.currentUser = currentUser;
    if (displayInfoRec != null) {
      OpportunityData.DealsHandoffNotes = displayInfoRec.Deals_Handoff_Notes__c;
      OpportunityData.DesiredOutcomes = displayInfoRec.Desired_Outcomes__c;
    }
    OpportunityData.onboardingTemplateList = onboardingList;
    return OpportunityData;
  }

  @AuraEnabled
  public static List<Onboarding_Checklist__c> getOnboardingCheckList(){
    List<Onboarding_Checklist__c> onBoardList = new List<Onboarding_Checklist__c>();
    onBoardList = [select Id, Question__c,Response_Option__c,Selection_Type__c, Index__c 
                  FROM Onboarding_Checklist__c 
                  WHERE Is_Active__c = true 
                  ORDER BY Index__c ASC];
    system.debug('onBoardList:::'+onBoardList.size());
    return onBoardList;
  }

  @AuraEnabled
  public static string updateAccount(String jsonAccountInput) {
    try {
      System.debug('line 78: '+jsonAccountInput);
      AccountWrapper accWrapper = (AccountWrapper) JSON.deserialize(
        jsonAccountInput,
        AccountWrapper.class
      );
      System.debug('line 83: '+accWrapper);
      Account updateAccount = new Account();
      updateAccount.Ownership = accWrapper.entityValue;
      updateAccount.Id = accWrapper.accountId;
      updateAccount.Industry = accWrapper.lob;
      updateAccount.Sub_Lob__c = accWrapper.subLob;
      updateAccount.CIN__c = accWrapper.cin;
      updateAccount.PAN__c = accWrapper.pan;
      updateAccount.GST__c = accWrapper.gst;
      updateAccount.Phone = accWrapper.phone;
      updateAccount.Merchant_Site_Url__c = accWrapper.merchantSiteURL;
      updateAccount.Website = accWrapper.website;
      updateAccount.Support_Email__c = accWrapper.supportEmail;
      updateAccount.Registered_Name__c = accWrapper.registeredName;
      updateAccount.Account_Holder_Name__c = accWrapper.accHolderName;
      updateAccount.Owner_Director_PAN_Number__c = accWrapper.ownerPan;
      System.debug('line 99: '+updateAccount);
      update updateAccount;
      return 'success';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<ChecklistWrapper> ChecklistTaskData(
    String templateId,
    String entityType
  ) {
    List<Checklist__c> checklistRec = [
      SELECT Id, Name
      FROM Checklist__c
      WHERE Project_Milestone__c = :templateId
    ];

    Set<Id> checkListIdSet = new Set<Id>();
    for (Checklist__c checkRec : checklistRec) {
      // if(checkRec.Name!='Document Verification'){
      checkListIdSet.add(checkRec.Id);
      // }
    }

    Map<Id, List<TaskWrapper>> checkListTaskMap = new Map<Id, List<TaskWrapper>>();
    List<Milestone_Task__c> mileStoneTaskList = [
      SELECT
        Id,
        Name,
        Checklist__c,
        Due_day__c,
        Checklist__r.Name,
        Select_Entity_Type__c
      FROM Milestone_Task__c
      WHERE Checklist__c IN :checkListIdSet
    ];
    List<Milestone_Task__c> mileStoneTaskList2 = [
      SELECT
        Id,
        Name,
        Checklist__c,
        Due_day__c,
        Checklist__r.Name,
        Select_Entity_Type__c
      FROM Milestone_Task__c
      WHERE
        Checklist__r.Name = 'Document Verification'
        AND Select_Entity_Type__c = :entityType
    ];
    mileStoneTaskList.addAll(mileStoneTaskList2);

    for (Milestone_Task__c task : mileStoneTaskList) {
      TaskWrapper taskRec = new TaskWrapper();
      taskRec.taskRec = task;
      taskRec.selected = true;
      taskRec.Name = task.Name;
      taskRec.DueDay = task.Due_day__c;
      taskRec.taskId = task.Id;
      taskRec.checklistId = task.Checklist__c;
      taskRec.checklistName = task.Checklist__r.Name;
      if (checkListTaskMap.containsKey(task.Checklist__c)) {
        checkListTaskMap.get(task.Checklist__c).add(taskRec);
      } else {
        checkListTaskMap.put(
          task.Checklist__c,
          new List<TaskWrapper>{ taskRec }
        );
      }
    }

    List<ChecklistWrapper> checklistData = new List<ChecklistWrapper>();
    for (Checklist__c checkRec : checklistRec) {
      ChecklistWrapper CheckData = new ChecklistWrapper();
      CheckData.checkListRec = checkRec;
      CheckData.checklistId = checkRec.Id;
      CheckData.Name = checkRec.Name;
      CheckData.selected = true;
      CheckData.taskList = checkListTaskMap.get(checkRec.Id);
      checklistData.add(CheckData);
    }

    return checklistData;
  }

  @AuraEnabled
  public static string createCaseChecklist(Case caseRec, List<ChecklistWrapper> checkList, List<DocChecklistWrapper> docChecklist,String accountId) {

    system.debug('caseRec::'+caseRec);
    try {
      if (caseRec != null) {
       
      Database.SaveResult caseResult = Database.insert(caseRec, true);

      if(caseResult.isSuccess() && !Test.isRunningTest()){
        CashfreeDataSynQueue caseQueue = new CashfreeDataSynQueue(caseResult.getId());
        Id jobId = System.enqueueJob(caseQueue);
      }
       

        if(docChecklist.size() != 0){
        List<Collected_Document__c> collDocList = new List<Collected_Document__c>();
        for (DocChecklistWrapper docCheck : docChecklist) {
          Collected_Document__c collDocRecrd = new Collected_Document__c();
          collDocRecrd.Name = docCheck.label;
          collDocRecrd.isCollected__c = docCheck.selected;
          collDocRecrd.Case__c = caseRec.Id;
          collDocList.add(collDocRecrd);
        }
        if (collDocList.size() > 0) {
          Insert collDocList;
        }
      }

        Set<Id> checkListIdSet = new Set<Id>();
        List<TaskWrapper> taskWList = new List<TaskWrapper>();
        Map<String, Id> newChecklistMap = new Map<String, Id>();
        List<Case_Checklist__c> newCheckList = new List<Case_Checklist__c>();
        for (ChecklistWrapper check : checkList) {
          System.debug('check::' + check);
          Case_Checklist__c newRec = new Case_Checklist__c();
          newRec.Name = check.Name;
          newRec.Case__c = caseRec.Id;
          if (!check.newTask) {
            newRec.Checklist__c = check.checklistId;
          }
          if (check.taskList != null) {
            taskWList.addAll(check.taskList);
          }
          newCheckList.add(newRec);
        }

        if (newCheckList.size() > 0) {
          insert newCheckList;
        }

        for (Case_Checklist__c check : newCheckList) {
          newChecklistMap.put(check.Name, check.Id);
        }

        List<Task> newTaskList = new List<Task>();
        for (TaskWrapper taskWrap : taskWList) {
          Task taskRec = new Task();
          taskRec.Subject = taskWrap.Name;
          taskRec.ActivityDate = System.today().addDays(7);
          taskRec.WhatId = newChecklistMap.get(taskWrap.checklistName);
          newTaskList.add(taskRec);
        }

        if (newTaskList.size() > 0) {
          insert newTaskList;
        }
    
        return 'suuccess';
      }

     return 'error';
    } catch (Exception e) {
      System.debug('Error:::' + e.getMessage());
      System.debug('Error::::' + e.getLineNumber());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Case_Checklist__c> caseChecklist(String recordId) {
    try {
      return [
        SELECT
          Id,
          Name,
          Completed__c,
          Checklist__c,
          (
            SELECT
              Id,
              Subject,
              OwnerId,
              Owner.Name,
              Status,
              Link__c,
              ActivityDate
            FROM Tasks
          )
        FROM Case_Checklist__c
        WHERE
          Case__c = :recordId
          AND Name != 'Sales Approval'
          AND Name != 'Bank Ops Approval'
          AND Name != 'Risk Team Approval'
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  
  @AuraEnabled
  public static List<ContentDocumentLink> getAllAttachmenterlatedtoTask(String recordId) {
    try {
     
      List<Case_Checklist__c> taskrec=[ SELECT Id,Name, Completed__c,Checklist__c,
                                        (SELECT Id, Subject,  OwnerId, Owner.Name, Status, Link__c, ActivityDate 
                                        FROM Tasks )
                                        FROM Case_Checklist__c
                                        WHERE Case__c = :recordId
                                          AND Name != 'Sales Approval'
                                          AND Name != 'Bank Ops Approval'
                                          AND Name != 'Risk Team Approval'
      ];
      set<id> taskid = new set<id>();
      for(Case_Checklist__c casecheckitm : taskrec){
        for(Task itm :casecheckitm.Tasks){
          taskid.add(itm.id);
        }
      }
      system.debug('taskids'+taskid);
      if(taskid.size()>0){
          return [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:taskid];
      }
      else{
        return null;
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   // return null;
  }
  
  @AuraEnabled
  public static string uploadfileonTask(String taskid, String contentverid, String deletedocverid)  {
    try {
      
      system.debug('taskid result :::'+taskid);
      system.debug('conVersionId result :::'+contentverid);

      if(contentverid!=Null){

        ContentDocumentLink contentdoclink =new ContentDocumentLink();
        contentdoclink.ContentDocumentId=contentverid;
        contentdoclink.LinkedEntityId=taskid;
        insert contentdoclink;

        if(deletedocverid!= null){

          ContentDocumentLink deletecontentdoclink =new ContentDocumentLink();

          deletecontentdoclink = [SELECT id,ContentDocumentId,LinkedEntityId 
                                  FROM ContentDocumentLink 
                                  WHERE ContentDocumentId=:deletedocverid AND LinkedEntityId=:taskid LIMIT 1];
           if(deletecontentdoclink!=null){
            delete deletecontentdoclink;
           }                       
        }
      }
      return 'success';

    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }


  @AuraEnabled
  public static string createOnBoardResponseRecord(List<OnboardingChecklistResponseWrapper> onboardList, String recordId){
    try{
      System.debug('line 407 onboardList:::'+onboardList);
      List<Onboarding_Checklist_Response__c> onboardResponseList = new List<Onboarding_Checklist_Response__c>();
      for(Integer i=0; i<onboardList.size(); i++){
        Onboarding_Checklist_Response__c onboardResponse = new Onboarding_Checklist_Response__c();
        onboardResponse.Onboarding_Checklist__c = onboardList[i].QuestionId;
        onboardResponse.Opportunity__c = recordId;
        onboardResponse.Question__c = onboardList[i].QuestionName;
        onboardResponse.Response__c = onboardList[i].QuestionResponse;
        onboardResponseList.add(onboardResponse);
      }
      if(onboardResponseList.size() > 0){
        insert onboardResponseList;
        System.debug('onboardResponseList:::'+onboardResponseList);      
      }
    }catch(Exception e){
      System.debug('Error: '+e.getCause());
      System.debug('Error: '+e.getLineNumber());
      System.debug('Error: '+e.getMessage());
      return 'error';
    }
    
    return 'success';  

  }



  @AuraEnabled
  public static string updateTask(String taskId, String statusValue) {
    try {
      Task updateTask = new Task();
      updateTask.Status = statusValue;
      updateTask.Id = taskId;
      updateTask.Description = 'Done';
      update updateTask;
      return 'success';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static List<Collected_Document__c> caseCollDocuments(String recordId) {
    try {
      Case caseRecord = [
        SELECT Id, ParentId
        FROM Case
        WHERE Id = :recordId
        LIMIT 1
      ];
      if (caseRecord.ParentId != null) {
        recordId = caseRecord.ParentId;
      } else {
        //do nothing....
      }
      return [SELECT Id, Name, isCollected__c FROM Collected_Document__c WHERE Case__c = :recordId];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
 
 
 
  @AuraEnabled
  public static string createTask(
    Date taskduedate,
    String taskSubject,
    String whatId
  ) {
    try {
      System.debug('whatId::' + whatId);
      if (taskSubject != '' && taskduedate != null) {
        Task createTask = new Task();
        createTask.Subject = taskSubject;
        createTask.ActivityDate = taskduedate;
        createTask.WhatId = whatId;
        insert createTask;
        System.debug('createTask::' + createTask);
        return 'success';
      }
      return 'error';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static string deleteTask(String taskId) {
    try {
      System.debug('taskId::' + taskId);
      if (taskId != null) {
        Task deleteTsk = new Task();
        deleteTsk.Id = taskId;
        delete deleteTsk;
        System.debug('deleteTsk::' + deleteTsk);
        return 'success';
      }
      return 'error';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static string updateTaskSubject(String taskId, String subject) {
    try {
      System.debug('subjectName::' + subject);
      Task updateTask = new Task();
      updateTask.Id = taskId;
      updateTask.Subject = subject;
      update updateTask;
      System.debug('updateTaskRecrd::' + updateTask);
      return 'success';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static string createNewCaseChecklist(
    String caseRecId,
    String checkList
  ) {
    try {
      if (caseRecId != null) {
        List<Case_Checklist__c> newCheckList = new List<Case_Checklist__c>();
        System.debug('checkList::' + checkList);
        if (checkList != '' || checkList != null) {
          System.debug('check::' + checkList);
          Case_Checklist__c newRec = new Case_Checklist__c();
          newRec.Name = checkList;
          newRec.Case__c = caseRecId;
          newCheckList.add(newRec);
        }

        if (newCheckList.size() > 0) {
          insert newCheckList;
          return 'success';
        }
      }
      return 'error';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static List<OptionsWrapper> getOptionsForApprovalType(
    String recordId
  ) {
    List<OptionsWrapper> ApprovalList = new List<OptionsWrapper>();
    Schema.DescribeFieldResult fieldResult = Case.Approval__c.getDescribe();
    List<Schema.PicklistEntry> typeValue = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : typeValue) {
      OptionsWrapper pickistValueOption = new OptionsWrapper();
      pickistValueOption.label = pickListVal.getLabel();
      pickistValueOption.value = pickListVal.getValue();
      ApprovalList.add(pickistValueOption);
    }
    System.debug('ApprovalList' + ApprovalList);
    return ApprovalList;
  }

  @AuraEnabled
  public static List<OptionsWrapper> fetchSubLobPicklistValues() {
    List<OptionsWrapper> result = new List<OptionsWrapper>();
    Schema.DescribeFieldResult fieldResult = Account.Sub_LOB__c.getDescribe();
    List<Schema.PicklistEntry> pickListValue = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry value : pickListValue) {
      OptionsWrapper pickistValueOption = new OptionsWrapper();
      pickistValueOption.label = value.getLabel();
      pickistValueOption.value = value.getValue();
      result.add(pickistValueOption);
    }
    return result;
  }

  @AuraEnabled
  public static List<OptionsWrapper> getOptionsForOwnershipPicklist(
    String recordId
  ) {
    List<OptionsWrapper> ownershipList = new List<OptionsWrapper>();
    Schema.DescribeFieldResult fieldResult = Account.Ownership.getDescribe();
    List<Schema.PicklistEntry> typeValue = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : typeValue) {
      OptionsWrapper pickistValueOption = new OptionsWrapper();
      pickistValueOption.label = pickListVal.getLabel();
      pickistValueOption.value = pickListVal.getValue();
      ownershipList.add(pickistValueOption);
    }
    System.debug('ownershipList' + ownershipList);
    return ownershipList;
  }

  @AuraEnabled
  public static List<OptionsWrapper> getOptionsForOppApprovalType(
    String recordId
  ) {
    List<OptionsWrapper> oppApprovalList = new List<OptionsWrapper>();
    Schema.DescribeFieldResult fieldResult = Opportunity.Approval__c.getDescribe();
    List<Schema.PicklistEntry> typeValue = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : typeValue) {
      OptionsWrapper pickistValueOption = new OptionsWrapper();
      pickistValueOption.label = pickListVal.getLabel();
      pickistValueOption.value = pickListVal.getValue();
      oppApprovalList.add(pickistValueOption);
    }
    System.debug('oppApprovalList' + oppApprovalList);
    return oppApprovalList;
  }

  @AuraEnabled
  public static string updateOpportunity(
    String recordId,
    String selectedApproval,
    String selectedComment,
    String selectedDeviation
  ) {
    try {
      String saveDeviation;
      if (selectedDeviation == 'Yes') {
        saveDeviation ='Yes';
      } else if (selectedDeviation == 'No'){
        saveDeviation = 'No';
      }
      else{
        saveDeviation ='';
      }

      // String sales;
      // string bank;
      // string risk;
      // string finance;

      // if(selectedApproval=='Sales Approval'){
      //   sales=selectedComment;
      // }
      // else if(selectedApproval=='Bank Ops Approval'){
      //   bank=selectedComment;
      // }
      // else if(selectedApproval=='Risk Approval'){
      //   risk=selectedComment;
      // }
      // else if(selectedApproval=='Finance Approval'){
      //   finance=selectedComment;
      // }

      if (selectedApproval != '') {
        Opportunity updateOpportunity = new Opportunity();
        updateOpportunity.Id = recordId;
        updateOpportunity.Approval__c = selectedApproval;
       // updateOpportunity.Comments__c = selectedComment;
       if(selectedApproval=='Sales Approval'){
       // sales=selectedComment;
        updateOpportunity.Sales_Approval_Comments__c=selectedComment;
      }
      else if(selectedApproval=='Bank Ops Approval'){
       // bank=selectedComment;
        updateOpportunity.Bank_Ops_Approval_Comments__c=selectedComment;
      }
      else if(selectedApproval=='Risk Approval'){
       // risk=selectedComment;
        updateOpportunity.Risk_Approval_Comments__c=selectedComment;
      }
      else if(selectedApproval=='Finance Approval'){
        //finance=selectedComment;
        updateOpportunity.Finance_Approval_Comments__c=selectedComment;
      }

        updateOpportunity.Any_Deviation__c = saveDeviation;
        update updateOpportunity;
        return 'success';
      }
      return 'error';
    } catch (Exception e) {
      System.debug('Error Message:::' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description : method used to update approval field  process on case and map comment
   *                field to their respective comment fields
   * @parameter: 1.Case Record Id
   *             2.Aproval For (Bank Ops, Sales Approval, Risk Approval And Finanace Approval)
   *             3.Approval Comments
   * @return: Result could be success and error
   */
  @AuraEnabled
  public static String updateCase(
    String recordId,
    String selectedApproval,
    String submitterComment
  ) {
    try {
      if (selectedApproval != '') {
        Case updateCase = new Case();
        updateCase.Id = recordId;
        updateCase.Approval__c = selectedApproval;
        if (updateCase.Approval__c == 'Bank Approval') {
          updateCase.Bank_Ops_Comment__c = submitterComment;
        } else if (updateCase.Approval__c == 'Risk Team Approval') {
          updateCase.Risk_Team_Comment__c = submitterComment;
        } else if (updateCase.Approval__c == 'Sales Team Approval') {
          updateCase.Sales_Team_Comment__c = submitterComment;
        } else if (updateCase.Approval__c == 'Finance Approval') {
          updateCase.Finance_Comment__c = submitterComment;
        }
        update updateCase;
        return 'success';
      }
      return 'error';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string updateDeviation(
    Id opportunityId,
    String deviationValue
  ) {
    String result = 'failed';
    Opportunity opp = new Opportunity();
    opp.Id = opportunityId;
    opp.Any_Deviation__c = deviationValue;
    System.debug('Opportunity Record::::' + opp);

    Database.SaveResult updateResult = Database.update(opp, true);
    if (updateResult.isSuccess()) {
      result = 'success';
    }
    return result;
  }

  @AuraEnabled
  public static CaseMappingWrapper createCaseWrapperVariable(String recordId) {
    CaseMappingWrapper result = new CaseMappingWrapper();
    Opportunity oppRecord = [
      SELECT
        Id,
        Account.Support_Email__c,
        Account.Merchant_Site_Url__c,
        Account.Name,
        Account.Id,
        Account.Registered_Name__c,
        Account.Website,
        Account.Industry,
        Account.Ownership,
        Account.BillingCity,
        Account.BillingState,
        Account.BillingStreet,
        Account.BillingPostalCode,
        Account.BillingCountry,
        Account.MID__c
      FROM Opportunity
      WHERE Id = :recordId
    ];

    if (oppRecord != null) {
      CaseMappingWrapper wrapper = new CaseMappingWrapper();
      wrapper.accountName = oppRecord.Account.Name;
      if (oppRecord.Account.MID__c != null) {
        wrapper.mid = oppRecord.Account.MID__c;
      } else {
        wrapper.mid = '';
      }
      // wrapper.mid = oppRecord.Account.MID__c != null ? oppRecord.Account.MID__c : null;
      wrapper.accountId = oppRecord.Account.Id;
      wrapper.supportEmail = oppRecord.Account.Support_Email__c;
      wrapper.merchantSiteUrl = oppRecord.Account.Merchant_Site_Url__c;
      wrapper.registerBusinessName = oppRecord.Account.Registered_Name__c;
      wrapper.website = oppRecord.Account.Website;
      wrapper.lob = oppRecord.Account.Industry;
      wrapper.entityType = oppRecord.Account.Ownership;
      String street = (oppRecord.Account.BillingStreet == null
        ? ''
        : String.valueOf(oppRecord.Account.BillingStreet) + ', ');
      String city = (oppRecord.Account.BillingCity == null
        ? ''
        : String.valueOf(oppRecord.Account.BillingCity) + ', ');
      String state = (oppRecord.Account.BillingState == null
        ? ''
        : String.valueOf(oppRecord.Account.BillingState) + ', ');
      String country = (oppRecord.Account.BillingCountry == null
        ? ''
        : String.valueOf(oppRecord.Account.BillingCountry));
      wrapper.addressData = street + city + state + country;
      result = wrapper;
      return result;
    } else {
      return result;
    }
  }

  @AuraEnabled
  public static Contact fetchContactRecord(String contactId) {
    Contact conRecord = [
      SELECT Id, Email, Phone
      FROM Contact
      WHERE Id = :contactId
      LIMIT 1
    ];
    return conRecord;
  }

  @AuraEnabled
  public static InitiateOnboardingWrapper checkDeviationAndCaseStatus(
    String recordId
  ) {
    Boolean deviation = false;
    Boolean parentCase = false;
    InitiateOnboardingWrapper result = new InitiateOnboardingWrapper();
    result.opportunityDeviation = parentCase;
    result.parentCaseCreation = parentCase;
    List<Opportunity> oppRecord = [
      SELECT Id , Any_Deviation__c
      FROM Opportunity
      WHERE Id = :recordId
      LIMIT 1
    ];
    List<Case> caseRecord = [
      SELECT Id
      FROM Case
      WHERE Opportunity__c = :recordId AND Is_Parent__c = TRUE
      LIMIT 1
    ];
    if (caseRecord.size() != 0 && oppRecord.size() != 0) {
      //if(oppRecord[0].Any_Deviation__c ==true){
      result.opportunityDeviation = true;
      result.parentCaseCreation = true;
      //}
    } else if (oppRecord.size() != 0 && caseRecord.size() == 0) {
      // if(oppRecord[0].Any_Deviation__c ==true){
      result.opportunityDeviation = true;
      result.parentCaseCreation = false;
      //}
    }
    return result;
  }

  @AuraEnabled
  public static CaseSubjectName createCaseSubjectName(String recordId) {
    CaseSubjectName result = new CaseSubjectName();
    List<Opportunity> oppRecord = [
      SELECT Id, Name
      FROM Opportunity
      WHERE Id = :recordId
      LIMIT 1
    ];
    if (oppRecord.size() != 0) {
      result.subjectName = oppRecord[0].Name + ' - ' + 'Onboarding';
    }
    return result;
  }

  @AuraEnabled
  public static String updateSingleTaskRecord(String JSONInput) {
    String result = '';
    TaskUpdateWrapper taskRecord = (TaskUpdateWrapper) JSON.deserializeStrict(
      JSONInput,
      TaskUpdateWrapper.class
    );
    if (taskRecord != null) {
      Task updateTaskRecord = new Task();
      updateTaskRecord.Id = taskRecord.taskId;
      updateTaskRecord.Subject = taskRecord.Subject;
      updateTaskRecord.Status = taskRecord.status;
      updateTaskRecord.Link__c = taskRecord.link;
      if (updateTaskRecord.Status == 'Completed') {
        updateTaskRecord.Description = 'Done';
      }
      System.debug('Task Record:::' + updateTaskRecord);

      Database.SaveResult recordResult = Database.update(updateTaskRecord);
      if (recordResult.isSuccess()) {
        Id taskId = recordResult.getId();
        List<Task> taskData = [SELECT Id, WhatId FROM Task WHERE Id = :taskId];
        if (taskData[0].WhatId != null) {
          for (Task taskValue : [
            SELECT Id, Status, What.Name
            FROM Task
            WHERE WhatId = :taskData[0].WhatId
          ]) {
            System.debug('Task Name:::::' + taskValue);
            System.debug('Task Name::::' + taskValue.What.Name);
            if (
              taskValue.What.Name == 'Website Check' &&
              taskValue.Status == 'Completed'
            ) {
              result = 'Pass';
            } else {
              result = 'Fail';
              break;
            }
          }
        }
      }
    }
    return result;
  }

  @AuraEnabled
  public static String getingCaseId(String recordId) {
    System.debug('Record Id::::' + recordId);
    List<Case> casenewlist = new List<Case>();
    String objectName = '';
    String result = '';
    //WorkOrder workrec = [Select Id, CaseId From WorkOrder Where Id =:workId];
    List<Case> caselistrec = [
      SELECT Id, Work_Job__c
      FROM Case
      WHERE Id = :recordId
    ];
    // if(caselistrec.size() != 0){
    //     if(caselistrec[0].Work_Job__c == null){
    //         result = caselistrec[0].Id;
    //     }
    //     else{
    //         List<WorkOrder> workrec = [Select Id, CaseId
    //                              From WorkOrder
    //                              Where Id =:caselistrec[0].Work_Job__c LIMIT 1];
    //        if(workrec.size() != 0){
    //         result = workrec[0].CaseId;
    //        }
    //     }
    // }
    String recordPrefix = String.valueOf(recordId).substring(0, 3);
    System.debug('Prefic Name:::' + recordPrefix);
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    for (Schema.SObjectType sType : schemaMap.values()) {
      Schema.DescribeSObjectResult describeResult = sType.getDescribe();
      String prefix = describeResult.getKeyPrefix();
      if (prefix != null && prefix.equals(recordPrefix)) {
        objectName = describeResult.getName();
        System.debug('Object Name::::' + objectName);
        break;
      }
    }
    if (objectName == 'Case') {
      Case caseRecord = [
        SELECT Id, Is_Parent__c, ParentId
        FROM Case
        WHERE Id = :recordId
      ];

      if (caseRecord.Is_Parent__c == true) {
        result = String.valueOf(caseRecord.Id);
      } else {
        result = String.valueOf(caseRecord.ParentId);
      }
    } else if (objectName == 'WorkOrder') {
      WorkOrder wOrderRecord = [
        SELECT Id, CaseId
        FROM WorkOrder
        WHERE Id = :recordId
      ];
      if (wOrderRecord.CaseId != null) {
        result = String.valueOf(wOrderRecord.CaseId);
      }
    }
    return result;
  }

  @AuraEnabled(cacheable=true)
  public static String getPaymentGatewayProduct(String recordId) {
    String result = '';
    List<Opportunity_Product__c> oppProductList = [ SELECT Id, Name FROM Opportunity_Product__c WHERE Opportunity__c = :recordId];
    if (oppProductList.size() != 0) {
      result = oppProductList[0].Name;
    }
    return result;
  }

 
  public class CaseSubjectName {
    @AuraEnabled
    public String subjectName;
  }

  public class InitiateOnboardingWrapper {
    @AuraEnabled
    public Boolean opportunityDeviation;
    @AuraEnabled
    public Boolean parentCaseCreation;
  }

  public class OptionsWrapper {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }
  }

  public class OpportunityDataWrapper {
    @AuraEnabled
    public Opportunity oppRec { get; set; }
    @AuraEnabled
    public OpportunityContactRole oppPrimaryContact { get; set; }
    @AuraEnabled
    public User currentUser { get; set; }
    @AuraEnabled
    public String DealsHandoffNotes { get; set; }
    @AuraEnabled
    public String DesiredOutcomes { get; set; }
    @AuraEnabled
    public List<Project_Milestone__c> onboardingTemplateList { get; set; }
  }

  public class ChecklistWrapper {
    @AuraEnabled
    public Checklist__c checkListRec { get; set; }
    @AuraEnabled
    public String checklistId { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public Boolean selected { get; set; }
    @AuraEnabled
    public Boolean newTask { get; set; }
    @AuraEnabled
    public List<TaskWrapper> taskList { get; set; }
  }
  public class DocChecklistWrapper {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public Boolean selected { get; set; }
  }

  public class TaskWrapper {
    @AuraEnabled
    public Milestone_Task__c taskRec { get; set; }
    @AuraEnabled
    public String taskId { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public Decimal DueDay { get; set; }
    @AuraEnabled
    public Boolean selected { get; set; }
    @AuraEnabled
    public String checklistId { get; set; }
    @AuraEnabled
    public String checklistName { get; set; }
  }

  public class CaseMappingWrapper {
    @AuraEnabled
    public String businessEmail { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public String supportEmail { get; set; }
    @AuraEnabled
    public String registerBusinessName { get; set; }
    @AuraEnabled
    public String merchantSiteUrl { get; set; }
    @AuraEnabled
    public String businessName { get; set; }
    @AuraEnabled
    public String website { get; set; }
    @AuraEnabled
    public String lob { get; set; }
    @AuraEnabled
    public String entityType { get; set; }
    @AuraEnabled
    public String addressData { get; set; }
    @AuraEnabled
    public String mid { get; set; }
  }

  public class AccountWrapper {
    @AuraEnabled public String accountId;
    @AuraEnabled public String lob;
    @AuraEnabled public String subLob;
    @AuraEnabled public String cin;
    @AuraEnabled public String gst;
    @AuraEnabled public String pan;
    @AuraEnabled public String entityValue;
    @AuraEnabled public String phone;
    @AuraEnabled public String merchantSiteURL;
    @AuraEnabled public String supportEmail;
    @AuraEnabled public String registeredName;
    @AuraEnabled public String accHolderName;
    @AuraEnabled public String ownerPan;
    @AuraEnabled public String accountEmail;
    @AuraEnabled public String website;
  }

  public class TaskUpdateWrapper {
    @AuraEnabled
    public String taskId;
    @AuraEnabled
    public String Subject;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String link;
  }

  public class OnboardingChecklistResponseWrapper{
    @AuraEnabled public Id QuestionId{get;set;}
    @AuraEnabled public String QuestionName{get;set;}
    @AuraEnabled public String QuestionResponse{get;set;}
  }
}