/**
 *  Description    :   Helper class for Trigger_IdeaComment trigger.
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

public with sharing class IdeaCommentTriggerHelper {
	
	//Boolean variable for account trigger execution
    public static Boolean Execute_IdeaComment_Trigger = true;
    
    /**
     *	@description	:	Method to send Email notification to IdeaComment User if Idea of this is related to Community_Subscription__c.
     *
     *	@args			:	List<IdeaComment>
     *
     *	@return			:	void
     *
     **/
	public static void sendNotificationToUser(List<IdeaComment> ideaComments) {
		
		//Set to hold Idea Id
		Set<Id> setIdeaIds = new Set<Id>();
		
		//Set to hold Created By Id
		Set<Id> setCreatedByIds = new Set<Id>();
		
		//Map to hold List of Community Subscription corresponding to Idea Id
		Map<Id, List<Community_Subscription__c>> mapIdeaIdAnCS = new Map<Id, List<Community_Subscription__c>>();
		
		//Loop through IdeaComment
		for(IdeaComment iC : ideaComments) {
			
			//Check for Idea Id
			if(iC.IdeaId != null) {
				
				//Add Idea Id in set
				setIdeaIds.add(iC.IdeaId);
				setCreatedByIds.add(iC.CreatedById);	
			}
		}
		
		//Query through Community_Subscription__c
		for(Community_Subscription__c cS : [Select Id, User__c, User__r.Email, User__r.ContactId, User__r.Contact.Account.Type, Idea_Question_Id__c
											From Community_Subscription__c Where Idea_Question_Id__c IN : setIdeaIds AND User__c != null AND User__r.ContactId != null
												AND  User__c NOT IN : setCreatedByIds AND User__r.Contact.Account.Type NOT IN : Constants.SET_ACCOUNT_TYPE_FOR_IDEA]) {
													
			//Check for Idea Id in map
			if(mapIdeaIdAnCS.containsKey(cS.Idea_Question_Id__c)) {
				
				//Add Community_Subscription__c record in map
				mapIdeaIdAnCS.get(cS.Idea_Question_Id__c).add(cS);
			} else {
				
				//Populate Map with values
				mapIdeaIdAnCS.put(cS.Idea_Question_Id__c, new List<Community_Subscription__c>{cS});
			} 
		}
		
		//Check for Map size
		if(mapIdeaIdAnCS.size() > 0) {
			
			//Query through EmailTemplate
			List<EmailTemplate> eT = [select Id from EmailTemplate where DeveloperName =: Label.EMAILTEMPLATE_MARKETO_COMMUNITY_IDEA_COMMENT LIMIT 1];
			
			//Call EmailHandler class method to send email notification
			EmailHandler.sendEmail(eT, mapIdeaIdAnCS);
		}
	}
}