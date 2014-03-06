/**
 *  Description    :   Helper class for Trigger_Reply trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/12/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/

public without sharing class ReplyTriggerHelper {
	
	//Boolean variable for Reply trigger execution
    public static Boolean execute_Reply_Trigger = true;
    
    /**
     *	@description	:	Method to create new Community_Activity and ReplyIdeaSchedulerLog__c records on the Reply creation
     *						Case 1. Create ReplyIdeaSchedulerLog__c record when new reply is inserted
     *						Case 2. Create Community_Activity__c if reply by Community user
     *
     *	@args			:	Map<Id, Reply>
     *
     *	@return			:	void
     *
     **/
	public static void createCAAndRISLog(Map<Id, Reply> mapReplies) {
		
		//List of Community_Activity__c
		List<Community_Activity__c> cAs = new List<Community_Activity__c>();
		
		//List of ReplyIdeaSchedulerLog__c
		List<ReplyIdeaSchedulerLog__c> rISLogs = new List<ReplyIdeaSchedulerLog__c>();
		
		//Loop through Reply
		for(Reply reply : [Select Id, Name, CreatedById, CreatedBy.ContactId, QuestionId From Reply Where Id IN : mapReplies.keySet()]) {
			
			//Instance of ReplyIdeaSchedulerLog__c
			ReplyIdeaSchedulerLog__c rISL = new ReplyIdeaSchedulerLog__c();
			
			//Populate field values
			rISL.Reply_Idea_Id__c = reply.Id;
			rISL.SentStatus__c = false;
			rISL.Type__c = Constants.REPLYIDEASCHEDULERLOG_TYPE_REPLYPOSTED;
			
			//Add in list
			rISLogs.add(rISL);
			
			//Check for Contact Id
			if(reply.CreatedBy.ContactId != null) {
				
				//Instance of Community_Activity__c
				Community_Activity__c cA = new Community_Activity__c();
				
				//Populate field values
				cA.Activity_Id__c = reply.Id;
				cA.Posted_date__c = System.now();
				cA.Type__c = Constants.COMMUNITY_ACTIVITY_TYPE_QUESTIONCOMMENT;
				cA.Link__c = '/answers/viewQuestion.apexp?id=' + reply.QuestionId;
				cA.Contact__c = reply.CreatedBy.ContactId;
				
				//Check for Title 
				if(reply.Name != null && reply.Name != '')
					cA.Title__c = reply.Name;
				
				//Add in list
				cAs.add(cA);
			}
		}
		
		//Check for list(rISLogs) size
		if(rISLogs.size() > 0)
			insert rISLogs;
		
		//Check for list(cAs) size
		if(cAs.size() > 0)
			insert cAs;
	}
}