@isTest
public class TestUtill {
    
     public static List<Lead> createLead(Integer num){
        List<Lead> returnList = new List<Lead>();
        for(Integer i=1; i<=num; i++){
            Lead lead = new Lead();
            lead.Status = 'New';
            lead.Lead_Type__c = 'Inbound';
            lead.LastName = 'New Lead '+ i;
            lead.Company = 'Test Business '+ i;
            lead.Email = 'Test.'+ i + '@test.com';
            returnList.add(lead);
        }
        return returnList;
    }
    
    public static List<Contact> createContact(Integer num){
        List<Contact> returnList = new List<Contact>();
        for(Integer i=1; i<=num; i++){
            Contact con = new Contact();
            con.LastName = 'New Contact '+ i;
            con.Email = 'Test.'+ i + '@test.com';
            returnList.add(con);
        }
        return returnList;
    }
    
    public static List<Account> createAccount(Integer num){
        List<Account> returnList = new List<Account>();
        for(Integer i=1; i<=num; i++){
            Account acc = new Account();
            acc.Name = 'New Account '+ i;
            acc.Website='www.google.com';
            returnList.add(acc);
        }
        return returnList;
    }
    
    public static List<Opportunity> createOpportunity(Integer num){
        List<Opportunity> returnList = new List<Opportunity>();
        for(Integer i=1; i<=num; i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity '+ i;
            opp.StageName = 'Qualification';
            opp.CloseDate = System.today() + i;
            returnList.add(opp);
        }
        return returnList;
    }
    
    public static List<Product__c> createProduct(Integer num){
        List<Product__c> returnList = new List<Product__c>();
        for(Integer i=1; i<=num; i++){
            Product__c pro = new Product__c();
            pro.Name = 'Test Product '+ i;
            pro.Description__c = 'Test Description Value';
            returnList.add(pro);
        }
        return returnList;
    }
    
    public static List<Modes__c> createMode(Integer num){
        List<Modes__c> returnList = new List<Modes__c>();
        for(Integer i=1; i<=num; i++){
            Modes__c mode = new Modes__c();
            mode.Name = 'Test Mode'+ i;
            returnList.add(mode);
        }
        return returnList;
    }
    
    public static List<Settlement__c> createSettlement(Integer num){
        List<Settlement__c> returnList = new List<Settlement__c>();
        for(Integer i=1; i<=num; i++){
            Settlement__c settlement = new Settlement__c();
            settlement.Name = 'Settlement '+ i;
            settlement.Commercial__c = 10 + i;
            settlement.Commercial_Price__c = 100 + i;
            returnList.add(settlement);
        }
        return returnList;
    }
    
    public static List<Commercial__c> createCommercial(Integer num){
        List<Commercial__c> returnList = new List<Commercial__c>();
        for(Integer i=1; i<=num; i++){
            Commercial__c commercial = new Commercial__c();
            commercial.Commercial_Price__c = 100 + i;
            commercial.Commercials__c = 10 + i;
            commercial.Name = 'Test Commercial '+ i;
            returnList.add(commercial);
        }
        return returnList;
    }
    
    public static List<Opportunity_Product__c> createOpportunityProduct(Integer num){
        List<Opportunity_Product__c> returnList = new List<Opportunity_Product__c>();
        for(Integer i=1; i<=num; i++){
            Opportunity_Product__c oppProduct = new Opportunity_Product__c();
            oppProduct.Name = 'Opportunity Product '+ i;
            returnList.add(oppProduct);
        }
        return returnList;
    }
    
    public static List<Opportunity_Mode__c> createOpportunityMode(Integer num){
        List<Opportunity_Mode__c> returnList = new List<Opportunity_Mode__c>();
        for(Integer i=1; i<=num; i++){
            Opportunity_Mode__c oppMode = new Opportunity_Mode__c();
            oppMode.Name = 'Opportunity Mode '+ i;
            oppMode.Actual_Price_Percent__c = 10 + i;
            oppMode.Actual_Price__c = 100 + i;
            oppMode.Add_On__c = 10 + i;
            oppMode.Add_On_Price__c = 20 + i;
            returnList.add(oppMode);
        }
        return returnList;
    }
    
