import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { NavigationMixin } from 'lightning/navigation';
import getDiscrepancy from '@salesforce/apex/RaiseCaseController.getDiscrepancy';
import insertCases from '@salesforce/apex/RaiseCaseController.insertCases';
import getFieldPicklistValue from '@salesforce/apex/RaiseCaseController.getFieldPicklistValue';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import WORK_ORDER_NUMBER from '@salesforce/schema/WorkOrder.WorkOrderNumber';

const fields = [WORK_ORDER_NUMBER];

export default class RaiseCaseCustomComponent extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    caseDetails;

    @track not_null_discrepancy = true;

    @track caseForOptions = [];
    @track caseDiscrepancyList = [];

    @track discrepancyList = [];

    // connected callback method loads on pageload...
    connectedCallback() {
        // querying the Discrepancy Records onPageLoad..
        getDiscrepancy({})
            .then(result => {
                console.log('Length:::' + JSON.stringify(result));
                this.discrepancyList = result.filter(el => {
                    el.uniqueId = Math.random();
                    return el;
                });
                console.log("🚀 >>>> RaiseCaseCustomComponent >>>> this.discrepancyList", this.discrepancyList);
                // cloning the list of discrepancy value
                // this.discrepancyList = [...this.discrepancyList];
                this.error = undefined;
            })
            .catch(error => {
                console.log('Error::' + JSON.stringify(error));
                this.showToastMessage('Error', 'RaiseCaseCustomComponent Connected Callback Error', 'error');
            });

        // calling the method to get picklist value onload...
        this.getFieldPicklistValueFunction('Case', 'Case_For__c');
    }

    // handle method on click of picklist value in UI.
    @track caseForValue;
    handleCaseFor(event) {
        this.caseForValue = event.target.value;
        console.log("🚀 >>>> RaiseCaseCustomComponent >>>> caseForValue", this.caseForValue);
    }

    @track tickvalue;
    @track datasetId;
    @track discrepancyObject ={
        caseDescripancyValue : null,
        uniqueId : null,
        checkedValue : null,
    };
    
    handleTickButton(event) {
        this.tickvalue = event.target.checked;
        console.log("🚀 >>>> RaiseCaseCustomComponent >>>> this.tickvalue", this.tickvalue);
        this.datasetId = event.target.name;
        console.log("🚀 >>>> RaiseCaseCustomComponent >>>> this.datasetId", this.datasetId);

        if(this.tickvalue == true) {
            this.discrepancyList = this.discrepancyList.filter(el => {
                if(el.uniqueId == this.datasetId){
                    el.checkedValue = this.tickvalue;
                }
                return el;
            });
            console.log("🚀 >>>>  >>>> this.discrepancyList", this.discrepancyList);
        }else{
            this.discrepancyList = this.discrepancyList.filter(el => {
                if(el.uniqueId == this.datasetId){
                    el.checkedValue = this.tickvalue;
                }
                return el;
            });
            console.log("🚀 >>>>  >>>> this.discrepancyList", this.discrepancyList);
        }
    }

    get workOrderNumber() {
        return getFieldValue(this.caseDetails.data, WORK_ORDER_NUMBER);
    }

    // method to get Picklistvalues by providing object Name and the picklist field Name .
    getFieldPicklistValueFunction(objectNameVar, fieldNameVar) {
        getFieldPicklistValue({ objectName: objectNameVar, fieldName: fieldNameVar })
            .then(result => {
                console.log('Result (getFieldPicklistValue) ::: ' + JSON.stringify(result));
                if (fieldNameVar == 'Case_For__c') {
                    this.caseForOptions = result;
                    console.log("🚀 >>>> RaiseCaseCustomComponent >>>> this.caseForOptions", this.caseForOptions);
                }
            })
            .catch(error => {
                console.log('Error (getFieldPicklistValue) ::: ' + JSON.stringify(error));
                this.spinnerOn = false;
                this.toast('Error', 'Something is wrong, please contact your system administrator', 'error', 'pester');
            });
    }

    // method where cases gets inserted to the DB
    @track insertionOutput = false;
    insertCasesOnSave() {
        // validating list(before sending to apex) here
        this.validation(this.discrepancyList);
        // assigning choosen case for value to list
        this.discrepancyList = this.discrepancyList.filter(el => {
            if(el.checkedValue){
                el.caseForValue = this.caseForValue;
                return el;
            }
        });
        console.log(">> this.discrepancyList   ", this.discrepancyList);

        console.log(" >>>> >>>>this.recordId  ",this.recordId  );
        // method call ...
        insertCases({ recordId: this.recordId, casevalueList: this.discrepancyList })
            .then(result => {
                this.insertionOutput = result;
                this.showMessageOnInsertionOfCases();
                console.log("🚀 >>>> RaiseCaseCustomComponent >>>> this.insertionOutput", this.insertionOutput);
                this.error = undefined;
            })
            .catch(error => {
                console.log('Error::' + JSON.stringify(error));
                this.showToastMessage('Error', 'RaiseCaseCustomComponent Connected Callback Error', 'error');
            });
    }

    // Toast Message for the successful Events
    showMessageOnInsertionOfCases() {
        if (this.insertionOutput == true) {
            this.showToastMessage('Toast Success', 'Cases Successfully Saved', 'success');
        }
    }

    // method to call insertCasesOnSave() method on Click of Save Button on UI
    handleSave() {
        this.insertCasesOnSave();
        this.handleClose();
    }

    // method to close the modal pop-up 
    handleClose() {
        this.updateRecordView();
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    /**
    * The function is called from the component's controller, and it waits for one second before
    * refreshing the page
    */
    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

    // method to validate size of lists available in the JS. If length is 0 return a ToastMessage
    validation(discrepancyList) {
        if (discrepancyList.length == 0) {
            this.showToastMessage('Error', 'Please Select a Discrepancy.', 'error');
            return true;
        }
        return false;
    }

    //TOAST-MESSAGE TO POPUP
    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}