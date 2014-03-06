/**
 *  Description     :   Helper class for Trigger_UsageData trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/26/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class UsageDataTriggerHelper {
	
	/**
     * @Description  :  This method is used to validate the value of Marketo Users with the no.of contacts on that account.
     *
     * @args         :  List<JBCXM__UsageData__c>
     *
     * @return       :  void
     *
	**/
	public static void validateMarketoUser(List<JBCXM__UsageData__c> newUsageDatas){
		 
		//set to hold the account Id of Usage data
		Set<Id> setUsageDataAccIds = new Set<Id>();
		
		//Loop through Usage Data
		for(JBCXM__UsageData__c jUD : newUsageDatas){
			
			//Check the appropraite condition to fire trigger
			if(jUD.JBCXM__Account__c != null){
				
				//Add the value in set
				setUsageDataAccIds.add(jUD.JBCXM__Account__c);
			}
		}
		
		//Map to hold the account Id as key corresponding to the contact list as values
		Map<Id, List<Contact>> mapAccIdAndCons = new Map<Id, List<Contact>>();
		
		for(Contact con: [Select Id, Name, Marketo_End_User__c, CreatedDate, AccountId From Contact Where AccountId IN : setUsageDataAccIds 
							AND Marketo_End_User__c = true]){
			
			//Check the key in map
			if(mapAccIdAndCons.containsKey(con.AccountId)){
				
				//Add the value in map
				mapAccIdAndCons.get(con.AccountId).add(con);
			
			} else {
				
				//Populate the value in map
				mapAccIdAndCons.put(con.AccountId, new List<Contact>{con});
			}				
		}
		
		//Loop through Usage Data
		for(JBCXM__UsageData__c jUD : newUsageDatas){
			
			//Check the value in map
			if(mapAccIdAndCons.containsKey(jUD.JBCXM__Account__c)){
				
				//Populate the value
				jUD.Marketo_Users__c = mapAccIdAndCons.get(jUD.JBCXM__Account__c).size();
			} else
				
				jUD.Marketo_Users__c = 0;
		}
	}
}