/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Clarizen Project.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/17/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_ClarizenProject on clzV5__Clarizen_Project__c (after insert, after update) {
	
	//Check for Clarizen Project trigger flag
	if(!ClarizenProjectTriggerHelper.execute_ClarizenProject_Trigger)
		return;
	
	//Check the request type
	if(Trigger.isAfter){
		
		//Check the event type
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method to insert a new record of JBCXM Milestones
			ClarizenProjectTriggerHelper.validateClarizenJBCXMMilestone(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
			
		}
		if(Trigger.isUpdate){
			
			//Call the helper class's method to schedule the class for sending mail of contacl on clarizen Project mail addresses.
			ClarizenProjectTriggerHelper.validateSMBSendSurveyMail(Trigger.new, Trigger.oldMap);
		}
	}
    
}