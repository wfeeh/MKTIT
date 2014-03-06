/**
 *  Description    :   Helper class for Trigger_TaskClone trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/14/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/

public with sharing class TaskCloneTriggerHelper {
	
	//Boolean variable for account trigger execution
    public static Boolean execute_TaskClone_Trigger = true;
    
    /**
     *	@description	:	Method to create Task record if Account_Owner__c is assigned to Taskclone record
     *
     *	@args			:	List<TaskClone__c>
     *
     *	@return			:	void
     *
     **/
	public static void createTask(List<TaskClone__c> newTaskClones, Map<Id, TaskClone__c> mapOldTClones) {
		
		//List of Task
		List<Task> tasks = new List<Task>();
		
		//Loop through Taskclone
		for(TaskClone__c tC : newTaskClones) {
			
			//Check for Account Owner
			if(tc.TaskId__c != null && tC.Account_Owner__c != null && tC.Account_Owner__c instanceof Id && (mapOldTClones == null 
				|| tC.Account_Owner__c != mapOldTClones.get(tC.Id).Account_Owner__c)) {
					
				//Instance of Task
				Task tsk = new Task();
				
				tsk.Subject = Constants.TASK_SUBJECT_ADD_CSM_TO_OPPORTUNITY_TEAM;
				tsk.ActivityDate = System.today().addDays(3);
				tsk.Type = Constants.TASK_TYPE_AE_CSM_FOLLOWUP;
				tsk.Description = Label.DomainUrl + tC.TaskId__c;
				tsk.OwnerId = tC.Account_Owner__c;
				
				//Add in list
				tasks.add(tsk);
			}
		}
		
		//Check for list size
		if(tasks.size() > 0) {
			
			//Database Class to send email about task createion to owner
			Database.DMLOptions dmlo = new Database.DMLOptions();
	        dmlo.EmailHeader.triggerUserEmail = true;
	        
	        //Insert Task
	        Database.insert(tasks,dmlo);
		}
	}
}