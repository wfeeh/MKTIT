/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Certification History
 *
 *  Created By      :   
 *
 *  Created Date    :   02/14/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
	
trigger Trigger_CertificationHistory on Certification_History__c (before insert, before update, after insert, after update) {
	
	//Check the  Certification History trigger flag
	if(!CertificationHistoryTriggerHelper.execute_Cretification_History_Trigger)
    	return;
    
    //Check for request type
    if(Trigger.isBefore) {
    	
    	//Check for event type
    	if(Trigger.isInsert || Trigger.isUpdate) {
    		
    		//Call helper class method to sent information about contact if exam result is pass
    		CertificationHistoryTriggerHelper.validateAccountAndEmail(Trigger.new);
    	}
    }
    
    //Check for request type
    if(Trigger.isAfter) {
    	
    	//Check for event type
    	if(Trigger.isInsert || Trigger.isUpdate) {
    		
    		//Call helper class method to sent information about contact if exam result is pass
    		CertificationHistoryTriggerHelper.userCertification(Trigger.new, Trigger.oldMap);
    		
    		//Call helper class method to create
    		CertificationHistoryTriggerHelper.createJBCXMMilstone(Trigger.new, Trigger.oldMap);
    	}
    }
}