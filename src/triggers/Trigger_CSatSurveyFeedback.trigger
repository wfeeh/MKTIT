/**
 *  Description     :   This trigger to handle all the pre and post processing operation for CSatSurveyFeedback 
 *
 *  Created By      :   
 *
 *  Created Date    :   02/15/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_CSatSurveyFeedback on CSatSurveyFeedback__c (after insert) {
	
	//Check for CSatSurveyFeedback trigger flag
	if(!CSatSurveyFeedbackTriggerHelper.execute_CSatSurveyFeedback_Trigger)
		return;
	
	//Check the request type
	if(Trigger.isAfter){
		
		//Check the event type
		if(Trigger.isInsert){
			
			//Call the helper class's method to validate the case.
			 CSatSurveyFeedbackTriggerHelper.validateCase(Trigger.New);
			 
			 //Call the helper class's to validate the JBCXM Milestone.
			 CSatSurveyFeedbackTriggerHelper.validateCSFJBCXMilestone(Trigger.New);
		}
	}
}