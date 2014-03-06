/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Roaster.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/20/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Roster on lmsilt__Roster__c (after insert, after update) {
    
    //check the request type
    if(Trigger.isAfter){
        
        //Check the event type
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //call the helper class to insert a new record of MKT Email Workflow in CyberU after finding the appropriate condition
            RosterTriggerHelper.validateMKTEmailWorkflow(Trigger.New, Trigger.oldMap, Trigger.isInsert);
        }
    }
}