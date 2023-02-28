import { LightningElement, wire, api, track } from "lwc";
import lookUp from "@salesforce/apex/ContactWithPhone.search";
import updatetask from "@salesforce/apex/ContactWithPhone.updateTask";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class CustomLookupComponent extends LightningElement {
  @api objName = "Contact";
  @api iconName = "standard:contact";
  @api filter = "Phone!=null";
  @api searchPlaceholder = "Search";
  @api defaultName = "";
  @api inputLabel;
  @api uniqueId;
  @api disabled;
  @api name;
  @track selectedName;
  @track selectedId;
  @track selectedPhone;
  @track records;
  @track result;
  @track isValueSelected = false;
  @track blurTimeout;
  stopRecursion = false;
  searchTerm;
  @api recordId;
  @track boxClass =
    "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
  @track inputClass = "";

  //metod for Finding contact based on Phone Number
  @wire(lookUp, {
    searchTerm: "$searchTerm",
    myObject: "$objName",
    filter: "$filter"
  })
  wiredRecords({ error, data }) {
    if (data) {
      this.error = undefined;
      this.records = data;
    } else if (error) {
      this.error = error;
      this.records = undefined;
    }
  }

  renderedCallback() {
    if (!this.stopRecursion) this.populateDefault();
  }

  connectedCallback() {
    console.log("objName= " + this.objName);
    console.log("iconName= " + this.iconName);
    console.log("filter= " + this.filter);
    console.log("searchPlaceholder= " + this.searchPlaceholder);
    console.log("defaultName= " + this.defaultName);
  }

  populateDefault() {
    console.log("inside populateDefault" + this.defaultName);
    if (this.defaultName != "") {
      this.selectedPhone = this.defaultName;
      this.stopRecursion = true;
      this.isValueSelected = true;
      if (this.blurTimeout) {
        clearTimeout(this.blurTimeout);
      }
      this.boxClass =
        "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
    }
  }

  handleClick() {
    this.searchTerm = "";
    this.inputClass = "slds-has-focus";
    this.boxClass =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open";
  }

  onBlur() {
    this.blurTimeout = setTimeout(() => {
      this.boxClass =
        "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
    }, 300);
  }

  onSelect(event) {
    let selectedId = event.currentTarget.dataset.id;
    let selectedName = event.currentTarget.dataset.name;
    let selectedPhone = event.currentTarget.dataset.phone;
    console.log("selectedPhone", selectedName);
    let selectedRecord = {
      Id: selectedId,
      Phone: selectedPhone,
      uniqueId: this.uniqueId,
      name: this.name
    };

    console.log("selectedPhone", selectedPhone);
    console.log("recordid", this.recordId);
    const valueSelectedEvent = new CustomEvent("lookupselected", {
      detail: selectedRecord
    });
    this.dispatchEvent(valueSelectedEvent);
    this.isValueSelected = true;
    this.selectedPhone = selectedPhone;
    this.selectedName = selectedName;
    this.selectedId = selectedId;
    if (this.blurTimeout) {
      clearTimeout(this.blurTimeout);
    }
    console.log(" this.selectedId", this.selectedId);
    console.log("this.selectedPhone", this.selectedPhone);
    this.boxClass =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
  }

  @api handleRemovePill() {
    this.isValueSelected = false;
    const noValueSelectedEvent = new CustomEvent("nolookupselected", {
      detail: this.isValueSelected
    });
    this.dispatchEvent(noValueSelectedEvent);
  }

  onChange(event) {
    this.searchTerm = event.target.value;
  }

  handleClickSave() {
    updatetask({
      tid: this.recordId,
      cid: this.selectedId,
      phone: this.selectedPhone
    })
      .then((result) => {
        console.log("Inside Result");
        console.log(result);
        this.result = result;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Contact saved",
            message: "Successfully",
            variant: "success"
          })
        );
        this.updateRecordView();
        const closeQA = new CustomEvent("close");
        this.dispatchEvent(closeQA);
      })
      .catch((error) => {
        console.log(error);
      });
  }

  updateRecordView() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      // eslint-disable-next-line no-eval
      eval("$A.get('e.force:refreshView').fire();");
    }, 1000);
  }

  handleCancel() {
    const closeQA = new CustomEvent("close");
    this.dispatchEvent(closeQA);
  }
}
