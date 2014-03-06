/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Sales Invoice Payment.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/25/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_SalesInvoicePaymentDetail on Sales_Invoice_Payment__c (after insert) {
    
    //Check the request type
    if(Trigger.isAfter){
        
        //Check the event type
        if(Trigger.isInsert){
            
            //Call the helper class's method to create a new record of Sales Invoice Item Payment Detail
            SalesInvoicePaymentDetailTriggerHelper.validateSIIPDetail(Trigger.new);
        }
    }
}