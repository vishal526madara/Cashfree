/**
 * @description       : 
 * @author            :Appstrail Developer
 * @group             : SK Group
 * @last modified on  : 15-02-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   22-12-2022   Saurav Kashyap   Initial Version
**/
public without sharing class DocumentManagementControllerNew {
    /**
    * @description 
    * @author 
    * @return String 
    **/
    @AuraEnabled
    public static String getNodeType(){
        List<Cashfree_Document_Master__c> cashfreeDocumentMasterList = [SELECT Id, Name, KYC_Category__c 
        FROM Cashfree_Document_Master__c WHERE KYC_Category__c != null];
        Set<String> kycCategorySet = new Set<String>();
        for(Cashfree_Document_Master__c cashfreeDocumentMasterVar : cashfreeDocumentMasterList){
            kycCategorySet.add(cashfreeDocumentMasterVar.KYC_Category__c);
        }
        List<KycCategoryWrapper> kycCategoryWrapperList = new List<KycCategoryWrapper>();
        for(String kycCategoryVar : kycCategorySet){
            KycCategoryWrapper kycCategoryWrapperObject = new KycCategoryWrapper();
            kycCategoryWrapperObject.kycCategoryValue = kycCategoryVar;
            kycCategoryWrapperObject.drop = false;
            kycCategoryWrapperList.add(kycCategoryWrapperObject);
        }
        return JSON.serialize(kycCategoryWrapperList);
    }

    public class KycCategoryWrapper{
        @AuraEnabled public String kycCategoryValue;
        @AuraEnabled public Boolean drop;
    }

    /**
    * @description 
    * @author 
    * @param String kycCategoryValue 
    * @param String recordId 
    * @return String 
    **/
    @AuraEnabled
    public static String getCategoryType(String kycCategoryValue, String recordId){
        String categoryHolder = '';
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id =: recordId];
            List<Account> accList = [SELECT Id, Name, Ownership, Industry, Sub_Lob__c FROM Account WHERE Id =: oppList[0].AccountId];
            categoryHolder = kycCategoryValue == 'Regular' ? accList[0].Ownership: accList[0].Sub_Lob__c;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Account'){
            List<Account> accList = [SELECT Id, Name, Ownership, Industry, Sub_Lob__c FROM Account WHERE Id =: recordId];
            categoryHolder = kycCategoryValue == 'Regular' ? accList[0].Ownership: accList[0].Sub_Lob__c;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Case'){
            List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE Id =: recordId];
            List<Account> accList = [SELECT Id, Name, Ownership, Industry, Sub_Lob__c FROM Account WHERE Id =: caseList[0].AccountId];
            categoryHolder = kycCategoryValue == 'Regular' ? accList[0].Ownership: accList[0].Sub_Lob__c;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='WorkOrder'){
            List<WorkOrder> workOrderList = [SELECT Id, AccountId FROM WorkOrder WHERE Id =: recordId];
            List<Account> accList = [SELECT Id, Name, Ownership, Industry, Sub_Lob__c FROM Account WHERE Id =: workOrderList[0].AccountId];
            categoryHolder = kycCategoryValue == 'Regular' ? accList[0].Ownership: accList[0].Sub_Lob__c;
        }
        List<Cashfree_Document_Master__c> cashfreeDocumentMasterList = [SELECT Id, Name, KYC_Category__c 
        FROM Cashfree_Document_Master__c WHERE KYC_Category__c =: kycCategoryValue AND Name =: categoryHolder];
       // system.debug('kycCategoryValue>>'+kycCategoryValue);
       // system.debug('categoryHolder>>'+categoryHolder);
       // system.debug('cashfreeDocumentMasterList>>'+cashfreeDocumentMasterList);
        //Set<String> categorySet = new Set<String>();
        //for(Cashfree_Document_Master__c cashfreeDocumentMasterVar : cashfreeDocumentMasterList){
            //categorySet.add(cashfreeDocumentMasterVar.Name);
        //}
        List<CategoryWrapper> categoryWrapperList = new List<CategoryWrapper>();
        for(Cashfree_Document_Master__c cashfreeDocumentMasterVar : cashfreeDocumentMasterList){
            CategoryWrapper categoryWrapperObject = new CategoryWrapper();
            categoryWrapperObject.categoryId = cashfreeDocumentMasterVar.Id;
            categoryWrapperObject.categoryValue = cashfreeDocumentMasterVar.Name;
            //categoryWrapperObject.drop = false;
            categoryWrapperObject.drop = true;
            categoryWrapperList.add(categoryWrapperObject);
        }
        return JSON.serialize(categoryWrapperList);
    }

    public class CategoryWrapper{
        @AuraEnabled public String categoryId;
        @AuraEnabled public String categoryValue;
        @AuraEnabled public Boolean drop;
    }



    @AuraEnabled
    public static String getDocumentType(String categoryId, String categoryValue, 
        String kycCategoryValue, String recordId){
        List<Document_Type__c> documentTypeList = [SELECT Id, Name, Cashfree_Document_Master__c,
        Cashfree_Document_Master__r.Name FROM Document_Type__c WHERE Cashfree_Document_Master__c =: categoryId ORDER By Document_type_Order__c];

        Set<String> documentTypeValueSet = new Set<String>();
        for(Document_Type__c documentTypeVar : documentTypeList){
            documentTypeValueSet.add(documentTypeVar.Name);
        }

        String accountId;
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id =: recordId];
            accountId = oppList[0].AccountId;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Account'){
            accountId = recordId;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Case'){
            List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE Id =: recordId];
            accountId = caseList[0].AccountId;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='WorkOrder'){
            List<WorkOrder> workOrderList = [SELECT Id, AccountId FROM WorkOrder WHERE Id =: recordId];
            accountId = workOrderList[0].AccountId;
        }
        system.debug('accountId>>'+accountId);
        system.debug('kycCategoryValue>>'+kycCategoryValue);
        system.debug('categoryValue>>'+categoryValue);
        system.debug('documentTypeValueSet>>'+documentTypeValueSet);

        Map<Id, Folder__c> folderMap = new Map<Id, Folder__c>([SELECT Id, Name, Account__c, 
        Category_Type__c, Document__c, Document_Type__c, Node__c, CreatedDate, Comments__c, Decision__c 
        FROM Folder__c WHERE Account__c =: accountId AND Node__c =: kycCategoryValue AND 
        Category_Type__c =: categoryValue AND Document_Type__c =: documentTypeValueSet AND Document__c!= null]);
		system.debug('folderMap>>'+folderMap);
        
        Map<String, List<Folder__c>> documentTypeVsfolderListMap = new  Map<String, List<Folder__c>>();
          
        for(Folder__c folderVar : folderMap.values()){
            system.debug('docment>>>>>>'+documentTypeVsfolderListMap.containsKey(folderVar.Document_Type__c));
            if(documentTypeVsfolderListMap.containsKey(folderVar.Document_Type__c)){
                List<Folder__c> existedList = documentTypeVsfolderListMap.get(folderVar.Document_Type__c);
                existedList.add(folderVar);
                documentTypeVsfolderListMap.put(folderVar.Document_Type__c, existedList);
			}
			else{
                List<Folder__c> sampleList = new List<Folder__c>();
                sampleList.add(folderVar);
                documentTypeVsfolderListMap.put(folderVar.Document_Type__c,sampleList);
			}
        }

        
        List<DocumentTypeWrapper> documentTypeWrapperList = new List<DocumentTypeWrapper>();
        for(Document_Type__c documentTypeVar : documentTypeList){
            DocumentTypeWrapper documentTypeWrapperObject = new DocumentTypeWrapper();
            documentTypeWrapperObject.documentTypeId = documentTypeVar.Id;
            documentTypeWrapperObject.documentTypeValue = documentTypeVar.Name;
            documentTypeWrapperObject.drop = false;
            documentTypeWrapperObject.containsFile = documentTypeVsfolderListMap.containsKey(documentTypeVar.Name) ? true: false;
            
            documentTypeWrapperList.add(documentTypeWrapperObject);
        }
        return JSON.serialize(documentTypeWrapperList);
    }

    @AuraEnabled
    public static String deleteFile(String docId, String recId){
        delete [SELECT Id FROM ContentDocument WHERE Id =: docId];
        delete [SELECT Id FROM Folder__c WHERE Id =: recId];
        return 'Done';
    }

    public class DocumentTypeWrapper{
        @AuraEnabled public String documentTypeId;
        @AuraEnabled public String documentTypeValue;
        @AuraEnabled public Boolean drop;
        @AuraEnabled public Boolean containsFile;
    }
    // document Query function ... >>>
    @AuraEnabled
    public static String getDocumentList(String documentTypeId, String documentTypeValue, 
        String categoryValue, String kycCategoryValue, String recordId){
        List<DocumentWrapper> documentWrapperList = new List<DocumentWrapper>();
        String accountId;
        
        // updated part ... >>> S-E->
            String merchantId;
        // updated part ... >>> S-E->
        
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id =: recordId];
            accountId = oppList[0].AccountId;
            merchantId = [SELECT Id, MID__c FROM Account WHERE Id =: accountId ].MID__c;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Account'){
            accountId = recordId;
            merchantId = [SELECT Id, MID__c FROM Account WHERE Id =: accountId ].MID__c;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Case'){
            List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE Id =: recordId];
            accountId = caseList[0].AccountId;
            merchantId = [SELECT Id, MID__c FROM Account WHERE Id =: accountId ].MID__c;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='WorkOrder'){
            List<WorkOrder> workOrderList = [SELECT Id, AccountId FROM WorkOrder WHERE Id =: recordId];
            accountId = workOrderList[0].AccountId;
            merchantId = [SELECT Id, MID__c FROM Account WHERE Id =: accountId ].MID__c;
        }
		system.debug('accountId>>'+accountId);
        system.debug('merchantId>>'+merchantId);
        system.debug('kycCategoryValue>>'+kycCategoryValue);
        system.debug('categoryValue>>'+categoryValue);
        system.debug('documentTypeValue>>'+documentTypeValue);

        // updated part ... >>> S-E->
            Map<Id, Folder__c> folderMap = new Map<Id, Folder__c>([SELECT Id, Name, Account__c,Pre_Signed_URL__c,
                                                                    External_Doc_Type__c,Category_Type__c, Document__c, 
                                                                    Document_Type__c, Node__c, CreatedDate, 
                                                                    Comments__c, Decision__c 
                                                                    FROM Folder__c 
                                                                    WHERE Account__c =: accountId 
                                                                    AND Node__c =: kycCategoryValue 
                                                                    AND Category_Type__c =: categoryValue 
                                                                    AND Document_Type__c =: documentTypeValue 
                                                                    AND Document__c!= null]);
            system.debug('folderMap>>'+folderMap);
        // updated part ... >>> S-E->
        
        Map<String, Folder__c> documentNameVsFolder = new Map<String, Folder__c>();

        Map<String, ContentDocumentLink> folderIdVsContentDocumentLink = new Map<String, ContentDocumentLink>();

        if(folderMap.size()>0){
            for(Folder__c folderVar : folderMap.values()){
                documentNameVsFolder.put(folderVar.Document__c, folderVar);
            }
            system.debug('documentNameVsFolder>>'+documentNameVsFolder);
            //SELECT ContentDocumentId, Id, CreatedDate, FileType, ContentSize FROM ContentVersion
            /*List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id, LinkedEntityId, 
            ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: folderMap.keySet()];
            for(ContentDocumentLink contentDocumentLinkVar : contentDocumentLinkList){
                folderIdVsContentDocumentLink.put(contentDocumentLinkVar.LinkedEntityId, contentDocumentLinkVar);
            }*/
        }
        
        List<Document_List__c> documentList = [SELECT Id, Name, Document_Type__c,External_Doc_Type__c FROM 
        Document_List__c WHERE Document_Type__c=: documentTypeId];
        system.debug('documentList>>'+documentList);

        for(Document_List__c documentListVar : documentList){
            DocumentWrapper documentWrapperObject = new DocumentWrapper();
            documentWrapperObject.accId = accountId;
            documentWrapperObject.masterId = documentListVar.Id;
            documentWrapperObject.documentText = documentListVar.Name;
            documentWrapperObject.createdDate = '--';
            // updated part ... >>> S-E->
            documentWrapperObject.merchId = merchantId;
            documentWrapperObject.doctype = documentListVar.External_Doc_Type__c;
            documentWrapperObject.decisionAction = 'Pending';
            // updated part ... >>> S-E->
            if(documentNameVsFolder.size()>0){
                system.debug('called 1::');
                if(documentNameVsFolder.containsKey(documentListVar.Name)){
                    system.debug('called 2::');
                    Folder__c folderObject = new Folder__c ();
                    folderObject = documentNameVsFolder.get(documentListVar.Name);
                    system.debug('called 3::');
                    system.debug('called 3::'+folderObject);
                    documentWrapperObject.uploadedDocumentParentId = folderObject.Id;
                    documentWrapperObject.uploadedDocumentParentIdInverse = null;
                    documentWrapperObject.createdDate = folderObject.CreatedDate.format();
                    documentWrapperObject.comments = folderObject.Comments__c;
                    documentWrapperObject.decisionAction = folderObject.Decision__c;
                    // updated part ... >>> S-E->
                        documentWrapperObject.uploadedDocumentId = folderObject.Id;//temporary Adjustment.....>>>>
                        documentWrapperObject.preSignedURL = folderObject.Pre_Signed_URL__c;
                    // updated part ... >>> S-E->
                    documentWrapperObject.uploadedBoolean = true;
                    /*if(folderIdVsContentDocumentLink.size()>0){
                        if(folderIdVsContentDocumentLink.containsKey(folderObject.Id)){
                            ContentDocumentLink contentDocumentLinkObject = new ContentDocumentLink();
                            contentDocumentLinkObject = folderIdVsContentDocumentLink.get(folderObject.Id);
                            documentWrapperObject.uploadedDocumentId = contentDocumentLinkObject.ContentDocumentId;
                        }
                    }*/
                }
            }
            documentWrapperList.add(documentWrapperObject);
        }

        return JSON.serialize(documentWrapperList);
    }

    @AuraEnabled
    public static string createDocument(ContentDocumentLink contentDocumentLinkObject, Folder__c folderObject, String present){
        upsert folderObject;
        if(present=='No'){
            contentDocumentLinkObject.LinkedEntityId = folderObject.Id;
        }
        insert contentDocumentLinkObject;
        return 'Done';
    }

    @AuraEnabled
    public static string getAccountId(String recordId){
        String accountId;
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id =: recordId];
            accountId = oppList[0].AccountId;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Account'){
            accountId = recordId;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Case'){
            List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE Id =: recordId];
            accountId = caseList[0].AccountId;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='WorkOrder'){
            List<WorkOrder> workOrderList = [SELECT Id, AccountId FROM WorkOrder WHERE Id =: recordId];
            accountId = workOrderList[0].AccountId;
        }
        return accountId;
    }

    /*
        get the stored documents
    */

    @AuraEnabled
    public static String checkIfOppClosedOrNot(Id recordId){
        String returnString = 'No';
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Name, AccountId, StageName, IsWon FROM Opportunity WHERE Id =: recordId];
            if(oppList[0].IsWon){
                returnString = 'Yes';
            }else{
                returnString = 'No';
            }
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Account'){
            returnString = 'No';
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Case'){
            returnString = 'No';
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='WorkOrder'){
            returnString = 'No';
        }
        return returnString;
    }

    @AuraEnabled
    public static List<Folder__c> getStoredDocuments(Id recordId){
        List<Folder__c> getFolderRecords = new List<Folder__c>();
        try {
            String accountId = getAccountId(recordId);

            getFolderRecords = [SELECT Id, Name, Account__c, Node__c, Category_Type__c, Document_Type__c, Document__c 
                                                FROM Folder__c 
                                                WHERE Account__c =: accountId 
                                                WITH SECURITY_ENFORCED
                                                ORDER BY Document_Type__c, Document__c];

            System.debug('getFolderRecords: '+getFolderRecords);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return getFolderRecords;
    }

    @AuraEnabled
    public static string getFileSize(String docId, String fileSizeInMb){
        Integer fileSizeInByte = Integer.valueOf(fileSizeInMb)*1000000;
        List<ContentDocument> contentDocumentList = [SELECT Id, ContentSize FROM 
        ContentDocument WHERE Id =: docId];
        if(contentDocumentList[0].ContentSize>fileSizeInByte){
            delete contentDocumentList;
            return 'Invalid Size';
        }else{
            return 'Valid Size';
        }
    }

    @AuraEnabled
    public static String updateFolder(Folder__c folderObject){
        update folderObject;
        return 'Done';
    }

    @AuraEnabled
    public static List<OptionsWrapper> getFieldPicklistValue(){
        return fieldPicklistValue('Folder__c', 'Decision__c', false);
    }

    public static List<OptionsWrapper> fieldPicklistValue(String objectName, String fieldName, Boolean noneValue){
        List<OptionsWrapper> optionsWrapperList = new List<OptionsWrapper>();
        Schema.SObjectType sObjectTypeVar = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult resultVar = sObjectTypeVar.getDescribe();
        Map<String,Schema.SObjectField> sObjectFieldVar = resultVar.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = sObjectFieldVar.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
        if(noneValue){
            OptionsWrapper optionsWrapperObject = new OptionsWrapper();
            optionsWrapperObject.label = '';
            optionsWrapperObject.value = null;
            optionsWrapperList.add(optionsWrapperObject);
        }
        for(Schema.PicklistEntry pickListVal : picklistEntryList){
            OptionsWrapper optionsWrapperObject = new OptionsWrapper();
            optionsWrapperObject.label = pickListVal.getLabel();
            optionsWrapperObject.value = pickListVal.getValue();
            optionsWrapperList.add(optionsWrapperObject);
        }
        return optionsWrapperList;
    }

    
    /**
    * @description 
    * @author Appstrail Developer
    * @param String merchantId 
    * @param string contentVId 
    * @param String filetype 
    * @param String docType 
    * @param String filetypename 
    * @return String 
    **/
    @AuraEnabled   // get the contentversion Id and then query the versionData from that id and convert it to string and pass it api
    public static String uploadmerchant_document(String merchantId,
                                                 string contentVId,
                                                 String filetype, 
                                                 String docType, 
                                                 String filetypename,
                                                 String recId,
                                                 String kycCategoryValue,
                                                 String categoryValue,
                                                 String documentTypeValue,
                                                 String documentTextVarTemp){

        system.debug('merchantId '+merchantId );
        system.debug('filetype '+filetype);
        system.debug('docType '+docType);
        system.debug('contentVId '+contentVId);
        system.debug('filetypename '+filetypename);
        system.debug('recId '+recId);
        system.debug('kycCategoryValue '+kycCategoryValue);
        system.debug('categoryValue '+categoryValue);
        system.debug('documentTypeValue '+documentTypeValue);
        system.debug('documentTextVarTemp '+documentTextVarTemp);   
        
        String className ='DocumentManagementControllerNew';
        String methodName ='uploadmerchant_document';

        List<API_Logger__c> apiLoggerList = new List<API_Logger__c>();
  
        List<Error_Log__c>  errorLoggerList = new List<Error_Log__c>();

        List<Account> accList = [Select Id FROM Account WHERE MID__c  = :merchantId];

        
        ContentVersionWrapper ContentVersionWrapperObject = new ContentVersionWrapper();
        
        ContentVersionWrapperObject = getContentDocument(contentVId);
        system.debug('ContentVersionWrapperObject >> '+ContentVersionWrapperObject);
        
        CashfreeAPIUtil.CombinedWrapper wrap= new CashfreeAPIUtil.CombinedWrapper();
        String jsonWebToken='';
            if(accList.size() == 0){
                System.debug('MID Not Found Codition Pass:::');
                 throw new AuraHandledException('MID Not Found....');
            }
            wrap =CashfreeAPIUtil.generateJWTToken();
            jsonWebToken= 'Bearer '+wrap.jwtToken;

        
        List<Cashfree_API_Token__mdt> cashFreeMetaData = CashfreeAPIUtil.fetchAPIValue();
        
        String endpoint =cashFreeMetaData[0].End_Point__c;
        
        //system.debug('endpoint  result:::'+endpoint);
        
        String docUploadUrl =endpoint+'/integration/salesforce/v1/docs/'+merchantId+'/upload';
        // String encoded = EncodingUtil.urlEncode(file, 'UTF-8');
        		
        String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
        String header = '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="docType"\r\n\r\n'+doctype+
            '\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="file"; filename="'+filetypename+
            '"\r\nContent-Type: '+filetype;
        String footer = '\r\n--'+boundary+'--';              
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('=')){
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(ContentVersionWrapperObject.versionData);
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        if(last4Bytes.endsWith('=')){
            Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
            HttpRequest tmp = new HttpRequest();
            tmp.setBodyAsBlob(decoded4Bytes);
            String last4BytesFooter = tmp.getBody()+footer;   
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded.substring(0,bodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
        }
        else{
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setMethod('POST');
        req.setEndpoint(docUploadUrl);
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(60000);
        req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
        req.setHeader('Authorization', jsonWebToken);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug('res::'+ res);
        System.debug('resgetbody::'+ res.getbody());
		
        Map<String,Object> bodyReq=(Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            string errorbody = string.valueOf(bodyReq);
        try {
            
            if(res.getStatusCode()==200){
                system.debug('accList--'+accList);
                if(recId=='' && accList.size()>0){
                    Folder__c newDocFolder = new Folder__c();
                    newDocFolder.Account__c = accList[0].Id;
                    newDocFolder.Category_Type__c = categoryValue;
                    newDocFolder.Document__c = documentTextVarTemp;
                    newDocFolder.Document_Type__c = documentTypeValue;
                    newDocFolder.External_Doc_Type__c = docType;
                    newDocFolder.Node__c = kycCategoryValue;
                    insert newDocFolder;
                    system.debug('newDocFolder-'+newDocFolder);
                }

                    apiLoggerList.add(API_Logger.createAPI_Logger(className,String.valueOf(req),String.valueOf(res),docUploadUrl,String.valueOf(res.getStatusCode()),accList[0].Id));
                    insert apiLoggerList;

                return 'success';
                
            } 
            else if(res.getStatusCode()==400){

                errorLoggerList.add(ErrorLogger.createErrorLogger(className, methodName, 'CustomException, Status_Code:-'+ res.getStatusCode() , errorbody,null, accList[0].Id));
                insert errorLoggerList;
                
                String jsonStr = res.getbody();
                Map<String, String> m = (Map<String, String>) JSON.deserialize(jsonStr, Map<String, String>.class);

                System.debug('res::'+ m);
                List<String> mapOutput = new List<String>();
                mapOutput = m.values();
                if(mapOutput.size()>0){
                    System.debug('res::'+ mapOutput[0]);
                    System.debug('res::'+ mapOutput[1]);
                    return mapOutput[0]+'.'+' '+mapOutput[1]+'.';
                }
            }
            else {
                System.debug('errorbody::'+ errorbody);
                throw new CustomException(errorbody);
            }
        } catch (Exception e) {
            string typenameandstatcode = e.getTypeName() +', Status_Code:-'+ res.getStatusCode();

            string errormessage = errorbody;
            errorLoggerList.add(ErrorLogger.createErrorLogger(className, methodName, typenameandstatcode, errormessage, e.getLineNumber(), accList[0].Id));
            Insert errorLoggerList;
            return errormessage;
        }
        return 'error';
   	}

    /**
    * @description 
    * @author Saurav Kashyap | 27-12-2022 
    * @param String docId 
    * @return docSizewrap 
    **/
    @AuraEnabled
    public static docSizewrap getDocSizeChecker(String docId){
        System.debug('DocId>>>  '+docId);
        docSizewrap dsWrap = new docSizewrap();
         
        List<ContentVersion> contenVersionList = [SELECT ContentDocumentId, Id, CreatedDate, 
                                                    FileType, ContentSize 
                                                    FROM ContentVersion 
                                                    WHERE Id =: docId];
        System.debug('contenVersionList >> '+contenVersionList);
        List<ContentDocument> contenDocumentList = [SELECT Id 
                                                FROM ContentDocument
                                                WHERE Id =: contenVersionList[0].ContentDocumentId];
        System.debug('contenDocumentList >> '+contenDocumentList);
        //SELECT Id FROM ContentDocument
        Integer fileSizeInByte = Integer.valueOf(1024*1024*6);
        System.debug('fileSizeInByte >> '+fileSizeInByte);
        if(contenVersionList[0].ContentSize>fileSizeInByte){
            dsWrap.size = contenVersionList[0].ContentSize/1048576;
            delete contenDocumentList;
            System.debug('dsWrap inside >size >> '+dsWrap);
            dsWrap.returnedresult = 'Invalid Size';
            return dsWrap;
        }else{
            System.debug('dsWrap outside >size >> '+dsWrap);
            dsWrap.returnedresult = 'Valid Size';
            return dsWrap;
        }
    }

    public class docSizewrap{
        @AuraEnabled
        public String returnedresult{get;set;}
        @AuraEnabled
        public Integer size{get;set;}
    }

    /**
    * @description 
    * @author Saurav Kashyap | 22-12-2022 
    * @param String contentVId 
    * @return ContentVersionWrapper 
    **/
    public static ContentVersionWrapper getContentDocument(String contentVId){
        System.debug('contentVId    >>>>  ?..  ' + contentVId);
        ContentVersionWrapper  contentVWrapObject = new ContentVersionWrapper();

        ContentVersion cvData = new ContentVersion();
        cvData = [SELECT Id, ContentDocumentId, VersionData, 
                            ContentSize 
                            FROM ContentVersion 
                            WHERE Id =: contentVId];
        contentVWrapObject.contentSize = cvData.ContentSize;
        contentVWrapObject.cotentDocumentId = cvData.ContentDocumentId;
        contentVWrapObject.versionData = cvData.VersionData;//blobToString(cvData.VersionData,'UTF-8');
        contentVWrapObject.fileData = EncodingUtil.base64Encode(cvData.VersionData);
        
        System.debug('ContentVersion  cvData   >>>>  ?..  ' + cvData);
        System.debug('ContentVersionWrapper  contentVWrapObject   >>>>  ?..  ' + contentVWrapObject);
        return contentVWrapObject;
    }

    /**
    * @description 
    * @author Saurav Kashyap | 23-12-2022 
    * @param String recordId 
    * @return MerchantDocAPIUtill 
    **/
    @AuraEnabled
    public static MerchantDocAPIUtill getAllSyncedDocs(String recordId){
        // function @returnTypes
        MerchantDocAPIUtill result = new MerchantDocAPIUtill();        
        List<Cashfree_API_Token__mdt> cashfreeAPIData = new List<Cashfree_API_Token__mdt>();
        CashfreeAPIUtil.CombinedWrapper  jsonToken = new CashfreeAPIUtil.CombinedWrapper();
        Folder__c[] folderObjectRecords = new Folder__c[0];
        Map<String,Folder__c> folderMap = new Map<String,Folder__c>();
        MerchantDocAPIUtill.MerchantDocsResponseWrapper[] folderCreationData = new MerchantDocAPIUtill.MerchantDocsResponseWrapper[0];
        String folderReturnType;

        Account accountRec = new Account();
        String merchantId;
        String accountId;

        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Name, AccountId 
                                        FROM Opportunity 
                                        WHERE Id =: recordId];
            accountRec = [SELECT Id, Name, MID__c, 
                                        OwnerId, Ownership, Industry 
                                        FROM Account 
                                        WHERE Id=:oppList[0].AccountId];
            merchantId = accountRec!=null ? accountRec.MID__c : null;
            accountId = accountRec!=null ? accountRec.Id : null;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Account'){
            accountRec = [SELECT Id, Name, MID__c, 
                                        OwnerId, Ownership, Industry 
                                        FROM Account 
                                        WHERE Id=:recordId];
            merchantId = accountRec!=null ? accountRec.MID__c : null;
            accountId = accountRec!=null ? recordId : null;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Case'){
            List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE Id =: recordId];
            accountRec = [SELECT Id, Name, MID__c, 
                        OwnerId, Ownership, Industry 
                        FROM Account 
                        WHERE Id=:caseList[0].AccountId];
            merchantId = accountRec!=null ? accountRec.MID__c : null;
            accountId = accountRec!=null ? accountRec.Id : null;
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='WorkOrder'){
            List<WorkOrder> workOrderList = [SELECT Id, AccountId FROM WorkOrder WHERE Id =: recordId];
            accountRec = [SELECT Id, Name, MID__c, 
                        OwnerId, Ownership, Industry 
                        FROM Account 
                        WHERE Id=:workOrderList[0].AccountId];
            merchantId = accountRec!=null ? accountRec.MID__c : null;
            accountId = accountRec!=null ? accountRec.Id : null;
        }

        System.debug('merchantId ...>>>  '+merchantId);

        folderObjectRecords = [SELECT Account__c, Id, External_Doc_Type__c, 
                                Pre_Signed_URL__c, Document__c, Node__c, 
                                Document_Type__c, Category_Type__c, Name 
                                FROM Folder__c
                                WHERE Account__c=:accountId];
        System.debug('folderObjectRecords ...>>>  '+folderObjectRecords);
        System.debug('folderObjectRecords.size() ...>>>  '+folderObjectRecords.size());

        for(Folder__c f : folderObjectRecords){
            folderMap.put(f.External_Doc_Type__c,f);
        }
        System.debug('MAP >>> folderMap ...>>>  '+folderMap);

        // fetching Endpoint URL...
        try {
            cashfreeAPIData =  CashfreeAPIUtil.fetchAPIValue();
            System.debug('cashfreeAPIData ...>>>  '+cashfreeAPIData);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        // fetching JWT Token...
        try {
            jsonToken = CashfreeAPIUtil.generateJWTToken();
            System.debug('jsonToken ...>>>  '+jsonToken);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        // fetching all synced up data/documnets...
        try {
            result = CashfreeDocumentSyncUtill.fetchMerchantAllDocument(merchantId, jsonToken.jwtToken, cashfreeAPIData[0].End_Point__c);
            System.debug('result ...>>> inside trycatchbloack '+result);
            System.debug('result.message ...>>> inside trycatchbloack '+ result.message);

            MerchantDocAPIUtill.MerchantDocsResponseWrapper[] merchDocWrap = new MerchantDocAPIUtill.MerchantDocsResponseWrapper[0];
            merchDocWrap = result.data.merchantDocs;

            for(MerchantDocAPIUtill.MerchantDocsResponseWrapper docTypeWrap : merchDocWrap){
                if(folderMap.containsKey(docTypeWrap.docType)){
                    System.debug('docTypeWrap.docType inside for loop '+docTypeWrap.docType);
                }else{
                    folderCreationData.add(docTypeWrap);
                    System.debug('folderCreationData inside for loop '+folderCreationData);
                    System.debug('folderCreationData.size() inside for loop '+folderCreationData.size());
                }
            }

            if(folderCreationData.size()>0){
                folderCreationFunction(JSON.serialize(accountRec),folderCreationData,result);
            }

        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        System.debug('result ...>>> before return '+result);
        return result;
    }

    /**
    * @description 
    * @author Appstrail Developer | 27-12-2022 
    * @param String accountRecord 
    **/
    public static void folderCreationFunction(String accountRecord,MerchantDocAPIUtill.MerchantDocsResponseWrapper[] extraFolderData,MerchantDocAPIUtill apiResponseData){
        //fetch endpoint url from metadata
        List<Folder__c> newFolderList = new List<Folder__c>();
        List<Folder__c> folderToInsert = new List<Folder__c>();

        Account accData = (Account) JSON.deserializeStrict(accountRecord, Account.class);
        final String ENTITY_TYPE = accData.Ownership;
        //final String LOB_TYPE = accData.Industry;
        

        /**
         * @description: Document will be visible according to the Account's Entity Type and Sub Lob Type
         * @createdDate: 2 Feb,2023
         */
        final String LOB_TYPE = accData.Sub_LOB__c;

        System.debug('LOB_TYPE ::::'+ LOB_TYPE );
        System.debug('ENTITY_TYPE ::::'+ ENTITY_TYPE );

        Map<String, MerchantDocAPIUtill.MerchantDocsResponseWrapper> docResponseMap = new Map<String, MerchantDocAPIUtill.MerchantDocsResponseWrapper>();

        MerchantDocAPIUtill result = new MerchantDocAPIUtill();
        result = apiResponseData;
        System.debug('API result.message ::::'+ result.message );

        if(result.message != 'Empty result'){
            System.debug('Entered in !empty result' );
            Map<String, Cashfree_Document_Master__c> cashfreeDocumentMasterMap = new Map<String, Cashfree_Document_Master__c>();
            Map<Id, List<Document_Type__c>> cashfreeDocumentType = new Map<Id, List<Document_Type__c>>();
            Map<String, List<Document_List__c>> cashfreeDocumentListMap = new Map<String, List<Document_List__c>>();
            Map<Id, Cashfree_Document_Master__c> cashfreeDocMasterMap = new Map<Id, Cashfree_Document_Master__c>();
            Set<Id> cashfreeDocumentMasterIdSet = new Set<Id>();
            Set<Id> documentTypeId = new Set<Id>();
    
            Map<String, String> presiteHolderMap = new Map<String,String>();
    
            for(Cashfree_Document_Master__c docMaster : [Select Id, KYC_Category__c,Name From Cashfree_Document_Master__c 
            Where Name =: ENTITY_TYPE OR Name =: LOB_TYPE]){
                System.debug('Inside Docs master For Loop docMaster ::::'+ docMaster );
                System.debug('Inside Docs master For Loop docMaster.KYC_Category__c ::::'+ docMaster.KYC_Category__c );
                if(docMaster.KYC_Category__c != null){
                    cashfreeDocumentMasterIdSet.add(docMaster.Id);
                    cashfreeDocumentMasterMap.put(docMaster.KYC_Category__c, docMaster);
                    cashfreeDocMasterMap.put(docMaster.Id, docMaster);
                }
            }
            System.debug('Outside For Loop cashfreeDocumentMasterMap ::::'+ cashfreeDocumentMasterMap );
            System.debug('Outside For Loop cashfreeDocumentMasterIdSet:::::'+ cashfreeDocumentMasterIdSet);
            System.debug('Outside For Loop cashfreeDocMasterMap:::::'+ cashfreeDocMasterMap);
    
    
            for(Document_Type__c docType : [Select Id, Cashfree_Document_Master__c, Name, Document_type_Order__c  From Document_Type__c Where Cashfree_Document_Master__c IN: cashfreeDocumentMasterIdSet]){
                documentTypeId.add(docType.Id);
                System.debug('Inside Docs Type For Loop docType ::::'+ docType );
                if(!cashfreeDocumentType.containsKey(docType.Cashfree_Document_Master__c)){
                 List<Document_Type__c> tempList = new List<Document_Type__c>();
                 tempList.add(docType);
                 System.debug('Inside if Docs Type For Loop tempList ::::'+ tempList );
                 cashfreeDocumentType.put(docType.Cashfree_Document_Master__c, tempList);
                 System.debug('Inside if Docs Type For Loop cashfreeDocumentType ::::'+ cashfreeDocumentType );
                }else{
                    cashfreeDocumentType.get(docType.Cashfree_Document_Master__c).add(docType);
                    System.debug('Inside else Docs Type For Loop cashfreeDocumentType ::::'+ cashfreeDocumentType );
                }
            }
            System.debug('outside Docs Type For Loop cashfreeDocumentType ::::'+ cashfreeDocumentType );
    
            System.debug('cashfreeDocumentType:::::'+ cashfreeDocumentType);
    
            for(Document_List__c documentList : [Select Id, Document_Type__c, Name, External_Doc_Type__c  From Document_List__c Where Document_Type__c IN: documentTypeId AND External_Doc_Type__c != null]){
                System.debug('documentList::::::'+ documentList);
                if(!cashfreeDocumentListMap.containsKey(documentList.Document_Type__c)){
                    List<Document_List__c> tempList = new List<Document_List__c>();
                    tempList.add(documentList);
                    cashfreeDocumentListMap.put(documentList.External_Doc_Type__c, tempList);
                }else{
                    cashfreeDocumentListMap.get(documentList.External_Doc_Type__c).add(documentList);
                }
            }
    
            System.debug('cashfreeDocumentListMap:::::'+ cashfreeDocumentListMap);
    
            for(MerchantDocAPIUtill.MerchantDocsResponseWrapper externalResponse : result.data.merchantDocs){
                System.debug(' inside for loop externalResponse::::'+ externalResponse);
                presiteHolderMap.put(externalResponse.docType, externalResponse.presignedURL);
                docResponseMap.put(externalResponse.docType, externalResponse);
                System.debug(' inside for loop presiteHolderMap::::'+ presiteHolderMap);
                System.debug(' inside for loop docResponseMap::::'+ docResponseMap);
            }
            System.debug(' Outside for loop docResponseMap::::'+ docResponseMap);
            System.debug('Outside presiteHolderMap::::'+ presiteHolderMap);
    
            for(String documenKey : presiteHolderMap.keySet()){
                System.debug(' Inside for loop documenKey::::'+ documenKey);
                for(String docListId : cashfreeDocumentListMap.keySet()){
                    System.debug(' Inside for loop docListId::::'+ docListId);
                    for(Document_List__c docList : cashfreeDocumentListMap.get(docListId)){
                        System.debug('docList.External_Doc_Type__c::::'+ docList.External_Doc_Type__c);
                        System.debug('documenKey::::::'+ documenKey);
                    if(docList.External_Doc_Type__c == documenKey){
                        
                    for(Id docTypeId : cashfreeDocumentType.keySet()){
                        for(Document_Type__c cashfreDocType : cashfreeDocumentType.get(docTypeId)){
                            System.debug('docTypeId ::::'+ docTypeId );
                            System.debug('cashfreDocType.Id::::'+ cashfreDocType.Id);
                            if(docList.Document_Type__c == cashfreDocType.Id){
                                System.debug('Pass');
                                for(Id docMasterId : cashfreeDocMasterMap.keySet()){
                                    if(cashfreDocType.Cashfree_Document_Master__c == docMasterId){
                                        Folder__c newDocFolder = new Folder__c();
                                        newDocFolder.Account__c = accData.Id;
                                        newDocFolder.Category_Type__c = cashfreeDocMasterMap.get(docMasterId).Name;
                                        newDocFolder.Decision__c = docResponseMap.get(documenKey).status;
                                        newDocFolder.Document__c = docList.Name;
                                        newDocFolder.Document_Type__c = cashfreDocType.Name;
                                        newDocFolder.External_Doc_Type__c = docResponseMap.get(documenKey).docType;
                                        newDocFolder.Node__c = cashfreeDocMasterMap.get(docMasterId).KYC_Category__c;
                                        newDocFolder.Pre_Signed_URL__c = docResponseMap.get(documenKey).presignedURL;
                                        newFolderList.add(newDocFolder);
                                    }
                                }
                            }
                        }
                      }
                    }
                  }
                }
            }
            System.debug('List::::'+ newFolderList);

            Map<String,MerchantDocAPIUtill.MerchantDocsResponseWrapper> docTypemap = new Map<String,MerchantDocAPIUtill.MerchantDocsResponseWrapper>();
            System.debug('docTypemap List ::::'+ docTypemap);
            for(MerchantDocAPIUtill.MerchantDocsResponseWrapper wrapF : extraFolderData){
                docTypemap.put(wrapF.docType,wrapF);
                System.debug('docTypemap List ::::'+ docTypemap);
            }
            if(newFolderList.size() != 0){
                for(Folder__c fo : newFolderList){
                    System.debug('fo List ::::'+ fo);
                    if(docTypemap.containsKey(fo.External_Doc_Type__c)){
                        folderToInsert.add(fo);
                        System.debug('folderToInsert List ::::'+ folderToInsert);
                    }
                }
                if(folderToInsert.size()!=0){
                    System.debug(' Before Insertion ::: folderToInsert List ::::'+ folderToInsert);
                    Insert folderToInsert;
                }
            }
        }
    }
    /**
    * @description 
    * @author Saurav Kashyap | 03-01-2023 
    * @param String contentVersionId 
    **/
    @AuraEnabled
    public static Boolean deleteDocs(String contentVersionId){
        try {
            System.debug('contentVersionId '+contentVersionId);
             List<ContentVersion> c = new  List<ContentVersion>();
            List<ContentDocument> cd = new List<ContentDocument>();
            Boolean ret = false;
            String  deletedId;
            if(contentVersionId!=null){
                c = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionId];
                System.debug('Con version'+c);
                if(c.size()>0)
                    deletedId =c[0].ContentDocumentId;
                if(deletedId ==null){
                    ret = false;
                }else{
                    cd =[SELECT Id FROM ContentDocument WHERE Id =: deletedId];
                    System.debug('Con Document'+cd);
                    if(cd.size()>0)
                        DELETE cd;
                    ret = true;
                }
                System.debug('Con version deletedId'+deletedId);
            }
            return ret;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static boolean checkIfAM(String recordId){
        
        String userId = UserInfo.getUserId();
        Set<Id> ownerIdSet = new Set<id>();
        
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Opportunity'){
            List<Opportunity> oppList = [SELECT Id, Name, AccountId,ownerId 
                                        FROM Opportunity 
                                        WHERE Id =: recordId];
            ownerIdSet.add(oppList[0].OwnerId);
            Account accountRec = [SELECT Id, Name, MID__c, 
                                        OwnerId, Ownership, Industry 
                                        FROM Account 
                                        WHERE Id=:oppList[0].AccountId];
            ownerIdSet.add(accountRec.OwnerId);
            
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Account'){
            Account accountRec = [SELECT Id, Name, MID__c, 
                                        OwnerId, Ownership, Industry 
                                        FROM Account 
                                        WHERE Id=:recordId];
            ownerIdSet.add(accountRec.OwnerId);
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='Case'){
            List<Case> caseList = [SELECT Id, AccountId,Opportunity__c 
                                   FROM Case WHERE Id =: recordId];
            Account accountRec = [SELECT Id, Name, MID__c, 
                        OwnerId, Ownership, Industry 
                        FROM Account 
                        WHERE Id=:caseList[0].AccountId];
            ownerIdSet.add(accountRec.OwnerId);
            if(caseList[0].Opportunity__c!=NULL){
                List<Opportunity> oppList = [SELECT Id, Name, AccountId,ownerId 
                                        FROM Opportunity 
                                        WHERE Id =: caseList[0].Opportunity__c];
            	ownerIdSet.add(oppList[0].OwnerId);
            }
            
        }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName()=='WorkOrder'){
            List<WorkOrder> workOrderList = [SELECT Id, AccountId 
                                             FROM WorkOrder WHERE Id =: recordId];
            Account accountRec = [SELECT Id, Name, MID__c, 
                        OwnerId, Ownership, Industry 
                        FROM Account 
                        WHERE Id=:workOrderList[0].AccountId];
            ownerIdSet.add(accountRec.OwnerId);
        }
        
        if(ownerIdSet.contains(userId))
            return true;
        
        return false;
    } 


    public class DocumentListWrapper{
        @AuraEnabled public String CategoryType;
        @AuraEnabled public String Document;
        @AuraEnabled public String DocumentType;
        @AuraEnabled public String Node;
    }
    public class OptionsWrapper{
        public OptionsWrapper(){
            label = '';
            value = '';
        }
        public OptionsWrapper(OptionsWrapper wrap){
            this.label = wrap.label;
            this.value = wrap.value;
        }
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    public class DocumentWrapper{ 
        public DocumentWrapper(){
            masterId = '';
            documentText = '';
            uploadedDocumentParentId = '';
            uploadedDocumentParentIdInverse = 'Contains';
            uploadedDocumentId = '';
            uploadedBoolean = false;
            accId = '';
            createdDate = '';
            decisionAction = '';
            comments = '';
            merchId = '';
            doctype = '';
            preSignedURL ='';
        }
        public DocumentWrapper(DocumentWrapper wrap){
            this.masterId = wrap.masterId;
            this.documentText = wrap.documentText;
            this.uploadedDocumentParentId = wrap.uploadedDocumentParentId;
            this.uploadedDocumentParentIdInverse = wrap.uploadedDocumentParentIdInverse;
            this.uploadedDocumentId = wrap.uploadedDocumentId;
            this.accId = wrap.accId;
            this.createdDate = wrap.createdDate;
            this.decisionAction = wrap.decisionAction;
            this.uploadedBoolean = wrap.uploadedBoolean;
            this.comments = wrap.comments;
            this.merchId = wrap.merchId;
            this.doctype = wrap.doctype;
            this.preSignedURL =wrap.preSignedURL;
        }
        @AuraEnabled public String masterId;
        @AuraEnabled public String documentText;
        @AuraEnabled public String uploadedDocumentParentId;
        @AuraEnabled public String uploadedDocumentParentIdInverse;
        @AuraEnabled public String uploadedDocumentId;
        @AuraEnabled public Boolean uploadedBoolean;
        @AuraEnabled public String accId;
        // updated part ... >>> S-E-> 
            @AuraEnabled public String merchId;
            @AuraEnabled public String doctype;
            @AuraEnabled public String preSignedURL;
        // updated part ... >>> S-E->
        @AuraEnabled public String createdDate;
        @AuraEnabled public String decisionAction;
        @AuraEnabled public String comments;
    }
    public class ContentVersionWrapper{
        @AuraEnabled public Integer contentSize;
        @AuraEnabled public String cotentDocumentId;
        @AuraEnabled public Blob versionData;
        @AuraEnabled public String fileData;
    }
}