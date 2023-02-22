import { api, LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import FORM_FACTOR from "@salesforce/client/formFactor";
import DesktopView from "./initialOnBoardingComponent.html";
import MobileView from "./initialOnBoardingMobileView.html";
import currentOpportunityRec from "@salesforce/apex/OnBoardingController.currentOpportunityRec";
import ChecklistTaskData from "@salesforce/apex/OnBoardingController.ChecklistTaskData";
//import updateDocTask from '@salesforce/apex/OnBoardingController.updateDocTask';
import createCaseChecklist from "@salesforce/apex/OnBoardingController.createCaseChecklist";
import fetchContactRecord from "@salesforce/apex/OnBoardingController.fetchContactRecord";
import createCaseWrapperVariable from "@salesforce/apex/OnBoardingController.createCaseWrapperVariable";
import createOnBoardResponseRecord from "@salesforce/apex/OnBoardingController.createOnBoardResponseRecord";

//import createCaseSubjectName from '@salesforce/apex/OnBoardingController.createCaseSubjectName';
export default class InitialOnBoardingComponent extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api defaultSubjectName;
  @track onBoardingType;

  @track casecategory;

  //Default Project Name
  @track defaultProjectName = "";

  @track required = true;
  //stop recurssion onboarding component
  stopOnboardingComponent = false;

  disableNext = true;
  handlenextbutton;

  @track projectChange = "project";
  //
  oppRecord = null;

  //Use to Store Opportunity Product Id
  holdOpportunityProduct = "";
  relatedOpportunityProduct;

  objectApiName = "Opportunity";
  accountFieldApi = "AccountId";
  libraryName = "Account Documents";
  @track screen = {
    //templatePage:true,
    firstPage: true,
    secondPage: false,
    thirdPage: false,
    forthPage: false
  };
  load = false;

  accountRecordHolder = null;

  render() {
    return FORM_FACTOR === "Large" ? DesktopView : MobileView;
  }

  caseTypeList = [
    { label: "General Request", value: "General Request" },
    { label: "Special Request", value: "Special Request" }
  ];

  completeClass = "slds-progress__item slds-is-completed";
  notCoveredClass = "slds-progress__item";
  activeClass = "slds-progress__item slds-is-active";
  @track initialOnboardingSteps = [
    {
      name: "Kick Off Onboarding",
      index: 1,
      completed: false,
      progressClass: this.activeClass
    },
    {
      name: "Choose Template",
      index: 2,
      completed: false,
      progressClass: this.notCoveredClass
    },
    {
      name: "Project Creation",
      index: 3,
      completed: false,
      progressClass: this.notCoveredClass
    }
  ];

  opportunityData;
  entityType;
  @track caseRec = {
    ContactId: "",
    ContactName: "",
    Deal_Handoff_Notes__c: "",
    Desired_Outcomes__c: "",
    Subject: this.defaultProjectName,
    Onboarding_Template__c: "",
    OnboardingTemplateName: "",
    Start_Date__c: "",
    End_Date__c: "",
    Description: "",
    ContactEmail: "",
    ContactPhone: "",
    Type: "Onboarding",
    MID__c: "",
    Case_For__c: "Onboarding Team"
  };
  contactFilter = "";

  accountName = null;

  docChecklistList = [];

  /* to store questionaire Answer*/
  @api answerresult = [];

  templateList;
  ownerName;

  onHandleBack() {
    const event = CustomEvent("displayquestion");
    this.dispatchEvent(event);
  }

  onHandleBackSecondPage() {
    this.screen.secondPage = false;
    this.screen.firstPage = true;
  }


  @wire(getRecord, {
    recordId: "$recordId",
    fields: ["Id", "Opportunity.Name", "Opportunity.Account.Name"]
  })
  fetchOpportunityRecord({ data, error }) {
    if (data) {
      console.log("Opportunity Records:::" + JSON.stringify(data));
      this.oppRecord = data;
      this.accountName = this.oppRecord.fields.Account.value.fields.Name.value;
      this.defaultProjectName = data.fields.Name.value + " - " + "Onboarding";
      this.caseRec.Subject = this.defaultProjectName;
      //this.caseRec.AccountId=this.accountRecordHolder.Id;
      //this.getOpportunityData();
      console.log("Function Called::::" + JSON.stringify(this.caseRec));
    } else if (error) {
    }
  }

  @wire(getRelatedListRecords, {
    parentRecordId: "$recordId",
    relatedListId: "Opportunity_Product_s__r",
    fields: ["Opportunity_Product__c.Id"]
  })
  opportunityProductData(data, error) {
    if (data) {
      this.relatedOpportunityProduct = data;
    } else if (error) {
    }
  }



  connectedCallback() {
    this.createCaseAccountRecord();
  }



  createSubjectForCase() {
    console.log("funtion Called::" + this.stopOnboardingComponent);
    console.log("function Called:::" + this.defaultSubjectName);
    if (this.defaultSubjectName != "") {
      this.stopOnboardingComponent = true;
      this.defaultProjectName = this.defaultSubjectName;
      this.caseRec.Subject = this.defaultProjectName;
    }
    this.load = false;
  }



 
  async getOpportunityData() {
    console.log("this.recordId::", JSON.stringify(this.caseRec));
    this.load = true;
    await currentOpportunityRec({ recordId: this.recordId })
      .then((result) => {
        this.opportunityData = result;
        this.entityType = this.opportunityData.oppRec.Account.Ownership;
        this.caseRec.Deal_Handoff_Notes__c = result.DealsHandoffNotes;
        // this.caseRec.OwnerId = result.oppRec.OwnerId;
        this.caseRec.Desired_Outcomes__c = result.DesiredOutcomes;
        // if (this.opportunityData.oppPrimaryContact) {
        //   this.caseRec.ContactId =
        //     this.opportunityData.oppPrimaryContact.ContactId;
        //   this.caseRec.ContactName =
        //     this.opportunityData.oppPrimaryContact.Contact.Name;
        // }
        if (this.opportunityData.oppRec) {
          this.contactFilter =
            "AccountId='" + this.opportunityData.oppRec.AccountId + "'";
          this.caseRec.AccountId = this.opportunityData.oppRec.AccountId;
          this.ownerName = this.opportunityData.oppRec.Owner.Name;
        }
        /*this.templateList=this.opportunityData.onboardingTemplateList.filter(item=>{
                    item.select=false;
                    return item;
                });*/
        this.caseRec.Onboarding_Template__c =
          this.opportunityData.onboardingTemplateList[0].Id;
        this.caseRec.OnboardingTemplateName =
          this.opportunityData.onboardingTemplateList[0].Name;
        this.createSubjectForCase();

      })
      .catch((error) => {
        this.load = false;
        console.log("error::", error);
        this.showToastMessage("Error", error.body.message, "error");
      });
  }
  @track Questionaire = false;


  opportunityProductName() {
    getPaymentGatewayProduct({ recordId: this.recordId })
      .then((result) => {

      })
      .catch((error) => {
        this.load = false;
        console.log("error::", error);
        this.showToastMessage("Error", error.body.message, "error");
      });
  }

  async createCaseAccountRecord() {
    await createCaseWrapperVariable({ recordId: this.recordId })
      .then((result) => {
        this.accountRecordHolder = result;
        console.log(
          "Account Record:::" + JSON.stringify(this.accountRecordHolder)
        );
        //   if(this.accountRecordHolder.businessEmail == null){
        //     this.accountRecordHolder.businessEmail = '';
        //   }
        console.log("File Connect::::", this.accountRecordHolder);
        if (this.accountRecordHolder.mid != '') {
          this.caseRec.MID__c = this.accountRecordHolder.mid;
        } else {
          this.caseRec.MID__c = null;
        }

        if (this.accountRecordHolder.supportEmail == undefined) {
          this.accountRecordHolder.supportEmail = "";
        } else {
          this.caseRec.SuppliedEmail = this.accountRecordHolder.supportEmail;
        }

        if (this.accountRecordHolder.registerBusinessName == undefined) {
          this.accountRecordHolder.registerBusinessName = "";
        } else {
          this.caseRec.Registered_Business_Name__c =
            this.accountRecordHolder.registerBusinessName;
        }
        if (this.accountRecordHolder.merchantSiteUrl == undefined) {
          this.accountRecordHolder.merchantSiteUrl = "";
        } else {
          this.caseRec.Merchant_Site_Url__c =
            this.accountRecordHolder.merchantSiteUrl;
        }
        if (this.accountRecordHolder.businessName == undefined) {
          this.accountRecordHolder.businessName = "";
        }
        if (this.accountRecordHolder.website == undefined) {
          this.accountRecordHolder.website = "";
        } else {
          this.caseRec.Website__c = this.accountRecordHolder.website;
        }
        if (this.accountRecordHolder.lob == undefined) {
          this.accountRecordHolder.lob = "";
        } else {
          this.caseRec.LOB__c = this.accountRecordHolder.lob;
        }
        if (this.accountRecordHolder.entityType == undefined) {
          this.accountRecordHolder.entityType = "";
        } else {
          this.caseRec.Entity_Type__c = this.accountRecordHolder.entityType;
        }
        this.getOpportunityData();
      })
      .catch((error) => {
        console.log("Error Data:::" + error);
      });
  }

  selectedTemplate;
  /*handleTemplateSelect(event){
        var templateId=event.target.value;
        console.log('templateId::'+templateId);
        this.templateList.forEach(item=>{
            if(item.Id==templateId){
                this.caseRec.Onboarding_Template__c=item.Id;
                this.caseRec.OnboardingTemplateName=item.Name;
                item.select=true;
            }else{
                item.select=false;
            }
        })
        this.checkNextButton();
    }*/

  disabledTemplateNext = true;
  checkNextButton() {
    if (
      this.caseRec.Onboarding_Template__c != "" ||
      this.caseRec.Onboarding_Template__c
    ) {
      this.disabledTemplateNext = false;
    } else {
      this.disabledTemplateNext = true;
    }
  }

  /*handleTemplateNext(){
        this.screen.templatePage=false;
        this.screen.firstPage=true;
    }

    handleContactBack(){
        this.screen.templatePage=true;
        this.screen.firstPage=false;
    }*/

  handleContactNext() {
    console.log('Case Record::::', this.caseRec);
    this.getTemplateCheckList();
    this.screen.firstPage = false;
    this.screen.secondPage = true;
  }

  checkValidation() {
    // if(this.caseRec.ContactId)
  }

  handleChecklistBack() {
    this.screen.secondPage = false;
    this.screen.firstPage = true;
  }

  /*handleChecklistNext(){
        this.screen.secondPage=false;
        this.screen.thirdPage=true;
    }

    handleProjectBack(){
        this.screen.thirdPage=false;
        this.screen.secondPage=true;
    }*/

  handleTemplateChange(event) {
    var templateRec = event.detail;
    this.caseRec.Onboarding_Template__c = templateRec.Id;
    this.caseRec.OnboardingTemplateName = templateRec.Name;
    this.checkTemplateSelected();
    console.log("caseRec::", this.caseRec);
  }

  disableTemplateLib = true;
  checkTemplateSelected() {
    if (this.caseRec.Onboarding_Template__c) {
      this.disableTemplateLib = false;
      this.getTemplateCheckList();
      this.selectedChecklist = [];
    } else {
      this.disableTemplateLib = true;
      this.checklist = null;
    }
  }

  @track checklist = [];
  getTemplateCheckList() {
    this.load = true;
    this.checklist = [];
    console.log("entityType:::::", this.entityType);
    ChecklistTaskData({
      templateId: this.caseRec.Onboarding_Template__c,
      entityType: this.entityType
    })
      .then((result) => {
        console.log("ChecklistTaskData:::", result);
        this.checklist = result.filter((item) => {
          item.selected = true;
          item.showTask = false;
          item.newTask = false;
          item.userId = this.opportunityData.currentUser.Id;
          item.userName = this.opportunityData.currentUser.Name;
          item.openTask = 0;
          if (item.taskList) {
            item.openTask = item.taskList.length;
          }
          return item;
        });
        this.load = false;
      })
      .catch((error) => {
        this.load = false;
        console.log("error::", error);
        this.showToastMessage("Error", error.body.message, "error");
      });
  }

  handleSelectChecklist(event) {
    var checklist = event.target.name;
    var checked = event.target.checked;
    this.checklist.forEach((item) => {
      if (item.checklistId == checklist) {
        item.selected = checked;
      }
    });
    console.log("this.checklist", this.checklist);
  }

  newChecklist = {
    Name: "",
    userId: "",
    checklistId: "",
    userName: "",
    selected: true,
    showTask: false,
    newTask: true,
    taskList: []
  };
  showNewChecklist = false;
  showPopover = false;
  handleNewChecklist() {
    this.newChecklist.checklistId = Math.random();
    this.showNewChecklist = true;
    this.showPopover = true;
  }

  handleChecklistName(event) {
    var value = event.target.value;
    this.newChecklist.Name = value;
  }

  handleNewChecklistSave() {
    this.load = true;
    this.checklist.push(this.newChecklist);
    console.log("this.checklist", this.checklist);
    this.handleCancelNewChecklist();
    this.load = false;
  }

  handleCancelNewChecklist() {
    this.load = true;
    this.showNewChecklist = false;
    this.newChecklistTask = false;
    this.ChecklistTask = false;
    this.showPopover = false;
    this.newChecklist = {
      Name: "",
      userId: "",
      checklistId: "",
      userName: "",
      selected: true,
      showTask: false,
      newTask: true
    };
    this.newTask = {
      Name: "",
      DueDay: "",
      taskId: "",
      checklistId: "",
      checklistName: ""
    };
    this.checkTaskCount();
    this.load = false;
  }

  // handlecontactremove(event){
  //   this.contactName = event.target.name;

  //   console.log('1contactName>>',this.contactName);
  //   console.log('1projectChange>>',this.projectChange);

  //   if(this.projectChange=='' && this.contactName==''){
  //     this.disableNext=true;
  //   }
  // }



  handleFieldChange(event) {
    console.log("Default Value:::" + JSON.stringify(this.caseRec));
    var fieldName = event.target.name;
    var value = event.target.value;



    this.projectChange = event.target.value;

    if (this.projectChange != '' && this.handlenextbutton != false) {
      this.disableNext = false;
    }
    else {
      this.disableNext = true;
    }



    console.log('2projectChange>>', this.projectChange);

    // if(fieldName == 'Subject'){
    //    this.caseRec[fieldName] = this.defaultProjectName;
    // }
    // else{
    this.caseRec[fieldName] = value;
    // }

    console.log("caseRec::" + JSON.stringify(this.caseRec));
  }

  newTask = {
    Name: "",
    DueDay: "",
    taskId: "",
    checklistId: "",
    userId: "",
    userName: ""
  };
  newChecklistTask = false;
  openedChecklist;
  ChecklistTask = false;
  handleOpenTask(event) {
    var checklistId = event.target.name;
    this.checklist.forEach((item) => {
      if (checklistId == item.checklistId) {
        this.openedChecklist = item;
      }
    });
    this.ChecklistTask = true;
  }

  handleOpenNewTask() {
    this.newTask.checklistId = this.openedChecklist.checklistId;
    this.newTask.checklistName = this.openedChecklist.Name;
    this.newTask.userId = this.opportunityData.currentUser.Id;
    this.newTask.userName = this.opportunityData.currentUser.Name;
    this.showPopover = true;
    this.newChecklistTask = true;
  }

  handleTaskFieldChange(event) {
    var fieldName = event.target.name;
    var value = event.target.value;
    this.newTask[fieldName] = value;
    console.log("newTask::", this.newTask);
  }

  checkTaskCount() {
    this.checklist.forEach((item) => {
      if (item.taskList) {
        item.openTask = item.taskList.length;
      } else {
        item.openTask = 0;
      }
    });
  }

  handleSaveTask() {
    if (this.openedChecklist.taskList) {
      this.openedChecklist.taskList.push(this.newTask);
    } else {
      this.openedChecklist.taskList = [this.newTask];
    }
    this.handleCancelNewChecklist();
  }

  handleSaveChecklistTask() {
    this.load = true;
    this.checklist.forEach((item) => {
      if (item.checklistId == this.openedChecklist.checklistId) {
        item = this.openedChecklist;
      }
    });
    console.log("checklist::", this.checklist);
    this.handleCancelNewChecklist();
    this.load = false;
  }

  checkMendetoryFields() {
    if (this.caseRec.Subject == "" || this.caseRec.Subject == null) {
      this.showToastMessage(
        "Error",
        "Please fill all required fields.",
        "error"
      );
      return true;
    }
    return false;
  }

  checkCheckList() {
    if (this.checklist.length == 0) {
      this.showToastMessage("Error", "Please select checklist.", "error");
      return true;
    }
  }

  handleSave() {
    console.log("Function Call Save:::");
    console.log("this.caseRec:::::", this.caseRec);
    console.log("checkList::::::", this.checklist);
    console.log("checkList::::::", this.docChecklistList);

    this.load = true;
    if (this.checkMendetoryFields()) {
      this.load = false;
      return;
    }
    this.caseRec.Opportunity__c = this.recordId;

    createCaseChecklist({
      caseRec: this.caseRec,
      checkList: this.checklist,
      docChecklist: this.docChecklistList,
      accountId: this.opportunityData.oppRec.AccountId
    })
      .then((result) => {
        console.log("ChecklistTaskData:::", result);
        if (result == "error") {
          this.showToastMessage("Error", "Something went wrong.", "error");
        } else {
          this.handleHideInitiateOnboardButton();
          this.showToastMessage(
            "Success",
            "Records created successfully.",
            "success"
          );

        }
        this.createOnBoard();

      })
      .catch((error) => {
        this.load = false;
        console.log("error::" + error);
        this.showToastMessage("Error", error.body.message, "error");
      });

  }
  createOnBoard() {
    createOnBoardResponseRecord({ onboardList: this.answerresult, recordId: this.recordId })
      .then(result => {
        if (result == 'success') {
          console.log('result:::', result);
          this.handleCancel();
          this.load = false;
        }
      })
      .catch((error) => {
        console.log("error::" + JSON.stringify(error));
      })
  }
  //handle case type picklist
  handleCaseType(event) {
    console.log("Option::::" + event.detail.value);
    console.log("Option::::" + event.target.value);
    if (event.target.name == "Case Type") {
      if (event.target.value == "General Request") {
        console.log("If Pass::::");
        this.casecategory = event.target.value;
        this.caseRec.Type = "Onboarding";
      } else {
        this.casecategory = event.target.value;
        this.caseRec.Type = event.target.value;
      }
    }
    console.log("Case Record::::" + JSON.stringify(this.caseRec));
  }

  handleHideInitiateOnboardButton() {
    const eventData = new CustomEvent("initiatebutton", { detail: false });
    this.dispatchEvent(eventData);
  }

  handleContactChange(event) {
    this.handlenextbutton = event.detail;

    if (this.projectChange != '' && this.handlenextbutton != false) {
      this.disableNext = false;
    }
    else {
      this.disableNext = true;
    }
    console.log('Function Called::::' + JSON.stringify(event.detail));
    if (!event.detail) {
      this.caseRec.ContactName = null;
      this.caseRec.ContactId = null;
      this.handlenextbutton = false;
      console.log('Case Data inside :::' + JSON.stringify(this.handlenextbutton));
      return;
    }

    // if(event.detail!=false){
    //   this.contactName=true;
    // }




    console.log('Event Data:::', event.detail);
    let contactRec = event.detail;
    this.caseRec.ContactName = contactRec.Name;
    this.caseRec.ContactId = contactRec.Id;
    console.log('Case Data:::' + JSON.stringify(this.handlenextbutton));




    fetchContactRecord({ contactId: contactRec.Id })
      .then((result) => {
        console.log("result:::", result);
        if (result) {
          this.caseRec.ContactEmail = result.Email;
          this.caseRec.ContactPhone = result.Phone;
          this.stopOnboardingComponent = true;
          // this.disableNext=false;

          this.screen.firstPage = true;
        }
      })
      .catch((error) => {
        console.log("error:::", error);
      });
    console.log("caseRec::", this.caseRec);
  }

  //CANCEL ACTION
  handleCancel() {
    let aura = window["$" + "A"];
    aura.get("e.force:refreshView").fire();
    const closeQA = new CustomEvent("close");
    this.dispatchEvent(closeQA);
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

  //REDIRECT TO RECORD FUNCTION
  handleRedirect(recId) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recId,
        actionName: "view"
      }
    });
  }

  
  selectedNavHandler(event) {
    for (let i = 0; i < event.size; i++) {
      console.log("394: " + JSON.stringify(event.detail[i]));
    }
    console.log("393: " + JSON.stringify(event.detail));
    this.docChecklistList = JSON.stringify(event.detail);
    console.log(
      "Document CheckList:::" + JSON.stringify(this.docChecklistList)
    );
  }
}