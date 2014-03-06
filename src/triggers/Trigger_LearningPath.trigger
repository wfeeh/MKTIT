/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Learning Path.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_LearningPath on lmscons__Learning_Path__c (before insert, before update) {
	
	//Check for curriculum trigger flag
	if(!LearningPathTriggerHelper.execute_LearningPath_Trigger)
		return;
		
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method diaplay the error on product on appropraite condition.
			LearningPathTriggerHelper.validateLPProduct(Trigger.new, Trigger.oldMap);
			
			//Call the helper class's method to validate the MKT total hour (field)
			LearningPathTriggerHelper.validateLPTotalHours(Trigger.new, Trigger.oldMap);
		}
	}
}