/**
 *  Description    :   Helper class for Trigger_CampaignMember trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/8/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/

public without sharing class CampaignMemberTriggerHelper {
	
	//Boolean variable to control CampaignMember trigger execution
	public static Boolean Execute_CampaignMember_Trigger = true;
	
	/**
	 *	@Description	:	Method to sent Http request for CampaignMember's related Contact (If portal user is active for that contact) and Campaign
	 *						according to campaign, contact and Status(Attended, Sent).
	 *
	 *	@args			:	List<CampaignMember>, Map<Id, CampaignMember>, Integer
	 *
	 *	@return			:	void
	 *
	 **/
	public static void sendHttpRequest(List<CampaignMember> newCamMembers, Map<Id, CampaignMember> mapOldCamMembers, Integer triggerSize) {
		
		//Set to hold CampaignMember's Contact Id
		Set<Id> setConIds = new Set<Id>();
		
		//Set to hold CampaignMember Ids
		Set<Id> setCMIds = new Set<Id>();
		
		//Map to hold ContactId as key and User List as value
		Map<Id,Id> mapConIdsAndUserIds = new Map<Id, Id>();
		
		//Variables to hold Campaign Id from Custom Label
		String yearlyCampId = Label.AttendASummit;
		String AdvocateProgramSignUpsId = Label.AdvocateProgramSignUps;
    	String AttendedDreamForceId = Label.AttendedDreamForce;
    	
    	//String for Campaign Start date
    	String camStatrtDate = '';
    	
    	//String to hold Custom setting value
    	for(Configuration_Manager__c config : Constants.getConfigManagerByParameterKey(Constants.CONFIG_MANAGER_PARAMETER_KEY_CAMPAIGNSTARTDATE)) {
    		
    		//Check for Parme
    		if(config.Parameter_Value__c != null && config.Parameter_Value__c != '') {
    			
    			//bind value in string
    			if(camStatrtDate == '')
    				camStatrtDate = config.Parameter_Value__c;
    		}
    	}
    	
    	//Date variable to hold Campaign start date
    	Date campStatrtDate = date.newInstance(2013, 7, 31);
    	
    	//Check for String
    	if(camStatrtDate != null && camStatrtDate != '') {
    		
    		try {
    			campStatrtDate = Date.parse(camStatrtDate);
    		} catch(Exception e){}
    	}
    	
    	//Map to hold CampaignId as key and List of ContactId as value according to CampaignMember
    	Map<Id, List<Id>> mapCamIdAndConIds = new Map<Id, List<Id>>();
		
		//Loop through CampaignMembers
		for(CampaignMember cM : newCamMembers) {
				
			//Check for approprite condition to fire trigger
			if(cM.ContactId != null && cM.CampaignId != null && cM.Status != null && (cM.Status == Constants.CAMPAIGNMEMBER_STATUS_ATTENDED
																 					 || cM.Status == Constants.CAMPAIGNMEMBER_STATUS_SENT)
			   && (mapOldCamMembers == null || cM.Status != mapOldCamMembers.get(cM.Id).Status)) {
			   		
				//Add Contact Id in set
				setConIds.add(cM.ContactId);
				
				//Add CampaignId in set
				setCMIds.add(cM.Id);
			}
		}
		
		//Map to hold Campaigns
		Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign>([Select Id, Name, StartDate From Campaign where IsActive = true AND Name Like '%User Group Attendees%'
																			AND StartDate >: campStatrtDate ORDER By startDate DESC LIMIT 12]);
		
		//Loop through Users
		for(User usr : [Select Id, Name, ContactId, IsPortalEnabled, IsActive, Email From User Where IsActive = true AND IsPortalEnabled = true
																							AND ContactId != null AND ContactId IN : setConIds]) {
			
			//Put values in map
			mapConIdsAndUserIds.put(usr.ContactId, usr.Id);																							  	
		}
		
		//Loop through CampaignMember
		for(CampaignMember cM : [Select Id, ContactId, CampaignId, Campaign.Name, Campaign.StartDate, Campaign.IsActive, Status 
																			From CampaignMember Where Id IN : setCMIds]) {
			
			//Check for Integer
			if(triggerSize == 1 && mapCampaigns.size() > 0) {
				
				//Check for CampaignId
				if(cM.Status == Constants.CAMPAIGNMEMBER_STATUS_ATTENDED && mapConIdsAndUserIds.ContainsKey(cM.ContactId)) {
					
					//Check for CampaignId
					if(cM.CampaignId == yearlyCampId ) {
					
						//Call BadgeVilleWebServiceCallouts method for call out
						BadgeVilleWebServiceCallouts.attendASummitReward(mapConIdsAndUserIds.get(cM.ContactId), Label.ATTENDED_USER_SUMMIT, yearlyCampId);
					
					} else if(cM.CampaignId == AdvocateProgramSignUpsId) {
						
						//Call BadgeVilleWebServiceCallouts method for call out
						BadgeVilleWebServiceCallouts.attendASummitReward(mapConIdsAndUserIds.get(cM.ContactId), Label.SYNCHWITHBOULDERLOGIC, AdvocateProgramSignUpsId);
					
					} else if(cM.CampaignId == AttendedDreamForceId) {
						
						//Call BadgeVilleWebServiceCallouts method for call out
						BadgeVilleWebServiceCallouts.attendASummitReward(mapConIdsAndUserIds.get(cM.ContactId), Label.ATTENDED_DREAM_FORCE, AttendedDreamForceId);
					}
				
				} else if(mapCampaigns.containsKey(cM.CampaignId) && cM.Status == Constants.CAMPAIGNMEMBER_STATUS_SENT 
							&& mapConIdsAndUserIds.ContainsKey(cM.ContactId)) {
					
					//Call BadgeVilleWebServiceCallouts's method to call out
					BadgeVilleWebServiceCallouts.attendASummitReward(mapConIdsAndUserIds.get(cM.ContactId), Label.ATTEND_A_USER_GROUP_MEETING, cM.CampaignId);				
				}
			
			//Process Callout through batch if more than one record updated or created
			} else if(mapCampaigns.size() > 0){
				
				//Check for Campaign
				if(mapConIdsAndUserIds.containsKey(cM.ContactId) && cM.Status == Constants.CAMPAIGNMEMBER_STATUS_ATTENDED && (cM.CampaignId == yearlyCampId 
					|| ((cM.CampaignId == AdvocateProgramSignUpsId || cM.CampaignId == AttendedDreamForceId) 
						&& ! mapCampaigns.containsKey(cM.CampaignId)))) {
															
					//Check for CampaignId in map
					if(mapCamIdAndConIds.containsKey(cM.CampaignId)) {
						
						//Add contact Id
						mapCamIdAndConIds.get(cM.CampaignId).add(cM.ContactId);
					} else {
						//Add contact Id
						mapCamIdAndConIds.put(cM.CampaignId, new List<Id>{cM.ContactId});	
					}
				} else if(mapConIdsAndUserIds.containsKey(cM.ContactId) && mapCampaigns.containsKey(cM.CampaignId) && cM.Status == Constants.CAMPAIGNMEMBER_STATUS_SENT) {
					
					//Check if map already contains CampaignId
					if(mapCamIdAndConIds.containsKey(cM.CampaignId)) {
						
						//Add Contact In map
						mapCamIdAndConIds.get(cM.CampaignId).add(cM.ContactId);
					} else {
						
						//Populae map
						mapCamIdAndConIds.put(cM.CampaignId, new List<Id>{cM.ContactId});
					}
				} 
			}
		}
		
		//Loop through Map Key(CampaignId)
		for(Id camId : mapCamIdAndConIds.keySet()) {
			
			//Check for CampaignId
			if(camId == yearlyCampId) {
				
				 //Execute batch to Sent Http request 
				 Database.executeBatch(new BadgeVilleBatchApexWebCalloutClass(mapCamIdAndConIds.get(camId), Label.ATTENDED_USER_SUMMIT, camId), 10);
			
			} else if(camId == AttendedDreamForceId) {
				
				//Execute batch to Sent Http request 
				Database.executeBatch(new BadgeVilleBatchApexWebCalloutClass(mapCamIdAndConIds.get(camId), Label.ATTENDED_DREAM_FORCE, camId), 10);
			
			} else if(camId == AdvocateProgramSignUpsId) {
				
				//Execute batch to Sent Http request 
				Database.executeBatch(new BadgeVilleBatchApexWebCalloutClass(mapCamIdAndConIds.get(camId), Label.SYNCHWITHBOULDERLOGIC, camId), 10);
			
			} else {
				
				//Execute batch to Sent Http request 
				Database.executeBatch(new BadgeVilleBatchApexWebCalloutClass(mapCamIdAndConIds.get(camId), Label.ATTEND_A_USER_GROUP_MEETING, camId), 10);
			}
		}																				
	}
}