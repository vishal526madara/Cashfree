import { LightningElement, track, api } from "lwc";
import uploadFile from "@salesforce/apex/taskAttachment.uploadFile";
import documentidList from "@salesforce/apex/taskAttachment.queryContentDocument";
import deletetaskfile from "@salesforce/apex/taskAttachment.deleteDocuments";

export default class TaskAttachment extends LightningElement {
  @track isModalOpen = false;
  @track load = false;
  @api recordId;
  fileData;
  doComments = false;
  @track documentId = [];
  connectedCallback() {
    console.log("recordId:::" + this.recordId);
    // this.dispatchEventMethod('File uploaded successfully','success');
    this.getDcocument();
  }
  handlecomment() {
    this.isModalOpen = true;
  }

  getTaskFunc() {
    this.load = true;
  }

  get acceptedFormats() {
    return [".pdf", ".png"];
  }

  openfileUpload(event) {
    const file = event.target.files[0];
    var reader = new FileReader();
    reader.onload = () => {
      var base64 = reader.result.split(",")[1];
      this.fileData = {
        filename: file.name,
        base64: base64,
        recordId: this.recordId
      };
      console.log("fileData::" + JSON.stringify(this.fileData));
      this.handleSaveFile();
    };
    reader.readAsDataURL(file);
  }

  handleSaveFile() {
    const { base64, filename, recordId } = this.fileData;
    uploadFile({ base64, filename, recordId })
      .then((result) => {
        console.log("result::" + JSON.stringify(result));
        this.fileData = null;
        let title = `${filename} uploaded successfully!!`;
        this.dispatchEventMethod("File uploaded successfully", "success");
        this.getDcocument();
      })
      .catch((error) => {
        console.log("uploadFile error::" + JSON.stringify(error));
      });
  }
  handleClick() {
    this.template.querySelector(".fileUpload").click();
  }
  getDcocument() {
    this.load = true;
    documentidList({ recordId: this.recordId })
      .then((result) => {
        console.log(
          "11 getContentDocumentList :: >>>  " + JSON.stringify(result)
        );
        this.documentId = result;
        console.log(
          "11 getContentDocumentList :: >>>  " + JSON.stringify(this.documentId)
        );
        this.documentId = this.documentId.filter((item) => {
          console.log("item >>> ", item);
          if (!item.uniqueId) {
            item.uniqueId = Math.random();
          }
          return item;
        });
        console.log(
          "11 after uniqueId :: >>>  " + JSON.stringify(this.documentId)
        );
        this.doComments = true;
        // this.dispatchEventMethod('File uploaded successfully','success');
        this.load = false;
      })
      .catch((error) => {
        console.log(
          "Error (getContentDocumentList) ::: " + JSON.stringify(error)
        );
        this.toast(
          "Error",
          "Something is wrong, please contact your system administrator",
          "error",
          "pester"
        );
      });
  }

  dispatchToast() {}
  dispatchEventMethod(messageValue, typeValue) {
    console.log("Toast Event::" + messageValue);
    this.dispatchEvent(
      new CustomEvent("dosearch", {
        detail: { message: messageValue, type: typeValue },
        composed: true,
        bubbles: true
      })
    );
  }

  // previewHandler(event){
  //     console.log(event.target.dataset.id)
  //     this[NavigationMixin.Navigate]({
  //         type:'standard__namedPage',
  //         attributes:{
  //             pageName:'filePreview'
  //         },
  //         state:{
  //             selectedRecordId: event.target.dataset.id
  //         }
  //     })
  // }

  redirectToContentDocument(event) {
    // Replace "ContentDocumentId" with the ID of the Content Document you want to redirect to
    var contentId = event.currentTarget.dataset.id;
    window.location.href =
      "/lightning/r/ContentDocument/" + contentId + "/view";
  }

  handledelete(event) {
    console.log("deleteId:##::");
    var deleteId = event.currentTarget.dataset.id;
    console.log("deleteId:::", deleteId);
    deletetaskfile({
      recordId: deleteId
    })
      .then((result) => {
        console.log("delete >>>>>>>>>>>>>:##::");
        if (result == "SUCCESS") {
          this.getDcocument();
        }

        this.dispatchEventMethod("File deleted successfully", "success");
      })

      .catch((error) => {
        console.log("Error:::" + error);
        this.showToastMessage("Error", "Error Saving record.", "error");
      });
  }
}
