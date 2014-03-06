/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Sales Invoice Item
 *
 *  Created By      :   
 *
 *  Created Date    :   02/25/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_SalesInvoiceItem on Sales_Invoice_Item__c (before insert, before update) {
	
	//Check the request type
	if(Trigger.isBefore){
		
		//Check the event type
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class's method to validate the opp Line Total
			SalesInvoiceItemTriggerHelper.validateOppLineTotal(Trigger.new);
		}
	}
}