    public static List<Opportunity_Add_On__c> createOpportunityAddOn(Integer num){
        List<Opportunity_Add_On__c> returnList = new List<Opportunity_Add_On__c>();
        for(Integer i=1; i<=num; i++){
            Opportunity_Add_On__c oppAddOn = new Opportunity_Add_On__c();
            oppAddOn.Name = 'Opportunity Add On '+ i;
            oppAddOn.Add_On_Percent__c = 10 + i;
            oppAddOn.Add_On_Price__c = 100 + i;
            returnList.add(oppAddOn);
        }
        return returnList;
    }
    
    
    public static List<Checklist__c> createCheckList(Integer num){
        List<Checklist__c> checkList = new List<Checklist__c>();
        for(Integer i=1; i<=num; i++){
            Checklist__c check = new Checklist__c();
            check.Name = 'Test Check List Name '+ i;
            //check.End_Date__c = System.today() + 10 + i;
            check.Description__c = 'Test Description '+ i;
            //check.Start_Date__c = System.today() + i;
            //check.Type__c = 'Onboarding';
            checkList.add(check);
        }
        return checkList;
    }
    
    public static List<Case> createCase(Integer num){
        List<Case> caseList = new List<Case>();
        for(Integer i=1; i<=num; i++){
            Case ce = new Case();
            ce.Status = 'Open';
            caseList.add(ce);
        }
        return caseList;
    }
    
    public static List<Task> createTask(Integer num){
        List<Task> taskList = new List<Task>();
        for(Integer i=1; i<=num; i++){
            Task tsk = new Task();
            tsk.Subject = 'Test Task Subject '+ i;
            tsk.ActivityDate = System.today() + i;
            tsk.Priority = 'High';
            tsk.Status = 'Open';
            taskList.add(tsk);
        }
        return taskList;
    }
    
    public static List<Project_Milestone__c> createProjectMilestone(Integer num){
        List<Project_Milestone__c> proMileList = new List<Project_Milestone__c>();
        for(Integer i=1; i<=num; i++){
            Project_Milestone__c pMileStone = new Project_Milestone__c();
            pMileStone.Name = 'Test Stage '+ i;
            pMileStone.Type__c = 'Onboarding';
            //pMileStone.Order__c = Math.random();
            pMileStone.Description__c = 'Test Description';
            //pMileStone.Guidance_for_Success__c = 'Test Guidance For Success';
            proMileList.add(pMileStone);
        }
        return proMileList;
    }
    
    public static List<Milestone_Task__c> createMileStoneTask(Integer num){
        List<Milestone_Task__c> mileStoneTask = new List<Milestone_Task__c>();
        for(Integer i=1; i<=num; i++){
            Milestone_Task__c mTask = new Milestone_Task__c();
            mTask.Description__c = 'Test Description MileStone Task';
            mTask.Due_Day__c = i + 1;
            //mTask.Operator__c = 'Day After';
            mTask.Name = 'Test Task '+ i;
            //mTask.Team_Role__c = 'Marketing';
            //mTask.Task_Type__c = 'A';
            mileStoneTask.add(mTask);
        }
        return mileStoneTask;
    }

    public static List<Product__c> createCustomProduct(Integer num){
        List<Product__c> proList = new List<Product__c>();
        for(Integer i=1 ; i<=num; i++){
            Product__c pro = new Product__c();
            pro.Description__c = 'Test Description';
            pro.Index__c = Math.random();
            pro.Name = 'Test Product '+ i;
            proList.add(pro);
        }
        return proList;
    }
    
    /*public static List<Related_Document__c> createRelatedDocument(Integer num){
        List<Related_Document__c> relDocList = new List<Related_Document__c>();
        for(Integer i=1; i<=num; i++){
            Related_Document__c rDoc = new Related_Document__c();
            rDoc.Description__c = 'Test Related Document Description';
            rDoc.Document_Type__c = 'Aadhar Card';
            rDoc.File_Name__c = 'Test File Name '+ i;
            rDoc.Files_ID__c = String.valueOf(i);
            relDocList.add(rDoc);
        }
        return relDOcList;
    }*/
    
