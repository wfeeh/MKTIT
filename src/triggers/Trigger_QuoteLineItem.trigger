/**
 *  Description     :   This trigger to handle all the pre and post processing operation for QuoteLineItem
 *
 *  Created By      :   
 *
 *  Created Date    :   02/12/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/

trigger Trigger_QuoteLineItem on QuoteLineItem (after insert, after update, after delete) {
	
	//Check for QuoteLineItem trigger flag
	if(!QuoteLineItemTriggerHelper.execute_QuoteLineItem_Trigger)
		return;
	
	//Check for the request type
	if(Trigger.isAfter) {
		
		//Check for event type
		if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
			
			//Call helper class method to update Quote
			QuoteLineItemTriggerHelper.validateQuote(Trigger.new, Trigger.old);
		}
	}
}