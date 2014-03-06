/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Question
 *
 *  Created By      :   
 *
 *  Created Date    :   02/12/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
	
trigger Trigger_Question on Question (after insert) {
	
	//Check for Question trigger flag
	if(!QuestionTriggerHelper.execute_Question_Trigger)
		return;
	
	//Check for request type
	if(Trigger.isAfter) {
		
		//Check for event type
		if(Trigger.isInsert) {
			
			//Call helper class method to create new Community_Activity__c records
			QuestionTriggerHelper.createCommunityActivity(Trigger.newMap);
		}
	}
}