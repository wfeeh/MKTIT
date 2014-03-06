/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Class.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/22/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Class on lmsilt__Class__c (before insert, before update) {
	
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event type
		if(trigger.isInsert || Trigger.isUpdate){
			
			//Call the helpe class method to validate tha MKT Total hours
			ClassTriggerHelper.validateClassMKTTotalHours(Trigger.New, Trigger.oldMap);
		}
	}
}