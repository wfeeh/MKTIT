/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Case Milestone
 *
 *  Created By      :   
 *
 *  Created Date    :   02/17/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_CaseMilestone on Case_Update_Milestones__c (after update) {
	
	//Check the request type
	if(Trigger.isAfter){
		
		//Check the event
		if(Trigger.isUpdate){
			
			//Call the helper class's method to insert new record of Case Miletone 
			CaseMilestoneTriggerHelper.upadteCaseMileStone(Trigger.newMap, Trigger.oldMap);
		}
	}
}