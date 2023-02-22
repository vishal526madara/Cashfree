/*********************
 * @description: class is used to create onboarding and bypass all custom validation on
 *               opportunity
 * @creatddate: 29 Dec,2022
 * @author: Appstrail Developer(Vishal)
 *
 **********************/
public class MerchantOnboardingCreation {
  public static RestResponse readRequest(String jsonRequest) {
    Savepoint sp = Database.setSavepoint();

    RestResponse responseResult = new RestResponse();
    try {
      MerchantOnboardingRequest onboardingCase = (MerchantOnboardingRequest) JSON.deserialize(
        jsonRequest,
        MerchantOnboardingRequest.class
      );
      System.debug('Opportunity Id::::' + onboardingCase);
      if (
        onboardingCase.opportunityId == null &&
        !onboardingCase.initiateOnboarding
      ) {
        System.debug('If Condition Pass');
        return generateErrorResponse('Opportunity Id does not exist');
      } else {
        responseResult = validteOpportunityRecord(onboardingCase.opportunityId);
        if (responseResult.responseBody != null) {
          return responseResult;
        }

        return createOnboardingCase(onboardingCase.opportunityId);
      }
    } catch (Exception e) {
      Database.rollback(sp);
      Map<String, String> exceptionMap = new Map<String, String>();
      exceptionMap.put('status', 'error');
      exceptionMap.put('message', e.getMessage());

      responseResult.statusCode = 403;
      responseResult.responseBody = Blob.valueOf(JSON.serialize(exceptionMap));
      return responseResult;
    }
  }

  private static RestResponse createOnboardingCase(String opportunityId) {
    RestResponse finalResponse = new RestResponse();
    Opportunity oppRecord = [
      SELECT Id, AccountId, Name
      FROM Opportunity
      WHERE Id = :opportunityId
    ];
    System.debug('oppRecord>>>>' + oppRecord);

    /*****************************************************************************************************************/

    Account accRecord = [
      SELECT
        Id,
        Website,
        Registered_Name__c,
        Merchant_Site_Url__c,
        MID__c,
        Industry,
        Ownership
      FROM Account
      WHERE Id = :oppRecord.AccountId
    ];

    List<Contact> conRecord = [
      SELECT Id, Phone, Email
      FROM Contact
      WHERE AccountId = :oppRecord.AccountId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    Project_Milestone__c mileStone = [
      SELECT Id
      FROM Project_Milestone__c
      WHERE Name = 'Kick Off Onboarding'
    ];

    /*******************************************************************************************************************/

    //creating new onboarding case
    Case caseRecord = new Case();
    if (accRecord != null) {
      caseRecord.AccountId = accRecord.Id;
      caseRecord.Registered_Business_Name__c = accRecord.Registered_Name__c !=
        null
        ? accRecord.Registered_Name__c
        : '';
      caseRecord.Website__c = accRecord.Website != null
        ? accRecord.Website
        : null;
      caseRecord.Type = 'Onboarding';
      caseRecord.Case_For__c = 'Onboarding Team';
      caseRecord.Subject = oppRecord.Name + '- Onboarding';
      caseRecord.Start_Date__c = System.today();
      caseRecord.Opportunity__c = oppRecord.Id != null ? oppRecord.Id : null;
      caseRecord.Onboarding_Template__c = mileStone.Id != null
        ? mileStone.Id
        : null;
      caseRecord.Merchant_Site_Url__c = accRecord.Merchant_Site_Url__c != null
        ? accRecord.Merchant_Site_Url__c
        : '';
      caseRecord.MID__c = accRecord.MID__c != null ? accRecord.MID__c : '';
      caseRecord.LOB__c = accRecord.Industry != null ? accRecord.Industry : '';
      caseRecord.Entity_Type__c = accRecord.Ownership != null
        ? accRecord.Ownership
        : '';
      if (conRecord.size() != 0) {
        caseRecord.ContactId = conRecord[0].Id != null ? conRecord[0].Id : null;
      }

      List<OnBoardingController.ChecklistWrapper> checkList = OnBoardingController.ChecklistTaskData(
        caseRecord.Onboarding_Template__c,
        caseRecord.Entity_Type__c
      );
      for (OnBoardingController.ChecklistWrapper check : checkList) {
        check.newTask = false;
      }
      System.debug('List Data::::::' + checkList);
      CaseResponse caseResult = createCaseChecklist(
        caseRecord,
        checkList,
        String.valueOf(accRecord.Id)
      );
      if (caseResult.status == 'suuccess') {
        Opportunity updateOpp = new Opportunity();
        updateOpp.Id = opportunityId;
        updateOpp.StageName = 'Onboarding';
        updateOpp.External_Onboardong__c = true;

        Database.SaveResult updateOppResult = Database.update(updateOpp, true);
        if (updateOppResult.isSuccess()) {
          return generateSuccesssResponse(caseResult.caseId);
        }
      } else if (caseResult.status == 'error') {
        return generateErrorResponse('Failed To Create Record');
      }
    }
    return finalResponse;
  }

  private static RestResponse generateSuccesssResponse(String caseId) {
    RestResponse response = new RestResponse();
    Map<String, String> successResponseMap = new Map<String, String>();
    successResponseMap.put('status', 'success');
    successResponseMap.put('message', 'Onboarding initated Successfully');
    successResponseMap.put('caseId', caseId);

    response.statusCode = 200;
    response.responseBody = Blob.valueOf(JSON.serialize(successResponseMap));
    return response;
  }

  private static RestResponse generateErrorResponse(String message) {
    System.debug('Message:::' + message);
    Map<String, String> errorResponseMap = new Map<String, String>();
    errorResponseMap.put('message', message);
    errorResponseMap.put('status', 'error');
    RestResponse errorResponse = new RestResponse();
    errorResponse.statusCode = 400;
    errorResponse.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));

