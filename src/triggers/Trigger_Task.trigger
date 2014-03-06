/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Task
 *
 *  Created By      :   
 *
 *  Created Date    :   02/07/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 */
trigger Trigger_Task on Task (after insert, after update) {
    
     //Check for Request
    if(Trigger.isAfter) {
        
        //Check for Event
        if(Trigger.isInsert || Trigger.isUpdate) {
        
            //Call helper class method to validate the completin date
             TaskTriggerHelper.upsertTaskClone(Trigger.new, Trigger.oldMap);

        }
    }
}