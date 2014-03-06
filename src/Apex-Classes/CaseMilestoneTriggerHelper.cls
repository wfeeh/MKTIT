/**
 *  Description     :   Helper class for Trigger_CaseMilestone trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/17/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class CaseMilestoneTriggerHelper {
	
	/**
     * @Description  : This mehod is used to create a new record of Case Milestone after finding the appropriate conditions.
     *
     * @args         :  Map<Id, Case_Update_Milestones__c>, Map<Id, Case_Update_Milestones__c>
     *
     * @return       :  void
     *
	**/
    public static void upadteCaseMileStone(Map<Id, Case_Update_Milestones__c> mapNewCUMiletones, Map<Id, Case_Update_Milestones__c> mapOldCUMilestones){
     	
     	//Map to hold the Custom setting
    	Map<String,CustomMilestoneSettings__c> mapCustomMilestoneSettings = Constants.CUSTOMMILESTONESETTING_CUSTOM_SETTING;
     	
     	//Set to hol the Case Milestone Id
     	Set<Id> setCUMIds = new Set<Id>();
     	
     	//Check for CustomMilestoneSettings__c data
		if(mapCustomMilestoneSettings.size() == 0 || mapCustomMilestoneSettings.get('Custom Milestone').Custom_Milestone_Active__c != true)
			return;

		//Set to hold the case priority
		Set<string> setPriorities = new Set<String>();
		
		//Set  to hold the case support level
		Set<String> setSupportLevels = new Set<String>();
		
		//Loop through Case Milestone
		for(Case_Update_Milestones__c cUM : [Select Id, Completed__c, AutoComplete__c, Milestone_Type__c, Update__c, Case__c ,Case__r.Priority, Case__r.Support_Level__c, Case__r.IsClosed, Case__r.Ownerid ,
	 												Case__r.NextUpdateDueFrmCUM__c, Case__r.Status, Case__r.Entitlement.BusinessHoursId	From 
	 												Case_Update_Milestones__c Where Id IN :mapNewCUMiletones.keySet()]){
			
			//Check for field values to fire trigger
			if(cUM.Case__c != null && cUM.Completed__c == true && cUM.AutoComplete__c == true && cUM.Update__c == false 
	 			&& cUM.Milestone_Type__c != Constants.CASE_MILESTONENAME_FIRST_RESPONSE && (cUM.Completed__c != mapOldCUMilestones.get(cUM.Id).Completed__c
	 				|| cUM.AutoComplete__c != mapOldCUMilestones.get(cUM.Id).AutoComplete__c || cUM.update__c != mapOldCUMilestones.get(cUM.Id).Update__c
	 				|| cUM.Milestone_Type__c != mapOldCUMilestones.get(cUM.Id).Milestone_Type__c)){
				
				
				// check the value of priority and add the values in set
				if(cUM.Case__r.Priority != null && cUM.Case__r.Priority != '')
					setPriorities.add(cUM.Case__r.Priority);
			
				//check the value of Suppor level and add the values in set
				if(cUM.Case__r.Support_Level__c != null && cUM.Case__r.Support_Level__c != '')
					setSupportLevels.add(cUM.Case__r.Support_Level__c);
				
				//Add Id in set
				setCUMIds.add(cUM.Id);
			}
		}
		
		//Map to hold SLA Record corresponding to case Priority and Support Level
	 	Map<String, SLA__c> mapSLAs = Utility.mapGetSlaHours(setPriorities, setSupportLevels);
	 	
	 	//List to insert the Case Milestone
	 	List<Case_Update_Milestones__c> insertCUMs = new List<Case_Update_Milestones__c>();
	 	
	 	//Loop through Case Milestone
	 	for(Case_Update_Milestones__c cUM : [Select Id, Completed__c, AutoComplete__c, Milestone_Type__c, Update__c, Case__c ,Case__r.Priority, Case__r.Support_Level__c, Case__r.IsClosed, Case__r.Ownerid ,
	 												Case__r.NextUpdateDueFrmCUM__c, Case__r.Status,Case__r.EntitlementId, Case__r.Entitlement.BusinessHoursId	From 
	 												Case_Update_Milestones__c Where Id IN :setCUMIds]){
	 													
	 		//Instance of Case Milestone
	 		Case_Update_Milestones__c  cseUpdtMilestone = new Case_Update_Milestones__c();
 			
 			//Populate the values
 			cseUpdtMilestone.Case__c = cUM.Case__c;
 			cseUpdtMilestone.Milestone_Type__c = Constants.CASE_MILESTONENAME_CASE_UPDATE;
 			cseUpdtMilestone.Start_Date__c = System.now();
 			
 			//Make unique key by combining Case's Priority and support level
			String uniqueKey = '';
			
 			//Check for Case Priority and Support level
 			if(cUM.Case__r.Priority != null && cUM.Case__r.Priority != '' && cUM.Case__r.Support_Level__c != null && cUM.Case__r.Support_Level__c != '')
 				uniqueKey = cUM.Case__r.Priority + '-' + cUM.Case__r.Support_Level__c;
			
 			//Check for unique Key (Case Priority and Support level) in map
            if(mapSLAs.containsKey(uniqueKey)) {
                	
            	Integer numOfMinutes = mapSLAs.get(uniqueKey).Case_Update_Milestone_NOM__c.intValue();
                	
				cseUpdtMilestone.Target_Date__c = numOfMinutes!= null && cUM.Case__r.Priority != 'P1' ?
			    					 			BusinessHours.addGmt(cUM.Case__r.Entitlement.BusinessHoursId, System.now(),
			    					 			numOfMinutes*60000) : System.Now().addMinutes(numOfMinutes); 
			    					 	
                 cseUpdtMilestone.Duration__c = numOfMinutes != null ? String.valueOf(numOfMinutes) : null;
            }
            
            //Add the value in list
            insertCUMs.add(cseUpdtMilestone);
	 	}
	 	
	 	//Check the size of list
	 	if(insertCUMs.size() > 0){
	 		insert insertCUMs;
	 	}
	}
}