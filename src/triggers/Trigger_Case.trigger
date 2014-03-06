/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Case
 *
 *  Created By      :   
 *
 *  Created Date    :   01/23/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Case on Case (before insert , before update, before delete, after insert, after update) {
    
    if(!CaseTriggerHelper.Execute_Case_Trigger)
    	return;
    	
    //Check for the request type
    if(Trigger.isBefore && !CaseTriggerHelper.execute_Trigger_IsBefore){
        
        //Check for event
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Call helper class method to validate Entitlement and Asset on case
            CaseTriggerHelper.validateCaseContact(Trigger.new, Trigger.isInsert);
            
        }

        //Check for event
        if(trigger.isUpdate){
            
            //Call helper class method  to validate the value of BuisnessHoursId
            CaseTriggerHelper.validateBuisnessHoursId(trigger.new);
            
             //Call helper class method to update service time
            CaseTriggerHelper.validateSwitchAndServiceDate(Trigger.new, Trigger.oldMap);
        }
        //Set flag to true to stop recursive call
        CaseTriggerHelper.execute_Trigger_IsBefore = true;
    }
    
    //Check for Event
    if(Trigger.isAfter && !CaseTriggerHelper.execute_Trigger_IsAfter) {
    	
    	//Check for Event
    	if(Trigger.isInsert || Trigger.isUpdate) {
    	
    		//Call helper class method to validate the completin date
    		 CaseTriggerHelper.validateCaseCompletionDate(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate );
    		 
    		 //Call helper class method to create Case update milestone
    		 CaseTriggerHelper.validateCaseAndRelatdeMiletone(Trigger.new, Trigger.oldMap, Trigger.isInsert);
    	}
    	
    	//Check for event type
    	if(Trigger.isInsert){
    		 
    		//Calling helper class
    		CaseTriggerHelper.caseReceivedNotificationEmail(trigger.newMap);
    		
    		//Call the helper class's method SM Account and SM Contact related to email in email to case
    		CaseTriggerHelper.validateValueOfSituationAccAndCon(trigger.new);
    	}
    	
    	//Check for event type
    	if(Trigger.isUpdate) {
    		
    		//Call the helper class method to sent email notifiaction on close case
    		CaseTriggerHelper.sendSurveyOnCaseClose(Trigger.new, Trigger.oldMap);
    	}
    	
    	//Set flag to true to stop recursive call
    	CaseTriggerHelper.execute_Trigger_IsAfter = true;
    }
	
	//Check for request type
	if((Trigger.isAfter && Trigger.isInsert)||(Trigger.isBefore && (Trigger.isUpdate ||  Trigger.isDelete))){
		
		//Call helper class's method to validate the fields of JBCXM alert (object)
		CaseTriggerHelper.validateValuesOfJBCXMAlert(Trigger.new, Trigger.oldMap, Trigger.isDelete);
		
	}
}