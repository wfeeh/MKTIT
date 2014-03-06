/**
 *  Description     :   Helper class for Trigger_Quiz trigger.
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
public with sharing class QuizTriggerHelper {
	
	//Boolean variable for Quiz trigger execution
    public static Boolean execute_Quiz_Trigger = true;
    
	/**
     *  @Description    :   This method is used to diaplay the error on Learning Path Product if shopping cartItem consist the same Product Value
     *                      
     *  @args           :   List<lmscons__Quiz__c>,Map<Id, lmscons__Quiz__c>
     *
     *  @return         :   void
    **/
     public static void validateQuizProduct(List<lmscons__Quiz__c> newQuizes, Map<Id, lmscons__Quiz__c> mapOldQuizes){
    	
    	//Set to hold the Quiz Product Id
        Set<Id> setQuizProudctIds = new Set<Id>();
        
        //Set to hold the shopping cart Item's product Id
        Set<Id> setSCIProductIds = new Set<Id>();
        
        //Loop through Learning Path
        for(lmscons__Quiz__c quiz : newQuizes){
            
            //Check the appropriate condition to fire the trigger
            if(quiz.Product__c != null && (mapOldQuizes == null || mapOldQuizes.get(quiz.Id).Product__c != quiz.Product__c)){
                
                //Add the value in set
                setQuizProudctIds.add(quiz.Product__c);
            }
        }
        
        //Loop through Shopping CartItem
        for(kumocomm__ShoppingCartItem__c sCI : [Select Id, kumocomm__Product__c From kumocomm__ShoppingCartItem__c Where 
                                                            kumocomm__Product__c != null AND kumocomm__Status__c =: Constants.TRAINING_STATUS_IN_CART
                                                            AND kumocomm__Product__c IN : setQuizProudctIds]){
            //add the value in set
            setSCIProductIds.add(sCI.kumocomm__Product__c);                                             
        }
        
        //Loop through Quiz
        for(lmscons__Quiz__c quiz : newQuizes){
            
            //Check the appropriate condition to fire the trigger
            if(quiz.Product__c != null && (mapOldQuizes == null || mapOldQuizes.get(quiz.Id).Product__c != quiz.Product__c)){
                
                //Check product alrady consist in set
                if(setSCIProductIds.contains(quiz.Product__c)){
                    
                    //Display error
                    quiz.Product__c.addError(Label.MKT_CheckProductError);
                }
            }
        }
    }
}