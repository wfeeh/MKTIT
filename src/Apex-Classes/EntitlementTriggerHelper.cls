/**
 *  Description    :   Helper class for Trigger_Entitlement trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/10/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/

public without sharing class EntitlementTriggerHelper {

	//Boolean variable for account trigger execution
    public static Boolean Execute_Entitlement_Trigger = true;
    
    /**
     *	@description	:	Method to update entitlement Subscription End Date with EndDate
     *
     *	@args			:	List<Entitlement>, Map<Id, Entitlement>
     *
     *	@return			:	void
     *
     **/
	public static void validateSubscriptionEndDate(List<Entitlement> newEntitlements, Map<Id, Entitlement> mapOldEntitlements) {
		
		
		//Loop through Entitlement
		for(Entitlement ent : newEntitlements) {
			
			//Check appropriate condition to fire trigger
			if(ent.Subscription_End_Date__c != ent.EndDate && 
				(mapOldEntitlements == null || ent.EndDate != mapOldEntitlements.get(ent.Id).EndDate)) {
				
				//Update subscription ent date with EndDate
				ent.Subscription_End_Date__c = ent.EndDate;
			}
		}
	}
	
	/**
     *	@description	:	Method to update Account's support Level field according to entitlement's Type.
     *
     *	@args			:	List<Entitlement>, Map<Id, Entitlement>
     *
     *	@return			:	void
     *
     **/
	public static void updateAccountSupportLevel(List<Entitlement> newEntitlements, Map<Id,Entitlement> mapOldEntitlements) {
		
		//Set to hold Entitlement's Account ID
		Set<Id> setAccIds = new Set<Id>();
		
		//Map to hold Account Id and List of Entitlement corresponding to account
		Map<Id, List<Entitlement>> mapAccIdAndEntitlements = new Map<Id, List<Entitlement>>();
		
		//Loop through Entitlement
		for(Entitlement ent : newEntitlements) {
			
			//Check for Entitlement type to fire trigger
			if(ent.AccountId != null && ((ent.Type != null && mapOldEntitlements == null) || ent.Type != mapOldEntitlements.get(ent.Id).Type)){
				
				//Add account Id in set
				setAccIds.add(ent.AccountId);
			}
		}
		
		//Loop through Entitlements
		for(Entitlement ent : [Select Id, AccountId, Type, Status From Entitlement Where AccountId IN : setAccIds
																						AND Status =: Constants.ASSET_STATUS_ACTIVE]) {
																							
			//Check account Id in map
			if(mapAccIdAndEntitlements.containsKey(ent.AccountId)) {
				
				//Add Entitlement record
				mapAccIdAndEntitlements.get(ent.AccountId).add(ent);
			} else {
				
				//Populate map with values
				mapAccIdAndEntitlements.put(ent.AccountId, new List<Entitlement>{ent});
			}
		}
		
		//List of Account
		List<Account> accounts = new List<Account>();
		
		//Query through accounts
		for(Account acc : [Select Id, Name, Add_On_Products__c, Support_level1__c, PRODUCT_EDITIONS__C From Account Where Id IN : setAccIds]) {
			
			//Set Support_Level1__c to blank
			acc.Support_Level1__c = '';
			
			//Check account Id in map
			if(mapAccIdAndEntitlements.containsKey(acc.Id)) {
				
				//Loop through Entitlement
				for(Entitlement ent : mapAccIdAndEntitlements.get(acc.Id)) {
					
					//check for Type in field
					if(ent.Type != null && !acc.Support_Level1__c.containsignorecase(ent.Type)) {
						
						//Populate field value
     					acc.Support_Level1__c += ent.type + ' ;';
					}
				}
				
				//Add account in list
				accounts.add(acc);
			}
		}
		
		//Check for list size
		if(accounts.size() > 0) {
			
			//Set flag to false
     		AccountTriggerHelper.Execute_Account_Trigger = false;
     		
     		//Update account
     		update accounts;
		} 
	}
}