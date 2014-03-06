/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Article FeedBack
 *
 *  Created By      :   
 *
 *  Created Date    :   02/14/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
 
trigger Trigger_ArticleFeedBack on Article_FeedBack__c (after insert) {
	
	//Check for Account trigger flag
	if(!ArticleFeedbackTriggerHelper.execute_ArticleFeedBack_Trigger)
		return;
		
	//Check the request type
	if(Trigger.isAfter){
		
		//Check the event type
		if(Trigger.isInsert){
			
			//Call the helper class's method to send the email to the user of article feedback
			ArticleFeedbackTriggerHelper.articleFeedbackNotification(Trigger.new);
		}
	}
}