/**
 *  Description     :   This trigger to handle all the pre and post processing operation for TaskClone
 *
 *  Created By      :   
 *
 *  Created Date    :   02/14/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_TaskClone on TaskClone__c (after insert, after update) {
	
	//Check the  Case Comment trigger flag
	 if(!TaskCloneTriggerHelper.execute_TaskClone_Trigger)
    	return;
    
    //Check for request
    if(Trigger.isAfter) {
    	
    	//Check for event type
    	if(Trigger.isInsert || Trigger.isUpdate) {
    		
    		//Call helper class method to create new Task
    		TaskCloneTriggerHelper.createTask(Trigger.new, Trigger.oldMap);
    	}
    }
}