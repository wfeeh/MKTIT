/**
 * 09-03-11 vishals@grazitti.com
 * Trigger to track the Ideas/IdeaComments from the customer portal users.
 */
trigger RecordIdea on Idea (after insert, after update) {
  
  User currenetUser = [select id, contactId from User where Id=:UserInfo.getUserId()];
  System.debug('======='+currenetUser );
  Set<String> portalUsers = new Set<String>();
  Map<String, String> userToContact = new Map<String, String>();
  List<Community_Activity__c> listActivities = new List<Community_Activity__c>();
  
  if(Trigger.isInsert){
      for(Idea ide : Trigger.new){
          portalUsers.add(ide.createdById);
      }
      
      for(User u : [select Id, contactId from User where Id IN :portalusers and contactId != null]){
          userToContact.put(u.Id, u.contactId);
      }
      
      for(Idea ide : Trigger.new){
          if(userToContact.containsKey(ide.createdById)){
              Community_Activity__c commAct = new Community_Activity__c(contact__c = userToContact.get(ide.createdById));
              commAct.Type__c = 'Idea';
              //commAct.date__c = Date.Today();
              commAct.Activity_Id__c = ide.id;
              commAct.Posted_date__c = System.now();
              commAct.Title__c = ide.Title;
              commAct.Link__c = '/ideas/viewIdea.apexp?id=' + ide.Id;
              listActivities.add(commAct);
          }
      }
      
      if(listActivities.size() > 0){
          insert listActivities ;
      }
  }else if(Trigger.isUpdate){
      System.debug('=======update===========');
     
      Set<String> commentIds = new Set<String>();
      Map<String,string> commentToContact = new Map<String,String>();
      for(Idea ide : Trigger.new){
          if(ide.LastCommentId != Trigger.oldMap.get(ide.Id).LastCommentId){
              System.debug('====if 1==');
              commentIds.add(ide.LastCommentId);
          }
      }
      
      for(IdeaComment ideComm : [Select id, CreatedById,CreatedBy.ContactId from IdeaComment where Id IN : commentIds and CreatedBy.ContactId != null]){
         commentToContact.put(ideComm.Id, ideComm.CreatedBy.ContactId);
      }
      
     
      for(Idea ide : Trigger.new){
          if(commentToContact.containsKey(ide.LastCommentId)){
              Community_Activity__c commAct = new Community_Activity__c(contact__c = commentToContact.get(ide.LastCommentId));
              commAct.Type__c = 'IdeaComment';
              //commAct.date__c = Date.Today();
              commAct.Activity_Id__c = ide.LastCommentId; 
              commAct.Posted_date__c = System.now();
              commAct.Title__c = ide.Title;
              commAct.Link__c = '/ideas/viewIdea.apexp?id=' + ide.Id + '&cid=' +ide.LastCommentId;
              listActivities.add(commAct);
          }
      }
       System.debug('====listActivities=='+listActivities);
      if(listActivities.size() > 0){
          insert listActivities ;
      }
  }
}