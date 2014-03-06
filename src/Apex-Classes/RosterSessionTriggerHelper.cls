/**
 *  Description    :   Helper class for Trigger_RosterSession trigger.
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

public without sharing class RosterSessionTriggerHelper {
	
	/**
	 *	@description	:	Method to validate status and Attended of Roster according to child roster session's limit class
	 *
	 *	@args			:	List<lmsilt__GoToTraining_Session__c>, Map<Id,lmsilt__GoToTraining_Session__c>
	 *
	 *	@return			:	void
	 *
	 **/
	public static void validateRosterStatus(List<lmsilt__GoToTraining_Session__c> newRSessions, Map<Id, lmsilt__GoToTraining_Session__c> mapOldRSessions) {
		
		//Set to old limit class Id
		Set<Id> setLClassIds = new Set<Id>();
		
		//Set to hold Roster Id
		Set<Id> setRosterIds = new Set<Id>();
		
		//Loop through lmsilt__GoToTraining_Session__c
		for(lmsilt__GoToTraining_Session__c rS : newRSessions == null ? mapOldRSessions.values() : newRSessions) {
			
			//Check appropriate condition to fire trigger
			if(newRSessions != null && rS.lmsilt__Status__c != null && (mapOldRSessions == null 
				|| (rS.lmsilt__Status__c != mapOldRSessions.get(rS.Id).lmsilt__Status__c || rS.lmsilt__Class__c != mapOldRSessions.get(rS.Id).lmsilt__Class__c)
				|| (rS.lmsilt__Roster__c != mapOldRSessions.get(rS.Id).lmsilt__Roster__c))) {
					
				//Check for class Id
				if(rS.lmsilt__Class__c != null)
					setLClassIds.add(rS.lmsilt__Class__c);
				
				//Check for Roster
				if(rS.lmsilt__Roster__c != null)
					setRosterIds.add(rS.lmsilt__Roster__c);
				
				//Check for old Map and Roster
				if(mapOldRSessions != null && mapOldRSessions.get(rS.Id).lmsilt__Roster__c != null 
					&& rS.lmsilt__Roster__c != mapOldRSessions.get(rS.Id).lmsilt__Roster__c)
					setRosterIds.add(mapOldRSessions.get(rS.Id).lmsilt__Roster__c);
			
			} else if(newRSessions == null && rS.lmsilt__Status__c == Constants.ROSTER_SESSION_STATUS_ATTENDED && rS.lmsilt__Class__c != null
					  && rS.lmsilt__Roster__c != null) {
				
				//Add Class Id in set
				setLClassIds.add(rS.lmsilt__Class__c);
				
				//Add Roster Id in set
				setRosterIds.add(rS.lmsilt__Roster__c);
			}
		}
		
		//Map to hold Roster Id as key and List of Roster Session as value
		Map<Id, List<lmsilt__GoToTraining_Session__c>> mapRIdsAndRSs = new Map<Id, List<lmsilt__GoToTraining_Session__c>>();
		
		//Loop through lmsilt__GoToTraining_Session__c
		for(lmsilt__GoToTraining_Session__c rS : [Select Id, lmsilt__Roster__c,lmsilt__Roster__r.lmsilt__Class__c, lmsilt__Class__c, lmsilt__Status__c From
												  lmsilt__GoToTraining_Session__c Where lmsilt__Status__c =: Constants.ROSTER_SESSION_STATUS_ATTENDED
												  AND lmsilt__Class__c IN : setLClassIds AND lmsilt__Roster__c IN : setRosterIds]) {
		
			//Check for class
			if(rS.lmsilt__Class__c != null && rS.lmsilt__Roster__r.lmsilt__Class__c != null && rS.lmsilt__Class__c == rS.lmsilt__Roster__r.lmsilt__Class__c) {
				
				//Check for Roster Id in map
				if(mapRIdsAndRSs.containsKey(rS.lmsilt__Roster__c)) {
					
					mapRIdsAndRSs.get(rS.lmsilt__Roster__c).add(rS);
				} else {
					
					mapRIdsAndRSs.put(rS.lmsilt__Roster__c, new List<lmsilt__GoToTraining_Session__c>{rS});
				}
			} 										  	
		}
		
		//List of Roster
		List<lmsilt__Roster__c> rosters = new List<lmsilt__Roster__c>();
		
		//Loop through Rosters
		for(lmsilt__Roster__c lR : [Select lmsilt__Attended__c, lmsilt__Class__c, lmsilt__Status__c From lmsilt__Roster__c Where Id IN : setRosterIds]) {
			
			//Check if map ContainsKey
			if(mapRIdsAndRSs.containsKey(lR.Id) && mapRIdsAndRSs.get(lR.Id).Size() >= 2) {
				
				//Update Status and Attanted check box
				lR.lmsilt__Attended__c = true;
				lR.lmsilt__Status__c = Constants.ROSTER_SESSION_STATUS_ATTENDED;
			} else {
				
				//Update Status and Attanted check box
				lR.lmsilt__Attended__c = false;
				lR.lmsilt__Status__c = Constants.ROSTER_SESSION_STATUS_NOT_ATTENDED;
			}
			
			//Add in list
			rosters.add(lR);
		}
		
		//Try-Catch
		try {
			
			//Check for list size
			if(rosters.size() > 0)
				update rosters;
		} catch(Exception e) {
			//ayub.a@grazitti.com
			//Call EmailHandler class method to sent excaption mail
			EmailHandler.sendEmail('testng.salesforce@gmail.com', 'Exception Occures:: ' +e , 'Trigger Trigger_RosterSession have exception'+e);
		} 
	} 
}