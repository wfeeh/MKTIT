/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Reply
 *
 *  Created By      :   
 *
 *  Created Date    :   02/12/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_Reply on Reply (after insert) {
	
	//Check for Question trigger flag
	if(!ReplyTriggerHelper.execute_Reply_Trigger)
		return;
	
	//Check for request type
	if(Trigger.isAfter) {
		
		//Check for event type
		if(Trigger.isInsert) {
			
			//Call helper class method to create Community_Activity__c and ReplyIdeaSchedulerLog__c record
			ReplyTriggerHelper.createCAAndRISLog(Trigger.newMap);
		}
	}

}