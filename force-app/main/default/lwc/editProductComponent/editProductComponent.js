import { api, LightningElement, track } from "lwc";
import OpportunityProduct from "@salesforce/apex/ProductController.OpportunityProduct";
import updateProduct from "@salesforce/apex/ProductController.updateProduct";
import getCommercialRec from "@salesforce/apex/ProductController.getCommercialRec";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FORM_FACTOR from "@salesforce/client/formFactor";
import DesktopView from "./editProductComponent.html";
import MobileView from "./editProductMobileView.html";
import getModesRecord from "@salesforce/apex/ProductController.getModesRecord";
import paymentGateWayCommercials from "@salesforce/apex/ProductController.paymentGateWayCommercials";

export default class EditProductComponent extends LightningElement {
  @api recordId;
  noProduct = true;
  @track oppProduct;
  selectedSettlement;
  load = true;
  @track recordList = [];
  deleteList = [];
  selectedSettlementList = [];
  @track accordianClass = {
    mode: "slds-accordion__section",
    settle: "slds-accordion__section"
  };
  openAccordian = "slds-accordion__section slds-is-open";
  closeAccordian = "slds-accordion__section";

  @track
  showEditPaymentGateway = false;

  @track
  paymentGatewayWrapperList = [];

  render() {
    return FORM_FACTOR === "Large" ? DesktopView : MobileView;
  }

  connectedCallback() {
    console.log("Function Called:::");
    this.getOpportunityProduct();
  }

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

  getOpportunityProduct() {
    OpportunityProduct({ recordId: this.recordId })
      .then((result) => {
        console.log("result", result);
        var modeList = [];
        var settleId;
        this.oppProduct = result;
        this.oppProduct.OppPro.ProductImage =
          this.oppProduct.OppPro.Product__r.Product_Image__c;
        this.oppProduct.OppPro.SettlementLabel =
          this.oppProduct.OppPro.Product__r.Settlement_Cycle_Label__c;
        this.oppProduct.OppPro.ModeLabel =
          this.oppProduct.OppPro.Product__r.Mode_Label__c;
        this.recordList = this.oppProduct.oppModeList.filter((item) => {
          console.log("Real Data:::", item);
          if (item.hasOwnProperty("Method_Type__c")) {
            console.log('Condition Passed::');
            if (
              item.Commercial__r.Method_Type__r.Name != null &&
              item.Commercial__r.Method_Type__r.Mode__r.Name != null
            ) {
              item.ModeName =  item.Commercial__r.Method_Type__r.Mode__r.Name;
                // item.Commercial__r.Method_Type__r.Mode__r.Name +
                // " - " +
                // item.Commercial__r.Method_Type__r.Name;
            }
          } else {
            item.ModeName = item.Mode__r.Name;
          }

          item.CommPercent =
            item.Commercial__r.Commercials__c == null
              ? 0
              : item.Commercial__r.Commercials__c;
          item.CommPrice =
            item.Commercial__r.Commercial_Price__c == null
              ? 0
              : item.Commercial__r.Commercial_Price__c;
          item.check = true;
          if (!modeList.includes(item.Mode__c)) {
            modeList.push(item.Mode__c);
          }
          // settleId=item.Settlement__c;
          // this.selectedSettlement={
          //     Id:item.Settlement__c,
          //     Name:item.Settlement__r.Name,
          //     Commercial__c:item.Settlement__r.Commercial__c==null?0:item.Settlement__r.Commercial__c,
          //     check:true
          // }
          return item;
        });
        this.oppProduct.modeListMaster.filter((item) => {
          if (modeList.includes(item.Id)) {
            item.check = true;
          }
        });
        this.oppProduct.settlementList.filter((item) => {
          if (this.oppProduct.settlementIdList.includes(item.Id)) {
            item.check = true;
            this.selectedSettlementList.push(item);
          }
          item.Commercial_Price__c =
            item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
          item.Commercial__c =
            item.Commercial__c == null ? 0 : item.Commercial__c;
        });
        var addOnPrice = 0;
        var addOn = 0;
        this.selectedSettlementList.filter((item) => {
          addOnPrice += item.Commercial_Price__c;
          addOn += item.Commercial__c;
        });
        this.settlementTotal = {
          Commercial__c: addOn,
          Commercial_Price__c: addOnPrice
        };
        if (this.oppProduct) {
          this.noProduct = false;
          this.disableSave = false;
        } else {
          this.noProduct = true;
        }

        //update lined
        //date  05 June, 2022
        if (this.oppProduct.OppPro.Name == "Payment Gateway") {
          this.showEditPaymentGateway = true;
          this.generatePaymentProductWrapper(this.oppProduct.OppPro.Product__c);
        } else if (this.oppProduct.OppPro.Name == "Subscriptions") {
          this.showEditPaymentGateway = true;
          this.generatePaymentProductWrapper(this.oppProduct.OppPro.Product__c);
        } else if (this.oppProduct.OppPro.Name == "Payment Links") {
          this.showEditPaymentGateway = true;
          this.generatePaymentProductWrapper(this.oppProduct.OppPro.Product__c);
        } else if (this.oppProduct.OppPro.Name == "Payment Forms") {
          this.showEditPaymentGateway = true;
          this.generatePaymentProductWrapper(this.oppProduct.OppPro.Product__c);
        } else if (this.oppProduct.OppPro.Name == "Cashgram") {
          this.showEditPaymentGateway = true;
          this.generatePaymentProductWrapper(this.oppProduct.OppPro.Product__c);
        } else if (this.oppProduct.OppPro.Name == "Soft POS") {
          this.showEditPaymentGateway = true;
          this.generatePaymentProductWrapper(this.oppProduct.OppPro.Product__c);
        } else {
          this.showEditPaymentGateway = false;
          this.load = false;
        }
      })
      .catch((error) => {
        console.log("error:::", error);
        // this.showToastMessage('Error',error.message,'error');
        this.load = false;
      });
  }

