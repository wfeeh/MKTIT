/**
 *  Description     :   Helper class for Trigger_SalesOrder trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/14/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class SalesOrderTriggerHelper {
	
	//Boolean variable for sales order trigger execution
    public static Boolean execute_SalesOrder_Trigger = true;
    
     /**
     * @Description  :  This method is used to validate the Opportunity Order(field) if Custom setting equals to null and Opportunity (field) value
     *						not equals to null then the populate the value of Opportunity Order with Oppotunity(field) otherwise null
     *
     * @args         :  List<Sales__Order__c>
     *
     * @return       :  void
     *
     **/
     public static void validateOpportunityOrder(List<Sales_Order__c> newSalesOrder){
     	
     	//Map to hold the custom setting
     	Map<String, Excluded_Sales_Order_Document_Type__c> mapSalesOrder= Constants.SALESORDERSETTINGS;
     	
     	//Loop through Sales Order
     	for(Sales_Order__c sO : newSalesOrder){
     	
     		//Check the value in map to fire the trigger
     		if (mapSalesOrder.get(sO.Document_Type__c) == null && sO.Opportunity__c != null ){
     			
     			//Populate the value
     			sO.Opportunity_Orders__c = sO.Opportunity__c;
     			
     		} else {
     			 
     			 sO.Opportunity_Orders__c = null;
     		}
     	}
	}
}