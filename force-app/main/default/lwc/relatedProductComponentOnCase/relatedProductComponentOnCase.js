import { api, wire, LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import OpportunityProduct from "@salesforce/apex/ProductController.OpportunityProduct";
import opportunityId from "@salesforce/apex/ProductController.opportunityId";
import deleteProduct from "@salesforce/apex/ProductController.deleteProduct";
import FORM_FACTOR from "@salesforce/client/formFactor";
import DesktopView from "./relatedProductComponentOnCase.html";
import MobileView from "./relatedProductComponentOnCaseMobileView.html";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import BANKOPS_FIELD from "@salesforce/schema/Case.Initiate_Bank_Ops__c";
import INITIATEREFRESHBUTTON from "@salesforce/messageChannel/initiateRefresh__c";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import chekTaskStatus from "@salesforce/apex/ProductController.chekTaskStatus";
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";

/**
 * @createdDate: 19 Jan, 2023
 * @updatedBy: Vishal Hembrom
 * @functionality: Check Mid Validation
 */
import checkMerchantId from "@salesforce/apex/ProductController.checkMerchantId";

const fields = [BANKOPS_FIELD];

export default class RelatedProductComponentOnCase extends LightningElement {
  @api recordId;

  @track showInitiateOnBoardButton;
  subscription = null;

  opportunityRecordId;
  childCaseModal = false;

  @track oppProduct;
  recordList = [];
  load = true;
  addProductModel = false;
  editProductModel = false;
  selectedSettlementList = [];
  noProduct = true;
  homepage = true;

  @wire(getRecord, { recordId: "$recordId", fields })
  caseRecord;

  @wire(MessageContext)
  messageContext;

  subscribeForRefresh() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      INITIATEREFRESHBUTTON,
      (message) => {
        this.handleMessage(message);
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleMessage(message) {
    console.log("Function Caledd::::");
    console.log("Handle Message:::", message);
    if (message.showInitiateButton == "Visible") {
      this.showInitiateOnBoardButton = true;
    } else if (message.showInitiateButton == "Not_Visible") {
      this.showInitiateOnBoardButton = "";
    }
  }

  get bankOpsField() {
    return getFieldValue(this.caseRecord.data, BANKOPS_FIELD);
  }

  render() {
    return FORM_FACTOR === "Large" ? DesktopView : MobileView;
  }

  connectedCallback() {
    this.subscribeForRefresh();
    this.getOpportunityId();
  }

  getOpportunityId() {
    opportunityId({ recordId: this.recordId })
      .then((result) => {
        console.log("result: " + result);
        this.opportunityRecordId = result;
        this.getOpportunityData();
      })
      .catch((error) => {
        console.log("error: " + error);
      });
  }

  async getOpportunityData() {
    this.load = true;
    this.noProduct = true;
    await OpportunityProduct({ recordId: this.opportunityRecordId })
      .then((result) => {
        // console.log('result::'+JSON.stringify(result));
        console.log("result", result);
        if (result.OppPro != null) {
          this.oppProduct = result;
          this.oppProduct.OppPro.ProductImage =
            this.oppProduct.OppPro.Product__r.Product_Image__c;
          this.recordList = this.oppProduct.oppModeList.filter((item) => {
            //item.ModeName=item.Mode__r.Name;
            item.nameUrl = "/" + item.Id;
            item.CommPercent =
              item.Commercial__r.Commercials__c == null
                ? 0
                : item.Commercial__r.Commercials__c;
            item.CommPrice =
              item.Commercial__r.Commercial_Price__c == null
                ? 0
                : item.Commercial__r.Commercial_Price__c;
            return item;
          });
          this.oppProduct.settlementList.filter((item) => {
            if (this.oppProduct.settlementIdList.includes(item.Id)) {
              item.check = true;
              item.nameUrl = "/" + item.Id;
              this.selectedSettlementList.push(item);
            }
            item.Commercial_Price__c =
              item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
            item.Commercial__c =
              item.Commercial__c == null ? 0 : item.Commercial__c;
          });
          this.checkButtonVisibility();
        }
        this.load = false;
      })
      .catch((error) => {
        console.log("error", error);
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  checkButtonVisibility() {
    console.log("Button Visibility::::");
    console.log("Product Name:::::", this.oppProduct.OppPro.Name);
    if (this.oppProduct.OppPro.Name == "Payment Gateway") {
      chekTaskStatus({ caseId: this.recordId })
        .then((result) => {
          console.log("Button Result::::" + result);
          if (result == "Pass") {
            this.showInitiateOnBoardButton = true;
          } else {
            this.showInitiateOnBoardButton = false;
          }
        })
        .catch((error) => {
          this.showToastMessage("Error", "Something Went Wrong", "error");
        });
    } else {
      this.showInitiateOnBoardButton = true;
    }
    this.noProduct = false;
  }

  handleAddProduct() {
    this.homepage = false;
    this.addProductModel = true;
  }

  handleEditProduct() {
    this.homepage = false;
    this.editProductModel = true;
  }

  handleCancel() {
    this.addProductModel = false;
    this.editProductModel = false;
    this.homepage = true;
    let aura = window["$" + "A"];
    aura.get("e.force:refreshView").fire();
    this.selectedSettlementList = [];
    this.getOpportunityData();
  }

  //function to show toast events
  showToastMessage(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  showConfirmPopOver = false;
  handleConfirmReset() {
    this.homepage = false;
    this.showConfirmPopOver = true;
  }

  handleCancelReset() {
    this.showConfirmPopOver = false;
    this.homepage = true;
  }

  handleReset() {
    this.load = true;
    deleteProduct({ recordId: this.recordId })
      .then((result) => {
        if (result == "error") {
          this.showToastMessage("Error", "Something went wrong!", "error");
          this.load = false;
          return;
        } else {
          this.showToastMessage(
            "Success",
            "Product Deleted successfully.",
            "success"
          );
          this.showConfirmPopOver = false;
          this.handleCancel();
        }
      })
      .catch((error) => {
        console.log("error", error);
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  /**
   * @updateDate : 19 Jan, 2023
   * @updatedBy: Vishal Hembrom
   * @parameter: NA
   * @function: Iniate Bank Ops Operation (Create Work Order)
   */
  handleInitiateBankOpsOpen() {
    checkMerchantId({ caseId: this.recordId })
      .then((result) => {
        if (result == "Fail") {
          this.showToastMessage(
            "Warning......",
            "Not able to Initiate the Bank Ops,Please Check the MID",
            "warning"
          );
          return;
        }
        this.childCaseModal = true;
        console.log(this.childCaseModal);
      })
      .catch((error) => {
        this.showToastMessage("Error......", error.body.message, "error");
      });
  }

  handleInitiateBankOpsClose() {
    this.childCaseModal = false;
    console.log(this.childCaseModal);
  }
}
