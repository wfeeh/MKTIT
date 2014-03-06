/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Roster Session
 *
 *  Created By      :   
 *
 *  Created Date    :   02/18/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_RosterSession on lmsilt__GoToTraining_Session__c (after delete, after insert, after undelete, after update) {
	
	//Check for request Type
	if(Trigger.isAfter) {
		
		//Check for trigger even
		if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUnDelete) {
			
			//Call helper class method to update Roster Status
			RosterSessionTriggerHelper.validateRosterStatus(Trigger.new, Trigger.oldMap);
		}
	}
}