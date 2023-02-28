public class MerchantProductWrapper {
  public String merchantId; //23434
  public Product[] products;
  public class Product {
    public String status; //Active
    public String productCode; //Payment Gateway
  }
  public static MerchantProductWrapper parse(String json) {
    return (MerchantProductWrapper) System.JSON.deserialize(
      json,
      MerchantProductWrapper.class
    );
  }

  /*static testMethod void testParse() {
		String json=		'{'+
		'  "merchantId": "23434",'+
		'  "products": ['+
		'    {'+
		'      "status": "Active",'+
		'      "productCode": "Payment Gateway"'+
		'    }'+
		'  ]'+
		'}';
		MerchantProductWrapper obj = parse(json);
		System.assert(obj != null);
	}*/
}
