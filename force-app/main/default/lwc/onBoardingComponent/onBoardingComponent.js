import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import caseChecklist from '@salesforce/apex/OnBoardingController.caseChecklist';
import updateTask from '@salesforce/apex/OnBoardingController.updateTask';
import deleteTask from '@salesforce/apex/OnBoardingController.deleteTask';
import createTask from '@salesforce/apex/OnBoardingController.createTask';
import updateTaskSubject from '@salesforce/apex/OnBoardingController.updateTaskSubject';
import updateCase from '@salesforce/apex/OnBoardingController.updateCase';
import createNewCaseChecklist from '@salesforce/apex/OnBoardingController.createNewCaseChecklist';
import getOptionsForApprovalType from '@salesforce/apex/OnBoardingController.getOptionsForApprovalType';
import updateSingleTaskRecord from '@salesforce/apex/OnBoardingController.updateSingleTaskRecord';
import getingCaseId from '@salesforce/apex/OnBoardingController.getingCaseId';
import getAllAttachmenterlatedtoTask from '@salesforce/apex/OnBoardingController.getAllAttachmenterlatedtoTask';
import { publish, MessageContext } from 'lightning/messageService';
import INITIATEREFRESHBUTTON from '@salesforce/messageChannel/initiateRefresh__c';
export default class OnBoardingComponent extends NavigationMixin(LightningElement) {

    @api recordId;
    @track checklistList = [];
    load = false;
    showPopover = false;
    showNewChecklist = false;
    showApprovalPopover = false;
    approvalPicklist = [];

    // task picklist option
    @track
    taskPickList = [{ label: 'Open', value: 'Open' },
    { label: 'WIP', value: 'In Progress' },
    { label: 'Completed', value: 'Completed' }]
    // ownerIcon=ownerIcon;

    @track caseParentId;

    @wire(MessageContext)
    messageContext;


    connectedCallback() {
        this.convertCaseId();
        this.getallatachment();
    }

    async convertCaseId() {
        await getingCaseId({ recordId: this.recordId })
            .then(result => {
                console.log('Case Id::::' + result);
                this.caseParentId = result;
                this.getCaseChecklist(this.caseParentId);
            })
            .catch(error => {

            })
    }
    @track attachmentList = [];
    getallatachment() {
        getAllAttachmenterlatedtoTask({ recordId: this.recordId })
            .then(result => {
                console.log('taskid and attachment exist::1::' + JSON.stringify(result));
                if (result != '') {
                    console.log('taskid and attachment exist::2::' + JSON.stringify(result));
                    this.attachmentList = result;
                    // this.caseParentId = result;
                    // this.getCaseChecklist(this.caseParentId);
                }
                else {
                    console.log('taskid and attachment not exist::::' + result);
                }
            })
            .catch(error => {
                console.log('taskid error attachment::::' + error);
            })
    }
    showuploadModel = false;
    @track taskid;
    deletedocverid;

    handleuploaddoc(event) {

        this.taskid = event.currentTarget.dataset.id;
        this.deletedocverid = event.currentTarget.dataset.contentdocid;
        this.showuploadModel = true;
    }

