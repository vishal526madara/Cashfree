/**
 * @description       : 
 * @author            : Saurav Kashyap
 * @group             : SK Group
 * @last modified on  : 07-03-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   03-03-2023   Saurav Kashyap   Initial Version
**/
public class SubCaseCreationReader {
    public class MyException extends Exception {}
   

    /**
    * @description 
    * @author Saurav Kashyap | 06-03-2023 
    * @param String jsonString 
    * @return RestResponse 
    **/
    public static RestResponse readrequest(String jsonString){
        try{
            // Instance of RestResponse Object ... for Return Type >>>
            RestResponse restResponseData = new RestResponse();
            System.debug('Inside Try Block');

            //Instance Variables
            List<Case> onboardingCaseList = new  List<Case>();
            List<Opportunity> opportunityList = new  List<Opportunity>();

            // SubCaseCreation Wrapper to be Instanciated Here
            SubCaseCreationRequestWrapper subCaseWrapperObject = SubCaseCreationRequestWrapper.parse(jsonString);
            System.debug('Inside try >> subCaseWrapperObject >> '+subCaseWrapperObject);

            // Null Check For Request Json Wrapper Object ..
            if(subCaseWrapperObject!=null){
                //Is Product Available - If Yes
                if(!String.isBlank(subCaseWrapperObject.product))
                    //If MID Available - If Yes
                    if(!String.isBlank(subCaseWrapperObject.mid)){
                        /*Querying latest opportunity Record with filter criteria as 
                        opportunity Product and MID should Match to the Request 
                        Wrpper value and By created Date*/
                        opportunityList = [SELECT AccountId,Account.OwnerId, Id, Opportunity_Product__c 
                                            FROM Opportunity
                                            WHERE Opportunity_Product__c =: subCaseWrapperObject.product
                                            AND Account.MID__c =:subCaseWrapperObject.mid
                                            ORDER BY CreatedDate DESC];

                        System.debug('Inside try-If >> opportunityList >> '+opportunityList);
                    }else {
                        //If MID Available - If No
                        return restResponseData('Please fill MID Field value '+ subCaseWrapperObject.mid,null,500,null);
                    }
                else{
                    //Is Product Available - If No
                    return restResponseData('Please fill the Product Name '+ subCaseWrapperObject.product,null,500,null);
                }

                //Size check for opportunityList if it has value or not ...
                //if opportunityList.Size()>0 -yes
                if(opportunityList.size()>0){
                    System.debug('subCaseWrapperObject.mid >>>>  '+subCaseWrapperObject.mid);
                    System.debug('opportunityList[0].Id >>>>  '+opportunityList[0].Id);
                    /*Querying Case Record with filter criteria as 
                        opportunity ID and MID should Match to the Request 
                        Wrpper value.*/
                        onboardingCaseList = [SELECT Id, ParentId, Type, RecordTypeId, 
                                                Status, Origin, Subject, Description, 
                                                OwnerId,MID__c, CreatedDate, Case_For__c 
                                                FROM Case
                                                WHERE Opportunity__c =:opportunityList[0].Id 
                                                AND MID__c =:subCaseWrapperObject.mid];
                        System.debug('onboardingCaseList >>>>  '+onboardingCaseList);
                }else{
                    //if opportunityList.Size()>0 - No
                    System.debug('Inside try-Else >>  >> opportunityList.size() ->>  0 ');
                }

                // Size Check for Onboarding Case Record - If onboardingCaseList.size()>0 - YES
                if(onboardingCaseList.size()>0){
                    return createCaseRecord(subCaseWrapperObject,opportunityList,onboardingCaseList);
                }else{
                    // Size Check for Onboarding Case Record - If onboardingCaseList.size()>0 - NO
                    return restResponseData('No Such Onboarding Case Exists',null,500,null);
                }
            }
        return restResponseData;
        }catch (DmlException e){
            system.debug('Inside DmlException Catch');
            return restResponseData(e.getMessage() +' '+ e.getLineNumber(),null,400,null);
        }catch (QueryException e){
            system.debug('Inside QueryException Catch');
            return restResponseData(e.getMessage() +' '+ e.getLineNumber(),null,404,null);
        }catch(Exception e){
            system.debug('Inside Exception Catch');
            return restResponseData(e.getMessage() +' '+ e.getLineNumber(),null,500,null);
        }
    }

