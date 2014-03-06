/**
 *  Description     :   Helper class for Trigger_UsageDataLoadDetail trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/14/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class UsageDataLoadDetailTriggerHelper {
	
	/**
     * @Description  :  This method is to execute batch.
     *
     * @args         :  List<Usage_Data_Load_Detail__c>
     *
     * @return       :  void
     *
	**/
	public static void executeWeeklyUsageDataBatch(List<Usage_Data_Load_Detail__c> newUsageDataLoadDetail){
		
		//Boolean variable to execute batch
		Boolean execute_Weekly_Usage_Data_Load = false;
		
		//Loop through Usage Data Load Detail
		for(Usage_Data_Load_Detail__c uDLD : newUsageDataLoadDetail){
			
			//Check the appropriate condition to fire trigger
			if(uDLD.Start_Batch_Process__c == true){
				
				//set boolean variable true
				execute_Weekly_Usage_Data_Load = true;
			}
		}
		
		//Check the flag value to execute the batch
		if(execute_Weekly_Usage_Data_Load == TRUE){ 
			
			//Call the batch classs  
        	BatchCreateGS4WeeklyUsageData batchCreateAccConUData = new BatchCreateGS4WeeklyUsageData();
        	database.executeBatch(batchCreateAccConUData, 10);
    	}
	}
}