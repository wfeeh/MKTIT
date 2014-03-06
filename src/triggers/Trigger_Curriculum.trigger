/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Curriculum.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Curriculum on lmscons__Curriculum__c (before insert, before update) {
	
	//Check for curriculum trigger flag
	if(!CurriculumTriggerHelper.execute_Curriculum_Trigger)
		return;
	
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method diaplay the error on product on appropraite condition.
			CurriculumTriggerHelper.validateCurProduct(Trigger.new, Trigger.oldMap);
			
			//Call the helper class's method to update the MKT Total hurs field of curriculum 
			CurriculumTriggerHelper.validateMKTTotalHours(Trigger.new, Trigger.oldMap);
		}
	}

}