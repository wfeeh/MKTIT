/**
 *  Description    :   Helper class for Trigger_Question trigger.
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

public without sharing class QuestionTriggerHelper {
	
	//Boolean variable for Question trigger execution
    public static Boolean execute_Question_Trigger = true;
    
    /**
     *	@description	:	Method to create Community_Activity__c record according if Question is inserted by community users
     *
     *	@args			:	Map<Id,Question>
     *
     *	@return			:	void
     *
     **/
	public static void createCommunityActivity(Map<Id, Question> mapQuestions) {
		
		//List of Community_Activity__c
		List<Community_Activity__c> cAs = new List<Community_Activity__c>();
		
		//Loop through Community_Activity__c
		for(Question question : [Select Id, CreatedById, CreatedBy.ContactId, Title From Question Where Id IN : mapQuestions.keySet() AND CreatedBy.ContactId != null]) {
			
			//Instance of Community_Activity__c
			Community_Activity__c cA = new Community_Activity__c();
			
			//Populate field values
			cA.Activity_Id__c = question.Id;
			cA.Posted_date__c = System.now();
			cA.Type__c = Constants.COMMUNITY_ACTIVITY_TYPE;
			cA.Link__c = '/answers/viewQuestion.apexp?id=' + question.Id;
			cA.Contact__c = question.CreatedBy.ContactId;
			
			//Check for Title 
			if(question.Title != null && question.Title != '')
				cA.Title__c = question.Title;
			
			//Add in list
			cAs.add(cA);								
		}
		
		//Check for list size
		if(cAs.size() > 0)
			insert cAs;
	}
}