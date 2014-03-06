/**
 *  Description     :   Helper class for Trigger_Roster trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/8/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class RosterTriggerHelper {

    /**
     *  @Description    :   This method is used for the following funtionalities:
     *                      1. Upadte the Roaster.
     *                      2. Insert a new reord of MKT Email Workflow in CyberU after finding the appropriate conditions.
     *
     *  @args           :   List<lmsilt__Roster__c>,Map<Id, lmsilt__Roster__c>,Boolean isInsert
     *
     *  @return         :   void
    **/
     public static void validateMKTEmailWorkflow(List<lmsilt__Roster__c> newRoasters,Map<Id, lmsilt__Roster__c> mapOldRoasters,Boolean isInsert){
        
        //Set to hold the Class(field)  Ids  Roaster
        Set<Id> setClassIds = new Set<Id>();
        
        //Set to hold the Product(field) Ids Raoster
        Set<Id> setProducts = new Set<Id>();
        
        //Map to hold class Id as key and Set of Student ids as value 
        Map<Id, Set<Id>> mapCIdAndSIds = new Map<Id,Set<Id>>();
        
        //Map to hold student Id as key and Name as Value
        Map<Id, String> mapSIdAndSN = new Map<Id,String>();
        
        //List to hold query
        List<lmsilt__Roster__c> listRoasters = new List<lmsilt__Roster__c>();
        
        //Map to hold Student Id as key and corresponding to this Id list of Roster
        Map<Id, List<lmsilt__Roster__c>> mapSIdsAndRosters = new Map<Id, List<lmsilt__Roster__c>>();
        
        //Loop through Roaster
        for (lmsilt__Roster__c lR : [Select Id, MKT_Opportunity__c, lmsilt__Student__c, lmsilt__Attended__c, lmsilt__Class__c, lmsilt__Student__r.Name,
        									lmsilt__Class__r.lmsilt__Event__r.Product__c From lmsilt__Roster__c Where Id IN : newRoasters
        									AND lmsilt__Attended__c = true AND lmsilt__Student__c != null AND lmsilt__Class__c != null
        									AND lmsilt__Class__r.lmsilt__Event__c != null AND lmsilt__Class__r.lmsilt__Event__r.Product__c != null]){
            
            //Check the apprpriate condition to fire trigger
            if(mapOldRoasters == null || lR.lmsilt__Attended__c != mapOldRoasters.get(lR.Id).lmsilt__Attended__c) {
            
                //Populate map with value
                mapSIdAndSN.put(lR.lmsilt__Student__c, lR.lmsilt__Student__r.Name);
                
                //Add Product Id in set
                setProducts.add(lR.lmsilt__Class__r.lmsilt__Event__r.Product__c);
                
                //Check for class Id in map
                if(mapCIdAndSIds.containsKey(lR.lmsilt__Class__c))
                	mapCIdAndSIds.get(lR.lmsilt__Class__c).add(lR.lmsilt__Student__c);
                else
                	mapCIdAndSIds.put(lR.lmsilt__Class__c, new Set<Id>{lR.lmsilt__Student__c});
                	 
                //Check for Opportunity
                if(lR.MKT_Opportunity__c == null) {
                	
                	//Check if map contains Product
                	if(mapSIdsAndRosters.containsKey(lR.lmsilt__Student__c))
                		mapSIdsAndRosters.get(lR.lmsilt__Student__c).add(lR);
                	else
                		mapSIdsAndRosters.put(lR.lmsilt__Student__c, new List<lmsilt__Roster__c>{lR});
                }
            }
        }
        
        //Query through MKT PayementLicense
        for(MKT_PaymentLicense__c pL : [Select User__c, MKT_Payment__c, MKT_Payment__r.MKT_Opportunity__c, MKT_Payment__r.Product__c,
        									   MKT_Payment__r.Account__c From MKT_PaymentLicense__c Where User__c IN : mapSIdsAndRosters.keySet() 
        									   AND MKT_Payment__c != null AND MKT_Payment__r.Product__c IN : setProducts AND Canceled__c = false 
        									   AND MKT_Payment__r.MKT_Opportunity__c != null]) {
        	
        	//Check for User
        	if(mapSIdsAndRosters.containsKey(pL.User__c)) {
        		
        		//Loop through Roster
        		for(lmsilt__Roster__c lR : mapSIdsAndRosters.get(pL.User__c)) {
        			
        			//Check for Product
        			if(lR.lmsilt__Class__r.lmsilt__Event__r.Product__c == pL.MKT_Payment__r.Product__c) {
        				
        				//Update roster opportunity
        				lR.MKT_Opportunity__c = pL.MKT_Payment__r.MKT_Opportunity__c;
        				
        				//Add in list
        				listRoasters.add(lR);
        			}
        		}
        		
        		//Remove user from map to avoid multiple update
        		mapSIdsAndRosters.remove(pL.User__c);
        	}
        }
        
        //Map to hold Class name as Key and map of String and List of Attachment as value
        Map<String, Map<String, List<Attachment>>> mapCNAndMSAndAttachements = new Map<String, Map<String, List<Attachment>>>();
        
        //Map to hold Material 
        Map<Id, lmsilt__Material__c> mapMaterials = new Map<Id, lmsilt__Material__c>([Select Id, Name, lmsilt__Class__c, lmsilt__Sequence__c,
        												lmsilt__Description__c, lmsilt__Instructions__c FROM lmsilt__Material__c 
        												WHERE lmsilt__Class__c != null AND lmsilt__Class__c IN : setClassIds]); 
        //Loop through Attachments
        for(Attachment att : [Select Id, Name, ParentId FROM Attachment Where ParentId IN : mapMaterials.keySet()]) {
                                            
            //Check for Parent Id
            if(att.ParentId.getSobjectType() == lmsilt__Material__c.SObjectType && mapMaterials.containsKey(att.ParentId)) {
            	
            	//Check for Sequence__c
            	if(mapMaterials.get(att.ParentId).lmsilt__Sequence__c == null 
            		|| mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_ANYTIME) 
            		|| mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_BEFORE)
                	|| mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_AFTER)) {
                    
	                //Check for class in map
	                if(mapCNAndMSAndAttachements.containsKey(mapMaterials.get(att.ParentId).lmsilt__Class__c)) {
	                    
	                    //Check for Sequence__c
	                    if(mapMaterials.get(att.ParentId).lmsilt__Sequence__c == null 
	                    	|| mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_ANYTIME) 
	                    	|| mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_BEFORE)) {
	                        
	                        //Check for Sequence__c
	                        if(mapCNAndMSAndAttachements.get(mapMaterials.get(att.ParentId).lmsilt__Class__c).containsKey(Constants.ROASTER_SEQUENCE_BEFORE)) {
	                            
	                            //Add Attachment in map
	                            mapCNAndMSAndAttachements.get(mapMaterials.get(att.ParentId).lmsilt__Class__c).get(Constants.ROASTER_SEQUENCE_BEFORE).add(att);
	                        } else {
	                            
	                            //Add Attachment in map
	                            mapCNAndMSAndAttachements.get(mapMaterials.get(att.ParentId).lmsilt__Class__c).put(Constants.ROASTER_SEQUENCE_BEFORE, new List<Attachment> {att});
	                        }
	                    } else {
	                        
	                        //Check for Sequence__c
	                        if(mapCNAndMSAndAttachements.get(mapMaterials.get(att.ParentId).lmsilt__Class__c).containsKey(mapMaterials.get(att.ParentId).lmsilt__Sequence__c)) {
	                            
	                            //Add Attachment in map
	                            mapCNAndMSAndAttachements.get(mapMaterials.get(att.ParentId).lmsilt__Class__c).get(mapMaterials.get(att.ParentId).lmsilt__Sequence__c).add(att);
	                        } else {
	                            
	                            //Add Attachment in map
	                            mapCNAndMSAndAttachements.get(mapMaterials.get(att.ParentId).lmsilt__Class__c).put(mapMaterials.get(att.ParentId).lmsilt__Sequence__c, new List<Attachment>{att});
	                        }
	                    }
	                } else if(mapMaterials.get(att.ParentId).lmsilt__Sequence__c == null 
	                	|| mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_ANYTIME)
	                	|| mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_BEFORE)){
	                    mapCNAndMSAndAttachements.put(mapMaterials.get(att.ParentId).lmsilt__Class__c, new Map<String, List<Attachment>>{Constants.ROASTER_SEQUENCE_BEFORE => new List<Attachment>{att}});
	                } else if(mapMaterials.get(att.ParentId).lmsilt__Sequence__c.equalsIgnoreCase(Constants.ROASTER_SEQUENCE_AFTER)) {
	                    mapCNAndMSAndAttachements.put(mapMaterials.get(att.ParentId).lmsilt__Class__c, new Map<String, List<Attachment>>{mapMaterials.get(att.ParentId).lmsilt__Sequence__c => new List<Attachment> {att}});
	                }
	            }
            }	            
        }
        
        //Map to hold Class Id as Key and List of Session__c as value
        Map<Id, List<lmsilt__Session__c>> mapCIdAndSessions = new Map<Id, List<lmsilt__Session__c>>();
        
        //Loop through Sessions
        for(lmsilt__Session__c sS : [Select Id, IsDeleted, Name, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name,
                                     	lmsilt__Class__c, lmsilt__Event__c, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c, MKT_MultiDaySession__c
                                      	From lmsilt__Session__c Where lmsilt__Class__c != null AND lmsilt__Class__c IN : mapCIdAndSIds.keySet()
                                      		Order By lmsilt__Start_Date_Time__c]) {
        	
        	//Check if map contains Class Id
        	if(mapCIdAndSessions.containsKey(sS.lmsilt__Class__c))
        		mapCIdAndSessions.get(sS.lmsilt__Class__c).add(sS);
        	else
        		mapCIdAndSessions.put(sS.lmsilt__Class__c, new List<lmsilt__Session__c>{sS});                              			
		}
		
		//List of Email_Workflow
        List<MKT_Email_Workflow_in_CyberU__c> mKTEWICyberU = new List<MKT_Email_Workflow_in_CyberU__c>();
        
        //Loop through Class
        for(lmsilt__Class__c cL :[Select Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Event__c, lmsilt__Event__r.Name, 
                                         lmsilt__Event__r.lmsilt__Description__c, lmsilt__Location__c, lmsilt__Location__r.Name, 
                                         lmsilt__Location__r.lmsilt__City__c, lmsilt__Location__r.lmsilt__Contact_Phone__c, lmsilt__Location__r.lmsilt__Country__c,
                                         lmsilt__Location__r.lmsilt__Postal_code__c, lmsilt__Location__r.lmsilt__Region__c, 
                                         lmsilt__Location__r.lmsilt__Room__c, lmsilt__Location__r.lmsilt__State__c, 
                                         lmsilt__Location__r.lmsilt__Street_Address__c,lmsilt__Location__r.lmsilt__Type__c, 
                                         lmsilt__Location__r.lmsilt__ZIP__c,lmsilt__Location__r.ArrivalText__c,lmsilt__Location__r.Accommodations__c
                                  From lmsilt__Class__c Where Id IN : mapCIdAndSIds.keySet()]){
                                                
            //Check for class in map
            if(mapCIdAndSIds.containsKey(cL.Id)) {
            
            	//Loop through student Ids
            	for(Id stuId : mapCIdAndSIds.get(cL.Id)) {
            	
	        		//Instance of MKT Email Workflow in CyberU
	            	MKT_Email_Workflow_in_CyberU__c eWorkflow = new MKT_Email_Workflow_in_CyberU__c();
            
	                //Populate the values
	                eWorkflow.Class__c = cL.Id;
	                eWorkflow.User__c = stuId;
	                eWorkflow.ClassName__c = cL.Name;
	                eWorkflow.MKT_Username__c = mapSIdAndSN.get(stuId);
                
                	//Check the value for start date
                	if(cL.lmsilt__Start_Date__c != null){
                    
	                    //Populate the value 
	                    eWorkflow.ClassStartTime__c = cL.lmsilt__Start_Date__c.format('h:mm a', 'PST');
	                    eWorkflow.ClassStartDate__c = cL.lmsilt__Start_Date__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', 'PST') + ' PST';
                	}
                	
                	//Check the value for end date and populate the value
                	if(cL.lmsilt__End_Date__c != null)
                    	eWorkflow.ClassEndTime__c = cL.lmsilt__End_Date__c.format('h:mm a', 'PST');
                
                	//Check the value for Laoction an Laocation's room value and populate the value
                	if(cL.lmsilt__Location__c != null){
                    	
                    	if(cL.lmsilt__Location__r.Name != null)
                    		eWorkflow.LocationName__c = cL.lmsilt__Location__r.Name;
                    	
                    	if(cL.lmsilt__Location__r.lmsilt__Room__c!= null)
                        	eWorkflow.LocationRoom__c = cL.lmsilt__Location__r.lmsilt__Room__c;
                    
                    	if(cL.lmsilt__Location__r.ArrivalText__c != null)
                        	eWorkflow.ArrivalText__c = cL.lmsilt__Location__r.ArrivalText__c;
                    
                    	if(cL.lmsilt__Location__r.Accommodations__c != null)
                        eWorkflow.Accommodations__c = cL.lmsilt__Location__r.Accommodations__c;
                	}
        			
        			//Check for event
        			if(isInsert){
                	
                		//Check for location
                		if(cL.lmsilt__Location__c != null) {
                			
                			//Populate value for Location
                			eWorkflow.Location__c = '';
                				
                			//Check the condition of field and populate with the values
                			if(cL.lmsilt__Location__r.Name != null && cL.lmsilt__Location__r.Name != '')
                    			eWorkflow.Location__c += cL.lmsilt__Location__r.Name;
                			if(cL.lmsilt__Location__r.lmsilt__Street_Address__c != null && cL.lmsilt__Location__r.lmsilt__Street_Address__c != '')
                    			eWorkflow.Location__c +=', ' + cL.lmsilt__Location__r.lmsilt__Street_Address__c;
                			if(cL.lmsilt__Location__r.lmsilt__State__c != NULL && cL.lmsilt__Location__r.lmsilt__State__c != '')
                    			eWorkflow.Location__c +=', ' + cL.lmsilt__Location__r.lmsilt__State__c ;
                			if (cL.lmsilt__Location__r.lmsilt__Postal_code__c != NULL && cL.lmsilt__Location__r.lmsilt__Postal_code__c != '')
                    			eWorkflow.Location__c +=', ' + cL.lmsilt__Location__r.lmsilt__Postal_code__c;
                		}
            			
            			//Check for event
            			if(cL.lmsilt__Event__c != null && cL.lmsilt__Event__r.Name != null)
            				eWorkflow.EventName__c = cL.lmsilt__Event__r.Name;
               				
           				//Check for event description
           				if(cL.lmsilt__Event__c != null && cL.lmsilt__Event__r.lmsilt__Description__c != null)
           					eWorkflow.CourseDescription__c = '<pre><span style = "font-size: 10pt; font-family:\'Arial\',\'Helvetica\',\'sans-serif\'">• ' 
                                               	 			 + cL.lmsilt__Event__r.lmsilt__Description__c + '</span></pre>';
            
                		//Check for start Date
                		if(cL.lmsilt__Start_Date__c != null) {
	                		
	                		//Take date variable to populate the value of Start date according to the Week days                             
	                		DateTime reminder3 = cL.lmsilt__Start_Date__c.addHours(-2);
	                		DateTime reminder2;
	                		DateTime reminder1;
	                
	                		//Variable to hold day of week
	                		String dayOfWeek = cL.lmsilt__Start_Date__c.format('EEE', 'PST');
	                		
	                		//Check for day Of Week 
	                		if (dayOfWeek == 'Mon') {
		                    	reminder2 = cL.lmsilt__Start_Date__c.addDays(-3);
		                    	reminder1 = cL.lmsilt__Start_Date__c.addDays(-5);
	                		} else if (dayOfWeek == 'Tue') {
			                    reminder2 = cL.lmsilt__Start_Date__c.addDays(-4);
			                    reminder1 = cL.lmsilt__Start_Date__c.addDays(-6);
	                		} else if (dayOfWeek == 'Wed') {
			                    reminder2 = cL.lmsilt__Start_Date__c.addDays(-2);
			                    reminder1 = cL.lmsilt__Start_Date__c.addDays(-5);
	                		} else if (dayOfWeek == 'Thu') {
			                    reminder2 = cL.lmsilt__Start_Date__c.addDays(-2);
			                    reminder1 = cL.lmsilt__Start_Date__c.addDays(-6);
	                		} else if (dayOfWeek == 'Fri') {
			                    reminder2 = cL.lmsilt__Start_Date__c.addDays(-2);
			                    reminder1 = cL.lmsilt__Start_Date__c.addDays(-4);
	                		} else {
			                    reminder2 = cL.lmsilt__Start_Date__c.addDays(-2);
			                    reminder1 = cL.lmsilt__Start_Date__c.addDays(-4);
	                		}
	                		
	                		//Assign RegistrationReminders date
	                		eWorkflow.RegistrationReminders1Date__c = (reminder1 > system.now()) ? reminder1 : null;
			                eWorkflow.RegistrationReminders2Date__c = (reminder2 > system.now()) ? reminder2 : null;
			                eWorkflow.RegistrationReminders3Date__c = reminder3;
                		}
                		
		                //String to hold Session and Session Virtual field values
		                String sessions = '';
		                String sessionsVirtual = ''; 
                
		                //Integer variable to hold no. of sessions
		                Integer numberOfSessionsVirtual = 0;
		                Integer numberOfSessions = 0;
                
		                //Check if map contains Class Id for child sessions
		                if(mapCIdAndSessions.containsKey(cL.Id)){
                    
		                    //Loop through Session
		                    for (lmsilt__Session__c ses : mapCIdAndSessions.get(cL.Id)) {
                        
		                        //Integer varibale
		                        Integer numberOfSessionsTemp = 1;
                        
		                        //Create a date
		                        String datesSession = '<li><span><b>' + ses.lmsilt__Start_Date_Time__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', 'PST') 
		                                                + ' ' + ses.lmsilt__Start_Date_Time__c.format('h:mm a', 'PST') + ' - ' 
		                                                + ses.lmsilt__End_Date_Time__c.format('h:mm a', 'PST') + ' PST</b></span></li>';
                        
		                        //Check the value for MKT MultiDaySession
		                        if (ses.MKT_MultiDaySession__c) {
                            
                            		Integer sessionDays = ses.lmsilt__End_Date_Time__c.Day() -  ses.lmsilt__Start_Date_Time__c.Day();
                            
	                            	//Loop
	                            	for (Integer i = 1; i <= sessionDays; i++) {
                                		
                                		//Add new String to Date Session
                                		datesSession += '<li><span><b>' + ses.lmsilt__Start_Date_Time__c.addDays(i).format('EEEEEEEEE, MMMMMMMMM dd, yyyy', 'PST')
                                						+ ' ' + ses.lmsilt__Start_Date_Time__c.format('h:mm a', 'PST') + ' - ' 
		                                                + ses.lmsilt__End_Date_Time__c.format('h:mm a', 'PST') + ' PST</b></span></li>';
                                
                                		//Increase the counter
                                		numberOfSessionsTemp++;
                            		}
                        		}
        						
        						//Check for ILT vILT
                        		if (ses.lmsilt__ILT_vILT__c == 'vILT') {
                            		eWorkflow.IsVirtual__c = true;
                            		sessionsVirtual += datesSession;
                            		numberOfSessionsVirtual += numberOfSessionsTemp;
                        		}
                        		
                        		//Check for ILT
                        		if (ses.lmsilt__ILT_vILT__c == 'ILT') {
		                            
		                            //Assign values
		                            eWorkflow.IsClassroom__c = true;
		                            sessions += datesSession;
		                            numberOfSessions += numberOfSessionsTemp;
                        		}
                    		}
                		}
		                
		                //Check for variable values
		                if(sessions != null && sessions != '')
		                	eWorkflow.Sessions__c = '<ul>' + sessions + '</ul>';
		                
		                //Check for variable values
		                if(sessionsVirtual != null && sessionsVirtual != '')
		                	eWorkflow.SessionsVirtual__c = '<ul>' + sessionsVirtual + '</ul>';
		                
		                //Set session numbers
		                eWorkflow.NumberOfSessions__c = String.valueOf(numberOfSessions);
		                eWorkflow.NumberOfSessionsVirtual__c = String.valueOf(numberOfSessionsVirtual);
                
                		//Check for virtual session and class room
                		if (eWorkflow.IsVirtual__c == true && eWorkflow.IsClassroom__c == false)
                    		eWorkflow.ClassType__c = Label.MKT_Virtual;
                    		
                		if (eWorkflow.IsVirtual__c == true && eWorkflow.IsClassroom__c == true)
                    		eWorkflow.ClassType__c = Label.MKT_ClassroomVirtual; 
                		
                		if (eWorkflow.IsVirtual__c == false && eWorkflow.IsClassroom__c == true)
                    		eWorkflow.ClassType__c = Label.MKT_Classroom;
                
                		//Check if map contains Class Id
                		if (mapCNAndMSAndAttachements.containsKey(cL.Id)) {
                    
	                    	//Loop through
	                    	for(String str : mapCNAndMSAndAttachements.get(cL.Id).KeySet()) {
                        
		                        //Loop through Attachment
		                        for(Attachment att : mapCNAndMSAndAttachements.get(cL.Id).get(str)) {
                            
                            		//Check for Key
                            		if(str == 'before') {
                                		eWorkflow.ClassMaterials__c += '<li><a href = "' + Label.MKT_LinkFileDownload+'?file='+ att.id + '">' +
                                                                 att.Name + '</a></li>';
                            		} else if(str == 'after') {
                                		eWorkflow.ClassMaterialsAfter__c += '<li><a href = "' + Label.MKT_LinkFileDownload+'?file='+ att.id + '">' + 
                                                                    att.Name + '</a></li>';
                            		}
                        		}
                        	
	                        	//Check for key
	                        	if(str == 'before') 
	                            	eWorkflow.ClassMaterials__c = '<ul>' + eWorkflow.ClassMaterials__c + '</ul>';
	                        	if(str == 'after')
	                            	eWorkflow.ClassMaterialsAfter__c = '<ul>' + eWorkflow.ClassMaterialsAfter__c + '</ul>';
                    		}
                		}
            		}
            
		            //Add the value in list
		            mKTEWICyberU.add(eWorkflow);
        		}
            }
		}
        
        //check the size of list
        if(mKTEWICyberU.size() > 0)
            insert mKTEWICyberU;
            
        //Check the size of list
        if(listRoasters.size() > 0)
            update listRoasters;
    }
}