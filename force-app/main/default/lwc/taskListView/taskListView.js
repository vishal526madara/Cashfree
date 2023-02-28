import { LightningElement, wire, api, track } from "lwc";
import getTask from "@salesforce/apex/taskListViewController.getTask";
import Id from "@salesforce/user/Id";
import { NavigationMixin } from "lightning/navigation";
export default class TaskListView extends NavigationMixin(LightningElement) {
  @track taskData = [];
  @track taskData2 = [];
  priorityValue;
  statusValue;
  taskTypeValue;
  taskUserId = Id;
  load = false;
  connectedCallback() {
    console.log("taskUserId::" + this.taskUserId);
    this.getTaskFunc();
  }

  get taskpickListValue() {
    return [
      { label: "Call", value: "Call" },
      { label: "Meeting", value: "Meeting" },
      { label: "Other", value: "Other" }
    ];
  }
  get statusPicklistValue() {
    return [
      { label: "Open", value: "Open" },
      { label: "Completed", value: "Completed" }
    ];
  }
  get picklistValues() {
    return [
      { label: "High", value: "High" },
      { label: "Normal", value: "Normal" },
      { label: "Low", value: "Low" }
    ];
  }
  priorityChange(event) {
    this.priorityValue = event.detail;
    console.log("priorityValue::" + this.priorityValue);
    this.taskData = this.taskData2.filter((el) => {
      if (this.priorityValue.includes(el.Priority)) {
        return el;
      }
    });
    console.log("length::" + this.taskData.length);
  }
  statusChange(event) {
    this.statusValue = event.detail;
    console.log("priorityValue::" + this.priorityValue);
    this.taskData = this.taskData2.filter((el) => {
      if (this.statusValue.includes(el.status)) {
        return el;
      }
    });
    console.log("length::" + this.taskData.length);
  }

  taskTypeChange(event) {
    this.taskTypeValue = event.detail;
    console.log("priorityValue::" + this.priorityValue);
    this.taskData = this.taskData2.filter((el) => {
      if (this.taskTypeValue.includes(el.Type)) {
        return el;
      }
    });
    console.log("length::" + this.taskData.length);
  }

  getTaskFunc() {
    this.load = true;
    getTask({
      userId: this.taskUserId
    })
      .then((result) => {
        console.log("getTask result:::" + JSON.stringify(result));
        if (result != null) {
          this.taskData = result;
          this.taskData2 = result;
          this.taskDataLenghnt = this.taskData.length;
          console.log("taskData::", this.taskData);
        }
        this.load = false;
      })
      .catch((error) => {
        this.belowTemplate = false;
        console.log("error::" + JSON.stringify(error));
        this.load = false;
      });
  }
  handleClick(event) {
    const id = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: id,
        actionName: "view"
      }
    });
  }

  handleMultiValueChange(event) {
    this.selectedMultiPicklistValue = event.detail;
    console.log(
      "--selectedMultiPicklistValue--" +
        JSON.stringify(this.selectedMultiPicklistValue)
    );
    console.log(
      "--selectedMultiPicklistValue--",
      this.selectedMultiPicklistValue
    );
  }
}
