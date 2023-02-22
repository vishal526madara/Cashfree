import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getScore from '@salesforce/apex/ScoringController.getScore';

export default class ActivityComponent extends LightningElement {

    @api recordId;
    @track dataWrapper;
    load = false;

    @wire(getRecord, { recordId: '$recordId', fields: ['Id'] })
    getCase({ data, error }) {
        console.log('casrecord => ', data, error);
        if (data) {
            this.oppData();
        } else if (error) {
            console.error('ERROR in Wire => ', JSON.stringify(error)); // handle error properly
        }
    }

    connectedCallback() {
        this.oppData();
    }

    oppData() {
        this.load = false;
        getScore({ recordId: this.recordId })
            .then(result => {
                this.dataWrapper = result;
                this.load = true;
            })
            .catch(error => {
                console.log('error:::' + JSON.stringify(error));
                console.log('error:::' + JSON.stringify(error.message));
            });
    }
}