trigger RecordIdea_OnUpdate_temp on Idea (after update) {
  Set<String> portalUsers = new Set<String>();
  Map<String, String> userToContact = new Map<String, String>();
  Map<String, List<IdeaComment>> mapComments = new Map<String, List<IdeaComment>> ();
  Map<String, Idea> mapIdeas = new Map<String, Idea>();
  
  List<Community_Activity__c> listActivities = new List<Community_Activity__c>();
  	  for(Idea ide : Trigger.new){
          portalUsers.add(ide.createdById);
      }
      
      for(Idea myide : [Select i.ParentIdeaId, i.NumComments, i.CommunityId, i.Categories, CreatedDate, (Select Id, IdeaId, Idea.Title, CreatedById, CreatedDate From Comments) From Idea i where Id IN:Trigger.New]){
      	mapIdeas.put(myide.id, myide);
      	mapComments.put(myide.Id, myide.Comments);
      	for(IdeaComment iCommnent : myide.Comments){
      		portalUsers.add(iCommnent.createdById);
      	}
      }
      
      for(User u : [select Id, contactId from User where Id IN :portalusers and contactId != null]){
          userToContact.put(u.Id, u.contactId);
      }
      
      for(Idea ide : Trigger.new){
          if(userToContact.containsKey(ide.createdById)){
              Community_Activity__c commAct = new Community_Activity__c(contact__c = userToContact.get(ide.createdById));
              commAct.Type__c = 'Idea';
              //commAct.date__c = Date.Today();
              commAct.Activity_Id__c = ide.Id; 
              commAct.Posted_date__c = mapIdeas.get(ide.id).CreatedDate;
              commAct.Title__c = ide.Title;
              commAct.Link__c = '/ideas/viewIdea.apexp?id=' + ide.Id;
              listActivities.add(commAct);
          }
          if(mapComments.containsKey(ide.id) && mapComments.get(ide.id) != null){
              	for(IdeaComment icomm : mapComments.get(ide.id)){
              		  if(userToContact.containsKey(icomm.createdById)){
	              		  Community_Activity__c commAct = new Community_Activity__c(contact__c = userToContact.get(icomm.createdById));
			              commAct.Type__c = 'IdeaComment';
			              //commAct.date__c = Date.Today();
			              commAct.Activity_Id__c = icomm.id; 
              			  commAct.Posted_date__c = icomm.CreatedDate;
			              commAct.Title__c = icomm.idea.Title;
			              commAct.Link__c = '/ideas/viewIdea.apexp?id=' + icomm.ideaId + '&cid=' +icomm.id;
			              listActivities.add(commAct);
              		  }
              	}
          }
          
      }
      
      if(listActivities.size() > 0){
          insert listActivities ;
      }
}