/**
 * 09-03-11 vishals@grazitti.com
 * Trigger to track the Reply from the customer portal users.
 */
trigger RecordReply on Reply (after insert) {
  
  Set<String> portalUsers = new Set<String>();
  Map<String, String> userToContact = new Map<String, String>();
  List<Community_Activity__c> listActivities = new List<Community_Activity__c>();
  Map<Id, Reply> mapReply ;//= new Map<String, Reply>();
  
  if(Trigger.isInsert){ 
      for(Reply  ide : Trigger.new){
          portalUsers.add(ide.createdById);
      }
      mapReply = new Map<Id, Reply>([Select Id, QuestionId from Reply where ID IN : Trigger.new]);
      for(User u : [select Id, contactId from User where Id IN :portalusers and contactId != null]){
          userToContact.put(u.Id, u.contactId);
      }
      
      for(Reply ide : Trigger.new){
          if(userToContact.containsKey(ide.createdById)){
              Community_Activity__c commAct = new Community_Activity__c(contact__c = userToContact.get(ide.createdById));
              commAct.Type__c = 'QuestionComment';
              //commAct.date__c = Date.Today();
              commAct.Activity_Id__c = ide.Id; 
              commAct.Posted_date__c = System.now();
              commAct.Title__c = ide.Name;
              commAct.Link__c = '/answers/viewQuestion.apexp?id=' + mapReply.get(ide.Id).QuestionId;
              listActivities.add(commAct);
          }
      }
      
      if(listActivities.size() > 0){
          insert listActivities ;
      }
  }
}