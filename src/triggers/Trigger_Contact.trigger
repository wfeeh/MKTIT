/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Contact
 *
 *  Created By      :   
 *
 *  Created Date    :   01/23/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Contact on Contact (after insert, after update, before update) {
    
    //Check for variable to execute trigger
    if(!ContactTriggerHelper.Execute_Contact_Trigger)
    	return;
    
    //Check for the request type
    if(trigger.isBefore){
        
        //Check for trigger event
        if(trigger.isUpdate){
            
            //Call helper class's method used to populate the values of contact
            ContactTriggerHelper.createMilestones(Trigger.New, Trigger.oldMap);

        }
    }
    //Check for the request type
    if(trigger.isAfter){
        
        //Check for trigger event
        if(trigger.isInsert || trigger.isUpdate){
            
            //Call helper class's method used to populate the values of contact
            ContactTriggerHelper.validateGSDataOnAccountToCreateGSContact(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
        	
            //Call helper class's method used to populate the values of contact
            ContactTriggerHelper.synchWithBoulderLogic(Trigger.New, Trigger.oldMap);
        }
    }
}