    /**
    * @description 
    * @author Saurav Kashyap | 07-03-2023 
    * @param SubCaseCreationRequestWrapper subCaseWrapperObject 
    * @param List<Opportunity> opportunityList 
    * @param List<Case> onboardingCaseList 
    * @return RestResponse 
    **/
    public static RestResponse createCaseRecord(SubCaseCreationRequestWrapper subCaseWrapperObject, List<Opportunity> opportunityList, List<Case> onboardingCaseList){
        // Instance Variables ....
        Case subCase = new Case();
        List<User> u = new List<User>();

        System.debug('subCaseWrapperObject >>> '+subCaseWrapperObject);
        System.debug('opportunityList >>> '+opportunityList);
        System.debug('onboardingCaseList >>> '+onboardingCaseList);

        //Null Check for subCaseWrapperObject >>>>
        if(subCaseWrapperObject!=null){

            if(String.isBlank(subCaseWrapperObject.product) &&  !subCaseWrapperObject.subCaseCeation){
                return restResponseData('Please Add Product Name  in product field',null,400,null);
            }
            // if(String.isBlank(subCaseWrapperObject.product) && subCaseWrapperObject.subCaseCeation){
            //     return restResponseData('Please make ');
            // }

            // Null check for subCaseWrapperObject.title , If title field value is present in wrapper object - YES
            if(!String.isBlank(subCaseWrapperObject.title)){
                subCase.Subject = subCaseWrapperObject.title;
            }else{
                // Null check for subCaseWrapperObject.title , If title field value is present in wrapper object - NO
                return restResponseData('Please Fill the Title/Subject for the Case : '+ subCaseWrapperObject.title,null,500,null);
            }
            subCase.Description = subCaseWrapperObject.description!=null ? subCaseWrapperObject.description : null;
            // Null check for subCaseWrapperObject.assignee , If assignee field value is present in wrapper object - YES
            // if(!String.isBlank(subCaseWrapperObject.assignee))
            //     u =[SELECT Id, Name, Email FROM User WHERE Email =:subCaseWrapperObject.assignee];
            // System.debug('UserList '+u);
        }
        subCase.Status = 'New';
        subCase.Origin = 'Internal';
        subCase.Type = 'Onboarding';
        subCase.Case_For__c = 'Send to Account Manager';

        //Onboarding Case Id Mapping To the Sub Child Case >>>
        subCase.ParentId =onboardingCaseList[0].Id;
        //Opportunity Id Mapping To the Sub Child Case >>>
        subCase.Opportunity__c = opportunityList[0].Id;
        //Parent Account Id Mapping To the Sub Child Case >>>
        subCase.AccountId = opportunityList.size()>0 ? opportunityList[0].AccountId : null;
        //Owner Id Mapping To the Sub Child Case >>>
        //subCase.OwnerId = u.size()>0 ? u[0].Id : opportunityList.size()>0 ? opportunityList[0].Account.OwnerId : null;
        subCase.Sub_Case__c = true; //By Deafault Sub Case is

        /*Querying latest RecordType Record with filter criteria as 
        SobjectType ='Case' and Name should be 'Send to Account Manager'*/
        // List<RecordType> rectyplist = new List<RecordType>();
        // rectyplist = [SELECT Id, Name, DeveloperName, 
        //                 SobjectType, IsActive 
        //                 FROM RecordType 
        //                 WHERE SobjectType = 'Case' 
        //                 AND 
        //                 Name ='Send to Account Manager'];
        // System.debug('rectyplist:>> '+rectyplist);
        // Size check for rectyplist.size()>0 - If YES
        // if(rectyplist.size()>0)
        //     subCase.RecordTypeId = rectyplist.size()>0 ? rectyplist[0].Id : null;
        // else    // Size check for rectyplist.size()>0 - If NO
        //     System.debug('rectyplist: value DNE>> ');

        // returnType Variable to store SubCase ID >>>
        String returnedValue;
        // DML -> INSERT  Operation ....
        Database.SaveResult savedResult = Database.insert(subCase,false);
        System.debug('Case Successfully Created savedResult '+savedResult);
        // If DML Operation Is Successful ... >>>
        if(savedResult.isSuccess()){
            // getting SubCase ID after Sub-Case Creation
            returnedValue = savedResult.getId();
            System.debug('returnedValue >>> '+returnedValue);
            //Null Check for SubCase ID variable , If NotNull - YES
            if(returnedValue!=null)
                return restResponseData(null,'Sub Case created Successfully!',200,returnedValue);
            else     //Null Check for SubCase ID variable , If NotNull - NO
                return restResponseData('Case creation failed ',null,500,null);
        }else{
            // If DML Operation Failed ... >>>
            System.debug('Case creation failed >>>>');
            return restResponseData('Case creation failed ',null,500,null);
        }
    }

    /**
    * @description 
    * @author Saurav Kashyap | 06-03-2023 
    * @param String errorMessage 
    * @param String successMessage 
    * @param Integer statusCode 
    * @param String recordId 
    * @return RestResponse 
    **/
    public static RestResponse restResponseData(String errorMessage,String successMessage,Integer statusCode,String recordId){
        // Instance Variables ... >>>
        RestResponse restRes = new RestResponse();
        Map<String,String> responseMap = new  Map<String,String>();

        // Error Message Null Check
        if(errorMessage!=null){
            responseMap.put('message',errorMessage);
            responseMap.put('status','error');
            restRes.statusCode = statusCode;
        }
        // Success Message null check
        if(successMessage!=null){
            responseMap.put('message',successMessage);
            responseMap.put('status','success');
            restRes.statusCode = statusCode;
            responseMap.put('subCaseID',recordId); 
        }
        // Conversion of JSON Wrapper Object in BLOB format ... >>>
        restRes.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        system.debug('responseMap::'+responseMap);
        
        return restRes;
    }

}