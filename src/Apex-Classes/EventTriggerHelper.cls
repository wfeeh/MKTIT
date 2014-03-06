/**
 *  Description     :   Helper class for Trigger_Event trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Version      	:  	V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public with sharing class EventTriggerHelper {
	
	/**
	 *	@Description	:	This method is used to diaplay the error on Curriculum Product if shopping cartItem consist the same Product Value
	 *						
	 *	@args			:	List<lmscons__Curriculum__c>,Map<Id, lmscons__Curriculum__c>
	 *
	 *	@return			:	void
	**/
	public static void validateEventProduct(List<lmsilt__Event__c> newEvents, Map<Id, lmsilt__Event__c> mapOldEvents){
		
		//Set to hold the event's Product Id
		Set<Id> setEventProudctIds = new Set<Id>();
		
		//Set to hold the shopping cart Item's product Id
		Set<Id> setSCIProductIds = new Set<Id>();
		
		//Loop through Events
		for(lmsilt__Event__c ev : newEvents){
			
			//Check the appropriate condition to fire the trigger
			if(ev.Product__c != null && (mapOldEvents == null || mapOldEvents.get(ev.Id).Product__c != ev.Product__c)){
				
				//Add the value in set
				setEventProudctIds.add(ev.Product__c);
			}
		}
		
		//Loop through Shopping CartItem
		for(kumocomm__ShoppingCartItem__c sCI : [Select Id, kumocomm__Product__c From kumocomm__ShoppingCartItem__c Where 
															kumocomm__Product__c != null AND kumocomm__Status__c =: Constants.TRAINING_STATUS_IN_CART
															AND kumocomm__Product__c IN : setEventProudctIds]){
			//add the value in set
			setSCIProductIds.add(sCI.kumocomm__Product__c);												
		}
		
		//Loop through event
		for(lmsilt__Event__c ev : newEvents){
			
			//Check the appropriate condition to fire the trigger
			if(ev.Product__c != null && (mapOldEvents == null || mapOldEvents.get(ev.Id).Product__c != ev.Product__c)){
				
				//Check product alrady consist in set
				if(setSCIProductIds.contains(ev.Product__c)){
					
					//Display error
					ev.Product__c.addError(Label.MKT_CheckProductError);
				}
			}
		}
	}
}