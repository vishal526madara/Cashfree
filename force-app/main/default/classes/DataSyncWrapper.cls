/**
 * @description: warpper class, which used for creating json body to perform sync operation  
 *               from salesforce to cashfree db
 * @author: Vishal Hembrom
 * @createdDate: 29 Oct, 2022
 */
public without sharing class DataSyncWrapper {


    // Request Data Sync 
    public class DataRequest{
    public String businessName;
	public String orgType; // sf entity type
	public String merchantType; // sf LOB (Industry)
	public String websiteUrl; // sf website
	public String businessRegisteredName;
	public List<Addresses> addresses;
	public Analytics analytics;
	public String bankAccountNumber; // sf Bank Account Number - Account
	public String bankIFSC; // sf Account IFSC  - Account
	public String bankAccountHolderName;
	public List<ContactUser>  contactList;
	public String merchantEmail;
	public Integer merchantId;
	public Integer partnerId;
	public String merchantPhone; // sf Primary SPOC Mobile - Account
	public String salesManager; //
	public String accountManager;
	public String accountSource;
	public String subLob;

  /*************************************************************************************************
   * @updateDate: 21 March, 2023
   * @author : Vishal Hembrom
   * @description : Adding Of two New Field gstin and cin
   **************************************************************************************************/
  public String gstin;
  public String cin;


     /**
     * JSON Body Example
     * {
        "businessName": "merchant name - SF account name",
        "orgType": "SF entityType",
        "merchantType": "SF LOB",
        "websiteUrl": "SF Website",
        "businessRegisteredName": "SF RegisteredName",
        "addresses": [
            {
            "addressType": "Operating Addresses",
            "address": "SLS",
            "city": "Bangalore",
            "country": "India",
            "pinCode": "800011",
            "state": "Karnatka"
            }
        ],
        "analytics": {
            "fbclid": null,
            "gclid": null,
            "utmCampaign": null,
            "utmContent": null,
            "utmMedium": null,
            "utmSource": null,
            "utmTerm": null,
            "parentAccount": "SF parent account name",
            "bankName": "SF bankName",
            "bankRMName": "SF RM name"
        },
        "bankAccountNumber": "SF Bank Account Number",
        "bankIFSC": "SF Account IFSC",
        "bankAccountHolderName": "SF Account Holder Name",
        "contacts": [],
        "merchantEmail": "SF Primary SPOC Email",
        "merchantId": "SF External Id / MID",
        "partnerId": 23,
        "merchantPhone": "Primary SPOC Mobile",
        "salesManager": "SF Sales Manager emailaddress",
        "accountManager": "SF Account Owner",
        "accountSource": "SF Account Source",
        "subLob": "SF SUB LOB"

        //updateDate : 21 March,2023
         "gstin":"String value",
         "cin":"string value"
        //updateDate : 21 March,2023
        }
     */

    }


    //Data Sync Response
       public class DataResponse{
       public Integer status;
        public String message;
        public String title;
        public String detail;
       /*{ "status": "Success",
        "message": "Data synced successfully"
       }*/
      }

    public class Addresses {
		public String addressType;
		public String address;
		public String city;
		public String country;
		public String pinCode;
		public String state;
	}

	

	

	public class Analytics {
		public String fbclid; 
		public String gclid; 
		public String utmCampaign; 
		public String utmContent; 
		public String utmMedium; 
		public String utmSource; 
		public String utmTerm;
		public String parentAccount;
		public String bankName; //reference Id (Bank Record Object: Lead )  
		public String bankRMName; // Text Field (RM Name)
	}

    public Class ContactUser{
       public String email;
       public String name;
       public String phone;
    }
    
}