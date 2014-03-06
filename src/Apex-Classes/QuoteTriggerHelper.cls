/**
 *  Description    :   Helper class for Trigger_Quote trigger.
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

public without sharing class QuoteTriggerHelper {
	
	//Variable to control trigger execution
	public static Boolean execute_Quote_Trigger = true;
		
	/**
	 *	@description	:	Method to update Quote Opportunity Owner_Role_Mapping__c field with opportunity owner Id
	 *
	 *	@args			:	List<Quote>
	 *
	 *	@return			:	void
	 *
	 **/
	public static void validateOppOwnerRoleMapping(List<Quote> quotes) {
		
		//Set to hold Opportunity Id
		Set<Id> setOppIds = new Set<Id>();
		
		//Loop through Quote
		for(Quote quote : quotes) {
			
			//Check for OpportunityId
			if(quote.OpportunityId != null) {
				
				//Add Opportunity Id in set
				setOppIds.add(quote.OpportunityId);
			}
		}
		
		//List of opportunity
		List<Opportunity> opportunities = new List<Opportunity>();
		
		//Loop through opportuniy
		for(Opportunity opp : [Select Id, Owner_Role_Mapping__c, OwnerId, RecordTypeId, RecordType.DeveloperName From Opportunity Where Id IN : setOppIds 
									AND RecordType.DeveloperName !=: Constants.SFDC_OPPTY_RECORDTYPE_CLOSED_WON 
									AND StageName !=: Constants.OPPORTUNITY_STAGENAME_CLOSED_LOST]) {
										
			//Check for Owner Role Mapping
			if(opp.Owner_Role_Mapping__c != opp.OwnerId) {
				
				//update Owner Role with Owner Id
				opp.Owner_Role_Mapping__c = opp.OwnerId;
				
				//Add in list
				opportunities.add(opp);
			}
		}
		
		//Check for list size
		if(opportunities.size() > 0) {
			
			//Set opportunity trigger flag to false
			OpportunityTriggerHelper.execute_Opportunity_Trigger = false;
			
			//Update opportunity
			update opportunities;
		}
		
	}
}