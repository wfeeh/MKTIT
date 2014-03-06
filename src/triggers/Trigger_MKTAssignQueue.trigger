/**
 *  Description     :   This trigger to handle all the pre and post processing operation for MKT Assign Queue
 *
 *  Created By      :   
 *
 *  Created Date    :   02/18/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_MKTAssignQueue on MKT_AssignQueue__c (before insert, before update) {
    
    //Check  the request type
    if(Trigger.isBefore){
        
        //check the event type
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //Call the helper class's method to schedule batch class
            MKTAssignQueueTriggerHelper.validateApexJob(Trigger.New, Trigger.oldMap);
        }
    }
}