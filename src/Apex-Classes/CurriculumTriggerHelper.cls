/**
 *  Description    :   Helper class for Trigger_Curriculum trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/21/2014
 *
 *  Version      	:  	V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class CurriculumTriggerHelper {
	
	//Boolean variable for Curriculum trigger execution
    public static Boolean execute_Curriculum_Trigger = true;

	/**
	 *	@Description	:	This method is used to diaplay the error on Curriculum Product if shopping cartItem consist the same Product Value
	 *						
	 *	@args			:	List<lmscons__Curriculum__c>,Map<Id, lmscons__Curriculum__c>
	 *
	 *	@return			:	void
	**/
	public static void validateCurProduct(List<lmscons__Curriculum__c> newCurriculum, Map<Id,lmscons__Curriculum__c> mapOldCurriculum){
		
		//Set to hold the Curriculum's Product(field) Id
		Set<Id> setCurProductIds = new Set<Id>(); 
		
		//Set to hold the shopping cart Item's product Id
		Set<Id> setSCIProductIds = new Set<Id>();
		
		//Loop through Curriculum
		for(lmscons__Curriculum__c cur : newCurriculum){
			
			//Check the appropriate condition to fire the trigger
			if(cur.Product__c != null && (mapOldCurriculum == null || mapOldCurriculum.get(cur.Id).Product__c != cur.Product__c)){
				
				//Add the values in set
				setCurProductIds.add(cur.Product__c);
			}
		}
		
		//Loop through Shopping CartItem
		for(kumocomm__ShoppingCartItem__c sCI : [Select Id, kumocomm__Product__c From kumocomm__ShoppingCartItem__c Where 
															kumocomm__Product__c != null AND kumocomm__Status__c =: Constants.TRAINING_STATUS_IN_CART
															AND kumocomm__Product__c IN : setCurProductIds]){
			//add the value in set
			setSCIProductIds.add(sCI.kumocomm__Product__c);												
		}
		
		//Loop through Curriculum
		for(lmscons__Curriculum__c cu : newCurriculum){
			
			//Check the appropriate condition to fire the trigger
			if(cu.Product__c != null && (mapOldCurriculum == null || mapOldCurriculum.get(cu.Id).Product__c != cu.Product__c)){
				
				//Check product alrady consist in set
				if(setSCIProductIds.contains(cu.Product__c)){
					
					//Display error
					cu.Product__c.addError(Label.MKT_CheckProductError);
				}
			}
		}
	}
	/**
	 *	@Description	:	This method is used to upadte the MKT total hour field value.
	 *						
	 *	@args			:	List<lmscons__Curriculum__c>,Map<Id, lmscons__Curriculum__c>
	 *
	 *	@return			:	void
	**/
	public static void validateMKTTotalHours(List<lmscons__Curriculum__c> newCurriculum , Map<Id, lmscons__Curriculum__c> mapOldCurriculum){
		
		//Loop through curriculum
		for(lmscons__Curriculum__c cu : newCurriculum){
			
			//Check the appropriate condition to fire the trigger
			if(mapOldCurriculum == null || mapOldCurriculum.get(cu.Id).lmscons__Duration__c != cu.lmscons__Duration__c){
				
				//Check the value of duration field
				if(cu.lmscons__Duration__c != null){
					
					//Check the value for Duration field value is samller than 60 or not
					if(cu.lmscons__Duration__c < 60){
						
						//Populate the value
						cu.MKT_Total_hours__c = String.valueOf(cu.lmscons__Duration__c) + 'min';
						
					} else{
						
						//Populate the value
						cu.MKT_Total_hours__c = String.valueOf((cu.lmscons__Duration__c).divide(60, 1, System.RoundingMode.UP)) + 'h';
					}
					
				} else{
					
					cu.MKT_Total_hours__c = null;
				}
			}
		}
	}
}