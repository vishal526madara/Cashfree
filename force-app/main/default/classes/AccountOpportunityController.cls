/**
 * AccountOpportunityController
 *
 * Controller class for AccountOpportunityComponent, accountProductChartComponent.
 * @author Kartik Patkar, Appstrail
 * @date 08-12-2021
 *
 */
public with sharing class AccountOpportunityController {
  @AuraEnabled
  public static List<ProductData> accountOppProduct(String recordId) {
    try {
      Set<Id> selectedProIdSet = new Set<Id>();
      Map<Id, Decimal> proIdCountMap = new Map<Id, Decimal>();
      Map<Id, Merchant_Product__c> merchantProductMap = new Map<id, Merchant_Product__c>();
      List<Merchant_Product__c> merchantProdList = [
        SELECT Id, Name, Product__c, Product__r.Name, Status_Color__c
        FROM Merchant_Product__c
        WHERE Account__c = :recordId
      ];

      for (Merchant_Product__c merchantProd : merchantProdList) {
        merchantProductMap.put(merchantProd.Product__c, merchantProd);
        selectedProIdSet.add(merchantProd.Product__c);
        if (proIdCountMap.containsKey(merchantProd.Product__c)) {
          Decimal temp = proIdCountMap.get(merchantProd.Product__c);
          proIdCountMap.put(merchantProd.Product__c, temp + 1);
        } else {
          proIdCountMap.put(merchantProd.Product__c, 1);
        }
      }

      List<ProductData> productDataList = new List<ProductData>();
      for (Product__c proRec : [
        SELECT Id, Name, Product_Image__c, Product_Code__c
        FROM Product__c
        WHERE Is_Active__c = TRUE
        ORDER BY Index__c ASC
      ]) {
        ProductData product = new ProductData();
        product.Id = proRec.Id;
        if (merchantProductMap.containsKey(proRec.Id)) {
          product.productColor =
            'background-color : ' +
            merchantProductMap.get(proRec.Id).Status_Color__c;
          product.textColor =
            +'color:' + merchantProductMap.get(proRec.Id).Status_Color__c;
        } else
          product.productColor = '';
        product.productName = proRec.Name;
        product.productImage = proRec.Product_Image__c;
        // product.checked=selectedProIdSet.contains(proRec.Id);
        if (proIdCountMap.containsKey(proRec.Id)) {
          product.count = proIdCountMap.get(proRec.Id);
        } else {
          product.count = 0;
        }
        if (product.count > 0) {
          product.checked = true;
        }
        productDataList.add(product);
      }

      return productDataList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class ProductData {
    @AuraEnabled
    public String productName { get; set; }
    @AuraEnabled
    public String productImage { get; set; }
    @AuraEnabled
    public String productColor { get; set; }
    @AuraEnabled
    public String textColor { get; set; }
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public Boolean checked { get; set; }
    @AuraEnabled
    public Decimal count { get; set; }
  }
}
