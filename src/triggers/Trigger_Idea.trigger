/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Idea
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Idea on Idea (after update, after insert) {
	
	//Check for Idea trigger flag
	if(!IdeaTriggerHelper.Execute_Idea_Trigger)
		return;
		
	//Check the request type
	if(Trigger.isAfter){
		
		//check the event type
		if(Trigger.isUpdate){
			
			//call the helper class's method  to validate the Ideas Status
			IdeaTriggerHelper.validateIdeaStatus(Trigger.New, Trigger.oldMap);
		}
		if (Trigger.isInsert || Trigger.isUpdate){
			
			//call the helper class's method to Validate the /community activity
			IdeaTriggerHelper.validateCommunityActivity(Trigger.newMap, Trigger.oldMap);
		}
	} 
}