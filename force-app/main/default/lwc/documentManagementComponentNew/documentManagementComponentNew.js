/**
 * @description       : 
 * @author            : Appstrail Developer
 * @group             : SK Group
 * @last modified on  : 28-12-2022
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   23-12-2022   Saurav Kashyap   Initial Version
**/
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNodeType from '@salesforce/apex/DocumentManagementControllerNew.getNodeType';
import getAccountId from '@salesforce/apex/DocumentManagementControllerNew.getAccountId';
import getStoredDocuments from '@salesforce/apex/DocumentManagementControllerNew.getStoredDocuments';
import checkIfOppClosedOrNot from '@salesforce/apex/DocumentManagementControllerNew.checkIfOppClosedOrNot';
import getAllSyncedDocs from '@salesforce/apex/DocumentManagementControllerNew.getAllSyncedDocs';


import folderIcon from '@salesforce/resourceUrl/folderIcon';
import pin from '@salesforce/resourceUrl/pin';
import { getRecord } from 'lightning/uiRecordApi';

export default class DocumentManagementComponentNew extends NavigationMixin(LightningElement){
    @api componentHide;

    @track spinnerOn = true;
    @track templateBodyShow = false;
    //templateBodyShow
    @track pin = pin;
    @api objectApiName;
    @api showBoth;
    @api showLeftOnly;
    @api showRightOnly;
    @api fileSizeUpload;
    @api recordId;
    @track folderIcon = folderIcon;
    @track tempList = [];
    @track regularListMap = [];
    @track lobListMap = [];
    @track lobTrue = false;
    @track regularTrue = false;
    @track regularCategory;
    @track lobCategory;

    @wire(getRecord, { recordId: '$recordId', fields: [ 'Id'] })
    getEngagement({ data, error }) {
        console.log('Get Engagement => ', data, error);
        if (data) {
            this.getNodeTypeFunction();
            this.getStoredDocumentsFunction();
        } else if (error) {
            console.error('ERROR in Wire => ', JSON.stringify(error));
        }
    }

    connectedCallback(){
        console.log('this.recordId => ', this.recordId);
        // this.getNodeTypeFunction();
        // this.getStoredDocumentsFunction();
        this.getAllDocumentSync();
    }
    /**
    * @description : Function to call the fetchAlllDocumentAPI
    * @author Saurav Kashyap | 22-12-2022 
    * @param String Opportunity recordId 
    **/
    getAllDocumentSync(){
        getAllSyncedDocs({recordId : this.recordId})
        .then(result=>{
            this.templateBodyShow = true;
            this.spinnerOn = false;
            console.log('getAllSyncedDocs (Success) :: ',result);
        })
        .catch(error=>{
            console.log('getAllSyncedDocs (Error) ::: '+JSON.stringify(error));
            this.toast('Error','Unable to Fetch Document from CF System','error','pester');
        });
    }

    @track kycTypeList = [];

