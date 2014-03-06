/**  
 *  Description    :   Helper class for Trigger_Asset trigger.
 *
 *  Created By     : 
 *
 *  Created Date   :   02/7/2014
 *
 *  Version        :   V_1.0
 *
 *  Revision Logs  :   V_1.0 - Created 
 *
 **/
public without sharing class AssetTriggerHelper {
	
	/**
     * @Description  :  Method to Update the enDate(field) of entitlement on insertion and updation of UsageEndDate (field)Asset
     *
     * @args         :  List<Asset>, Map<Id,Asset>
     *
     * @return       :  void
     *
     **/
     public static void validateEntitleEndDate(List<Asset> newAssets, Map<Id,Asset> mapOldAssets){
     
     	//Set hold the Ids of asset
     	Set<Id> setAssetIds = new Set<Id>();
     	
     	//List to update the entitlemnt enddate field
     	List<Entitlement> entitlements = new List<Entitlement>();
     	
     	//Loop through Asset
     	for(Asset ast : newAssets){
     		
     		//Check the appropriate condition to fire trigger
     		if( ast.UsageEndDate != mapOldAssets.get(ast.Id).UsageEndDate){
     			
     			//add the values in set
     			setAssetIds.add(ast.Id);
     		}
		}
		
		//Loop through entitlement
     	for(Entitlement ent : [Select Id, AssetId, Asset.UsageEndDate,StartDate, EndDate From Entitlement Where AssetId IN : setAssetIds]){
     		
     		//Check the condition for populate the endDate (field)of Entitlement
     		if(ent.AssetId != null && ent.Asset.UsageEndDate != null && ent.StartDate != null){
     			
     			//Populate Entitlement endDate(field) with the Asset UsageEndDate
     			ent.EndDate = ent.Asset.UsageEndDate;
     		} else {
     			
     			//Populate the EndDate field with ull value
     			ent.EndDate = null;
     		}
     		
     		//Add the values in list
     		entitlements.add(ent);
     	}
     	
     	//Check the size of list
     	if(entitlements.size() > 0)
     		update entitlements;
	}
	
	/**
     * @Description  :  Method to Update Asset's child Asset and Parent Account according to Asset field values
     *
     * @args         :  List<Asset>, Map<Id,Asset>
     *
     * @return       :  void
     *
     **/
     public static void upateAccountOnAsset(List<Asset> newAssets, Map<Id,Asset> mapOldAssets){
     	
     	//Set to hold Account Id
     	Set<Id> setAccountIds = new Set<Id>();
     	
     	//Set to hold Asset Id
     	Set<Id> setAssetIds = new Set<Id>();
     	
     	//Loop through new accounts
     	for(Asset ast : newAssets) {
     		
     		//Check condition to fire trigger
     		if(ast.AccountId != null && (mapOldAssets == null || ast.Add_On_Product__c != mapOldAssets.get(ast.Id).Add_on_product__c 
     			|| ast.Subscription_Type__c != mapOldAssets.get(ast.Id).Subscription_Type__c)) {
     			
     			//Add Account Id in list
     			setAccountIds.add(ast.AccountId);
     		}
     		
     		//Add asset Id in set
     		setAssetIds.add(ast.Id);
     	}
     	
     	//Map to hold Account Id and List of Asset
     	Map<Id, List<Asset>> mapAccIdAndAssets = new Map<Id, List<Asset>>();
     	
     	//Query through assets
     	for(Asset ast : [Select Id, Name, Asset_type__c, Add_On_Product__c, AccountId, Status, Subscription_type__c From Asset
     								Where AccountId IN : setAccountIds AND Status =: Constants.ASSET_STATUS_ACTIVE]) {
     		
     		//Check values in map
     		if(mapAccIdAndAssets.containsKey(ast.AccountId)) {
     			
     			//Add new Asset
     			mapAccIdAndAssets.get(ast.AccountId).add(ast);
     		} else {
     			
     			//Populate values in map
     			mapAccIdAndAssets.put(ast.AccountId, new List<Asset>{ast});
     		}
     	}
     	
     	//List of account
     	List<Account> accounts = new List<Account>();
     	
     	//Loop through Account
     	for(Account acc : [Select Id, Name, Add_On_Products__c, Support_level1__c, PRODUCT_EDITIONS__C
     							From Account Where Id IN : setAccountIds]) {
     					   	
     		//Initialize Product Editions
     		acc.PRODUCT_EDITIONS__c = '';
     		acc.Add_On_Products__c = '';
     		
     		//Check if Map contains Account Id
     		if(mapAccIdAndAssets.containsKey(acc.Id)) {
     			
     			//Loop through accts
     			for(Asset ast : mapAccIdAndAssets.get(acc.Id)) {
     				
     				//Check for Asset value
     				if(ast.Asset_type__c == Constants.PRODUCT_CONVERTTO_SUBSCRIPTION) {
     					
     					//Check for Subscription_type__c
     					if(ast.Subscription_Type__c != null && Constants.SET_SUBSCRIPTION_TYPE.contains(ast.Subscription_Type__c)
     						&& !acc.PRODUCT_EDITIONS__c.containsignorecase(ast.Subscription_type__c.subString(4))) {
     						
     						//Assign value in Product Edition
     						acc.PRODUCT_EDITIONS__c += ast.Subscription_type__c.subString(4) + ' Edition;';	
     					}
     				} else if(ast.Asset_Type__c == Constants.PRODUCT_CONVERTTO_ADD_ON) {
     					
     					if(ast.Add_on_product__c != null && !acc.Add_On_Products__c.containsignorecase(ast.Add_on_product__c)) {
     						
     						acc.Add_On_Products__c += ast.Add_on_Product__c + ' ;';
     					}
     				}
     			}
     		}
     	}
     	
     	//List of Asset
     	List<Asset> assets = new List<Asset>();
     	
     	//Loop through Asset
     	for(Asset ast : [Select Id, Name, Add_On_Product__c, Parent_Instance__c, Parent_Instance__r.Acct_Prefix__c, Status From Asset Where Parent_Instance__c IN : setAssetIds]) {
     		
     		//Check for Asset Name
     		if(ast.Parent_Instance__r.Acct_Prefix__c != null && ast.Add_On_Product__c != null
     			&& ast.Name != ast.Parent_Instance__r.Acct_Prefix__c + ' ' + ast.Add_On_Product__c) {
     			
     			//Update Asset Name
     			ast.Name = ast.Parent_Instance__r.Acct_Prefix__c + ' ' + ast.Add_On_Product__c;
     		}
     		
     		//Update Asset Status
     		ast.Status = Constants.ASSET_STATUS_ACTIVE;
     		
     		//Add in list
     		assets.add(ast);
     	}
     	
     	//Check for list size
     	if(accounts.size() > 0) {
     		
     		//Set flag to false
     		AccountTriggerHelper.Execute_Account_Trigger = false;
     		
     		//Update account
     		update accounts;
     	}
     	
     	//Check for asset size
     	if(assets.size() > 0)
     		update assets;
    }
}