    public static List<Directory__c> createDirectory(Integer num){
        List<Directory__c> docList = new List<Directory__c>();
        for(Integer i=1; i<=num; i++){
            Directory__c dir = new Directory__c();
            dir.Description__c = 'Test Directory  Description';
            dir.File_Name__c = 'Test File Name '+ i;
            dir.Folder_ID__c = String.valueOf(i);
            docList.add(dir);
        }
        return docList;
    }
    
    /*public static List<Document_Team_Member__c> createDocTeamMember(Integer num){
        List<Document_Team_Member__c> docTeamList = new List<Document_Team_Member__c>();
        for(Integer i=1; i<=num; i++){
            Document_Team_Member__c docTeamMember = new Document_Team_Member__c();
            docTeamMember.Access__c = 'Read/Edit';
            docTeamMember.Name = 'Document Team Member '+ i;
            docTeamMember.Owner__c = true;
            docTeamList.add(docTeamMember);
        }
        return docTeamList;
    }*/
    
    public static List<ContentFolder> createContentFolder(Integer num){
        List<ContentFolder> contentFolderList = new List<ContentFolder>();
        for(Integer i=1; i<num; i++){
            ContentFolder cFolder = new ContentFolder();
            cFolder.Name = 'Test Content Folder'+ i;
            contentFolderList.add(cFolder);
        }
        return contentFolderList;
    }
    
    public static List<ContentVersion> createContentVersion(Integer num){
        List<ContentVersion> cVersionList = new List<ContentVersion>();
        for(Integer i=1; i<=num; i++){
            ContentVersion cVersion = new ContentVersion();
            cVersion.Title = 'Content Version '+ i;
            cVersion.PathOnClient = 'test'+i;
            cVersion.VersionData = EncodingUtil.base64Decode('Test Version data');
            cVersionList.add(cVersion);
        }
        return cVersionList;
    }
    
    
    /*public static List<Document_Team_Member__c> createDocumentTeamMember(Integer num){
        List<Document_Team_Member__c> docTeamMemberList = new List<Document_Team_Member__c>();
        For(Integer i=1; i<=num; i++){
            Document_Team_Member__c dTeamMember = new Document_Team_Member__c();
            dTeamMember.Access__c = 'Read Only';
            dTeamMember.Name = 'Document Team Member '+ i;
            dTeamMember.Owner__c = true;
            docTeamMemberList.add(dTeamMember);
        }
        return docTeamMemberList;
    }*/
    
    public static List<User> createUser(Integer num){
        Profile p = [SELECT Id FROM Profile WHERE Name='system administrator'];
        List<User> returnList = new List<User>();
        for(Integer i=1; i<=num; i++){
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User user = new User();
            user.Alias = uid;
            user.Email = 'test'+i+'@test.com';
            user.EmailEncodingKey = 'UTF-8';
            user.LastName = 'Test '+ i;
            user.LanguageLocaleKey = 'en_US';
            user.LocaleSidKey = 'en_US';
            user.ProfileId = p.Id;
            user.TimeZoneSidKey = 'America/New_York';
            user.UserName = uid + '@test'+i+'.com';
            user.IsActive = true;

            returnList.add(user);
        }
         return returnList;
    }
    
