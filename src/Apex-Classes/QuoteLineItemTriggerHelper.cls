/**
 *  Description    :   Helper class for Trigger_QuoteLineItem trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/12/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
	
public without sharing class QuoteLineItemTriggerHelper {
	
	//Variable to control trigger execution
	public static Boolean execute_QuoteLineItem_Trigger = true;
	
	/**
	 *	@description	:	Method to update related Quote according to QuoteLineItems
	 *
	 *	@args			:	List<QuoteLineItem>, List<QuoteLineItem>
	 *
	 *	@return			:	void
	 *
	 **/
	public static void validateQuote(List<QuoteLineItem> newQLItems, List<QuoteLineItem> oldQLItems) {
		
		//Map to hold Quotes
		Map<Id, Quote> mapQuotes = new Map<Id, Quote>();
		
		//Loop through QuoteLineItem
		for(QuoteLineItem qLI : newQLItems != null ? newQLItems : oldQLItems) {
			
			//Check for Quote Id
			if(qLI.QuoteId != null) {
				
				//Populate map with values
				mapQuotes.put(qLI.QuoteId, new Quote(Id = qLI.QuoteId, Sales_Approval__c = Constants.QUOTE_APPROVAL_APPROVED, 
													 PS_Approval__c = Constants.QUOTE_APPROVAL_APPROVED, 
													 Support_Approval__c = Constants.QUOTE_APPROVAL_APPROVED ));
			}
		}
		
		//Query through Quote and QuoteLineItem
		for(QuoteLineItem qLI : [Select Id, QuoteId, Discount, PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.Edition__c,
							 		PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Family, PricebookEntry.Product2.Name From QuoteLineItem
							 		 Where QuoteId IN : mapQuotes.keySet() AND PricebookEntryId != null AND PricebookEntry.Product2Id != null]){
			
			//Check if map contains Quote
			if(mapQuotes.containsKey(qLI.QuoteId)) {
				
				//Check for Product's Edition and QuoteLineItem Discount
				if((qLI.PricebookEntry.Product2.Edition__c == Constants.PRODUCT_EDITION_ENTERPRISE && qLI.Discount >= 30)
						|| (qLI.PricebookEntry.Product2.Edition__c != Constants.PRODUCT_EDITION_ENTERPRISE && qLI.Discount > 0)
					&& mapQuotes.get(qLI.QuoteId).Sales_Approval__c != Constants.QUOTE_APPROVAL_APPROVAL_NEEDED) {
							
					//Update quote
					mapQuotes.get(qLI.QuoteId).Sales_Approval__c = Constants.QUOTE_APPROVAL_APPROVAL_NEEDED;
				}
				
				//Check for Product Code
				if((qLI.PricebookEntry.Product2.ProductCode != null && (qLI.PricebookEntry.Product2.ProductCode == Constants.PRODUCT_PRODUCTCODE_INT_CUST
																	|| qLI.PricebookEntry.Product2.ProductCode == Constants.PRODUCT_PRODUCTCODE_SV_SOW))
					|| (qLI.Discount > 0 && qLI.PricebookEntry.Product2.Family != null 
						&& qLI.PricebookEntry.Product2.Family == Constants.OPPORTUNITYLINEITEM_PRODUCT_SERVICES)
					|| (qLI.PricebookEntry.Product2.Name != null && qLI.PricebookEntry.Product2.Name.containsIgnoreCase(Constants.PRODUCT_NAME_LAUNCH_PACK)
						&& qLI.PricebookEntry.Product2.Edition__c == Constants.PRODUCT_EDITION_ENTERPRISE)
					&& mapQuotes.get(qLI.QuoteId).PS_Approval__c != Constants.QUOTE_APPROVAL_APPROVAL_NEEDED) {
					
					//Update quote
					mapQuotes.get(qLI.QuoteId).PS_Approval__c = Constants.QUOTE_APPROVAL_APPROVAL_NEEDED;
				}
				
				//Check for Support_Approval__c
				if(qLI.PricebookEntry.Product2.Family != null && qLI.PricebookEntry.Product2.Family == Constants.OPPORTUNITYLINEITEM_PRODUCT_SERVICES
					&& mapQuotes.get(qLI.QuoteId).Support_Approval__c != Constants.QUOTE_APPROVAL_APPROVAL_NEEDED){
					
					//Update quote
					mapQuotes.get(qLI.QuoteId).Support_Approval__c = Constants.QUOTE_APPROVAL_APPROVAL_NEEDED;
				}
			}
		}
		
		//Check for map size
		if(mapQuotes.size() > 0) {
			
			//Set Quote trigger variable to false
			QuoteTriggerHelper.execute_Quote_Trigger = false;
			
			//Update Quotes
			update mapQuotes.values();
		}
	}
}