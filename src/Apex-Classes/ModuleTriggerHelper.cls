/**
 *  Description     :   Helper class for Trigger_Moduletrigger.
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
public without sharing class ModuleTriggerHelper {
	
	//Boolean variable for Learning trigger execution
    public static Boolean execute_Module_Trigger = true;
    
    /**
     *  @Description    :   This method is used to diaplay the error on Learning Path Product if shopping cartItem consist the same Product Value
     *                      
     *  @args           :   List<lmscons__Training_Content__c>,Map<Id, lmscons__Training_Content__c>
     *
     *  @return         :   void
    **/
    public static void validateModuleProduct(List<lmscons__Training_Content__c> newModules, Map<Id, lmscons__Training_Content__c> mapOldModules){
    	
    	   //Set to hold the Module Product Id
        Set<Id> setModuleProudctIds = new Set<Id>();
        
        //Set to hold the shopping cart Item's product Id
        Set<Id> setSCIProductIds = new Set<Id>();
        
        //Loop through Learning Path
        for(lmscons__Training_Content__c tC : newModules){
            
            //Check the appropriate condition to fire the trigger
            if(tc.Product__c != null && (mapOldModules == null || mapOldModules.get(tc.Id).Product__c != tc.Product__c)){
                
                //Add the value in set
                setModuleProudctIds.add(tc.Product__c);
            }
        }
        
        //Loop through Shopping CartItem
        for(kumocomm__ShoppingCartItem__c sCI : [Select Id, kumocomm__Product__c From kumocomm__ShoppingCartItem__c Where 
                                                            kumocomm__Product__c != null AND kumocomm__Status__c =: Constants.TRAINING_STATUS_IN_CART
                                                            AND kumocomm__Product__c IN : setModuleProudctIds]){
            //add the value in set
            setSCIProductIds.add(sCI.kumocomm__Product__c);                                             
        }
        
        //Loop through module
        for(lmscons__Training_Content__c tc : newModules){
            
            //Check the appropriate condition to fire the trigger
            if(tc.Product__c != null && (mapOldModules == null || mapOldModules.get(tc.Id).Product__c != tc.Product__c)){
                
                //Check product alrady consist in set
                if(setSCIProductIds.contains(tc.Product__c)){
                    
                    //Display error
                    tc.Product__c.addError(Label.MKT_CheckProductError);
                }
            }
        }
    }
	/**
	 *	@Description	:	This method is used to upadte the MKT total hour field value.
	 *						
	 *	@args			:	List<lmscons__Training_Content__c>,Map<Id, lmscons__Training_Content__c>
	 *
	 *	@return			:	void
	**/
	public static void validateModuleTotalHours(List<lmscons__Training_Content__c> newModules, Map<Id, lmscons__Training_Content__c> mapOldModules){
		
		//Loop through module
		for(lmscons__Training_Content__c tc : newModules){
			
			//Check the appropriate condition to fire the trigger
			if(mapOldModules == null || mapOldModules.get(tc.Id).lmscons__Duration__c != tc.lmscons__Duration__c){
				
				//Check the value of duration field
				if(tc.lmscons__Duration__c != null){
					
					//Check the value for Duration field value is samller than 60 or not
					if(tc.lmscons__Duration__c < 60){
						
						//Populate the value
						tc.MKT_Total_hours__c = String.valueOf(tc.lmscons__Duration__c) + 'min';
						
					} else{
						
						//Populate the value
						tc.MKT_Total_hours__c = String.valueOf((tc.lmscons__Duration__c).divide(60, 1, System.RoundingMode.UP)) + 'h';
					}
					
				} else{
					
					tc.MKT_Total_hours__c = null;
				}
			}
		}
	}
}