    //get all the stored documents againt the related account record
    getStoredDocumentsFunction(){
        this.regularListMap = [];
        this.lobListMap = [];
        this.lobTrue = false;
        this.regularTrue = false;

        getStoredDocuments({recordId : this.recordId})
        .then(result => {
            console.log('getStoredDocuments: '+JSON.stringify(result));
            // for(var key in conts){
            //     this.mapData.push({value:conts[key], key:key}); //Here we are creating the array to show on UI.
            // }
            if(result.length > 0){
                
                for(let i = 0; i < result.length; i++){
                    this.tempList = [];
                    console.log(result[i]);
                    if(result[i].Node__c == 'Regular'){
                        this.regularTrue = true;
                        this.regularCategory = result[i].Category_Type__c;
                        if(this.regularListMap.length > 0){
                            let flag = 0;
                            this.regularListMap=this.regularListMap.filter(ele =>{
                                if(ele.key == result[i].Document_Type__c){
                                    console.log('ele .value',ele.value);
                                    ele.value.push(result[i].Document__c);
                                    flag = 1;
                                }
                                return ele;
                            });
                            if(flag == 0){
                                this.tempList.push(result[i].Document__c);
                                this.regularListMap.push({key: result[i].Document_Type__c, value: this.tempList});
                            }
                            console.log('regularListMap: '+JSON.stringify(this.regularListMap));

                        }else{
                            console.log('regularListMap: '+JSON.stringify(this.regularListMap));
                            this.tempList.push(result[i].Document__c);
                            this.regularListMap.push({key: result[i].Document_Type__c, value: this.tempList});
                            console.log('regularListMap: '+JSON.stringify(this.regularListMap));
                        }
                        console.log('regularList: '+JSON.stringify(this.regularList));

                    }else if(result[i].Node__c == 'LOB'){
                        this.lobTrue = true;
                        this.lobCategory = result[i].Category_Type__c;
                        if(this.lobListMap.length > 0){
                            let flag = 0;
                            this.lobListMap=this.lobListMap.filter(ele =>{
                                if(ele.key == result[i].Document_Type__c){
                                    console.log('ele .value',ele.value);
                                    ele.value.push(result[i].Document__c);
                                    flag = 1;
                                }
                                return ele;
                            });
                            if(flag == 0){
                                this.tempList.push(result[i].Document__c);
                                this.lobListMap.push({key: result[i].Document_Type__c, value: this.tempList});
                            }
                            console.log('lobListMap: '+JSON.stringify(this.lobListMap));

                        }else{
                            console.log('lobListMap: '+JSON.stringify(this.lobListMap));
                            this.tempList.push(result[i].Document__c);
                            this.lobListMap.push({key: result[i].Document_Type__c, value: this.tempList});
                            console.log('lobListMap: '+JSON.stringify(this.lobListMap));
                        }
                        console.log('lobListMap: '+JSON.stringify(this.lobListMap));
                    }
                }
            }else{
                this.checkIfOppOrNotFunction();
            }
        })
        .catch(error => {
            console.log('Error getStoredDocuments ::: '+JSON.stringify(error));
            this.toast('Error','Something is wrong, please contact your system administrator','error','pester');
        })
    }

    checkIfOppOrNotFunction(){
        checkIfOppClosedOrNot({recordId : this.recordId})
        .then(result=>{
            console.log('checkIfOppOrNotFunction (Success) :: '+result);
            if(result == 'Yes'){
                this.toast('Please Upload Documents','Atleast upload one document to close the opportunity','error','sticky');
            }
        })
        .catch(error=>{
            console.log('checkIfOppOrNotFunction (Error) ::: '+JSON.stringify(error));
            this.toast('Error','Something is wrong, please contact your system administrator','error','pester');
        });
    }

    getNodeTypeFunction(){
        this.spinnerOn = true;
        getNodeType()
        .then(result=>{
            console.log('Get Node Type :: '+result);
            this.kycTypeList = JSON.parse(result);
            console.log('Get Node Type (Size) :: '+this.kycTypeList.length);
            console.log('Get Node Type (kycTypeList)  :: '+JSON.stringify(this.kycTypeList));
            this.spinnerOn = false;
        })
        .catch(error=>{
            console.log('Error Get Node Type ::: '+JSON.stringify(error));
            this.toast('Error','Something is wrong, please contact your system administrator','error','pester');
        });
    }

    handleHideKycCategory(event){
        console.log('Name Value (handleHideKycCategory) '+event.target.dataset.kycvalue);
        for(let i =0; i<this.kycTypeList.length; i++){
            if(this.kycTypeList[i].kycCategoryValue == event.target.dataset.kycvalue){
                this.kycTypeList[i].drop = false;
            }else{
                this.kycTypeList[i].drop = false;
            }
        }
    }

    handleShowKycCategory(event){
        console.log('Name Value (handleShowKycCategory) '+event.target.dataset.kycvalue);
        for(let i =0; i<this.kycTypeList.length; i++){
            if(this.kycTypeList[i].kycCategoryValue == event.target.dataset.kycvalue){
                this.kycTypeList[i].drop = true;
            }else{
                this.kycTypeList[i].drop = false;
            }
        }
    }


    navigateToRelatedPage(result){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: result,
                objectApiName: 'Folder__c',
                relationshipApiName: 'Folders__r',
                actionName: 'view'
            }
        });
    }

    getAccountIdFunction(event){
        getAccountId({recordId : this.recordId})
        .then(result=>{
            this.accountRecordId = result;
            this.navigateToRelatedPage(result);
        })
        .catch(error=>{
            console.log('Error Get Node Type ::: '+JSON.stringify(error));
            this.toast('Error','Something is wrong, please contact your system administrator','error','pester');
        });
    }

    toast(type, message, variant, mode){
        const evt = new ShowToastEvent({
            title: type,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    handleRefreshComponent(){
        //refresh component
        this.getStoredDocumentsFunction();
        console.log('handleRefreshComponent');
    }
}