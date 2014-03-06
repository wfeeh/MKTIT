/**
 *  Description     :   Helper class for Trigger_Class trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   01/22/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public with sharing class ClassTriggerHelper {
	
	/**
     * @Description  :  This method is used to validate the MKT total hours with the value of Total hours.
     *
     * @args         :  List<lmsilt__Class__c>, Map<Id,lmsilt__Class__c>
     *
     * @return       :  void
     *
	**/
	public static void validateClassMKTTotalHours(List<lmsilt__Class__c> newClasses ,Map<Id, lmsilt__Class__c> mapOldClasses){
		
		//Loop through Class
		for(lmsilt__Class__c cl : newClasses){
			
			//check the appropriate cindition to fire trigger
			if(mapOldClasses == null || mapOldClasses.get(cl.Id).lmsilt__Total_hours__c != cl.lmsilt__Total_hours__c){
				
				//check the class's total hour field value
				if(cl.lmsilt__Total_hours__c != null && cl.lmsilt__Total_hours__c != ''){
					
					//get the total hours in a string valiable to process the total hour value
					String totalHours = cl.lmsilt__Total_hours__c;
					
					//check the total hours contains the 'h' or not
					if(totalHours.contains('h')){
						
						//Split the string in h or with a blank value
						String[] totalHoursSplit = totalHours.split('h', 2);
						
						//Populate the value in totalHours
						totalHours = totalHoursSplit[0];
					}
					
					//get the total hours in decimal value
					Decimal totalHoursDec = Decimal.valueOf(totalHours.replace(',','.'));
					
					//check the total hour value is smaller then convert it inot minutes
					if (totalHoursDec < 1){
						totalHours = String.valueOf((totalHoursDec*60).setScale(0,System.RoundingMode.UP)) + 'min';
						
					} else{
						
						//split the string
						String[] totalHoursSplit = totalHours.Split(',', 2);
						
						//Check the size of splitted string
						if (totalHoursSplit.size() == 1 || totalHoursSplit[1] == '0') 
                    		totalHours = String.valueOf(totalHoursDec.setScale(0,System.RoundingMode.UP)) + 'h';
                    	else 
                    		totalHours = String.valueOf(totalHoursDec.setScale(1,System.RoundingMode.UP)) + 'h';
					}
					
					//Populate the value
					cl.MKT_Total_hours__c = totalHours;
				
				} else{
					
					//Populate the value
					cl.MKT_Total_hours__c = cl.lmsilt__Total_hours__c;
				} 
			}
		}
	}
}