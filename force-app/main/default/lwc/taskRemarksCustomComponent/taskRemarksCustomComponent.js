/**
 * @description       :
 * @author            : Saurav Kashyap
 * @group             : Appstrail Developer
 * @last modified on  : 25-01-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   23-01-2023   Saurav Kashyap   Initial Version
 **/
import { LightningElement, track, api } from "lwc";
import getTask from "@salesforce/apex/TaskRemarksCustomController.getTask";
import saveTask from "@salesforce/apex/TaskRemarksCustomController.saveTask";
import deletetaskcomment from "@salesforce/apex/TaskRemarksCustomController.deletetaskcomment";
import updateTask from "@salesforce/apex/TaskRemarksCustomController.updateTask";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class TaskRemarksCustomComponent extends LightningElement {
  // @api toast;
  @api recordId;
  @track load = false;
  @track isModalOpen = false;
  @track taskComments;
  doComments = false;
  @track belowTemplate = false;
  connectedCallback() {
    this.getTaskFunc();
  }

  getTaskFunc() {
    this.load = true;
    getTask({
      recordId: this.recordId
    })
      .then((result) => {
        console.log("getTask result:::" + JSON.stringify(result));
        if (result != null) {
          this.taskComments = result;
          this.taskComments.filter((el) => {
            el.taskEdit = false;
          });
          if (this.taskComments.length > 0) {
            this.doComments = true;
            this.belowTemplate = true;
          } else {
            this.belowTemplate = false;
          }
        }
        this.load = false;
      })
      .catch((error) => {
        this.belowTemplate = false;
        console.log("error::" + JSON.stringify(error));
        this.load = false;
      });
  }

  // handlecomment() {
  //     this.isModalOpen = false;
  //     this.disableButton = false;
  // }

  closeModal() {
    this.isModalOpen = false;
  }

  @track disableButton = true;
  @track newValue = "";
  handlefieldchange(event) {
    this.newValue = event.target.value;
    console.log("newValue:::" + JSON.stringify(this.newValue));
  }

  handleSave() {
    console.log("newValue result:::", this.newValue);
    this.load = true;
    if (this.newValue != "") {
      saveTask({
        recordId: this.recordId,
        newValue: this.newValue
      })
        .then((result) => {
          console.log("saveTask result:::" + JSON.stringify(result));
          if (result == "success") {
            //this.showToastMessage('Success', 'Remarks Has Been Created', 'success','pester');
            this.dispatchEventMethod("Remarks Has Been Created", "success");
            this.getTaskFunc();
            this.closeModal();
            this.newValue = "";
            this.disableButton = true;
            // this.toast();
          }
          this.load = false;
        })
        .catch((error) => {
          this.disableButton = false;
          console.log("error::" + JSON.stringify(error));
          this.load = false;
        });
    } else {
      // this.showToastMessage('Error', 'Please Add Remarks', 'error','pester');
      this.dispatchEventMethod("Please Add Remarks", "error");
      // this.toast();
      this.load = false;
      return;
    }
  }

  dispatchToast() {}

  dispatchEventMethod(messageValue, typeValue) {
    this.dispatchEvent(
      new CustomEvent("dosearch", {
        detail: { message: messageValue, type: typeValue },
        composed: true,
        bubbles: true
      })
    );
  }

  handleTaskEdit(event) {
    var taskId = event.currentTarget.dataset.id;
    console.log("taskId:::" + JSON.stringify(taskId));
    this.taskComments.forEach((item) => {
      if (item.remarkIdWrap == taskId) {
        console.log("inside::");
        item.taskEdit = true;
      } else {
        item.taskEdit = false;
      }
    });
    console.log(" yaha >>> taskComments:::::", this.taskComments);
  }

  handleFieldEdit(event) {
    for (let i = 0; i < this.taskComments.length; i++) {
      if (event.currentTarget.dataset.id == this.taskComments[i].remarkIdWrap) {
        this.taskComments[i].Comment = event.target.value;
      }
    }
  }

  handleTaskCancelEdit(event) {
    var taskId = event.currentTarget.dataset.id;
    console.log("taskId:::::", taskId);
    this.taskComments.filter((item) => {
      if (item.remarkIdWrap == taskId) {
        item.taskEdit = false;
      }
    });
  }

  UpdateSingleTask() {
    this.load = true;
    console.log("taskComments result:::" + JSON.stringify(this.taskComments));
    updateTask({
      recordId: this.recordId,
      datawraplist: this.taskComments
    })
      .then((result) => {
        console.log("updateTask result:::" + JSON.stringify(result));
        if (result == "success") {
          //this.showToastMessage('Success', 'The Remark has been Updated', 'success','pester');
          this.dispatchEventMethod("The Remark has been Updated", "success");
          this.getTaskFunc();
        }
        this.load = false;
      })
      .catch((error) => {
        console.log("error::" + JSON.stringify(error));
        this.load = false;
      });
  }

  handledelete(event) {
    console.log("deleteId:##::");
    var deleteId = event.currentTarget.dataset.id;
    console.log("deleteId:::" + JSON.stringify(deleteId));
    deletetaskcomment({
      taskcommentId: deleteId
    })
      .then((result) => {
        if (result == "success") {
          this.getTaskFunc();
        }
      })
      .catch((error) => {
        console.log("Error:::" + error);
        //this.showToastMessage('Error', 'Error Saving record.', 'error','pester');
        this.dispatchEventMethod("Error Saving record.", "error");
      });
  }

  showToastMessage(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }
}
