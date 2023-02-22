import { LightningElement, track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getLeadDetails from '@salesforce/apex/LeadScoringController.getLeadDetails';

export default class LeadScoringComponent extends NavigationMixin(LightningElement) {
    @api recordId;

    @track hasBudget = false;
    @track valueOfProgressRing =0;
    @track discovery = false;
    @track decisionMaker = false;

    @track websitePercentage = 0;
    @track leadSourcePercentage = 0;
    @track campaignTypePercentage = 0;
    @track actionTypePercentage = 0;
    @track campaignSubTypePercentage = 0;

    @track websitePoints = 0;
    @track leadSourcePoints = 0;
    @track campaignTypePoints = 0;
    @track actionTypePoints = 0;
    @track campaignSubTypePoints = 0;

    @track valueOfTotalPoints =0;

    connectedCallback(){
        this.getLead();
    }

    @wire(getRecord, { recordId: '$recordId',  
    fields: [ 'Id', 'Campaign_Sub_type__c','Campaign_Type__c','Action_Type__c','LeadSource','Lead_Type__c',
        'Website']
    })
getLeadValues({ data, error }) {
    console.log('casrecord => ', data, error);
    if (data) {
        this.getLead();
    } else if (error) {
        console.error('ERROR in Wire => ', JSON.stringify(error)); // handle error properly
    }
}
    
    @track leadList =[];
    getLead(){
        console.log(' Current Lead recordId>>>    '+this.recordId);
        getLeadDetails({recordId:this.recordId})
        .then(result => {
         console.log("result from apex::  "+JSON.stringify(result));
         this.leadList = result;
         console.log("this.leadList from apex::  "+JSON.stringify(this.leadList));
         if(this.leadList!=null){
            for(let i=0;i<this.leadList.childWrapperList.length;i++){
                if(this.leadList.childWrapperList[i].field =='Website'){
                    this.websitePercentage =this.leadList.childWrapperList[i].weightage;
                    this.websitePoints=this.leadList.childWrapperList[i].points;
                //}else if(this.leadList.childWrapperList[i].field =='LeadSource'){
                }else if(this.leadList.childWrapperList[i].field =='Lead_Type__c'){
                    this.leadSourcePercentage =this.leadList.childWrapperList[i].weightage;
                    this.leadSourcePoints=this.leadList.childWrapperList[i].points;
                }else if(this.leadList.childWrapperList[i].field =='Action_Type__c'){
                    this.actionTypePercentage =this.leadList.childWrapperList[i].weightage;
                    this.actionTypePoints=this.leadList.childWrapperList[i].points;
                }else if(this.leadList.childWrapperList[i].field =='Campaign_Type__c'){
                    this.campaignTypePercentage =this.leadList.childWrapperList[i].weightage;
                    this.campaignTypePoints=this.leadList.childWrapperList[i].points;
                }else if(this.leadList.childWrapperList[i].field =='Campaign_Sub_type__c'){
                    this.campaignSubTypePercentage =this.leadList.childWrapperList[i].weightage;
                    this.campaignSubTypePoints=this.leadList.childWrapperList[i].points;
                }
            }

            this.valueOfProgressRing =this.leadList.Percentage;
            this.valueOfTotalPoints = this.leadList.totalPoints;
         }

         console.log("this.leadList after conversion  "+JSON.stringify(this.leadList));
         console.log(" this.leadList child's length  "+ this.leadList.childWrapperList.length);
         this.error = undefined;
        })
        .catch(error=>{
            console.log('Error::'+JSON.stringify(error));
            this.showToastMessage('Error in the Duplicate Component',error.message,'error');
        });
    }

    // recordReference(recordId) {
    //     this[NavigationMixin.Navigate]({ 
    //         type: 'standard__recordPage', 
    //         attributes: {  
    //             recordId: recordId, 
    //             actionName: 'view', 
    //         }, 
    //     }); 
    // } 
}