    return errorResponse;
  }

  private static RestResponse validteOpportunityRecord(String oppId) {
    RestResponse responseResult = new RestResponse();
    Map<String, String> responseMap = new Map<String, String>();
    List<Opportunity> oppRecord = [
      SELECT Id
      FROM Opportunity
      WHERE Id = :oppId
    ];
    if (oppRecord.size() == 0) {
      responseMap.put('status', 'error');
      responseMap.put('message', 'Opportunity Does Not Exist');

      responseResult.statusCode = 404;
      responseResult.responseBody = Blob.valueOf(JSON.serialize(responseMap));
      return responseResult;
    } else {
      List<Case> caseRecord = [
        SELECT Id, Is_Parent__c, Subject
        FROM Case
        WHERE Opportunity__c = :oppRecord[0].Id AND Is_Parent__c = TRUE
      ];
      System.debug('caserecord>>>>>>>>>>>>>>' + caseRecord);
      if (caseRecord.size() != 0) {
        responseMap.put('status', 'error');
        responseMap.put('message', 'Customer Already Onboarded');
        responseResult.statusCode = 400;
        responseResult.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        return responseResult;
      }
    }
    return responseResult;
  }

  /********************************
   * @description: method used to create onboardiing case with specific task list or checkList
   * @parameter: Case Record, check list of task and account id
   * @return: case id with message, message could be success or error
   *****************************/
  private static CaseResponse createCaseChecklist(
    Case caseRec,
    List<OnBoardingController.ChecklistWrapper> checkList,
    String accountId
  ) {
    CaseResponse result = new CaseResponse();
    result.caseId = null;
    result.status = 'error';
    Database.SaveResult caseResult = Database.insert(caseRec, true);
    if (caseResult.isSuccess()) {
      result.caseId = caseResult.getId();
      result.status = 'suuccess';
      CashfreeDataSynQueue caseQueue = new CashfreeDataSynQueue(
        caseResult.getId()
      );
      Id jobId = System.enqueueJob(caseQueue);
    }

    Set<Id> checkListIdSet = new Set<Id>();
    List<OnBoardingController.TaskWrapper> taskWList = new List<OnBoardingController.TaskWrapper>();
    Map<String, Id> newChecklistMap = new Map<String, Id>();
    List<Case_Checklist__c> newCheckList = new List<Case_Checklist__c>();
    for (OnBoardingController.ChecklistWrapper check : checkList) {
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
    for (OnBoardingController.TaskWrapper taskWrap : taskWList) {
      Task taskRec = new Task();
      taskRec.Subject = taskWrap.Name;
      taskRec.ActivityDate = System.today().addDays(7);
      taskRec.WhatId = newChecklistMap.get(taskWrap.checklistName);
      newTaskList.add(taskRec);
    }

    if (newTaskList.size() > 0) {
      insert newTaskList;
    }

    return result;
  }
  /***********************************
     * {
        "opportunityId": "1",
        "initiateOnboarding": true
        }
     *******************************/
  public class MerchantOnboardingRequest {
    public String opportunityId;
    public Boolean initiateOnboarding;
  }

  public class CaseResponse {
    public String caseId;
    public String status;
  }
}
