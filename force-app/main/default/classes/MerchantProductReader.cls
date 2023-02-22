public class MerchantProductReader {
  public static String readRequest(String jsonString) {
    Map<String, String> responseMap = new Map<String, String>();
    try {
      MerchantProductWrapper wrap = MerchantProductWrapper.parse(jsonString);
      Set<String> productCodeSet = new Set<String>();
      for (MerchantProductWrapper.Product prod : wrap.products) {
        productCodeSet.add(prod.productCode);
      }
      system.debug('productCodeSet-->' + productCodeSet);
      List<Account> acc = [
        SELECT
          Id,
          MID__c,
          (
            SELECT
              Id,
              Account__c,
              Product__r.Name,
              Product__r.Product_Code__c,
              Product__c
            FROM Merchant_Products__r
          )
        FROM Account
        WHERE MID__c = :wrap.merchantId
      ]; //change here

      if (acc.size() > 0) {
        String accountId = acc[0].Id;
        Map<String, Merchant_Product__c> merchantProductMap = new Map<String, Merchant_Product__c>();
        for (Merchant_Product__c prod : acc[0].Merchant_Products__r) {
          merchantProductMap.put(prod.Product__r.Product_Code__c, prod);
        }
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for (Product__c prod : [
          SELECT Id, Name, Product_Code__c
          FROM Product__C
          WHERE Product_Code__c IN :productCodeSet
        ]) {
          productMap.put(prod.Product_Code__c, prod);
        }
        system.debug('productMap-->' + productMap);
        List<Merchant_Product__c> merchantProductToUpdateList = new List<Merchant_Product__c>();

        for (MerchantProductWrapper.Product prod : wrap.products) {
          if (!productMap.containsKey(prod.productCode)) {
            responseMap.put('status', 'error');
            responseMap.put(
              'message',
              'No such product exist with ProductCode : ' + prod.productCode
            );
            break;
          } else {
            if (merchantProductMap.containsKey(prod.productCode)) {
              Merchant_Product__c mrProd = new Merchant_Product__c();
              mrProd.Id = merchantProductMap.get(prod.productCode).Id;
              mrProd.Status__c = prod.status;
              merchantProductToUpdateList.add(mrProd);
            } else {
              Merchant_Product__c mrProd = new Merchant_Product__c();
              //mrProd.Id = merchantProductMap.get(prod.productCode).Id;
              mrProd.Status__c = prod.status;
              mrProd.Product__c = productMap.get(prod.productCode).Id;
              mrProd.Account__c = accountId;
              merchantProductToUpdateList.add(mrProd);
            }
          }
        }

        if (merchantProductToUpdateList.size() > 0) {
          upsert merchantProductToUpdateList;
          responseMap.put('status', 'success');
          responseMap.put('message', 'Record Updated Successfully!');
        }
      }  //no such merchant exist
      else {
        responseMap.put('status', 'error');
        responseMap.put(
          'message',
          ' no such merchant exist with MID : ' + wrap.merchantId
        );
        //return responseMap
      }
    } catch (exception e) {
      system.debug('error>>>' + e.getMessage() + '-Line ' + e.getLineNumber());

      responseMap.put('status', 'error');
      responseMap.put('message', e.getMessage() + ' ' + e.getLineNumber());

      //ExceptionLogClass.LogException('RequestReader','readRequest(String requestBody)',e.getMessage() +'- Line-' + e.getLineNumber(),requestBody);
    }
    return JSON.serialize(responseMap);
    //return '';
  }
}
