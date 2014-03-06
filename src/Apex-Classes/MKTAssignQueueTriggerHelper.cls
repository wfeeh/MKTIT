/**
 *  Description     :   Helper class for Trigger_MKTAssignQueue trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/18/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class MKTAssignQueueTriggerHelper {
	
	/**
     * @Description  :  This method is used to schedule Batch According to ApexClassName field value on Assign Queue
     *
     * @args         :  List<MKT_AssignQueue__c>, Map<Id, MKT_AssignQueue__c>
     *
     * @return       :  void
     *
	**/
	public static void validateApexJob(List<MKT_AssignQueue__c> newMKTAQueues, Map<Id, MKT_AssignQueue__c> mapOldMKTAQueues){
		
		//Integer variable for maximum Apex job limit  
		Integer apexJobsLimit = 4;
		
		//Set to hold the AsncClass name
		Set<String> setAJobClass = new Set<String>();
		
		//Query through AsyncApexJob
		List<AsyncApexJob> asyncApexJobs = [Select Id, TotalJobItems, Status, ParentJobId, JobType, ApexClass.Name, ApexClassId 
											      From AsyncApexJob WHERE Jobtype =: Constants.ASYNC_JOB_TYPE_BATCHAPEX AND 
											      ( Status =: Constants.ASYNC_JOB_TYPE_QUEUED OR Status =: Constants.ASYNC_JOB_TYPE_PROCESSING)];
											      
		//Assign currently processing Or Queued job count in variable
		Integer currentJobs = asyncApexJobs.Size();
		
		//Loop through AsyncApexJob to get Class name
		for(AsyncApexJob async : asyncApexJobs){
			
			//Add the value in set
			setAJobClass.add(async.ApexClass.Name);
		}
		
		//Map to hold Class Name as key and Assign Queue as 
		Map<String,MKT_AssignQueue__c> mapACAndAQ = new map<String,MKT_AssignQueue__c>();
		
		//Integer variable 
		Integer jobsSizeTemp = currentJobs;

		//Set to hold OrderItem
		Set<String> setOItemIds = new Set<String>();
		
		//Variable to pass in batch class
		String batchRTQuery;
		
		//Variable to pass in batch class 
		String batchURTQuery;
		
		//Loop through MKT AssignQueue
		for(MKT_AssignQueue__c mKT: newMKTAQueues) {
			
			//Check the size of apex jobs
			if (jobsSizeTemp >= apexJobsLimit) 
				break;
			
			//Check the appropriate condition to fire trigger
			if(mKT.MKT_Status__c == Constants.MKT_STATUS_PENDING && mKT.MKT_ApexClassName__c != null && mKT.MKT_ApexClassName__c != '' 
				&& !setAJobClass.contains(mKT.MKT_ApexClassName__c) && mKT.MKT_SerializedData__c != null && mKT.MKT_SerializedData__c != ''
				&& Constants.SET_ASYNCAPEX_JOB.contains(mKT.MKT_ApexClassName__c)
				&& (mapOldMKTAQueues == null || (mKT.MKT_Status__c != mapOldMKTAQueues.get(mKT.Id).MKT_Status__c) 
												 || mKT.MKT_ApexClassName__c != mapOldMKTAQueues.get(mKT.Id).MKT_ApexClassName__c)) {
				
				//Increase the counter
				jobsSizeTemp++;
				
				//Add class name in collaction to avoid scheduling same batch multiple times 
				setAJobClass.add(mKT.MKT_ApexClassName__c);
				
				//Populate map with value
				mapACAndAQ.put(mKT.MKT_ApexClassName__c, mKT);
				
				//Try - Catch
				try {
					
					//Check for class name	
					if(mKT.MKT_ApexClassName__c == Constants.CLASSNAME_MKT_BATCHASSIGN){
					
						//Add the order Item Id in set by deserializing MKT_SerializedData field value
						setOItemIds.addAll((set<String>)JSON.deserialize(mKT.MKT_SerializedData__c, Set<String>.class ));
					
					}else if(mKT.MKT_ApexClassName__c == Constants.CLASSNAME_BATCHREGISTERFORTRAINING){
						
						//Deserialize MKT_SerializedData value and assign to string
						batchRTQuery = (String)JSON.deserialize(mKT.MKT_SerializedData__c, String.class);
						
					} else if(mKT.MKT_ApexClassName__c == Constants.CLASSNAME_BATCHUNREGISTERFORTRAINING){
						
						//Deserialize MKT_SerializedData value and assign to string 
						batchURTQuery = (String)JSON.deserialize(mKT.MKT_SerializedData__c, String.class);
					}
				} catch(JSONException e) {
					mKT.addError(e.getMessage());
				}catch(DMLException e) {
					mKT.addError(e.getDmlFieldNames(0) + e.getDmlMessage(0));
				} catch(Exception e) {
					mKT.addError(e.getMessage());
				}
			}
		}
		
		//Check for set size
		if(setOItemIds.size() > 0) {
			
			//Query through OrderItem
			List<kumocomm__OrderItem__c> orderItems = [Select Id, MKT_Class__c, kumocomm__Amount__c, kumocomm__Order__c, kumocomm__Product__c, 
															kumocomm__Quantity__c, kumocomm__Order__r.kumocomm__Contact__c From kumocomm__OrderItem__c 
										                	Where Id IN : setOItemIds];
			
			//Set to hold the Class name from OrderItem
			Set<String> setOIClass = new Set<String>();
		
			//Loop through	kumocomm OrderItem
			for(kumocomm__OrderItem__c oI : orderItems){
				
				//Check the value of kumocomm OrderItem's MKT Class(field) value
				if (oI.MKT_Class__c != null)
					setOIClass.add(oI.MKT_Class__c );											  	
			}
			
			//Check for list size
			if(orderItems.size() > 0) {
				
				//Call the batch class
				MKT_BatchAssign batch = new MKT_BatchAssign();
				
				//Assign variables value
		    	batch.recs = orderItems;
		    	
		    	//Check for set size
		    	if(setOIClass.size() > 0)
		    		batch.ClassIds = setOIClass;
				
				//execute the batch class
				Id batchprocessid = Database.executeBatch(batch, 1);
				
				//Update Assign Queue
				mapACAndAQ.get(Constants.CLASSNAME_MKT_BATCHASSIGN).MKT_Status__c = Label.MKT_ASSIGN_QUEUE_STATUS_PROCESSING;
				mapACAndAQ.get(Constants.CLASSNAME_MKT_BATCHASSIGN).MKT_AsyncApexJobId__c = batchprocessid;
			}
		}
    	
    	//Check for string
    	if(batchRTQuery != null && batchRTQuery != '') {
	    	
	    	//Call the batch class
	    	lmsilt.BatchRegisterForTraining batchReg = new lmsilt.BatchRegisterForTraining();
	    	batchReg.Query = batchRTQuery;
			
			//Execute the batch
			Id batchprocessid = Database.executeBatch(batchReg, 1);
			
			//Update Assign Queue
			mapACAndAQ.get(Constants.CLASSNAME_BATCHREGISTERFORTRAINING).MKT_Status__c = Label.MKT_ASSIGN_QUEUE_STATUS_PROCESSING;
			mapACAndAQ.get(Constants.CLASSNAME_BATCHREGISTERFORTRAINING).MKT_AsyncApexJobId__c = batchprocessid;
			
    	}
    	
    	//Check for string
    	if(batchURTQuery != null && batchURTQuery != ''){
	    	
	    	//Call the batch class
	    	lmsilt.BatchUnRegisterForTraining batchUnReg = new lmsilt.BatchUnRegisterForTraining();
			batchUnReg.Query = batchURTQuery;
			
			//Execute the batch class
			Id batchprocessid = Database.executeBatch(batchUnReg, 1);
			
			//Update Assign Queue
			mapACAndAQ.get(Constants.CLASSNAME_BATCHUNREGISTERFORTRAINING).MKT_Status__c = Label.MKT_ASSIGN_QUEUE_STATUS_PROCESSING;
			mapACAndAQ.get(Constants.CLASSNAME_BATCHUNREGISTERFORTRAINING).MKT_AsyncApexJobId__c = batchprocessid;
	    }
	    
	    //Check for variables
	    if(setOItemIds.size() > 0 || (batchURTQuery != null && batchURTQuery != '') || (batchRTQuery != null && batchRTQuery != '')) {
	    	
	    	//Schedule job to update assign queue
	    	HelperWithoutSharing.StartAssignJob();
	    }
	}
}