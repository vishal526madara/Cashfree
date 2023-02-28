import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import insertWorkOrder from "@salesforce/apex/uploadCSVController.insertWorkOrder";
import getTemplateApiNames from "@salesforce/apex/uploadCSVController.getTemplateApiNames";
import FORM_FACTOR from "@salesforce/client/formFactor";
import DesktopView from "./uploadCSVComponent.html";

export default class UploadCSVComponent extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @track showLoadingSpinner = false;
  @track importButtonDisable = true;
  MAX_FILE_SIZE = 2000000; //Max file size 2.0 MB
  filename;

  render() {
    return FORM_FACTOR === "Large" ? DesktopView : MobileView;
  }

  importcsv(event) {
    if (event.target.files.length > 0) {
      let filesUploaded = event.target.files;
      this.filename = event.target.files[0].name;
      if (filesUploaded.size > this.MAX_FILE_SIZE) {
        this.filename = "File Size is to long to process";
        this.importButtonDisable = true;
      } else {
        this.importButtonDisable = false;
        this.readFiles();
      }
    }
  }

  readFiles() {
    [...this.template.querySelector("lightning-input").files].forEach(
      async (file) => {
        try {
          const result = await this.load(file);
          // Process the CSV here
          this.showLoadingSpinner = false;
          // this.processData(result);
          this.csvJSON(result);
        } catch (e) {
          // handle file load exception
        }
      }
    );
  }

  async load(file) {
    return new Promise((resolve, reject) => {
      this.showLoadingSpinner = true;
      const reader = new FileReader();
      // Read file into memory as UTF-8
      //reader.readAsText(file);
      reader.onload = function () {
        resolve(reader.result);
      };
      reader.onerror = function () {
        reject(reader.error);
      };
      reader.readAsText(file);
    });
  }

  //process CSV input to JSON
  csvJSON(csv) {
    this.data = [];
    let lines = csv.split(/\r\n|\n/);
    let result = [];
    let headers = lines[0].split(",");
    for (let i = 1; i < lines.length - 1; i++) {
      let obj = {};
      let currentline = lines[i].split(",");
      for (let j = 0; j < headers.length; j++) {
        obj[headers[j]] = currentline[j];
      }
      result.push(obj);
    }
    //return result; //JavaScript object
    this.data = result;
  }

  insertRecordsFunction() {
    this.spinnerOn = true;
    console.log("Work Order List:::", this.data);
    insertWorkOrder({ workOrderList: this.data, recordId: this.recordId })
      .then((result) => {
        this.spinnerOn = false;
        //this.showToastMessage('Success','Records Uploaded Successfully','success');
        //this.cancel();
        console.log("Function Call:::");
        this.handleSuccessFire();
        this.navigateToWorkOrderList();
      })
      .catch((error) => {
        console.log("Error::::" + error);
        this.handleErrorFire();
        this.showToastMessage("Error", error.body.fieldErrors, "error");
      });
  }

  @track dataTemplate = [];
  connectedCallback() {
    this.getTemplateApiNamesFunction();
  }

  getTemplateApiNamesFunction() {
    console.log("Function Called:::");
    this.dataTemplate = [];
    getTemplateApiNames()
      .then((result) => {
        this.dataTemplate = JSON.parse(result);
      })
      .catch((error) => {});
  }

  // this method validates the dataTemplate and creates the csv file to download
  downloadCSVFile() {
    let rowEnd = "\n";
    let csvString = "";
    let rowData = new Set();
    rowData = this.dataTemplate;
    // splitting using ','
    csvString += rowData.join(",");
    csvString += rowEnd;
    // Creating anchor element to download
    let downloadElement = document.createElement("a");
    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href =
      "data:text/csv;charset=utf-8," + encodeURI(csvString);
    downloadElement.target = "_self";
    // CSV File Name
    downloadElement.download = "Invoice Import CSV Template.csv";
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click();
  }

  cancel() {
    //     console.log('Cancel :::: ');
    //     let aura = window["$" + "A"];
    // aura.get('e.force:refreshView').fire();
    // const closeQA = new CustomEvent('close');
    // this.dispatchEvent(closeQA);
  }

  //SHOW TOAST EVENT
  showToastMessage(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  navigateToWorkOrderList() {
    console.log("Function Called:::");
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: "006Bg0000007NxZIAU",
        actionName: "view"
      }
    }).then((url) => {
      console.log("Url Value:::" + JSON.stringify(url));
    });
  }

  constructor() {
    super();
    this.addEventListener("sampleresponse", (e) => {
      console.log(e.detail);
    });
  }

  handleErrorFire() {
    this.dispatchEvent(
      new CustomEvent("errormessage", {
        detail: "error"
      })
    );
  }

  handleSuccessFire() {
    this.dispatchEvent(
      new CustomEvent("samplemessage", {
        detail: "Success"
      })
    );
  }
}
