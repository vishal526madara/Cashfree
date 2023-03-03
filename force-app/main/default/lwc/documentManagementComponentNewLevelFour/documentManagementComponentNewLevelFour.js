/**
 * @description       : 
 * @author            : Saurav Kashyap
 * @group             : SK Group
 * @last modified on  : 28-02-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   19-12-2022   Saurav Kashyap   Initial Version
**/
import { LightningElement, api, track,wire } from 'lwc';
import getDocumentList from '@salesforce/apex/DocumentManagementControllerNew.getDocumentList';
// 
import insert_OR_Method_Callout from '@salesforce/apex/MerchantViewDocumentClass.insert_OR_Method_Callout';
import deleteDocs from '@salesforce/apex/DocumentManagementControllerNew.deleteDocs';
// 
import deleteFile from '@salesforce/apex/DocumentManagementControllerNew.deleteFile';
import createDocument from '@salesforce/apex/DocumentManagementControllerNew.createDocument';
import getFileSize from '@salesforce/apex/DocumentManagementControllerNew.getFileSize';
import getFieldPicklistValue from '@salesforce/apex/DocumentManagementControllerNew.getFieldPicklistValue';
import updateFolder from '@salesforce/apex/DocumentManagementControllerNew.updateFolder';

import uploadmerchant_document from '@salesforce/apex/DocumentManagementControllerNew.uploadmerchant_document';
import getDocSizeChecker from '@salesforce/apex/DocumentManagementControllerNew.getDocSizeChecker';
import checkIfAM from '@salesforce/apex/DocumentManagementControllerNew.checkIfAM';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import DocStatusImage	  from '@salesforce/resourceUrl/DocStatusImage';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';


export default class DocumentManagementComponentNewLevelFour extends NavigationMixin(LightningElement) {
    @api recordId;
    @api documentTypeId;
    @api documentTypeValue;
    @api objectApiName;

    @api kycCategoryValue
    @api categoryValue
    @api categoryId;

    @api fileSizeUpload;

    @track spinnerOn = true;
    @track caseObject = false;
    @track showTemplateBody = false;

    pendingImg = DocStatusImage + '/pending-icon1.png' ;
    rejectedImg = DocStatusImage + '/Rejected-icon.png' ;
    approvedImg = DocStatusImage + '/approved-icon.png' ;
    userId = Id;
    userProfileName;
    get acceptedFormats() {
        return ['.zip', '.png', '.doc', '.pdf', '.jpg', '.jpeg' , '.jfif' , '.pjpeg' , '.pjp' ];
    }

    enableEditOfStatus = false;
    loggedInIsAM = false;

