/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Account
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_EmailMessage on EmailMessage (before insert, after insert) {
	
	//Check for Account trigger flag
	if(!EmailMessageTriggerHelper.Execute_Entitlement_Trigger)
		return;
	
	//Check for the request type
    if(Trigger.isBefore) {
        
        //Check for trigger event
        if(Trigger.isInsert) {
        	
        	//Call EmailMessageTriggerHelper class method to create new Case
        	EmailMessageTriggerHelper.createCase(Trigger.new);
        }
    }
    
	//Check for the request type
    if(Trigger.isAfter) {
        
        //Check for trigger event
        if(Trigger.isInsert) {
        	
        	//Call EmailMessageTriggerHelper class method to create new CaseComment
        	EmailMessageTriggerHelper.createCaseComment(Trigger.new);
        }
    }
}