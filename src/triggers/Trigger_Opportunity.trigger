/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Opportunity
 *
 *  Created By      :
 *
 *  Created Date    :   01/24/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/
trigger Trigger_Opportunity on Opportunity (after update, before delete, before update, before insert) {
    
    //Check for Opportunity trigger flag
	if(!OpportunityTriggerHelper.execute_Opportunity_Trigger)
		return;
		
    //Check for request type
    if(trigger.isBefore && !OpportunityTriggerHelper.execute_Trigger_IsBefore){
        
        //Check for trigger event
        if( trigger.isInsert || trigger.isUpdate){
            
            //Call helper class's method to update Account Renewal Owner with the opportunity OwnerId
            OpportunityTriggerHelper.updateAccRenewalOwner(Trigger.new);

        }
        
        //Check for trigger event
        if(trigger.isUpdate){
            
            //Call helper class's method to validate the  No. of Elite Product field value
            OpportunityTriggerHelper.validateNoOfElietProduct(Trigger.new);
            
            //Call helper's class method
            OpportunityTriggerHelper.opportunityfuture(trigger.new,trigger.oldMap);
            
            //Call hellper class method to update product Info and SVS field on opportunity
            OpportunityTriggerHelper.validateProductInfoAndSVS(trigger.new);
        }
        
        //Set flag to true to stop recursive call
        OpportunityTriggerHelper.execute_Trigger_IsBefore = true;
    }

    //Check for request type
    if(trigger.isAfter && !OpportunityTriggerHelper.execute_Trigger_IsAfter){
        
        //Check for trigger event
        if(trigger.isUpdate){
        
            //Call helper class's method used to populate the values of contact
            OpportunityTriggerHelper.cloneOpportunity(Trigger.new, Trigger.oldMap);
            
            //Call helper class's method used to validate teh values in MKT_payment object
            OpportunityTriggerHelper.validateValuesInMKTPayment(Trigger.new, Trigger.oldMap);
            
            //Call helper class method to create/update new Asset and Entitlement records on opportunity according to there relation b/w opportunity
            //and OpportunityLineItem and Related Assets
            OpportunityTriggerHelper.createAssetAndEntitlement(Trigger.newMap, Trigger.oldMap);
        }
        
        //Set flag to true to stop recursive call
        OpportunityTriggerHelper.execute_Trigger_IsAfter = true;
    }
    //Check for request type
    if((trigger.isAfter || trigger.isBefore )&& ! OpportunityTriggerHelper.execute_Trigger_Is_Before_Ater){
        
        //Check the event type
        if(trigger.isUpdate || trigger.isDelete){
            
            //Call helper class's method used to create a new record on Deal Trans
            OpportunityTriggerHelper.validateDealTransOnOppLineItem(Trigger.new, Trigger.oldMap);
        }
        
        //Set flag to true to stop recursive call
        OpportunityTriggerHelper.execute_Trigger_Is_Before_Ater = true;
    }  
}