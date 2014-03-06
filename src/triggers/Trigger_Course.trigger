/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Course.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/20/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Course on lmscons__Training_Path__c (before insert, before update) {
    
    //Check for Training Path trigger flag
    if(! CourseTriggerHelper.execute_TrainingPath_Trigger)
        return;
    
    //Check the request type
    if(Trigger.isBefore){
        
        //Check the event
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //Call the helper class's method to update the MKT Total hour field
             CourseTriggerHelper.updateTotalHours(Trigger.new, Trigger.oldMap);
            
            //Call the helper class's method diaplay the error on product on appropraite condition.
             CourseTriggerHelper.valiadteProduct(Trigger.new, Trigger.oldMap);
        }
    }
}