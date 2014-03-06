/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Sales Order.
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Revision Logs   :   V_1.0 - Create
 *
 **/
trigger Trigger_SalesOrder on Sales_Order__c (before insert, before update) {
	
	//Check for Sales Order trigger flag
	if(!SalesOrderTriggerHelper.execute_SalesOrder_Trigger)
		return;
	
	//Check the request type	
	if(Trigger.isBefore){
		
		//Check the event 
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method to populate the value in Opportunity Order(field) value with appropriate condition
			SalesOrderTriggerHelper.validateOpportunityOrder(Trigger.new); 
		}
	}
}