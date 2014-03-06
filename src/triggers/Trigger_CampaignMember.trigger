/**
 *  Description     :   This trigger to handle all the pre and post processing operation for CampaignMember
 *
 *  Created By      :   
 *
 *  Created Date    :   02/8/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_CampaignMember on CampaignMember (after insert, after update) {
	
	//Check for flag to
	if(!CampaignMemberTriggerHelper.Execute_CampaignMember_Trigger)
		return;
	
	//Check for the request type
	if(Trigger.isAfter) {
		
		//Check for trigger event
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call helper class method
			CampaignMemberTriggerHelper.sendHttpRequest(Trigger.new, Trigger.oldMap, Trigger.size);
			
		} 
	}

}