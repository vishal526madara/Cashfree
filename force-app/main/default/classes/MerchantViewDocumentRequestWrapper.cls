/**
 * @description       : 
 * @author            : Saurav Kashyap
 * @group             : SK Group
 * @last modified on  : 16-12-2022
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   16-12-2022   Saurav Kashyap   Initial Version
**/
public with sharing class MerchantViewDocumentRequestWrapper {
	/*{    
        "email":"email@email.com",  
        "name":"account name",   
        "phone":"spoc phone"
    }*/
	public String email;
	public String name;
	public String phone;

	

	/**
	* @description 
	* @author Saurav Kashyap | 16-12-2022 
	* @param String json 
	* @return MerchantViewDocumentRequestWrapper 
	**/
	public static MerchantViewDocumentRequestWrapper parse(String json) {
		return (MerchantViewDocumentRequestWrapper) System.JSON.deserialize(json, MerchantViewDocumentRequestWrapper.class);
	}
}