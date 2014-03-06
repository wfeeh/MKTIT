/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Support News(Marketo News)
 *
 *  Created By      :   
 *
 *  Created Date    :   02/18/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_SupportNews on Marketo_News__c (after insert, after update) {
	
	//Check for request typee
	if(Trigger.isAfter) {
		
		//Check for trigger event
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call Helper class method
			SupportNewsTriggerHelper.sendNotification(Trigger.new, Trigger.oldMap);
		}
	}

}