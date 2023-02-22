public without sharing class ContactCustomLookupController {
  @AuraEnabled(cacheable=true)
  public static List<sObject> search(
    String searchTerm,
    string myObject,
    String filter
  ) {
    filter = 'Phone != null';
    String myQuery = null;
    if (filter != null && filter != '') {
      myQuery =
        'Select Id, Name, Phone from ' +
        myObject +
        ' Where Phone Like  \'%' +
        searchTerm +
        '%\' AND ' +
        filter +
        ' LIMIT  5';
    } else {
      if (searchTerm == null || searchTerm == '') {
        myQuery =
          'Select Id, Name, Phone from ' +
          myObject +
          ' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
      } else {
        myQuery =
          'Select Id, Name, Phone from ' +
          myObject +
          ' Where Phone Like  \'%' +
          searchTerm +
          '%\' LIMIT  5';
      }
    }
    List<sObject> lookUpList = database.query(myQuery);
    return lookUpList;
  }
}
