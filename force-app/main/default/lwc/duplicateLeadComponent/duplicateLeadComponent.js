import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import getLeadRecords from "@salesforce/apex/LeadDuplicateComponentController.getLeadRecords";

export default class DuplicateLeadComponent extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  // @api objectApiName;
  @track showLeadDuplicate = false;

  @track spinnerOn;
  @track entitiesFound = false;
  @track leadRecordList = [];
  @track entityLength = 0;
  @track error;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: ["Id", "Phone", "MobilePhone", "Phone"]
  })
  getLeadValues({ data, error }) {
    console.log("leadRecord => ", data, error);
    if (data) {
      this.getLead();
    } else if (error) {
      console.error("ERROR in Wire => ", JSON.stringify(error)); // handle error properly
    }
  }

  connectedCallback() {
    console.log(" :: Duplicate Connected Callback :: ");
    console.log(
      " :: Duplicate Connected Callback :: (Record Id) :: " + this.recordId
    );
    this.getLead();
  }

  getLead() {
    console.log(
      " Duplicate Event record id While querying Lead record List>>>    " +
        this.recordId
    );
    getLeadRecords({ recordId: this.recordId })
      .then((result) => {
        console.log("result::", result);
        this.leadRecordList = result;
        console.log(
          "🚀 >>>> Duplicate this.leadRecordList",
          this.leadRecordList
        );
        console.log(
          "🚀 >>>>>Duplicate  this.leadRecordList",
          this.leadRecordList.length
        );
        if (this.leadRecordList.length > 0) {
          this.entitiesFound = true;
          this.entityLength = this.leadRecordList.length;
          this.showLeadDuplicate = true;
        } else {
          this.entitiesFound = false;
          this.showLeadDuplicate = false;
        }
        //  this.showLeadDuplicate = false;
        this.error = undefined;
      })
      .catch((error) => {
        console.log("Error::" + JSON.stringify(error));
        this.showToastMessage(
          "Error in the Duplicate Component",
          error.message,
          "error"
        );
      });
  }

  recordReference(event) {
    var index = event.currentTarget.name;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: index,
        actionName: "view"
      }
    });
  }

  showToastMessage(type, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: type,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }

  // handleListViewNavigation() {
  //     // Navigate to the Accounts object's Recent list view.
  //     this[NavigationMixin.Navigate]({
  //         type: 'standard__objectPage',
  //         attributes: {
  //             objectApiName: 'Lead',
  //             actionName: 'list'
  //         },
  //         state: {
  //             // 'filterName' is a property on 'state'
  //             // and identifies the target list view.
  //             // It may also be an 18 character list view id.
  //             // or by 18 char '00BT0000002TONQMA4'
  //             filterName: 'Recent'
  //         }
  //     });
  // }
  // navigateToRelatedPage(){
  //     this.navigateToRelatedPageNavigationMixin(this.recordId);
  // }

  // navigateToRelatedPageNavigationMixin(clientId){
  //     this[NavigationMixin.Navigate]({
  //         type: 'standard__recordRelationshipPage',
  //         attributes: {
  //             recordId: clientId,
  //             objectApiName: 'Lead',
  //             relationshipApiName: 'Addendums__r',
  //             actionName: 'view'
  //         }
  //     });

  // }

  // handleRecordEdit(event){
  //     this.spinnerOn = true;
  //     this[NavigationMixin.Navigate]({
  //         type: 'standard__recordPage',
  //         attributes: {
  //             recordId: event.target.name,
  //             objectApiName: 'Addendum__c', // objectApiName is optional
  //             actionName: 'edit'
  //         }
  //     });
  //     this.spinnerOn = false;
  // }
}
