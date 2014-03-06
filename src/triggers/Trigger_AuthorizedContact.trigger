/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Authorized Contact
 *
 *  Created By      :   
 *
 *  Created Date    :   02/22/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_AuthorizedContact on Authorized_Contact__c (after delete, after insert, after update) {
	
	//Check the request type
	if(Trigger.isAfter){
		
		//Check the event type
		if(Trigger.isInsert){
			
			//Call the helper Class's method for sending notifiaction to new authorize contact
			AuthorizeContactTriggerHelper.sendingAuthConNotification(Trigger.New);
		}
		//Check the event type
		if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
			
			//Call the helper class's method to validate the Support contact email
			AuthorizeContactTriggerHelper.validateAContact(Trigger.new, Trigger.oldMap); 
		}
	}
}