/**
 *  Description    :   Helper class for Trigger_CertificationHistory trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
    
public without sharing class CertificationHistoryTriggerHelper {
	
	//Boolean variable for account trigger execution
    public static Boolean execute_Cretification_History_Trigger = true;
    
    /**
     *	@description	:	Method to sent information about user certification and give badges if
     *						1. BadgeVilleReward Status != true
     *						2. Exam Result = Pass
     *						3. Contact is portal user
     *
     *	@args			:	List<Certification_History__c>, Map<Id, Certification_History__c>
     *
     *	@return			:	void
     *
     **/
	public static void userCertification(List<Certification_History__c> newCHistories, Map<Id, Certification_History__c> mapOldCHistories) {
		
		//Set to hold contact Id
		Set<Id> setConIds = new Set<Id>();
		
		//Set to hold Certification_History__c Id
		Set<String> setSHIds = new Set<String>();
		
		//Loop through Cretification_History 
		for(Certification_History__c cH : newCHistories) {
			
			//Check appropriate condition to fire trigger
			if(cH.Certification_Contact__c != null && cH.BadgeVilleReward_Status__c != true && cH.Exam_Result__c == Constants.CHISTORY_EXAM_RESULT_PASS 
				&& (mapOldCHistories == null || cH.Exam_Result__c != mapOldCHistories.get(cH.Id).Exam_Result__c)) {
					
					//Add contact Id in set
					setConIds.add(cH.Certification_Contact__c);
			}
		}
		
		//Map to hold Contact Id as key and User As value
		Map<Id, User> mapConIdAndUsers = new Map<Id, User>();
		
		//Loop through users
		for(User usr : [Select Id, Name, IsPortalEnabled, Email, ContactId From User Where IsActive = true AND IsPortalEnabled = true 
																						   AND ContactId != null AND ContactId IN : setConIds]) {
			
			//Populate map with values
			mapConIdAndUsers.put(usr.ContactId, usr);
		}
		
		//Loop through Cretification_History
		for(Certification_History__c cH : newCHistories) {
			
			//Check appropriate condition to fire trigger
			if(cH.Certification_Contact__c != null && cH.BadgeVilleReward_Status__c != true && cH.Exam_Result__c == Constants.CHISTORY_EXAM_RESULT_PASS
				&& mapConIdAndUsers.containsKey(cH.Certification_Contact__c) && (mapOldCHistories == null || cH.Exam_Result__c != mapOldCHistories.get(cH.Id).Exam_Result__c)) {
				
				//Add Certification_History__c Id in set
				setSHIds.add(cH.Id);
			}
		}
		
		//Check for set size
		if(setSHIds.size() > 0) {
			
			//Execute Batch
			BVBatchApexWebCalloutCertificationClass bv = new BVBatchApexWebCalloutCertificationClass(setSHIds);
			Database.executeBatch(bv,1);
		} 
	}
	
	/**
	 *	@descripation	:	Method to update Account and Email on Certification History according to Certification Contact.
	 *
	 *	@args			:	List<Certification_History>
	 *
	 *	@return			:	void
	 *
	 **/
	public static void validateAccountAndEmail(List<Certification_History__c> newCHistories) {
		
		//Set to hold contact Id
		Set<Id> setConIds = new Set<Id>();
		
		//Loop through Certification_History__c
		for(Certification_History__c cH : newCHistories) {
			
			//Check for Contact
			if(cH.Certification_Contact__c != null) {
				
				//Add contact Id in set
				setConIds.add(cH.Certification_Contact__c);
			}
		}
		
		//Map to hold contact
		Map<Id, Contact> mapContacts = new Map<Id, Contact>([Select Id, Email, AccountId From Contact Where Id IN : setConIds]);
		
		//Loop through Certification_History__c
		for(Certification_History__c cH : newCHistories) {
			
			//Check for contact Id
			if(cH.Certification_Contact__c != null && mapContacts.containsKey(cH.Certification_Contact__c)) {
				
				//Check for Account Id
				if(cH.Account__c != mapContacts.get(cH.Certification_Contact__c).AccountId) 
					cH.Account__c = mapContacts.get(cH.Certification_Contact__c).AccountId;
				
				//Check for Email
				if(cH.Business_Email_Address__c != mapContacts.get(cH.Certification_Contact__c).Email)
					cH.Business_Email_Address__c = mapContacts.get(cH.Certification_Contact__c).Email;
			}
		}
	}
	
	/**
	 *	@description	:	Method to create JBCXM__Milestone__c record if cerification History's Account is alreay related to any JBCXM__CustomerInfo__c 
	 *						record 
	 *
	 *	@args			:	List<Certification_History__c>, Map<Id, Certification_History__c>()
	 *
	 *	@return			:	void
	 *
	 **/
	public static void createJBCXMMilstone(List<Certification_History__c> newCHIstories, Map<Id, Certification_History__c> mapOldCHistories) {
		
		//Set to hold contact Id
		Set<Id> setAccIds = new Set<Id>();
		
		//Set to hold Certification_History__c Id
		Set<Id> setCHIds = new Set<Id>();
		
		//Map to hold account Id as key and JBCXM__CustomerInfo__c as value
		Map<Id, JBCXM__CustomerInfo__c> mapAccIdAndJBCXMCInfo = new Map<Id, JBCXM__CustomerInfo__c>();
		
		//Loop through Certification_History__c
		for(Certification_History__c cH : newCHIstories) {
			
			//Check appropriate condition to fire trigger
			if(cH.Certification_Contact__c != null && cH.Account__c != null && cH.Exam_Result__c == Constants.CHISTORY_EXAM_RESULT_PASS
				&& (mapOldCHistories == null || cH.Exam_Result__c != mapOldCHistories.get(cH.Id).Exam_Result__c)) {
					
				//Add Account Id in set
				setAccIds.add(cH.Account__c);
				
				//Add Certification_History__c Id in set
				setCHIds.add(cH.Id);
			}
		}
		
		//Loop through JBCXM__CustomerInfo__c
		for(JBCXM__CustomerInfo__c jCI : [Select Id,JBCXM__Account__c From JBCXM__CustomerInfo__c Where JBCXM__Account__c IN : setAccIds]) {
			
			//Populate map with values
			mapAccIdAndJBCXMCInfo.put(jCI.JBCXM__Account__c, jCI);
		}
		
		//Query through JBCXM__PickList__c
		List<JBCXM__PickList__c> jBCXMs = [SELECT Id, JBCXM__SystemName__c, JBCXM__Category__c FROM JBCXM__PickList__c 
																		WHERE JBCXM__Category__c =: Constants.CONTACT_JBCXM_CATEGORY_MILESTONE
																		AND JBCXM__SystemName__c =:Constants.JBCXM_PICKLIST_SYSTEMNAME_MARKETO_CERTIFIED LIMIT 1];
		
		//List of JBCXM__Milestone__c
		List<JBCXM__Milestone__c> jBCXMMilestones = new List<JBCXM__Milestone__c>();
		
		//Loop through Certification_History__c
		for(Certification_History__c cH : [Select Id, Account__C, Certification_Contact__c, Certification_Contact__r.Name, Business_Email_Address__c,
												  Date_Passed_Exam__c, Certification_Level__c From Certification_History__c Where Id IN : setCHIds ]) {
															
			//Check for Account Id
			if(mapAccIdAndJBCXMCInfo.containsKey(cH.Account__c) && jBCXMs.size() > 0) {
				
				//Instance of JBCXM__Milestone__c
				JBCXM__Milestone__c jM = new JBCXM__Milestone__c();
				
				//Populate field values
				jM.JBCXM__Milestone__c = jBCXMs[0].Id;
				jM.JBCXM__Account__c = cH.Account__c;
				jM.JBCXM__Comment__c = 'Name: ' + cH.Certification_Contact__r.Name;
				
				//Check for Email
				if(cH.Business_Email_Address__c != null) 
					jM.JBCXM__Comment__c += ' | Email: ' + cH.Business_Email_Address__c;
				
				//Check for Certification_Level__c
				if(cH.Certification_Level__c != null)
					jM.JBCXM__Comment__c += ' | Marketo Certification: ' + cH.Certification_Level__c;
				
				//Check for Date_Passed_Exam__c
				if(cH.Date_Passed_Exam__c != null)
					jM.JBCXM__Date__c = cH.Date_Passed_Exam__c;
				
				//Add in list
				jBCXMMilestones.add(jM);	
			}
		}
		
		//Check for list size
		if(jBCXMMilestones.size() > 0) {
			
			//try-Catch block
			try {
				
				insert jBCXMMilestones;
			} catch(Exception e) {
				
				JBCXM__Log__c errorLog = New JBCXM__Log__c();
				
				//Populate field values
				errorLog.JBCXM__ExceptionDescription__c = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()
														  + ' while running the Trigger to create a Milestone for Marketo Certification';
				errorLog.JBCXM__LogDateTime__c = datetime.now();
				errorLog.JBCXM__SourceData__c = e.getMessage();
				errorLog.JBCXM__SourceObject__c = 'Case';
				errorLog.JBCXM__Type__c = 'Trigger_CertificationHistory';
				
				//insert error
				insert errorLog;
			}
		} 
	}
}