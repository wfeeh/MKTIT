/**
 *  Description     :   Helper class for Trigger_SalesInvoicePaymentDetail trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/25/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class SalesInvoicePaymentDetailTriggerHelper {
    
    /**
     * @Description  :  This method is used to create an new record of Sales Invoice Item Payment Detail. 
     *
     * @args         :  List<Sales_Invoice_Payment__c>, Map<Id, Sales_Invoice_Payment__c>
     *
     * @return       :  void
     *
    **/
    public static void validateSIIPDetail(List<Sales_Invoice_Payment__c> newSIPayments){
        
        //Map to hold the Sales Invoice Id as key corresponding to the Sales Invoice Item as values.
        Map<Id, List<Sales_Invoice_Item__c>> mapSItemsIdAndSIItems = new Map<Id,List<Sales_Invoice_Item__c>>();
        
        //Setto hold the 
        set<Id> setSIPSalesInvoicesIds = new Set<Id>();
        
        //Loop through Sales Invoice Payment
        for(Sales_Invoice_Payment__c sIP : newSIPayments){
            
            //add the value in set
            setSIPSalesInvoicesIds.add(sIP.Sales_Invoice__c);
            
        }
        
        //Loop through Sales Invoice Item
        for(Sales_Invoice_Item__c sIV : [Select Id, Sales_Invoice__c,Sales_invoice__r.subtotal__c, Extended_Price__c From Sales_Invoice_Item__c 
                                                    Where Sales_Invoice__c IN : setSIPSalesInvoicesIds]){
            
            //Check the values in map                                           
            if(mapSItemsIdAndSIItems.containsKey(sIV.Sales_Invoice__c)){
                
                //Add vaules in map
                mapSItemsIdAndSIItems.get(sIV.Sales_Invoice__c).add(sIV);
                
            }else{
                
                //Populate the value in map
                mapSItemsIdAndSIItems.put(sIV.Sales_Invoice__c, new List<Sales_Invoice_Item__c>{sIV});
            }
        }
        
        //List to insert the Sales Invoice item Payment Detail
        List<Sales_Invoice_Item_Payment_Detail__c> sIIPDetails = new List<Sales_Invoice_Item_Payment_Detail__c>();
        
        //Loop through Sales Invoice Payment
        for(Sales_Invoice_Payment__c sIP :newSIPayments){
            
            //Check the key in map
            if(mapSItemsIdAndSIItems.containsKey(sIP.Sales_Invoice__c)){
                
                //Instance of Sales Invoice Item Payment Detail
                Sales_Invoice_Item_Payment_Detail__c sIIPD= new Sales_Invoice_Item_Payment_Detail__c();
                
                //Populate the value
                sIIPD.Sales_Invoice_Payment_Detail__c = sIP.Id;
                sIIPD.CurrencyIsoCode = sIP.CurrencyIsoCode;
                
                //Loop through Sales Invoice Item
                for(Sales_Invoice_Item__c sII : mapSItemsIdAndSIItems.get(sIP.Sales_Invoice__c)){
                    
                    //Populate the value
                    sIIPD.Sales_Invoice_Item__c = sII.Id;
                    
                    //Check the value for Subtoatal
                    if(sII.sales_invoice__r.Subtotal__c != null && sII.sales_invoice__r.Subtotal__c != 0){
                        
                        //Populate the value
                        sIIPD.Payment_Applied__c = sIP.Payment_Total__c * sII.Extended_Price__c/sIP.sales_invoice__r.Subtotal__c;
                        
                    }else{
                        sIIPD.Payment_Applied__c = 0;
                    }
                }
                //Add the values in list
                sIIPDetails.add(sIIPD);
            }
        }
        
        //Check the size of list
        if(sIIPDetails.size() > 0)
            insert sIIPDetails;
    }
}