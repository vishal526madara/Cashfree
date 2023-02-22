/**
 * @description       : 
 * @author            : Appstrail Developer
 * @group             : 
 * @last modified on  : 28-12-2022
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   28-12-2022   Saurav Kashyap   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCategoryType from '@salesforce/apex/DocumentManagementControllerNew.getCategoryType';
import folderIcon from '@salesforce/resourceUrl/folderIcon';

export default class DocumentManagementComponentNewLevelTwo extends LightningElement {
    @api kycCategoryValue;
    @api objectApiName;
    @track spinnerOn = true;
    @track showTemplateBody = false;
    @api recordId;
    @track folderIcon = folderIcon;


    @api fileSizeUpload;

    connectedCallback(){
        this.getCategoryTypeFunction();
    }

    @track categoryList = [];
    getCategoryTypeFunction(){
        getCategoryType({kycCategoryValue : this.kycCategoryValue, recordId : this.recordId})
        .then(result=>{
            console.log('Category Type :: '+result);
            this.categoryList = JSON.parse(result);
            console.log('Category Type (Size) :: '+this.categoryList.length);
            console.log('Category Type (categoryList)  :: '+JSON.stringify(this.categoryList));
            this.spinnerOn = false;
            this.showTemplateBody = true;
        })
        .catch(error=>{
            console.log('Error Category Type ::: '+JSON.stringify(error));
            this.toast('Error','Something is wrong, please contact your system administrator','error','pester');
        });
    }

    handleHideCategory(event){
        console.log('Name Value (handleHideCategory) '+event.target.dataset.catvalue);
        console.log('Id Value (handleHideCategory) '+event.target.dataset.catid);
        for(let i =0; i<this.categoryList.length; i++){
            if(this.categoryList[i].categoryId == event.target.dataset.catid){
                this.categoryList[i].drop = false;
            }else{
                this.categoryList[i].drop = false;
            }
        }
    }

    handleShowCategory(event){
        console.log('Name Value (handleShowCategory) '+event.target.dataset.catvalue);
        console.log('Id Value (handleShowCategory) '+event.target.dataset.catid);
        for(let i =0; i<this.categoryList.length; i++){
            if(this.categoryList[i].categoryId == event.target.dataset.catid){
                this.categoryList[i].drop = true;
            }else{
                this.categoryList[i].drop = false;
            }
        }
    }

    handleDispatchEvent(){
        console.log('handleDispatchEvent two');
        //dispatch event
        const eventTwo = CustomEvent('eventtwo');
        this.dispatchEvent(eventTwo);
    }
}