/**
 *  Description    :   Helper class for Trigger_Roaster trigger.
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
public with sharing class CourseTriggerHelper {
    
     //Boolean variable for Training Path trigger execution
    public static Boolean execute_TrainingPath_Trigger = true;
    
    /**
     *  @Description    :   This method is used to upadte the MKT total hour field value.
     *                      
     *  @args           :   List<lmscons__Training_Path__c>,Map<Id, lmscons__Training_Path__c>
     *
     *  @return         :   void
    **/
    public static void updateTotalHours(List<lmscons__Training_Path__c> newTrainingPaths,Map<Id, lmscons__Training_Path__c> mapOldTrainingPaths){
        
        //List to hold the training paths
        List<lmscons__Training_Path__c> trainingPaths = new List<lmscons__Training_Path__c>();
        
        //Loop through Training Path
        for(lmscons__Training_Path__c tP : newTrainingPaths){
            
            //Check the appropriate condition to fire trigger
            if(mapOldTrainingPaths == null || mapOldTrainingPaths.get(tP.Id).lmscons__Duration__c != tp.lmscons__Duration__c) {
                
                //Check for Duration
                if(tp.lmscons__Duration__c != null) {
                
                    //Variables to hold the value of duration after solving it
                    String totalHours = '';
                    
                    //variableto hold the value of duration
                    Decimal totalHoursDec = tP.lmscons__Duration__c;
                
                    //check the value of Duaraation(field)
                    if(totalHoursDec < 60){
                        
                        //Poulate the value 
                         totalHours = String.valueOf(totalHoursDec) + ' min';
                    } else{
                        
                        //Poulate the value
                        totalHours = String.valueOf(totalHoursDec.divide(60, 1, System.RoundingMode.UP)) + ' h';
                    }
                    
                    tP.MKT_Total_hours__c = totalHours;
                
                } else{
                
                    tP.MKT_Total_hours__c = null;
                }
            }
        }
    }
    /**
     *  @Description    :   This method is used to diaplay the error on Training Path Product if shopping cartItem consist the same Product Value
     *                      
     *  @args           :   List<lmscons__Training_Path__c>,Map<Id, lmscons__Training_Path__c>
     *
     *  @return         :   void
    **/
    public static void valiadteProduct(List<lmscons__Training_Path__c> newTrainingPaths, Map<Id,lmscons__Training_Path__c> mapOldTrainingPaths){
        
        //Set to hold the Product Id
        Set<Id> setTPProductIds = new Set<Id>();
        
        //Set to hold the productId of shopping cartItem
        Set<Id> setSCIProductIds = new Set<Id>();
        
        //Loop through Training Path
        for(lmscons__Training_Path__c tP: newTrainingPaths){
            
            //Check the appropriate condition to fire the trigger
            if(tP.Product__c != null && (mapOldTrainingPaths == null || mapOldTrainingPaths.get(tP.Id).Product__c != tP.Product__c)){
                
                //Add the value in set
                setTPProductIds.add(tP.Product__c);
            }
        }
        
        
        //Query through ShoppingCartItem
        for(kumocomm__ShoppingCartItem__c scItem : [Select Id, kumocomm__Product__c From kumocomm__ShoppingCartItem__c Where 
                                                            kumocomm__Product__c != null AND kumocomm__Status__c =: Constants.TRAINING_STATUS_IN_CART
                                                            AND kumocomm__Product__c IN : setTPProductIds]){
            
            //Add the value in Set
            setSCIProductIds.add(scItem.kumocomm__Product__c);                                              
        }
        
        //Loop through Training Path
        for(lmscons__Training_Path__c tP: newTrainingPaths){
            
            //Check the appropriate condition to fire the trigger
            if(tP.Product__c != null && (mapOldTrainingPaths == null || mapOldTrainingPaths.get(tP.Id).Product__c != tP.Product__c)){
                
                //Check product alrady consist in set
                if(setSCIProductIds.contains(tP.Product__c)){
                    
                    //Display error
                    tP.Product__c.addError(Label.MKT_CheckProductError);
                }
            }
        }
    }
}