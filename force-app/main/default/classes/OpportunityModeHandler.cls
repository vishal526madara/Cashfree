/**
 * @description:
 * @date:
 * @updateDate:
 * @author: Savita (Appstrail Developer)
 * */
public with sharing class OpportunityModeHandler {
  public static void afterInsert(List<Opportunity_Mode__c> modeList) {
    System.debug('Function Called:::');
    checkDeviation(modeList);
  }

  public static void afterUpdate(
    List<Opportunity_Mode__c> modeList,
    Map<Id, Opportunity_Mode__c> modeMap
  ) {
    List<Opportunity_Mode__c> inputList = new List<Opportunity_Mode__c>();
    for (Opportunity_Mode__c mode : modeList) {
      if (
        mode.Actual_Price__c != modeMap.get(mode.Id).Actual_Price__c ||
        mode.Actual_Price_Percent__c !=
        modeMap.get(mode.Id).Actual_Price_Percent__c
      ) {
        inputList.add(mode);
      }
    }

    if (inputList.size() != 0) {
      checkDeviation(modeList);
    }
  }

  public static void checkDeviation(List<Opportunity_Mode__c> modeList) {
    // try{
    Set<Id> opportunityIdSet = new Set<Id>();
    Set<Id> commercialIdSet = new Set<Id>();
    Set<Id> oppProdcutIdSet = new Set<Id>();

    Map<Id, List<Opportunity_Mode__c>> oppProductModeMap = new Map<Id, List<Opportunity_Mode__c>>();
    Map<Id, List<Opportunity_Mode__c>> oppModeMap = new Map<Id, List<Opportunity_Mode__c>>();
    Map<Id, Id> oppAndProductMap = new Map<Id, Id>();
    Id oppId;

    Map<Id, Commercial__c> commercialMap = new Map<Id, Commercial__c>();

    List<Opportunity> updateList = new List<Opportunity>();

    for (Opportunity_Mode__c mode : modeList) {
      commercialIdSet.add(mode.Commercial__c);
      oppProdcutIdSet.add(mode.Opportunity_Product__c);

      if (!oppProductModeMap.containsKey(mode.Opportunity_Product__c)) {
        List<Opportunity_Mode__c> tempList = new List<Opportunity_Mode__c>();
        tempList.add(mode);
        oppProductModeMap.put(mode.Opportunity_Product__c, tempList);
      } else {
        oppProductModeMap.get(mode.Opportunity_Product__c).add(mode);
      }
    }

    for (Opportunity_Product__c oppProduct : [
      SELECT Id, Opportunity__c
      FROM Opportunity_Product__c
      WHERE Id IN :oppProdcutIdSet
    ]) {
      oppAndProductMap.put(oppProduct.Id, oppProduct.Opportunity__c);
    }

    for (Commercial__c commercial : [
      SELECT Id, Commercial_Price__c, Commercials__c
      FROM Commercial__c
      WHERE Id IN :commercialIdSet
    ]) {
      commercialMap.put(commercial.Id, commercial);
    }

    for (Opportunity_Mode__c mode : modeList) {
      oppId = oppAndProductMap.get(mode.Opportunity_Product__c);
      if (!oppModeMap.containsKey(oppId)) {
        List<Opportunity_Mode__c> tempList = new List<Opportunity_Mode__c>();
        tempList.add(mode);
        oppModeMap.put(oppId, tempList);
      } else {
        oppModeMap.get(oppId).add(mode);
      }
    }

    List<User> getAdminUserId = [
      SELECT Id, Division1__c
      FROM User
      WHERE Name = 'Salesforce Admin'
      LIMIT 1
    ];
    List<Opportunity> oppList = [
      SELECT Id, Account.AccountSource
      FROM Opportunity
      WHERE Id = :oppId
    ];

    List<User> getCurrentUser = [
      SELECT Id, Division1__c, Sub_Division__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    System.debug('getCurrentUser' + getCurrentUser);

    /*List<Pricing_Approval_Matrix__c> getApprovalMatrixRec = [SELECT Id, Approver__c, Account_Source__c, Division__c, Sub_Division__c 
                                                              FROM Pricing_Approval_Matrix__c 
                                                              WHERE Is_Active__c = true  
                                                              AND Division__c =: getCurrentUser[0].Division1__c 
                                                              AND Sub_Division__c =: getCurrentUser[0].Sub_Division__c 
                                                              AND Account_Source__c =: oppList[0].Account.AccountSource 
                                                              ORDER BY CreatedDate DESC 
                                                              LIMIT 1];*/
    List<Pricing_Approval_Matrix__c> getApprovalMatrixRec = [
      SELECT Id, Approver__c, Account_Source__c, Division__c, Sub_Division__c
      FROM Pricing_Approval_Matrix__c
      WHERE Is_Active__c = TRUE
    ];

    for (Id iterateOppId : oppModeMap.keySet()) {
      for (Opportunity_Mode__c mode : oppModeMap.get(iterateOppId)) {
        System.debug('Pass::');
        if (
          mode.Actual_Price__c <
          commercialMap.get(mode.Commercial__c).Commercial_Price__c ||
          mode.Actual_Price_Percent__c <
          commercialMap.get(mode.Commercial__c).Commercials__c
        ) {
          Opportunity opp = new Opportunity();
          opp.Id = iterateOppId;
          opp.Any_Deviation__c = 'Yes';
          opp.Product_Price__c = 'Price Changed';
          System.debug('Opportunity Record::::' + opp);
          updateList.add(opp);
          break;
        }
      }
    }
    String approvalProcessName = 'Price_Change_Approval';
    String subComments = 'Submitted for approval. Please approve.';
    if (updateList.size() != 0) {
      System.debug('List Size:::::' + updateList);
      update updateList;

      for (Integer i = 0; i < updateList.size(); i++) {
        System.debug('inside line 126 for');
        System.debug(
          'i: ' + i + ': ' + updateList[i].Id + ' ' + updateList[i].OwnerId
        );
        System.debug('test getApprovalMatrixRec: ' + getApprovalMatrixRec);
        System.debug('test getAdminUserId: ' + getAdminUserId);
        sendForApproval(
          updateList[i].Id,
          updateList[i].OwnerId,
          subComments,
          approvalProcessName,
          getApprovalMatrixRec,
          getCurrentUser,
          oppList
        );
      }
    }
  }

  /**
   * @description:Sending Approval Based on Pricing_Approval_Matrix__c Records
   * @parameter:objectId:OpportunityId,submitterId:CurrentUserId ,subComments:Approval Submission comments,approvalProcessName,
   * 				getApprovalMatrixRec:Pricing_Approval_Matrix__c Records,getCurrentUser,opportunityList:new opportunity Record.
   * @return :void
   * ***/
  public static void sendForApproval(
    Id objectId,
    Id submitterId,
    String subComments,
    String approvalProcessName,
    List<Pricing_Approval_Matrix__c> getApprovalMatrixRec,
    List<User> getCurrentUser,
    List<Opportunity> opportunityList
  ) {
    List<User> getAdminUserId = [
      SELECT Id, Division1__c
      FROM User
      WHERE Name = 'Salesforce Admin'
      LIMIT 1
    ];
    Set<Id> accIdSet = new Set<Id>();
    for (Opportunity oppList : opportunityList) {
      accIdSet.add(oppList.AccountId);
    }
    List<Account> accountList = [
      SELECT Id, Name, AccountSource
      FROM Account
      WHERE Id IN :accIdSet
    ];
    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments(subComments);
    req.setObjectId(objectId);
    req.setProcessDefinitionNameOrId(approvalProcessName);
    Set<String> acctSourceSet = new Set<String>();
    Set<String> divisonSet = new Set<String>();
    Set<String> subDivSet = new Set<String>();
    Map<String, Pricing_Approval_Matrix__c> approvalMatrixMap = new Map<String, Pricing_Approval_Matrix__c>();
    for (Pricing_Approval_Matrix__c priceMatrix : getApprovalMatrixRec) {
      acctSourceSet.add(priceMatrix.Account_Source__c);
      divisonSet.add(priceMatrix.Division__c);
      subDivSet.add(priceMatrix.Sub_Division__c);
      approvalMatrixMap.put(
        priceMatrix.Account_Source__c +
          priceMatrix.Division__c +
          priceMatrix.Sub_Division__c,
        priceMatrix
      );
    }
    for (String key : approvalMatrixMap.keySet()) {
      System.debug('Key:::' + key);
      System.debug('approvalMatrixMap' + approvalMatrixMap.get(key));
    }

    for (Account accList : accountList) {
      for (User userList : getCurrentUser) {
        String accSource = accList.AccountSource;
        String divison = userList.Division1__c;
        String subDiv = userList.Sub_Division__c;
        String approvalMatrixApproverId = '';
        String userRec =
          accList.AccountSource +
          userList.Division1__c +
          userList.Sub_Division__c;
        System.debug('Opportunity Key:::' + userRec);
        if (approvalMatrixMap.containsKey(userRec)) {
          approvalMatrixApproverId = approvalMatrixMap.get(userRec).Approver__c;
        } else {
          if (!acctSourceSet.contains(accList.AccountSource))
            accSource = 'Any';
          if (!divisonSet.contains(userList.Division1__c))
            divison = 'Any';
          if (!subDivSet.contains(userList.Sub_Division__c))
            subDiv = 'Any';
          System.debug('Opportunity Key:::' + accSource + divison + subDiv);
          if (approvalMatrixMap.containsKey(accSource + divison + subDiv)) {
            approvalMatrixApproverId = approvalMatrixMap.get(
                accSource + divison + subDiv
              )
              .Approver__c;
          } else {
            if (approvalMatrixMap.containsKey(accSource + divison + 'Any')) {
              approvalMatrixApproverId = approvalMatrixMap.get(
                  accSource + divison + subDiv
                )
                .Approver__c;
            } else if (
              approvalMatrixMap.containsKey(accSource + 'Any' + subDiv)
            ) {
              approvalMatrixApproverId = approvalMatrixMap.get(
                  accSource + divison + subDiv
                )
                .Approver__c;
            } else if (
              approvalMatrixMap.containsKey('Any' + divison + subDiv)
            ) {
              approvalMatrixApproverId = approvalMatrixMap.get(
                  accSource + divison + subDiv
                )
                .Approver__c;
            } else if (
              approvalMatrixMap.containsKey(accSource + 'Any' + 'Any')
            ) {
              approvalMatrixApproverId = approvalMatrixMap.get(
                  accSource + divison + subDiv
                )
                .Approver__c;
            } else if (approvalMatrixMap.containsKey('Any' + 'Any' + subDiv)) {
              approvalMatrixApproverId = approvalMatrixMap.get(
                  accSource + divison + subDiv
                )
                .Approver__c;
            } else if (approvalMatrixMap.containsKey('Any' + divison + 'Any')) {
              approvalMatrixApproverId = approvalMatrixMap.get(
                  accSource + divison + subDiv
                )
                .Approver__c;
            }
          }
        }
        req.setSubmitterId(userList.Id);
        if (!String.isBlank(approvalMatrixApproverId)) {
          req.setNextApproverIds(new List<Id>{ approvalMatrixApproverId });
        } else {
          req.setNextApproverIds(new List<ID>{ getAdminUserId[0].Id });
        }
      }
    }

    req.setSkipEntryCriteria(true); //submit the approval request for processing
    Approval.ProcessResult result = Approval.process(req);
    System.debug('Submitted for approval successfully: ' + result.isSuccess()); //display if the reqeust was successful
  }
}
