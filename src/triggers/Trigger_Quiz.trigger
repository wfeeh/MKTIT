/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Quiz.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Quiz on lmscons__Quiz__c (before insert, before update) {

	//Check for Quiz trigger flag
	if(!QuizTriggerHelper.execute_Quiz_Trigger)
		return;
		
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method diaplay the error on product on appropraite condition.
			QuizTriggerHelper.validateQuizProduct(Trigger.new, Trigger.oldMap);
		}
	}
}