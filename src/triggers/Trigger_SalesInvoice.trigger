/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Sales Invoice
 *
 *  Created By      :   
 *
 *  Created Date    :   02/24/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_SalesInvoice on Sales_Invoice__c (after insert, after update, after delete, before insert, before update) {
    
    //Check the request type
    if(Trigger.isBefore){
        
        //Check the event type
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //call the helper class to validate the value of opportunity Invoices 
            SalesInvoiceTriggerHelper.validateOpp(Trigger.new);
        }
    }
    
    //Check the request type
    if(Trigger.isAfter){
        
        //check the event type
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
            
            //Call the helper class's method to populate the Latest Payement Date (field)value of opportunity
            SalesInvoiceTriggerHelper.validateLatestPaymentDate(Trigger.new, Trigger.oldMap);
        }
    }
}