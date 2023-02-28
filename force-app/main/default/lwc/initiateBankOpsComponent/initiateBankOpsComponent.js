import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getParentCaseDetails from "@salesforce/apex/BankOpsController.getParentCaseDetails";
import getOpportunityProductDetails from "@salesforce/apex/BankOpsController.getOpportunityProductDetails";
import getCaseRec from "@salesforce/apex/BankOpsController.getCaseRec";
import generatePaymentWrapper from "@salesforce/apex/BankOpsController.generatePaymentWrapper";
import opportunityProductName from "@salesforce/apex/BankOpsController.opportunityProductName";

export default class InitiateBankOpsComponent extends LightningElement {
  @api parentCaseRecordId;
  @track subjectinfo;
  @api oppId;
  @track caserdId;
  @track finalProductList = [];
  //@modification: varible use to display Case Form
  //@track first = true;

  //@decription: varibale use to show list of work order

  @track customForm2Modal;
  @track parentCaseId;
  casrRec;
  queueName = "Bank Ops Team";
  checkboxOptions = [];
  checkboxValue = [];
  selectedChecklist = [];

  @track paymentGatewayProduct = [];

  @track paymentGatewayTempList = [];

  @track productName = "";

  @track showPaymentGatewayProduct;

  connectedCallback() {
    this.getCurrentCaseRec();
  }

  getCurrentCaseRec() {
    console.log("this.recordId", this.parentCaseRecordId);
    getCaseRec({ recordId: this.parentCaseRecordId })
      .then((result) => {
        this.casrRec = result.Id;
        console.log("casrRec ", this.casrRec);
        this.getOpportunityProductDetailsFunc();
      })
      .catch((error) => {
        console.log("error:::: " + JSON.stringify(error.message));
      });
  }

  // goToStepTwo() {
  //     if(this.queueName == null || this.subjectinfo == null){
  //         console.log("inside error");
  //         this.showToast('Error','Please fill the required fields','error','dismissible');
  //     }else{
  //         this.first = false;
  //         this.customForm2Modal = true;
  //         this.currentStep = '2';
  //     }
  // }

  //    goBackToStepOne () {
  //         this.currentStep = '1';
  //         this.customForm2Modal=false;
  //         this.first = true;
  //     }

  getOpportunityProductDetailsFunc() {
    getOpportunityProductDetails({ oppRecordId: this.oppId })
      .then((result) => {
        this.finalProductList = result;
        console.log("Opportunity Product List ::::", result);
        for (let i = 0; i < result.length; i++) {
          let modes = {
            label: result[i].commercialName,
            value: result[i].commercialId
          };
          console.log("Prev Length::::" + this.checkboxOptions.length);
          this.checkboxOptions = [...this.checkboxOptions, modes];
          this.checkboxValue = [...this.checkboxValue, result[i].commercialId];
          this.selectedChecklist = [
            ...this.selectedChecklist,
            result[i].commercialId
          ];
          //this.checkboxValue.push(modes.value);
          console.log("Next Length::" + this.checkboxOptions.length);
        }
        this.fetchOpportunityProductName();
        console.log("Check First List ::" + JSON.stringify(this.checkboxValue));
        console.log(
          "Check Box List::::" + JSON.stringify(this.checkboxOptions)
        );
      })
      .catch((error) => {
        console.log("error: " + JSON.stringify(error.message));
      });
  }

  async fetchOpportunityProductName() {
    await opportunityProductName({ opportunityId: this.oppId })
      .then((result) => {
        console.log("Product Name::::" + result);
        if (result != "") {
          this.productName = result;
        }
        if (this.productName == "Payment Gateway") {
          this.paymentGatewatewayProduct();
        } else if (this.productName == "Subscriptions") {
          this.paymentGatewatewayProduct();
        } else if (this.productName == "Payment Links") {
          this.paymentGatewatewayProduct();
        } else if (this.productName == "Payment Forms") {
          this.paymentGatewatewayProduct();
        } else if (this.productName == "Soft POS") {
          this.paymentGatewatewayProduct();
        } else if (this.productName == "Cashgram") {
          this.paymentGatewatewayProduct();
        } else {
          this.showPaymentGatewayProduct = false;
          this.customForm2Modal = true;
        }
      })
      .catch((error) => {
        console.log("Error:::::" + JSON.stringify(error));
      });
  }

  paymentGatewatewayProduct() {
    generatePaymentWrapper({ opportunityId: this.oppId })
      .then((result) => {
        console.log("Function Called::::121", result);
        this.paymentGatewayProduct = result;
        for (let i = 0; i < this.paymentGatewayProduct.length; i++) {
          console.log("Wrapper Data:::", this.paymentGatewayProduct[i]);
          for (
            let j = 0;
            j < this.paymentGatewayProduct[i].productWrapperList.length;
            j++
          ) {
            let tempCommerical = {
              commercialId:
                this.paymentGatewayProduct[i].productWrapperList[j]
                  .commercialId,
              commercialName:
                this.paymentGatewayProduct[i].productWrapperList[j]
                  .commercialName
            };
            this.paymentGatewayTempList.push(tempCommerical);
          }
        }
        this.showPaymentGatewayProduct = true;
        this.customForm2Modal = true;
      })
      .catch((error) => {
        console.log("Error:::" + error);
      });
  }

