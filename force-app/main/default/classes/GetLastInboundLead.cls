public class GetLastInboundLead {
  @InvocableMethod(
    label='Get Last Inbound Lead'
    description='Get the lead number of the last inbound lead created'
  )
  public static List<Round_Robin_Assignee__c> GetLastLead() {
    List<Round_Robin__c> getRoundRobinRecord = [
      SELECT Id, Name, Is_Active__c, Lead_Type__c, Lead_Source__c
      FROM Round_Robin__c
      WHERE Is_Active__c = TRUE AND Lead_Type__c = 'Inbound'
      LIMIT 1
    ];

    System.debug('getRoundRobinRecord: ' + getRoundRobinRecord);

    //String[] picklistValues = getRoundRobinRecord[0].Lead_Source__c.split(';');
    //System.debug('picklistValues: '+picklistValues);

    /*List<Lead> queryLeads = [SELECT Id, IsConverted, Lead_Order_Number__c, Previous_Lead_Owner__c, Lead_Number__c, OwnerId , Lead_Type__c, LeadSource, CreatedDate 
                                 FROM Lead 
                                 WHERE Lead_Type__c IN: picklistValues 
                                 AND LeadSource = 'Inbound' AND Lead_Order_Number__c != null
                                 ORDER BY CreatedDate DESC, Lead_Order_Number__c ASC
                                 LIMIT 1];*/

    List<Lead> queryLeads = [
      SELECT
        Id,
        IsConverted,
        Lead_Order_Number__c,
        Previous_Lead_Owner__c,
        Lead_Number__c,
        OwnerId,
        Lead_Type__c,
        LeadSource,
        CreatedDate
      FROM Lead
      WHERE LeadSource = 'Inbound' AND Lead_Order_Number__c != NULL
      ORDER BY CreatedDate DESC, Lead_Order_Number__c ASC
      LIMIT 1
    ];

    System.debug('queryLeads: ' + queryLeads);

    List<Round_Robin_Assignee__c> getAssignees = new List<Round_Robin_Assignee__c>();
    //if no previous inbound lead matching criteria is created
    if (queryLeads.size() > 0) {
      //previous lead owner and order number will be null
      getAssignees = [
        SELECT Is_Active__c, Id, Order_Number__c, User__c, Round_Robin__c
        FROM Round_Robin_Assignee__c
        WHERE
          Round_Robin__c = :getRoundRobinRecord[0].Id
          AND User__c = :queryLeads[0].Previous_Lead_Owner__c
          AND Is_Active__c = TRUE
        LIMIT 1
      ];

      //not needed
      if (getAssignees.size() == 0) {
        getAssignees = [
          SELECT Is_Active__c, Id, Order_Number__c, User__c, Round_Robin__c
          FROM Round_Robin_Assignee__c
          WHERE
            Round_Robin__c = :getRoundRobinRecord[0].Id
            AND Order_Number__c = :queryLeads[0].Lead_Order_Number__c
            AND Is_Active__c = TRUE
          LIMIT 1
        ];
      }
    }

    System.debug('getAssignees: ' + getAssignees);

    return getAssignees;
  }

  /* public class MyInvocableVariables { 
        @InvocableVariable(label='Lead Number' required=true)  
        public Integer leadNumber;         
    }*/
}
