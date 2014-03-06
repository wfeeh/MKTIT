/**
 *  Description    :   Helper class for Trigger_Case trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Version      	:  	V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/       
public without sharing class CaseTriggerHelper {
	
	//Boolean variable to control CampaignMember trigger execution
	public static Boolean Execute_Case_Trigger = true;
	
	//Boolean variable to Case trigger execution on request type
	public static Boolean execute_Trigger_IsBefore = false;
	public static Boolean execute_Trigger_IsAfter = false;
	
	/**
	 *	@Description	:	Method to Update case Entitlement, Asset and set related contact's 	Redirect_To_Case_Create__c to true 
	 *
	 *	@args			:	List<Case>, Boolean
	 *
	 *	@return			:	void
	 **/
	public static void validateCaseContact(List<Case> newCases, Boolean isInsert) {
		
		//Set to hold case contact Id
		Set<Id> setContactIds = new Set<Id>();
		
		//Map to hold User's Munchkin Id as key and list of user as value
		Map<String, List<User>> mapUsers = new Map<String, List<User>>();
		Map<String, List<User>> mapAuthUsers = new Map<String, List<User>>();
		
		//Map to hold Contact Id as key and Entitlements corresponding to this contact
		Map<Id, Entitlement> mapConIdAndEntitlements = new Map<Id, Entitlement>();
		
		//Map to hold Email with Entitlement
		Map<String, Entitlement> mapConEmailAndEntitlement = new Map<String, Entitlement>();
				
		//Map of User Id and Entitlement
		Map<Id, Entitlement> mapUsrIdAndEntitlement = new Map<Id, Entitlement>();
		
		//Set to hold email address related to case
		Set<String> setEmails = new Set<String>();
		
		//Map of contacts
		Map<Id,Contact> mapContacts = new Map<Id,Contact>();
		
		//Set to hold auth.contactId
		Set<Id> setAuthContacts = new set<Id>(); 
		
		//Loop through case
		for(Case cse : newCases) {
			
			//Check for case contact
			if(cse.ContactId != null) {
				
				//Add contact Id in set
				setContactIds.add(cse.ContactId);
			}
			
			//Check for 
			if(cse.SuppliedEmail != null)
					setEmails.add(cse.SuppliedEmail);
		}
		
		//Loop through contact
		for(Contact con : [Select Id, Redirect_To_Case_Create__c, Email From Contact Where Id IN : setContactIds AND Email != null]) {
			
			//Add Contact Email in Set
			setEmails.add(con.Email);
			mapContacts.put(con.Id, con);
		}
		
		//Set of String
		Set<Id> setEntitleId = new Set<Id>();
		
		//Query through Authorized_Contact__c
		for(Authorized_Contact__c authCon : [Select Email__c, Contact__c, Entitlement__c From Authorized_Contact__c
																		Where Email__c != null AND Email__c IN  : setEmails]) {
																			
			//Populate map with value
			setAuthContacts.add(authCon.Id);
			
			//Populate set
			setEntitleId.add(authCon.Entitlement__c);													
		}
   
		//Set to hold Munchkin Ids
		Set<String> setMunchinIds = new Set<String>();
		
		//String variable to hold Munchkin Id of current user
		String currentUsrMunchkinId = '';
		
		//Id variable to hold current user id
		Id curentUserId = UserInfo.getUserId(); 
		
		//Loop through user Id
		for(User usr : [Select Id, Email, Munchkin_ID__c, ContactId, Contact.Email From User where Munchkin_ID__c != null 
																								   AND ((ContactId IN : setContactIds AND isActive = true)
																											OR ContactId IN : setAuthContacts 
																										 	OR Id = :UserInfo.getUserId())]) {
			
			//Check for current user Id
			if(usr.Id == UserInfo.getUserId())
				currentUsrMunchkinId = usr.Munchkin_ID__c;
				
			//Add values in set
			setMunchinIds.add(usr.Munchkin_ID__c);
				
			//Check for Contact Id
			if(setContactIds.contains(usr.ContactId)) {
			
				//Check if map contains MunchKin Id
				if(mapUsers.containsKey(usr.Munchkin_ID__c)) {
					
					//Add new User
					mapUsers.get(usr.Munchkin_ID__c).add(usr);
				} else {
					
					//Populate map with value
					mapUsers.put(usr.Munchkin_ID__c, new List<User>{usr});
				}
			}
			
			//Check for Auth. Contact
			if(setAuthContacts.contains(usr.ContactId)) {
				
				//Check for User in map
				if(mapAuthUsers.containsKey(usr.Munchkin_ID__c)) {
					
					//Add new User in map
					mapAuthUsers.get(usr.Munchkin_ID__c).add(usr);
				} else {
					
					//Populate map with values
					mapAuthUsers.put(usr.Munchkin_ID__c, new List<User>{usr});
				}
			}
		}
		
		//Loop through Entitlement
		for(Entitlement entitlement : [Select Id, AssetId, Asset.Munchkin_ID__c, of_Active_Authorized_Contacts_Available__c From Entitlement  
                    								where Status = 'Active' AND (Asset.Munchkin_ID__c IN : setMunchinIds OR Id IN : setEntitleId) ]) {
                    									
        	//Check for Munchkin Id
        	if(currentUsrMunchkinId == entitlement.Asset.Munchkin_ID__c && !mapUsrIdAndEntitlement.containsKey(curentUserId)) {
        		
        		//Populate map with value
        		mapUsrIdAndEntitlement.put(UserInfo.getUserId(), entitlement);
        	}
        	
        	//Check if munchkin Id in map
        	if(mapAuthUsers.containsKey(entitlement.Asset.Munchkin_ID__c)) {
        		
        		//Loop through map
        		for(User usr : mapAuthUsers.get(entitlement.Asset.Munchkin_ID__c)) {
        			
        			//Populate map with values
        			mapConEmailAndEntitlement.put(usr.Contact.Email,entitlement);
        		}
        	} 
        	
        	//Check Munchkin Id in set
        	if(mapUsers.containsKey(entitlement.Asset.Munchkin_ID__c)) {
        	
	        	//Loop through Users
	        	for(User usr : mapUsers.get(entitlement.Asset.Munchkin_ID__c)){
	        		
	        		//Populate map with values
        			mapConIdAndEntitlements.put(usr.ContactId, entitlement);
	        	}
        	}
        }
        
        //List of contact
        List<Contact> contacts = new List<Contact>();
        
        //Loop through case
        for(Case cse : newCases) {
        	
        	//Check if map contains contactId
        	if(cse.Origin != null && cse.Origin == Constants.Case_ORIGIN_EMAIL && cse.ContactId != null && isInsert 
        		&& UserInfo.getUserType() == Constants.USER_TYPE_STANDARD && mapConIdAndEntitlements.containsKey(cse.ContactId)) {
        		
        		//Update case
        		cse.Count_AuthContact_Available__c = mapConIdAndEntitlements.get(cse.ContactId).of_Active_Authorized_Contacts_Available__c;
        		
        		//Check if contact map also contains case's contact
        		if(mapContacts.containsKey(cse.ContactId) && mapContacts.get(cse.ContactId).Redirect_To_Case_Create__c != true) {
        			
        			//Update contacts field
        			mapContacts.get(cse.ContactId).Redirect_To_Case_Create__c = true;
        			
        			//Add in list for update
        			contacts.add(mapContacts.get(cse.ContactId));
        		}
        	}
        	
        	//Check for case origin and Current user
        	if(cse.Origin != Constants.Case_ORIGIN_EMAIL && UserInfo.getUserType() != Constants.USER_TYPE_STANDARD
        		&& mapUsrIdAndEntitlement.containsKey(UserInfo.getUserId())) {
        		
        		//update case Entitlement field and asset
        		cse.EntitlementId = mapUsrIdAndEntitlement.get(UserInfo.getUserId()).Id;
        		cse.AssetId = mapUsrIdAndEntitlement.get(UserInfo.getUserId()).AssetId;
        		
        	} else if(cse.Origin != null && cse.Origin == Constants.Case_ORIGIN_EMAIL) { 
        		
        		//update Entitlement on case
        		if(cse.SuppliedEmail != null && mapConEmailAndEntitlement.ContainsKey(cse.SuppliedEmail) 
        			&& mapConEmailAndEntitlement.get(cse.SuppliedEmail) != null) {
        			
        			cse.EntitlementId = mapConEmailAndEntitlement.get(cse.SuppliedEmail).Id;
        			cse.AssetId = mapConEmailAndEntitlement.get(cse.SuppliedEmail).AssetId != null ? mapConEmailAndEntitlement.get(cse.SuppliedEmail).AssetId : null;	
        		
        		} else if(mapContacts.containsKey(cse.ContactId) && mapContacts.get(cse.ContactId).Email != null 
        					&& mapConEmailAndEntitlement.containsKey(mapContacts.get(cse.ContactId).Email)
        					&& mapConEmailAndEntitlement.get(mapContacts.get(cse.ContactId).Email) != null) {
        			
        			cse.EntitlementId = mapConEmailAndEntitlement.get(mapContacts.get(cse.ContactId).Email).Id;
        			cse.AssetId =  mapConEmailAndEntitlement.get(mapContacts.get(cse.ContactId).Email).AssetId;
        			
        		}	 
        	} 
        }
		
		//Check the size of contact list and update
    	if(contacts.size()>0)
    		update contacts;
        
	}
	
	/**
	 *	@Description	:	This trigger is used to validate completion date field
	 *
	 *	@args			:	List<Case>, Map<Id,Case>
	 *
	 *	@return			:	void
	 **/
	 public static void validateCaseCompletionDate(List<Case> newCases, Map<Id,Case> mapOldCases, Boolean isInsert, Boolean isUpdate){
	 	
	 	//Set to hold case Ids
	 	Set<Id> setCaseIds = new Set<Id>();
	 	
	 	//Loop through case
	 	for(Case cse : newCases){
            
            //Check the values for fire the trigger
			if(cse.Origin != null && cse.Origin == Constants.CASE_ORIGIN_PHONE && (mapOldCases == null || 
				(cse.IsClosed && cse.IsClosed != mapOldCases.get(cse.id).isClosed ))){
				
				//Add the values in set
            	setCaseIds.add(cse.id); 
			}  
        }
        
       	//Query through CaseMilestone
	 	List<CaseMilestone> caseMilestones = new List<CaseMilestone>();
             
		//Loop through list CaseMilestone
        for (CaseMilestone cm : [Select Id, completionDate,MilestoneType.Name From CaseMilestone Where CaseId IN : setCaseIds And 
 									    										( MilestoneType.Name =: Constants.CASE_MILESTONENAME_FIRST_RESPONSE 
 									    										OR MilestoneType.Name =: Constants.CASE_MILESTONENAME_RESOLUTION )
                    															And completionDate = null ]){
                	
			//Check for Event and Milestone Name
            if((cm.MilestoneType.Name == Constants.CASE_MILESTONENAME_FIRST_RESPONSE && isInsert) ||
                	(cm.MilestoneType.Name == Constants.CASE_MILESTONENAME_RESOLUTION && isUpdate)) {
                		
            	//Assigning value 
                cm.completionDate = System.today();
                		
                //add the value in list
                caseMilestones.add(cm);
            }
       }
            
	   //Check for size
	   if(caseMilestones.size() > 0)
					
	   		//Update 
		    update caseMilestones;
     }
	/**
	 *	@Description	:	This method is used to update the value of BusinessHoursId
	 *
	 *	@args			:	List<Case>
	 *
	 *	@return			:	void
	 **/
	 public static void validateBuisnessHoursId(List<Case> newCases){
	 	
	 	//Set to hold case Id
	 	Set<Id> setCaseIds = new Set<Id>();
	 	
	 	//Set hold entitlement Id
	 	Set<Id> setEntitleIds = new Set<Id>();
	 	
	 	//Loop through case
	 	for(Case cse : newCases){
	 		
	 		//Check the condition to fire trigger
	 		if(cse.Priority == Constants.CASE_PRIORITY_P1){
	 			
	 			//Add the values in set
	 			setCaseIds.add(cse.Id);
	 			
	 		} else If(cse.EntitlementId != null){
	 			
	 			//Add the values in set
	 			setEntitleIds.add(cse.EntitlementId);
	 		}
	 	}
	 	 
	 	//List of buisness hours
	 	List<BusinessHours> buisnessHrs = new List<BusinessHours>();
	 	
	 	//Check the size of set
	 	if(setCaseIds.size() > 0){
	 		
		 	//Query through BuinsnessHours
		 	buisnessHrs	= [Select Id, Name From Businesshours Where Name = : Constants.BUISNESSHOURS_NAME_P1_ISSUES LIMIT 1]; 
	 	}
	 	
	 	//Query through Entitlement
	 	Map<Id,Entitlement> mapEntitlements = new Map<Id,Entitlement>([Select Id, BusinessHoursId From Entitlement Where Id IN : setEntitleIds]);
	 	
	 	//Loop through Case																	
	 	for(Case cse : newCases){
	 		
	 		//Check the value of Priority(field) and size of Listset
	 		if(cse.Priority == Constants.CASE_PRIORITY_P1 && buisnessHrs.size() > 0){
	 			
	 			//Populate the value of BusinessHoursId
	 			cse.BusinessHoursId = buisnessHrs[0].Id; 
	 			 
	 		} else if(cse.EntitlementId != null && mapEntitlements.containsKey(cse.EntitlementId)){
	 			
	 			//Populate the value of BusinessHoursId
	 			cse.BusinessHoursId = mapEntitlements.get(cse.EntitlementId).BusinessHoursId;
	 		}
    	}
	}
	
	/**
	 *	@Description	:	This method is to Send Notification using case records. 
	 *
	 *	@args			:	Map<Id, Case>
	 *
	 *	@return			:	void
	 **/
	public Static void CaseReceivedNotificationEmail(Map<Id, Case> mapOfCase) {

		//List of case
		Set<Id> caseIds = new Set<Id>();

		//Loop through values of map
		for(Case cse : mapOfCase.Values()) {
			
			//Check for	Emails
			if(cse.SuppliedEmail != NULL && cse.SuppliedEmail != 'jordan@easyemailsolutions.com' 
				&& cse.SuppliedEmail != 'jackie@jackiewalts.com' && cse.SuppliedEmail != 'support@marketo.com' 
				&& cse.SuppliedEmail.contains('@marketo.com') && cse.RecordType.Name == Constants.CASE_RECORD_TYPE_NAME_SUPPORT_EMAIL_TO_CASE 
				&& cse.Account.Type != Constants.CASE_ACCOUNT_TYPE_EX_CUSTOMER  && cse.Account.Type != Constants.CASE_ACCOUNT_TYPE_EX_PARTNER 
				&& cse.ContactId != Null && cse.Entitlement.Status == 'Active' && cse.Entitlement.SlaProcessId != NULL 
				&& (cse.Entitlement.SlaProcess.Name == 'Spark Plus Support'|| cse.Entitlement.SlaProcess.Name == 'Spark Support') 
				&& cse.Entitlement.SocialMarketing_Only__c != True && cse.Contact.Is_Authorized_Contact__c == 'Yes' && cse.Origin == 'Email'){		
				
				//Add to list
				caseIds.add(cse.Id);
			}
		}
		//Call the future handler class
		CaseNotificationFutureHandler.caseNotificationHandler(caseIds);
	}

	/**
	 *	@Description	:	This method is validate the value in JBCXM__Alert__c
	 *
	 *	@args			:	List<Case>, Map<Id,Case>, Boolean isdelete
	 *
	 *	@return			:	void
	 **/
	 public static void validateValuesOfJBCXMAlert(List<Case> newCases, Map<Id,Case> mapOldCases, Boolean isDelete){
	 	
	 	//set to hold CaseIds
	 	Set<Id> setAccountIds = new Set<Id>();
	 	
	 	//Set to hold case Id these related JBCXM Alert records for delete
	 	Set<Id> setDelCaseIds = new Set<Id>();
		
	 	//Loop through Case
	 	for(Case cse : !isDelete ? newCases : mapOldCases.values()){
	 		
	 		//Check the value to fire trigger
	 		if(!isDelete && cse.AccountId != null && cse.Priority == Constants.CASE_PRIORITY_P1 &&(mapOldCases == null 
	 			||(cse.Priority == Constants.CASE_PRIORITY_P1 && mapOldCases.get(cse.id).priority != cse.priority))){
	 			
	 			//Assign the values in set
	 			setAccountIds.add(cse.AccountId);
	 			
	 		} else if(!isDelete && mapOldCases != null && cse.Priority != mapOldCases.get(cse.Id).Priority && mapOldCases.get(cse.Id).Priority == Constants.CASE_PRIORITY_P1) {
	 			
	 			//Add value in set
	 			setDelCaseIds.add(cse.Id);
	 		} else if(isDelete) {
	 			
	 			//Add value in set
	 			setDelCaseIds.add(cse.Id);
	 		}
	 		
	 	}
	 	
	 	//Map to hold the AccountId value of JBCXM_CustomerInfo
	 	Map<String, JBCXM__CustomerInfo__c> mapJBCXMcutomerInfo = new Map<String,JBCXM__CustomerInfo__c>();
	 	
		//Loop through JBCXM CustomerInfo
		for(JBCXM__CustomerInfo__c customerInfo : [Select Id, JBCXM__ASV__c, JBCXM__MRR__c, JBCXM__Account__c From JBCXM__CustomerInfo__c 
													Where JBCXM__Account__c IN : setAccountIds And (JBCXM__ASV__c != null OR JBCXM__MRR__c != null)]){
			
			//Assign the values in map
			mapJBCXMcutomerInfo.put(customerInfo.JBCXM__Account__c, customerInfo);
		}
		
		//Map to hold JBCXM Picklist record Id corresponding to SystemName
		Map<String, Id> mapJBCXMPicks = new Map<String, Id>();
		
		//Query through JBCXM PickList
		for(JBCXM__PickList__c jBCXMPick : [Select Id, Name, JBCXM__SystemName__c,JBCXM__Category__c From JBCXM__PickList__c
											Where JBCXM__Category__c Like 'Alert %' 
											AND JBCXM__SystemName__c IN ('alertseverity2','ID', 'Customer Concern', 'OpenCase')]) {
																												 	
			//Populate map with values
			mapJBCXMPicks.put(jBCXMPick.JBCXM__SystemName__c, jBCXMPick.Id);
		}
		
		//List to hold the JBCXM Alert
		List<JBCXM__Alert__c> jBCXMAlerts = new List<JBCXM__Alert__c>();
		
		//Query through JBCXM__Alert__c list for delete
		List<JBCXM__Alert__c> jBCXMAlertsForDelete  = [Select Id, JBCXM__AssociatedObjectRecordID__c From JBCXM__Alert__c 
															Where JBCXM__AssociatedObjectRecordID__c IN : setDelCaseIds];		
		
		//Check for delete case
		if(!isDelete) {
		
			//Loop through case
			for(Case cse : newCases){
				
				//Check the value to fire trigger
	 			if(!isDelete && cse.AccountId != null && cse.Priority == Constants.CASE_PRIORITY_P1 &&(mapOldCases == null 
	 				||(cse.Priority == Constants.CASE_PRIORITY_P1 && mapOldCases.get(cse.id).priority != cse.priority))){
				
					//check the vaules in map
					if(mapJBCXMcutomerInfo.containsKey(cse.AccountId)){
						
						//Instance of JBCXM Alert
						JBCXM__Alert__c jBCXMAlert = new JBCXM__Alert__c();
							
						jBCXMAlert.Name = 'New P1 Case has been logged' ;	
						jBCXMAlert.JBCXM__Account__c  	= cse.AccountId;
						jBCXMAlert.JBCXM__Date__c  = Date.today();
						jBCXMAlert.JBCXM__ASV__c = mapJBCXMcutomerInfo.get(cse.AccountId).JBCXM__ASV__c != null ? mapJBCXMcutomerInfo.get(cse.AccountId).JBCXM__ASV__c : 0;
						jBCXMAlert.JBCXM__MRR__c = mapJBCXMcutomerInfo.get(cse.AccountId).JBCXM__MRR__c != null ? mapJBCXMcutomerInfo.get(cse.AccountId).JBCXM__MRR__c : 0;
						jBCXMAlert.JBCXM__AssociatedObjectRecordID__c = cse.Id;
						jBCXMAlert.JBCXM__Comment__c = 'An open P1 case has been logged and needs to be reviewed.<br><br><a target="_blank" href="' +
						 							   URL.getSalesforceBaseUrl().toExternalForm().replace('-api','') + '/' + cse.Id + '">Case ' + 
						 							   cse.CaseNumber + '</a>';
						
						//Check for value in map
						if(mapJBCXMPicks.containsKey(Constants.JBCXM_PICKLIST_SYSTEM_NAME_ALERTSEVERITY))
							jBCXMAlert.JBCXM__Severity__c = mapJBCXMPicks.get(Constants.JBCXM_PICKLIST_SYSTEM_NAME_ALERTSEVERITY);
						
						if(mapJBCXMPicks.containsKey(Constants.JBCXM_PICKLIST_SYSTEM_NAME_ID))
							jBCXMAlert.JBCXM__Status__c  = mapJBCXMPicks.get(Constants.JBCXM_PICKLIST_SYSTEM_NAME_ID);
							
						if(mapJBCXMPicks.containsKey(Constants.JBCXM_PICKLIST_SYSTEM_NAME_CUSTOMER_CONCERN))
							jBCXMAlert.JBCXM__Type__c = mapJBCXMPicks.get(Constants.JBCXM_PICKLIST_SYSTEM_NAME_CUSTOMER_CONCERN);
						
						if(mapJBCXMPicks.containsKey(Constants.JBCXM_PICKLIST_SYSTEM_NAME_OPENCASE))
							jBCXMAlert.JBCXM__Type__c = mapJBCXMPicks.get(Constants.JBCXM_PICKLIST_SYSTEM_NAME_OPENCASE);
							
						//add the values in List
						jBCXMAlerts.add(jBCXMAlert);
					}
	 			}
			}
		}
		
		try{
			
			//Check the size of list
			if(jBCXMAlertsForDelete.size()> 0)
				delete jBCXMAlertsForDelete;
				
			//Check the size of list
			if(jBCXMAlerts.size() > 0)
				insert jBCXMAlerts;
			 
		} catch (Exception e) {
			
			//Instance of JBCXM__Log
        	JBCXM__Log__c errorLog = new JBCXM__Log__c();
        	
        	//Assign the values in JBCXM__ExceptionDescription(field)
        	errorLog.JBCXM__ExceptionDescription__c = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()+' while running the Trigger to create alerts from P1 Cases';
            errorLog.JBCXM__LogDateTime__c = datetime.now();
            errorLog.JBCXM__SourceData__c = e.getMessage();
            errorLog.JBCXM__SourceObject__c = 'Case';
            errorLog.JBCXM__Type__c  = 'validateValuesOfJBCXMAlert';
        
	        //Insert the error Log   
	        insert errorLog;	
	 	}
	}
	
	/**
	 *	@Description	:	Method to update P1_Service_Restored_Time__c and P1_Switch_Time__c field on case according to CaseHistory record for
	 *						Priority field and also add sone error messsage in case of Entitliment and perticlur record type 
	 *
	 *	@args			:	List<Case>, Map<Id, Case>
	 *
	 *	@return			:	void
	 **/
	public static void validateSwitchAndServiceDate(List<Case> newCases, Map<Id, Case> mapOldCases) {
		
		//Map to hold  case Id as key and Case history record for Priority field as value according to created date
		Map<Id, CaseHistory> mapCaseHistories = new Map<Id, CaseHistory>();
		
		//Set to hold case Ids
		Set<Id> setCaseIds = new Set<Id>();
		Set<Id> setEntitlementIds = new Set<Id>();
		
		//String variable to hold RecordType Id corresponding of Case
		String caseRecordTypeId = CaseRecordOrTypeIds__c.getInstance('NonSupportCaseRecTIds').ReferenceIds__c;
		
		//String to hold particular values of close region(picklist) 
		String caseCloseRegion = CaseRecordOrTypeIds__c.getInstance('Auto_Case_Close_Reasons').ReferenceIds__c;
		
		//String to hold Group keyPrifix
		String groupKeyPrefix = Group.SObjectType.getDescribe().getKeyPrefix();
		
		//Loop through Case
		for(Case cse : newCases) {
			
			//Check the appropriate condition to fire the trigger
			if(cse.Status == Constants.CASE_STATUS_CLOSED && cse.Status != mapOldCases.get(cse.Id).Status && cse.P1_Service_Restored_Time__c == null
				&& cse.Priority == Constants.CASE_PRIORITY_P1) {
				
				//Add value in set
				setCaseIds.add(cse.Id);
			}
			
			//Check for RecordType Id
			if(caseRecordTypeId.containsIgnoreCase(cse.RecordTypeId) && cse.ContactId != null && cse.Status == Constants.CASE_STATUS_CLOSED
				&& cse.Status != mapOldCases.get(cse.Id).Status && !caseCloseRegion.containsIgnoreCase(cse.Close_Reason__c)) {
				
				//Add value in set
				setEntitlementIds.add(cse.EntitlementId);		
			}
		}
		
		//Query through current user
		List<User> currentUser = [Select Id, Name, IsPortalEnabled From User Where Id =: UserInfo.getUserId() LIMIT 1];
		
		
		//Loop through CaseHistory
		for(CaseHistory cHistory : [Select Id, CreatedDate, NewValue, CaseId From CaseHistory Where CaseId IN : setCaseIds 
															AND Field =: Constants.CASE_FIELD_PRIORITY order By CreatedDate DESC]) {
																
			
			//Check for Case id in map
			if(!mapCaseHistories.containsKey(cHistory.CaseId)) {
				
				//Populate map with value
				mapCaseHistories.put(cHistory.CaseId, cHistory);
			}												
		}
		
		//Map of Entitlement
		Map<Id, Entitlement> mapEntitliments = new Map<Id, Entitlement>([Select Id, AssetId from Entitlement Where Id IN : setEntitlementIds]);
		
		//Loop through new Case
		for(Case cse : newCases) {
			
			//Check the appropriate condition to fire the trigger
			if(cse.Status == Constants.CASE_STATUS_CLOSED && cse.Status != mapOldCases.get(cse.Id).Status && cse.P1_Service_Restored_Time__c == null
				&& cse.Priority == Constants.CASE_PRIORITY_P1) {
					
				//Update case P1_Service_Restored_Time__c with current time
				cse.P1_Service_Restored_Time__c = System.now();
			
				//Check if map contains case Id
				if(mapCaseHistories.containsKey(cse.Id)) {
					
					//Update case P1_Switch_Time__c with CaseHistory created date
					cse.P1_Switch_Time__c = mapCaseHistories.get(cse.Id).createdDate; 
				} else {
					
					//Update with case's created date
					cse.P1_Switch_Time__c = cse.createdDate;
				}			
			}
			
			//Check for error condition
			if(caseRecordTypeId.containsIgnoreCase(cse.RecordTypeId) && cse.Close_Reason__c!= null && !caseCloseRegion.containsIgnoreCase(cse.Close_Reason__c)
				&& cse.Status == Constants.CASE_STATUS_CLOSED && cse.Status != mapOldCases.get(cse.Id).Status) {
				
				//Check for Portal user error
				if(!currentUser[0].IsPortalEnabled && String.valueOf(cse.OwnerId).StartsWithIgnoreCase(groupKeyPrefix) 
					&& cse.Origin == Constants.CASE_ORGIN_TBD) {
						
						//Add error for user
						cse.addError('Records that are owned by a queue may not be closed with a valid close reason. Please take ownership of this' 
									 + 'record and try again.');
				}
				
				//Check for Entitlement
				if(cse.EntitlementId != null && mapEntitliments.containsKey(cse.EntitlementId) && mapEntitliments.get(cse.EntitlementId).AssetId == null) {
					
					//Add error message 
					cse.addError('Case Asset Entitlement Invalid Error - Please Reach out to supportfeedback@marketo.com for further assistance.');
				}
			}
		}
	}
	/**
	 *	@Description	:	This method  is used to SM Account and SM Contact related to email in email to case.
	 *
	 *	@args			:	List<Case>
	 *
	 *	@return			:	void
	 **/
	 public static void validateValueOfSituationAccAndCon (List<Case> newCases){

		//List of Case to update
		List<Case> casesToUpdate = new List<Case>();
		
		//Set to hols case SuppliedEmail
		Set<String> setSuppliedEmails = new Set<String>();
		
		//Set to hold Case id
		Set<Id> setCaseIds = new Set<Id>();
		
		//Loop through
		for(Case cse : newCases){
			
			//Check the conditio to fire trigger
        	if(cse.SuppliedEmail != null && cse.Origin != null && cse.Origin.equals(Constants.CASE_ORGIN_TBD)) {
        		
        		//Add values in set
        		setSuppliedEmails.add(cse.SuppliedEmail);	
        		setCaseIds.add(cse.Id);	
        	}
		}
		
		//Map  to hold the Acounting Email as key corresponding to the ID of account
		Map<String,Id> mapCaseAccountID = new Map<String,Id>();
		
		//Loop through Account to populate Map
		for(Account acc : [Select Id, Accounting_Email__c From Account Where Accounting_Email__c IN : setSuppliedEmails]){
			
			//check the values in map and populate it with the values
			if(!mapCaseAccountID.containsKey(acc.Accounting_Email__c)) {

				mapCaseAccountID.put(acc.Accounting_Email__c, acc.Id);
			 }
        }
		
		//Map to hold contact as Email as key corresponding to the contact
		Map<String, Contact> mapCaseContactEmail = new Map<String,Contact>();
		
		//Loop through Contact to populate Map
		for (Contact con : [Select Id, Email, AccountId From Contact Where Email IN : setSuppliedEmails]){
			
			//Check the values in map and also populate it with the values
            if(!mapCaseContactEmail.containsKey(con.Email)) {
			  
                mapCaseContactEmail.put(con.Email, con);
            }
        }
        
        //Loop through case
		for(Case cse :[Select Id, SuppliedEmail, Origin, Situation_Contact__c, Situation_Account__c ,ContactId, AccountId From Case Where Id IN :setCaseIds]) {
            
            //Check the values to fire trigger
			if(cse.SuppliedEmail!= null  &&  cse.Origin!= null && cse.Origin.equals(Constants.CASE_ORGIN_TBD)) {
			
				//Check for suppliedEmail in map if yes then popultae te value in Situation Contact
				if(mapCaseContactEmail.containsKey(cse.SuppliedEmail)) {
					
					//Assigning values	
					cse.Situation_Contact__c = mapCaseContactEmail.get(cse.SuppliedEmail).Id;
					cse.Situation_Account__c = mapCaseContactEmail.get(cse.SuppliedEmail).AccountId;
	            }
	            
				//Check dor supplied email if yes then populate the value in Situation Account   
				if(cse.SuppliedEmail != null && cse.Situation_Account__c == null && mapCaseAccountID.containsKey(cse.SuppliedEmail)) {
	                
					//Assignning values
					cse.Situation_Account__c = mapCaseAccountID.get(cse.SuppliedEmail);
	            }
	            
	            //Assign the acconutId and contactId with null values
	            cse.AccountId = null;
	            cse.ContactId = null;
	                  
	            //Add to list
				casesToUpdate.add(cse);
			}
         }
		
		//Check for list size
		if(casesToUpdate.size() > 0) 
			update casesToUpdate;
	}
	
	/**
	 *	@Description	:	Method to sent Email notification about case absed on there Contact
	 *
	 *	@args			:	List<Case>, Map<Id, Case>
	 *
	 *	@return			:	void
	 **/
	 public static void sendSurveyOnCaseClose(List<Case> newCases , Map<Id,Case> mapOldCases){
		
		//Map to get CSatSurveySettings__c(custom setting) Data
		Map<String, CSatSurveySettings__c> mapCSatSurveySettings = Constants.CSATSURVEYSETTINGS_CUSTOM_SETTING;
		
		//Check for CSatSurveySettings__c data
		if(mapCSatSurveySettings.size() == 0 || mapCSatSurveySettings.get('IsCSatSurveyActive').Survey_Active__c != true)
			return;
		
		//Query through RecordType
	 	 ID caseRecortypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Support Cases').getRecordTypeId();
	 	System.debug('##### '); 
	 	//Set to hold case contactId
	 	Set<Id> setCaseConId = new Set<Id>();
	 	
	 	//Set to hold case id
	 	Set<Id> setCaseIds = new Set<Id>();
	 	
	 	//Map to hold User contactId as key corresponding to the Community Profile
    	Map<Id,Community_Profile__c> mapComProflies = new Map<Id,Community_Profile__c>();
    	
    	//Set to hold
    	Set<Id> setUserId = new Set<Id>();
    	
	 	//String to hold Group keyPrifix
		String groupKeyPrefix = Group.SObjectType.getDescribe().getKeyPrefix();

	 	//Map to hold Contact's Preferred Language as key and corresponding to this hold list of case to send email notification
	 	Map<String, List<Case>> mapConLangAndCases = new Map<String, List<Case>>();
	 	
	 	//Loop through Case
	 	for(Case cse : newCases){
	 
	 		//Check the value  for fire the trigger
	 		if(cse.ContactId != null && cse.isClosed == true && cse.RecordTypeId == caseRecortypeId && Constants.SET_CASE_CLOSE_REASON.Contains(cse.Close_Reason__c)
	 			&& (cse.isClosed != mapOldCases.get(cse.id).isClosed) && cse.Problem_Type__c != Constants.CASE_PROBLEM_TYPE_CONFIGURATION 
	 			&& cse.Category__c != Constants.CASE_CATEGORY_CONFIGURATION_OUTREACH){
	 			
	 			//Add the values in set
	 			setCaseConId.add(cse.ContactId);
	 			setCaseIds.add(cse.Id);
	 		}
	 	}
	 	
	 	//Map to populate the value Authorize contact boolean value
    	Map <Id,Boolean> mapToGetAuthConBooleanValue = Utility.getAuhContactValue(setCaseConId);
    	
    	System.debug('mapToGetAuthConBooleanValue ##### : ' +mapToGetAuthConBooleanValue);
	 	
	 	//Loop through Commmunity Profile
    	for(Community_Profile__c comProfile : [Select Id, User__r.ContactId, CSatSurveyPreferences__c From
    																	 Community_Profile__c  Where User__r.ContactId IN : setCaseConId]){
    		//Map to populate values
    		mapComProflies.put(comProfile.User__r.ContactId , comProfile);														 	
    	}
    	
    	//Loop through User
    	for(User usr : [Select IsPortalEnabled, ContactId From User Where Contactid IN : setCaseConId AND IsPortalEnabled = true ]){
    		
    		//Assign the values in set
    		setUserId.add(usr.ContactId);
    	}
    	
    	//Loop through Case
    	for(Case cse : [Select Id, OwnerId, isClosed, RecordTypeId, Close_Reason__c, Problem_Type__c, Category__c, ContactId , Contact.Preferred_Language__c, 
    						Contact.Email, SurveyLinkEmailerSent__c, (Select Id, Case__C, Lastmodifieddate, Contact__c From Support_CSat_Survey_Feedbacks__r) 
    					From Case Where Id IN : setCaseIds]){

    		//Check the value  for fire the trigger
	 		if(cse.ContactId != null && cse.isClosed == true && cse.RecordTypeId == caseRecortypeId 
	 			&& Constants.SET_CASE_CLOSE_REASON.Contains(cse.Close_Reason__c) && (cse.isClosed != mapOldCases.get(cse.id).isClosed) 
	 			&& cse.Problem_Type__c != Constants.CASE_PROBLEM_TYPE_CONFIGURATION && cse.Category__c != Constants.CASE_CATEGORY_CONFIGURATION_OUTREACH){
	 			
	 			//Check the values
	 			if(mapToGetAuthConBooleanValue.containsKey(cse.ContactId)&& mapToGetAuthConBooleanValue.get(cse.ContactId) == true
	 				&& !String.valueOf(cse.OwnerId).StartsWithIgnoreCase(groupKeyPrefix) && mapComProflies.containsKey(cse.ContactId)
	 				&& (mapComProflies.get(cse.ContactId).CSatSurveyPreferences__c == null 
	 					|| mapComProflies.get(cse.ContactId).CSatSurveyPreferences__c == Constants.CASE_DEFAULT_ALWAYS) 
	 				&& setUserId.contains(cse.ContactId) && cse.Support_CSat_Survey_Feedbacks__r.size() > 0) {
	 				
	 				//Check for case's Contact Preferred_Language__c
	 				if(cse.Contact.Preferred_Language__c != null) {
	 					
	 					//Check value in map
	 					if(mapConLangAndCases.containsKey(cse.Contact.Preferred_Language__c)) {
	 						
	 						//Add new Case
	 						mapConLangAndCases.get(cse.Contact.Preferred_Language__c).add(cse);
	 					} else {
	 						
	 						//Populate map with value
	 						mapConLangAndCases.put(cse.Contact.Preferred_Language__c, new List<Case>{cse});
	 					}
	 				} else {
	 					
	 					//Check default language
	 					if(mapConLangAndCases.containsKey(Constants.CASE_DEFAULT_ENGLISH)) {
	 						
	 						//Add new case in map
	 						mapConLangAndCases.get(Constants.CASE_DEFAULT_ENGLISH).add(cse);
	 					} else {
	 						
	 						//Populate map with values
	 						mapConLangAndCases.put(Constants.CASE_DEFAULT_ENGLISH, new List<Case>{cse});
	 						
	 					} 
	 				}	
	 			}
	 		}
	 	}
	 	
	 	//Check for map size
	 	if(mapConLangAndCases.size() > 0 ) {
	 		
	 		//Call EmailHandler calss method to sent notification mail
	 		EmailHandler.sendEmail(mapConLangAndCases);
	 	}
	}
	/**
	 *	@Description	:	Method to sent Email notification about case absed on there Contact
	 *
	 *	@args			:	List<Case>, Map<Id, Case>
	 *
	 *	@return			:	void
	 **/
	 public static void validateCaseAndRelatdeMiletone(List<Case>  newCases ,Map<Id,Case> mapOldCases, Boolean isInsert){
	 	
	 	//Set to hold recordTypeId
	 	Set<Id> setRecordTypIds = new Set<Id>();
	 	
	 	//Set to hold Case contact Id
	 	Set<Id> setCaseConIds = new Set<Id>();
	 	
	 	//Set to hold Case Id
	 	Set<Id> setCaseIds = new Set<Id>();
	 	
	 	//Set to hold case priority and Support level 
	 	Set<String> setPriorities = new Set<String>();
	 	Set<String> setSupportLevels = new Set<String>();
	 	
	 	//String to hold Group keyPrifix
		String groupKeyPrefix = Group.SObjectType.getDescribe().getKeyPrefix();
		
		//Query through CaseADmin
	 	List<CaseAdmin__c> caseAdmins = [Select Name,CaseAdminId__c from CaseAdmin__c Where Name =: Constants.NAME_BILL LIMIT 1];
	 	
		
	 	//Query through RecordType
	 	for(RecordType recordType : [Select Id,DeveloperName From RecordType Where SobjectType='Case' And 
	 																			DeveloperName IN: Constants.SET_RECORDTYPE_DEVELOPER_NAME]){
	 		
	 		//Add the values in set
	 		setRecordTypIds.add(recordType.Id);																		
	 	}
	 	
	 	//Map to hold custom setting data
	 	Map<String, Case_Statuses__c> mapCaseStatus = Constants.MAP_CASE_STATUSES;
	 	
	 	//Set to hold Status values
	 	Set<String> setNonIgnoreCaseStatus = new Set<String>();
	 	Set<String> setIgnoreCaseStatus = new Set<String>();
	 	
	 	//Check for map
	 	if(mapCaseStatus != null && mapCaseStatus.size() > 0) {
	 		
	 		//Check for custom setting data and add in set by spliting ','
	 		if(mapCaseStatus.containsKey('Case Status') && mapCaseStatus.get('Case Status').Non_Ignore_Case_Status_Values__c != null)
	 			setNonIgnoreCaseStatus.addAll(mapCaseStatus.get('Case Status').Non_Ignore_Case_Status_Values__c.split(','));
	 		
	 		//Check for custom setting data and add in set by spliting ','
	 		if(mapCaseStatus.containsKey('Case Status') && mapCaseStatus.get('Case Status').Ignore_Case_Status_Values__c != null)
	 			setIgnoreCaseStatus.addAll(mapCaseStatus.get('Case Status').Ignore_Case_Status_Values__c.split(','));
	 	}
	 	
	 	//Loop through Case
	 	for(Case cse : newCases){
	 		
	 		//Check the condition to fire the trigger
	 		if(!setRecordTypIds.contains(cse.RecordTypeId)){
	 			
	 			//Add values in set
	 			setPriorities.add(cse.Priority);
	 			setSupportLevels.add(cse.Support_Level__c);
	 			
	 			//Check the conditon for supportLevel(field)
	 			if(isInsert && cse.Support_level__c != null){
	 				
	 				//Add the values in set
	 				setCaseConIds.add(cse.ContactId);
	 				setCaseIds.add(cse.Id);
	 			}
	 			
	 			//Check the values
	 			if(!isInsert && cse.Status != Constants.CASE_STATUS_CLOSED && cse.Status != mapOldCases.get(cse.Id).Status 
	 				&& !(String.valueOf(cse.OwnerId).StartsWithIgnoreCase(groupKeyPrefix))){
	 					
	 				//Add the values in set
	 				setCaseIds.add(cse.Id);
	 			}
	 		}
	 	}
	 	
	 	//Map to hold the ContactId of Authorize contsct as key correspoding to the BusinessHoursId
	 	Map<Id,Id> mapAuthConIdAdnBusinessId = new Map<Id,Id>();
	 	
	 	//Map to hold SLA Record corresponding to case Priority and Support Level
	 	Map<String, SLA__c> mapSLAs = Utility.mapGetSlaHours(setPriorities, setSupportLevels);
	 	
	 	//Loop through Authorized Contact
	 	for(Authorized_Contact__c authCon :[Select Entitlement__r.Type, Entitlement__c, Contact__r.Id, Entitlement__r.BusinessHoursId, Contact__c From 
	 														Authorized_Contact__c Where Contact__c IN :setCaseConIds
	 														AND Entitlement__c != null AND Entitlement__r.BusinessHoursId != null]){
	 		
	 		//assign the values  in map
	 		mapAuthConIdAdnBusinessId.put(authCon.Contact__r.Id,  authCon.Entitlement__r.BusinessHoursId);														
	   	}
	   	
	   	List<Case> cases = new List<Case>();
	   	List<Case_Update_Milestones__c> cUMilestones = new List<Case_Update_Milestones__c>(); 
	 
	 	//Loop through Case
	 	for(Case cse : [Select Id, OwnerId, ContactId, Status,RecordTypeId, Priority, Support_level__c, NextUpdateDueFrmCUM__c,
	 						EntitlementId, Entitlement.BusinessHoursId,createdDate, RecordType.DeveloperName, Origin,
	 						(Select CaseId,IsCompleted, TargetDate,StartDate From CaseMilestones Where IsCompleted = false LIMIT 1),
	 						(Select OwnerId,Case__c,Start_Date__c,Target_Date__c, Milestone_Type__c, Completed__c From Case_Milestones__r Where Completed__c = false LIMIT 1)
	 						From Case Where Id IN :setCaseIds]){	
	 		
	 		//Check the condition to fire the trigger
	 		if(!setRecordTypIds.contains(cse.RecordTypeId)){
	 			
	 			//Unique Key
	 			String uniqueKey = '';
	 			
	 			//Check for unique Key
	 			if(cse.Support_level__c != null && cse.Priority != null) {
	 				
	 				//Unique Key
	 				uniqueKey = cse.Priority + '-' + cse.Support_Level__c;
	 			}
	 		
	 			//Check the conditon for supportLevel(field)
	 			if(isInsert && cse.Support_level__c != null && cse.Priority != null){
	 				
	 				//Check for SLA First Response NOM 
	 				if(mapSLAs.containsKey(uniqueKey) && mapSLAs.get(uniqueKey).First_Response_NOM__c != null 
	 					&& mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue() > 0
	 					&& mapAuthConIdAdnBusinessId.containsKey(cse.ContactId)) {
	 					
	 					cse.NextUpdateDueFrmCUM__c = BusinessHours.addGmt(mapAuthConIdAdnBusinessId.get(cse.ContactId), cse.createdDate,
	 																		Integer.valueOf(mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue())*60000);
	 					
	 					//Add in list to update case
	 					cases.add(cse);
	 				}
	 				
	 				if(mapSLAs.containsKey(uniqueKey)) {
	 				
		 				//Instance of Case_Update_Milestones__c
		 				Case_Update_Milestones__c cUM = new Case_Update_Milestones__c();
		 				
		 				//Call utility class method to create new Case Update Milestones
		 				cUM = Utility.caseUpdateMilestone(cse, caseAdmins, mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue(), false);
		 				
		 				//Add in list
		 				cUMilestones.add(cUM);
	 				}
	 			}
	 			
	 			//Check the values
	 			if(!isInsert && cse.Status != Constants.CASE_STATUS_CLOSED && cse.Status != mapOldCases.get(cse.Id).Status){
	 					
	 				//Check for list size
	 				if(cse.Case_Milestones__r.size() > 0) {
	 						
	 					//Loop through Case_Milestones__c
	 					for(Case_Update_Milestones__c cUM : cse.Case_Milestones__r) {
	 							
	 						//Check for Owner on case
	 						if(cse.OwnerId != null && !(String.valueOf(cse.OwnerId).StartsWithIgnoreCase(groupKeyPrefix))) {
	 						
		 						//Check Case Update Milestone Owner and than update owner to case owner
		 						if(cUM.OwnerId != null && cUM.OwnerId != cse.OwnerId)
		 							cUM.OwnerId = cse.OwnerId;
		 							
	 						}
	 						
	 						//Check for Priority
 							if(((cse.Priority != null && mapOldCases.get(cse.Id).Priority != null && Integer.valueof(cse.Priority.substringAfter('P')) < Integer.valueof(mapOldCases.get(cse.Id).Priority.substringAfter('P'))) 
								|| (cse.Status != null && cse.Status != mapOldCases.get(cse.Id).Status)) && cse.OwnerId != null 
								&& mapOldCases.get(cse.Id).OwnerId != null && !(String.valueOf(cse.OwnerId).StartsWithIgnoreCase(groupKeyPrefix))
								&& !(String.valueOf(mapOldCases.get(cse.Id).OwnerId).StartsWithIgnoreCase(groupKeyPrefix))) {
	 								
		 						//Check for case status
		 						if(cse.Status != null && mapOldCases.get(cse.Id).Status != null && setNonIgnoreCaseStatus.contains(mapOldCases.get(cse.Id).Status)
		 							&& setIgnoreCaseStatus.contains(cse.Status)){
		 								
		 								//Check for MileStone
		 							if(cUM.Milestone_Type__c != null && cUM.Milestone_Type__c == 'Case Update') {
		 									
	 									cUM.Completion_Date__c = System.now();
	 									cUM.Completed__c = true;
	 									cUM.AutoComplete__c = true;
	 									cUM.Violation__c = false;
	 									cUM.update__c = true;
	 									
		 							} else if(cUM.Milestone_Type__c != null && cUM.Milestone_Type__c == 'First Response') {
		 									
	 									//Update
	 									cUM.update__c = true;
	 									
	 									//Check for SLA First Response NOM 
 										if(mapSLAs.containsKey(uniqueKey) && mapSLAs.get(uniqueKey).First_Response_NOM__c != null
 											&& mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue() > 0) {
	 											
 											cUM.Duration__c = String.valueOf(mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue()) + '';
 											
 											//Check for Priority substring after
 											if(Integer.valueof(cse.Priority.substringAfter('P')) != 1) {
 												cUM.Target_Date__c = BusinessHours.addGmt(cse.Entitlement.BusinessHoursId,
 																	 System.now(), Integer.valueOf(mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue())*60000);
 																	 
 											} else {
 												cUM.Target_Date__c = cUM.Start_Date__c.addMinutes(Integer.valueOf(mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue()));
 											}
 										}
		 									
		 							} 
		 						}else if((cse.Status != null && mapOldCases.get(cse.Id).Status != null && setIgnoreCaseStatus.contains(mapOldCases.get(cse.Id).Status)
		 								&& setNonIgnoreCaseStatus.contains(cse.Status))
		 								||
		 								((cse.Priority != null && mapOldCases.get(cse.Id).Priority != null && Integer.valueof(cse.Priority.substringAfter('P')) < Integer.valueof(mapOldCases.get(cse.Id).Priority.substringAfter('P')))
		 									&& !setIgnoreCaseStatus.contains(cse.Status) && cUM.Milestone_Type__c != 'First Response')) {
		 							
		 							//Integer variable
		 							Integer numOfMinutes;
		 							
		 							//Check for Priority
		 							if(cse.Priority != null && mapOldCases.get(cse.Id).Priority != null && Integer.valueof(cse.Priority.substringAfter('P')) != Integer.valueof(mapOldCases.get(cse.Id).Priority.substringAfter('P'))
		 								&& uniqueKey != '' && mapSLAs.containsKey(uniqueKey) && mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue() > 0){
		 								//Add values in Integer
		 								numOfMinutes = Integer.valueOf(mapSLAs.get(uniqueKey).First_Response_NOM__c.intValue());
		 							
		 							} else if(cse.Status != null && cse.Status != mapOldCases.get(cse.Id).Status && uniqueKey != '' && mapSLAs.containsKey(uniqueKey) && mapSLAs.get(uniqueKey).Case_Update_Milestone_NOM__c.intValue() > 0) {
		 								//Add Value in Integer
		 								numOfMinutes = Integer.valueOf(mapSLAs.get(uniqueKey).Case_Update_Milestone_NOM__c.intValue());
		 							}
		 							
		 							//Instanceo of Case_Update_Milestones__c
		 							Case_Update_Milestones__c caseUM = new Case_Update_Milestones__c();
		 							
		 							//Call Utility class method
		 							caseUM = Utility.caseUpdateMilestone(cse, null, numOfMinutes, true);
		 							
		 							//Add in List
		 							cUMilestones.add(caseUM);
		 							
		 							//Update case
		 							cse.NextUpdateDueFrmCUM__c = caseUM.Target_Date__c;
		 							
		 							//Add in list
		 							cases.add(cse);
		 						}
		 					}
		 					
		 					//Add in list
		 					cUMilestones.add(cUM);
	 					}
	 				}
				} 
	 		}
		}
		
		//Check for list size
		if(cases.size() > 0)
			update cases;
		
		//Check for List 
		if(cUMilestones.size() > 0)
			upsert cUMilestones;
	}
}