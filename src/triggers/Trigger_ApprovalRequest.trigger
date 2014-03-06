/**
 *  Description     :   This trigger to handle all the pre and post processing operation for ApprovalRequest
 *
 *  Created By      :   
 *
 *  Created Date    :   02/13/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_ApprovalRequest on Apttus_Approval__Approval_Request__c (after insert, after update, before insert, before update) {
	
	//Check for Approval Request trigger flag
	if(!ApprovalRequestTriggerHelper.execute_ApprovalRequest_Trigger)
		return;
		
	//Check the request type
	if(Trigger.isAfter){
		
		//Check the event type
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method
			ApprovalRequestTriggerHelper.validateQuote(Trigger.new);
		}
	}
	
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event type
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//
			ApprovalRequestTriggerHelper.validateAppReqRelatedQuote(Trigger.new);
		}
	}
}