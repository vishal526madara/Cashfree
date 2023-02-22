/**
 * @description       :
 * @author            : Saurav Kashyap
 * @group             :
 * @last modified on  : 12-01-2022
 **/

/* @description:(Request Data) method used to callout to Cashfree database and perform POST Operation,
*               In which Merchant Gets Added to Their DB.
* @parameter: serialize input in string format
*             example: to create Merchant
				{    
					"email":"email@email.com",  
					"name":"account name",   
					"phone":"spoc phone"
				}
*/
public class AddMerchantRequestWrapper {
  public String email;
  public String name;
  public String phone;

  public static AddMerchantRequestWrapper parse(String json) {
    return (AddMerchantRequestWrapper) System.JSON.deserialize(
      json,
      AddMerchantRequestWrapper.class
    );
  }
}
