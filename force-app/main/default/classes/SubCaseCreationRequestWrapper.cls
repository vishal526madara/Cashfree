/**
 * @description       : 
 * @author            : Saurav Kashyap
 * @group             : SK Group
 * @last modified on  : 06-03-2023
 * @last modified by  : Saurav Kashyap 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-03-2023   Saurav Kashyap   Initial Version
**/

/**
 *@requestBody : {
					"mid": "320173",
					"product": "Payment Gateway",
					"title": "Subject title",
					"description": "Testing Through API .Test Description."
					}
 */
public class SubCaseCreationRequestWrapper {

	public String mid;
	public String product;
	public String title;
	// public String assignee;
	public String description;
	public Boolean subCaseCeation=false;

	
	public static SubCaseCreationRequestWrapper parse(String json) {
		return (SubCaseCreationRequestWrapper) System.JSON.deserialize(json, SubCaseCreationRequestWrapper.class);
	}
}