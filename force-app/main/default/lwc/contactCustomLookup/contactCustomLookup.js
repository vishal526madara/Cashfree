import { LightningElement, wire, api, track } from "lwc";
import lookUp from "@salesforce/apex/ContactCustomLookupController.search";

export default class ContactCustomLookup extends LightningElement {
  @api objName;
  @api iconName;
  @api filter = "";
  @api searchPlaceholder = "Search";
  @api defaultName;
  @api inputLabel;
  @api uniqueId;
  @api disabled;
  @api name;

  @track selectedName;
  @track records;
  @track isValueSelected;
  @track blurTimeout;
  stopRecursion = false;
  searchTerm;
  //css
  @track boxClass =
    "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
  @track inputClass = "";

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
    console.log('Filter Data::::'+ this.filter);
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
      this.selectedName = this.defaultName;
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
    //let selectedName = event.currentTarget.dataset.name;
    let selectedName = event.currentTarget.dataset.phone;
    let selectedRecord = {
      Id: selectedId,
      Name: selectedName,
      uniqueId: this.uniqueId,
      name: this.name
    };
    const valueSelectedEvent = new CustomEvent("lookupselected", {
      detail: selectedRecord
    });
    this.dispatchEvent(valueSelectedEvent);
    this.isValueSelected = true;
    this.selectedName = selectedName;
    if (this.blurTimeout) {
      clearTimeout(this.blurTimeout);
    }
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
}
