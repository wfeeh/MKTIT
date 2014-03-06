/**
 * 09-03-11 vishals@grazitti.com
 * Trigger to track the Question from the customer portal users.
 */
trigger RecordQuestion on Question (after insert) {
  
  Set<String> portalUsers = new Set<String>();
  Map<String, String> userToContact = new Map<String, String>();
  List<Community_Activity__c> listActivities = new List<Community_Activity__c>();
  
  if(Trigger.isInsert){
      for(Question ide : Trigger.new){
          portalUsers.add(ide.createdById);
      }
      
      for(User u : [select Id, contactId from User where Id IN :portalusers and contactId != null]){
          userToContact.put(u.Id, u.contactId);
      }
      
      for(Question ide : Trigger.new){
          if(userToContact.containsKey(ide.createdById)){
              Community_Activity__c commAct = new Community_Activity__c(contact__c = userToContact.get(ide.createdById));
              commAct.Type__c = 'Question';
              //commAct.date__c = Date.Today();
              commAct.Activity_Id__c = ide.Id; 
              commAct.Posted_date__c = System.now();
              commAct.Title__c = ide.Title;
              commAct.Link__c = '/answers/viewQuestion.apexp?id=' + ide.Id;
              listActivities.add(commAct);
          }
      }
      
      if(listActivities.size() > 0){
          insert listActivities ;
      }
  }
}