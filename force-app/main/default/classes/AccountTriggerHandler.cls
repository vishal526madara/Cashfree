/**
 * @description: handler class of account trigger
 * @date: NA
 * @updateDate: 21 Nov, 2022
 * @author: Vishal Hembrom
 * ********/
public class AccountTriggerHandler {
  public static Boolean isCreated = false;

  public static void onBeforeInsert(List<Account> newList) {
    updateExternalId(newList, null);
    updateOwnerAndSalesManager(newList, null);
  }
  public static void onBeforeUpdate(
    List<Account> newList,
    Map<id, Account> oldMap
  ) {
    updateExternalId(newList, oldMap);
    updateOwnerAndSalesManager(newList, oldMap);
  }

  public static void afterInsert(List<Account> accList) {
    // updateRoundRobinOwner(accList);
  }

  private static void updateExternalId(
    List<Account> newList,
    Map<id, Account> oldMap
  ) {
    for (Account acc : newList) {
      if (
        acc.mid__c != null &&
        (oldMap == null ||
        acc.mid__c != oldMap.get(acc.Id).mid__c)
      ) {
        acc.External_id__c = acc.mid__c;
      }
    }
  }

  private static void updateOwnerAndSalesManager(
    List<Account> newList,
    Map<id, Account> oldMap
  ) {
    Set<String> managerEmailSet = new Set<String>();
    Set<String> ownerEmailSEt = new Set<String>();
    for (Account acc : newList) {
      if (
        acc.Owner_Email_ID__c != null &&
        (oldMap == null ||
        acc.Owner_Email_ID__c != oldMap.get(acc.Id).Owner_Email_ID__c)
      ) {
        ownerEmailSEt.adD(acc.Owner_Email_ID__c);
      }

      if (
        acc.Sales_Manager_Email_ID__c != null &&
        (oldMap == null ||
        acc.Sales_Manager_Email_ID__c !=
        oldMap.get(acc.Id).Sales_Manager_Email_ID__c)
      ) {
        managerEmailSet.adD(acc.Sales_Manager_Email_ID__c);
      }
    }

    if (ownerEmailSEt.size() > 0 || managerEmailSet.size() > 0) {
      Map<String, User> userMap = new Map<String, User>();

      for (User us : [
        SELECT Id, Email, IsActive
        FROM User
        WHERE Email IN :ownerEmailSEt OR Email IN :managerEmailSet
      ]) {
        userMap.put(us.Email, us);
      }

      for (Account acc : newList) {
        if (
          acc.Owner_Email_ID__c != null &&
          ownerEmailSEt.contains(acc.Owner_Email_ID__c) &&
          userMap.containsKey(acc.Owner_Email_ID__c) &&
          userMap.get(acc.Owner_Email_ID__c).isActive
        ) {
          acc.OwnerId = userMap.get(acc.Owner_Email_ID__c).Id;
        }

        if (
          acc.Sales_Manager_Email_ID__c != null &&
          managerEmailSet.contains(acc.Sales_Manager_Email_ID__c) &&
          userMap.containsKey(acc.Sales_Manager_Email_ID__c)
        ) {
          acc.Sales_Manager__c = userMap.get(acc.Sales_Manager_Email_ID__c).Id;
        }
      }
    }
  }
}