    public static List<Campaign> createCampaign(Integer num){
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=1; i<=num; i++){
            Campaign camp = new Campaign();
            camp.Name = 'Test Campaign '+ i;
            camp.IsActive = true;
            camp.Type = 'Event';
            campaignList.add(camp);
        }
        return campaignList;
    }
    
    public static List<Round_Robin__c> createRoundRobin(Integer num){
        List<Round_Robin__c> roundRobinList = new List<Round_Robin__c>();
        for(Integer i=1; i <= num; i++){
            Round_Robin__c roundRobinObj = new Round_Robin__c();
            roundRobinObj.Lead_Type__c = 'Inbound';
            roundRobinObj.Lead_Source__c = 'Web;Intercom;Payment Forms';
            roundRobinObj.Name = 'Round Robin for Inbound';
            roundRobinObj.Is_Active__c = true;
            roundRobinList.add(roundRobinObj);
        }
        return roundRobinList;
    }
    
    public static List<Round_Robin_Assignee__c> createRoundRobinAssignee(Integer num, Id roundRobinId){
        List<Round_Robin_Assignee__c> roundRobinAssigneeList = new List<Round_Robin_Assignee__c>();
        for(Integer i=1; i <= num; i++){
            Round_Robin_Assignee__c roundRobinAssigneeObj = new Round_Robin_Assignee__c();
            roundRobinAssigneeObj.Is_Active__c = true;
            roundRobinAssigneeObj.Round_Robin__c = roundRobinId;
            roundRobinAssigneeList.add(roundRobinAssigneeObj);
        }
        return roundRobinAssigneeList;
    }

    public static List<Group> creategroup(Integer num){
        List<Group> grouplist = new List<Group>();
        for(Integer i=1; i <= num; i++){
            Group groupobj = new Group();
            groupobj.Name='Test#';
            grouplist.add(groupobj);
        }
        return grouplist;
    }
    public static List<Bank_Ops__c> createbankops(Integer num){
        List<Bank_Ops__c> bankopslist = new List<Bank_Ops__c>();
        for(Integer i=1; i <= num; i++){
            Bank_Ops__c bankopsobj = new Bank_Ops__c();
            bankopsobj.Name='Bank Ops Record '+ i;
            bankopslist.add(bankopsobj);
        }
        return bankopslist;
    }
    public static List<WorkOrder> createworkorder(Integer num){ 
        List<WorkOrder> workorderlist = new List<WorkOrder>();
        for(Integer i=1; i <= num; i++){
            WorkOrder workorderobj = new WorkOrder();
            workorderobj.Status = 'New';
            workorderlist.add(workorderobj);
        }
        return workorderlist;
    }
    public static List<Entitlement> createentitlement(Integer num){ 
        List<Entitlement> entitlementlist = new List<Entitlement>();
        for(Integer i=1; i <= num; i++){
            Entitlement entitlementobj = new Entitlement();
            entitlementlist.add(entitlementobj);
        }
        return entitlementlist;
    }
    public static List<Method_Type__c> createmethod(Integer num){ 
        List<Method_Type__c> methodlist = new List<Method_Type__c>();
        for(Integer i=1; i <= num; i++){
            Method_Type__c methodobj = new Method_Type__c();
            //methodobj[0].Name = 'Test#'+i;
            methodlist.add(methodobj);
        }
        return methodlist;
    }
    public static List<Cashfree_Document_Master__c> createcashfreedoc(Integer num){ 
        List<Cashfree_Document_Master__c> cashfreedoclist = new List<Cashfree_Document_Master__c>();
        for(Integer i=1; i <= num; i++){
            Cashfree_Document_Master__c cashfreedocobj = new Cashfree_Document_Master__c();
            //methodobj[0].Name = 'Test#'+i;
            cashfreedoclist.add(cashfreedocobj);
        }
        return cashfreedoclist;
    }
    public static List<Document_Type__c> createdocumenttype(Integer num){ 
        List<Document_Type__c> documenttypelist = new List<Document_Type__c>();
        for(Integer i=1; i <= num; i++){
            Document_Type__c documenttypeobj = new Document_Type__c();
            //methodobj[0].Name = 'Test#'+i;
            documenttypelist.add(documenttypeobj);
        }
        return documenttypelist;
    }
    public static List<Folder__c> createfolder(Integer num){ 
        List<Folder__c> folderlist = new List<Folder__c>();
        for(Integer i=1; i <= num; i++){
            Folder__c folderobj = new Folder__c();
            //methodobj[0].Name = 'Test#'+i;
            folderlist.add(folderobj);
        }
        return folderlist;
    }
     public static List<Document_List__c> createdocumentlist(Integer num){ 
        List<Document_List__c> documentlistlist = new List<Document_List__c>();
        for(Integer i=1; i <= num; i++){
            Document_List__c documentlistobj = new Document_List__c();
            //methodobj[0].Name = 'Test#'+i;
            documentlistlist.add(documentlistobj);
        }
        return documentlistlist;
    }
    public static List<OpportunityContactRole> createoppcontactrole(Integer num){ 
        List<OpportunityContactRole> oppcontactrolelist = new List<OpportunityContactRole>();
        for(Integer i=1; i <= num; i++){
            OpportunityContactRole oppcontactroleobj = new OpportunityContactRole();
            //methodobj[0].Name = 'Test#'+i;
            oppcontactrolelist.add(oppcontactroleobj);
        }
        return oppcontactrolelist;
    }


    public static List<Collected_Document__c> createcollecteddoc(Integer num){ 
        List<Collected_Document__c> collecteddoclist = new List<Collected_Document__c>();
        for(Integer i=1; i <= num; i++){
            Collected_Document__c collecteddocobj = new Collected_Document__c();
            //collecteddocobj[0].Name = 'Test#'+i;
            collecteddoclist.add(collecteddocobj);
        }
        return collecteddoclist;
    }

   


    public static List<Bank_Ops_Junction__c> createBankOpsJunction(Integer num){
        List<Bank_Ops_Junction__c> result = new List<Bank_Ops_Junction__c>();
        for(Integer i=0; i<=num; i++){
            Bank_Ops_Junction__c junctionRecord = new Bank_Ops_Junction__c();
            junctionRecord.Name = 'Junction Record '+ i;
            result.add(junctionRecord);
        }
        return result; 
    }

    public static List<Round_Robin__c> createIndividualRoundRobin(Integer num){
        List<Round_Robin__c> returnList = new List<Round_Robin__c>();
        for(Integer i=1; i<=num; i++){
            Round_Robin__c roundRobin = new Round_Robin__c();
            roundRobin.Is_Active__c = true;
            roundRobin.Name = 'Round Robin Rule '+ i;
            returnList.add(roundRobin);
        }
        return returnList;
    }

    public static List<Round_Robin_Assignee__c> createRounRobinAssignee(Integer num){
        List<Round_Robin_Assignee__c> returnList = new List<Round_Robin_Assignee__c>();
        for(Integer i=1; i<=num; i++){
            Round_Robin_Assignee__c assignee = new Round_Robin_Assignee__c();
            assignee.Is_Active__c = true;
            assignee.Name = 'Round Robin Assignee Name '+ i;
            returnList.add(assignee);
        }
        return returnList;
    }

    public static List<Opportunity_Round_Robin__c> createOpportunityRoundRobin(Integer num){
        List<Opportunity_Round_Robin__c> oppRRList = new List<Opportunity_Round_Robin__c>();
        for(Integer i=1; i<=num; i++){
            Opportunity_Round_Robin__c oppRR = new Opportunity_Round_Robin__c();
            oppRR.Name = 'Opportunity Round Robin '+ i;
            oppRR.Is_Active__c = true;
            oppRRList.add(oppRR);
        }
        return oppRRList;
    }

    public static List<Opportunity_Round_Robin_Assignee__c> createOpportunityRoundRobinAssignee(Integer num){
        List<Opportunity_Round_Robin_Assignee__c> oppRRAList = new List<Opportunity_Round_Robin_Assignee__c>();
        for(Integer i=1; i<=num; i++){
            Opportunity_Round_Robin_Assignee__c oppRRA = new Opportunity_Round_Robin_Assignee__c();
            oppRRA.Is_Active__c = true;
            oppRRAList.add(oppRRA);
        }
        return oppRRAList;
    }


    public static List<Merchant_Product__c> createMerchantProduct(Integer num){
        List<Merchant_Product__c> result = new List<Merchant_Product__c>();
        for(Integer i=1; i<=num; i++){
            Merchant_Product__c mProduct = new Merchant_Product__c();
            mProduct.Status__c = 'Active';
            result.add(mProduct);
        }
        return result;
    }
}