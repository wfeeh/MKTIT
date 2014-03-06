/**  
 *  Description    :   Helper class for Trigger_Case trigger.
 *
 *  Created By     : 
 *
 *  Created Date   :  02/07/2014
 *
 *  Version        :   V_1.0
 *
 *  Revision Logs  :   V_1.0 - Created 
 *
 **/
public with sharing class TaskTriggerHelper {
	
	/**
     * @Description  :  Method to upsert TaskClone according to task
     *					if Task Type = 'CSM – Upsell/Cross sell Product'
     *											OR
     *									'CSM - Upsell/Cross sell Services'
     *					Case 1 : If there is no TasKClone on task than create a new TaskClone
     *					Case 2 : If TaskClone already associate with task than update it. 
     *
     * @args         :  List<Task>, Map<Id, Task>
     *
     * @return       :  void
     *
     **/
     public static void upsertTaskClone(List<Task> newTasks, Map<Id, Task> mapOldTasks){
     	
     	//Set to hold whatId of task
     	Set<Id> setWhatIds = new Set<Id>();
     	
     	//Set to hold Task Id
     	Set<Id> setTaskIds = new Set<Id>();
     	
     	//List of Task clone
     	List<TaskClone__c> taskClones = new List<TaskClone__c>();
     	
     	//Loop through Task
     	for(Task tsk : newTasks){
       		if(tsk.Type!= null &&  tsk.WhatId != null && (mapOldTasks == null || tsk.Type != mapOldTasks.get(tsk.Id).Type)
       			&& (tsk.Type.equalsIgnoreCase(Constants.TASK_TYPE_CSM_UPSELL_PRODUCT_ONLY) 
       				|| tsk.Type.equalsIgnoreCase(Constants.TASK_TYPE_CSM_UPSELL_SERVICES))){
       						  	
       			//Add the values in set
       			setWhatIds.add(tsk.WhatId);
       			setTaskIds.add(tsk.Id);				
       	   	}
		}
		
		//Map to hold the Account Id as key corresponding to the account 
		Map<Id, Account> mapAccounts = new Map<Id, Account>([Select Id, Owner.Name, OwnerId, Owner.Email from Account Where Id IN : setWhatIds]);
		
		//Map to hold the Task Id as key coresponding to the List Of Taskcloe As values
		Map<Id,List<TaskClone__c>> mapTskIdAndTskClone = new Map<Id,List<TaskClone__c>>();
		
		//Loop through TaskClone
		for(TaskClone__c tC : [Select Id, Subject__c, Comments__c, Assigned_to_user__c, RelatedTo__c, RelatedTo_Id__c, WhoName__c, Status__c, User_Email__c,
									  TaskId__c, Type__c, ContactId__c, LeadId__c, Account_Owner__c, Account_Owner_Mail__c, Call_Logged_By__c
								From TaskClone__c Where TaskId__c IN : setTaskIds]){
			
			//Check the values in map
			if(mapTskIdAndTskClone.containsKey(tC.TaskId__c)){
				mapTskIdAndTskClone.get(tC.TaskId__c).add(tC);
			} else {
				mapTskIdAndTskClone.put(tC.TaskId__c, new List<TaskClone__c>{tC});
			}
		}
		System.debug('########### : mapTskIdAndTskClone' +mapTskIdAndTskClone);
		//Loop through task
		for(Task tsk : [Select Id, Type, Subject, Description, CreatedBy.Email, Owner.Email, Owner.Name, Who.Name, What.Name, Status
													 From Task Where Id IN : setTaskIds]){
			
			//Check appropriate to fire trigger 
			if(tsk.Type != null &&  tsk.WhatId != null && (mapOldTasks == null || tsk.Type != mapOldTasks.get(tsk.Id).Type)
				&& (tsk.Type.equalsIgnoreCase(Constants.TASK_TYPE_CSM_UPSELL_PRODUCT_ONLY)
       				|| tsk.Type.equalsIgnoreCase(Constants.TASK_TYPE_CSM_UPSELL_SERVICES))){
       			System.debug('########### task Id : ' + tsk.Id);
       			System.debug('########### mapTskIdAndTskClone : ' + mapTskIdAndTskClone);
       			//Check for Task clones on Task if Task clone already associated than update it else create a new Task Clone on it
       			if(mapTskIdAndTskClone.containsKey(tsk.Id)){
				System.debug('###########');
					//Loop through TaskClone
					for(TaskClone__c tC : mapTskIdAndTskClone.get(tsk.Id)){
						
						//Call utility class method to update Task Clone 
						tC = Utility.taskClone(tsk, tC, mapAccounts.containsKey(tsk.WhatId) ? mapAccounts.get(tsk.WhatId) : null);
						
						//Add in list to update
						taskClones.add(tC);
					}
				} else {
					
					//Instance of Task clone to insert new Task clone
					TaskClone__c tC = new TaskClone__c();
					
					//Call utility class method to populate field values
					tC = Utility.taskClone(tsk, tC, mapAccounts.containsKey(tsk.WhatId) ? mapAccounts.get(tsk.WhatId) : null);
					
					//Add in list
					taskClones.add(tC);
				}	  	
       		}
		}
		
		//Check for list size
		if(taskClones.size() > 0)
			upsert taskClones;
	}
}