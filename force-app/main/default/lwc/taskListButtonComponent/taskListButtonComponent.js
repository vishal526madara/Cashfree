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
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import fetchTaskType from '@salesforce/apex/TaskListButtonController.fetchTaskType';
import fetchSubTypePicklist from '@salesforce/apex/TaskListButtonController.fetchSubTypePicklist';
import insertTaskRecord from '@salesforce/apex/TaskListButtonController.insertTaskRecord';
import bulkRemarkInsertion from '@salesforce/apex/TaskRemarksCustomController.bulkRemarkInsertion';
import bulkUploadAttachment from '@salesforce/apex/TaskListButtonController.bulkUploadAttachment';

export default class TaskListButtonComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isModalOpen = true;
    @track load = false;
    @track isMainPageVisible = false;
    @api flexipageRegionWidth = 'slds-col ' + 'CLASSIC'; // default to classic. If its lightning, framework will set the value
    @api strOutput=false;
    fileSize =[];

    /*******************************************************************************/
   
    @track taskTypeList;


    @track relatedObjectList = [{ label: 'Lead', value: 'Lead', iconName:'standard:lead' }, { label: 'Account', value: 'Account', iconName:'standard:account' }, { label: 'Opportunity', value: 'Opportunity', iconName:'standard:opportunity'}];


    contactId = null;

    relatedOjectName='Account';
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
        'taskReminder': false
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

    attachmentFile={
        'filename':null,
        'base64': null,
        'recordId':null
    }


    showAttachments = false;
    get reminderMessage(){
        return this.SALESFORCE_TASK_RECORD.dueDate != null ? "You will be reminded on "+ `${this.SALESFORCE_TASK_RECORD.dueDate}` + " at 10:00 AM" : "No Reminder has been set yet";
    }
    //reminderMessage = "You will be reminded at "+ this.SALESFORCE_TASK_RECORD.dueDate + " at 10:00 AM";

    /*******************************************************************************/


    hasRendered = true;
    IsRemarksVisible = true;
    
    connectedCallback() {
        const dateV = new Date();
        this.list(dateV);
    }


    get acceptedFormats() {
        return ['.pdf', '.png','.jpg'];
    }

    handleUploadFinished(event) {
        this.showAttachments = false;
        console.log('File Date:::'+ JSON.stringify(event.detail.files));
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files[0];
        this.attachmentFileArray.push(uploadedFiles);
        this.showAttachments = true;
        console.log('Array List:::'+ JSON.stringify(this.attachmentFileArray));
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
    handlefieldchange() {

    }

    handleFieldPartChange(event) {
        //this.template.querySelector(`[data-id="tasksubtypepicklist"]`).disabled = true;
        this.deplendentPicklistValue = '';
        this.SALESFORCE_TASK_RECORD.taskType = event.detail.value;
        this.fetchSubTaskTypePicklistValues(event.detail.value);
        console.log('Picklsit Value::::' + typeof event.detail.value);

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
        this.SALESFORCE_TASK_RECORD.startDate = event.detail.value
    }


    handleEndDate(event) {
        this.SALESFORCE_TASK_RECORD.endDate = event.detail.value;
    }


    handleAssigneeLookup(event) {
        console.log('Look Up Selected:::');
        this.template.querySelector(`[data-id="taskowner"]`).classList.remove('slds-has-error');
        this.defaultAssignRecord = event.detail.Name;
        this.SALESFORCE_TASK_RECORD.assigneeRecordId = event.detail.Id;
    }

    handleNoAssigneeLookup(event) {
        console.log('handle No Asssignee Called:::');
        this.template.querySelector(`[data-id="taskowner"]`).classList.add('slds-has-error');
        this.defaultAssignRecord = '';
        this.SALESFORCE_TASK_RECORD.assigneeRecordId = null;
    }

    handleRemarksCommentChange(event) {
        this.remarkObject = {
            'remarkIdWrap': Math.random(),
            'createdByName':  this.formatDate(new Date()),
            'Comment': event.detail.value
        }
    }

    formatDate(date) {
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0'+minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return (date.getMonth()+1) + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
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


    handleSelectRelatedObjectValue(event){
       // this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.add('slds-dropdown-trigger');
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.add('slds-dropdown-trigger_click');
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.add('slds-is-open');
    }

    handleSelectRelatedObjectName(event){
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-is-open');
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-dropdown-trigger_click');
        let objectEvent = new CustomEvent ("",{
            detail:{
                value: event.currentTarget.dataset.id
            },
        });
        this.handleObjectSelect(objectEvent);
        console.log('Value::::',event.currentTarget.dataset.id);
    }

    handleRemoveRelatedObject(){
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-is-open');
        this.template.querySelector(`[data-id="iconrelatedobject"]`).classList.remove('slds-dropdown-trigger_click');
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
    handleObjectSelect(event) {
        console.log('Event Detail::::' + JSON.stringify(event.detail));
        this.relatedObjectValue = event.detail.value;
        this.relatedOjectName = this.relatedObjectValue;

        console.log('Object Name:::' + this.relatedOjectName);


        if (this.relatedOjectName == 'Account') {
            this.relatedObjectIconName = 'standard:account';
        } else if (this.relatedOjectName == 'Opportunity') {
            this.relatedObjectIconName = 'standard:opportunity';
        } else if (this.relatedOjectName == 'Lead') {
            this.relatedObjectIconName = 'standard:lead';
        }
        this.template.querySelector(`[data-id="relatedCustomLookup"]`).handleRemovePill();


    }

    handleRelatedLookupSelected(event) {
        console.log('Event Phone Number::::', event.detail.Name);
        this.SALESFORCE_TASK_RECORD.relatedToId = event.detail.Id;
        this.defaultRelatedObjectRecordName = event.detail.Name;
        //this.contactSearchFilter = 'Phone LIKE \'%'+ this.defaultRelatedObjectRecordName + '%\'';
        console.log('Lookup Selected:::' + JSON.stringify(event.detail));
    }

    handleRelatedNoLookupSelected(event) {
        this.SALESFORCE_TASK_RECORD.relatedToId = null;
        this.defaultRelatedObjectRecordName = '';
    }

    handleContactLookupSelected(event) {
        this.SALESFORCE_TASK_RECORD.contactRecordId = event.detail.Id;
        this.defaultContactObjectRecordName = event.detail.Name;
    }

    handleContactNoLookupSelected(event) {
        this.SALESFORCE_TASK_RECORD.contactRecordId = null;
        this.defaultContactObjectRecordName = '';
    }

    handledDueDate(event) {
        this.SALESFORCE_TASK_RECORD.dueDate = event.detail.value;
    }




    closeModal() {
        this.isModalOpen = false;              
        if(this.strOutput == false){
            this.handleListViewNavigation();
            }
            if(this.strOutput == true){
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
        console.log('File Record:::'+ JSON.stringify(event.target.files[0]));
        reader.onload = () => {
        let  base64 = reader.result.split(',')[1];
        this.attachmentFile = {
            'filename': cuurentFile.name,
            'base64': base64,
            'recordId': Math.random()
        }
    }
    reader.readAsDataURL(cuurentFile);
        this.attachmentFileArray.push(this.attachmentFile);
        console.log('File Attachment::::',this.attachmentFileArray);

    }


    handleAddFile(event){
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
         if(this.SALESFORCE_TASK_RECORD.priority == '' || this.SALESFORCE_TASK_RECORD.priority == undefined || this.SALESFORCE_TASK_RECORD.priority == null){
            this.showEventMessage('Record Field','Please Select Priority', 'warning', 'pester');
            this.template.querySelector(`[data-id="priorityinput"]`).messageWhenValueMissing = "Please Select Priority";
            this.template.querySelector(`[data-id="priorityinput"]`).reportValidity();
            this.load = false;
            return;
         }

         /**
          * @description: custom validation of Owner Field
          */
          console.log('Value:::'+ this.SALESFORCE_TASK_RECORD.assigneeRecordId);
         if(this.SALESFORCE_TASK_RECORD.assigneeRecordId == '' || this.SALESFORCE_TASK_RECORD.assigneeRecordId == undefined ||this.SALESFORCE_TASK_RECORD.assigneeRecordId == null){
           
            this.template.querySelector(`[data-id="taskowner"]`).classList.add('slds-has-error');
            
            
            console.log('Return::::'+ this.load);
            this.showEventMessage('Record Field','Please Select Owner', 'warning', 'pester');
            this.load = false;
            return;
         }
        console.log('Final List::::'+ JSON.stringify(this.SALESFORCE_TASK_RECORD));
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
        if(this.remarksList.length == 0){
            this.SALESFORCE_TASK_RECORD = {};
            this.load = false;
            if(this.strOutput == false){
            this.navigateToTaskPage(newTaskId);
            }
            if(this.strOutput == true){
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
    getFileSize(){
        bulkUploadAttachment()
        .then(result=>{
            console.log('Result::::'+ JSON.stringify(result));
            // result.filter(el=>{
            //     this.fileSize= el.ContentDocument.ContentSize;
            // })
            // console.log('this.fileSize::'+this.fileSize);
        })
    }

    handleSaveAllAttachment(newTaskId){
        console.log('taskId::',newTaskId);
        if(this.attachmentFileArray.length == 0){
            this.SALESFORCE_TASK_RECORD = {};
            this.load = false;
            this.navigateToTaskPage(newTaskId);
            return;
        }
        let documentList=[];

        console.log('Final Function Call:::'+ this.attachmentFileArray.length);
        for(let i=0; i<this.attachmentFileArray.length; i++){
            console.log('Number::::'+ i);
           documentList.push(this.attachmentFileArray[i].documentId);
        }
        bulkUploadAttachment({taskId:newTaskId, jsonAttachmentList:documentList})
        .then(result =>{
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
        console.log('strOutput::'+this.strOutput);
       if(this.strOutput == false){
        this.handleListViewNavigation();
       }
       if(this.strOutput == true){
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
        console.log('Function Called::'+title);
        console.log('Function Called::'+message);
        console.log('Function Called::'+variant);
        console.log('Function Called::'+mode);

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
}