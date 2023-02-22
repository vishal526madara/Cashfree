/**
 * @description       :
 * @author            : Saurav Kashyap
 * @group             :
 * @last modified on  : 12-01-2022
 **/

/* @description:(Response Data) method used to callout to Cashfree database and perform POST Operation,
*               In which MerchantID Gets Returned to The Salesforce DB.
* @parameter: serialize input in string format
*             example: response Structure
				{    
					"status":"success",
					"data":
							{
								"merchantId":2335
							}
				}
*/
public class AddMerchantResponseWrapper {
  public String status;
  public Data data;

  public class Data {
    public Integer merchantId;
  }

  public static AddMerchantResponseWrapper parse(String json) {
    return (AddMerchantResponseWrapper) System.JSON.deserialize(
      json,
      AddMerchantResponseWrapper.class
    );
  }
}
