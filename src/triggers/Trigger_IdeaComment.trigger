/**
 *  Description     :   This trigger to handle all the pre and post processing operation for IdeaComment
 *
 *  Created By      :   
 *
 *  Created Date    :   02/12/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_IdeaComment on IdeaComment (after insert) {
	
	//Check for IdeaComment trigger flag
	if(!IdeaCommentTriggerHelper.Execute_IdeaComment_Trigger)
		return;
		
	//Check for the request type
    if(Trigger.isAfter) {
        
        //Check for trigger event
        if(Trigger.isInsert) {
        	
        	//Call Helper class method to notify user about comment
        	IdeaCommentTriggerHelper.sendNotificationToUser(Trigger.new);
        }
    }
}