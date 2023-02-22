public with sharing class BankOpsController {
  /**
   * @description: method used to create work orders with respect to child case
   * @modification: no requirement to create child case
   *                direct creation of work order and assigned to bank opes queue
   * @parameter  :parentCaseId
   *              Modelist(Opportunity Product)
   *              subject
   *              defaultQueueName
   * @return: string response
   *  */
  @AuraEnabled
  public static String getParentCaseDetails(
    Id parentCaseId,
    String selectedModes,
    String subjectinformation,
    String queueName
  ) {
    // try {
    List<ProductWrapper> commercialWrapperList = new List<ProductWrapper>();
    System.debug('queueName: ' + queueName);
    String queueDeveloperName;
    if (queueName == 'Onboarding Team') {
      queueDeveloperName = 'Onboarding_Team';
    } else if (queueName == 'Bank Ops Team') {
      queueDeveloperName = 'Bank_Ops_Queue';
    } /*else if(queueName == 'Risk Team'){
                queueDeveloperName = 'Risk_Team_queue';
            }*/
    Case getCaseDetails = [
      SELECT
        Id,
        CaseNumber,
        ContactId,
        AccountId,
        SuppliedName,
        SuppliedEmail,
        SuppliedPhone,
        Type,
        Subject,
        SuppliedCompany,
        Status,
        Reason,
        Origin,
        Language,
        Priority,
        Description,
        IsClosed,
        ClosedDate,
        ContactPhone,
        ContactMobile,
        ContactEmail,
        ContactFax,
        Comments,
        Opportunity__c,
        Opportunity_Product__c,
        Desired_Outcomes__c,
        Deal_Handoff_Notes__c,
        Onboarding_Template__c,
        ParentId,
        OwnerId,
        Start_Date__c,
        End_Date__c,
        Approval__c
      FROM Case
      WHERE Id = :parentCaseId
    ];

    // if(getCaseDetails != null){
    //     System.debug('Case Data::::'+ getCaseDetails);
    List<Group> queue = [
      SELECT Id, Name, DeveloperName, Type
      FROM Group
      WHERE Type = 'Queue' AND DeveloperName = :queueDeveloperName
      LIMIT 1
    ];

    /*for(Integer i=0; i<selectedModes.size(); i++){*/
    // Case caseCopy = getCaseDetails.clone(false, false, false, false);
    // caseCopy.ParentId = parentCaseId;
    // caseCopy.Subject = subjectinformation;
    // caseCopy.OwnerId = queue[0].Id;
    // caseCopy.Case_For__c = 'Bank Ops Team';
    // caseCopy.Type = 'Onboarding';
    // insert caseCopy;
    System.debug('List::::' + selectedModes);
    if (selectedModes != '') {
      commercialWrapperList = (List<ProductWrapper>) JSON.deserialize(
        selectedModes,
        List<ProductWrapper>.class
      );
      System.debug('Case List::::' + commercialWrapperList);
    }
    createWorkOrder(getCaseDetails, commercialWrapperList, queue[0].Id);
    /*}*/
    // }
    return 'success';
    // } catch (Exception e) {
    // System.debug('Error:::'+e.getCause());
    // System.debug('Error::::'+e.getLineNumber());
    // throw new AuraHandledException(e.getMessage());
    // }
  }

  /**
   * @description: create work order
   * @parameter: caseId, WorkOrder List, Queue Id
   * @return: NA
   **/
  @AuraEnabled
  public static void createWorkOrder(
    Case caseRecord,
    List<ProductWrapper> selectedModes,
    String queueId
  ) {
    try {
      //Map<Id,List<Bank_Ops__c>> bankOpsMap = new Map<Id,List<Bank_Ops__c>>();
      Map<Id, List<Bank_Ops_Junction__c>> bankOpsJunctionMap = new Map<Id, List<Bank_Ops_Junction__c>>();
      Map<Id, Commercial__c> commercialMap = new Map<Id, Commercial__c>();

      Set<String> commercialIdSet = new Set<String>();

      for (Integer i = 0; i < selectedModes.size(); i++) {
        commercialIdSet.add(selectedModes[i].commercialId);
      }

      System.debug('Id Set::::' + commercialIdSet);
      System.debug('Id Set:size:::' + commercialIdSet.size());
      if (!commercialIdSet.contains(null)) {
        System.debug('Id Set>>>::::' + commercialIdSet);
        for (Bank_Ops_Junction__c bankOpsJunction : [
          SELECT
            Id,
            Name,
            Commercial__c,
            Bank_Ops__c,
            Bank_Ops__r.Name,
            Bank_Ops__r.Bank__c
          FROM Bank_Ops_Junction__c
          WHERE Commercial__c IN :commercialIdSet
        ]) {
          system.debug('bankOpsJunction' + bankOpsJunction);
          if (!bankOpsJunctionMap.containsKey(bankOpsJunction.Commercial__c)) {
            List<Bank_Ops_Junction__c> bankOpsJunctionList = new List<Bank_Ops_Junction__c>();
            bankOpsJunctionList.add(bankOpsJunction);
            bankOpsJunctionMap.put(
              bankOpsJunction.Commercial__c,
              bankOpsJunctionList
            );
          } else {
            bankOpsJunctionMap.get(bankOpsJunction.Commercial__c)
              .add(bankOpsJunction);
          }
        }

        for (Commercial__c commercial : [
          SELECT
            Id,
            Name,
            Method_Type__r.Name,
            Method_Type__r.Mode__r.Name,
            Method_Type__r.Mode__r.Product__r.Name,
            Mode__c,
            Mode__r.Name
          FROM Commercial__c
          WHERE Id = :commercialIdSet
        ]) {
          if (!commercialMap.containsKey(commercial.Id)) {
            commercialMap.put(commercial.Id, commercial);
          }
        }
      }
      List<WorkOrder> workOrderList = new List<WorkOrder>();
      List<Id> bankIdList = new List<Id>();

      system.debug('bankOpsJunctionMap.size(t)>>>' + bankOpsJunctionMap.size());
      system.debug('commercialIdSet.size(t)>>>' + commercialIdSet.size());

      /**
       * @updateDate: 11 Oct,2022
       * @description: field mapping of Method and Method Details
       */
      if (bankOpsJunctionMap.size() != 0) {
        for (Id commerciaId : bankOpsJunctionMap.keySet()) {
          for (
            Bank_Ops_Junction__c bankOpsJunctionRecord : bankOpsJunctionMap.get(
              commerciaId
            )
          ) {
            if (!bankIdList.contains(bankOpsJunctionRecord.Bank_Ops__c)) {
              bankIdList.add(bankOpsJunctionRecord.Bank_Ops__c);
              WorkOrder wOrder = new WorkOrder();
              wOrder.Bank__c = bankOpsJunctionRecord.Bank_Ops__r.Bank__c;
              wOrder.Commercial__c = bankOpsJunctionRecord.Commercial__c;
              wOrder.OwnerId = caseRecord.OwnerId;
              wOrder.AccountId = caseRecord.AccountId;
              wOrder.ContactId = caseRecord.ContactId;
              wOrder.CaseId = caseRecord.Id;
              wOrder.Description = caseRecord.Description;
              //updated Line  11 Oct, 2022
              wOrder.Method__c = commercialMap.get(
                  bankOpsJunctionRecord.Commercial__c
                )
                .Method_Type__r.Mode__r.Name;
              wOrder.Method_Details__c = commercialMap.get(
                  bankOpsJunctionRecord.Commercial__c
                )
                .Method_Type__r.Name;
              //updated Line  11 Oct, 2022
              System.debug(
                'Value::::' +
                commercialMap.get(bankOpsJunctionRecord.Commercial__c)
                  .Method_Type__r.Mode__r.Product__r.Name
              );
              System.debug(
                'Value::::' +
                commercialMap.get(bankOpsJunctionRecord.Commercial__c)
                  .Method_Type__r.Mode__r.Name
              );
              System.debug(
                'Value::::' +
                commercialMap.get(bankOpsJunctionRecord.Commercial__c)
                  .Method_Type__r.Name
              );
              wOrder.Subject =
                commercialMap.get(bankOpsJunctionRecord.Commercial__c)
                  .Method_Type__r.Mode__r.Product__r.Name +
                ' ' +
                commercialMap.get(bankOpsJunctionRecord.Commercial__c)
                  .Method_Type__r.Mode__r.Name +
                ' ' +
                commercialMap.get(bankOpsJunctionRecord.Commercial__c)
                  .Method_Type__r.Name +
                ' - ' +
                bankOpsJunctionRecord.Bank_Ops__r.Name;
              wOrder.Priority = caseRecord.Priority;
              if (queueId != null) {
                wOrder.OwnerId = queueId;
              }
              workOrderList.add(wOrder);
            }
          }
        }
      }

      system.debug('bankOpsJunctionMap.size()>>>' + bankOpsJunctionMap.size());
      system.debug('commercialIdSet.size()>>>' + commercialIdSet.size());
      if (bankOpsJunctionMap.size() != commercialIdSet.size()) {
        for (Integer i = 0; i < selectedModes.size(); i++) {
          if (
            bankOpsJunctionMap.size() != 0 &&
            !bankOpsJunctionMap.containsKey(selectedModes[i].commercialId)
          ) {
            WorkOrder workOrderObj = new WorkOrder();
            workOrderObj.Commercial__c = selectedModes[i].commercialId;
            workOrderObj.OwnerId = caseRecord.OwnerId;
            workOrderObj.AccountId = caseRecord.AccountId;
            workOrderObj.ContactId = caseRecord.ContactId;
            workOrderObj.CaseId = caseRecord.Id;
            workOrderObj.Description = caseRecord.Description;
            workOrderObj.Subject = selectedModes[i].commercialName;
            workOrderObj.Priority = caseRecord.Priority;
            if (queueId != null) {
              workOrderObj.OwnerId = queueId;
            }
            System.debug('Work Order Record::::' + workOrderObj);
            workOrderList.add(workOrderObj);
          }
          /**
           * @description: If product is product is two level hierachy example : Auto Collect
           *               "Product --> Mode --> Commercials"
           * @instruction:  this line is used to create work order when who does not have bank ops
           *                example: Product --> Mode --> Method Type --> Commecials --> Banks Ops Junction <--- Bank Ops
           */
          else if (bankOpsJunctionMap.size() == 0) {
            WorkOrder workOrderObj = new WorkOrder();
            workOrderObj.Commercial__c = selectedModes[i].commercialId;
            workOrderObj.OwnerId = caseRecord.OwnerId;
            workOrderObj.AccountId = caseRecord.AccountId;
            workOrderObj.ContactId = caseRecord.ContactId;
            workOrderObj.CaseId = caseRecord.Id;
            workOrderObj.Description = caseRecord.Description;
            workOrderObj.Subject = selectedModes[i].commercialName;
            workOrderObj.Priority = caseRecord.Priority;
            if (queueId != null) {
              workOrderObj.OwnerId = queueId;
            }
            System.debug('Work Order Record::::' + workOrderObj);
            workOrderList.add(workOrderObj);
          }
        }
      }

      if (workOrderList.size() > 0) {
        insert workOrderList;

        /**
         * @updateDate: 30 Nov,2022
         * @description: update initiate bank ops checkbox to false
         * @author: Utkarsha Patil, Appstrail
         */
        //query the current case
        Case getCaseRecord = [
          SELECT Id, Initiate_Bank_Ops__c
          FROM Case
          WHERE Id = :caseRecord.Id
          LIMIT 1
        ];

        if (getCaseRecord != null) {
          //update the initiate bank ops field to false since work order are created
          getCaseRecord.Initiate_Bank_Ops__c = false;
          update getCaseRecord;
        }
      }

      //SELECT Id, OwnerId, WorkOrderNumber, AccountId, ContactId, CaseId, Description, Subject, Priority FROM WorkOrder
    } catch (Exception e) {
      System.debug('Error Number:::' + e.getLineNumber());
      System.debug('Error Message:::' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<ProductWrapper> getOpportunityProductDetails(
    Id oppRecordId
  ) {
    try {
      List<ProductWrapper> result = new List<ProductWrapper>();
      List<Opportunity_Mode__c> oppMode = new List<Opportunity_Mode__c>();
      List<String> oppModeList = new List<String>();
      Map<Id, List<Opportunity_Mode__c>> oppModeMap = new Map<Id, List<Opportunity_Mode__c>>();
      List<Opportunity_Product__c> oppProduct = [
        SELECT Id, Name
        FROM Opportunity_Product__c
        WHERE Opportunity__c = :oppRecordId
        LIMIT 1
      ];

      if (oppProduct.size() > 0) {
        oppMode = [
          SELECT
            Id,
            Commercial__c,
            Commercial__r.Name,
            Method_Type__c,
            Method_Type__r.Name
          FROM Opportunity_Mode__c
          WHERE Opportunity_Product__c = :oppProduct[0].Id
        ];
        if (oppMode.size() > 0) {
          for (Integer i = 0; i < oppMode.size(); i++) {
            ProductWrapper wrapper = new ProductWrapper();
            wrapper.commercialId = oppMode[i].Commercial__c;
            wrapper.commercialName = oppMode[i].Commercial__r.Name;
            result.add(wrapper);
          }
        }
      }

      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static Case getCaseRec(String recordId) {
    try {
      System.debug('recordId' + recordId);
      Case caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id = :recordId];
      System.debug('caseRec' + caseRec);
      return caseRec;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<MethodTypeWrapper> generatePaymentWrapper(
    String opportunityId
  ) {
    List<MethodTypeWrapper> result = new List<MethodTypeWrapper>();
    Map<Id, List<Opportunity_Mode__c>> oppModeMap = new Map<Id, List<Opportunity_Mode__c>>();
    List<Opportunity_Mode__c> oppModeList = new List<Opportunity_Mode__c>();
    List<Opportunity_Product__c> oppProduct = [
      SELECT Id
      FROM Opportunity_Product__c
      WHERE Opportunity__c = :opportunityId
      LIMIT 1
    ];
    if (oppProduct.size() != 0) {
      oppModeList = [
        SELECT
          Id,
          Commercial__c,
          Commercial__r.Name,
          Method_Type__c,
          Method_Type__r.Name
        FROM Opportunity_Mode__c
        WHERE Opportunity_Product__c = :oppProduct[0].Id
      ];
      if (oppModeList.size() != 0) {
        for (Opportunity_Mode__c mode : oppModeList) {
          if (!oppModeMap.containsKey(mode.Method_Type__c)) {
            List<Opportunity_Mode__c> modeList = new List<Opportunity_Mode__c>();
            modeList.add(mode);
            oppModeMap.put(mode.Method_Type__c, modeList);
          } else {
            oppModeMap.get(mode.Method_Type__c).add(mode);
          }
        }
        System.debug('Map Data::::' + oppModeMap);
        for (Id modeId : oppModeMap.keySet()) {
          MethodTypeWrapper parentWrapper = new MethodTypeWrapper();
          parentWrapper.methodId = oppModeMap.get(modeId).get(0).Method_Type__c;
          parentWrapper.methodName = oppModeMap.get(modeId)
            .get(0)
            .Method_Type__r.Name;
          List<ProductWrapper> parentProductWrapper = new List<ProductWrapper>();
          for (Opportunity_Mode__c oppMode : oppModeMap.get(modeId)) {
            ProductWrapper childWrapper = new ProductWrapper();
            childWrapper.commercialId = oppMode.Commercial__c;
            childWrapper.commercialName = oppMode.Commercial__r.Name;
            childWrapper.methodId = oppModeMap.get(modeId)
              .get(0)
              .Method_Type__c;
            parentProductWrapper.add(childWrapper);
          }
          parentWrapper.productWrapperList = parentProductWrapper;
          result.add(parentWrapper);
        }
      }
    }
    return result;
  }

  @AuraEnabled
  public static String opportunityProductName(String opportunityId) {
    String result = '';
    List<Opportunity_Product__c> oppProduct = [
      SELECT Id, Product__r.Name
      FROM Opportunity_Product__c
      WHERE Opportunity__c = :opportunityId
    ];
    if (oppProduct.size() != 0) {
      result = oppProduct[0].Product__r.Name;
    }
    return result;
  }

  public class MethodTypeWrapper {
    @AuraEnabled
    public String methodId { get; set; }
    @AuraEnabled
    public String methodName { get; set; }
    @AuraEnabled
    public List<ProductWrapper> productWrapperList { get; set; }
  }

  public class ProductWrapper {
    @AuraEnabled
    public String methodId { get; set; }
    @AuraEnabled
    public String commercialId { get; set; }
    @AuraEnabled
    public String commercialName { get; set; }
  }
}
