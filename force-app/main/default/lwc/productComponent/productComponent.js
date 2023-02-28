import { api, LightningElement, track } from "lwc";
import productData from "@salesforce/apex/ProductController.productData";
import getModesRecord from "@salesforce/apex/ProductController.getModesRecord";
import getCommercialRec from "@salesforce/apex/ProductController.getCommercialRec";
import saveProduct from "@salesforce/apex/ProductController.saveProduct";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FORM_FACTOR from "@salesforce/client/formFactor";
import DesktopView from "./productComponent.html";
import MobileView from "./productMobileView.html";

import paymentGateWayCommercials from "@salesforce/apex/ProductController.paymentGateWayCommercials";

export default class ProductComponent extends LightningElement {
  @track productList = [];
  @api recordId;
  modesList = [];
  @track commercialList = [];
  selectProductIllustration = true;
  selectModeIllustration = true;
  noModes = false;
  modeTitle;
  disableNext = true;
  modesOptions = [];
  trueVariable = true;
  @track screens = {
    productPage: true,
    modePage: false
  };
  load = true;

  @track accordianClass = {
    mode: "slds-accordion__section",
    settle: "slds-accordion__section"
  };
  openAccordian = "slds-accordion__section slds-is-open";
  closeAccordian = "slds-accordion__section";

  @track
  showPaymentProducts = false;
  @track
  activeSectionName = [];
  @track
  paymentGatewayCommercialList = [];

  handleAccordian(event) {
    var name = event.target.name;
    // var value=event.target.value;
    var value = event.currentTarget.dataset.id;
    switch (name) {
      case "modes":
        this.accordianClass.mode =
          value === this.closeAccordian
            ? this.openAccordian
            : this.closeAccordian;
        break;
      case "settle":
        this.accordianClass.settle =
          value === this.closeAccordian
            ? this.openAccordian
            : this.closeAccordian;
        break;
    }
  }

  render() {
    return FORM_FACTOR === "Large" ? DesktopView : MobileView;
  }

  connectedCallback() {
    this.getProducts();
  }

