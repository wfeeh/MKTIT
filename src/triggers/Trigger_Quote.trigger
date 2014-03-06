/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Quote
 *
 *  Created By      :
 *
 *  Created Date    :   02/12/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_Quote on Quote (after insert, after update) {
	
	//Check for Account trigger flag
	if(!QuoteTriggerHelper.execute_Quote_Trigger)
		return;
	
	//Check for request type
	if(Trigger.isAfter) {
		
		//Check for request
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call helper class method to update related opportunity
			QuoteTriggerHelper.validateOppOwnerRoleMapping(Trigger.new);
		}
	}
}