  /**
   * @description: function used to create child case with work line item
   * @update: no requirement of to creat child case it directly create work order
   *           date : 18 July,2022
   */
  getParentCaseDetailsFunc() {
    let tempCheckList = "";
    if (
      this.productName == "Payment Gateway" ||
      this.productName == "Subscriptions" ||
      this.productName == "Payment Links" ||
      this.productName == "Payment Forms" ||
      this.productName == "Soft POS" ||
      this.productName == "Cashgram"
    ) {
      this.checkboxValue = [];
      for (let i = 0; i < this.paymentGatewayTempList.length; i++) {
        this.checkboxValue.push(this.paymentGatewayTempList[i].commercialName);
      }
    } else {
      console.log("Else List:::", this.checkboxValue);
      console.log("Else List:::", this.finalProductList);
      this.paymentGatewayTempList = [];
      for (let i = 0; i < this.checkboxValue.length; i++) {
        if (this.checkboxValue[i] == this.finalProductList[i].commercialId) {
          this.paymentGatewayTempList.push(this.finalProductList[i]);
        }
      }
      //   let normalLevelProduct = this.checkboxValue;
      //   this.checkboxValue = [];
      //   this.paymentGatewayTempList = [];
      //   for (let i = 0; i < normalLevelProduct.length; i++) {
      //     let tempObject = {
      //       commercialName: normalLevelProduct[i]
      //     };
      //     this.paymentGatewayTempList.push(tempObject);
      //   }
    }
    console.log(
      "Checked Value:::" + JSON.stringify(this.paymentGatewayTempList)
    );

    // Update 21 July,2022
    //if(this.paymentGatewayTempList.length != 0){
    tempCheckList = JSON.stringify(this.paymentGatewayTempList);
    // }

    console.log("Temp List::::", tempCheckList);

    getParentCaseDetails({
      parentCaseId: this.parentCaseRecordId,
      selectedModes: tempCheckList,
      subjectinformation: this.subjectinfo,
      queueName: this.queueName
    })
      .then((result) => {
        console.log("result:result" + JSON.stringify(result));
        this.showToast(
          "Success",
          "Case(s) created successfully",
          "success",
          "dismissible"
        );
        this.updateRecordView();
        this.dispatchEvent(new CustomEvent("close"));
      })
      .catch((error) => {
        console.log("error: " + JSON.stringify(error));
      });
  }

  handleCloseModal() {
    console.log("close 1");
    this.dispatchEvent(new CustomEvent("close"));
    console.log("close 2");
  }

  handleSave() {
    console.log("checkboxValue:" + this.checkboxValue);
    if (this.checkboxValue.length == 0) {
      console.log("inside is empty");
      this.showToast(
        "Error",
        "Please select atleast one coverage",
        "error",
        "dismissible"
      );
    } else {
      this.getParentCaseDetailsFunc();
    }
  }

  subjectData(event) {
    this.subjectinfo = event.target.value;
  }

  handleCheckboxChange(event) {
    this.selectedChecklist = [];
    this.checkboxValue = [];
    this.selectedChecklist = event.detail.value;
    this.checkboxValue = event.detail.value;

    // this.checkboxValue = event.detail.value;
    // if(event.detail.checked == true){
    //  this.selectedChecklist.push(event.detail.value);
    // }

    console.log("checkboxValue: " + JSON.stringify(this.checkboxValue));
    console.log("selectedChecklist: " + JSON.stringify(this.selectedChecklist));
  }

  handleQueueChange(event) {
    console.log(event.detail.value);
    this.queueName = event.detail.value;
  }

  /*show toast message
    title: toast title
    message: toast message in detail
    variant: success, error, warning
    mode: pester, dismissable, sticky
    */
  showToast(toastTitle, message, variant, mode) {
    console.log("inside toast");
    const event = new ShowToastEvent({
      title: toastTitle,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(event);
  }

  handlePaymentGatewayProduct(event) {
    console.log("Value:::", event.target.dataset.commercialId);
    console.log("Commercial List:::", this.paymentGatewayTempList);
    if (event.target.checked == false) {
      for (let i = 0; i < this.paymentGatewayTempList.length; i++) {
        console.log("Value:::::" + this.paymentGatewayTempList[i].commercialId);
        if (
          this.paymentGatewayTempList[i].commercialId ==
          event.target.dataset.commercialId
        ) {
          console.log("Pass");
          this.paymentGatewayTempList.splice(i, 1);
          break;
        }
      }
    } else {
      let tempCommerical = {
        commercialId: event.target.dataset.commercialId,
        commercialName: event.target.value
      };
      this.paymentGatewayTempList.push(tempCommerical);
    }
    console.log("Value::::", JSON.stringify(this.paymentGatewayTempList));
  }

  updateRecordView() {
    setTimeout(() => {
      eval("$A.get('e.force:refreshView').fire();");
    }, 1000);
  }
}
