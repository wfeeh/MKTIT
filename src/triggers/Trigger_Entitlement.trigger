/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Entitlement
 *
 *  Created By      :   
 *
 *  Created Date    :   02/10/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_Entitlement on Entitlement (before insert, before update, after insert, after update) {
	
	//Check variable to execute trigger
	if(!EntitlementTriggerHelper.Execute_Entitlement_Trigger)
		return;
	
	//Check for the request type
	if(Trigger.isBefore) {
		
		//Check for event type
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call helper class method to update subscription End Date
			EntitlementTriggerHelper.validateSubscriptionEndDate(Trigger.new, Trigger.oldMap);
		}
	}
	
	//Check for the request type
	if(Trigger.isAfter) {
		
		//Check for event type
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call helper class method to update Account related to Entitlement
			EntitlementTriggerHelper.updateAccountSupportLevel(Trigger.new, Trigger.oldMap);
		}
	}
}