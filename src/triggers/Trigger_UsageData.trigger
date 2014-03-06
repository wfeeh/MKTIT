/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Usage Data.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/26/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_UsageData on JBCXM__UsageData__c (before insert, before update) {
	
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event type
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//call the helper class's method to valiadte the value of Marketo User
			UsageDataTriggerHelper.validateMarketoUser(Trigger.new);
		}
	}
}