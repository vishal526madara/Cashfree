import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDocumentType from "@salesforce/apex/DocumentManagementControllerNew.getDocumentType";
import folderIcon from "@salesforce/resourceUrl/folderIcon";
import locationRed from "@salesforce/resourceUrl/locationRed";
import locationRedGif from "@salesforce/resourceUrl/locationRedGif";

export default class DocumentManagementComponentNewLevelThree extends LightningElement {
  @api categoryValue;
  @api objectApiName;
  @api categoryId;
  @api recordId;
  @api kycCategoryValue;

  @track locationRed = locationRed;
  @track locationRedGif = locationRedGif;

  @api fileSizeUpload;

  @track folderIcon = folderIcon;
  connectedCallback() {
    this.getDocumentTypeFunction();
  }

  @track documentTypeList = [];
  getDocumentTypeFunction() {
    this.spinnerOn = true;
    getDocumentType({
      categoryId: this.categoryId,
      categoryValue: this.categoryValue,
      kycCategoryValue: this.kycCategoryValue,
      recordId: this.recordId
    })
      .then((result) => {
        console.log("Category Type :: " + result);
        this.documentTypeList = JSON.parse(result);
        console.log(
          "documentTypeList  (Size) :: " + this.documentTypeList.length
        );
        console.log(
          "documentTypeList  :: " + JSON.stringify(this.documentTypeList)
        );
        this.spinnerOn = false;
      })
      .catch((error) => {
        console.log("Error Category Type ::: " + JSON.stringify(error));
        this.toast(
          "Error",
          "Something is wrong, please contact your system administrator",
          "error",
          "pester"
        );
      });
  }

  handleHideDocument(event) {
    console.log(
      "Name Value (handleHideDocument) " + event.target.dataset.docvalue
    );
    console.log(
      "Name Value (handleHideDocument) id " + event.target.dataset.docid
    );
    for (let i = 0; i < this.documentTypeList.length; i++) {
      if (
        this.documentTypeList[i].documentTypeId == event.target.dataset.docid
      ) {
        this.documentTypeList[i].drop = false;
      } else {
        this.documentTypeList[i].drop = false;
      }
    }
  }

  handleShowDocument(event) {
    console.log(
      "Name Value (handleShowDocument) " + event.target.dataset.docvalue
    );
    console.log(
      "Name Value (handleShowDocument) id" + event.target.dataset.docid
    );
    for (let i = 0; i < this.documentTypeList.length; i++) {
      if (
        this.documentTypeList[i].documentTypeId == event.target.dataset.docid
      ) {
        this.documentTypeList[i].drop = true;
      } else {
        this.documentTypeList[i].drop = false;
      }
    }
  }

  handleRefresh(event) {
    console.log("handleRefresh three");
    this.getDocumentTypeFunction();
  }

  handleDispatchEvent(event) {
    console.log("handleDispatchEvent three");
    this.getDocumentTypeFunction();
    //dispatch event
    const eventThree = CustomEvent("eventthree");
    this.dispatchEvent(eventThree);
  }
}
