/**
 * @description       : LeadScoringController{}
 * @author            :Saurav Kashyap
 * @group             : Appstrail
 * @last modified on  : 10-26-2022
 **/

public with sharing class LeadScoringController {
  /* * @Name : - LeadScoringController.getLeadDetails
    * @Description: - Takes current recordId and returns the values 
                      of 5 fields(Lead) along with the score and weightage 
                      value after the comparison of field to the 
                      Custom metadata records for each of the 4 fields.
    * @Params : - String recordId(Lead)
    * @ReturnType : - leadWrapper
    **/
  @AuraEnabled
  public static leadWrapper getLeadDetails(String recordId) {
    Lead leadList = [
      SELECT
        Id,
        Campaign_Sub_type__c,
        Campaign_Type__c,
        Action_Type__c,
        LeadSource,
        Website,
        Lead_Type__c
      FROM Lead
      WHERE Id = :recordId
      LIMIT 1
    ]; //Lead_Type__c = lead Source
    System.debug('leadList >> ' + leadList);

    //metadata for field 1
    List<Lead_Source__mdt> leadSourceMdt = [
      SELECT
        DeveloperName,
        MasterLabel,
        Id,
        NamespacePrefix,
        Label,
        Weightage__c,
        Score__c
      FROM Lead_Source__mdt
    ];
    System.debug('leadSourceMdt >> ' + leadSourceMdt);

    Map<String, Lead_Source__mdt> leadSourceMap = new Map<String, Lead_Source__mdt>();
    for (Lead_Source__mdt lsRec : leadSourceMdt) {
      leadSourceMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('leadSourceMap >> ' + leadSourceMap);

    //metadata for field 2
    List<Campaign_Type__mdt> campaignTypeMdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Score__c,
        Weightage__c
      FROM Campaign_Type__mdt
    ];
    System.debug('campaignTypeMdt >> ' + campaignTypeMdt);

    Map<String, Campaign_Type__mdt> campaignTypeMap = new Map<String, Campaign_Type__mdt>();
    for (Campaign_Type__mdt lsRec : campaignTypeMdt) {
      campaignTypeMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('campaignTypeMap >> ' + campaignTypeMap);

    //metadata for field 3
    List<Campaign_Subtype__mdt> campaignSubTypeMdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Weightage__c,
        Score__c
      FROM Campaign_Subtype__mdt
    ];
    System.debug('campaignSubTypeMdt >> ' + campaignSubTypeMdt);

    Map<String, Campaign_Subtype__mdt> campaignSubTypeMap = new Map<String, Campaign_Subtype__mdt>();
    for (Campaign_Subtype__mdt lsRec : campaignSubTypeMdt) {
      campaignSubTypeMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('campaignSubTypeMap >> ' + campaignSubTypeMap);

    //metadata for field 4
    List<Action_Type__mdt> actionTypeMdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Weightage__c,
        Score__c
      FROM Action_Type__mdt
    ];
    System.debug('actionTypeMdt >> ' + actionTypeMdt);

    Map<String, Action_Type__mdt> actionTypeMap = new Map<String, Action_Type__mdt>();
    for (Action_Type__mdt lsRec : actionTypeMdt) {
      actionTypeMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('actionTypeMap >> ' + actionTypeMap);

    //metadata for field 5
    List<Lead_Scoring_Website_Check__mdt> leadScoringWebsiteCheckmdt = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Label,
        QualifiedApiName,
        Weightage__c,
        Score__c
      FROM Lead_Scoring_Website_Check__mdt
    ];
    System.debug('leadScoringWebsiteCheckmdt >> ' + leadScoringWebsiteCheckmdt);

    Map<String, Lead_Scoring_Website_Check__mdt> leadScoringWebsiteCheckMap = new Map<String, Lead_Scoring_Website_Check__mdt>();
    for (Lead_Scoring_Website_Check__mdt lsRec : leadScoringWebsiteCheckmdt) {
      leadScoringWebsiteCheckMap.put(lsRec.MasterLabel, lsRec);
    }
    System.debug('leadScoringWebsiteCheckMap >> ' + leadScoringWebsiteCheckMap);

    leadWrapper leadWrapperRec = new leadWrapper();
    List<childWrapper> leadChildWrapper = new List<childWrapper>();

    childWrapper websiteW = new childWrapper();
    childWrapper leadSourceW = new childWrapper();
    childWrapper actiontypeW = new childWrapper();
    childWrapper campaignTypeW = new childWrapper();
    childWrapper campaignSubTypeW = new childWrapper();

    // comparison/assignment of lead record values and custom metadata values of Lead Object
    //with validation check
    if (leadList != null) {
      // Boolean value Comparison..
      if (leadList.Website != null) {
        // Boolean Value....
        Boolean bool = false;
        // String value ....
        String str = string.valueof(leadList.Website);
        System.debug('str ' + str);
        // Function Calling  .....
        bool = LeadScoringController.validateWebsite(str);
        System.debug('bool ' + bool);
        if (bool == false) {
          if (leadScoringWebsiteCheckMap.containsKey('Valid')) {
            Lead_Scoring_Website_Check__mdt lswc_MDT = new Lead_Scoring_Website_Check__mdt();
            lswc_MDT = leadScoringWebsiteCheckMap.get('Valid');
            websiteW.field = 'Website';
            websiteW.points = Integer.ValueOf(lswc_MDT.Score__c);
            websiteW.weightage = Integer.ValueOf(lswc_MDT.Weightage__c);
            System.debug('websiteW.points Valid >> ' + websiteW.points);
            System.debug('websiteW.weightage Valid >> ' + websiteW.weightage);
          } else {
            websiteW.points = 0;
            websiteW.weightage = 45;
            websiteW.field = 'Website';
            System.debug('websiteW >> ' + websiteW);
          }
        } else {
          if (leadScoringWebsiteCheckMap.containsKey('Default')) {
            Lead_Scoring_Website_Check__mdt lswc_MDT = new Lead_Scoring_Website_Check__mdt();
            lswc_MDT = leadScoringWebsiteCheckMap.get('Default');
            websiteW.field = 'Website';
            websiteW.points = Integer.ValueOf(lswc_MDT.Score__c);
            websiteW.weightage = Integer.ValueOf(lswc_MDT.Weightage__c);
            System.debug('websiteW.points Default >> ' + websiteW.points);
            System.debug('websiteW.weightage Default >> ' + websiteW.weightage);
          } else {
            websiteW.points = 0;
            websiteW.weightage = 45;
            websiteW.field = 'Website';
            System.debug('websiteW >> ' + websiteW);
          }
        }
        leadChildWrapper.add(websiteW);
      } else {
        if (leadScoringWebsiteCheckMap.containsKey('Default')) {
          Lead_Scoring_Website_Check__mdt lswc_MDT = new Lead_Scoring_Website_Check__mdt();
          lswc_MDT = leadScoringWebsiteCheckMap.get('Default');
          websiteW.field = 'Website';
          websiteW.points = Integer.ValueOf(lswc_MDT.Score__c);
          websiteW.weightage = Integer.ValueOf(lswc_MDT.Weightage__c);
          System.debug('websiteW.points Default >> ' + websiteW.points);
          System.debug('websiteW.weightage Default >> ' + websiteW.weightage);
        } else {
          websiteW.points = 0;
          websiteW.weightage = 45;
          websiteW.field = 'Website';
          System.debug('websiteW >> ' + websiteW);
        }
        leadChildWrapper.add(websiteW);
        System.debug('websiteW >> ' + websiteW);
      }

      //if(leadList.LeadSource !=null){
      if (leadList.Lead_Type__c != null) {
        // System.debug('leadSourceMap.containsKey(leadList.LeadSource) >> '+ leadSourceMap.containsKey(leadList.LeadSource));
        // System.debug('Print KK :: '+ leadSourceMap.keySet());
        // System.debug('Print KK 2 :: '+ leadList.LeadSource);

        System.debug(
          'leadSourceMap.containsKey(leadList.LeadSource) >> ' +
          leadSourceMap.containsKey(leadList.Lead_Type__c)
        );
        System.debug('Print KK :: ' + leadSourceMap.keySet());
        System.debug('Print KK 2 :: ' + leadList.Lead_Type__c);
        //if(leadSourceMap.containsKey(leadList.LeadSource)){
        if (leadSourceMap.containsKey(leadList.Lead_Type__c)) {
          Lead_Source__mdt ls_MDT = new Lead_Source__mdt();

          //ls_MDT =leadSourceMap.get(leadList.LeadSource);
          ls_MDT = leadSourceMap.get(leadList.Lead_Type__c);

          //leadSourceW.field = 'LeadSource';
          leadSourceW.field = 'Lead_Type__c';

          leadSourceW.points = Integer.ValueOf(ls_MDT.Score__c);
          leadSourceW.weightage = Integer.ValueOf(ls_MDT.Weightage__c);

          System.debug('leadSourceW.points >> ' + leadSourceW.points);
          System.debug('leadSourceW.weightage >> ' + leadSourceW.weightage);
        } else {
          if (leadSourceMap.containsKey('Default')) {
            Lead_Source__mdt ls_MDT = new Lead_Source__mdt();
            ls_MDT = leadSourceMap.get('Default');
            leadSourceW.field = 'Lead_Type__c';
            leadSourceW.points = Integer.ValueOf(ls_MDT.Score__c);
            leadSourceW.weightage = Integer.ValueOf(ls_MDT.Weightage__c);
            System.debug('leadSourceW.points default >> ' + leadSourceW.points);
            System.debug(
              'leadSourceW.weightage default >> ' + leadSourceW.weightage
            );
          } else {
            leadSourceW.points = 0;
            leadSourceW.weightage = 20;
            //leadSourceW.field = 'LeadSource';
            leadSourceW.field = 'Lead_Type__c';
            System.debug('leadSourceW >> ' + leadSourceW);
          }
        }
        leadChildWrapper.add(leadSourceW);
        System.debug('leadSourceW >> ' + leadSourceW);
      } else {
        if (leadSourceMap.containsKey('Default')) {
          Lead_Source__mdt ls_MDT = new Lead_Source__mdt();
          ls_MDT = leadSourceMap.get('Default');
          leadSourceW.field = 'Lead_Type__c';
          leadSourceW.points = Integer.ValueOf(ls_MDT.Score__c);
          leadSourceW.weightage = Integer.ValueOf(ls_MDT.Weightage__c);
          System.debug('leadSourceW.points default >> ' + leadSourceW.points);
          System.debug(
            'leadSourceW.weightage default >> ' + leadSourceW.weightage
          );
        } else {
          leadSourceW.points = 0;
          leadSourceW.weightage = 20;
          //leadSourceW.field = 'LeadSource';
          leadSourceW.field = 'Lead_Type__c';
          System.debug('leadSourceW >> ' + leadSourceW);
        }
        leadChildWrapper.add(leadSourceW);
        System.debug('leadSourceW >> ' + leadSourceW);
      }

      if (leadList.Action_Type__c != null) {
        System.debug(
          'actionTypeMap.containsKey(leadList.Action_Type__c) >> ' +
          actionTypeMap.containsKey(leadList.Action_Type__c)
        );
        if (actionTypeMap.containsKey(leadList.Action_Type__c)) {
          Action_Type__mdt at_MDT = new Action_Type__mdt();

          at_MDT = actionTypeMap.get(leadList.Action_Type__c);

          actiontypeW.field = 'Action_Type__c';
          actiontypeW.points = Integer.ValueOf(at_MDT.Score__c);
          actiontypeW.weightage = Integer.ValueOf(at_MDT.Weightage__c);

          System.debug('actiontypeW.points >> ' + actiontypeW.points);
          System.debug('actiontypeW.weightage >> ' + actiontypeW.weightage);
        } else {
          if (actionTypeMap.containsKey('Default')) {
            Action_Type__mdt at_MDT = new Action_Type__mdt();

            at_MDT = actionTypeMap.get('Default');

            actiontypeW.field = 'Action_Type__c';
            actiontypeW.points = Integer.ValueOf(at_MDT.Score__c);
            actiontypeW.weightage = Integer.ValueOf(at_MDT.Weightage__c);

            System.debug('actiontypeW.points >> ' + actiontypeW.points);
            System.debug('actiontypeW.weightage >> ' + actiontypeW.weightage);
          } else {
            actiontypeW.points = 0;
            actiontypeW.weightage = 10;
            actiontypeW.field = 'Action_Type__c';
            System.debug('actiontypeW >> ' + actiontypeW);
          }
        }
        leadChildWrapper.add(actiontypeW);
        System.debug('actiontypeW >> ' + actiontypeW);
      } else {
        if (actionTypeMap.containsKey('Default')) {
          Action_Type__mdt at_MDT = new Action_Type__mdt();

          at_MDT = actionTypeMap.get('Default');

          actiontypeW.field = 'Action_Type__c';
          actiontypeW.points = Integer.ValueOf(at_MDT.Score__c);
          actiontypeW.weightage = Integer.ValueOf(at_MDT.Weightage__c);

          System.debug('actiontypeW.points >> ' + actiontypeW.points);
          System.debug('actiontypeW.weightage >> ' + actiontypeW.weightage);
        } else {
          actiontypeW.points = 0;
          actiontypeW.weightage = 10;
          actiontypeW.field = 'Action_Type__c';
        }
        leadChildWrapper.add(actiontypeW);
        System.debug('actiontypeW >> ' + actiontypeW);
      }

      if (leadList.Campaign_Type__c != null) {
        System.debug(
          'actionTypeMap.containsKey(leadList.Campaign_Type__c) >> ' +
          actionTypeMap.containsKey(leadList.Campaign_Type__c)
        );
        if (campaignTypeMap.containsKey(leadList.Campaign_Type__c)) {
          Campaign_Type__mdt ct_MDT = new Campaign_Type__mdt();
          ct_MDT = campaignTypeMap.get(leadList.Campaign_Type__c);
          campaignTypeW.field = 'Campaign_Type__c';
          campaignTypeW.points = Integer.ValueOf(ct_MDT.Score__c);
          campaignTypeW.weightage = Integer.ValueOf(ct_MDT.Weightage__c);
          System.debug('campaignTypeW.points >> ' + campaignTypeW.points);
          System.debug('campaignTypeW.weightage >> ' + campaignTypeW.weightage);
        } else {
          if (campaignTypeMap.containsKey('Default')) {
            Campaign_Type__mdt ct_MDT = new Campaign_Type__mdt();
            ct_MDT = campaignTypeMap.get('Default');
            campaignTypeW.field = 'Campaign_Type__c';
            campaignTypeW.points = Integer.ValueOf(ct_MDT.Score__c);
            campaignTypeW.weightage = Integer.ValueOf(ct_MDT.Weightage__c);
            System.debug('campaignTypeW.points >> ' + campaignTypeW.points);
            System.debug(
              'campaignTypeW.weightage >> ' + campaignTypeW.weightage
            );
          } else {
            campaignTypeW.points = 0;
            campaignTypeW.weightage = 20;
            campaignTypeW.field = 'Campaign_Type__c';
            System.debug('campaignTypeW >> ' + campaignTypeW);
          }
        }
        leadChildWrapper.add(campaignTypeW);
        System.debug('campaignTypeW >> ' + campaignTypeW);
      } else {
        if (campaignTypeMap.containsKey('Default')) {
          Campaign_Type__mdt ct_MDT = new Campaign_Type__mdt();
          ct_MDT = campaignTypeMap.get('Default');
          campaignTypeW.field = 'Campaign_Type__c';
          campaignTypeW.points = Integer.ValueOf(ct_MDT.Score__c);
          campaignTypeW.weightage = Integer.ValueOf(ct_MDT.Weightage__c);
          System.debug('campaignTypeW.points >> ' + campaignTypeW.points);
          System.debug('campaignTypeW.weightage >> ' + campaignTypeW.weightage);
        } else {
          campaignTypeW.points = 0;
          campaignTypeW.weightage = 20;
          campaignTypeW.field = 'Campaign_Type__c';
          System.debug('campaignTypeW >> ' + campaignTypeW);
        }
        leadChildWrapper.add(campaignTypeW);
        System.debug('campaignTypeW >> ' + campaignTypeW);
      }

      if (leadList.Campaign_Sub_type__c != null) {
        System.debug(
          'campaignSubTypeMap.containsKey(leadList.Campaign_Sub_type__c) >> ' +
          campaignSubTypeMap.containsKey(leadList.Campaign_Sub_type__c)
        );
        if (campaignSubTypeMap.containsKey(leadList.Campaign_Sub_type__c)) {
          Campaign_Subtype__mdt cst_MDT = new Campaign_Subtype__mdt();
          cst_MDT = campaignSubTypeMap.get(leadList.Campaign_Sub_type__c);

          campaignSubTypeW.field = 'Campaign_Sub_type__c';
          campaignSubTypeW.points = Integer.ValueOf(cst_MDT.Score__c);
          campaignSubTypeW.weightage = Integer.ValueOf(cst_MDT.Weightage__c);
          System.debug('campaignSubTypeW.points >> ' + campaignSubTypeW.points);
          System.debug(
            'campaignSubTypeW.weightage >> ' + campaignSubTypeW.weightage
          );
        } else {
          if (campaignSubTypeMap.containsKey('Default')) {
            Campaign_Subtype__mdt cst_MDT = new Campaign_Subtype__mdt();
            cst_MDT = campaignSubTypeMap.get('Default');

            campaignSubTypeW.field = 'Campaign_Sub_type__c';
            campaignSubTypeW.points = Integer.ValueOf(cst_MDT.Score__c);
            campaignSubTypeW.weightage = Integer.ValueOf(cst_MDT.Weightage__c);
            System.debug(
              'campaignSubTypeW.points >> ' + campaignSubTypeW.points
            );
            System.debug(
              'campaignSubTypeW.weightage >> ' + campaignSubTypeW.weightage
            );
          } else {
            campaignSubTypeW.points = 0;
            campaignSubTypeW.weightage = 5;
            campaignSubTypeW.field = 'Campaign_Sub_type__c';
            System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
          }
        }
        leadChildWrapper.add(campaignSubTypeW);
        System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
      } else {
        if (campaignSubTypeMap.containsKey('Default')) {
          Campaign_Subtype__mdt cst_MDT = new Campaign_Subtype__mdt();
          cst_MDT = campaignSubTypeMap.get('Default');

          campaignSubTypeW.field = 'Campaign_Sub_type__c';
          campaignSubTypeW.points = Integer.ValueOf(cst_MDT.Score__c);
          campaignSubTypeW.weightage = Integer.ValueOf(cst_MDT.Weightage__c);
          System.debug('campaignSubTypeW.points >> ' + campaignSubTypeW.points);
          System.debug(
            'campaignSubTypeW.weightage >> ' + campaignSubTypeW.weightage
          );
        } else {
          campaignSubTypeW.points = 0;
          campaignSubTypeW.weightage = 5;
          campaignSubTypeW.field = 'Campaign_Sub_type__c';
          System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
        }
        leadChildWrapper.add(campaignSubTypeW);
        System.debug('campaignSubTypeW >> ' + campaignSubTypeW);
      }
    }

    if (leadWrapperRec != null) {
      Decimal sumPoint = 0.0;
      Integer sumWeightage = 0;
      for (childWrapper chldWrap : leadChildWrapper) {
        System.debug('chldWrap where it is breaking::::: >  >> ' + chldWrap);
        sumPoint += (chldWrap.points * Integer.ValueOf(chldWrap.weightage));
        sumWeightage += Integer.ValueOf(chldWrap.weightage);
        System.debug('sumPoint >> ' + sumPoint);
        System.debug('sumWeightage >> ' + sumWeightage);
      }
      leadWrapperRec.totalPoints = sumPoint / 100;
      System.debug(
        'leadWrapperRec.totalPoints >> ' + leadWrapperRec.totalPoints
      );
      leadWrapperRec.Percentage = Integer.ValueOf(sumPoint / 5);
      System.debug('leadWrapperRec.Percentage >> ' + leadWrapperRec.Percentage);
      leadWrapperRec.childWrapperList = leadChildWrapper;
      System.debug(
        'leadWrapperRec.childWrapperList >> ' + leadWrapperRec.childWrapperList
      );

      System.debug('leadWrapperRec >> ' + leadWrapperRec);
    }
    // Lead leadObjectUpdate = new Lead();
    // leadObjectUpdate.Id = recordId;
    // leadObjectUpdate.Lead_Score__c = leadWrapperRec.totalPoints;
    // update leadObjectUpdate;
    return leadWrapperRec;
  }
  /*
    @Name : LeadScoringController.validateWebsite(String Website)
    @Description: Checking the Website Regex Structure if it is Properly written or incorrectly filled !!!
    @params : Takes Website value as a string...
    @ReturnType : Returns a Boolean value...
    */
  public static Boolean validateWebsite(String Website) {
    Boolean result;
    //^ ((https?|ftp|smtp)://)?(www.)?  at starting
    // +(/[a-zA-Z0-9#])+/? *$at last

    // String WebsiteREGEX = '[a-zA-Z0-9]+.[a-zA-Z]';
    // '([a-zA-Z0-9\\-\\.]|[A-Z0-9a-z\\-\\.])+\\.([a-zA-Z]|[A-Za-z]|com|org|net|mil|edu|(co\\.[a-zA-Z].))'
    String WebsiteREGEX = '([a-zA-Z0-9\\-\\.]|[A-Z0-9a-z\\-\\.])+\\.([a-zA-Z]|[A-Za-z]|com|COM|org|ORG|net|NET|mil|EDU|edu|(co\\.[a-zA-Z].)|(CO\\.[A-Za-z].))';

    // Create a new Pattern object "yourPattern" with Regex for Website
    Pattern yourPattern = Pattern.compile(WebsiteREGEX);

    // Create a new Pattern object "Mymatcher" with Regex for Website
    Matcher Mymatcher = yourPattern.matcher(Website);

    //Verify the match (Returns "true" if matches otherwise "false")
    if (!MyMatcher.matches()) {
      return true;
    } else {
      return false;
    }
    // result=Mymatcher.matches();

    // return result;
  }

  public class leadWrapper {
    @AuraEnabled
    public Decimal totalPoints { get; set; }
    @AuraEnabled
    public Integer Percentage { get; set; }
    @AuraEnabled
    public List<childWrapper> childWrapperList { get; set; }
  }

  public class childWrapper {
    @AuraEnabled
    public Integer points { get; set; }
    @AuraEnabled
    public Integer weightage { get; set; }
    @AuraEnabled
    public String field { get; set; }
  }
}