  generatePaymentProductWrapper(paymentProductId) {
    console.log("Function Called::::" + paymentProductId);
    getModesRecord({ productId: paymentProductId })
      .then((result) => {
        this.paymentGatewayWrapperList = result;
        console.log("Wrapper List:::", this.paymentGatewayWrapperList);
        this.load = false;
      })
      .catch((error) => {
        console.log("Error::::" + error);
      });
  }

  @track
  newList = [];
  handleSelectMode(event) {
    this.load = true;
    var checked = event.target.checked;
    var name = event.target.name;
    getCommercialRec({ modeId: name })
      .then((result) => {
        if (checked) {
          result.filter((item) => {
            console.log("Record:::", item);
            item.ModeName=item.Mode__r.Name;
            item.Commercial__c = item.Id;
            item.CommPrice =
              item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
            item.CommPercent =
              item.Commercials__c == null ? 0 : item.Commercials__c;
            item.Actual_Price_Percent__c =
              item.Commercials__c + Number(this.settlementTotal.Commercial__c);
            item.Actual_Price__c =
              item.Commercial_Price__c +
              Number(this.settlementTotal.Commercial_Price__c);
            item.Opportunity_Product__c = this.oppProduct.OppPro.Id;
            item.Add_On__c = this.settlementTotal.Commercial__c;
            item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
            this.newList.push(item);
            return item;
          });
        } else {
          this.recordList = this.recordList.filter((item) => {
            console.log("Else Function Called:::", item);
            if (item.Mode__c == name) {
              this.deleteList.push(item.Id);
            }
            return item.Mode__c != name;
            // return item.Mode__c!=name;
          });
          this.newList = this.newList.filter((item) => {
            // if(item.Mode__c==name){
            //     item.check=false;
            // }
            return item.Mode__c != name;
          });
        }
        this.oppProduct.modeListMaster.filter((item) => {
          if (item.Id == name) {
            item.check = checked;
          }
          return item;
        });
        console.log("this.newList:::" + JSON.stringify(this.newList));
        console.log("this.deleteList:::" + JSON.stringify(this.deleteList));
        this.load = false;
      })
      .catch((error) => {
        console.log("error:::" + JSON.stringify(error));
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  handlePaymentGatewayMethod(event) {
    this.load = true;
    var checked = event.target.checked;
    var name = event.target.dataset.methodId;
    paymentGateWayCommercials({ methodTypeId: name })
      .then((result) => {
        if (checked) {
          result.filter((item) => {
            let existingData=false;
            for(let i=0; i<this.recordList.length; i++){
                if(item.Method_Type__c == this.recordList[i].Method_Type__c){
                    existingData =true;
                    break;
                }
            }
            console.log("Record:::", item);
            if (item.Method_Type__r.Mode__r.Name != null) {
              item.ModeName =  item.Method_Type__r.Mode__r.Name;
                // item.Method_Type__r.Mode__r.Name +
                // " - " +
                // item.Method_Type__r.Name;
            } else {
              item.ModeName = item.Mode__r.Name;
            }

            item.Commercial__c = item.Id;
            item.CommPrice =
              item.Commercial_Price__c == null ? 0 : item.Commercial_Price__c;
            item.CommPercent =
              item.Commercials__c == null ? 0 : item.Commercials__c;
            item.Actual_Price_Percent__c =
              item.Commercials__c + Number(this.settlementTotal.Commercial__c);
            item.Actual_Price__c =
              item.Commercial_Price__c +
              Number(this.settlementTotal.Commercial_Price__c);
            item.Opportunity_Product__c = this.oppProduct.OppPro.Id;
            item.Add_On__c = this.settlementTotal.Commercial__c;
            item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
            if(existingData == true){
                //do nothing.....
            }
            else{
            this.newList.push(item);
            }
            return item;
          });
        } else {
          this.recordList = this.recordList.filter((item) => {
            console.log("Error:::", item);
            if (item.Method_Type__c == name) {
              this.deleteList.push(item.Id);
            }
            return item.Method_Type__c != name;
            // return item.Mode__c!=name;
          });
          this.newList = this.newList.filter((item) => {
            // if(item.Mode__c==name){
            //     item.check=false;
            // }
            return item.Method_Type__c != name;
          });
        }
        this.oppProduct.modeListMaster.filter((item) => {
          if (item.Id == name) {
            item.check = checked;
          }
          return item;
        });
        console.log('Record List::::',this.recordList);
        console.log('New List::::',this.newList);
        console.log('Delete List::::',this.deleteList);
        this.load = false;
      })
      .catch((error) => {
        console.log("error:::" + JSON.stringify(error));
        this.showToastMessage("Error", error.message, "error");
        this.load = false;
      });
  }

  // paymentGatewayCommercialRecord(id){
  //     paymentGateWayCommercials({methodTypeId : id})
  //     .then(result => {
  //         result.filter(item => {
  //             item.methodName=item.Method_Type__r.Name;
  //             item.Commercial__c=item.Id;
  //             item.Commercial_Price__c=item.Commercial_Price__c==null?0:item.Commercial_Price__c;
  //             item.Commercials__c=item.Commercials__c==null?0:item.Commercials__c;
  //             item.actualPrice=item.Commercial_Price__c==null?0:item.Commercial_Price__c;
  //             item.actualPricePercent=item.Commercials__c==null?0:item.Commercials__c;
  //             item.Add_On__c=0;
  //             this.commercialList.push(item);
  //             return item;
  //         })
  //         if(this.commercialList.length==0){
  //             this.selectModeIllustration=true;
  //         }else{
  //             this.selectModeIllustration=false;
  //         }
  //     })
  //     }

  handleFieldChange(event) {
    var productId = event.currentTarget.dataset.id;
    var fieldName = event.target.name;
    var value = event.target.value;
    switch (fieldName) {
      case "actualPricePercent":
        this.oppProduct.oppModeList.filter((item) => {
          if (item.Id == productId) {
            item.Actual_Price_Percent__c = value;
          }
        });
        this.recordList.filter((item) => {
          if (item.Id == productId) {
            item.Actual_Price_Percent__c = value;
          }
        });
        this.newList.filter((item) => {
          if (item.Id == productId) {
            item.Actual_Price_Percent__c = value;
          }
        });
        break;
      case "actualPrice":
        this.oppProduct.oppModeList.filter((item) => {
          if (item.Id == productId) {
            item.Actual_Price__c = value;
          }
        });
        this.recordList.filter((item) => {
          if (item.Id == productId) {
            item.Actual_Price__c = value;
          }
        });
        this.newList.filter((item) => {
          if (item.Id == productId) {
            item.Actual_Price__c = value;
          }
        });
        break;
      case "addOn":
        this.oppProduct.oppModeList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On__c = value;
            item.Actual_Price_Percent__c = item.CommPercent + Number(value);
          }
        });
        this.recordList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On__c = value;
            item.Actual_Price_Percent__c = item.CommPercent + Number(value);
          }
        });
        this.newList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On__c = value;
            item.Actual_Price_Percent__c = item.CommPercent + Number(value);
          }
        });
        break;
      case "addOnPrice":
        this.oppProduct.oppModeList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On_Price__c = value;
            item.Actual_Price__c = item.CommPrice + Number(value);
          }
        });
        this.recordList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On_Price__c = value;
            item.Actual_Price__c = item.CommPrice + Number(value);
          }
        });
        this.newList.filter((item) => {
          if (item.Id == productId) {
            item.Add_On_Price__c = value;
            item.Actual_Price__c = item.CommPrice + Number(value);
          }
        });
        break;
    }
    console.log(
      "this.oppProduct.oppModeList:::" +
        JSON.stringify(this.oppProduct.oppModeList)
    );
    console.log("this.newList:::" + JSON.stringify(this.newList));
  }

  disableSave = true;
  handleUpdate() {
    this.load = true;
    this.disableSave = true;
    // if(this.selectedSettlementList.length==0){
    //     this.showToastMessage('Error','Please select a settlement.','error');
    //     this.disableSave=false;
    //     this.load=false;
    //     return;
    // }
    var newCount = 0;
    this.newList.filter((item) => {
      if (item.check) {
        newCount++;
        // return item;
      }
    });
    var count = 0;
    this.recordList.filter((item) => {
      if (!item.check) {
        this.deleteList.push(item.Id);
        count++;
      }
    });
    if (this.recordList.length == count && newCount == 0) {
      this.showToastMessage("Error", "Please select a mode.", "error");
      this.disableSave = false;
      this.load = false;
      return;
    }
    this.newList = this.newList.filter((item) => {
      item.Id = null;
      if (item.check) {
        return item;
      }
    });
    console.log("DeleteList:::" + JSON.stringify(this.deleteList));
    console.log("this.newList:::" + JSON.stringify(this.newList));
    console.log("this.recordList:::" + JSON.stringify(this.recordList));
    //this.oppProduct.oppModeList.concat(this.newList);
    updateProduct({
      oppModeList: this.recordList,
      newList: this.newList,
      deleteList: this.deleteList,
      settlementList: this.selectedSettlementList
    })
      .then((result) => {
        console.log("result::" + result);
        if (result == "error") {
          this.showToastMessage("Error", "Something went wrong!", "error");
          this.disableSave = false;
          this.load = false;
          return;
        } else {
          this.showToastMessage(
            "Success",
            "Record Updated successfully.",
            "success"
          );
          this.handleCancel();
        }
      })
      .catch((error) => {
        console.log("error:::" + JSON.stringify(error));
        if(error.body.message.includes('ENTITY_IS_LOCKED')){
        this.showToastMessage("Error", "Record Is In Lock State, Please Contact your Manager or Admin", "error");
        }
        else{
          this.showToastMessage("Error", error.message, "error");
        }
        this.disableSave = false;
        this.load = false;
      });
  }

  @track newList = [];
  handleRecordSelect(event) {
    var recId = event.target.name;
    var checked = event.target.checked;
    if (checked) {
      this.recordList.filter((item) => {
        if (item.Id == recId) {
          item.check = true;
        }
      });
    } else {
      this.recordList.filter((item) => {
        if (item.Id == recId) {
          item.check = false;
        }
      });
    }
    console.log("recordList:::" + JSON.stringify(this.recordList));
    console.log("newlist:::" + JSON.stringify(this.newList));
  }

  handleNewRecordSelect(event) {
    var recId = event.target.name;
    var checked = event.target.checked;
    // if(checked){
    this.newList.filter((item) => {
      if (item.Id == recId) {
        item.check = checked;
      }
    });
    // }else{
    //     this.newList.filter(item=>{
    //         // return item.Id!=recId;
    //         if(item.Id==recId){
    //             item.check=false;
    //         }
    //     });
    // }
    console.log("recordList:::" + JSON.stringify(this.recordList));
    console.log("newlist:::" + JSON.stringify(this.newList));
  }

  handleCancel() {
    let aura = window["$" + "A"];
    aura.get("e.force:refreshView").fire();
    // const closeQA = new CustomEvent('close');
    // this.dispatchEvent(closeQA);
    const closeQA = new CustomEvent("callpasstoparent");
    this.dispatchEvent(closeQA);
  }

  @track settlementList;
  settlementTotal;
  previousPrice = 0;
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
      this.oppProduct.settlementList.filter((item) => {
        if (item.Id == value) {
          this.selectedSettlementList.push({
            Name: item.Name,
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
      this.selectedSettlementList.filter((item) => {
        addOnPrice += item.Commercial_Price__c;
        addOn += item.Commercial__c;
      });
      this.settlementTotal = {
        Commercial__c: addOn,
        Commercial_Price__c: addOnPrice
      };
      this.recordList.filter((item) => {
        item.Add_On__c = this.settlementTotal.Commercial__c;
        item.Actual_Price_Percent__c =
          item.CommPercent + Number(this.settlementTotal.Commercial__c);
        item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
        item.Actual_Price__c =
          item.CommPrice + Number(this.settlementTotal.Commercial_Price__c);
      });
      this.newList.filter((item) => {
        item.Add_On__c = this.settlementTotal.Commercial__c;
        item.Actual_Price_Percent__c =
          item.CommPercent + Number(this.settlementTotal.Commercial__c);
        item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
        item.Actual_Price__c =
          item.CommPrice + Number(this.settlementTotal.Commercial_Price__c);
      });
      // this.saveList.filter(item=>{
      //     item.actualPricePercent=item.Commercials__c+Number(price);
      //     item.Actual_Price_Percent__c=item.Commercials__c+Number(price);
      // });
    } else {
      this.selectedSettlementList = this.selectedSettlementList.filter(
        (item) => {
          return item.Id != value;
        }
      );
      var addOnPrice = 0;
      var addOn = 0;
      this.selectedSettlementList.filter((item) => {
        addOnPrice += item.Commercial_Price__c;
        addOn += item.Commercial__c;
      });
      this.settlementTotal = {
        Commercial__c: addOn,
        Commercial_Price__c: addOnPrice
      };
      this.recordList.filter((item) => {
        item.Add_On__c = this.settlementTotal.Commercial__c;
        item.Actual_Price_Percent__c =
          item.CommPercent + this.settlementTotal.Commercial__c;
        item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
        item.Actual_Price__c =
          item.CommPrice + this.settlementTotal.Commercial_Price__c;
      });
      this.newList.filter((item) => {
        item.Add_On__c = this.settlementTotal.Commercial__c;
        item.Actual_Price_Percent__c =
          item.CommPercent + this.settlementTotal.Commercial__c;
        item.Add_On_Price__c = this.settlementTotal.Commercial_Price__c;
        item.Actual_Price__c =
          item.CommPrice + this.settlementTotal.Commercial_Price__c;
      });
      // this.saveList.filter(item=>{
      //     item.actualPricePercent=item.actualPricePercent-price;
      //     item.Actual_Price_Percent__c=item.Actual_Price_Percent__c+price;
      // });
    }
    this.oppProduct.settlementList.filter((item) => {
      if (item.Id == value) {
        item.check = checked;
      }
      return item;
    });
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

  handleSelectAll(event) {
    var checked = event.target.checked;
    this.recordList.filter((item) => {
      item.check = checked;
    });
    this.newList.filter((item) => {
      item.check = checked;
    });
  }
}