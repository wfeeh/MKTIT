/**
 *  Description     :   Helper class for Trigger_SalesInvoice trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/24/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class SalesInvoiceTriggerHelper {
	
	/**
     * @Description  :  This method is used to  validate the Opportunity invoices with Opportunity with appropraite conditions.
     *
     * @args         :  List<Sales_Invoice__c>, Map<Id,Sales_Invoice__c>
     *
     * @return       :  void
     *
	**/
	public static void validateOpp(List<Sales_Invoice__c> newSalesInvoices){
		
		//set to hold the Custom setting
		Set<String> setConfig = Utility.ConfigManagerParameterValue(Constants.CONFIG_MANAGER_PARAMETER_KEY_EXCLUDEDSALESINVOICEDOCUMENTTYPE); 
		
		//loop through sales invoices
		for(Sales_Invoice__c sI : newSalesInvoices){
			
			//Check the appropriate condition to fire trigger
			if(!setConfig.contains(sI.Document_Type__c)){
				
				//check the condition for Opportunity
				if(sI.Opportunity__c != null)
					sI.Opportunity_Invoices__c = sI.Opportunity__c;
				
				else
					sI.Opportunity_Invoices__c = null;
			}
		}
	}
	/**
     * @Description  :  This method is used to  validate the Opportunity invoices with Opportunity with appropraite conditions.
     *
     * @args         :  List<Sales_Invoice__c>, Map<Id,Sales_Invoice__c>
     *
     * @return       :  void
     *
	**/
	public static void validateLatestPaymentDate(List<Sales_Invoice__c> newSInvoices, Map<Id, Sales_Invoice__c> mapOldSInvoices){
		
		//Set to hold the opportuinty Ids
		Set<Id> setSIOppIds = new Set<Id>();
		
		//Loop through sales invoices
		for(Sales_Invoice__c sI : newSInvoices != null ? newSInvoices : mapOldSInvoices.values()){
			
			//Check the appropriate condition to fire trigger
			if(sI.Document_Type__c != Constants.SALES_INVOICE_DOC_TYPE_REVENUE_RECOGNITION_ACTIVATION  && sI.Last_Payment_Date__c != null && (mapOldSInvoices == null || 
								mapOldSInvoices.get(sI.Id).Last_Payment_Date__c != sI.Last_Payment_Date__c)){
				
				//Add the value in set
				setSIOppIds.add(sI.Opportunity__c);
				
			} else if(newSInvoices == null && mapOldSInvoices.get(sI.Id).Document_Type__c != Constants.SALES_INVOICE_DOC_TYPE_REVENUE_RECOGNITION_ACTIVATION){
				
				//Add the value in set
				setSIOppIds.add(sI.Opportunity__c);
			}
		}
		
		//List to hold the opportunity
		List<Opportunity> opportunities = new List<Opportunity>();
		
		//Loop through Sales Invoices
		for(Opportunity opp : [Select Id, Latest_Payment_Date__c ,(Select Id, Last_Payment_Date__c From SalesInvoices__r Where Document_Type__c !=: Constants.SALES_INVOICE_DOC_TYPE_REVENUE_RECOGNITION_ACTIVATION 
								   AND Last_Payment_Date__c != null Order By Last_Payment_Date__c DESC NULLS LAST LIMIT 1 )From Opportunity Where Id IN : setSIOppIds]){
				
			//Check the conditio for Sales invoice last Payement date
			if(opp.SalesInvoices__r.size() > 0){
				
				//Populate the value
				opp.frm_payment__c = true;	
				opp.Latest_Payment_Date__c = opp.SalesInvoices__r[0].Last_Payment_Date__c;
			
			}else {
				
				opp.Latest_Payment_Date__c = null;
			}
			
			//Add the value in list
			opportunities.add(opp);		
		}
		
		//Check the size of list
		if(opportunities.size() > 0)
			update opportunities;
	}
}