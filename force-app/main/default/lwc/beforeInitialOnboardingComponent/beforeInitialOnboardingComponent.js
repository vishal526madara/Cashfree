import { api, LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getOptionsForApprovalType from "@salesforce/apex/OnBoardingController.getOptionsForOppApprovalType";
import getOptionsForOwnershipPicklist from "@salesforce/apex/OnBoardingController.getOptionsForOwnershipPicklist";
import updateOpportunity from "@salesforce/apex/OnBoardingController.updateOpportunity";
import updateDeviation from "@salesforce/apex/OnBoardingController.updateDeviation";
import getAccountDetails from "@salesforce/apex/OnBoardingController.currentOpportunityRec";
import updateAccount from "@salesforce/apex/OnBoardingController.updateAccount";
import getPaymentGatewayProduct from "@salesforce/apex/OnBoardingController.getPaymentGatewayProduct";
import getOnboardingCheckList from "@salesforce/apex/OnBoardingController.getOnboardingCheckList";

import {
  getRecord,
  getFieldValue,
  updateRecord,
  getRecordNotifyChange
} from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import LOB from "@salesforce/schema/Account.Industry";
import SUB_LOB from "@salesforce/schema/Account.Sub_LOB__c";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import checkDeviationAndCaseStatus from "@salesforce/apex/OnBoardingController.checkDeviationAndCaseStatus";
import createCaseSubjectName from "@salesforce/apex/OnBoardingController.createCaseSubjectName";
import fetchSubLobPicklistValues from "@salesforce/apex/OnBoardingController.fetchSubLobPicklistValues";

import {
  subscribe,
  MessageContext,
  unsubscribe,
  APPLICATION_SCOPE
} from "lightning/messageService";
import DEVIATION_REFRESH from "@salesforce/messageChannel/deviationRefresh__c";

export default class BeforeInitialOnboardingComponent extends LightningElement {
  subscription = null;
  @api recordId;

  @track LOBPICKLIST;
  @track SUBLOBPICKLIST;

  @track load = false;

  @track showQuestionaire = false;
  /**
   * variable used to hold product name
   * functionality: whenever initiate onboard start for payment gateway product then merchatsiteurl
   * and website should be mandatory
   */
  @track opportunityProductName;

  @track subLobData;

  getAccDetails = false;
  checkDiviation = false;
  noCheck = false;
  needApprovalchecked = false;
  okayforOnboarding = false;

  //Use to Show Initiate Onboarding Button
  //Initially It Was False
  @track
  showOnboardingButton = false;

  //use to store deviation Record
  holdDeviationRecords;

  showPopover = false;
  accDetailPopover = false;

  checkDeviationPopover = false;

  approvalPopover = false;
  okayforOnboardingPopover = false;
  ownershipPicklist = [];
  approvalPicklist = [];
  defaultSubLobPickList = [];

  subDefaultPickList = [];
  defaultSubLob;
  subLobVisibilty;

  LOBPICKLIST = [];
  SUBLOBPICKLIST = [];

  @track oppData;
  accId;
  selectedEntity = "";
  salesApproval = false;
  bankOpsApproval = false;
  selectedDeviation;
  showrows;
  opportunity;
  showOnboardingChecklist;

  //Wired Product Name
  wiredProductName;

  @track statusCheckDeviation;
  hideNeedApproval = false;
  //accountObject;

  @track accountObject = {
    accountId: null,
    lob: null,
    subLob: null,
    cin: null,
    gst: null,
    ownerPan: null,
    accHolderName: null,
    pan: null,
    phone: null,
    registeredName: null,
    merchantSiteURL: null,
    supportEmail: null,
    accountEmail: null,
    entityValue: null,
    website: null
  };

  @track questionList = [];
  @track pickValue = false;
  @track textValue = false;
  picklistOptionValuesArray = [];
  displayQuestionList = [];

  handleDisplayQuestion() {
    console.log("inside handleDisplayQuestion");
    if (this.displayQuestionList.length == 0) {
      getOnboardingCheckList()
        .then((result) => {
          this.questionList = result;
          if (this.questionList.length == 0) {
            this.showOnboardingChecklist = false;
            this.displayNext = true;
          } else {
            this.displayNext = false;
            this.showOnboardingChecklist = true;
            for (let i = 0; i < this.questionList.length; i++) {
              this.picklistOptionValuesArray = [];
              if (this.questionList[i].Selection_Type__c == "Picklist") {
                this.pickValue = true;
                this.textValue = false;
              } else {
                this.textValue = true;
                this.pickValue = false;
              }
              var arrayValues =
                this.questionList[i].Response_Option__c.split(",");
              for (let i = 0; i < arrayValues.length; i++) {
                let picklistOptionValues = {
                  label: arrayValues[i],
                  value: arrayValues[i]
                };
                this.picklistOptionValuesArray.push(picklistOptionValues);
                //console.log('picklistOptionValues: '+i,':'+picklistOptionValues);
              }
              console.log(
                "picklistOptionValuesArray: " +
                  JSON.stringify(this.picklistOptionValuesArray)
              );
              let tempQuestion = {
                QuestionName: this.questionList[i].Question__c,
                IsPicklist: this.pickValue,
                IsTextValue: this.textValue,
                QuestionResponse: "",
                ResponseOptions: this.picklistOptionValuesArray,
                QuestionId: this.questionList[i].Id
              };
              // console.log('Selection Type:::',this.QuestionList[i].Selection_Type__c);
              // if(this.QuestionList[i].Selection_Type__c == 'Picklist'){

              //   this.pickValue = true;
              //   this.textValue = false;
              // }else{
              //   this.textValue = true;
              // }

              this.displayQuestionList = [
                ...this.displayQuestionList,
                tempQuestion
              ];
            }
            console.log("this.QuestionList::", this.displayQuestionList);
            //this.QuestionList = result;
          }
        })
        .catch((error) => {
          console.log("error::", error);
        });
    }
    //this.showInitiateOnboardingPopover = true;
    //console.log('Show Questionaire:::',this.showInitiateOnboardingPopover);
  }

  @track IdValue;
  @track AnswerList = [];
  @track tempList = [];
  @track displayNext = false;
  handleResponseChange(event) {
    console.log("inside handleResponseChange");
    console.log("value: " + event.target.value);
    let questionRecord = this.displayQuestionList.find(
      (ele) => ele.QuestionId === event.target.dataset.id
    );
    questionRecord.QuestionResponse = event.target.value;
    console.log("questionRecord: " + JSON.stringify(questionRecord));
    let flag = false;
    for (let i = 0; i < this.displayQuestionList.length; i++) {
      console.log("response:" + this.displayQuestionList[i].QuestionResponse);
      if (this.displayQuestionList[i].QuestionResponse == "") {
        flag = true;
        break;
      }
    }

    if (flag == false) {
      this.displayNext = true;
    }
    // for(let i = 0; i < this.QuestionList.length; i++){
    //   if(event.target.dataset.id == this.QuestionList[i].Id){
    //     this.QuestionList[i].answer = event.target.value;
    //     console.log('Question Answer:::',this.QuestionList[i].answer);
    //     let anserValue={
    //       Id : event.target.dataset.id,
    //       Question__c  : event.target.name,
    //       Response_Option__c : event.target.value

    //     }
    //     this.AnswerList.push(anserValue);
    //   }
    // }
    // this.tempList = this.AnswerList;

    // console.log('answer:::', this.QuestionList);
    //   console.log('Answer Length:::',this.AnswerList.length);
    //   console.log('Question Length:::',this.QuestionList.length);
    //   if(this.AnswerList.length % this.QuestionList.length == 0){
    //     this.displayNext = true;
    //   }else{
    //     this.displayNext = false;
    //   }
    // console.log('AnswerList:::',this.AnswerList);
  }

  dataCkecklist = [
    { label: "Get Account Details", isCompleted: true },
    { label: "Check Diviation", isCompleted: true },
    { label: "Needs Approval", isCompleted: true },
    { label: "Get Account Details", isCompleted: true }
  ];
  get options() {
    return [
      { label: "Yes", value: "yes" },
      { label: "No", value: "no" }
    ];
  }

  @wire(MessageContext)
  messageContext;

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        DEVIATION_REFRESH,
        (message) => this.handleOnboardingRefresh(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  handleOnboardingRefresh(message) {
    console.log("Message::::" + message);
    this.approvalTypePicklist();
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
    console.log("this.QuestionList::", this.QuestionList);
  }

  //@wire(getRecord, { recordId: "$recordId", fields })

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      "Opportunity.Id",
      "Opportunity.Bank_Ops_Approval__c",
      "Opportunity.Sales_Approval__c",
      "Opportunity.Any_Deviation__c",
      "Opportunity.Finance_Approval__c",
      "Opportunity.Risk_Approval__c",
      "Opportunity.Price_Deviation_Approval__c"
    ]
  })
  fetchCurrentOpportunity({ data, error }) {
    this.opportunity = { data, error };
    console.log("Opportunity Record::::::", this.opportunity);
    if (data) {
      //this.checkApprovalStatus();
    } else if (error) {
    }
  }

  @track showRequiredFields = false;
  @wire(getPaymentGatewayProduct, { recordId: "$recordId" })
  assignOpportunityProductName(result) {
    this.wiredProductName = result;
    if (result.data) {
      this.opportunityProductName = result.data;
      if (this.opportunityProductName == "Payment Gateway") {
        this.showRequiredFields = true;
        //     console.log('Product Name Pass');
        //     let val = 'Merchant_Site_Url';
        //    this.template.querySelector('[data-id="Merchant_Site_Url"]').className='font-style';
      } else {
        this.showRequiredFields = false;
      }
    } else if (result.error) {
    }
  }

  renderStop = false;
  renderedCallback() {}

  intervalCallFunction() {
    let value = setInterval(() => {
      getRecordNotifyChange([{ recordId: this.recordId }]);
      if (this.opportunity.data != null) {
        if (!this.renderStop) {
          if (
            this.opportunity.data.fields.Bank_Ops_Approval__c.value == true ||
            this.opportunity.data.fields.Sales_Approval__c.value == true ||
            this.opportunity.data.fields.Risk_Approval__c.value == true ||
            this.opportunity.data.fields.Finance_Approval__c.value == true ||
            this.opportunity.data.fields.Price_Deviation_Approval__c.value ==
              true
          ) {
            this.renderStop = true;
            this.approvalTypePicklist();
          }
        }
      }
    }, 1000);
  }

  //wire function is used to fetch account object information
  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  accountInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$accountInfo.data.defaultRecordTypeId",
    fieldApiName: LOB
  })
  lobFieldInfo({ data, error }) {
    if (data) {
      this.LOBPICKLIST = data.values;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$accountInfo.data.defaultRecordTypeId",
    fieldApiName: SUB_LOB
  })
  subLobInfo({ data, error }) {
    if (data) {
      this.subLobData = data;
      //this.fetchSubLobPickListValue();
      //this.approvalTypePicklist();
    }
  }

  handleLobChange(event) {
    this.subLobVisibilty = false;
    this.handleLobChangeHandler(
      this.subLobData.controllerValues[event.target.value]
    );
    if (event.currentTarget.dataset.id == "LOB") {
      this.accountObject.lob = event.target.value;
      this.accountObject.subLob = "";
      this.oppData.Account.Sub_LOB__c = "";
    }
  }

  handleLobChangeHandler(controllingValue) {
    let key = controllingValue;
    this.SUBLOBPICKLIST = this.subLobData.values.filter((opt) =>
      opt.validFor.includes(key)
    );

    //  if(event.currentTarget.dataset.id == 'LOB'){
    //      this.accountObject.lob = event.target.value;
    //  }
  }

  connectedCallback() {
    console.log("Opportunity Records::::::", this.opportunity);
    this.subscribeToMessageChannel();
    this.getAccountDetails();
    //this.fetchSubLobPickListValue();
    this.intervalCallFunction();
    this.approvalTypePicklist();
    //this.checkDeviationStatus();
  }

  financeApproval = false;
  riskApproval = false;
  priceDeviationApproval = false;
  getAccountDetails() {
    getAccountDetails({ recordId: this.recordId })
      .then((result) => {
        this.oppData = result.oppRec;
        if (this.oppData.AccountId != "undefined") {
          this.accountObject.accountId = this.oppData.AccountId;
        }

        if (this.oppData.Account.Industry != undefined) {
          this.handleLobChangeHandler(this.oppData.Account.Industry);
          this.accountObject.lob = this.oppData.Account.Industry;
          //this.accountObject.subLob = '';
        }

        if (this.oppData.Account.Sub_LOB__c != undefined) {
          this.subDefaultPickList.push({
            label: this.oppData.Account.Sub_LOB__c,
            value: this.oppData.Account.Sub_LOB__c
          });
          this.defaultSubLob = this.oppData.Account.Sub_LOB__c;
          this.subLobVisibilty = true;
          this.handleLobChangeHandler(this.oppData.Account.Sub_LOB__c);
          this.accountObject.subLob = this.oppData.Account.Sub_LOB__c;
        }

        if (this.oppData.CIN__c != "undefined") {
          this.accountObject.cin = this.oppData.Account.CIN__c;
        }
        if (this.oppData.Account_Holder_Name__c != "undefined") {
          this.accountObject.accHolderName =
            this.oppData.Account.Account_Holder_Name__c;
        }
        if (this.oppData.Owner_Director_PAN_Number__c != "undefined") {
          this.accountObject.ownerPan =
            this.oppData.Account.Owner_Director_PAN_Number__c;
        }

        if (this.oppData.GST__c != "undefined") {
          this.accountObject.gst = this.oppData.Account.GST__c;
        }
        if (this.oppData.PAN__c != "undefined") {
          this.accountObject.pan = this.oppData.Account.PAN__c;
        }
        if (this.oppData.Registered_Name__c != "undefined") {
          this.accountObject.registeredName =
            this.oppData.Account.Registered_Name__c;
        }
        if (this.oppData.Phone != "undefined") {
          this.accountObject.phone = this.oppData.Account.Phone;
        }
        if (this.oppData.Support_Email__c != "undefined") {
          this.accountObject.supportEmail =
            this.oppData.Account.Support_Email__c;
        }
        if (
          this.oppData.Account.Merchant_Site_Url__c == undefined ||
          this.oppData.Account.Merchant_Site_Url__c == "" ||
          this.oppData.Account.Merchant_Site_Url__c == null
        ) {
          this.accountObject.merchantSiteURL = "";
        } else {
          this.accountObject.merchantSiteURL =
            this.oppData.Account.Merchant_Site_Url__c;
        }
        if (
          this.oppData.Account.Website == undefined ||
          this.oppData.Account.Website == null ||
          this.oppData.Account.Website == ""
        ) {
          this.accountObject.website = "";
        } else {
          this.accountObject.website = this.oppData.Account.Website;
        }

        if (this.oppData.Ownership != "undefined") {
          this.accountObject.entityValue = this.oppData.Account.Ownership;
        }

        this.accId = result.oppRec.AccountId;
        this.selectedEntity = result.oppRec.Account.Ownership;
        this.bankOpsApproval = result.oppRec.Bank_Ops_Approval__c;
        this.salesApproval = result.oppRec.Sales_Approval__c;
        this.financeApproval = result.oppRec.Finance_Approval__c;
        this.riskApproval = result.oppRec.Risk_Approval__c;
        this.priceDeviationApproval = result.oppRec.Price_Deviation_Approval__c;
        if (this.selectedEntity == null || this.selectedEntity == "") {
          this.getAccDetails = false;
        } else {
          this.getAccDetails = true;
        }

        if (
          this.salesApproval == true &&
          this.bankOpsApproval == true &&
          this.riskApproval == true &&
          this.financeApproval == true &&
          this.priceDeviationApproval == true
        ) {
          this.needApprovalchecked = true;
        } else {
          this.needApprovalchecked = false;
        }
        this.checkDeviationStatus();
      })
      .catch((error) => {
        console.log("error::", error);
        //this.showToastMessage('Error', error.body.message, 'error');
      });
  }

  //Show Check Deviation Status
  checkDeviationStatus() {
    if (this.opportunity.data != null) {
      console.log(
        "this.opportunity.data.fields.Any_Deviation__c.value",
        this.opportunity.data.fields.Any_Deviation__c.value
      );
      if (this.opportunity.data.fields.Any_Deviation__c.value == "Yes") {
        this.selectedDeviation = "yes";
        // this.noCheck = false;
        this.hideNeedApproval = true;
        this.statusCheckDeviation = "Yes";
        //this.showrows = true;
        this.showOnboardingButton = false;
      } else if (this.opportunity.data.fields.Any_Deviation__c.value == "No") {
        //this.showrows = true;
        this.statusCheckDeviation = "No";
        this.selectedDeviation = "no";
        this.hideNeedApproval = false;
        this.checkDiviation = true;
        this.noCheck = false;
        // this.checkDiviation = true;
        this.showOnboardingButton = true;
      }
      this.checkApprovalStatus();
    }
  }

  checkApprovalStatus() {
    this.salesApproval = false;
    this.bankOpsApproval = false;
    //this.checkDiviation = false;
    if (this.opportunity.data != null) {
      if (this.opportunity.data.fields.Any_Deviation__c.value == "Yes") {
        //Check Status for Bank Ops Approval
        if (this.opportunity.data.fields.Bank_Ops_Approval__c.value == true) {
          this.bankOpsApproval = true;
        } else if (
          this.opportunity.data.fields.Bank_Ops_Approval__c.value == false
        ) {
          this.bankOpsApproval = false;
        }

        //check Status for Sales Approval
        if (this.opportunity.data.fields.Sales_Approval__c.value == true) {
          this.salesApproval = true;
        } else if (
          this.opportunity.data.fields.Sales_Approval__c.value == false
        ) {
          this.salesApproval = false;
        }

        if (
          this.opportunity.data.fields.Sales_Approval__c.value == true &&
          this.opportunity.data.fields.Bank_Ops_Approval__c.value == true &&
          this.opportunity.data.fields.Risk_Approval__c.value == true &&
          this.opportunity.data.fields.Finance_Approval__c.value == true &&
          this.opportunity.data.fields.Price_Deviation_Approval__c.value == true
        ) {
          // this.handleDeviationChange = true;
          this.bankOpsApproval = true;
          this.salesApproval = true;
          this.riskApproval = true;
          this.financeApproval = true;
          this.needApprovalchecked = true;
          this.priceDeviationApproval = true;
        }
        this.checkDiviation = true;
      } else if (this.opportunity.data.fields.Any_Deviation__c.value == "No") {
        this.checkDiviation = true;
      } else {
        this.checkDiviation = false;
      }
    }
    this.checkInitiateButtonStatus();
  }

  //ENTITY PICKLIST VALUES
  getownershipPicklist() {
    getOptionsForOwnershipPicklist()
      .then((result) => {
        this.ownershipPicklist = result;
        this.getAccountDetails();
      })
      .catch((error) => {
        console.log("error::" + JSON.stringify(error));
        this.showToastMessage("Error", error.body.message, "error");
      });
  }

  checkInitiateButtonStatus() {
    checkDeviationAndCaseStatus({ recordId: this.recordId })
      .then((result) => {
        if (
          result.opportunityDeviation == true &&
          result.parentCaseCreation == true
        ) {
          this.showOnboardingButton = false;
        } else if (
          result.opportunityDeviation == false &&
          result.parentCaseCreation == true
        ) {
          this.showOnboardingButton = false;
        } else if (
          result.opportunityDeviation == true &&
          result.parentCaseCreation == false
        ) {
          if (this.selectedDeviation == "yes") {
            if (
              this.bankOpsApproval == true ||
              this.salesApproval == true ||
              this.riskApproval == true ||
              this.financeApproval == true ||
              this.priceDeviationApproval == true
            ) {
              this.showOnboardingButton = true;
            }
          } else if (this.selectedDeviation == "no") {
            this.showOnboardingButton = true;
          }

          //this.needApprovalchecked = false;
        } else if (
          result.opportunityDeviation == false &&
          result.parentCaseCreation == false
        ) {
          this.showOnboardingButton = "";
          //this.needApprovalchecked = false;
        }
      })
      .catch((error) => {
        console.log("Error::::" + JSON.stringify(error));
      });
  }

  //APPROVAL PICKLIST VALUES
  approvalTypePicklist() {
    getOptionsForApprovalType()
      .then((result) => {
        this.approvalPicklist = result;
        this.getownershipPicklist();
      })
      .catch((error) => {
        console.log("error::" + JSON.stringify(error));
        this.showToastMessage("Error", error.body.message, "error");
      });
  }

  handleClosePopoverModal() {
    this.showPopover = false;
    this.accDetailPopover = false;
    this.checkDeviationPopover = false;
    this.approvalPopover = false;
    this.okayforOnboardingPopover = false;
    //this.updateRecordView();
  }

  handleGetAccDetails() {
    refreshApex(this.wiredProductName);
    this.accDetailPopover = true;
    this.checkDeviationPopover = false;
    this.approvalPopover = false;
    this.okayforOnboardingPopover = false;
  }

  handleEntityTypeChange(event) {
    this.accountObject.accountId = this.accId;
    if (event.currentTarget.dataset.id == "AccountName") {
      this.accountObject.entityValue = event.target.value;
      this.selectedEntity = event.target.value;
    } else if (event.currentTarget.dataset.id == "LOB") {
      this.accountObject.subLob = "";
      this.oppData.Account.Sub_LOB__c = "";
      this.accountObject.lob = event.target.value;
    } else if (event.currentTarget.dataset.id == "SUB_LOB") {
      this.oppData.Account.Sub_LOB__c = event.target.value;
      this.accountObject.subLob = event.target.value;
    } else if (event.currentTarget.dataset.id == "PAN") {
      this.accountObject.pan = event.target.value;
    } else if (event.currentTarget.dataset.id == "CIN") {
      this.accountObject.cin = event.target.value;
    } else if (event.currentTarget.dataset.id == "GST") {
      this.accountObject.gst = event.target.value;
    } else if (event.currentTarget.dataset.id == "Account_Holder_Name") {
      this.accountObject.accHolderName = event.target.value;
    } else if (event.currentTarget.dataset.id == "Owner_PAN_Number") {
      this.accountObject.ownerPan = event.target.value;
    } else if (event.currentTarget.dataset.id == "Registered_Name") {
      this.accountObject.registeredName = event.target.value;
    } else if (event.currentTarget.dataset.id == "Merchant_Site_Url") {
      this.accountObject.merchantSiteURL = event.target.value;
    } else if (event.currentTarget.dataset.id == "support_email") {
      this.accountObject.supportEmail = event.target.value;
    } else if (event.currentTarget.dataset.id == "phone") {
      this.accountObject.phone = event.target.value;
    } else if (event.currentTarget.dataset.id == "Website") {
      this.accountObject.website = event.target.value;
    }
    // else if(event.currentTarget.dataset.id == "Email"){
    //     this.accountObject.accountEmail = event.target.value;
    // }
  }

  handleSaveAccDetails() {
    let panValidattionPattern = /[A-Z]{5}[0-9]{4}[A-Z]{1}/;
    let gstValidationPattern =
      /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;

    if (this.selectedEntity == null || this.selectedEntity == "") {
      this.showToastMessage("Error", "Please enter Entity Type.", "error");
      return true;
    }
    if (this.accountObject.lob == null || this.accountObject.lob == "") {
      this.showToastMessage("Error", "Please enter LOB.", "error");
      return true;
    }
    // if(this.accountObject.accountEmail == null || this.accountObject.accountEmail == ""){
    //     this.showToastMessage("Email Validation","Please Enter Email Address","warning");
    //     return true;
    // }
    if (this.accountObject.pan == null || this.accountObject.pan == "") {
      this.showToastMessage(
        "Error",
        "Please enter Business PAN Number.",
        "error"
      );
      return true;
    }
    if (
      this.accountObject.pan != undefined &&
      this.accountObject.pan != "" &&
      !panValidattionPattern.test(JSON.stringify(this.accountObject.pan))
    ) {
      this.showToastMessage(
        "Error",
        "Please enter valid PAN Number",
        "warning"
      );
      return true;
    }
    if (
      (this.accountObject.ownerPan != undefined ||
        this.accountObject.ownerPan != "") &&
      !panValidattionPattern.test(JSON.stringify(this.accountObject.ownerPan))
    ) {
      this.showToastMessage(
        "PAN Number Validation",
        "Please enter valid PAN Number",
        "warning"
      );
      return true;
    }

    if (
      this.accountObject.gst != undefined &&
      this.accountObject.gst != "" &&
      !this.accountObject.gst.match(gstValidationPattern)
    ) {
      //!gstValidationPattern.test(JSON.stringify(this.accountObject.gst))
      this.showToastMessage(
        "GST Number Validation",
        "Please Enter valid GST Number",
        "warning"
      );
      return true;
    }
    if (this.showRequiredFields) {
      if (
        this.accountObject.merchantSiteURL == "" ||
        this.accountObject.website == "" ||
        this.accountObject.merchantSiteURL == undefined ||
        this.accountObject.website == undefined
      ) {
        this.showToastMessage(
          "Mandatory Fields",
          "Merchant Site URL and Website are mandatory",
          "warning"
        );
        return true;
      }
    }
    if (
      this.accountObject.subLob == "" ||
      this.accountObject.subLob == undefined ||
      this.accountObject.subLob == null
    ) {
      this.showToastMessage(
        "Sub Lob Is Mandatory",
        "Without it you cannot proceed",
        "warning"
      );
      return true;
    }
    let JsonInput = JSON.stringify(this.accountObject);
    updateAccount({ jsonAccountInput: JsonInput })
      .then((result) => {
        if (result == "error") {
          this.showToastMessage("Error", "Something went wrong.", "error");
        } else {
          //this.getAccountDetails();
          //this.handleSavecheckDeviation();
          getAccountDetails({ recordId: this.recordId })
            .then((result) => {
              this.oppData = result.oppRec;
            })
            .catch((error) => {
              this.showToastMessage(
                "Warning",
                "Something Went Wrong",
                "Warning"
              );
            });
          this.showToastMessage("Success", "update successfull", "success");
          this.handleClosePopoverModal();
          this.getAccDetails = true;
        }
      })
      .catch((error) => {
        console.log("error::", error);
        this.showToastMessage("Error", error.body.message, "error");
      });
  }

  handleCheckDeviation() {
    this.showPopover = true;
    this.accDetailPopover = false;
    this.checkDeviationPopover = true;
    this.approvalPopover = false;
    this.okayforOnboardingPopover = false;
  }

  handleDeviationChange(event) {
    console.log("event.value:" + event.target.value);
    this.selectedDeviation = event.target.value;
  }

  handleSavecheckDeviation() {
    console.log("inside handleSavecheckDeviation");
    if (this.selectedDeviation == "" || this.selectedDeviation == "") {
      this.showToastMessage("Error", "Please select Deviation.", "error");

      return true;
    } else {
      console.log("inside deviation else");
      this.showrows = true;
      this.handleClosePopoverModal();
    }

    if (this.selectedDeviation == "yes") {
      console.log("inside deviation yes");
      this.holdDeviationRecords = "Yes";
      //this.updateRecordView();
      this.checkDiviation = true;
      this.noCheck = false;
      this.updateDeviation();
      this.showOnboardingButton = false;
      console.log("inside deviation yes");
      //this.checkInitiateButtonStatus();
    } else if (this.selectedDeviation == "no") {
      console.log("inside deviation no");
      this.showOnboardingButton = true;
      this.holdDeviationRecords = "No";
      this.checkDiviation = true;
      this.noCheck = false;
      this.updateDeviation();
      console.log("inside deviation no");

      //this.approvalTypePicklist();
    }
  }

  /**
   * @description: update opportunity whendeviation is true or false
   * @parameter: user input
   * @return: NA
   */
  updateDeviation() {
    console.log("inside updateDeviation");
    updateDeviation({
      opportunityId: this.recordId,
      deviationValue: this.holdDeviationRecords
    })
      .then((result) => {
        if (result == "success") {
          // this.showOnboardingButton = "";
          getRecordNotifyChange([{ recordId: this.recordId }]);
          this.approvalTypePicklist();
          this.showToastMessage(
            "Success",
            "Record Updated Successfully",
            "success"
          );
        } else {
          this.showToastMessage(
            "Failed",
            "Record failed to Updated",
            "warning"
          );
        }
      })
      .catch((error) => {
        this.showToastMessage("Failed", "Record failed to Updated", "error");
      });
  }

  // /*
  // *@documentation: method used to update current opportunity wheather status is true or not
  //                  Object: Opportunity and Field: Any_Deviation__c
  // *@parameter: NA
  // @retun
  // updateDeviation(){

  // }

  handleNeedApproval() {
    this.showPopover = true;
    this.accDetailPopover = false;
    this.checkDeviationPopover = false;
    this.approvalPopover = true;
    this.okayforOnboardingPopover = false;
  }

  selectedApproval = "";
  handleApprovalChange(event) {
    this.selectedApproval = event.target.value;
  }
  selectedComment = "";
  handleCommentChange(event) {
    this.selectedComment = event.target.value;
  }

  handleSaveApproval() {
    updateOpportunity({
      recordId: this.recordId,
      selectedApproval: this.selectedApproval,
      selectedComment: this.selectedComment,
      selectedDeviation: this.selectedDeviation
    })
      .then((result) => {
        if (result == "error") {
          this.showToastMessage("Error", "Something went wrong.", "error");
        } else if (result == "success") {
          this.showToastMessage("Success", "successfull", "success");
          this.updateRecordView();
          this.handleClosePopoverModal();
          this.showOnboardingButton = "";
          getRecordNotifyChange([{ recordId: this.recordId }]);
          this.approvalTypePicklist();
        }
      })
      .catch((error) => {
        console.log("error::", error);
        this.showToastMessage("Error", error.body.message, "error");
      });
  }

  handleOkayforOnboarding() {
    this.showPopover = true;
    this.accDetailPopover = false;
    this.checkDeviationPopover = false;
    this.approvalPopover = false;
    this.okayforOnboardingPopover = true;
  }
  selectedOnbarding;
  handleOnboarding(event) {
    this.selectedOnbarding = event.target.value;
  }

  handleSaveokayforOnboarding() {
    if (this.selectedOnbarding == "" || this.selectedOnbarding == "") {
      this.showToastMessage("Error", "Please select option.", "error");
      return true;
    } else {
      this.handleClosePopoverModal();
    }
    if (this.selectedOnbarding == "yes") {
      this.okayforOnboarding = true;
      this.showOnboardingButton = true;
    } else if (this.selectedOnbarding == "no") {
      this.okayforOnboarding = false;
    }
  }

  showQuestionaireFunc(event) {
    console.log("inside showQuestionaireFunc");
    console.log("Event:::", JSON.stringify(event.target.answerresult));
    console.log("Event:::1", event.target.answerresult);
    console.log("Event:::2", event.target.answerresult);
    console.log("Event:::3", event.target.answerresult);
    this.QuestionList = event.target.answerresult;

    this.showInitiateOnboardingPopover = false;
    this.showQuestionaire = true;

    this.handleDisplayQuestion();
  }

  hideModalBox() {
    this.showQuestionaire = false;
  }

  defaultSubjectName = "";
  showInitiateOnboardingPopover = false;
  handleInitiateOnboarding() {
    this.showQuestionaire = false;
    createCaseSubjectName({ recordId: this.recordId })
      .then((result) => {
        this.defaultSubjectName = result.subjectName;
        this.showInitiateOnboardingPopover = true;
      })
      .catch((error) => {
        this.showToastMessage("Warning", "Something Went Wrong...", "warning");
      });
  }
  handleCloseInitiateOnboardingPopover() {
    this.showInitiateOnboardingPopover = false;
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

  handleVisibiltyInitiateOnboarding(event) {
    if (event.detail == false) {
      this.showOnboardingButton = false;
    }
  }
  updateRecordView() {
    setTimeout(() => {
      eval("$A.get('e.force:refreshView').fire();");
    }, 1000);
  }
}
