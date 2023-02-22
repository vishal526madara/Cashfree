import { LightningElement, api, track } from 'lwc';
import uploadfileonTask from '@salesforce/apex/OnBoardingController.uploadfileonTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UploadFileOnTaskComponent extends LightningElement {
    @api showuploadModel;
    @api taskid;
    @api deletedocverid;
    @api load;

    // showpreview=false;
    // showupload=false;
    @track passchildtoparent = { closemodel: "false", showpreview: "false", showupload: "true" };

    handleCloseUpload(event) {

        this.showuploadModel = false;
        this.passchildtoparent.showpreview = 'false';
        this.passchildtoparent.showupload = 'true';
        this.closemodel();
    }

    get acceptedFormats() {
        return ['.jpeg', '.png', '.svg', '.gif', 'tiff'];
    }

    contentdata;

    handleuploadfile(event) {

        this.load = true;
        this.showuploadModel = false;
        this.contentdata = event.detail.files[0].documentId;

        uploadfileonTask({ taskid: this.taskid, contentverid: this.contentdata, deletedocverid: this.deletedocverid })
            .then(result => {
                if (result == 'success') {

                    //  this.showpreview=true;
                    this.passchildtoparent.showpreview = 'true';
                    this.passchildtoparent.showupload = 'false';
                    // this.updateRecordView();
                    this.showToastMessage('Success', 'File Uploaded Successfully', 'success');
                    this.closemodel();
                }
                else {
                    console.log('taskid Id::::' + JSON.stringify(result));
                }

            })
            .catch(error => {
                this.passchildtoparent.showpreview = 'false';
                this.passchildtoparent.showupload = 'true';
                this.showToastMessage('Error', error.body.message, 'error');
                console.log('taskid Id::error::' + JSON.stringify(error));
                this.closemodel();
            })

    }
    closemodel() {
        this.load = false;
        const custEvent = new CustomEvent(
            'cancelmodelpop', {
            detail: this.passchildtoparent
        });
        this.dispatchEvent(custEvent);
    }

    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

    //TOAST MESSAGE FUNCTION
    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}