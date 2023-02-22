@isTest
public class MerchantProductWebserviceTest {
  @testSetup
  static void makeData() {
    List<Account> accList = TestUtill.createAccount(1);
    accList[0].MID__c = '23434';
    insert accList;

    List<Product__c> productList = TestUtill.createProduct(6);
    productList[0].Product_Code__c = '1';
    productList[1].Product_Code__c = '2';
    productList[2].Product_Code__c = '3';
    productList[3].Product_Code__c = '4';
    productList[4].Product_Code__c = '5';
    productList[5].Product_Code__c = '5';

    insert productList;

    List<Merchant_Product__c> mProductList = TestUtill.createMerchantProduct(5);
    mProductList[0].Account__c = accList[0].Id;
    mProductList[0].Product__c = productList[0].Id;

    mProductList[1].Account__c = accList[0].Id;
    mProductList[1].Product__c = productList[1].Id;

    mProductList[2].Account__c = accList[0].Id;
    mProductList[2].Product__c = productList[2].Id;

    mProductList[3].Account__c = accList[0].Id;
    mProductList[3].Product__c = productList[3].Id;

    mProductList[4].Account__c = accList[0].Id;
    mProductList[4].Product__c = productList[4].Id;

    insert mProductList;
  }

  @isTest
  static void updateMerchantProductsTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/merchantProductUpdate'; //Request URL
    req.httpMethod = 'POST';

    String json =
      '{' +
      '  "merchantId": "23434",' +
      '  "products": [' +
      '    {' +
      '      "status": "Active",' +
      '      "productCode": "1"' +
      '     },' +
      '     {' +
      '      "status": "Active",' +
      '      "productCode": "2"' +
      '      },' +
      '      {' +
      '      "status": "Active",' +
      '      "productCode": "3"' +
      '       },' +
      '       {' +
      '      "status": "Active",' +
      '      "productCode": "4"' +
      '        },' +
      '        {' +
      '      "status": "Active",' +
      '      "productCode": "5"' +
      '         }' +
      '         ]' +
      '}';

    MerchantProductWrapper wrap = MerchantProductWrapper.parse(json);
    Set<String> productCodeSet = new Set<String>();
    for (MerchantProductWrapper.Product prod : wrap.products) {
      productCodeSet.add(prod.productCode);
    }

    List<Account> accList = new List<Account>();
    Account acc = new Account();
    acc.Name = 'Merchant Account';
    acc.MID__c = wrap.merchantId;
    accList.add(acc);
    // Insert accList;

    List<Product__c> ProductList = new List<Product__c>();

    for (string str : productCodeSet) {
      Product__c Pro1 = new Product__c();
      pro1.Name = str;
      ProductList.add(pro1);
    }
    Product__c Pro2 = new Product__c();
    pro2.Name = 'Product1';
    ProductList.add(pro2);
    //Insert ProductList;

    List<Merchant_Product__c> MerProList = new List<Merchant_Product__c>();

    for (Product__C product : ProductList) {
      Merchant_Product__c MerProduct = new Merchant_Product__c();
      MerProduct.Account__c = acc.Id;
      MerProduct.Product__c = ProductList[0].Id;
      MerProduct.Status__c = 'InActive';
      MerProList.add(MerProduct);
    }
    //Insert MerProList;

    req.requestBody = blob.valueOf(json);

    RestContext.request = req;
    RestContext.response = res;
    System.debug('res:::' + RestContext.response);
    System.debug('req:::' + RestContext.request);
    Test.startTest();
    MerchantProductWebservice.updateMerchantProducts();
    Test.stopTest();
  }

  @isTest
  static void updateMerchantProductsTest1() {
    delete [SELECT Id FROM Account];
    delete [SELECT Id FROM Product__c];
    delete [SELECT Id FROM Merchant_Product__c];

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/merchantProductUpdate'; //Request URL
    req.httpMethod = 'POST';

    String json =
      '{' +
      '  "merchantId": "23434",' +
      '  "products": [' +
      '    {' +
      '      "status": "Active",' +
      '      "productCode": "Payment Gateway"' +
      '    }' +
      '  ]' +
      '}';

    MerchantProductWrapper wrap = MerchantProductWrapper.parse(json);
    List<Account> accList = new List<Account>();
    Account acc = new Account();
    acc.Name = 'Merchant Account';
    acc.MID__c = wrap.merchantId;
    accList.add(acc);
    insert accList;

    req.requestBody = blob.valueOf(json);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    MerchantProductWebservice.updateMerchantProducts();
    Test.stopTest();
  }

  @isTest
  static void updateMerchantProductsTest2() {
    delete [SELECT Id FROM Account];
    delete [SELECT Id FROM Product__c];
    delete [SELECT Id FROM Merchant_Product__c];

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/merchantProductUpdate'; //Request URL
    req.httpMethod = 'POST';

    String json =
      '{' +
      '  "merchantId": "",' +
      '  "products": [' +
      '    {' +
      '      "status": "Active",' +
      '      "productCode": "Payment Gateway"' +
      '    }' +
      '  ]' +
      '}';

    MerchantProductWrapper wrap = MerchantProductWrapper.parse(json);

    req.requestBody = blob.valueOf(json);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    MerchantProductWebservice.updateMerchantProducts();
    Test.stopTest();
  }
  @isTest
  static void updateMerchantProductsTest3() {
    delete [SELECT Id FROM Account];
    delete [SELECT Id FROM Product__c];
    delete [SELECT Id FROM Merchant_Product__c];

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/merchantProductUpdate'; //Request URL
    req.httpMethod = 'POST';

    String json =
      '{' +
      '  "merchantId": "23434",' +
      '  "products": [' +
      '    {' +
      '      "status": "Active",' +
      '      "productCode": "Payment Gateway"' +
      '    }' +
      '  ]' +
      '}';

    MerchantProductWrapper wrap = MerchantProductWrapper.parse(json);
    Set<String> productCodeSet = new Set<String>();
    for (MerchantProductWrapper.Product prod : wrap.products) {
      productCodeSet.add(prod.productCode);
    }

    List<Account> accList = new List<Account>();
    Account acc = new Account();
    acc.Name = 'Merchant Account';
    acc.MID__c = wrap.merchantId;
    accList.add(acc);
    insert accList;

    List<Product__c> ProductList = new List<Product__c>();

    Product__c Pro2 = new Product__c();
    pro2.Name = 'Product1';
    ProductList.add(pro2);

    for (string str : productCodeSet) {
      Product__c Pro1 = new Product__c();
      pro1.Name = str;
      ProductList.add(pro1);
    }

    insert ProductList;

    List<Merchant_Product__c> MerProList = new List<Merchant_Product__c>();

    Merchant_Product__c MerProduct = new Merchant_Product__c();
    MerProduct.Account__c = acc.Id;
    MerProduct.Product__c = ProductList[0].Id;
    MerProduct.Status__c = 'InActive';
    MerProList.add(MerProduct);

    insert MerProList;

    req.requestBody = blob.valueOf(json);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    MerchantProductWebservice.updateMerchantProducts();
    Test.stopTest();
  }
}