  getProducts() {
    productData()
      .then((result) => {
        this.productList = result.filter((item) => {
          item.check = false;
          return item;
        });
        this.load = false;
      })
      .catch((error) => {
        console.log("error:::" + JSON.stringify(error));
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  navItem = "slds-nav-vertical__item";
  activeNavItem = "slds-nav-vertical__item slds-is-active";
  selectedProduct;
  //on selecting product
  handleProductSelect(event) {
    this.load = true;
    this.selectedProduct = {};
    console.log("Id:::" + event.target.id);
    var productId = event.target.id.split("-");
    this.productList.filter((item) => {
      if (item.Id == productId[0]) {
        this.selectedProduct = {
          Id: item.Id,
          Name: item.Name,
          Product_Image__c: item.Product_Image__c,
          Product__c: item.Id,
          Opportunity__c: this.recordId,
          Settlement_Cycle_Label__c: item.Settlement_Cycle_Label__c,
          Mode_Label__c: item.Mode_Label__c
        };
        this.checkProductStatus();
        item.check = true;
      } else {
        item.check = false;
      }
    });
    getModesRecord({ productId: productId[0] })
      .then((result) => {
        console.log("Wrapper::::", result);
        for (let i = 0; i < result.length; i++) {
          console.log("Wrapper:::" + JSON.stringify(result[i]));
        }
        this.modesOptions = result;
        for (let i = 0; i < this.modesOptions.length; i++) {
          this.activeSectionName.push(this.modesOptions[i].modesList.Name);
        }
        console.log("Section Name:::" + this.activeSectionName);
        console.log("modesOptions::" + JSON.stringify(this.modesOptions));
        this.disableNext = false;
        this.load = false;
      })
      .catch((error) => {
        console.log("error:::" + error);
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  checkProductStatus() {
    if (this.selectedProduct.Name == "Payment Gateway") {
      this.showPaymentProducts = true;
    } else if (this.selectedProduct.Name == "Subscriptions") {
      this.showPaymentProducts = true;
    } else if (this.selectedProduct.Name == "Payment Links") {
      this.showPaymentProducts = true;
    } else if (this.selectedProduct.Name == "Payment Forms") {
      this.showPaymentProducts = true;
    } else if (this.selectedProduct.Name == "Cashgram") {
      this.showPaymentProducts = true;
    } else if (this.selectedProduct.Name == "Soft POS") {
      this.showPaymentProducts = true;
    } else {
      this.showPaymentProducts = false;
    }
    console.log("Product Name:::" + this.selectedProduct.Name);
    console.log("Boolean Value:::" + this.showPaymentProducts);
  }

  modeList = [];
  //on selecting modes
  handleNavigation(event) {
    var name = event.target.name;
    var checked = event.target.checked;
    console.log("Check Or Not::" + checked);
    console.log("name:::" + JSON.stringify(name));
    if (checked) {
      this.modesOptions.settlementList =
        this.modesOptions.settlementList.filter((item) => {
          item.check = false;
          return item;
        });
      // console.log('this.modeList:::'+JSON.stringify(this.modeList));
      this.commercialRecord(name);
    } else {
      console.log("List Data:::", this.commercialList);
      this.commercialList = this.commercialList.filter((item) => {
        return item.Mode__c != name;
      });
      console.log("List Data:::", this.commercialList);
      if (this.commercialList.length == 0) {
        this.selectModeIllustration = true;
      } else {
        this.selectModeIllustration = false;
      }
    }
  }

  handleProductNavigation(event) {
    console.log("Is Checked:::" + event.target.checked);
    console.log("Event Data:::", event.target.dataset.methodId);
    if (event.target.checked) {
      this.paymentGatewayCommercialRecord(event.target.dataset.methodId);
      console.log("List ::::" + JSON.stringify(this.commercialList));
    } else {
      this.commercialList = this.commercialList.filter((item) => {
        return item.Method_Type__c != event.target.dataset.methodId;
      });
      if (this.commercialList.length == 0) {
        this.selectModeIllustration = true;
      } else {
        this.selectModeIllustration = false;
      }
    }
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

  //on next button action
  handleNext() {
    this.load = true;
    this.screens.productPage = false;
    this.screens.modePage = true;
    this.load = false;
  }

  //on back button action
  handleBack() {
    this.load = true;
    this.screens.modePage = false;
    this.screens.productPage = true;
    this.modesList = [];
    this.commercialList = [];
    this.settlementList = [];
    this.saveList = [];
    this.modesOptions.settlementList.filter((item) => {
      item.check = false;
    });
    this.selectModeIllustration = true;
    this.load = false;
  }

  paymentGatewayCommercialRecord(id) {
    paymentGateWayCommercials({ methodTypeId: id }).then((result) => {
      result.filter((item) => {
        console.log("Value:::", item);
        item.modeName = item.Method_Type__r.Mode__r.Name;
        //  item.Method_Type__r.Mode__r.Name+' - '+item.Method_Type__r.Name;
        item.Commercial__c = item.Id;
        item.Commercial_Price__c =
          item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
        item.Commercials__c =
          item.Commercials__c == null ? 0 : item.Commercials__c;
        item.actualPrice =
          item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
        item.actualPricePercent =
          item.Commercials__c == null ? 0 : item.Commercials__c;
        item.Add_On__c = 0;
        let validationOption = [];
        if (item.Bank_Validation__c != null) {
          console.log("Bank Data:::" + item.Bank_Validation__c);
          let bankValidation = item.Bank_Validation__c;
          let bankValidationArray = bankValidation.split(",");
          console.log("Value::::" + JSON.stringify(bankValidationArray));
          for (let i = 0; i < bankValidationArray.length; i++) {
            let tempValidation = {
              label: bankValidationArray[i],
              value: bankValidationArray[i]
            };
            console.log("PickList Value:::", tempValidation);
            validationOption.push(tempValidation);
          }
          item.bankValidationRecord = validationOption;
          item.viewValidation = true;
        } else {
          item.viewValidation = false;
        }
        this.commercialList.push(item);
        return item;
      });
      console.log("List data::::", this.commercialList);
      if (this.commercialList.length == 0) {
        this.selectModeIllustration = true;
      } else {
        this.selectModeIllustration = false;
      }
    });
  }

  commercialRecord(id) {
    getCommercialRec({ modeId: id })
      .then((result) => {
        console.log("Commercial:::" + JSON.stringify(result));
        result.filter((item) => {
          item.modeName = item.Mode__r.Name;
          item.Commercial__c = item.Id;
          item.Commercial_Price__c =
            item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
          item.Commercials__c =
            item.Commercials__c == null ? 0 : item.Commercials__c;
          item.actualPrice =
            item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
          item.actualPricePercent =
            item.Commercials__c == null ? 0 : item.Commercials__c;
          item.Add_On__c = 0;
          this.commercialList.push(item);
          return item;
        });
        // this.commercialList.concat(result);
        if (this.commercialList.length == 0) {
          this.selectModeIllustration = true;
        } else {
          this.selectModeIllustration = false;
        }
      })
      .catch((error) => {
        console.log("error:::" + JSON.stringify(error));
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  @track settlementList = [];
  settlementTotal;
  previousPrice = 0;
  //on settlement selection
  handleSettlement(event) {
    var price =
      event.currentTarget.dataset.id == null
        ? 0
        : event.currentTarget.dataset.id;
    var checked = event.target.checked;
    var name = event.target.name;
    var value = event.target.value;
    console.log("name:::" + name);
    console.log("value:::" + value);
    console.log("price:::" + price);
    if (checked) {
      //this.settlementList=[];
      this.modesOptions.settlementList.filter((item) => {
        if (item.Id == value) {
          this.settlementList.push({
            Name: name,
            Id: item.Id,
            check: true,
            Commercial__c: item.Commercial__c == null ? 0 : item.Commercial__c,
            Commercial_Price__c:
              item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c
          });
        }
      });
      var addOnPrice = 0;
      var addOn = 0;
      this.settlementList.filter((item) => {
        addOnPrice += item.Commercial_Price__c;
        addOn += item.Commercial__c;
      });
      this.settlementTotal = {
        Commercial__c: addOn,
        Commercial_Price__c: addOnPrice
      };
      this.modesOptions.settlementList.filter((item) => {
        if (item.Id == value) {
          item.check = true;
        }
        // else{
        //     item.check=false;
        // }
        return item;
      });
      this.commercialList.filter((item) => {
        item.Add_On__c = this.settlementTotal.Commercial__c;
        item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
        item.actualPricePercent =
          Number(item.Commercials__c) + Number(item.Add_On__c);
        item.actualPrice =
          Number(item.Commercial_Price__c) + Number(item.Add_On_Price__c);
      });
      this.saveList.filter((item) => {
        item.Add_On__c = this.settlementTotal.Commercial__c;
        item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
        item.actualPricePercent =
          Number(item.Commercials__c) + Number(item.Add_On__c);
        item.actualPrice =
          Number(item.Commercial_Price__c) + Number(item.Add_On_Price__c);
        item.Actual_Price_Percent__c =
          Number(item.Commercials__c) + Number(item.Add_On__c);
        item.Actual_Price__c =
          Number(item.Commercial_Price__c) + Number(item.Add_On_Price__c);
      });
    } else {
      this.settlementList = this.settlementList.filter((item) => {
        return item.Id != value;
      });
      var addOnPrice = 0;
      var addOn = 0;
      this.settlementList.filter((item) => {
        addOnPrice += item.Commercial_Price__c;
        addOn += item.Commercial__c;
      });
      this.settlementTotal = {
        Commercial__c: addOn,
        Commercial_Price__c: addOnPrice
      };
      this.commercialList.filter((item) => {
        item.actualPricePercent =
          item.actualPricePercent - this.settlementTotal.Commercial__c;
        item.actualPrice =
          item.actualPrice - this.settlementTotal.Commercial_Price__c;
        item.Add_On__c = addOn;
        item.Add_On_Price__c = addOnPrice;
      });
      this.saveList.filter((item) => {
        item.actualPricePercent =
          item.actualPricePercent - this.settlementTotal.Commercial__c;
        item.Actual_Price_Percent__c =
          item.Actual_Price_Percent__c - this.settlementTotal.Commercial__c;
        item.actualPrice =
          item.actualPrice - this.settlementTotal.Commercial_Price__c;
        item.Actual_Price__c =
          item.Actual_Price__c - this.settlementTotal.Commercial_Price__c;
        item.Add_On__c = addOn;
        item.Add_On_Price__c = addOnPrice;
      });
      // this.settlementTotal=null;
    }
    this.modesOptions.settlementList.filter((item) => {
      if (item.Id == value) {
        item.check = checked;
      }
      return item;
    });
  }

  //on field change
  handleFieldChange(event) {
    var productId = event.currentTarget.dataset.id;
    var fieldName = event.target.name;
    var value = event.target.value;
    switch (fieldName) {
      case "actualPricePercent":
        this.commercialList.filter((item) => {
          if (item.Id == productId) {
            item.actualPricePercent = value;
          }
        });
        this.saveList.filter((item) => {
          if (item.Id == productId) {
            item.actualPricePercent = value;
            item.Actual_Price_Percent__c = value;
          }
        });
        break;
      case "actualPrice":
        this.commercialList.filter((item) => {
          if (item.Id == productId) {
            item.actualPrice = value;
          }
        });
        this.saveList.filter((item) => {
          if (item.Id == productId) {
            item.actualPrice = value;
            item.Actual_Price__c = value;
          }
        });
        break;
      case "addOn":
        this.commercialList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On__c = value;
            item.actualPricePercent =
              Number(item.Commercials__c) + Number(item.Add_On__c);
          }
        });
        this.saveList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On__c = value;
            item.actualPricePercent =
              Number(item.Commercials__c) + Number(item.Add_On__c);
            item.Actual_Price_Percent__c =
              Number(item.Commercials__c) + Number(item.Add_On__c);
          }
        });
        break;
      case "addOnPrice":
        this.commercialList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On_Price__c = value;
            item.actualPrice =
              item.Commercial_Price__c + Number(item.Add_On_Price__c);
          }
        });
        this.saveList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On_Price__c = value;
            item.actualPrice =
              item.Commercial_Price__c + Number(item.Add_On_Price__c);
            item.Actual_Price__c =
              item.Commercial_Price__c + Number(item.Add_On_Price__c);
          }
        });
        break;
    }
    console.log("this.commercialList:::" + JSON.stringify(this.commercialList));
  }

  @track saveList = [];
  //on seleting coverage records
  handleRecordSelect(event) {
    var recId = event.target.name;
    var checked = event.target.checked;
    if (checked) {
      this.commercialList.filter((item) => {
        if (item.Id == recId) {
          item.Actual_Price_Percent__c = item.actualPricePercent;
          item.Actual_Price__c = item.actualPrice;
          this.saveList.push(item);
        }
      });
    } else {
      this.commercialList.filter((item) => {
        return item.Id != recId;
      });
      this.saveList = this.saveList.filter((item) => {
        return item.Id != recId;
      });
    }
  }

  //on save action
  handleSave() {
    this.load = true;
    console.log("selectedproduct::" + JSON.stringify(this.selectedProduct));
    console.log("saveList::" + JSON.stringify(this.saveList));
    console.log("settlementList::" + JSON.stringify(this.settlementList));
    if (this.saveList.length == 0) {
      this.showToastMessage("Error", "Please select a coverage.", "error");
      this.load = false;
      return;
    }
    // if(this.settlementList==null){
    //     this.showToastMessage('Error','Please select a settlement.','error');
    //     this.load=false;
    //     return;
    // }
    this.selectedProduct.Id = null;
    this.saveList.filter((item) => {
      item.Id = null;
      // item.Settlement__c=this.settlementTotal.Id;
    });
    saveProduct({
      productRec: this.selectedProduct,
      oppProList: this.saveList,
      settlementList: this.settlementList
    })
      .then((result) => {
        console.log("result:::" + JSON.stringify(result));
        if (result == "error") {
          this.showToastMessage("Error", "Something went wrong!", "error");
          this.load = false;
          return;
        } else {
          this.showToastMessage(
            "Success",
            "Record created successfully.",
            "success"
          );
          this.handleCancel();
        }
      })
      .catch((error) => {
        console.log("Error::::" + error);
        console.log("error:::" + JSON.stringify(error));
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  //cancel event
  handleCancel() {
    let aura = window["$" + "A"];
    aura.get("e.force:refreshView").fire();
    // const closeQA = new CustomEvent('close');
    // this.dispatchEvent(closeQA);
    const closeQA = new CustomEvent("callpasstoparent");
    this.dispatchEvent(closeQA);
  }

  handleSelectAll(event) {
    var checked = event.target.checked;
    if (checked) {
      this.commercialList.filter((item) => {
        item.Actual_Price_Percent__c = item.actualPricePercent;
        item.Actual_Price__c = item.actualPrice;
        item.check = true;
        this.saveList.push(item);
      });
    } else {
      this.saveList = [];
      this.commercialList.filter((item) => {
        item.Actual_Price_Percent__c = item.actualPricePercent;
        item.Actual_Price__c = item.actualPrice;
        item.check = false;
      });
    }
  }
}
