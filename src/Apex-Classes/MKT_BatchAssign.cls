global class MKT_BatchAssign implements Database.Batchable<kumocomm__OrderItem__c>, Database.Stateful {

	global List<kumocomm__OrderItem__c> recs { get;set; }
	global Set<String> ClassIds { get;set; }
	
	//Start Method
	global Iterable<kumocomm__OrderItem__c> start(Database.BatchableContext BC) {
		
		//Return order Item list
		return recs;
	}
	
	//Execute Method
	global void execute(Database.BatchableContext BC, List<kumocomm__OrderItem__c> scope) {

		//Loop through Order Item
		for (kumocomm__OrderItem__c oI : scope) {

			//Try - Catch 
			try {
				
				//Check for contact and Product
    			if(oI.kumocomm__Order__c != null && oI.kumocomm__Order__r.kumocomm__Contact__c != null && oI.kumocomm__Product__c != null) {
    			
	    			//List of users
					List<User> users = [SELECT Id FROM User WHERE ContactId = :oI.kumocomm__Order__r.kumocomm__Contact__c LIMIT 1];
					
					//Check for user list
					if(users.size() > 0) {
				
		    			//List of Curriculum
		    			List<lmscons__Curriculum__c> curriculums = [SELECT Id FROM lmscons__Curriculum__c WHERE Product__c =: oI.kumocomm__Product__c];
		    			
		    			//List of Learning_Path
		    			List<lmscons__Learning_Path__c> lPaths = [SELECT Id FROM lmscons__Learning_Path__c WHERE Product__c =: oI.kumocomm__Product__c];
						
						//List of Training_Path
						List<lmscons__Training_Path__c> tPaths = [SELECT Id FROM lmscons__Training_Path__c WHERE Product__c =: oI.kumocomm__Product__c];
						
						//List of Training_Content
						List<lmscons__Training_Content__c> tContents = [SELECT Id FROM lmscons__Training_Content__c WHERE Product__c =: oI.kumocomm__Product__c];
						
						//List of Training_Event
						List<lmsilt__Event__c> events = [SELECT Id FROM lmsilt__Event__c WHERE Product__c =: oI.kumocomm__Product__c];
						
						//List of Training_Quiz
						List<lmscons__Quiz__c> quizs = [SELECT Id FROM lmscons__Quiz__c WHERE Product__c =: oI.kumocomm__Product__c];
					
						//Check for child records according to product and Call manage package call method according to these values
						if(curriculums.size() > 0) {
							lmsilt.ILTUtil.assignCurriculum(users, curriculums[0]);
						} else if(lPaths.size() > 0) {
							lmsilt.ILTUtil.assignLearningPath(users, lPaths[0]);
						} else if (tPaths.size() > 0) {
							lmsilt.ILTUtil.assignCourse(users, tPaths[0]);
						} else if (tContents.size() > 0) {
							lmscons.LMSUtil.assignModule(users, tContents[0]);
						} else if (events.size() > 0) {
							
							//Check for Class
							if(oI.MKT_Class__c == null) {
								lmsilt.ILTUtil.assignEvent(users, events[0]);
							} else {
								HelperWithoutSharing.EnrollUserToClass(users[0].Id, oI.MKT_Class__c);
							}
						} else if (quizs.size() > 0) {
							lmscons.LMSUtil.assignQuiz(users, quizs[0]);
						}
					}
    			}
    		} catch (Exception e) {
    			
    			//Set status to error
    			oI.MKT_Assignment_Status_c__c = 'Error';
    			
    			//Update Order Item
    			update oI;
    			
    			//Through exception
    			throw e;
    		}
			oI.MKT_Assignment_Status_c__c = 'Completed';
			update oI;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		//Check for set size and Call helper class method
		if(ClassIds.size() > 0)
			HelperWithoutSharing.RegisterforTrainingClass (ClassIds);
	}

	global class applicationException extends Exception {}
}