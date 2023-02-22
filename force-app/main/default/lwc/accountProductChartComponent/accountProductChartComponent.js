import { api, LightningElement, track } from 'lwc';
import accountOppProduct from '@salesforce/apex/AccountOpportunityController.accountOppProduct';
import productIcon from '@salesforce/resourceUrl/productIcon';
import gatewayIcon from '@salesforce/resourceUrl/gatewayIcon';
import cashgramIcon from '@salesforce/resourceUrl/cashgramIcon';
import autoCollectIcon from '@salesforce/resourceUrl/autoCollectIcon';
import subscriptionIcon from '@salesforce/resourceUrl/subscriptionIcon';
import b2bPaymentIcon from '@salesforce/resourceUrl/b2bPaymentIcon';
import ndfcGatewayIcon from '@salesforce/resourceUrl/ndfcGatewayIcon';
import educationIcon from '@salesforce/resourceUrl/educationIcon';
export default class AccountProductChartComponent extends LightningElement {

    @api recordId;
    noProduct=true;
    @track oppPro=[];
    productIcon=productIcon;
    load=true;
    noBlurClass='image-style';
    blurClass='image-style blur-effect';
    circleClass='icon-circle icon-circle-blue slds-m-around_xx-small slds-align_absolute-center';
    noCircleClass='icon-circle slds-m-around_xx-small slds-align_absolute-center';

    blueSquare="slds-grid slds-wrap icon-square icon-circle-blue slds-align--absolute-center";
    greySquare="slds-grid slds-wrap icon-square icon-circle-grey slds-align--absolute-center";

    // iconList=[productIcon,gatewayIcon,cashgramIcon,autoCollectIcon,subscriptionIcon,b2bPaymentIcon,
    //             ndfcGatewayIcon,educationIcon];

    iconList=['utility:image','utility:money','utility:screen','utility:moneybag','utility:desktop_and_phone',
                'utility:currency_input','utility:desktop_console'];
    runFirst = false;
    connectedCallback(){
        // this.iconList=[productIcon,gatewayIcon,cashgramIcon,autoCollectIcon];
        this.getOpportunityProduct();
        this.runFirst = true;
    }

    renderedCallback(){
        
        if(this.runFirst){
            for(let opp in this.oppPro){
                console.log('opp->' +JSON.stringify(this.oppPro[opp]));
                console.log('opp.productColor '+ this.oppPro[opp].productColor );
                if(opp.productColor != ''){

                    //console.log(' color -->' + this.template.querySelector(`[data-product="${this.oppPro[opp].productName}"]`));
                    //this.template.querySelector(`[data-product="${this.oppPro[opp].productName}"]`).style  = opp.productColor;
                }
                    
                //this.template.querySelector(".p").style="color:green"

            }
        }
        
    }

    getOpportunityProduct(){
        this.load=true;
        accountOppProduct({recordId:this.recordId})
        .then(result=>{
            console.log('opportunity Pro',result);
            if(result.length==0){
                this.noProduct=true;
            }else{
                var count=0;
                this.oppPro=result.filter(item=>{
                    if(item.checked){
                        item.effect='active-effect';
                        item.class='slds-icon_container slds-icon-custom-custom62 icon-style slds-align_absolute-center active-effect active-background';
                        // item.circleClass=this.circleClass;
                    }else{
                        item.effect='inactive-effect';
                        item.class='slds-icon_container slds-icon-custom-custom62 icon-style slds-align_absolute-center inactive-effect inactive-background';
                        // item.circleClass=this.noCircleClass;
                    }
                    // item.iconUrl=this.iconList[count];
                    
                    item.iconUrl=this.iconList[count];
                    count++;
                    if(count==this.iconList.length){
                        count=0;
                    }
                    return item;
                });
                this.noProduct=false;
            }
            this.load=false;
        })
        .catch(error=>{
            console.log('error',error);
            this.showToastMessage('Error',error.message,'error');
            this.load=false;
        });
    }

}