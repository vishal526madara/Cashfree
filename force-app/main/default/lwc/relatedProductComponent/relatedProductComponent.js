import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import OpportunityProduct from "@salesforce/apex/ProductController.OpportunityProduct";
import deleteProduct from "@salesforce/apex/ProductController.deleteProduct";
import FORM_FACTOR from "@salesforce/client/formFactor";
import DesktopView from "./relatedProductComponent.html";
import MobileView from "./relatedProductMobileView.html";

/**update date: 15 Nov,2022
 * @description: Lms added to refresh onboarding component
 * @parameter: LMS : deviationRefresh
 */
import { publish, MessageContext } from "lightning/messageService";
import DEVIATION_REFRESH from "@salesforce/messageChannel/deviationRefresh__c";
export default class RelatedProductComponent extends LightningElement {
  @api recordId;
  oppProduct;
  recordList = [];
  load = true;
  addProductModel = false;
  editProductModel = false;
  selectedSettlementList = [];
  noProduct = true;
  homepage = true;

  @wire(MessageContext)
  messageContext;

  handleOnboardingCompoent() {
    const payload = { showDeviationButton: true };
    publish(this.messageContext, DEVIATION_REFRESH, payload);
  }

  render() {
    return FORM_FACTOR === "Large" ? DesktopView : MobileView;
  }

  connectedCallback() {
    this.getOpportunityData();
  }

  getOpportunityData() {
    this.load = true;
    this.noProduct = true;
    OpportunityProduct({ recordId: this.recordId })
      .then((result) => {
        // console.log('result::'+JSON.stringify(result));
        console.log("result::::", result);
        console.log("Resulted Data::::" + JSON.stringify(result));
        if (result.OppPro != null) {
          this.oppProduct = result;
          this.oppProduct.OppPro.ProductImage =
            this.oppProduct.OppPro.Product__r.Product_Image__c;
          this.recordList = this.oppProduct.oppModeList.filter((item) => {
            //console.log('Name::::'+ item.Method_Type__r.Name)
            //item.ModeName=item.Method_Type__r.Name;
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
          this.noProduct = false;
        }
        this.load = false;
      })
      .catch((error) => {
        console.log("error" + error);
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
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
    this.handleOnboardingCompoent();
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
}