    handlepreviewdoc(event) {

        console.log('event.currentTarget.taskid:::::' + event.currentTarget.contentdocid);
        console.log('event.currentTarget.taskid:::::' + event.currentTarget.dataset.contentdocid);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: event.currentTarget.dataset.contentdocid
            }
        })
    }
    spinner=false;
    cancelmodel(event) {
        this.showuploadModel = false;
       // this.updateRecordView();
       this.load=false;
       console.log('event.detail.showpreview;'+event.detail.showpreview);
       if(event.detail.showpreview){
        
           this.attachmentList=[];
        this.refreshComponent();
            console.log('event.detail.showpreview;2'+event.detail.showpreview);
       }

    //    this.currentChecklist.Tasks.filter(item => {
    //     if (item.Id == this.taskid) {
    //         console.log('event.detail.showpreview;'+event.detail.showpreview);
    //         console.log('event.detail.showpreview;2'+event.detail.showupload);

    //         item.showupload = event.detail.showupload;
    //         item.showpreview = event.detail.showpreview;
    //     }
    //     })
    }

    completeCount = 0;
    totalCount = 0;
    @track
    currentChecklist;
    nextChecklist;

    /*
     *@description: variable used to hold approval comments
     */
    caseApprovalComment;
    //showupload=true;

    getCaseChecklist(caseId) {
        this.load = true;
        this.completeCount = 0;
        caseChecklist({ recordId: caseId })
            .then(result => {
                var first = true;
                var index = 1;
                this.checklistList = result.filter(item => {
                    // if(item.Completed__c==true){
                    //     this.completeCount++;
                    // }

                    item.openTask = 0;
                    item.inProgress = 0;
                    item.completeTask = 0;
                    if (item.Tasks) {
                        var completeTask = 0;
                        var allTask = item.Tasks.length;
                        item.Tasks.filter(el => {
                            el.taskEdit = false;
                            if (el.OwnerId) {
                                el.ownerName = el.Owner.Name;
                            }
                            if (el.Status == 'Open') {
                                item.openTask++;
                            }
                            if (el.Status == 'In Progress') {
                                item.inProgress++;
                            }
                            if (el.Status == 'Completed') {
                                item.completeTask++;
                                completeTask++;
                                el.select = true;
                                el.taskClass = 'task-name task-line-through';
                            }
                            else {
                                el.taskClass = 'task-name';
                                el.select = false;
                            }

                            el.showupload = true;
                            el.showpreview = false;
                            console.log('taskid:LinkedEntityId:otuside::' + el.Id);
                            this.attachmentList.filter(attchitem => {
                                console.log('taskid:LinkedEntityId:otuside::' + el.Id + ': taskid::' + attchitem.LinkedEntityId);
                                // console.log('taskid::otuside::'+el.id+':::'+el.id);
                                if (el.Id == attchitem.LinkedEntityId) {
                                    console.log('taskid:LinkedEntityId:>>>>>>>>>>:' + attchitem.LinkedEntityId);
                                    el.showupload = false;
                                    el.showpreview = true;
                                    el.ContentDocumentId = attchitem.ContentDocumentId;
                                }
                            });

                            return el;
                        });
                        if (completeTask == allTask) {
                            item.Completed__c = true;
                        } else {
                            item.Completed__c = false;
                        }
                    }
                    item.index = index;
                    index++;
                    item.active = false;
                    item.firstPage = false;
                    if (first) {
                        item.active = true;
                        item.firstPage = true;
                        first = false;
                        this.currentChecklist = item;
                        this.selectedchecklistname= item.Name;
                        this.selectedChecklistId = item;
                        console.log('if checklistList::', this.currentChecklist);
                        this.nextChecklist = result[1];
                    }
                    return item;
                });

                this.totalCount = this.checklistList.length;
                console.log('checklistList::', this.checklistList);
                console.log('List Data:::' + JSON.stringify(this.checklistList));
                this.load = false;
            })
            .catch(error => {
                this.load = false;
                console.log('error::', error);
                this.showToastMessage('Error', error.body.message, 'error');
            })
    }
    handleGetUpdatedChecklist() {
        this.load = true;
        this.completeCount = 0;
        caseChecklist({ recordId: this.caseParentId })
            .then(result => {
                var first = true;
                var index = 1;
                console.log('result#::', result);
                this.checklistList = result.filter(item => {
                    // if(item.Completed__c==true){
                    //     this.completeCount++;
                    // }
                    console.log('item::', item);

                    item.openTask = 0;
                    item.inProgress = 0;
                    item.completeTask = 0;
                    if (item.Tasks) {
                        var completeTask = 0;
                        var allTask = item.Tasks.length;
                        item.Tasks.filter(el => {
                            el.taskEdit = false;
                            if (el.OwnerId) {
                                el.ownerName = el.Owner.Name;
                            }
                            if (el.Status == 'Open') {
                                item.openTask++;
                            }
                            if (el.Status == 'In Progress') {
                                item.inProgress++;
                            }
                            if (el.Status == 'Completed') {
                                item.completeTask++;
                                completeTask++;
                                el.select = true;
                                el.taskClass = 'task-name task-line-through';
                            }
                            else {
                                el.taskClass = 'task-name';
                                el.select = false;
                            }
                            return el;
                        });
                        if (completeTask == allTask) {
                            item.Completed__c = true;
                        } else {
                            item.Completed__c = false;
                        }
                    }
                    item.index = index;
                    index++;
                    item.active = false;
                    console.log('item.id::', item.Id);
                    console.log('this.selectedChecklistId::', this.selectedChecklistId);

                    if (item.Id == this.selectedChecklistId) {
                        item.active = true;
                        this.currentChecklist = item;
                        //this.selectedChecklistId=item;
                        console.log('if checklistList::', this.currentChecklist);
                        this.nextChecklist = result[1];
                    }
                    return item;
                });
                this.totalCount = this.checklistList.length;
                console.log('checklistList::', this.checklistList);
                this.load = false;
            })
            .catch(error => {
                this.load = false;
                console.log('error::', error);
                this.showToastMessage('Error', error.body.message, 'error');
            })

    }

    newChecklist = { Name: '' };
    handleNewChecklist() {
        this.showNewChecklist = true;
        this.showPopover = true;
        this.showApprovalPopover = false;
        console.log('this.newChecklist:::', this.newChecklist.Name);
    }

    handleChecklistName(event) {
        var value = event.target.value;
        this.newChecklist.Name = value;
        console.log('after entering newChecklist Name:::', this.newChecklist.Name);

    }

    handleNewChecklistSave() {
        this.load = true;
        createNewCaseChecklist({ caseRecId: this.recordId, checkList: this.newChecklist.Name })
            .then(result => {
                console.log('ChecklistTaskData:::', result);
                if (result == 'error') {
                    this.showToastMessage('Error', 'Something went wrong.', 'error');
                } else {
                    this.showToastMessage('Success', 'Records created successfully.', 'success');
                    this.handleCancelPopover();
                }
                this.load = false;
            })
            .catch(error => {
                this.load = false;
                console.log('error::', error);
                this.showToastMessage('Error', error.body.message, 'error');
            });
    }

    handleCancelPopover() {
        this.load = true;
        this.showNewChecklist = false;
        this.showPopover = false;
        this.showApprovalPopover = false;
        this.showAddTask = false;
        this.newChecklist = { Name: '' };
        this.newTaskSubject = '';
        this.newTaskDuedate = '';
        this.load = false
    }

    selectedChecklistId;
    selectedchecklistname='Website Check';

    handleChecklistTab(event) {
        this.selectedChecklistId = event.currentTarget.dataset.id;
        this.selectedchecklistname = event.currentTarget.dataset.taskname;
        console.log('selectedchecklistname::'+this.selectedchecklistname);
        this.checklistList.forEach(item => {
            if (item.Id == this.selectedChecklistId) {
                item.active = true;
                this.currentChecklist = item;
            } else {
                item.active = false;
            }
        })
    }

    get showiploadandprev(){
        return  (this.selectedchecklistname=='Website Check');
    }

    handleApproval() {
        this.approvalTypePicklist();
        this.showNewChecklist = false;
        this.showApprovalPopover = true;
        this.showPopover = true;
        console.log('this.newChecklist:::', this.newChecklist.Name);

    }
    //APPROVAL PICKLIST VALUES
    approvalTypePicklist() {
        this.load = true;
        getOptionsForApprovalType({ recordId: this.recordId })
            .then(result => {
                this.approvalPicklist = result;
                this.load = false;
            })
            .catch(error => {
                console.log('error::' + JSON.stringify(error));
                this.showToastMessage('Error', error.body.message, 'error');
                this.load = false;
            });
    }
    selectedApproval = '';
    handleApprovalChange(event) {
        this.selectedApproval = event.target.value;
        console.log('selectedApproval::', this.selectedApproval);
    }
    handleSendApproval() {
        this.load = true;
        console.log('selectedApproval::', this.selectedApproval);
        updateCase({ recordId: this.recordId, selectedApproval: this.selectedApproval, submitterComment: this.caseApprovalComment })
            .then(result => {
                if (result == 'error') {
                    this.showToastMessage('Error', 'Something went wrong.', 'error');
                } else {
                    this.showToastMessage('Success', 'Approval Send Successfully', 'success');
                    this.handleCancelPopover();
                    this.updateRecordView();
                }
                this.load = false;
            })
            .catch(error => {
                this.load = false;
                console.log('error::', error);
                this.showToastMessage('Error', error.body.message, 'error');
            })
    }

    handleTaskSelect(event) {
        var taskId = event.target.name;
        var checked = event.target.checked;
        this.currentChecklist.Tasks.filter(item => {
            if (item.Id == taskId) {
                item.select = checked;
                if (checked) {
                    item.taskClass = 'task-name task-line-through';
                    this.updateTask(taskId, 'Completed');

                } else {
                    item.taskClass = 'task-name';
                    this.updateTask(taskId, 'Open');
                }
            }
        })
    }

    updateTask(taskId, statusValue) {
        updateTask({ taskId: taskId, statusValue: statusValue })
            .then(result => {
                if (result == 'success') {
                    this.showToastMessage('Success', 'Task Record Updated.', 'success');
                    this.handleGetUpdatedChecklist();
                }
            })
            .catch(error => {
                this.load = false;
                console.log('error::', error);
                this.showToastMessage('Error', error.body.message, 'error');
            })
    }



    handleNext() {
        this.load = true;
        var count = 0;
        var index = 0;
        this.checklistList.forEach(item => {
            item.active = false;
            if (item.Name == this.nextChecklist.Name) {
                this.currentChecklist = this.nextChecklist;
                item.active = true;
                index = count;
            }
            count++;
            return item;
        });
        if ((index + 1) < this.checklistList.length) {
            this.nextChecklist = this.checklistList[index + 1];
        }
        this.load = false;
    }

    handleBack() {
        this.load = true;
        var count = 0;
        var index = 0;
        this.checklistList.forEach(item => {
            item.active = false;
            if (item.Name == this.currentChecklist.Name) {
                this.nextChecklist = item;
                item.active = false;
                index = count;
            }
            count++;
            return item;
        });
        if ((index - 1) >= 0) {
            this.currentChecklist = this.checklistList[index - 1];
            this.currentChecklist.active = true;
        }
        this.load = false;
    }
    handleTaskEdit(event) {
        console.log('clicked edit:::::');
        var taskId = event.currentTarget.dataset.id;
        console.log('taskId:::::', taskId);
        console.log('this.currentChecklist:::::', this.currentChecklist);

        this.currentChecklist.Tasks.filter(item => {
            if (item.Id == taskId) {
                item.taskEdit = true;

                item.showupload = true;
                if(item.showpreview){
                item.showpreview = true;
                }
                // if(item.showpreview==true){
                //     item.showpreview = true;
                // }
                // if(item.showpreview==true){
                //     item.showpreview = true;
                // }
            }
        })

    }
    subjectValue;
    taskid;
    handleTaskFieldEdit(event) {
        console.log('handleTaskFieldEdit:::' + event.target.name);
        this.taskid = event.target.name;
        console.log('taskId:::', event.target.value);
        this.currentChecklist.Tasks.filter(item => {
            if (item.Id == this.taskid) {
                this.subjectValue = event.target.value;
            }
        })
    }


    handlePickListValue(event) {
        var ProductId = event.currentTarget.dataset.id;
        var value = event.target.value;
        var fieldName = event.target.name;
        console.log('Picklist Value::::' + event.target.value);
        console.log('Main List::::', this.currentChecklist);
        for (let i = 0; i < this.currentChecklist.Tasks.length; i++) {
            if (this.currentChecklist.Tasks[i].Id == event.currentTarget.dataset.id) {
                if (event.target.value == 'Open') {
                    this.currentChecklist.Tasks[i].Status = 'Open';
                }
                else if (event.target.value == 'In Progress') {
                    this.currentChecklist.Tasks[i].Status = 'In Progress';
                }
                else if (event.target.value == 'Completed') {
                    this.currentChecklist.Tasks[i].Status = 'Completed';
                }
            }
        }
        switch (fieldName) {
            case 'link':
                this.currentChecklist.Tasks = this.currentChecklist.Tasks.filter(el => {
                    if (el.Id == ProductId) {
                        el.Link__c = value;
                        console.log('value::', value);
                    }
                    return el;
                });
                break;

        }

    }

    handleSubjectValue(event) {
        for (let i = 0; i < this.currentChecklist.Tasks.length; i++) {
            if (event.target.name == this.currentChecklist.Tasks[i].Id) {
                if (event.target.fieldName == 'Subject') {
                    this.currentChecklist.Tasks[i].Subject = event.target.value;
                }
            }
        }
    }

    @track
    singleTaskRecord = {
        taskId: null,
        Subject: null,
        status: null,
        link: null
    }

    UpdateSingleTask(event) {
        
        console.log('Function Called::');
        for (let i = 0; i < this.currentChecklist.Tasks.length; i++) {
            if (event.target.name == this.currentChecklist.Tasks[i].Id) {
                this.singleTaskRecord.taskId = this.currentChecklist.Tasks[i].Id;
                this.singleTaskRecord.Subject = this.currentChecklist.Tasks[i].Subject;
                this.singleTaskRecord.status = this.currentChecklist.Tasks[i].Status;
                this.singleTaskRecord.link = this.currentChecklist.Tasks[i].Link__c;
                console.log('currentChecklist:', this.currentChecklist.Tasks[i].Id)
                break;
            }
        }
        console.log('Record Data::::' + JSON.stringify(this.singleTaskRecord));
        if (this.singleTaskRecord != null) {

            let jsonInput = JSON.stringify(this.singleTaskRecord);
            updateSingleTaskRecord({ JSONInput: jsonInput })
                .then(result => {
                    console.log('Expected Result:::::', result);
                    if (result == 'Pass') {
                        this.refreshComponent();
                        this.handleRefreshInitiateComponent('Visible');
                        this.showToastMessage('Success', 'Task Record Updated.', 'success');
                        this.handleGetUpdatedChecklist();
                        this.handleTaskEditCancel(this.taskid);
                        

                    } else if (result == 'Fail') {
                        this.refreshComponent();
                        this.handleRefreshInitiateComponent('Not_Visible');
                        this.showToastMessage('Success', 'Task Record Updated.', 'success');
                        this.handleGetUpdatedChecklist();
                        this.handleTaskEditCancel(this.taskid);
                    }
                    else if (result == '') {
                        this.showToastMessage('Failed', 'Failed to Updated.', 'warning');
                    }
                    this.singleTaskRecord.taskId = null;
                    this.singleTaskRecord.Subject = null;
                    this.singleTaskRecord.status = null;
                    this.singleTaskRecord.link = null;

                })
                .catch(error => {
                    this.load = false;
                    console.log('error::' + JSON.stringify(error));
                    this.showToastMessage('Error', error.body.message, 'error');
                })
        }

    }

    handleRefreshInitiateComponent(status) {
        const message = {
            showInitiateButton: status
        };
        publish(this.messageContext, INITIATEREFRESHBUTTON, message);
    }

    handleTaskUpdate() {
        console.log('subjectValue::', this.subjectValue);
        updateTaskSubject({ taskId: this.taskid, subject: this.subjectValue })
            .then(result => {
                if (result == 'success') {
                    this.showToastMessage('Success', 'Task Record Updated.', 'success');
                    this.handleGetUpdatedChecklist();
                    this.handleTaskEditCancel(this.taskid);
                }
            })
            .catch(error => {
                this.load = false;
                console.log('error::' + JSON.stringify(error));
                this.showToastMessage('Error', error.body.message, 'error');
            })
    }
    handleTaskEditCancel(taskId) {
        this.currentChecklist.Tasks.filter(item => {
            if (item.Id == taskId) {
                item.taskEdit = false;
            }
        })
    }
    handleTaskCancelEdit(event) {
        // this.taskEdit= false;
        var taskId = event.currentTarget.dataset.id;
        console.log('taskId:::::', taskId);
        this.currentChecklist.Tasks.filter(item => {
            if (item.Id == taskId) {
                item.taskEdit = false;
                this.refreshComponent();
                //  item.showupload = true;
                // if(item.showpreview==true){
                //     item.showpreview = true;
                // }
                // if(item.showpreview==true){
                //     item.showpreview = true;
                // }
            }
        })
    }
    handleTaskDelete(event) {
        console.log('handleTaskDelete:::');
        var taskid = event.target.name;
        console.log('taskId:::', taskid);
        this.deleteTask(taskid);

    }
    deleteTask(taskid) {
        this.load = true;
        console.log('taskId#:::', taskid);
        deleteTask({ taskId: taskid })
            .then(result => {
                if (result == 'success') {
                    this.showToastMessage('Success', 'Task Record Deleted.', 'success');
                    this.handleGetUpdatedChecklist();
                }
            })
            .catch(error => {
                this.load = false;
                console.log('error::', error);
                this.showToastMessage('Error', error.body.message, 'error');
            })
    }
    handleNewTask() {
        this.showNewChecklist = false;
        this.showPopover = true;
        this.showApprovalPopover = false;
        this.showAddTask = true;
    }

    newTaskSubject = '';
    newTaskDuedate = '';
    handleAddTaskFieldEdit(event) {
        console.log('event.target.name:::', event.target.name);
        console.log('event.target.value:::', event.target.value);
        if (event.target.name == 'subject') {
            this.newTaskSubject = event.target.value;
            console.log('taskSubject:::', this.newTaskSubject);
        }
        if (event.target.name == 'duedate') {
            this.newTaskDuedate = event.target.value;
            console.log('taskduedate:::', this.newTaskDuedate);

        }
    }
    handleSaveAddTask() {
        console.log('handleAddTask:::::');
        console.log('taskduedate:::', this.newTaskDuedate);
        console.log('taskSubject:::', this.newTaskSubject);
        console.log('currentChecklistName:::', this.currentChecklist.Id);
        this.load = true;
        createTask({ taskduedate: this.newTaskDuedate, taskSubject: this.newTaskSubject, whatId: this.currentChecklist.Id })
            .then(result => {
                if (result == 'success') {
                    this.showToastMessage('Success', 'Task Record Created.', 'success');
                    this.handleCancelPopover();
                    this.handleGetUpdatedChecklist();
                }
            })
            .catch(error => {
                this.load = false;
                console.log('error::', error);
                this.showToastMessage('Error', error.body.message, 'error');
            })

    }

    //TOAST MESSAGE FUNCTION
    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    //HANDLER USED TO STORE USER'S COMMENT
    handleCaseApprovalComment(event) {
        this.caseApprovalComment = event.target.value;
        console.log('Value::::' + this.caseApprovalComment);
    }

    //REDIRECT TO RECORD FUNCTION
    handleRedirect(recId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                actionName: 'view'
            }
        });
    }

    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

    refreshComponent(event){
            this.recordId;
            this.checklistList = [];
            this.load = false;
            this.showPopover = false;
            this.showNewChecklist = false;
            this.showApprovalPopover = false;
            this.approvalPicklist = [];
            this.caseParentId;
            this.attachmentList = []; 
            this.showuploadModel = false;
            this.taskid;
            this.completeCount = 0;
            this.selectedchecklistname;
            this.totalCount = 0;
            this.currentChecklist;
            this.nextChecklist;
            this.caseApprovalComment;
            this.newChecklist = { Name: '' };
            this.selectedChecklistId;
            this.selectedApproval = '';
            this.subjectValue;
            this.taskid;
            this.singleTaskRecord = {
                    taskId: null,
                    Subject: null,
                    status: null,
                    link: null
                }

        this.newTaskSubject = '';
        this.newTaskDuedate = '';

        this.convertCaseId();
        this.getallatachment();
    }
}