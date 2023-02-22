/**
 * @description       : 
 * @author            : Saurav Kashyap
 * @group             : Appstrail
 * @last modified on  : 25-01-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   25-01-2023   Saurav Kashyap   Initial Version
**/
({
    myAction : function(component, event, helper) {

    },
    closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})