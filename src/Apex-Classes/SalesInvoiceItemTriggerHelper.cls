/**
 *  Description     :   Helper class for Trigger_SalesInvoiceItem trigger.
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
public without sharing class SalesInvoiceItemTriggerHelper {
	
	/**
     * @Description  :  This method is used to validate the opp Line Total(field) value with the Opportunity LineItem's Total Price Services and
     *					 Total ARR forRUSF with appropraiate conditions.
     *
     * @args         :  List<Sales_Invoice__c>
     *
     * @return       :  void
     *
	**/
	public static void validateOppLineTotal(List<Sales_Invoice_Item__c> newSalesIvoiceItems){
		
		// set to hold the Opp Product Id
		Set<Id> setOppProIds = new Set<Id>();
		
		//Loop through Sales Invoice Items
		for(Sales_Invoice_Item__c sII : newSalesIvoiceItems){
			
			//Check the appropriate condition to fire trigger
			if(sII.Opp_Product_Id__c != null && sII.Opp_Product_Id__c instanceOf Id){
				
				//Add the value in set
				setOppProIds.add(sII.Opp_Product_Id__c);
			}
		}
		
		//Map to hold the Id as key corresponding to the opportunity line Item as values
		Map<Id, OpportunityLineItem>  mapOppLineItems = new map <Id, OpportunityLineItem>([Select Id, Total_Price_Services__c, Total_ARR_for_RUSF__c From 
																							OpportunityLineItem Where Id IN : setOppProIds]);
		
		//Loop  through Sales Invoice Item
		for(Sales_Invoice_Item__c sII : newSalesIvoiceItems){
			
			//check the map Key
			if(mapOppLineItems.containsKey(sII.Opp_Product_Id__c)){
				
				//check the values in map
				if(mapOppLineItems.get(sII.Opp_Product_Id__c).Total_ARR_for_RUSF__c != null && mapOppLineItems.get(sII.Opp_Product_Id__c).Total_ARR_for_RUSF__c != 0){
				
					//Populate the value
					sII.Opp_Line_Total__c = mapOppLineItems.get(sII.Opp_Product_Id__c).Total_ARR_for_RUSF__c;
					
				} else If(mapOppLineItems.get(sII.Opp_Product_Id__c).Total_Price_Services__c != null && mapOppLineItems.get(sII.Opp_Product_Id__c).Total_Price_Services__c != 0){
					
					//Populate the value
					 sII.Opp_Line_Total__c = mapOppLineItems.get(sII.Opp_Product_Id__c).Total_Price_Services__c;
					 
				}else{
					 sII.Opp_Line_Total__c = 0;
				}
			}
		}
	}
}