     @wire(getRecord, { recordId: Id, fields: [ ProfileName] })
     userDetails({ error, data }) {
        if (error) { 
            this.error = error;
        } else if (data) {           
            
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }

            console.log('profileName--' + this.userProfileName);  
            if(this.userProfileName == 'Operations - Merchant Onboarding' || this.userProfileName == 'System Administrator')
                this.enableEditOfStatus = true;
            
        }
    }

    // @track spinnerOn2 = true;
    // @track showPreviewBody = false;
    //showTemplateBody
    connectedCallback() {
        this.init();
        this.checkIfLoggedInIsAM();
        
    }

    init(){
        console.log('recordId >>> :: ' + this.recordId);
        if (this.objectApiName == 'Case') {
            this.caseObject = true;
            this.getFieldPicklistValueFunction();
        } else {
            this.caseObject = false;
            this.getDocumentListFunction();
        }
        console.log('fileSizeUpload :: ' + this.fileSizeUpload);
    }


    // handledocfile(event){
    //     console.log('fileSizeUpload  handle:: '+this.documentTextVarTemp);

    // }

    @track fieldPicklistValueList = [];
    getFieldPicklistValueFunction() {
        this.spinnerOn = true;
        getFieldPicklistValue()
            .then(result => {
                console.log('getFieldPicklistValue :: ' + result);
                this.fieldPicklistValueList = result;
                this.getDocumentListFunction();
                this.spinnerOn = false;
                this.showTemplateBody = true;
            })
            .catch(error => {
                console.log('getFieldPicklistValue ::: ' + JSON.stringify(error));
                this.toast('Error', 'Something is wrong During getting Picklist from DB, please contact your system administrator', 'error', 'pester');
            });
    }

    checkIfLoggedInIsAM() {
        checkIfAM({recordId: this.recordId})
            .then(result => {
                console.log('loggedInIsAM :: ' + result);
                this.loggedInIsAM = result;              
            })
            .catch(error => {
                console.log('loggedInIsAM ::: ' + JSON.stringify(error));
                //this.toast('Error', 'Something is wrong During getting Picklist from DB, please contact your system administrator', 'error', 'pester');
            });
    }

    @track documentList = [];
    getDocumentListFunction() {
        this.spinnerOn = true;
        console.log('f1 '+this.documentTypeId+' f2 '+this.documentTypeValue+' f3 '+this.categoryValue+' f4 '+this.kycCategoryValue+' f5 '+this.recordId);
        getDocumentList({
            documentTypeId: this.documentTypeId, documentTypeValue: this.documentTypeValue,
            categoryValue: this.categoryValue, kycCategoryValue: this.kycCategoryValue, recordId: this.recordId
        })
            .then(result => {
                this.spinnerOn = false;
                this.documentList = JSON.parse(result);
                console.log('Document List >>> :: ' + JSON.stringify(this.documentList));
                for(let i=0;i<this.documentList.length;i++){
                    if(this.documentList[i].decisionAction == 'Pending'){
                        this.documentList[i].statusImage = this.pendingImg;
                        this.documentList[i].allowUpload = true;
                    }
                        
                     if(this.documentList[i].decisionAction == 'Rejected'){
                        this.documentList[i].statusImage = this.rejectedImg;
                        this.documentList[i].allowUpload = true;
                     }
                        
                     if(this.documentList[i].decisionAction == 'Approved'){
                         this.documentList[i].statusImage = this.approvedImg;
                         if(this.loggedInIsAM)
                            this.documentList[i].allowUpload = false;
                         else
                            this.documentList[i].allowUpload = true;  

                     }
                              
                }

                console.log('Document Type && Merch ID :: ');
                this.spinnerOn = false;
                this.showTemplateBody = true;
                
            })
            .catch(error => {
                console.log('Error Get Node Type ::: ' + JSON.stringify(error));
                this.toast('Error', 'Something is wrong, please contact your system administrator', 'error', 'pester');
            });
    }

    toast(type, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: type,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    @track image_url;
    @track previewComponent = false;
    @track account_Id;
    @track doctype;
    @track merchId;
    previewFile(event) {
        this.previewComponent =true;
        // this.showTemplateBody = false;
        this.spinnerOn = true;
        console.log('this.previewComponent >> p >> ', this.previewComponent);
        let pid = event.currentTarget.dataset.docid;
        this.account_Id = event.currentTarget.dataset.acc;
        this.doctype = event.currentTarget.dataset.doc;
        this.merchId = event.currentTarget.dataset.merch;
        console.log('pid >> ', pid);
        console.log('this.account_Id  >> ', this.account_Id);
        console.log('this.doctype >> ', this.doctype);
        console.log('this.merchId  >> ', this.merchId);
        // call API
        if (this.account_Id && this.doctype && this.merchId) {
            this.apiCallout();
        }else{
            this.showTemplateBody = true;
            this.spinnerOn = false;
        }
        // call API
        // window.open(this.documentList[pid].preSignedURL,'_blank');
    }
    // updated part ... >>> S-E->
    apiCallout() {
        insert_OR_Method_Callout({ AccountId: this.account_Id, merchantId: this.merchId, docType: this.doctype })
            .then(result => {
                console.log('result.MVDResponseWrapperObj >> ', result.MVDResponseWrapperObj);
                console.log('Result Print :: ', result);
                console.log('presignedURL >> ', result.MVDResponseWrapperObj.data.presignedURL);
                if(result) {
                    this.image_url = result.MVDResponseWrapperObj.data.presignedURL;
                    console.log('this.image_url >> ', this.image_url);
                    this.spinnerOn = this.image_url != null ? false : true;
                    console.log('this.previewComponent >> n >> ', this.previewComponent);
                }
            })
            .catch(error => {
                this.showTemplateBody = true;
                    this.spinnerOn = false;
                console.log('Error Get Node Type ::: ' + JSON.stringify(error));
                this.toast('Error', 'Something is wrong During API Callout, please contact your system administrator', 'error', 'pester');
            });
    }
    // updated part ... >>> S-E->

    //
    // method to close the modal pop-up 
    //previewComponent modal close function
    handleClose() {
        this.previewComponent = false;
        this.updateRecordView();
       
    }
    /**
 * The function is called from the component's controller, and it waits for one second before
 * refreshing the page
 */
    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }
    @track variable;
    recordRefresh(record_Id){
        this.variable = record_Id;
        console.log("<<<  : : :  : : :  >>>  recordRefresh : : :  >>>  this.variable", this.variable);
        //navigation used here
        const eventFour = CustomEvent('uploadfile');
        this.dispatchEvent(eventFour);
        //this.navigateToRecordViewPage(this.variable);
    }
    navigateToRecordViewPage(record_Id) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: record_Id,
                actionName: 'view'
            }
        });
    }
    

    filePreview(event) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: event.currentTarget.dataset.docid
            }
        })
    }

    handleDeleteFile(event) {
        this.spinnerOn = true;
        console.log('Content Document Id Print :: ' + event.currentTarget.dataset.docid);
        console.log('Recor Id Print :: ' + event.currentTarget.dataset.recid);
        this.deleteFileFunction(event.currentTarget.dataset.docid, event.currentTarget.dataset.recid);
    }

    deleteFileFunction(docIdVar, recIdVar) {
        deleteFile({ docId: docIdVar, recId: recIdVar })
            .then(result => {
                console.log('Result Print :: ' + result);
                this.toast('Success', 'File was removed', 'success', 'pester');
                this.getDocumentListFunction();
                //dispatch event
                const eventFour = CustomEvent('deletefile');
                this.dispatchEvent(eventFour);

            })
            .catch(error => {
                console.log('Error Get Node Type ::: ' + JSON.stringify(error));
                this.toast('Error', 'Something is wrong, please contact your system administrator', 'error', 'pester');
            });
    }


    handleUploadFinished(event) {
        this.spinnerOn = true;
        const uploadedFiles = event.detail.files;
        this.storefile = JSON.stringify(uploadedFiles);

        console.log('uploadedFiles::' + uploadedFiles);
        console.log('this.storefile::' + this.storefile);
        console.log('uploadedFiles::' + JSON.stringify(uploadedFiles));
        console.log('event.detail::', event.detail);
        console.log('event.target.name::', event.target.name);
        console.log('uploadedFiles[0].documentId  ::  ', uploadedFiles[0].documentId);
        console.log('uploadedFiles[0].name ::  ', uploadedFiles[0].name);
        console.log('uploadedFiles[0].contentVersionId  ::  ', uploadedFiles[0].contentVersionId);
        console.log('recid :: ' + event.currentTarget.dataset.recid);
        console.log('documenttext :: ' + event.currentTarget.dataset.documenttext);
        console.log('accid :: ' + event.currentTarget.dataset.accid);

        let nameVarTemp = event.target.name;
        let documentIdVarTemp = uploadedFiles[0].documentId;
        let uploadedNameVarTemp = uploadedFiles[0].name;
        let contentVersionIdVarTemp = uploadedFiles[0].contentVersionId;
        let recidVarTemp = event.currentTarget.dataset.recid;
        let documenttextVarTemp = event.currentTarget.dataset.documenttext;
        let accidVarTemp = event.currentTarget.dataset.accid;

        if (this.fileSizeUpload == '' || this.fileSizeUpload == undefined || this.fileSizeUpload == null) {
            this.controlUploadEngine(nameVarTemp, documentIdVarTemp, uploadedNameVarTemp,
                contentVersionIdVarTemp, recidVarTemp, documenttextVarTemp, accidVarTemp);
            if (event.target.dataset.recid == '' || event.target.dataset.recid == undefined) {
                let folderObject = {
                    sObjectType: 'Folder__c',
                    Account__c: event.currentTarget.dataset.accid,
                    Category_Type__c: this.categoryValue,
                    Document__c: event.currentTarget.dataset.documenttext,
                    Document_Type__c: this.documentTypeValue,
                    Node__c: this.kycCategoryValue
                }

                let documentLinkObject = {
                    sObjectType: 'ContentDocumentLink',
                    LinkedEntityId: '',
                    ContentDocumentId: uploadedFiles[0].documentId
                }
                this.createDocumentFunction(documentLinkObject, folderObject, 'No');
            } else {
                let folderObject = {
                    sObjectType: 'Folder__c',
                    Account__c: event.currentTarget.dataset.accid,
                    Category_Type__c: this.categoryValue,
                    Document__c: event.currentTarget.dataset.documenttext,
                    Document_Type__c: this.documentTypeValue,
                    Node__c: this.kycCategoryValue,
                    Id: event.currentTarget.dataset.recid
                }

                let documentLinkObject = {
                    sObjectType: 'ContentDocumentLink',
                    LinkedEntityId: event.currentTarget.dataset.recid,
                    ContentDocumentId: uploadedFiles[0].documentId
                }
                this.createDocumentFunction(documentLinkObject, folderObject, 'Yes');
            }
        } else {
            this.getFileSizeFunction(uploadedFiles[0].documentId, this.fileSizeUpload,
                nameVarTemp, documentIdVarTemp, uploadedNameVarTemp,
                contentVersionIdVarTemp, recidVarTemp, documenttextVarTemp, accidVarTemp);
        }

    }

    getFileSizeFunction(docIdVar, fileSizeInMbVar, nameVarTemp, documentIdVarTemp, uploadedNameVarTemp,
        contentVersionIdVarTemp, recidVarTemp, documenttextVarTemp, accidVarTemp) {
        getFileSize({ docId: docIdVar, fileSizeInMb: fileSizeInMbVar })
            .then(result => {
                if (result == 'Invalid Size') {
                    this.toast('Error', 'Invalid size, file size cannot exceed ' + fileSizeInMbVar + ' MB', 'error', 'pester');
                    this.spinnerOn = false;
                } else {
                    // this.handleuploadfile();
                    this.controlUploadEngine(nameVarTemp, documentIdVarTemp, uploadedNameVarTemp,
                        contentVersionIdVarTemp, recidVarTemp, documenttextVarTemp, accidVarTemp);
                }
            })
            .catch(error => {
                console.log('error (createDocumentFunction) ::' + JSON.stringify(error));
                this.toast('Error', error.body.message, 'error', 'pester');
                this.spinnerOn = false;
            });
    }


    // @track storefile;
    // handleuploadfile(event){  

    //     console.log('this.size:3:'+JSON.stringify(event.target.files));
    //     console.log('this.size:3:'+JSON.stringify(event.target.files[0]));
    //     console.log('this.size:3:'+JSON.stringify(event.target.files));

    //     console.log('this.size:3:'+JSON.stringify(event.target.files[0].size));
    //     console.log('this.file:3:'+JSON.stringify(event.target.files[0].type));
    //     console.log('this.file:3:'+JSON.stringify(event.target.files[0].name));
    //     console.log('this.file:3:'+this.merchantidupload);
    //     console.log('this.file:3:'+this.doctypeupload);

    //     console.log('this.fileSizeUpload:3:'+this.fileSizeUpload);

    //     const filesize =this.fileSizeUpload *1024 *1024;
    //     console.log('this.file:3:::::'+filesize);

    //     this.spinnerOn=true;

    //     // if(event.target.files[0].size < filesize){
    //         this.uploadFile(event.target.files[0].size, event.target.files[0].type,event.target.files[0].name);
    //     // }
    //     // else{
    //         // this.spinnerOn=false;
    //     //     this.toast('Error','You cannot upload file size more than '+this.fileSizeUpload+' MB','error','pester');
    //     // }


    // }

    /*
    @description: Function used ON file upload ,connectively calls the upload file Function ... >>>
    
    */
    @track fileData;
    handleuploadfile(event) {

        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('No. of files uploaded : ' + uploadedFiles.length);
        console.log('uploaded file contents: ' + JSON.stringify(uploadedFiles));

        const filetype = uploadedFiles[0].mimeType;
        console.log("<<<  : : :  : : :  >>>  handleuploadfile : : :  >>>  filetype ", filetype);
        
        const contentVersionId = uploadedFiles[0].contentVersionId;
        console.log("<<<  : : :  : : :  >>>  handleuploadfile : : :  >>>  contentVersionId ", contentVersionId);
        
        const contentBodyId = uploadedFiles[0].contentBodyId;
        console.log("<<<  : : :  : : :  >>>  handleuploadfile : : :  >>>  contentBodyId ", contentBodyId);
        
        const fileName = uploadedFiles[0].name;
        console.log("<<<  : : :  : : :  >>>  handleuploadfile : : :  >>>  fileName ", fileName);
        this.spinnerOn = true;

        //var reader = new FileReader()
        // reader.onload = () => {
        //     var base64 = reader.result.split(',')[1]
        //     this.fileData = {
        //         'filename': file.name,
        //         'base64': base64
        //     }
        //     console.log(this.fileData)
        // }
        // reader.readAsDataURL(file);

        this.getUploadedFileSizeChecker(filetype,contentVersionId,fileName);

        //  this.uploadFile(event.target.files[0].size, event.target.files[0].type,event.target.files[0].name);
    }

    @track data;
    uploadFile(filetype,contentVersionId,fileName) {
        this.spinnerOn = true;
        console.log('inside filetype new function' +filetype);
        console.log('inside contentVersionId new function' + contentVersionId);
        console.log('inside fileName new function' +fileName);

        console.log('inside this.merchantidupload new function' + this.merchantidupload);
        console.log('inside this.doctypeupload new function' + this.doctypeupload);

        // const { base64, filename, recordId } = this.fileData
        // console.log("<<<  : : :  : : :  >>>  uploadFile : : :  >>>  this.fileData", this.fileData);

        uploadmerchant_document({ merchantId: this.merchantidupload, 
                                 contentVId: contentVersionId, 
                                 filetype: filetype,
                                  docType: this.doctypeupload,
                                   filetypename: fileName,
                                   recId : this.recIdVarTemp,
                                   kycCategoryValue : this.kycCategoryValue,
                                   categoryValue : this.categoryValue,
                                   documentTypeValue : this.documentTypeValue,
                                   documentTextVarTemp  : this.documentTextVarTemp })
            .then(result => {
                console.log('Documet Upload Message::::'+ result);
                if (result == 'success') {
                    this.spinnerOn = false;
                    this.toast('Success', 'File uploaded successfully', 'success', 'pester');
                    console.log('Got Result successfully');
                    //New Added ... >>>
                    //this.recordRefresh(this.recordId);
                    this.handledeleteDocs(contentVersionId);
                    this.getDocumentListFunction();
                    this.openUploadSection = false;
                    this.refreshThreeComponent();


                } else {
                    this.spinnerOn = false;
                    this.openUploadSection = false;
                    console.log('failed in upload');
                   // this.recordRefresh(this.recordId);
                    this.toast('Error', result, 'error', 'pester');
                }
            })
            .catch(error => {
                this.spinnerOn = false;
                this.openUploadSection = false;
                //this.recordRefresh(this.recordId);
                console.log('Eroor::::::',error);
                console.log('Error:::::'+ JSON.stringify(error));
                this.toast('Error', 'Something went wrong!', error.body.message, 'pester');
                console.log('error (createDocumentFunction) ::' + JSON.stringify(error));

            });
        }

     refreshThreeComponent(){
         const eventthree = CustomEvent('handlerefresh');
         this.dispatchEvent(eventthree);
         console.log('inside refresh custom event');
        
     }   

    getUploadedFileSizeChecker(filetype,contentVersionId,fileName){
        console.log('f1 '+filetype+' f2 '+contentVersionId+' f3 '+fileName);
        getDocSizeChecker({docId: contentVersionId})
        .then(result => {
            if (result.returnedresult == 'Invalid Size') {
                this.toast('Error', 'Invalid size of '+ result.size +' MB ,'+ ' file size cannot exceed *6* MB', 'error', 'pester');
                this.handledeleteDocs(contentVersionId);
                //this.recordRefresh(this.recordId);
                this.spinnerOn = false;
                this.openUploadSection = false;
            }else{
                this.uploadFile(filetype,contentVersionId,fileName);
                /*setTimeout(() => {
                    console.log('called successfully');
                    
                }, 1000);*/
            }
        })
        .catch(error => {
            console.log('error (createDocumentFunction) ::' + JSON.stringify(error));
            this.toast('Error', error.body.message, 'error', 'pester');
            this.spinnerOn = false;
        });
    }
    handledeleteDocs(ContentVID){
        console.log('contentVersion Id '+ContentVID);
        deleteDocs({contentVersionId: ContentVID})
        .then(result => {
            console.log('file Successfully Removed :: >>>'+result);
        })
        .catch(error => {
            console.log('error (handledeleteDocs) ::' + JSON.stringify(error));
            this.toast('Error', error.body.message, 'error', 'pester');
        });
    }


    /*
        uploadFile(file,filetype,filetypename){
            
            console.log('this.file:3:'+JSON.stringify(file));
            console.log('this.file:3:'+JSON.stringify(filetype));
            // console.log('this.file:3:'+JSON.stringify(this.docType));
    
            const blobfile = new Blob([file], { type : 'plain/text' });
            
            uploadmerchant_document({merchantId : this.merchantidupload, file: file, filetype : filetype , docType : this.doctypeupload, filetypename : filetypename})
            .then(result=>{
                if(result=='success'){
                    this.spinnerOn=false;
                    this.toast('Success','File uploaded successfully','success','pester');
                    console.log('Got Result successfully');
                    
                }else{
                    this.spinnerOn=false;
                    console.log('failed in upload');
                    this.toast('Error','Something went wrong!','error','pester');
                }
            })
            .catch(error=>{
                this.spinnerOn=false;
                this.toast('Error','Something went wrong!','error','pester');
                console.log('error (createDocumentFunction) ::'+JSON.stringify(error));
                
            });
        }
    */
    controlUploadEngine(nameVarTemp, documentIdVarTemp, uploadedNameVarTemp,
        contentVersionIdVarTemp, recidVarTemp, documenttextVarTemp, accidVarTemp) {
        if (recidVarTemp == '' || recidVarTemp == undefined) {
            let folderObject = {
                sObjectType: 'Folder__c',
                Account__c: accidVarTemp,
                Category_Type__c: this.categoryValue,
                Document__c: documenttextVarTemp,
                Document_Type__c: this.documentTypeValue,
                Node__c: this.kycCategoryValue
            }

            let documentLinkObject = {
                sObjectType: 'ContentDocumentLink',
                LinkedEntityId: '',
                ContentDocumentId: documentIdVarTemp
            }
            this.createDocumentFunction(documentLinkObject, folderObject, 'No');
        } else {
            let folderObject = {
                sObjectType: 'Folder__c',
                Account__c: accidVarTemp,
                Category_Type__c: this.categoryValue,
                Document__c: documenttextVarTemp,
                Document_Type__c: this.documentTypeValue,
                Node__c: this.kycCategoryValue,
                Id: recidVarTemp
            }

            let documentLinkObject = {
                sObjectType: 'ContentDocumentLink',
                LinkedEntityId: recidVarTemp,
                ContentDocumentId: documentIdVarTemp
            }
            this.createDocumentFunction(documentLinkObject, folderObject, 'Yes');
        }
    }

    createDocumentFunction(documentLinkObject, folderObjectVar, presentVar) {
        this.spinnerOn = true;
        createDocument({ contentDocumentLinkObject: documentLinkObject, folderObject: folderObjectVar, present: presentVar })
            .then(result => {
                if (result == 'Done') {
                    this.toast('Success', 'File Inserted', 'success', 'pester');
                    this.spinnerOn = false;
                    this.getDocumentListFunction();
                    //dispatch event
                    const eventFour = CustomEvent('uploadfile');
                    this.dispatchEvent(eventFour);
                    this.handleCloseUpload();
                } else {
                    this.toast('Error', 'Something went wrong!', 'error', 'pester');
                    this.spinnerOn = false;
                    this.handleCloseUpload();
                }
            })
            .catch(error => {
                console.log('error (createDocumentFunction) ::' + JSON.stringify(error));
                this.toast('Error', error.body.message, 'error', 'pester');
                this.spinnerOn = false;
            });
    }

    @track openUploadSection = false;

    handleCloseUpload() {
        this.recIdVarTemp = '';
        this.accIdVarTemp = '';
        this.documentTextVarTemp = '';

        this.openUploadSection = false;
    }

    @track recIdVarTemp;
    @track accIdVarTemp;
    @track documentTextVarTemp;
    @track merchantidupload;
    @track doctypeupload;

    handleOpenUpload(event) {


        console.log('documentList :: ??????? ' + JSON.stringify(this.documentList));
        console.log('recid :: ??????? ' + event.currentTarget.dataset.recid);
        console.log('documenttext :: ??????? ' + event.currentTarget.dataset.documenttext);
        
        console.log('accid :: ??????? ' + event.currentTarget.dataset.acc);
        console.log('merchantid :: ??????? ' + event.currentTarget.dataset.merch);
        console.log('doctype :: ??????? ' + event.currentTarget.dataset.doc);

        this.recIdVarTemp = event.currentTarget.dataset.recid;
        this.accIdVarTemp = event.currentTarget.dataset.accid;
        this.documentTextVarTemp = event.currentTarget.dataset.documenttext;
        this.merchantidupload = event.currentTarget.dataset.merch;
        this.doctypeupload = event.currentTarget.dataset.doc;
        if(event.currentTarget.dataset.merch){
            this.openUploadSection = true;
        }else{
            this.openUploadSection = false;
            this.toast('Error', ' MID is Missing', 'error', 'pester');
        }
        
    }

    handleChangeDecision(event) {
        let folderObject = {
            sObjectType: 'Folder__c',
            Id: event.target.dataset.uploadeddocumentparentid,
            Decision__c: event.target.value,
        }
        for (let i = 0; i < this.documentList.length; i++) {
            if (this.documentList[i].masterId == event.target.dataset.masterid) {
                this.documentList[i].decisionAction = event.target.value;

                if(this.documentList[i].decisionAction == 'Pending')
                    this.documentList[i].statusImage = this.pendingImg;
                if(this.documentList[i].decisionAction == 'Rejected')
                    this.documentList[i].statusImage = this.rejectedImg;
                if(this.documentList[i].decisionAction == 'Approved')
                    this.documentList[i].statusImage = this.approvedImg;
            }
        }
        this.updateFolderFunction(folderObject);
    }

    handleChangeComments(event) {
        let folderObject = {
            sObjectType: 'Folder__c',
            Id: event.target.dataset.uploadeddocumentparentid,
            Comments__c: event.target.value,
        }
        for (let i = 0; i < this.documentList.length; i++) {
            if (this.documentList[i].masterId == event.target.dataset.masterid) {
                this.documentList[i].comments = event.target.value;
            }
        }
        this.updateFolderFunction(folderObject);
    }

    updateFolderFunction(folderObjectVar) {
        updateFolder({ folderObject: folderObjectVar })
            .then(result => {
                console.log('Result :: ' + result);
            })
            .catch(error => {
                console.log('error (createDocumentFunction) ::' + JSON.stringify(error));
                this.toast('Error', error.body.message, 'error', 'pester');
                this.spinnerOn = false;
            });
    }
}