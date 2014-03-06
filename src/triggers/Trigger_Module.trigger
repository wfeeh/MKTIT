/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Module.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Module on lmscons__Training_Content__c (before insert, before update) {
	
	//Check for Module trigger flag
	if(!ModuleTriggerHelper.execute_Module_Trigger)
		return;
		
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method diaplay the error on product on appropraite condition.
			ModuleTriggerHelper.validateModuleProduct(Trigger.new, Trigger.oldMap);
			
			//Call the helper class's method to validate the MKT total hour (field)
			ModuleTriggerHelper.validateModuleTotalHours(Trigger.new, Trigger.oldMap);
		}
	}
}