/**
 *  Description     :   Helper class for Trigger_LearningPath trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class LearningPathTriggerHelper {
    
    //Boolean variable for Learning trigger execution
    public static Boolean execute_LearningPath_Trigger = true;
    
    /**
     *  @Description    :   This method is used to diaplay the error on Learning Path Product if shopping cartItem consist the same Product Value
     *                      
     *  @args           :   List<lmscons__Curriculum__c>,Map<Id, lmscons__Curriculum__c>
     *
     *  @return         :   void
    **/
    public static void validateLPProduct(List<lmscons__Learning_Path__c> newLPaths ,Map<Id,lmscons__Learning_Path__c> mapOldLPaths){
        
        //Set to hold the Learning Path's Product Id
        Set<Id> setLPProudctIds = new Set<Id>();
        
        //Set to hold the shopping cart Item's product Id
        Set<Id> setSCIProductIds = new Set<Id>();
        
        //Loop through Learning Path
        for(lmscons__Learning_Path__c lp : newLPaths){
            
            //Check the appropriate condition to fire the trigger
            if(lp.Product__c != null && (mapOldLPaths == null || mapOldLPaths.get(lp.Id).Product__c != lp.Product__c)){
                
                //Add the value in set
                setLPProudctIds.add(lp.Product__c);
            }
        }
        
        //Loop through Shopping CartItem
        for(kumocomm__ShoppingCartItem__c sCI : [Select Id, kumocomm__Product__c From kumocomm__ShoppingCartItem__c Where 
                                                            kumocomm__Product__c != null AND kumocomm__Status__c =: Constants.TRAINING_STATUS_IN_CART
                                                            AND kumocomm__Product__c IN : setLPProudctIds]){
            //add the value in set
            setSCIProductIds.add(sCI.kumocomm__Product__c);                                             
        }
        
        //Loop through event
        for(lmscons__Learning_Path__c lp : newLPaths){
            
            //Check the appropriate condition to fire the trigger
            if(lp.Product__c != null && (mapOldLPaths == null || mapOldLPaths.get(lp.Id).Product__c != lp.Product__c)){
                
                //Check product alrady consist in set
                if(setSCIProductIds.contains(lp.Product__c)){
                    
                    //Display error
                    lp.Product__c.addError(Label.MKT_CheckProductError);
                }
            }
        }
    }
	/**
	 *	@Description	:	This method is used to upadte the MKT total hour field value.
	 *						
	 *	@args			:	List<lmscons__Learning_Path__c>,Map<Id, lmscons__Learning_Path__c>
	 *
	 *	@return			:	void
	**/
	public static void validateLPTotalHours(List<lmscons__Learning_Path__c> newLPaths , Map<Id, lmscons__Learning_Path__c> mapOldPaths){
		
		//Loop through Learniing Path
		for(lmscons__Learning_Path__c lp : newLPaths){
			
			//Check the appropriate condition to fire the trigger
			if(mapOldPaths == null || mapOldPaths.get(lp.Id).lmscons__Duration__c != lp.lmscons__Duration__c){
				
				//Check the value of duration field
				if(lp.lmscons__Duration__c != null){
					
					//Check the value for Duration field value is samller than 60 or not
					if(lp.lmscons__Duration__c < 60){
						
						//Populate the value
						lp.MKT_Total_hours__c = String.valueOf(lp.lmscons__Duration__c) + 'min';
						
					} else{
						
						//Populate the value
						lp.MKT_Total_hours__c = String.valueOf((lp.lmscons__Duration__c).divide(60, 1, System.RoundingMode.UP)) + 'h';
					}
					
				} else{
					
					lp.MKT_Total_hours__c = null;
				}
			}
		}
	}
}