/**
 *  Description    :   Helper class for Trigger_SupportNews trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/18/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class SupportNewsTriggerHelper {
	
	
	//Set to hold Support news Id to Pass in Helper Class
	public static Set<Id> setSNIds = new Set<Id>();
	
	/**
	 *	@description	:	Method to sent email notification to Community_Subscription__c users about any updated support news 
	 *
	 *	@args			:	List<Marketo_News__c>, Map<Id, Marketo_News__c>()
	 *
	 *	@return			:	void
	 *
	 **/
	public static void sendNotification(List<Marketo_News__c> newNews, Map<Id, Marketo_News__c> mapOldNews) {
		
		//Map to hold news Id as key and list of community Subscription as value
		Map<Id, List<Community_Subscription__c>> mapNIdAndCSs = new Map<Id, List<Community_Subscription__c>>();
		Map<Id, List<Community_Subscription__c>> mapSNIdAndCSs = new Map<Id, List<Community_Subscription__c>>();
		
		//Map to hold news Id as key and List of contact As value
		Map<Id, List<Contact>> mapNIdAndCons = new Map<Id, List<Contact>>();
		
		//Set to hold Pod Value
		Set<String> setPods = new Set<String>();
		
		//Query through Community_Subscription__c
		List<Community_Subscription__c> cSs = [Select Id, User__c, User__r.IsActive, Type__c, User__r.Munchkin_Id__c From Community_Subscription__c
													Where User__r.IsActive = true AND Type__c =: Constants.COMMUNITY_SUBSCRIPTION_TYPE_NEWS_AND_ALERTS];
		
		//Set to hold Account Id
		Set<String> setConfig = new Set<String>();
		 
		//Loop througgh custom setting
	 	for(Configuration_Manager__c cM : Constants.getConfigManagerByParameterKey
	 												(Constants.CONFIG_MANAGER_PARAMETER_KEY_PARTNERACCOUNT)){
	 		//Check the values in  custom setting
	 		if(cM.Parameter_Value__c != null && cM.Parameter_Value__c != ''){
	 			
	 			//Add the values in set
	 			setConfig.add(cM.Parameter_Value__c);
	 			
	 		}
	 	}
		
		//Query through Contact
		List<Contact> partnerContacts = [Select Id, Email, AccountId From Contact where (Not Email like '%.fullcopy') AND Email != null 
											AND (AccountId IN : setConfig OR (Account.Type =: Constants.ACCOUNT_TYPE_PARTNER  
												 AND Account.Partner_Type__c =: Constants.ACCOUNT_PARTNER_TYPE_PREFERRED_SERVICES))];
		
		//Loop through Support News
		for(Marketo_News__c sN : newNews) {
			
			//Check for Appropriate condition to fire trigger
			if(sN.Active__c == true && (sN.Type__c == Constants.SUPPORT_NEWS_TYPE_NEWS || sN.Type__c == Constants.SUPPORT_NEWS_TYPE_ALERT)) {
				
				//Add Id in set
				setSNIds.add(sN.Id);
				
				//Check for Pod
				if(sN.POD__c == null) {
					
					//Check for Type
					if(sN.Type__c == Constants.SUPPORT_NEWS_TYPE_ALERT) {
						
						//Check for Community subscription size if size is grater than 0 than populate map with values
						if(cSs.size() > 0)
							//Populate map with values
							mapNIdAndCSs.put(sN.Id, cSs);
						
						//Check for contact Size if size is grater than 0 than populate map with values
						if(partnerContacts.size() > 0)
							mapNIdAndCons.put(sN.Id, partnerContacts);
					
					} else if(sN.Type__c == Constants.SUPPORT_NEWS_TYPE_NEWS) {
						
						//Check for Community subscription size if size is grater than 0 than populate map with values
						if(cSs.size() > 0)
							mapSNIdAndCSs.put(sN.Id, cSs); 
					}
				} else if(sN.POD__c != null) {
					
					//Check for type
					if(sN.Type__c == Constants.SUPPORT_NEWS_TYPE_NEWS) {
						
						//Check for Community subscription size if size is grater than 0 than populate map with values
						if(cSs.size() > 0)
							mapSNIdAndCSs.put(sN.Id, cSs);
					} else if(sN.Type__c == Constants.SUPPORT_NEWS_TYPE_ALERT) {
						
						for(String pod : sN.POD__c.split(';'))
							setPods.add(pod.trim());
					}
				}
			}
		}
		
		//Map to hold Munchkin_ID__c Id as key and Community_Subscription__c as value
		Map<String, List<Community_Subscription__c>> mapMIdAndCSs = new Map<String, List<Community_Subscription__c>>();
		 
		//Loop through community Subscription
		for(Community_Subscription__c cS : cSs) {
			
			//Check for Munchkin_ID__c Id
			if(cS.User__c != null && cS.User__r.Munchkin_ID__c != null) {
				
				//Check for Munchkin_ID__c in map
				if(mapMIdAndCSs.containsKey(cS.User__r.Munchkin_ID__c))
					mapMIdAndCSs.get(cS.User__r.Munchkin_ID__c).add(cS);
				else
					mapMIdAndCSs.put(cS.User__r.Munchkin_ID__c, new List<Community_Subscription__c> {cS});
			}
		}
		
		//Map to hold Pod and Community_Subscription__c
		Map<String, List<Community_Subscription__c>> mapPodAndCSs = new Map<String, List<Community_Subscription__c>>();
		
		//Loop through Asset record
		for (Asset ast: [Select Id, Pod__c, Munchkin_ID__c From Asset Where Pod__c IN : setPods and Status =: Constants.ASSET_STATUS_ACTIVE 
							AND Munchkin_ID__c != null AND Pod__c != null AND Asset_Type__c =: Constants.ASSET_TYPE_SUBSCRIPTION]) {
			
			//Check MunchKin Id in Map
			if(mapMIdAndCSs.containsKey(ast.Munchkin_ID__c)) {
				
				//If mapPodAndCSs map contains Pod Id
				if(mapPodAndCSs.containsKey(ast.Pod__c)) 
					mapPodAndCSs.get(ast.Pod__c).addAll(mapMIdAndCSs.get(ast.Munchkin_ID__c));
				else
				mapPodAndCSs.put(ast.Pod__c, mapMIdAndCSs.get(ast.Munchkin_ID__c)); 						
			}
		}
		
		//Loop through Support News
		for(Marketo_News__c sN : newNews) {
			
			//Check for Appropriate condition to fire trigger
			if(sN.Active__c == true && sN.Type__c == Constants.SUPPORT_NEWS_TYPE_ALERT && sN.Pod__c != null) {
				
				//Set to hold Community_Subscription__c
				Set<Community_Subscription__c> setTempCSs = new Set<Community_Subscription__c>();
				
				//Loop through Pod
				for(String pod : sN.Pod__c.trim().split(';')) {
					
					//Check Pod Id in map
					if(mapPodAndCSs.containsKey(pod.trim()))
						setTempCSs.addAll(mapPodAndCSs.get(pod.trim()));
				}
				
				//Check for set size
				if(setTempCSs.size() > 0) {
					
					//List of Community_Subscription__c
					List<Community_Subscription__c> tempCSs = new List<Community_Subscription__c>();
					tempCSs.addAll(setTempCSs);
					
					//Populate map with values
					mapNIdAndCSs.put(sN.Id, tempCSs);
				}
			}
		}
		
		//Check for Map Size
		if(mapNIdAndCons.size() > 0 || mapNIdAndCSs.size() > 0 || mapSNIdAndCSs.size() > 0) {
			
			//Query through EmailTemplate
			List<EmailTemplate> eTs = [Select Id, DeveloperName From EmailTemplate where DeveloperName =: Label.ET_DEVELOPERNAME_MARKETO_COMMUNITY_ALL_NEWS
																		OR DeveloperName =: Label.ET_DEVELOPERNAME_MARKETO_COMMUNITY_ALL_ALERTS LIMIT 2];
			
			//Check for EmailTemplate list size
			if(eTs.size() > 0 && eTs.size() == 2) {
				
				//Check for map size
				if(mapSNIdAndCSs.size() > 0) {
					
					//List of EmailTemplate
					List<EmailTemplate> eT = new List<EmailTemplate>();
					
					//Check for DeveloperName
					if(eTs[0].DeveloperName == Label.ET_DEVELOPERNAME_MARKETO_COMMUNITY_ALL_NEWS)
						eT.add(eTs[0]); 
					else 
						eT.add(eTs[1]);	
					
					//Call EmailHandler class method to send email
					EmailHandler.sendEmail(eT, mapSNIdAndCSs);
				}
				
				//Check for map
				if(mapNIdAndCons.size() > 0 || mapNIdAndCSs.size() > 0) {
					
					//List of EmailTemplate
					List<EmailTemplate> eT = new List<EmailTemplate>();
					
					//Check for DeveloperName
					if(eTs[0].DeveloperName == Label.ET_DEVELOPERNAME_MARKETO_COMMUNITY_ALL_NEWS)
						eT.add(eTs[1]); 
					else 
						eT.add(eTs[0]);
						
					//Check for Map size
					if(mapNIdAndCSs.size() > 0)
						EmailHandler.sendEmail(eT, mapNIdAndCSs);
					
					//Check for map size
					if(mapNIdAndCons.size() > 0)
						EmailHandler.sendEmail(eT, mapNIdAndCons);
				}
			}
		}
	}
}