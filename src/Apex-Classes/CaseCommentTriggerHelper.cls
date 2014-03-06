/**
 *  Description    :   Helper class for Trigger_CaseComment trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/8/2014
 *
 *  Version      	:  	V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class CaseCommentTriggerHelper {
	
	//Boolean variable to Case Comment trigger execution
	public static Boolean Execute_Case_Trigger = true;
	
	/**
	 *	@Description	:	Method to validate CompletionDate of CaseMileStone 
	 *
	 *	@args			:	List<CaseComment>
	 *
	 *	@return			:	void
	 **/
	 public static void validateCMCompletionDate(List<CaseComment> newCaseComments){
	 	
	 	//Set to hold Custom settings
	 	Set<String> setConfig  = new Set<String>();
	 	
	 	//Set t hold CaseComment Created userId
	 	Set<Id> setCrtdById = new Set<Id>();
	 	
	 	//Set to hold the ParentId of CaseComment
	 	Set<Id> setCCParentId = new Set<Id>();
	 	
	 	//List to update the CaseComment
	 	List<CaseMilestone> caseMilesStones = new  List<CaseMilestone>();
	 	
	 	//Loop througgh custom setting
	 	for(Configuration_Manager__c configM : Constants.getConfigManagerByParameterKey
	 												(Constants.CONFIG_MANAGER_PARAMETER_KEY_IGNORENONPORTALADMINFROMCOMPLETEMILESTOTE)){
	 		//Check the values in  custom setting
	 		if(configM.Parameter_Value__c != null && configM.Parameter_Value__c != ''){
	 			
	 			//Add the values in set
	 			setConfig.add(configM.Parameter_Value__c);
	 			
	 		}
	 	}
	 	
	 	//Loop through CaseComment
	 	for(CaseComment cseCmt : newCaseComments){
	 		
	 		//Addd the value in set
	 		setCrtdById.add(cseCmt.CreatedById);
	 	}
	 	
	 	//Map tp hold the user Id  as key Correspnding to the user
	 	Map<Id,User> mapUser = new Map<Id,User>([Select Id,  IsPortalEnabled, ContactId From User Where IsPortalEnabled = false AND ID IN : setCrtdById]);
	 	
	 	//Loop through CaseComment
	 	for(CaseComment cCmnt : newCaseComments){
	 		
	 		//Check the appropriate conditin too fire the trigger
	 		if(cCmnt.IsPublished && (mapUser.containsKey(cCmnt.CreatedById)) && !setConfig.contains(cCmnt.CreatedById)){
	 			
	 			//Add the value in set
	 			setCCParentId.add(cCmnt.ParentId);
	 			
	 		}
	 	}
	 	
	 	//Loop through CustomMilestone
	 	for(CaseMilestone cM : [Select Id, CompletionDate  from CaseMilestone Where 
	 										MilestoneType.Name =: Constants.CASE_MILESTONENAME_FIRST_RESPONSE AND CaseId IN : setCCParentId AND CompletionDate = null ]){
	 		
	 		//populate the value
	 		cM.CompletionDate = System.now();
	 		
	 		//add the values in  list
	 		caseMilesStones.add(cM);
	 		
	 	}
	 	
	 	//Check the size of list
	 	if(caseMilesStones.size() > 0)
	 		update caseMilesStones;
	}
	/**
	 *	@Description	:	Method to validate CompletionDate of CaseMileStone 
	 *
	 *	@args			:	List<CaseComment>
	 *
	 *	@return			:	void
	 **/
	 public static void validateCaseUpdateMileStone(List<CaseComment> newCaseComments){
	 	
	 	//Set to hold the CaseComment ParentId
	 	Set<Id> cCParentIds = new Set<Id>();
	 	
	 	//Set to hold createById of CaseComment
	 	Set<Id> cCCreatedById = new Set<Id>();
	 	
	 	//Map to get CustomMilestoneSettings__c(custom setting) Data
		Map<String, CustomMilestoneSettings__c> mapCustomMilestoneSettings = Constants.CUSTOMMILESTONESETTING_CUSTOM_SETTING;
		
		//Check for CustomMilestoneSettings__c data
		if(mapCustomMilestoneSettings.size() == 0 || mapCustomMilestoneSettings.get('Custom Milestone').Custom_Milestone_Active__c != true)
			return;
		
		//Map to hold custom setting data
	 	Map<String, Case_Statuses__c> mapCaseStatus = Constants.MAP_CASE_STATUSES;
	 	
	 	//Set to hold Status values
	 	Set<String> setNonIgnoreCaseStatus = new Set<String>();
	 	Set<String> setIgnoreCaseStatus = new Set<String>();
	 	
	 	//Check for map
	 	if(mapCaseStatus != null && mapCaseStatus.size() > 0) {
	 	
	 		//Check for custom setting data and add in set by spliting ','
	 		if(mapCaseStatus.containsKey('Case Status') && mapCaseStatus.get('Case Status').Ignore_Case_Status_Values__c != null)
	 			setIgnoreCaseStatus.addAll(mapCaseStatus.get('Case Status').Ignore_Case_Status_Values__c.split(','));
	 	}
	 	
		//Loop through CaseComment
		for(CaseComment cCmnt : newCaseComments){
			
			//Add the values in set
			cCParentIds.add(cCmnt.ParentId);
			cCCreatedById.add(cCmnt.CreatedById);
		}
		
		//Map to hold the Id of user corresponding to the User
		Map<Id,User> mapUser = new Map<Id,User>([Select Id, IsPortalEnabled From User Where Id IN : cCCreatedById]);
		
		//Map to hold the Id of case as Key corresponding to the case values
		Map<Id,Case>  mapCases = new Map<Id,Case>();
		
		//Set to hold the case priority
		Set<string> setPriorities = new Set<String>();
		
		//Set  to hold the case support level
		Set<String> setSupportLevels = new Set<String>();
		
		//Loop through case
		for(Case cse : [Select Id, Priority, Support_Level__c, IsClosed, ownerid, NextUpdateDueFrmCUM__c, Status, Entitlement.BusinessHoursId 
						From Case Where Id IN :cCParentIds]) {
		
			//Populate map with values
			mapCases.put(cse.Id, cse);
			
			// check the value of priority and add the values in set
			if(cse.Priority != null && cse.Priority != '')
				setPriorities.add(cse.Priority);
			
			//check the value of Suppor level and add the values in set
			if(cse.Support_Level__c != null)
				setSupportLevels.add(cse.Support_Level__c);					
		}
		
		//Map to hold SLA Record corresponding to case Priority and Support Level
	 	Map<String, SLA__c> mapSLAs = Utility.mapGetSlaHours(setPriorities, setSupportLevels);
	 
		//Set to hold the CaseAdmin(field)
		Set<String> setCaseAdmin = new Set<String>();
		
		//Loop through CaseAdmin(Custom setting)
		for(CaseAdmin__c cseAdmin : [Select CaseAdminId__c from CaseAdmin__c Where CaseAdminId__c != null]){
			
			//Add the value in set
        	setCaseAdmin.add(cseAdmin.CaseAdminId__c);
        }
        
        //Map to hold the caseUpdateMilstone Id as Key corresponding to the List of caseUpdateMilestone
		Map<Id,List<Case_Update_Milestones__c>> mapCseUpdateMilestone = new Map<Id,List<Case_Update_Milestones__c>>();
		
		//Loop through caseUpdateMilestone
        for (Case_Update_Milestones__c csemilestone : [Select Id, Case__c,Target_Date__c, Case__r.Priority, Case__r.Support_Level__c 
        												From Case_Update_Milestones__c Where Case__c IN : cCParentIds AND Completed__c = false]) {
			
			//Check the values in map		     								        	
       		if (mapCseUpdateMilestone.containsKey(csemilestone.Case__c)) {
       			
       			//Add new caseUpdateMikeStone
            	mapCseUpdateMilestone.get(csemilestone.Case__c).add(csemilestone);
            } else {
            	
            	//Populate values in map
                mapCseUpdateMilestone.put(csemilestone.Case__c, new List<Case_Update_Milestones__c>{csemilestone});
            }        
        }
		//List to update the caseUpdateMilestone
		List<Case_Update_Milestones__c> caseUpdateMileStones = new List<Case_Update_Milestones__c>();
		
		//List to upadet case
		List<Case> cases = new List<Case>();
		
		//Loop through CaseComment
		for(CaseComment cCmnt : newCaseComments){
			
			//Check the appropraiate conditions to fire trigger
			if(cCmnt.ParentId != null && mapCases.containsKey(cCmnt.ParentId) && mapCases.get(cCmnt.ParentId).Support_Level__c != null
				 && cCmnt.IsPublished == true && !(mapCases.get(cCmnt.ParentId).IsClosed )){
				
				//Check the values in map
				if(mapCseUpdateMilestone.containsKey(cCmnt.ParentId)){
					
					//Loop through cseUpdateMilestone
					for(Case_Update_Milestones__c cseUpdtM :mapCseUpdateMilestone.get(cCmnt.ParentId)){
						
						//Populate the values
						cseUpdtM.Completion_Date__c = System.now();
                        cseUpdtM.Completed__c = true;
                        cseUpdtM.Violation__c = cseUpdtM.Completion_Date__c > cseUpdtM.Target_Date__c ? true : false;
                        cseUpdtM.AutoComplete__c = false;
                        cseUpdtM.update__c = true;
                        
                        //Add the vaules in list
                        caseUpdateMileStones.add(cseUpdtM);
					}
				} else if(!setIgnoreCaseStatus.contains(mapCases.get(cCmnt.ParentId).Status) && mapCases.get(cCmnt.ParentId).Priority != null){
					
					//Make unique key by combining Case's Priority and support level
					String uniqueKey = mapCases.get(cCmnt.ParentId).Priority + '-' + mapCases.get(cCmnt.ParentId).Support_Level__c;
					  
					//Instance of customUpdateMilestone
					Case_Update_Milestones__c cUM    = new Case_Update_Milestones__c();
					
					//Populate the values
                    cUM.Case__c = cCmnt.parentid;
                    cUM.Milestone_Type__c = 'Case Update';
                    cUM.OwnerId = mapCases.get(cCmnt.parentId).OwnerId;
                    cUM.Start_Date__c = System.now();
                    
                    //Check for map
                    if(mapSLAs.containsKey(uniqueKey) && mapSLAs.get(uniqueKey).Case_Update_Milestone_NOM__c != null 
                    	&& mapSLAs.get(uniqueKey).Case_Update_Milestone_NOM__c.intValue() > 0) {
                    	
                    	Integer numOfMinutes = mapSLAs.get(uniqueKey).Case_Update_Milestone_NOM__c.intValue();
                    	
					    cUM.Target_Date__c = numOfMinutes!= null && mapCases.get(cCmnt.parentId).Priority != 'P1'?
					    					 BusinessHours.addGmt(mapCases.get(cCmnt.parentId).Entitlement.BusinessHoursId, System.now(),
					    					 numOfMinutes*60000):System.Now().addMinutes(numOfMinutes); 
					    
                         cUM.Duration__c = numOfMinutes != null ? numOfMinutes + '': null;

                    }
                    
                    //populate the value in case by case commment field
                    mapCases.get(cCmnt.parentId).NextUpdateDueFrmCUM__c = cUM.Target_Date__c;
                   
                   //add the value in list
                   cases.add(mapCases.values());
                   
                   //Add the vaules in list
                   caseUpdateMileStones.add(cUM);
                    
				}
			}
		}
		
		//Check the size of list
		if(caseUpdateMileStones.size() > 0)
			upsert caseUpdateMileStones;
			
		//Check the size of list
		if(cases.size() > 0)
			update cases;
	}
	/**
	 *	@Description	:	Method to validate error messages
	 *
	 *	@args			:	List<CaseComment>
	 *
	 *	@return			:	void
	 **/
	 public static void validateErrorMessage(List <CaseComment> newCaseComments){
	 	
	 	//Set to hold the CaseAdmin (field)
    	Set<String> setCaseAdminIds = new Set<String>();
    	
    	//Set to hold CaseComment createdById
    	Set<Id> setCseCmntCreatedByIds = new Set<Id>();
    	Set<Id> setCseCmntParentIds = new Set<Id>();
    	
    	
    	//Loop through CaseAdmin
    	for(CaseAdmin__c cseAdmin : [Select Id, CaseAdminId__c from CaseAdmin__c  Where CaseAdminId__c != null]){
    		
    		//Add the values in set
    		setCaseAdminIds.add(cseAdmin.CaseAdminId__c);
		}
		
		//Loop through CaseComment
		for(CaseComment cCmnt : newCaseComments){
			
			//Check the apporpriate condition to fire trigger
			if(cCmnt.isPublished == true && !setCaseAdminIds.contains(cCmnt.createdById)){
				
				//Add the values in set
				setCseCmntCreatedByIds.add(cCmnt.CreatedById);        
            	setCseCmntParentIds.add(cCmnt.ParentId); 
			}
		}
		
		//String to hold Group keyPrifix
		String groupKeyPrefix = Group.SObjectType.getDescribe().getKeyPrefix();
		
		//Map to hold the case Id as key corresponding to the Case 
		Map<Id,Case> mapCases = new Map<Id,Case>([Select ID, OwnerId, Status, Problem_Type__c, RecordTypeId From Case Where Id IN : setCseCmntParentIds]);
		
		//Map tp hold the Id of user as key cooresponding to the user
		MAP<Id,User> mapUsers = new Map<Id,User>([Select Id, IsPortalEnabled, ContactId From User Where IsPortalEnabled = false
		 											      AND Id IN : setCseCmntCreatedByIds]);

		//Loop through CaseCommnet
		for(CaseComment cCmnt : newCaseComments){
			
			//Cehck the appropriate condition to fire trigger
			if(cCmnt.isPublished == true && !setCaseAdminIds.contains(cCmnt.createdById) && 
					mapUsers.containsKey(cCmnt.CreatedById) && mapCases.containsKey(cCmnt.ParentId)	&& mapCases.get(cCmnt.ParentId).OwnerId != null 
				    && String.valueOf(mapCases.get(cCmnt.ParentId).OwnerId).StartsWithIgnoreCase(groupKeyPrefix)){
				
				//Add   the error		
		     	cCmnt.addError(Label.CASE_COMMENT_STATUS_MESSAGE);
		     	
			}
		}	
	}																							
}