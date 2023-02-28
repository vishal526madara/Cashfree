public with sharing class RoundRobinController {
  public static List<Lead> getLeadListWithRoundRobinOwner(
    Map<Id, List<Lead>> mapOfRoundRobinIdVsLeadList
  ) {
    List<Lead> leadListWithRoundRobinOwner = new List<Lead>();
    if (mapOfRoundRobinIdVsLeadList.size() > 0) {
      List<System_Administrator_Holder__mdt> systemAdministratorHolderList = [
        SELECT Id, DeveloperName, MasterLabel, Admin_User_Id__c
        FROM System_Administrator_Holder__mdt
      ];
      Map<Id, Round_Robin__c> roundRobinMap = new Map<Id, Round_Robin__c>(
        [
          SELECT Id, Previous_Active_User__c
          FROM Round_Robin__c
          WHERE Id = :mapOfRoundRobinIdVsLeadList.keySet()
        ]
      );
      List<Round_Robin_Assignee__c> roundRobinAssigneeList = [
        SELECT Id, Round_Robin__c, Is_Active__c, Order_Number__c, User__c
        FROM Round_Robin_Assignee__c
        WHERE Round_Robin__c = :roundRobinMap.keySet() AND Is_Active__c = TRUE
        ORDER BY Order_Number__c ASC
      ];
      Map<Id, List<Round_Robin_Assignee__c>> roundRobinIdVsAssigneeId = new Map<Id, List<Round_Robin_Assignee__c>>();
      for (
        Round_Robin_Assignee__c roundRobinAssigneeVar : roundRobinAssigneeList
      ) {
        if (
          roundRobinIdVsAssigneeId.containsKey(
            roundRobinAssigneeVar.Round_Robin__c
          )
        ) {
          List<Round_Robin_Assignee__c> existedList = roundRobinIdVsAssigneeId.get(
            roundRobinAssigneeVar.Round_Robin__c
          );
          existedList.add(roundRobinAssigneeVar);
          roundRobinIdVsAssigneeId.put(
            roundRobinAssigneeVar.Round_Robin__c,
            existedList
          );
        } else {
          List<Round_Robin_Assignee__c> sampleList = new List<Round_Robin_Assignee__c>();
          sampleList.add(roundRobinAssigneeVar);
          roundRobinIdVsAssigneeId.put(
            roundRobinAssigneeVar.Round_Robin__c,
            sampleList
          );
        }
      }
      List<Round_Robin__c> roundRobinList = new List<Round_Robin__c>();
      for (Id roundRobinVar : mapOfRoundRobinIdVsLeadList.keySet()) {
        if (mapOfRoundRobinIdVsLeadList.containsKey(roundRobinVar)) {
          List<Lead> tempLeadList = mapOfRoundRobinIdVsLeadList.get(
            roundRobinVar
          );
          if (roundRobinIdVsAssigneeId.containsKey(roundRobinVar)) {
            List<Round_Robin_Assignee__c> tempRoundRobinAssigneeList = roundRobinIdVsAssigneeId.get(
              roundRobinVar
            );
            //if(tempLeadList.size() > tempRoundRobinAssigneeList.size()){
            if (roundRobinMap.containsKey(roundRobinVar)) {
              // if(roundRobinMap.get(roundRobinVar).Previous_Active_User__c == null){
              //     Integer countCheck = 1;
              //     Integer countCheckLeadList = 1;
              //     for(Lead leadVar : tempLeadList){
              //         if(tempRoundRobinAssigneeList.size() >= countCheck){
              //             leadVar.OwnerId = tempRoundRobinAssigneeList[countCheck-1].User__c;
              //             if(tempLeadList.size() == countCheckLeadList){
              //                 Round_Robin__c roundRobinObject = new Round_Robin__c();
              //                 roundRobinObject.Id = roundRobinVar;
              //                 roundRobinObject.Previous_Active_User__c = String.valueOf(countCheck);
              //                 roundRobinList.add(roundRobinObject);
              //                 countCheckLeadList = 0;
              //             }
              //             if(tempRoundRobinAssigneeList.size() == countCheck){
              //                 countCheck = 0;
              //             }
              //         }
              //         countCheck++;
              //         countCheckLeadList++;
              //     }
              // }else{
              //Integer tempCheck = Integer.ValueOf(roundRobinMap.get(roundRobinVar).Previous_Active_User__c);
              //Integer countCheck = tempCheck == tempRoundRobinAssigneeList.size() ? 1 : tempCheck+1;
              Integer countCheck = roundRobinMap.get(roundRobinVar)
                  .Previous_Active_User__c == null
                ? 1
                : Integer.ValueOf(
                      roundRobinMap.get(roundRobinVar).Previous_Active_User__c
                    ) == tempRoundRobinAssigneeList.size()
                    ? 1
                    : Integer.ValueOf(
                        roundRobinMap.get(roundRobinVar).Previous_Active_User__c
                      ) + 1;
              Integer countCheckLeadList = 1;
              for (Lead leadVar : tempLeadList) {
                if (tempRoundRobinAssigneeList.size() >= countCheck) {
                  leadVar.OwnerId = tempRoundRobinAssigneeList[countCheck - 1]
                    .User__c;
                  leadVar.RR_Owner_Changed__c = true;
                  if (tempLeadList.size() == countCheckLeadList) {
                    Round_Robin__c roundRobinObject = new Round_Robin__c();
                    roundRobinObject.Id = roundRobinVar;
                    roundRobinObject.Previous_Active_User__c = String.valueOf(
                      countCheck
                    );
                    roundRobinList.add(roundRobinObject);
                    countCheckLeadList = 0;
                  }
                  if (tempRoundRobinAssigneeList.size() == countCheck) {
                    countCheck = 0;
                  }
                }
                countCheck++;
                countCheckLeadList++;
              }
              //}
            }
            //}
            //if(tempLeadList.size() < tempRoundRobinAssigneeList.size()){}
            //if(tempLeadList.size() == tempRoundRobinAssigneeList.size()){}
          } else {
            if (systemAdministratorHolderList.size() > 0) {
              for (Lead leadVar : tempLeadList) {
                leadVar.OwnerId = systemAdministratorHolderList[0]
                  .Admin_User_Id__c;
              }
            }
          }
          leadListWithRoundRobinOwner.addAll(tempLeadList);
        }
      }
      update roundRobinList;
    }
    return leadListWithRoundRobinOwner;
  }

  public static Boolean isInTimeZone(Round_Robin__c roundRobinRecord) {
    Double onTimeValue = generateTimeFormatNumber(
      String.valueOf(roundRobinRecord.On_Duty__c)
    );
    Double offTimeValue = generateTimeFormatNumber(
      String.valueOf(roundRobinRecord.Off_Duty__c)
    );
    System.debug('On Off Value::::' + onTimeValue);
    System.debug('On Off Value::::' + offTimeValue);
    Double leadRecordTime = generateTimeNumber(generateCurrentTime());
    System.debug('Temporary Key:::::' + leadRecordTime);
    if (onTimeValue < offTimeValue) {
      if (onTimeValue <= leadRecordTime && leadRecordTime <= offTimeValue) {
        return true;
      } else {
        return false;
      }
    } else {
      if (
        (onTimeValue <= leadRecordTime &&
        leadRecordTime <= Double.valueOf(Integer.valueOf('23.99'))) ||
        (Double.valueOf(Integer.valueOf('00')) <= leadRecordTime &&
        leadRecordTime <= offTimeValue)
      ) {
        return true;
      } else {
        return false;
      }
    }
  }

  private static Double generateTimeFormatNumber(String timeFormatValue) {
    Double result = 0;
    List<String> timeValueList = timeFormatValue.split(':');
    result =
      Double.valueOf(timeValueList[0]) +
      Double.valueOf((Integer.valueOf(timeValueList[1]) / 60));
    return result;
  }

  private static Double generateTimeNumber(String timeFormat) {
    Double result;
    List<String> timeList = timeFormat.split(':');
    if (timeList[0] != '12' && timeList[1].contains('PM')) {
      result =
        Double.valueOf(Integer.valueOf(timeList[0])) +
        12 +
        Double.valueOf(Integer.valueOf(timeList[1].substring(0, 2)) / 60);
    } else if (timeList[0] != '12' && timeList[1].contains('AM')) {
      result =
        Double.valueOf(Integer.valueOf(timeList[0])) +
        Double.valueOf(Integer.valueOf(timeList[1].substring(0, 2)) / 60);
    } else if (timeList[0] == '12' && timeList[1].contains('AM')) {
      //result = Double.valueOf(Integer.valueOf(timeList[0])) + 12 + Double.valueOf(Integer.valueOf(timeList[1].substring(0,2))/60);
      result =
        Double.valueOf(Integer.valueOf('00')) +
        Double.valueOf(Integer.valueOf(timeList[1].substring(0, 2)) / 60);
    } else if (timeList[0] == '12' && timeList[1].contains('PM')) {
      result =
        Double.valueOf(Integer.valueOf(timeList[0])) +
        Double.valueOf(Integer.valueOf(timeList[1].substring(0, 2)) / 60);
    }
    return result;
  }

  private static String generateCurrentTime() {
    DateTime dtDateTime = system.now();
    String sTime = dtDateTime.format('h:mm a');
    String sTime1 = dtDateTime.format('h:mm');
    return sTime;
  }
}
