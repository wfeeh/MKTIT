/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Asset
 *
 *  Created By      :   
 *
 *  Created Date    :   02/07/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
 
trigger Trigger_Asset on Asset (after insert, after update) {
	
	//Check for request
	if(trigger.isAfter){
		
		//Check for event
		if(trigger.isUpdate){
			
			//Call the helper class's method to update the Entitlement EndDate( field)
			AssetTriggerHelper.validateEntitleEndDate(Trigger.New, Trigger.oldMap);
		}	
		//Check for event
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call helper class method to update related account and Asset
			AssetTriggerHelper.upateAccountOnAsset(Trigger.new, Trigger.oldMap);
		}
	}
}