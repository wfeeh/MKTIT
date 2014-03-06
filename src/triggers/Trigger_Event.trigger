/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Event.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Event on lmsilt__Event__c (before insert, before update) {
	
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method diaplay the error on product on appropraite condition.
			EventTriggerHelper.validateEventProduct(Trigger.new, Trigger.oldMap);
		}
	}
}