/**
 * @description       : 
 * @author            : Saurav Kashyap
 * @group             : Appstrail
 * @last modified on  : 27-01-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   25-01-2023   Saurav Kashyap   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import fetchTaskType from '@salesforce/apex/TaskListButtonController.fetchTaskType';
import fetchSubTypePicklist from '@salesforce/apex/TaskListButtonController.fetchSubTypePicklist';
import insertTaskRecord from '@salesforce/apex/TaskListButtonController.insertTaskRecord';
import bulkRemarkInsertion from '@salesforce/apex/TaskRemarksCustomController.bulkRemarkInsertion';
import bulkUploadAttachment from '@salesforce/apex/TaskListButtonController.bulkUploadAttachment';

import __contactName__ from '@salesforce/schema/Contact.Name';
import __acccountName__ from '@salesforce/schema/Contact.AccountId';
import __contactPhone__ from '@salesforce/schema/Contact.Phone';
import __contactDepartment__ from '@salesforce/schema/Contact.Department__c';
import __contactDesignation__ from '@salesforce/schema/Contact.Designation__c';
import __contactEmail__ from '@salesforce/schema/Contact.Email';
import __contactMailingAddress__ from '@salesforce/schema/Contact.MailingAddress';
import __contactMobile__ from '@salesforce/schema/Contact.MobilePhone';









export default class TaskListButtonComponent extends NavigationMixin(LightningElement) {



    TASK_CALL = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#call";
    TASK_MEET = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#user";
    TASK_EMAIL = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#email";
    TASK_INTERNAL = "/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#settings";
    TASK_NOTE = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#note";

    ACCOUNT_ICON = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#account";
    OPPORTUNITY_ICON = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#opportunity";
    LEAD_ICON = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#lead";




    @track newContactFields = { 'contactName': __contactName__, 
                                'accountName': __acccountName__, 
                                'contactPhone': __contactPhone__,
                                'contactMailingAddress':__contactMailingAddress__,
                                'contactEmail':__contactEmail__,
                                'contactDesignation':__contactDesignation__,
                                'contactDepartment':__contactDepartment__,
                                'contactMobile': __contactMobile__};




    @api recordId;
    @track isModalOpen = true;
    @track load = false;
    @track isMainPageVisible = false;
    @api flexipageRegionWidth = 'slds-col ' + 'CLASSIC'; // default to classic. If its lightning, framework will set the value
    @api strOutput = false;
    fileSize = [];

    /*******************************************************************************/

    @track taskTypeList;


    @track relatedObjectList = [{ label: 'Lead', value: 'Lead', iconName: 'standard:lead' }, { label: 'Account', value: 'Account', iconName: 'standard:account' }, { label: 'Opportunity', value: 'Opportunity', iconName: 'standard:opportunity' }];


    contactId = null;

    relatedOjectName = 'Account';
    relatedObjectIconName = 'standard:account';
    defaultRelatedObjectRecordName = '';
    defaultContactObjectRecordName = '';

    showContactRecordForm = false;


    //show Fotter Button
    showFotterButton = true;

    dependentPicklist;
    deplendentPicklistValue = '';


    //priority list

    priorityList = [{ label: 'High', value: 'High' }, { label: 'Normal', value: 'Normal' }, { label: 'Low', value: 'Low' }];
    priorityPicklistValue = '';

    statusPicklist = [{ label: 'Open', value: 'Open' }, { label: 'Completed', value: 'Completed' }];
    statusPicklistValue = 'Open';

    formHeaderTile = 'New Task ';

    @track SALESFORCE_TASK_RECORD = {
        'taskType': null,
        'taskSubType': null,
        'taskSubject': null,
        'dueDate': null,
        'priority': null,
        'status': 'Open',
        'startDate': null,
        'endDate': null,
        'relatedToId': null,
        'contactRecordId': null,
        'assigneeRecordId': null,
        'taskReminder': false,
        'eventCreation': false
    }


    defaultAssignRecord = '';

    showRemarks = false;
    remarksList = [];

    remarkObject = {
        'remarkIdWrap': null,
        'createdByName': null,
        'Comment': null
    }


    attachmentFileArray = [];

    attachmentFile = {
        'filename': null,
        'base64': null,
        'recordId': null
    }


    /****
     * @Date 06 Feb,2023
     * @functionality: Adding contact serach function according to related object
     *                 eg : if user select account as a related object then he/she will
     *                 get only that account's contact record, this same goes to Opportnity 
     *                 Object. 
     */
    contactPhoneSearchFilter = '';


    showAttachments = false;
    get reminderMessage() {
        return this.SALESFORCE_TASK_RECORD.dueDate != null ? "You will be reminded on " + `${this.SALESFORCE_TASK_RECORD.dueDate}` + " at 10:00 AM" : "No Reminder has been set yet";
    }
    //reminderMessage = "You will be reminded at "+ this.SALESFORCE_TASK_RECORD.dueDate + " at 10:00 AM";

    /*******************************************************************************/


    hasRendered = true;
    IsRemarksVisible = true;

    currentTaskIconName = '';


    /**
     * //disable Custom Lookup
     **/
    disablePhoneNumber = true;
    /*********************************************************************************/


    /**
     * @createdDate: 07 March, 2023
     * @author: Vishal Hembrom
     * @description: variables are used for store opportunityId and accountId
     *               opportunityId is used in contact search filter value to
     *                eg Account Id = '001C1000005caPNIAY'
     *                accountId is used to passed record value into contact's lightning 
     *                record form
     * **/

    opportunityId = '';
    opportunityAccountId = '';
    //contactAccountRecordId='';
    //contactCreationFields = [CONTACT_LASTNAME];
    /*********************************************************************************/
    @wire(getRecord, { recordId: '$opportunityId', fields: ['Opportunity.Id', 'Opportunity.Name', 'Opportunity.AccountId'] })
    wireOpportunityRecord({ error, data }) {
        if (data) {
            this.opportunityAccountId = data.fields.AccountId.value;
            console.log('Wire Record::::' + this.opportunityAccountId);
        } else {
            console.log('Error:::' + error);
        }
    }



    showContactFooter = false;
    connectedCallback() {
        const dateV = new Date();
        this.list(dateV);
    }


    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
    }

    handleUploadFinished(event) {
        this.showAttachments = false;
        console.log('File Date:::' + JSON.stringify(event.detail.files));
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files[0];
        this.attachmentFileArray.push(uploadedFiles);
        this.showAttachments = true;
        console.log('Array List:::' + JSON.stringify(this.attachmentFileArray));
        this.getFileSize();
    }


    @track newValue;
    @track belowTemplate = true;
    @track doComments = true;
    @track taskComments = [];
    @track taskCom = {
        "createdByName": "Ramesh",
        "createddate": null,
        "remarkIdWrap": "2364"
    };


    handleFieldPartChange(event) {
        if (!this.taskTypePopUpOpen) {
            this.template.querySelector(`[data-id="tasktype"]`).classList.remove('slds-is-open');
            this.taskTypePopUpOpen = true;
        }
        this.handleRemoveTaskTypeClick();
        console.log('Test::::');
        console.log('Value::::::' + event.currentTarget.dataset.value);
        let parentPicklistValue = event.currentTarget.dataset.value;
        this.currentTaskIconName = this.checkTaskType(parentPicklistValue);
        //this.template.querySelector(`[data-id="tasksubtypepicklist"]`).disabled = true;
        this.deplendentPicklistValue = '';
        this.SALESFORCE_TASK_RECORD.taskType = parentPicklistValue
        this.fetchSubTaskTypePicklistValues(parentPicklistValue);
        console.log('Picklsit Value::::' + typeof parentPicklistValue);

    }

    handleFieldSubParentChange(event) {
        this.SALESFORCE_TASK_RECORD.taskSubType = event.detail.value;
        this.deplendentPicklistValue = event.detail.value;
    }

    handleStatusChange(event) {
        this.statusPicklistValue = event.detail.value;
        this.SALESFORCE_TASK_RECORD.status = event.detail.value;
    }


    handlePriorityChange(event) {
        this.priorityPicklistValue = event.detail.value;
        this.SALESFORCE_TASK_RECORD.priority = event.detail.value;
        //message-when-value-missing={priorityErrorMessage}
    }



    handleTaskSubject(event) {
        this.SALESFORCE_TASK_RECORD.taskSubject = event.detail.value;
    }

    handleStartDate(event) {
        console.log('Time::::' + event.detail.value);
        this.SALESFORCE_TASK_RECORD.startDate = event.detail.value;
        console.log('Undefined:::::');
        if (this.SALESFORCE_TASK_RECORD.startDate == null && this.SALESFORCE_TASK_RECORD.eventCreation == true) {
            console.log('Condition Passed::::');
            this.template.querySelector(`[data-error="startdateerror"]`).setCustomValidity('Please Fill Strat Date');
            this.template.querySelector(`[data-error="startdateerror"]`).reportValidity();
            return;
        }

        this.template.querySelector(`[data-error="startdateerror"]`).setCustomValidity('');
        this.template.querySelector(`[data-error="startdateerror"]`).reportValidity();


    }


    handleEndDate(event) {
        this.SALESFORCE_TASK_RECORD.endDate = event.detail.value;
        this.template.querySelector(`[data-error="enddateerror"]`).setCustomValidity('');
        this.template.querySelector(`[data-error="enddateerror"]`).reportValidity();
        if (this.SALESFORCE_TASK_RECORD.endDate == null && this.SALESFORCE_TASK_RECORD.eventCreation == true) {
            this.template.querySelector(`[data-error="enddateerror"]`).setCustomValidity('Please Fill End Date');
            this.template.querySelector(`[data-error="enddateerror"]`).reportValidity();
            return;
        }
        if (this.SALESFORCE_TASK_RECORD.eventCreation == true && this.SALESFORCE_TASK_RECORD.startDate != null && this.SALESFORCE_TASK_RECORD.endDate != null) {
            let numericValue = new Date(this.SALESFORCE_TASK_RECORD.endDate).getDay() - new Date(this.SALESFORCE_TASK_RECORD.startDate).getDay();
            console.log('Numeric Number::::' + numericValue);
            if (numericValue < 0) {
                this.template.querySelector(`[data-error="enddateerror"]`).setCustomValidity('End date can not be less than Start Date');
                this.template.querySelector(`[data-error="enddateerror"]`).reportValidity();
            }
            return
        }
    }


    visibleAssignee;
    handleAssigneeLookup(event) {
        console.log('Look Up Selected:::');
        this.visibleAssignee = false;
        this.template.querySelector(`[data-id="taskowner"]`).classList.remove('slds-has-error');
        this.defaultAssignRecord = event.detail.Name;
        this.SALESFORCE_TASK_RECORD.assigneeRecordId = event.detail.Id;
    }

    handleNoAssigneeLookup(event) {
        this.visibleAssignee = true;
        console.log('handle No Asssignee Called:::');
        this.template.querySelector(`[data-id="taskowner"]`).classList.add('slds-has-error');
        this.defaultAssignRecord = '';
        this.SALESFORCE_TASK_RECORD.assigneeRecordId = null;
    }

    handleRemarksCommentChange(event) {
        this.remarkObject = {
            'remarkIdWrap': Math.random(),
            'createdByName': this.formatDate(new Date()),
            'Comment': event.detail.value
        }
    }

    formatDate(date) {
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
    }

    handleRemarksComment(event) {
        this.showRemarks = false;
        if (this.remarkObject.remarkIdWrap != null) {
            this.remarksList.push(this.remarkObject);
            this.remarkObject = {
                'remarkIdWrap': null,
                'createdByName': null,
                'Comment': null
            }
        }
        console.log('Remarks List::::', this.remarksList);
        this.showRemarks = true;

    }

    handleTaskReminder(event) {
        console.log('Detail Value:::' + JSON.stringify(event.detail));
        console.log('Event Task Reminder::::' + event.detail.value);
        this.SALESFORCE_TASK_RECORD.taskReminder = event.detail.checked;
    }

    showRelatedObjectButton = false;
    handleSelectRelatedObjectValue(event) {
        console.log('Function Called::::');
        //this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.add('slds-dropdown-trigger');
        //this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.add('slds-dropdown-trigger_click');
        if (!this.showRelatedObjectButton) {
            this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.add('slds-is-open');
            this.showRelatedObjectButton = true;
        } else {
            this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-is-open');
            this.showRelatedObjectButton = false;
        }
    }

    handleSelectRelatedObjectName(event) {
        let obejctName = event.currentTarget.dataset.id;


        //  console.log('Function Called::::'+ this.disablePhoneNumber);
        //  console.log('Function 56789876::::'+typeof obejctName +' '+ obejctName);
        //  if(obejctName.localeCompare('Lead')){
        //     console.log('Function Passed Value::::');
        //     this.disablePhoneNumber = false;
        //  }else{
        //     this.disablePhoneNumber = false;
        //  }
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-is-open');
        this.showRelatedObjectButton = false;
        console.log('Function Call Successfull');
        let objectEvent = new CustomEvent("", {
            detail: {
                value: event.currentTarget.dataset.id
            },
        });
        this.handleObjectSelect(objectEvent);
        if (obejctName.localeCompare('Lead')) {
            this.disablePhoneNumber = true;
        } else {
            this.disablePhoneNumber = false;
        }
        console.log('Disable Phone NUmber::::' + this.disablePhoneNumber);
    }

    handleRemoveRelatedObject() {
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-is-open');
        //this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-dropdown-trigger_click');
    }

    taskTypePopUpOpen = true;
    handleTaskTypeClick(event) {
        console.log('Clicked::::');
        if (this.taskTypePopUpOpen) {
            this.template.querySelector(`[data-id="tasktype"]`).classList.add('slds-is-open');
            this.taskTypePopUpOpen = false;
        }
        else if (!this.taskTypePopUpOpen) {
            this.template.querySelector(`[data-id="tasktype"]`).classList.remove('slds-is-open');
            this.taskTypePopUpOpen = true;
        }
        this.template.querySelector(`[data-id="tasktypebuttonfocus"]`).classList.add('slds-has-focus');
    }

    handleRemoveTaskTypeClick(event) {
        console.log('Function Called:::');
        this.template.querySelector(`[data-id="tasktype"]`).classList.remove('slds-is-open');
        this.template.querySelector(`[data-id="tasktypebuttonfocus"]`).classList.remove('slds-has-focus');
    }


    list(dateV) {
        this.taskCom.createddate = dateV;
        this.taskComments.push(this.taskCom);
        this.fetchTaskTypePickListValues();
    }

    fetchTaskTypePickListValues() {
        this.load = true;
        this.isMainPageVisible = false;
        fetchTaskType()
            .then(result => {
                this.taskTypeList = result;
                for (let i = 0; i < this.taskTypeList.length; i++) {
                    this.taskTypeList[i].icon_name = this.checkTaskType(this.taskTypeList[i].value);
                    console.log('Icon Name:::::' + this.taskTypeList[i].icon_name);
                }
                this.isMainPageVisible = true;
                this.load = false;
                //this.fetchSubTaskTypePicklistValues();
            })
            .catch(error => {
                this.load = false;
                this.isMainPageVisible = false;
                //this.isModalOpen = false;
                this.showToastMessage('Error...', error.body.message, 'error', 'pester');
                console.log('Error:::::', error);
            })
    }

    checkTaskType(taskType) {
        /*TASK_CALL = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#call";
        TASK_MEET = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#call";
        TASK_EMAIL = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#email";
        TASK_INTERNAL = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#call";
        TASK_NOTE = "/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#note";
        */
        switch (taskType) {
            case 'Call': return this.TASK_CALL;
            case 'Meet': return this.TASK_MEET;
            case 'Email': return this.TASK_EMAIL;
            case 'Internal': return this.TASK_INTERNAL;
            case 'Note': return this.TASK_NOTE;
        }

    }


    handleCreateEvent(event) {
        // const inputBox = event.currentTarget;
        // inputBox.setCustomvalidity('Test Message');
        // inputBox.reportValidity();
        console.log('Test::::');
        console.log('Boolean Value:::' + event.target.checked);
        console.log('Boolean Data::::' + this.SALESFORCE_TASK_RECORD.eventCreation);
        let eventUserInput = event.target.checked;
        if (eventUserInput) {
            this.SALESFORCE_TASK_RECORD.eventCreation = true;
            this.template.querySelector(`[data-error="startdateerror"]`).required = true;
            this.template.querySelector(`[data-error="enddateerror"]`).required = true;
            console.log('Condition Passed:::' + this.SALESFORCE_TASK_RECORD.eventCreation);
            //this.template.querySelector(`[data-error="startdateerror"]`).message-when-bad-input = 'Please Select Start Date Time';
            //this.template.querySelector(`[data-error="startdateerror"]`).focus();
            //this.template.querySelector(`[data-error="startdateerror"]`).showHelpMessageIfInvalid();
            if (this.SALESFORCE_TASK_RECORD.startDate == null) {
                this.template.querySelector(`[data-error="startdateerror"]`).setCustomValidity('Please Select Start Date');
                this.template.querySelector(`[data-error="startdateerror"]`).reportValidity();
            }

            if (this.SALESFORCE_TASK_RECORD.endDate == null) {
                this.template.querySelector(`[data-error="enddateerror"]`).setCustomValidity('Please Select End Date');
                this.template.querySelector(`[data-error="enddateerror"]`).reportValidity();
            }

        }
        if (!eventUserInput) {
            this.SALESFORCE_TASK_RECORD.eventCreation = false;
            this.template.querySelector(`[data-error="startdateerror"]`).required = false;
            this.template.querySelector(`[data-error="enddateerror"]`).required = false;
            this.template.querySelector(`[data-error="enddateerror"]`).setCustomValidity('');
            this.template.querySelector(`[data-error="enddateerror"]`).reportValidity();
            this.template.querySelector(`[data-error="startdateerror"]`).setCustomValidity('');
            this.template.querySelector(`[data-error="startdateerror"]`).reportValidity();
        }
    }

    fetchSubTaskTypePicklistValues(parentPicklistValue) {
        console.log('Function Callled:::');
        fetchSubTypePicklist({ parentPicklist: parentPicklistValue })
            .then(result => {
                if (result.length != 0) {
                    this.dependentPicklist = result;
                    this.template.querySelector(`[data-id="tasksubtypepicklist"]`).disabled = false;
                    console.log('Result::::Task Type::', result);
                } else {

                }
            })
            .catch(error => {
                this.load = false;
                this.isMainPageVisible = false;
                //this.isModalOpen = false;
                this.showToastMessage('Error...', error.body.message, 'error', 'pester');
                console.log('Error:::::', error);
            })


    }








    /*
    *@description:  Select Related Object Value from user 
    * @value: Lead, Account And Contact
    * */


    relatedIconButtonName = this.ACCOUNT_ICON;
    handleObjectSelect(event) {
        console.log('Event Detail::::' + JSON.stringify(event.detail));
        this.relatedObjectValue = event.detail.value;
        this.relatedOjectName = this.relatedObjectValue;
        console.log('Object Name:::' + this.relatedOjectName);


        if (this.relatedOjectName == 'Account') {
            this.relatedObjectIconName = 'standard:account';
            this.relatedIconButtonName = this.ACCOUNT_ICON;
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.remove('slds-icon-standard-opportunity');
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.remove('slds-icon-standard-lead');
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.add('slds-icon-standard-account');

        } else if (this.relatedOjectName == 'Opportunity') {
            this.relatedObjectIconName = 'standard:opportunity';
            this.relatedIconButtonName = this.OPPORTUNITY_ICON;
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.remove('slds-icon-standard-lead');
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.remove('slds-icon-standard-account');
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.add('slds-icon-standard-opportunity');

            console.log('Funnction Passed::::');


            //relativeiconcolor
            //slds-icon-standard-opportunity
        } else if (this.relatedOjectName == 'Lead') {
            this.relatedObjectIconName = 'standard:lead';
            this.relatedIconButtonName = this.LEAD_ICON;
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.remove('slds-icon-standard-opportunity');
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.remove('slds-icon-standard-account');
            this.template.querySelector(`[data-icon-color="relativeiconcolor"]`).classList.add('slds-icon-standard-lead');

            //slds-icon-standard-lead
        }
        this.template.querySelector(`[data-id="relatedCustomLookup"]`).handleRemovePill();

        console.log('Related Oject Function Called::::');

    }

    handleRelatedLookupSelected(event) {

        this.SALESFORCE_TASK_RECORD.relatedToId = event.detail.Id;
        this.defaultRelatedObjectRecordName = event.detail.Name;


        if (this.relatedOjectName == 'Account') {

            this.contactPhoneSearchFilter = 'AccountId = \'' + this.SALESFORCE_TASK_RECORD.relatedToId + '\'';
        }
        if (this.relatedOjectName == 'Opportunity') {
            this.opportunityId = event.detail.Id;
            if (this.opportunityAccountId != '') {

                this.contactPhoneSearchFilter = 'AccountId = \'' + this.opportunityAccountId + '\'';
            }
        }
        if (this.relatedOjectName == 'Lead') {
            this.contactPhoneSearchFilter = '';
        }
        this.disablePhoneNumber = false;
        //this.contactSearchFilter = 'Phone LIKE \'%'+ this.defaultRelatedObjectRecordName + '%\'';
        console.log('Lookup Selected:::' + JSON.stringify(event.detail));
    }

    handleRelatedNoLookupSelected(event) {
        console.log('Function Called:::');
        this.SALESFORCE_TASK_RECORD.relatedToId = null;
        this.contactPhoneSearchFilter = '';
        this.defaultRelatedObjectRecordName = '';
        this.disablePhoneNumber = true;

        this.template.querySelector(`[data-id="relatedobjectphonenumber"]`).handleRemovePill();
        // this.SALESFORCE_TASK_RECORD.contactRecordId = null;
        // this.defaultContactObjectRecordName = '';
        console.log('Phone Number Contact Disable::::' + this.disablePhoneNumber);
    }

    handleContactLookupSelected(event) {
        this.SALESFORCE_TASK_RECORD.contactRecordId = event.detail.Id;
        this.defaultContactObjectRecordName = event.detail.Name;
    }

    handleContactNoLookupSelected(event) {
        console.log('Function Calledd:::1234');
        this.SALESFORCE_TASK_RECORD.contactRecordId = null;
        this.defaultContactObjectRecordName = '';
    }

    handledDueDate(event) {
        this.SALESFORCE_TASK_RECORD.dueDate = event.detail.value;
    }




    closeModal() {
        this.isModalOpen = false;
        if (this.strOutput == false) {
            this.handleListViewNavigation();
        }
        if (this.strOutput == true) {
            console.log('strOutput::true')
            this.navigateToOnboardingDetail();
            const closeQA = new CustomEvent('save');
            this.dispatchEvent(closeQA);
        }

    }


    handleCreateNewContact() {
        this.template.querySelector(`[data-id="modalfotter"]`).classList.add('slds-p-around--large');
        this.showFotterButton = false;
        this.isMainPageVisible = false;
        this.showContactRecordForm = true;
        this.formHeaderTile = 'Create New Contact';
        this.showContactFooter = true;
    }


    handleCreateContactRecord(event) {
        console.log('Function Called:::');
        console.log('Contact Record::::::' + JSON.stringify(event.detail.fields));
        console.log('Contact Record::::::' + JSON.stringify(event.detail));
        this.formHeaderTile = ' New Task  ';

        if (event.detail.fields.Phone.value != null) {
            this.defaultContactObjectRecordName = event.detail.fields.Phone.value;
            this.SALESFORCE_TASK_RECORD.contactRecordId = event.detail.id;
        } else {
            this.defaultContactObjectRecordName = '';
            this.SALESFORCE_TASK_RECORD.contactRecordId = null;
        }

        this.template.querySelector(`[data-id="modalfotter"]`).classList.remove('slds-p-around--large');
        console.log('Event Data:::::', event);
        this.showFotterButton = true;
        this.showContactRecordForm = false;
        this.isMainPageVisible = true;

    }


    handleUploadFile(event) {
        console.log('Value::::');
        let cuurentFile = event.target.files[0];
        console.log('File Record:::' + JSON.stringify(event.target.files[0]));
        reader.onload = () => {
            let base64 = reader.result.split(',')[1];
            this.attachmentFile = {
                'filename': cuurentFile.name,
                'base64': base64,
                'recordId': Math.random()
            }
        }
        reader.readAsDataURL(cuurentFile);
        this.attachmentFileArray.push(this.attachmentFile);
        console.log('File Attachment::::', this.attachmentFileArray);

    }


    handleAddFile(event) {
        this.template.querySelector(`[data-id="uploadattachment"]`).click();
    }

    handleCancelContactRecord(event) {
        console.log('Function Called:::');
        this.formHeaderTile = ' New Task  ';
        this.template.querySelector(`[data-id="modalfotter"]`).classList.remove('slds-p-around--large');
        this.showFotterButton = true;
        this.showContactRecordForm = false;
        this.isMainPageVisible = true;

    }


    // closeQuickAction() {
    //   const closeQA = new CustomEvent('close');
    //   this.dispatchEvent(closeQA);
    // }

    handleSave() {
        this.load = true;

        /** 
         * @description: custom validation of Priority field
         */
        if (this.SALESFORCE_TASK_RECORD.priority == '' || this.SALESFORCE_TASK_RECORD.priority == undefined || this.SALESFORCE_TASK_RECORD.priority == null) {
            this.showEventMessage('Record Field', 'Please Select Priority', 'warning', 'pester');
            this.template.querySelector(`[data-id="priorityinput"]`).messageWhenValueMissing = "Please Select Priority";
            this.template.querySelector(`[data-id="priorityinput"]`).reportValidity();
            this.load = false;
            return;
        }

        /**
         * @description: custom validation of Owner Field
         */
        console.log('Value:::' + this.SALESFORCE_TASK_RECORD.assigneeRecordId);
        if (this.SALESFORCE_TASK_RECORD.assigneeRecordId == '' || this.SALESFORCE_TASK_RECORD.assigneeRecordId == undefined || this.SALESFORCE_TASK_RECORD.assigneeRecordId == null) {
            this.visibleAssignee = true;
            this.template.querySelector(`[data-id="taskowner"]`).classList.add('slds-has-error');


            console.log('Return::::' + this.load);
            this.showEventMessage('Record Field', 'Please Select Owner', 'warning', 'pester');
            this.load = false;
            return;
        }

        if (this.SALESFORCE_TASK_RECORD.startDate == null && this.SALESFORCE_TASK_RECORD.eventCreation == true) {
            this.template.querySelector(`[data-error="startdateerror"]`).setCustomValidity('Please Fill Start Date');
            this.template.querySelector(`[data-error="startdateerror"]`).reportValidity();
            this.showEventMessage('Record Field', 'Please Enter Start Date', 'warning', 'pester');
            this.load = false;
            return;
        }

        if (this.SALESFORCE_TASK_RECORD.endDate == null && this.SALESFORCE_TASK_RECORD.eventCreation == true) {
            this.template.querySelector(`[data-error="enddateerror"]`).setCustomValidity('Please Fill End Date');
            this.template.querySelector(`[data-error="enddateerror"]`).reportValidity();
            this.showEventMessage('Record Field', 'Please Enter End Date', 'warning', 'pester');
            this.load = false;
            return;
        }
        if (this.SALESFORCE_TASK_RECORD.eventCreation == true && this.SALESFORCE_TASK_RECORD.startDate != null && this.SALESFORCE_TASK_RECORD.endDate != null) {
            let numericValue = new Date(this.SALESFORCE_TASK_RECORD.endDate).getDay() - new Date(this.SALESFORCE_TASK_RECORD.startDate).getDay();
            console.log('Numeric Number::::' + numericValue);
            if (numericValue < 0) {
                this.template.querySelector(`[data-error="enddateerror"]`).setCustomValidity('End date can not be less than Start Date');
                this.template.querySelector(`[data-error="enddateerror"]`).reportValidity();
                this.showEventMessage('Record Field', 'End Date can not be less than Start Date', 'warning', 'pester');
                this.load = false;
                return
            }

        }
        console.log('Final List::::' + JSON.stringify(this.SALESFORCE_TASK_RECORD));
        insertTaskRecord({ jsonInput: JSON.stringify(this.SALESFORCE_TASK_RECORD) })
            .then(result => {
                this.handleNewRemarkCreation(result);
                //this.template.querySelector('c-task-lis-button-component').remove('c-task-lis-button-component');
                // this.closeQuickAction();
            })
            .catch(error => {
                console.log('Error::' + JSON.stringify(error));
                this.load = false;
                console.log('Error Message:::' + typeof error.body.message);
                this.showEventMessage('Error!!!!', error.body.message, 'error', 'pester');
            })

    }

    handleNewRemarkCreation(newTaskId) {
        if (this.remarksList.length == 0) {
            this.SALESFORCE_TASK_RECORD = {};
            this.load = false;
            if (this.strOutput == false) {
                this.navigateToTaskPage(newTaskId);
            }
            if (this.strOutput == true) {
                console.log('strOutput::true')
                this.navigateToOnboardingDetail();
                const closeQA = new CustomEvent('save');
                this.dispatchEvent(closeQA);
            }

            return;
        }

        bulkRemarkInsertion({ taskId: newTaskId, jsonRemarksList: JSON.stringify(this.remarksList) })
            .then(result => {
                this.handleSaveAllAttachment(newTaskId);
            })
            .catch(error => {
                console.log('Error::' + JSON.stringify(error));
                this.load = false;
                console.log('Error Message:::' + typeof error.body.message);
                this.showEventMessage('Error!!!!', error.message.body, 'warning', 'pester');
            })

    }
    getFileSize() {
        bulkUploadAttachment()
            .then(result => {
                console.log('Result::::' + JSON.stringify(result));
                // result.filter(el=>{
                //     this.fileSize= el.ContentDocument.ContentSize;
                // })
                // console.log('this.fileSize::'+this.fileSize);
            })
    }

    handleSaveAllAttachment(newTaskId) {
        console.log('taskId::', newTaskId);
        if (this.attachmentFileArray.length == 0) {
            this.SALESFORCE_TASK_RECORD = {};
            this.load = false;
            this.navigateToTaskPage(newTaskId);
            return;
        }
        let documentList = [];

        console.log('Final Function Call:::' + this.attachmentFileArray.length);
        for (let i = 0; i < this.attachmentFileArray.length; i++) {
            console.log('Number::::' + i);
            documentList.push(this.attachmentFileArray[i].documentId);
        }
        bulkUploadAttachment({ taskId: newTaskId, jsonAttachmentList: documentList })
            .then(result => {
                this.SALESFORCE_TASK_RECORD = {};
                this.load = false;
                this.navigateToTaskPage(newTaskId);
            })
            .catch(error => {
                console.log('Error::' + JSON.stringify(error));
                this.load = false;
                console.log('Error Message:::' + typeof error.body.message);
                this.showEventMessage('Error!!!!', error.message.body, 'warning', 'pester');
            })

    }

    // method to close the modal pop-up 
    handleCancel() {
        this.updateRecordView();
        console.log('strOutput::' + this.strOutput);
        if (this.strOutput == false) {
            this.handleListViewNavigation();
        }
        if (this.strOutput == true) {
            this.navigateToOnboardingDetail();
        }
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

    /*
        Function to show toast message 
    */


    showEventMessage(title, message, variant, mode) {
        console.log('Function Called::' + title);
        console.log('Function Called::' + message);
        console.log('Function Called::' + variant);
        console.log('Function Called::' + mode);

        let evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);

    }

    /*
        This function navigates to the Standard Record Page ... >>>
    */
    recordReference(event) {
        var index = event.currentTarget.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: index,
                actionName: 'view',
            },
        });
    }

    /*
        This function navigates to the list view Page ... >>>
    */
    handleListViewNavigation() {
        // Navigate to the Accounts object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                // or by 18 char '00BT0000002TONQMA4'
                filterName: 'Recent'
            }
        });
    }

    navigateToOnboardingDetail() {
        //event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //how to apply this id and navigate to tab that has LWC component?
                //recordId: event.target.dataset.id,
                apiName: 'My_Tasks'
            }
        });
    }

    navigateToTaskPage(taskId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: taskId,
                objectApiName: 'Task',
                actionName: 'view'
            },
        });
    }


    handleCancelOperation() {

        var url = window.location.href;
        console.log('Window Url COm:::::' + url);
        console.log('Url Substring::' + url.substring(0, url.lastIndexOf('/') + 1));
        var value = url.substring(0, url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }
}