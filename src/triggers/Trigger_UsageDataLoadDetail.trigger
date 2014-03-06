/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Usage Data Load Detail
 *
 *  Created By      :   
 *
 *  Created Date    :   02/14/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_UsageDataLoadDetail on Usage_Data_Load_Detail__c (after insert) {
	
	//Check the request type
	if(Trigger.isAfter){
		
		//Check the event type
		if(Trigger.isInsert){
			
			//Call the helper class's method is to execute batch
			UsageDataLoadDetailTriggerHelper.executeWeeklyUsageDataBatch(Trigger.new);
		}
	}
}