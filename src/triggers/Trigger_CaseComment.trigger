/**
 *  Description     :   This trigger to handle all the pre and post processing operation for CaseComment
 *
 *  Created By      :   
 *
 *  Created Date    :   02/8/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_CaseComment on CaseComment (after insert, after update) {
	
	//Check the  Case Comment trigger flag
	 if(!CaseTriggerHelper.Execute_Case_Trigger)
    	return;
    	
	//Chek for request type
	if(Trigger.isAfter){
		
		//Check the event type
		if(Trigger.isInsert){
			
			//call the helper class's method to validate the value of CompletionDate (field)of caseMilestone 
			CaseCommentTriggerHelper.validateCMCompletionDate(Trigger.new);
			
			//call the helper class's method to validate error message 
			CaseCommentTriggerHelper.validateErrorMessage(Trigger.new);
		}
		
		//Check the event  type 
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method to update the case and upsert the case Update Milestone
			CaseCommentTriggerHelper.validateCaseUpdateMileStone(Trigger.new);
		}
		
	}
}