import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import apexchart from "@salesforce/resourceUrl/apexchart";
import radicaljs from "@salesforce/resourceUrl/radicalbar";
import getScore from '@salesforce/apex/ScoringController.getScore';
import { loadScript } from 'lightning/platformResourceLoader';
export default class ScoreComponent extends LightningElement {

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
                this.loadScriptValue();
                this.load = true;
            })
            .catch(error => {
                console.log('error:::' + JSON.stringify(error));
                console.log('error:::' + JSON.stringify(error.message));
            });
    }

    loadScriptValue() {
        Promise.all([
                loadScript(this, radicaljs),
                loadScript(this, apexchart + '/apexcharts.js'),
            ])
            .then(() => {
                console.log('Called::');
                const indicator = this.template.querySelector(".solutionPenetration");
                indicator.innerHTML = '';
                let radicalObj = new radialIndicator(indicator, {
                    radius: 14,
                    barColor: 'rgb(26 185 255)',
                    barWidth: 3,
                    initValue: 0,
                    minValue: 0,
                    maxValue: 100,
                    format: "##",
                })
                radicalObj.animate(this.dataWrapper.totalScore);
                console.log('Called End::');

            })
            .catch(error => {
                console.log('Error::::' + JSON.stringify(error));
                console.log('Error:::' + error);
            })
    }
}