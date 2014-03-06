/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Account
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_Account on Account (before insert, before update,after insert, after update) {
	
	//Check for Account trigger flag
	if(!AccountTriggerHelper.Execute_Account_Trigger)
		return;
    
    //Check for the request type
    if(Trigger.isBefore) {
        
        //Check for trigger event
        if(Trigger.isUpdate) {
            
            //Call helper class's method to update customer success manager and account executive
            AccountTriggerHelper.validateSuccessManagerAndExecutive(Trigger.new, Trigger.oldMap);
            
        }
        
        //Check for trigger event
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //Call helper class's method to update the accoun history field according to the rules
            AccountTriggerHelper.validateAccountScorer(Trigger.New);
        }
    }
    
    //check for the request type
    if(Trigger.isAfter){
        
        //Check for trigger event
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //Call helper class to create task on account
            AccountTriggerHelper.accCreateTasks(Trigger.New , Trigger.oldMap);
            AccountTriggerHelper.chatterPost(Trigger.New , Trigger.oldMap);
        }
    }
}