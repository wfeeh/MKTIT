/**
 *  Description     :   This trigger to handle all the pre and post processing operation for User
 *
 *  Created By      :   
 *
 *  Created Date    :   02/11/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_User on User (after insert, after update) {
    
    //Check for user trigger flag
    if(!UserTriggerHelper.Execute_User_Trigger)
        return;
        
    //Check the request type
    if(Trigger.isAfter){
        
        //Check the event type
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //Call helper class's method to send notification  to user of the same name
            UserTriggerHelper.duplicateUserNameNotification(Trigger.New, Trigger.oldMap);
            
            //Call helper class method to validate Munchkin_ID__c on related contact
            UserTriggerHelper.validateContactMunchkinAndTimeZone(Trigger.new, Trigger.oldMap);
        }
        
        //Check the event type
        if(Trigger.isInsert){
            
            //Call the helper class's method to call the manage package class
            UserTriggerHelper.validateConsumerUser(Trigger.New);
        }
    }
}