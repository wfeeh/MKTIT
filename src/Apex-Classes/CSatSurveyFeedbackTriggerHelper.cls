/**
 *  Description     :   Helper class for Trigger_CSatSurveyFeedback trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/15/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public with sharing class CSatSurveyFeedbackTriggerHelper {
	
	//Boolean variable for CSatSurveyFeedback trigger execution
    public static Boolean execute_CSatSurveyFeedback_Trigger = true;
    
    
	/**
     * @Description  :  1. This method is used is to upadte the Owner Id of CSatSurveyFeedback with Case OwnerId .
     *					2. This method also Populate the values in Case after appropriate condition.
     *
     * @args         :  List<CSatSurveyFeedback__c>
     *
     * @return       :  void
     *
     **/
     public static void validateCase(List<CSatSurveyFeedback__c> newCSatFBacks){
     	
     	//Set to hold the case(field)Id
     	Set<Id> cSFBCaseIds = new Set<Id>();
     	
     	//Set to hold the CSatSurveyFeedback
     	Set<Id> cSatIds = new Set<Id>();
     	
     	//String to hold Group keyPrifix
		String groupKeyPrefix = Group.SObjectType.getDescribe().getKeyPrefix();
        
        //Query through record Type
        List<RecordType> recordTypeIDs = [Select Id, DeveloperName From RecordType Where SobjectType =: Constants.CSATSURVEY_SOBJECT 
        															AND DeveloperName =: Constants.CSATSURVEY_DEVELOPERNAME LIMIT 1 ]; 
       
       //Loop through CSatSurveyFeedback
       for(CSatSurveyFeedback__c cSSFB : newCSatFBacks){
       		
       		//Check the appropriate condition to fire the trigger
       		if(cSSFB.Case__c != null){
       			
       			//Add the value in set
       			cSFBCaseIds.add(cSSFB.Case__c);
       			cSatIds.add(cSSFB.Id);
       		}
       }
       //Set to hold tha case ownerId
       Set<Id> setCseOwnerId = new Set<Id>();
       
       //Loop through Case
       for(Case cse : [Select Id, ParentID, CaseNumber, OwnerId from Case Where Id IN : cSFBCaseIds]){
       		
       		//Check the value Ower Id value starts with particluar prefix
       		if(!String.valueOf(cse.OwnerId).StartsWithIgnoreCase(groupKeyPrefix)){
       			
       			//Add the value in set
       			setCseOwnerId.add(Cse.OwnerId);
       		}
       }
       
       //Map to hold the Id as key corresponding to the User
       Map<Id, User> mapIdAndUsers = new Map<Id,User>([Select Id, ManagerId from User Where Id IN : setCseOwnerId AND ManagerId != null And isActive = true]);
       
       //List  to insert the Case
       List<Case> cseToAdd = new List<Case>();
       
       //List to update the ownerId ofCSatSurveyFeedback
       List<CSatSurveyFeedback__c> cSatSurveysFeedBcks = new List<CSatSurveyFeedback__c>();
       
       //Loop through CSatSurveyFeedback
       for(CSatSurveyFeedback__c cSF : [Select Id, Case__c,Account__c, Contact__c, Case__r.CaseNumber, OwnerId, Question_1__c,Question_7__c,
       										Case__r.OwnerId From CSatSurveyFeedback__c Where Id IN : cSatIds AND Case__c != null]){
       													
       		//Check the condition for ownerId 										
       		if(cSF.Case__r.OwnerId != null && !String.valueOf(cSF.Case__r.OwnerId).StartsWithIgnoreCase(groupKeyPrefix) ){
       			
       			//Populate the value
       			cSF.OwnerId = cSF.Case__r.OwnerId;
       			
       			//Add the value in List
       			cSatSurveysFeedBcks.add(csf);
       		}
       		
       		//Check the appropraite condition to fire Trigger
       		if((cSF.Question_1__c == '1'  || cSF.Question_1__c == '2') && cSF.Case__c != null && mapIdAndUsers.containsKey(cSF.Case__r.OwnerId) )	{
       			
       			//Instance of casee
       			Case cse = new Case();
       			
       			//Populate the values in case
       			if(cSF.Account__c != null)
       				cse.Situation_Account__c = cSF.Account__c;
       			
       			if(cSF.Contact__c != null)
       				cse.Situation_Contact__c = cSF.Contact__c;
       			
       			if(cSF.Case__r.CaseNumber != null)
       			cse.Subject = Constants.CSATSURVEY_SUBJECT_STRING + cSF.Case__r.CaseNumber;
       			
       			if(cSF.Question_7__c != null)
       				cse.Description =  cSF.Question_7__c;
       			
       			cse.Problem_Type__c = Constants.CSATSURVEY_TYPE_SURVEY_FOLLOW_UP;
       			
       			if(cSF.Case__c != null)
       				cse.ParentId = cSF.Case__c;
       			
       			if(mapIdAndUsers.get(cSF.Case__r.OwnerId).ManagerId != null)
       				cse.OwnerId = mapIdAndUsers.get(cSF.Case__r.OwnerId).ManagerId;
       			
       			//Check the size of RecordType List size
       			if(recordTypeIDs.size() > 0){
       				
       				//Populate the value
       				cse.RecordTypeId = recordTypeIDs[0].Id;
       			}
       			
       			//Add the values in List
       			cseToAdd.add(cse);
			}
		}
       
       //Check the size of List
       if(cseToAdd.size()>0)
       	insert cseToAdd;
       	
       	//Check the size of list
       	if(cSatSurveysFeedBcks.size() > 0)
       		update cSatSurveysFeedBcks; 
	}
	
	 
	/**
     * @Description  :  This method is used to insert the JBCXM Milestone record on finding appropriate condition of CCSatSurveyFeedback.
     *
     * @args         :  List<CSatSurveyFeedback__c>
     *
     * @return       :  void
     *
     **/
     public static void validateCSFJBCXMilestone(List<CSatSurveyFeedback__c> newCSatFB){
     	
     	//Set to hold the CSatSurveyFeedback ID
     	Set<Id> setCSatIds = new Set<Id>();
     	
     	//Set to hold the Account Id of CCSatSurveyFeedback
     	Set<Id> setCSatAccId = new Set<Id>();
     	
     	//Loop through CSatSurveyFeedback
     	for(CSatSurveyFeedback__c cSF : newCSatFB){
     		
     		//Check the appropriate conditios to fire trigger
     		if(cSF.Account__c != null){
     			
     			//Add the values in set
     			setCSatIds.add(cSF.Id);
				setCSatAccId.add(cSF.Account__c);
     		}
     	}
     	
     	//Map to hold account Id as key and JBCXM__CustomerInfo__c as value
		Map<Id, JBCXM__CustomerInfo__c> mapAccIdAndJBCXMCInfo = new Map<Id, JBCXM__CustomerInfo__c>();
		
		//Loop through JBCXM__CustomerInfo__c
		for(JBCXM__CustomerInfo__c jCI : [Select Id,JBCXM__Account__c From JBCXM__CustomerInfo__c Where JBCXM__Account__c IN : setCSatAccId]) {
			
			//Populate map with values
			mapAccIdAndJBCXMCInfo.put(jCI.JBCXM__Account__c, jCI);
		}
		
		//Query through JBCXM__PickList__c
		List<JBCXM__PickList__c> jBCXMs = [SELECT Id, JBCXM__SystemName__c, JBCXM__Category__c FROM JBCXM__PickList__c 
																		WHERE JBCXM__Category__c =: Constants.CONTACT_JBCXM_CATEGORY_MILESTONE
																		AND JBCXM__SystemName__c =:Constants.CSATSURVEY_JBCXM_SYSTEMNAME_CSAT LIMIT 1];
		
		//List of JBCXM__Milestone__c
		List<JBCXM__Milestone__c> jBCXMMilestones = new List<JBCXM__Milestone__c>();
		
		//Loop through CSatSurveyFeedback
		for(CSatSurveyFeedback__c cSF : [Select Id, Case__c, Contact__c, Account__c, Case__r.ClosedDate, Contact__r.Name  
														From CSatSurveyFeedback__c Where Id IN : setCSatIds AND
														Contact__c != null AND Account__c != null AND Case__c != null]){
			
			//Check the value of Account in map
			if(mapAccIdAndJBCXMCInfo.containsKey(cSF.Account__c) && jBCXMs.size() > 0){
				
				//Insatance of JBCXM Milestone
				JBCXM__Milestone__c jBCXM   = new JBCXM__Milestone__c();
				
				//Popuulate the values
				if(cSF.Account__c != null)
					jBCXM.JBCXM__Account__c = cSF.Account__c;
					
				jBCXM.JBCXM__Milestone__c = jBCXMs[0].Id;
				
				//Check the value of case's close date(field) value and populate the value
				if(cSF.Case__r.ClosedDate != null)
					jBCXM.JBCXM__Date__c = cSF.Case__r.ClosedDate.Date();
				else
					jBCXM.JBCXM__Date__c =  System.today();
				
				//Check the value of contact name value and populate the value
				if(cSF.Contact__r.Name != null)
					jBCXM.JBCXM__Comment__c = cSF.Contact__r.Name;
				else
					jBCXM.JBCXM__Comment__c = null;
 				
 				
 				//Add the value in List
 				jBCXMMilestones.add(jBCXM);
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
														  + 'while running the Trigger to create a Milestone for CSAT Survey';
				errorLog.JBCXM__LogDateTime__c = datetime.now();
				errorLog.JBCXM__SourceData__c = e.getMessage();
				errorLog.JBCXM__SourceObject__c = 'Case';
				errorLog.JBCXM__Type__c = 'Trigger_CSatSurveyFeedback';
				
				//insert error
				insert errorLog;
			}
		} 
	}
}