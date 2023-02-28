/**
 * @description:
 * @author:
 * @updateBy: Vishal Hembrom
 * @updatedDate: 3 Feb, 2023
 **/
public without sharing class ProductController {
  @AuraEnabled
  public static String opportunityId(String recordId) {
    try {
      List<Case> getCaseDetails = [
        SELECT Id, Opportunity__c
        FROM Case
        WHERE Id = :recordId
        LIMIT 1
      ];
      if (getCaseDetails.size() > 0) {
        return getCaseDetails[0].Opportunity__c;
      } else {
        return '';
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Product__c> productData() {
    try {
      return [
        SELECT
          Id,
          Name,
          Description__c,
          Product_Image__c,
          Mode_Label__c,
          Settlement_Cycle_Label__c
        FROM Product__c
        WHERE Is_Active__c = TRUE
        ORDER BY Index__c ASC
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static CheckboxList getModesRecord(String productId) {
    CheckboxList dataList = new CheckboxList();
    dataList.modesList = [
      SELECT Id, Name, (SELECT Id, Name, Commercials__c FROM Commercials__r)
      FROM Modes__c
      WHERE Product__c = :productId
      ORDER BY Index__c ASC
    ];
    dataList.settlementList = [
      SELECT Id, Name, Commercial__c, Commercial_Price__c
      FROM Settlement__c
      WHERE Product__c = :productId
      ORDER BY Index__c ASC
    ];
    dataList.modeWrapperList = generatePaymentGatewayProduct(productId);
    return dataList;
  }

  private static List<ModeWrapper> generatePaymentGatewayProduct(
    String productId
  ) {
    Set<Id> modeIdSet = new Set<Id>();
    Set<Id> methodTypeIdSet = new Set<Id>();
    List<ModeWrapper> result = new List<ModeWrapper>();
    Map<Id, List<Method_Type__c>> methodTypeMap = new Map<Id, List<Method_Type__c>>();
    Map<Id, List<Commercial__c>> commercialsMap = new Map<Id, List<Commercial__c>>();

    for (Modes__c mode : [
      SELECT Id, Name
      FROM Modes__c
      WHERE Product__c = :productId AND Active__c = TRUE
    ]) {
      modeIdSet.add(mode.Id);
      ModeWrapper mWrapper = new ModeWrapper();
      mWrapper.modeId = mode.Id;
      mWrapper.modeName = mode.Name;
      result.add(mWrapper);
    }

    System.debug('Mode Id Set:::' + modeIdSet);
    System.debug('Wrapper Data:::' + result);

    for (Method_Type__c methodType : [
      SELECT Id, Name, Mode__c
      FROM Method_Type__c
      WHERE Mode__c IN :modeIdSet
    ]) {
      methodTypeIdSet.add(methodType.Id);
      if (!methodTypeMap.containsKey(methodType.Mode__c)) {
        List<Method_Type__c> methodList = new List<Method_Type__c>();
        methodList.add(methodType);
        methodTypeMap.put(methodType.Mode__c, methodList);
      } else {
        methodTypeMap.get(methodType.Mode__c).add(methodType);
      }
    }

    System.debug('Method Map::::' + methodTypeMap);

    for (Commercial__c commercials : [
      SELECT Id, Name, Method_Type__c
      FROM Commercial__c
      WHERE Method_Type__c IN :methodTypeIdSet
    ]) {
      if (!commercialsMap.containsKey(commercials.Method_Type__c)) {
        List<Commercial__c> commercialList = new List<Commercial__c>();
        commercialList.add(commercials);
        commercialsMap.put(commercials.Method_Type__c, commercialList);
      } else {
        commercialsMap.get(commercials.Method_Type__c).add(commercials);
      }
    }

    System.debug('Commercial Map::::' + commercialsMap);

    for (ModeWrapper mWrapper : result) {
      System.debug('Value::::' + mWrapper);
      List<MethodTypeWrapper> mTypeList = new List<MethodTypeWrapper>();
      System.debug('Pass::' + mWrapper.modeId);
      System.debug('Pass::' + methodTypeMap.get(mWrapper.modeId));
      if (methodTypeMap.get(mWrapper.modeId) != null) {
        for (
          Method_Type__c methodTypeRecord : methodTypeMap.get(mWrapper.modeId)
        ) {
          MethodTypeWrapper methodTypeWrapperData = new MethodTypeWrapper();
          methodTypeWrapperData.methodModeId = mWrapper.modeId;
          methodTypeWrapperData.methodTypeId = methodTypeRecord.Id;
          methodTypeWrapperData.methodName = methodTypeRecord.Name;
          mTypeList.add(methodTypeWrapperData);
        }
      }
      mWrapper.methodTypeWrapperList = mTypeList;
    }

    for (ModeWrapper mWrapper : result) {
      for (MethodTypeWrapper methodWrap : mWrapper.methodTypeWrapperList) {
        List<CommercialWrapper> commList = new List<CommercialWrapper>();
        for (Commercial__c comm : commercialsMap.get(methodWrap.methodTypeId)) {
          CommercialWrapper comWrap = new CommercialWrapper();
          comWrap.modeId = mWrapper.modeId;
          comWrap.methodTypeId = methodWrap.methodTypeId;
          comWrap.commericalId = comm.Id;
          comWrap.commericalName = comm.Name;
          commList.add(comWrap);
        }
        methodWrap.commercialWrapperList = commList;
      }
    }

    System.debug('Main Result:::' + result);

    return result;
  }

  @AuraEnabled
  public static List<Commercial__c> getCommercialRec(String modeId) {
    // List<Modes__c> modesRecList=[SELECT Id,Name,(SELECT Id,Name,Commercials__c,Commercial_Price__c FROM Commercials__r) FROM Modes__c WHERE Id IN:modeList];
    List<Commercial__c> commercialList = [
      SELECT
        Id,
        Name,
        Commercials__c,
        Commercial_Price__c,
        Mode__c,
        Mode__r.Name,
        Method_Type__r.Name,
        Method_Type__r.Mode__r.Name
      FROM Commercial__c
      WHERE Mode__c = :modeId
    ];
    return commercialList;
  }

  @AuraEnabled
  public static List<Commercial__c> paymentGateWayCommercials(
    String methodTypeId
  ) {
    List<Commercial__c> commercialList = [
      SELECT
        Id,
        Name,
        Commercials__c,
        Commercial_Price__c,
        Mode__c,
        Mode__r.Name,
        Method_Type__c,
        Method_Type__r.Name,
        Bank_Validation__c,
        Method_Type__r.Mode__r.Name
      FROM Commercial__c
      WHERE Method_Type__c = :methodTypeId
    ];
    return commercialList;
  }

  @AuraEnabled
  public static string saveProduct(
    Opportunity_Product__c productRec,
    List<Opportunity_Mode__c> oppProList,
    List<Settlement__c> settlementList
  ) {
    try {
      List<Opportunity_Add_On__c> addOnList = new List<Opportunity_Add_On__c>();
      if (productRec != null) {
        insert productRec;
        for (Opportunity_Mode__c modeRec : oppProList) {
          modeRec.Opportunity_Product__c = productRec.Id;
        }
        if (oppProList.size() > 0) {
          insert oppProList;

          for (Opportunity_Mode__c modeRec : oppProList) {
            for (Settlement__c settlement : settlementList) {
              Opportunity_Add_On__c oppAddOn = new Opportunity_Add_On__c();
              oppAddOn.Name = settlement.Name;
              oppAddOn.Settlement__c = settlement.Id;
              oppAddOn.Opportunity_Mode__c = modeRec.Id;
              addOnList.add(oppAddOn);
            }
          }

          if (addOnList.size() > 0) {
            insert addOnList;
          }
        }
        return 'success';
      }
      return 'error';
    } catch (Exception e) {
      System.debug('Error::::' + e.getLineNumber());
      System.debug('Error::::' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static OpportunityProductWrapper OpportunityProduct(String recordId) {
    try {
      Map<String, List<Opportunity_Mode__c>> listofUpdatedProducts = new Map<String, List<Opportunity_Mode__c>>();
      Map<String, List<Opportunity_Mode__c>> selectedCommercialMap = new Map<String, List<Opportunity_Mode__c>>();
      List<OppProductUpdatedWrapper> oppProductUpdatedWrapper = new List<OppProductUpdatedWrapper>();
      List<String> settlementId = new List<String>();
      OpportunityProductWrapper DataWrapper = new OpportunityProductWrapper();
      List<Opportunity_Product__c> oppProList = [
        SELECT
          Id,
          Name,
          Product__c,
          Opportunity__c,
          Product__r.Product_Image__c,
          Product__r.Mode_Label__c,
          Product__r.Settlement_Cycle_Label__c,
          (
            SELECT
              Id,
              Name,
              Actual_Price_Percent__c,
              Actual_Price__c,
              Mode__r.Name,
              Mode__c,
              Commercial__r.Commercials__c,
              Commercial__r.Commercial_Price__c,
              Settlement__c,
              Settlement__r.Name,
              Settlement__r.Commercial__c,
              Add_On__c,
              Add_On_Price__c,
              Method_Type__c,
              Method_Type__r.Name,
              Commercial__r.Method_Type__r.Name,
              Commercial__r.Method_Type__r.Mode__r.Name
            FROM Opportunity_Mode__r
          )
        FROM Opportunity_Product__c
        WHERE Opportunity__c = :recordId
        LIMIT 1
      ];

      List<Opportunity_Add_On__c> addOnList = new List<Opportunity_Add_On__c>();
      if (oppProList.size() > 0) {
        if (oppProList[0].Opportunity_Mode__r.size() > 0) {
          String ModeRecId = oppProList[0].Opportunity_Mode__r[0].Id;
          addOnList = [
            SELECT Id, Name, Settlement__c
            FROM Opportunity_Add_On__c
            WHERE Opportunity_Mode__c = :ModeRecId
          ];
        }
        //Mode Object Queried data ... >>>
        DataWrapper.modeListMaster = [
          SELECT Id, Name, (SELECT Id, Name, Commercials__c FROM Commercials__r)
          FROM Modes__c
          WHERE Product__c = :oppProList[0].Product__c
        ];

        System.debug(
          'DataWrapper.modeListMaster: ' + DataWrapper.modeListMaster
        );
        for (Opportunity_Add_On__c addOn : addOnList) {
          settlementId.add(addOn.Settlement__c);
        }

        DataWrapper.settlementIdList = settlementId;
        DataWrapper.settlementList = [
          SELECT Id, Name, Commercial__c, Commercial_Price__c
          FROM Settlement__c
          WHERE Product__c = :oppProList[0].Product__c
        ];
        DataWrapper.OppPro = oppProList[0];
        //............................................................................................................................................
        // OpportunityModeRelated Queried data ... >>>
        DataWrapper.oppModeList = oppProList[0].Opportunity_Mode__r;
        for (Opportunity_Mode__c opm : oppProList[0].Opportunity_Mode__r) {
          if (opm.Mode__r.Name != null) {
            if (!selectedCommercialMap.keySet().contains(opm.Mode__r.Name)) {
              selectedCommercialMap.put(
                opm.Mode__r.Name,
                new List<Opportunity_Mode__c>()
              );
              selectedCommercialMap.get(opm.Mode__r.Name).add(opm);
            } else {
              selectedCommercialMap.get(opm.Mode__r.Name).add(opm);
            }
          } else {
            if (
              !selectedCommercialMap.keySet()
                .contains(opm.Commercial__r.Method_Type__r.Mode__r.Name)
            ) {
              selectedCommercialMap.put(
                opm.Commercial__r.Method_Type__r.Mode__r.Name,
                new List<Opportunity_Mode__c>()
              );
              selectedCommercialMap.get(
                  opm.Commercial__r.Method_Type__r.Mode__r.Name
                )
                .add(opm);
            } else {
              selectedCommercialMap.get(
                  opm.Commercial__r.Method_Type__r.Mode__r.Name
                )
                .add(opm);
            }
          }
        }
        System.debug(
          'Map Seperated selectedCommercialMap values :1: ' +
          selectedCommercialMap
        );
        for (String str : selectedCommercialMap.keySet()) {
          OppProductUpdatedWrapper opn = new OppProductUpdatedWrapper();
          opn.modeName = str;
          opn.oppModeList = selectedCommercialMap.get(str);
          oppProductUpdatedWrapper.add(opn);
        }
        DataWrapper.listOfSelectedProducts = oppProductUpdatedWrapper;
        System.debug(
          'New List DataWrapper.listOfSelectedProducts Values :2: >>>' +
          DataWrapper.listOfSelectedProducts
        );
        System.debug(
          'New List Values :2: >>>' + DataWrapper.listOfSelectedProducts.size()
        );
        //..............................................................................................................................................
      }
      System.debug(DataWrapper);
      return DataWrapper;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string updateProduct(
    List<Opportunity_Mode__c> oppModeList,
    List<Opportunity_Mode__c> newList,
    List<String> deleteList,
    List<Settlement__c> settlementList
  ) {
    try {
      String flag;
      if (oppModeList.size() > 0) {
        update oppModeList;
        flag = 'success';
      }
      System.debug('List::' + newList);

      if (newList.size() > 0) {
        insert newList;
        flag = 'success';
      }

      // if(deleteList.size()>0){
      //     List<Opportunity_Mode__c> deleteRec=[SELECT Id FROM Opportunity_Mode__c
      //                                             WHERE Id IN:deleteList];
      //     delete deleteRec;
      //     flag='success';
      // }

      List<String> modeIdList = new List<String>();
      for (Opportunity_Mode__c modeRec : oppModeList) {
        modeIdList.add(modeRec.Id);
      }

      for (Opportunity_Mode__c modeRec : newList) {
        modeIdList.add(modeRec.Id);
      }

      List<Opportunity_Add_On__c> newAddOnList = new List<Opportunity_Add_On__c>();
      List<Opportunity_Add_On__c> addOnList = [
        SELECT Id
        FROM Opportunity_Add_On__c
        WHERE Opportunity_Mode__c IN :modeIdList
      ];

      if (addOnList.size() > 0) {
        delete addOnList;
      }

      for (String modeId : modeIdList) {
        for (Settlement__c settlement : settlementList) {
          Opportunity_Add_On__c oppAddOn = new Opportunity_Add_On__c();
          oppAddOn.Name = settlement.Name;
          oppAddOn.Settlement__c = settlement.Id;
          oppAddOn.Opportunity_Mode__c = modeId;
          newAddOnList.add(oppAddOn);
        }
      }

      if (newAddOnList.size() > 0) {
        insert newAddOnList;
        flag = 'success';
      }

      if (deleteList.size() > 0) {
        List<Opportunity_Mode__c> deleteRec = [
          SELECT Id
          FROM Opportunity_Mode__c
          WHERE Id IN :deleteList
        ];
        delete deleteRec;
        flag = 'success';
      }

      if (flag == 'success') {
        return 'success';
      }
      return 'error';
    } catch (Exception e) {
      System.debug('Error:::' + e.getLineNumber());
      System.debug('Error:::' + e.getCause());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string deleteProduct(String recordId) {
    try {
      List<Opportunity_Product__c> productList = [
        SELECT Id
        FROM Opportunity_Product__c
        WHERE Opportunity__c = :recordId
      ];
      if (productList.size() > 0) {
        delete productList;
        return 'success';
      }
      return 'error';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String chekTaskStatus(String caseId) {
    String result = 'Fail';
    String tempCheckListId = null;
    for (Case_CheckList__c caseCheckList : [
      SELECT Id, Name
      FROM Case_CheckList__c
      WHERE Case__c = :caseId
    ]) {
      if (caseCheckList.Name == 'Website Check') {
        tempCheckListId = String.valueOf(caseCheckList.Id);
        break;
      }
    }
    if (tempCheckListId != null) {
      for (Task taskRecord : [
        SELECT Id, Status
        FROM Task
        WHERE WhatId = :tempCheckListId
      ]) {
        if (taskRecord.Status == 'Completed') {
          result = 'Pass';
        } else {
          result = 'Fail';
          break;
        }
      }
    }
    return result;
  }

  /**
   * @createdDate: 19 Jan, 2022
   * @updateBy: Vishal Hembrom
   * @functionality: Check it is valid MID or not
   * @parameter: Onboarding case Id
   * @return: String result either 'Pass' or 'Fail'
   */
  @AuraEnabled
  public static String checkMerchantId(String caseId) {
    String result = 'Fail';
    List<Case> caseList = [
      SELECT Id, Account.MID__c
      FROM Case
      WHERE Id = :caseId
    ];
    if (caseList.size() == 0) {
      return result;
    } else if (caseList.size() != 0 && caseList[0].Account.MID__c == null) {
      return result;
    }

    Pattern isnumbers = Pattern.Compile('^[0-9]+$');
    Matcher midMatch = isnumbers.matcher(caseList[0].Account.MID__c);
    if (midMatch.Matches()) {
      return 'Pass';
    } else {
      return result;
    }
  }

  /********************************************************************************************************************
   * @author: Vishal Hembrom
   * @description: generate wrapper product list
   * @createdDate: 23rd Jan, 2023
   *
   *********************************************************************************************************************/

  @AuraEnabled
  public static OpportunityProductInformation fetchOpportunityProduct(
    String opportunityId
  ) {
    List<OpportunityProduct> opportunityProductList = new List<OpportunityProduct>();
    OpportunityProductInformation finalResult = new OpportunityProductInformation();
    List<Opportunity_Product__c> oppProduct = [
      SELECT Id
      FROM Opportunity_Product__c
      WHERE Opportunity__c = :opportunityId
    ];
    Map<String, List<Opportunity_Mode__c>> oppModeMap = new Map<String, List<Opportunity_Mode__c>>();

    for (Opportunity_Mode__c mode : [
      SELECT
        Id,
        Method_Type__c,
        Method_Type__r.Name,
        Method_Type__r.Mode__c,
        Method_Type__r.Mode__r.Name,
        Actual_Price__c,
        Actual_Price_Percent__c,
        Add_On__c,
        Commercial__r.Commercial_Price__c,
        Commercial__r.Commercials__c
      FROM Opportunity_Mode__c
      WHERE Opportunity_Product__c = :oppProduct[0].Id
    ]) {
      String customKey =
        mode.Method_Type__r.Mode__c +
        ' ' +
        mode.Method_Type__c;
      if (!oppModeMap.containsKey(customKey)) {
        List<Opportunity_Mode__c> tempList = new List<Opportunity_Mode__c>();
        tempList.add(mode);
        oppModeMap.put(customKey, tempList);
      } else {
        oppModeMap.get(customKey).add(mode);
      }
    }

    for (String modeAndMethodKey : oppModeMap.keySet()) {
      OpportunityProduct product = new OpportunityProduct();
      product.modeName = oppModeMap.get(modeAndMethodKey)[0]
        .Method_Type__r.Mode__r.Name;
      product.methodName = oppModeMap.get(modeAndMethodKey)[0]
        .Method_Type__r.Name;
      List<CommercialProduct> commercialProductList = new List<CommercialProduct>();
      for (Opportunity_Mode__c modeRecord : oppModeMap.get(modeAndMethodKey)) {
        CommercialProduct commercialProduct = new CommercialProduct();
        commercialProduct.actualPrice = modeRecord.Actual_Price__c;
        commercialProduct.actualPricePercentage = modeRecord.Actual_Price_Percent__c;
        commercialProduct.addOn = modeRecord.Add_On__c;
        commercialProduct.addOnPrice = modeRecord.Add_On__c;
        commercialProduct.commercialPercentage = modeRecord.Commercial__r.Commercials__c;
        commercialProduct.commercialPrice = modeRecord.Commercial__r.Commercial_Price__c;
        commercialProductList.add(commercialProduct);
      }
      product.commercialProduct = commercialProductList;
      opportunityProductList.add(product);
    }
    finalResult.opportunityProductList = opportunityProductList;
    return finalResult;
  }

  /**********************************************************************************************************************/

  public class OptionsWrapper {
    @AuraEnabled
    public String value { get; set; }
    @AuraEnabled
    public String label { get; set; }
  }

  public class CheckboxList {
    @AuraEnabled
    public List<Modes__c> modesList { get; set; }
    @AuraEnabled
    public List<Settlement__c> settlementList { get; set; }
    @AuraEnabled
    public List<ModeWrapper> modeWrapperList { get; set; }
  }

  public class OpportunityProductWrapper {
    @AuraEnabled
    public Opportunity_Product__c OppPro { get; set; }
    @AuraEnabled
    public List<Modes__c> modeListMaster { get; set; }
    @AuraEnabled
    public List<Settlement__c> settlementList { get; set; }
    @AuraEnabled
    public List<Opportunity_Mode__c> oppModeList { get; set; }
    //Newly Added Wrapper To Display List Of Products .... >>>>
    @AuraEnabled
    public List<OppProductUpdatedWrapper> listOfSelectedProducts { get; set; }
    //Newly Added Wrapper To Display List Of Products .... >>>>
    @AuraEnabled
    public List<String> settlementIdList { get; set; }
  }

  public class OppProductUpdatedWrapper {
    @AuraEnabled
    public String modeName { get; set; }
    @AuraEnabled
    public List<Opportunity_Mode__c> oppModeList { get; set; }
  }

  public class ModeWrapper {
    @AuraEnabled
    public String modeId { get; set; }
    @AuraEnabled
    public String modeName { get; set; }
    @AuraEnabled
    public List<MethodTypeWrapper> methodTypeWrapperList { get; set; }
  }

  public class MethodTypeWrapper {
    @AuraEnabled
    public String methodModeId { get; set; }
    @AuraEnabled
    public String methodTypeId { get; set; }
    @AuraEnabled
    public String methodName { get; set; }
    @AuraEnabled
    public List<CommercialWrapper> commercialWrapperList { get; set; }
  }

  public class CommercialWrapper {
    @AuraEnabled
    public String modeId { get; set; }
    @AuraEnabled
    public String methodTypeId { get; set; }
    @AuraEnabled
    public String commericalId { get; set; }
    @AuraEnabled
    public String commericalName { get; set; }
    @AuraEnabled
    public List<String> bankValidation { get; set; }
  }

  /**
   *
   *
   */

  public class OpportunityProductInformation {
    @AuraEnabled
    public List<OpportunityProduct> opportunityProductList { get; set; }
  }

  public class OpportunityProduct {
    @AuraEnabled
    public String modeName { get; set; }
    @AuraEnabled
    public String methodName { get; set; }
    @AuraEnabled
    public List<CommercialProduct> commercialProduct { get; set; }
  }

  public class CommercialProduct {
    @AuraEnabled
    public Double actualPricePercentage { get; set; }
    @AuraEnabled
    public Double actualPrice { get; set; }
    @AuraEnabled
    public Double addOn { get; set; }
    @AuraEnabled
    public Double addOnPrice { get; set; }
    @AuraEnabled
    public Double commercialPercentage { get; set; }
    @AuraEnabled
    public Double commercialPrice { get; set; }
  }

  /********************************************************************************************************* */
}
