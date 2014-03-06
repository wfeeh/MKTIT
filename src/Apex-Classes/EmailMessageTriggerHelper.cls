/**
 *  Description    :   Helper class for Trigger_EmailMessage trigger.
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

public without sharing class EmailMessageTriggerHelper {
	
	//Boolean variable for account trigger execution
    public static Boolean Execute_Entitlement_Trigger = true;
    
    /**
     *
     *	@description	:	Method to create new Case record according to EmailMessage toAddress and Parent Case record Type
     *
     *	@args			:	List<EmailMessage>
     *
     *	@return			:	void
     *
     **/
	public static void createCase(List<EmailMessage> newEmailMessages) {
		
		//Set to hold Case Id
		Set<Id> setCaseIds = new Set<Id>();
		
		//Loop through EmailMessage
		for(EmailMessage eM : newEmailMessages) {
			
			//Check for ParentId and also check email related to case only
			if(eM.ParentId != null && eM.ParentId.getSobjectType() == Case.SObjectType && eM.Subject != null 
				&& eM.Subject.containsIgnoreCase(Constants.EmailMessage_SUBJECT_CASE)) {
				
				//Add case Id(ParentId) in Set
				setCaseIds.add(eM.ParentId);
			}
		}
		
		//List of recordType
		List<RecordType> rTypes = [Select Id, Name, DeveloperName, SObjectType From RecordType Where SobjectType = 'Case'
									AND (DeveloperName =: Constants.CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT
										OR DeveloperName =: Constants.CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT_FEEDBACK) LIMIT 2];
		
		//Map of cases
		Map<Id, Case> mapCases = new Map<Id, Case>([Select Id, AccountId, ContactId, RecordTypeId, RecordType.DeveloperName From Case Where Id IN : setCaseIds]);
		
		//Map to hold Queue Name as Key and Queue As value
		Map<String, Id> mapQueueNameAndId = new Map<String, Id>();
		
		//Loop through 
		for(QueueSobject qS : [Select Id, QueueId, Queue.Name From QueueSobject Where Queue.Name IN : Constants.SET_QUEUESOBJECT_NAME]) {
			
			//Check for Queue Name
			if(qS.QueueId != null && qS.Queue.Name != null && qS.Queue.Name == Constants.QUEUE_NAME_SUPPORT_FEEDBACK_QUEUE) {
				
				//Populate map
				mapQueueNameAndId.put(Constants.QUEUE_NAME_SUPPORT_FEEDBACK_QUEUE,qS.QueueId);
			} else if(qS.QueueId != null && qS.Queue.Name != null && qS.Queue.Name == Constants.QUEUE_NAME_SUPPORT_ESCALATIONS_QUEUE) {
				
				//Populate map
				mapQueueNameAndId.put(Constants.QUEUE_NAME_SUPPORT_ESCALATIONS_QUEUE,qS.QueueId);
			}
		}
		
		//List of case records
		List<Case> cases = new List<Case>();
		
		//Loop through EmailMessage
		for(EmailMessage eM : newEmailMessages) {
			
			System.assertEquals(Label.EMAILMESSAGE_ESCALATION_TOADDRESS, eM.ToAddress);
			
			//Check for ParentId and also check email related to case only
			if(eM.ParentId != null && eM.ParentId.getSobjectType() == Case.SObjectType && eM.Subject != null 
				&& eM.Subject.containsIgnoreCase(Constants.EmailMessage_SUBJECT_CASE) && mapCases.containsKey(eM.ParentId)) {
				
				//Check for Parent Id
				if(eM.ToAddress != null && eM.ToAddress == Label.EMAILMESSAGE_ESCALATION_TOADDRESS && mapCases.get(eM.ParentId).RecordTypeId != null 
					&& mapCases.get(eM.ParentId).RecordType.DeveloperName != Constants.CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT) {
						
					//Instance of Case 
					Case cse = new Case();
						
					//Call utility class method
					cse = Utility.populateFieldValues(eM, cse, mapCases);
						
					//Check for Owner Id
					if(mapQueueNameAndId.containsKey(Constants.QUEUE_NAME_SUPPORT_ESCALATIONS_QUEUE))
						cse.OwnerId = mapQueueNameAndId.get(Constants.QUEUE_NAME_SUPPORT_ESCALATIONS_QUEUE);
						System.debug('##### : ' + rTypes);
					//Check for Developer Name
					if(rTypes.size() == 2) {
						
						cse.RecordTypeId = rTypes[0].DeveloperName == Constants.CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT ?
										   rTypes[0].Id : rTypes[1].Id;						  
					}
					
					//Add in list
					cases.add(cse);
					
				} else if(eM.ToAddress != null && eM.ToAddress == Label.EMAILMESSAGE_FEEDBACK_TOADDRESS && mapCases.get(eM.ParentId).RecordTypeId != null 
					&& mapCases.get(eM.ParentId).RecordType.DeveloperName != Constants.CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT_FEEDBACK) {
						
					//Instance of Case 
					Case cse = new Case();
						
					//Call utility class method
					cse = Utility.populateFieldValues(eM, cse, mapCases);
						
					//Check for Owner Id
					if(mapQueueNameAndId.containsKey(Constants.QUEUE_NAME_SUPPORT_FEEDBACK_QUEUE))
						cse.OwnerId = mapQueueNameAndId.get(Constants.QUEUE_NAME_SUPPORT_FEEDBACK_QUEUE);
						
					//Check for Developer Name
					if(rTypes.size() == 2) {
						
						cse.RecordTypeId = rTypes[0].DeveloperName == Constants.CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT ?
										   rTypes[1].Id : rTypes[0].Id;						  
					}
					
					//Add in list
					cases.add(cse);
				}
			}
		}
		System.debug('########### : ' +cases);
		//Check for list size
		if(cases.size() > 0)
			insert cases;
	}
	
    /**
     *	@description	:	Method to create CaseComment Record account to EmailMessage's Case 
     *
     *	@args			:	List<EmailMessage>
     *
     *`	@return			:	void
     *
     **/
	public static void createCaseComment(List<EmailMessage> newEmailMessages) {
		
		//Set to hold case Ids
		Set<Id> setCaseIds = new Set<Id>();
		
		//Loop through EmailMessage
		for(EmailMessage eM : newEmailMessages) {
			
			//Check appropriate condition to fire trigger
			if(eM.ParentId != null && eM.ParentId.getSobjectType() == Case.SObjectType && (eM.Incoming == false 
				|| (eM.Subject != null && eM.Subject.containsIgnoreCase(Constants.EMAILMESSAGE_SUBJECT_REF)))) {
				
				//Add Parent Id in set
				setCaseIds.add(eM.ParentId);
			}
		}
		
		//Map to hold cases
		Map<Id, Case> mapCases = new Map<Id, Case>([Select Id, RecordTypeId, RecordType.DeveloperName From Case Where Id IN : setCaseIds]);
		
		//List of CaseComment
		List<CaseComment> caseComments = new List<CaseComment>();
		 
		//Loop through EmailMessage
		for(EmailMessage eM : newEmailMessages) {
			
			//Check appropriate condition to fire trigger
			if(eM.ParentId != null && eM.ParentId.getSobjectType() == Case.SObjectType && (eM.Incoming == false 
				|| (eM.Subject != null && eM.Subject.containsIgnoreCase(Constants.EMAILMESSAGE_SUBJECT_REF)))) {
				
				//Instance of caseComment
				CaseComment cC = new CaseComment();
				
				cC.ParentId = eM.ParentId;
				
				cC.CommentBody = formatTextBody(eM, mapCases);
				
				//Check for Record Type
				if(mapCases.containsKey(eM.ParentId) && mapCases.get(eM.ParentId).RecordType.DeveloperName != Constants.CASE_RECORDTYPE_DEVELPOER_NAME_SUPPORT_CASES
					&& em.Incoming == true) {
					
					cC.IsPublished = false;		
				} else
					cC.IsPublished = true;
				
				//Add CaseComment in list
				caseComments.add(cC);
			}
		}
	
		//Check for map size
		if(mapCases.size() > 0) {
			
			//Loop through map
			for(Case cse : mapCases.values()) {
				
				//Set Prevent_Comment_Notifications__c to true to stop email notification
				cse.Prevent_Comment_Notifications__c = true;
			}
			
			//Set flag tofalse to stop case trigger execution
			CaseTriggerHelper.Execute_Case_Trigger = false;
			
			//Update map 
			update mapCases.values();
		}
		
		//Check for CaseComment
		if(caseComments.size() > 0)
			insert caseComments;
		
		//Check for map size
		if(mapCases.size() > 0) {
			
			//Loop through map
			for(Case cse : mapCases.values()) {
				
				//Set Prevent_Comment_Notifications__c to false
				cse.Prevent_Comment_Notifications__c = false;
			}
			
			//Set flag tofalse to stop case trigger execution
			CaseTriggerHelper.Execute_Case_Trigger = false;
			
			//Update map 
			update mapCases.values();
		}
	}
	
	/**
	 *	@description	:	Method to format Text Body of EmailMessage
	 *
	 *	@args			:	EmailMessage, Map<Id, Case>
	 *
	 *	@return			:	String
	 *
	 **/
	public static String formatTextBody(EmailMessage eM, Map<Id, Case> mapCases) {
		
		//String to bind in case Commnet
		String commentBody = '';
			
		//Check for Casse Record Type Name
		if(eM.TextBody != null && eM.TextBody != '') {
		
			//Assign Text body
			commentBody = eM.TextBody.replaceAll('(<br>)\\1+','<br>');
		
			//Check for Record Type
			if(mapCases.containsKey(eM.ParentId) && mapCases.get(eM.ParentId).RecordType.DeveloperName == Constants.CASE_RECORDTYPE_DEVELPOER_NAME_SUPPORT_CASES
				&& em.Incoming == true) {
		
				if(commentBody.indexOfIgnoreCase(Constants.EMAILMESSAGE_COMMENT_BODY_MARKETO_CUSTOMER_SUPPORT) > 0)
					commentBody = commentBody.substring(0,commentBody.indexOfIgnoreCase(Constants.EMAILMESSAGE_COMMENT_BODY_MARKETO_CUSTOMER_SUPPORT));
			
				if(commentBody.lastindexOfIgnoreCase(Constants.EMAILMESSAGE_COMMENT_BODY_CONTAINS_ON) > 0)
					commentBody = commentBody.substring(0,commentBody.lastindexOfIgnoreCase(Constants.EMAILMESSAGE_COMMENT_BODY_CONTAINS_ON));
			
			
				//Add To Address and From Address in comment body
				if(eM.ToAddress != null && eM.FromAddress != null)
					commentBody = ' To: ' + eM.ToAddress + '\r\n' + ' From: ' + eM.FromAddress + '\r\n \r\n' + commentBody;
			}
	
			//Check comment body length
			if(commentBody.length() > 3970) {
		
				commentBody = commentBody.subString(0, 3970);
				commentBody += '\r\n<EMAIL TRUNCATED>';
			}	
		}
		
		//Return
		return commentBody;
	}	  
}