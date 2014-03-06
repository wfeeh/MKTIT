/**
 *  Description     :   Helper class for Trigger_ClarizenProject trigger.
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
public without sharing class ClarizenProjectTriggerHelper {
	
	 //Boolean variable for account trigger execution
    public static Boolean execute_ClarizenProject_Trigger = true;
    
    /**
     * @Description  :  This mehod is create a new record of JBCX Milestone on finding the appropriate conditions.
     *
     * @args         :  Map<Id,clzV5__Clarizen_Project__c>, Map<Id,clzV5__Clarizen_Project__c>, Boolean isInsert
     *
     * @return       :  void
     *
     **/
	public static void validateClarizenJBCXMMilestone(Map<Id,clzV5__Clarizen_Project__c> mapClarizenProjects, 
     																	Map<Id ,clzV5__Clarizen_Project__c> mapOldCP, Boolean isInsert){
     	
    	//Create a Map of all the Milestone types
		Map<String,JBCXM__PickList__c> mapJBCXMPicklist= new Map<String,JBCXM__PickList__c>();
     	
     	//Query through JBCXM__PickList__c
		for(JBCXM__PickList__c jBCXMS :[SELECT Id, JBCXM__SystemName__c, JBCXM__Category__c FROM JBCXM__PickList__c 
											WHERE JBCXM__Category__c =: Constants.CONTACT_JBCXM_CATEGORY_MILESTONE AND JBCXM__Active__c = true]){
		
			//Populate the value in map
			mapJBCXMPicklist.put(jBCXMS.JBCXM__SystemName__c,jBCXMS);						
		}
		
		//List to insert the JBCXM Milestone record
		List<JBCXM__Milestone__c> jBCXMMilestones = new List<JBCXM__Milestone__c>();
		
		//Loop through clarizen Projects
     	for(clzV5__Clarizen_Project__c cP : [Select Id, CLZ_C_ProjectFamily__c, clzV5__CLZ_Customer__c, clzV5__CLZ_Customer__r.JBCXM__CustomerInfo__c ,
     												Project_Type_Name__c, CLZ_C_ProjectEndDate__c From clzV5__Clarizen_Project__c Where Id IN : mapClarizenProjects.keySet() 
     												AND clzV5__CLZ_Customer__c != null	AND clzV5__CLZ_Customer__r.JBCXM__CustomerInfo__c != null And
     												CLZ_C_ProjectFamily__c =: Constants.CLARIZEN_PROJECT_FAMILY_MLMLP]){
     		
			//Check the value of Jbcxm picklist and populate the values
			if(isInsert && CP.clzV5__CLZ_StartDate__c  != null && mapJBCXMPicklist.containsKey(Constants.CLARIZEN_JBCXM_PICKLIST_PROJ_START)){
					
				//Instantce of JBCXM Milestone	
				JBCXM__Milestone__c jCXM = new JBCXM__Milestone__c();
				
				//Check the field value and Populate the value
				jCXM.JBCXM__Account__c = cP.clzV5__CLZ_Customer__c;
				jCXM.JBCXM__Milestone__c = mapJBCXMPicklist.get(Constants.CLARIZEN_JBCXM_PICKLIST_PROJ_START).Id;
				jCXM.JBCXM__Date__c = cP.clzV5__CLZ_StartDate__c;
					
				//Check Project Type Name 
				if(cP.Project_Type_Name__c != null)
					jCXM.JBCXM__Comment__c = cP.Project_Type_Name__c;
				
				//Add in list
				jBCXMMilestones.add(jCXM);
			}
			
			//Check for Due Date
			if(isInsert && CP.clzV5__CLZ_DueDate__c != null && mapJBCXMPicklist.containsKey(Constants.CLARIZEN_JBCXM_PICKLIST_PROJ_DUE)){
					
				//Instantce of JBCXM Milestone	
				JBCXM__Milestone__c jCXM = new JBCXM__Milestone__c();
				
				//Check the field value and Populate the value
				jCXM.JBCXM__Account__c = cP.clzV5__CLZ_Customer__c;
				jCXM.JBCXM__Milestone__c = mapJBCXMPicklist.get(Constants.CLARIZEN_JBCXM_PICKLIST_PROJ_DUE).Id;
				jCXM.JBCXM__Date__c = cP.clzV5__CLZ_DueDate__c;
				
				//Check Project Type Name	
				if(cP.Project_Type_Name__c != null)
					jCXM.JBCXM__Comment__c = cP.Project_Type_Name__c;
			
				//Add in list
				jBCXMMilestones.add(jCXM);
					
			}
			
			//Check appropriate condition for update case
			if(!isInsert && cP.CLZ_C_ProjectEndDate__c != null && mapOldCP.get(cP.Id).CLZ_C_ProjectEndDate__c != cP.CLZ_C_ProjectEndDate__c 
				&& mapJBCXMPicklist.containsKey(Constants.CLARIZEN_JBCXM_PICKLIST_PROJ_COMPL)){
				
				//Instantce of JBCXM Milestone	
				JBCXM__Milestone__c jCXM = new JBCXM__Milestone__c();
				
				//Assign fields value
				jCXM.JBCXM__Account__c = cP.clzV5__CLZ_Customer__c;
				jCXM.JBCXM__Milestone__c = mapJBCXMPicklist.get(Constants.CLARIZEN_JBCXM_PICKLIST_PROJ_COMPL).Id;
				jCXM.JBCXM__Date__c = cP.CLZ_C_ProjectEndDate__c;
				
				//Check Project Type Name	
				if(cP.Project_Type_Name__c != null)
					jCXM.JBCXM__Comment__c = cP.Project_Type_Name__c;
				
				//Add the value in list
				jBCXMMilestones.add(jCXM);
			}
		}
     	
     	try{
     		//Check the size of list
     		if(jBCXMMilestones.size() > 0)
     			insert jBCXMMilestones;
     			
     	}catch(Exception e) {
     		
     		//Instance of Error Log
     		JBCXM__Log__c errorLog = new JBCXM__Log__c();
     		
     		//Assign value in fields
     		errorLog.JBCXM__ExceptionDescription__c = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()
     												  + ' while running the Trigger to create Milestones from Clarizen Projects';
            errorLog.JBCXM__LogDateTime__c = datetime.now();
       		errorLog.JBCXM__SourceData__c = e.getMessage();
       		errorLog.JBCXM__SourceObject__c = 'clzV5__Clarizen_Project__c';
       		errorLog.JBCXM__Type__c = 'Trigger_ClarizenProject';
        	
        	//Insert
        	insert errorLog;
     	}
	}
	/**
	 * @Description  :  This mehod is used for the followin functions:
	 *					1. select all the Project Ids from SMB SheduledJobInfo and all the records of it.
	 *					2. shedule the class and send the mail to hte clarizen project contact.
	 *					3. create a new record of SMB SheduledJobInfo.
     *
     * @args         :  Map<Id,clzV5__Clarizen_Project__c>, Map<Id,clzV5__Clarizen_Project__c>, Boolean isInsert
     *
     * @return       :  void
     *
	**/
	public static void validateSMBSendSurveyMail(List<clzV5__Clarizen_Project__c> newClProjects, Map<Id,clzV5__Clarizen_Project__c> mapOldClProjects){
     	
     	//Set to hold the clarizen Project
     	List<clzV5__Clarizen_Project__c> cLProjs = new List<clzV5__Clarizen_Project__c>();
     	
     	//Set to hold the clarizen Project Id
     	Set<Id> setClProjIds = new Set<Id>();  
     	
     	//Loop through
     	for(clzV5__Clarizen_Project__c clP : newClProjects){
     		
     		//check the aappropriate condition to fire trigger
     		if(clP.clzV5__CLZ_State__c != null && clP.clzV5__CLZ_State__c != '' && clP.clzV5__CLZ_State__c.equalsIgnoreCase(Constants.CLARIZEN_COMPLETED)
     			&& clP.clzV5__CLZ_State__c != mapOldClProjects.get(clP.Id).clzV5__CLZ_State__c && clP.CLZ_C_BusinessUnit__c != null 
     			&& clP.CLZ_C_BusinessUnit__c != '' && clP.CLZ_C_BusinessUnit__c != mapOldClProjects.get(clP.Id).CLZ_C_BusinessUnit__c
     			&& clP.CLZ_C_ProjectFamily__c != null && clP.CLZ_C_ProjectFamily__c != '' && clP.CLZ_C_ProjectFamily__c != mapOldClProjects.get(clP.Id).CLZ_C_ProjectFamily__c
     			&& ((clP.CLZ_C_BusinessUnit__c.deleteWhitespace()).equalsIgnoreCase(Constants.CLARIZEN_AMERSB) || 
	     			(clP.CLZ_C_BusinessUnit__c.deleteWhitespace()).equalsIgnoreCase(Constants.CLARIZEN_AMERMM))
	     			&& clP.CLZ_C_ProjectFamily__c.containsIgnoreCase(Constants.CLARIZEN_PROJECT_FAMILY_MLMLP)){
     		 	
     			//Add the vaue in set
     			cLProjs.add(clP);
     			 	
     		} else if( mapOldClProjects.get(clP.Id).clzV5__CLZ_State__c != null && mapOldClProjects.get(clP.Id).clzV5__CLZ_State__c != '' &&
     			mapOldClProjects.get(clP.Id).clzV5__CLZ_State__c.equalsIgnoreCase(Constants.CLARIZEN_COMPLETED)
     			&& clP.clzV5__CLZ_State__c != Constants.CLARIZEN_COMPLETED){
     			
     			//Add the value in set
     			setClProjIds.add(clP.Id);
     		}
     	}
     	
     	//Query through SMB SheduledJobInfo
     	List<SMB_SheduledJobInfo__c> smbScheduleJobInfos = [Select Name, ProjectId__c From SMB_SheduledJobInfo__c Where ProjectId__c IN : setClProjIds AND ProjectId__c != null];
     	
     	//Check the list size
     	if(smbScheduleJobInfos.size() > 0){
     		system.debug('###########');
     		delete smbScheduleJobInfos;
     	}
     	//List to insert the record of SM SheduledJobInfo
	    List<SMB_SheduledJobInfo__c> sheduleProjects = new List<SMB_SheduledJobInfo__c>();

     	 //Check the size of list
     	 if(cLProjs.size() > 0){
     	 	
     	 	//Call the scheduler Class
     		SMB_ScheduledSurveyMail sheduleMail = new SMB_ScheduledSurveyMail();
     		
	     	//Set the time for the scheduler 
	        Datetime timeToSendMail = System.now();
	        timeToSendMail = timeToSendMail.addHours(24);
	        String sch = '' + timeToSendMail.second() + ' ' + timeToSendMail.minute() + ' ' + timeToSendMail.hour() + ' ' 
	        				+ timeToSendMail.day() + ' ' + timeToSendMail.month() + ' ? ' + timeToSendMail.year();
	        				system.debug('@@@@@@@@@@@'+sch);
	        String sheduledJobId = System.schedule('SendSurveyOfLaunchPack-'+timeToSendMail, sch, sheduleMail);
	     	
	     	
	     	
	     	//Loop through clarizen Project
	     	for(clzV5__Clarizen_Project__c proj : cLProjs){
	     		
	     		//Instance of SMB SheduledJobInfo
	        	SMB_SheduledJobInfo__c sheduleProjectRec = new SMB_SheduledJobInfo__c();
	            
	            //Populate the value 
	            sheduleProjectRec.ProjectId__c = proj.Id;
	            sheduleProjectRec.SheduledJobId__c = sheduledJobId;
	            sheduleProjects.add(sheduleProjectRec);
	            system.debug('############+sheduleProjects'+sheduleProjects);
	        }
     	}
        try{
        	
        	//Check the size of list
        	if(sheduleProjects.size()> 0)
        		insert sheduleProjects;
        } catch(exception e){}
	}
}