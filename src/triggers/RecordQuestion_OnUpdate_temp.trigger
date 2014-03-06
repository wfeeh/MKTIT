trigger RecordQuestion_OnUpdate_temp on Question (after update) {
  Set<String> portalUsers = new Set<String>();
  Map<String, String> userToContact = new Map<String, String>();
  List<Community_Activity__c> listActivities = new List<Community_Activity__c>();
  Map<Id, Question> mapQuestions ;
  
  if(Trigger.isUpdate){
      for(Question ide : Trigger.new){
          portalUsers.add(ide.createdById);
      }
      mapQuestions = new Map<Id, Question>([Select Id, CreatedDate from Question where ID IN : Trigger.new]);
      
      for(User u : [select Id, contactId from User where Id IN :portalusers and contactId != null]){
          userToContact.put(u.Id, u.contactId);
      }
      
      for(Question ide : Trigger.new){
          if(userToContact.containsKey(ide.createdById)){
              Community_Activity__c commAct = new Community_Activity__c(contact__c = userToContact.get(ide.createdById));
              commAct.Type__c = 'Question';
              //commAct.date__c = Date.Today();
              commAct.Activity_Id__c = ide.id; 
              commAct.Posted_date__c = mapQuestions.get(ide.id).CreatedDate;
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