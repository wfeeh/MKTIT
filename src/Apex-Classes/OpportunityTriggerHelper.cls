/**  
 *  Description    :   Helper class for Trigger_Opportunity trigger.
 *
 *  Created By     : 
 *
 *  Created Date   :  01/20/2014
 *
 *  Version        :  V_1.0
 *
 *  Revision Logs  :  V_1.0 - Created 
 *
 **/
public without sharing class OpportunityTriggerHelper {
	
	//Boolean variable to opportunity trigger execution
	public static Boolean execute_Opportunity_Trigger = true;
	public static Boolean execute_Trigger_IsBefore = false;
	public static Boolean execute_Trigger_IsAfter = false;
	public static Boolean execute_Trigger_Is_Before_Ater = false;
	
    /**
     * @Description  :  Method to clone the opportunity as well Contact Role,Opportunity Line Item and update the asset
     *
     * @args         :  List<Opportunity>, Map<Id,Opportunity>
     *
     * @return       :  void
     *
     **/
     public static void cloneOpportunity(List<Opportunity> newOpportunities, Map<Id,Opportunity> mapOldOpportunities ){
        
        //Set to hold oppportunity Ids
        Set<Id> oppIds = new Set<Id>();
        
        //List to hold opportunity
        List < Opportunity > oppList = new List < Opportunity > ();
        
        //Map to hold opportunity Id and new cloned opportunity list as value
        Map<Id, List<Opportunity>> mapOppIdAndClonedOpps = new Map<Id, List<Opportunity>>();
        
        //Variable to create dynamic SOQL string for Opportunity
        String oppQueryString = '';
        
        //Variable to create dynamic SOQL string for OpportunityLineItem
  		String oppLItemQueryString = '';
  		
        //Loop through opportunity
        for(Opportunity opp : newOpportunities){
            
            //check the condition of stage(field) value and type(field) value
            if(opp.Deal_Type__c != null && !Label.Deal_types.containsIgnorecase(opp.Deal_Type__c) 
            	&& opp.stageName == Constants.OPPORTUNITY_STAGENAME_CLOSED_WON && (opp.type == Constants.OPPORTUNITY_TYPE_NEW_BUSINESS
                	|| opp.type == Constants.OPPORTUNITY_TYPE_RENEWAL) && mapOldOpportunities.get(opp.id).StageName != opp.StageName
                    	&& mapOldOpportunities.get(opp.Id).recordtypeId != opp.recordtypeId) {
                            
            	//add the ids in set            
                oppIds.add(opp.Id);
        	}
        }
        
        //Loop through opprtunity to get all the fields
        for(String oppField : Opportunity.getSobjectType().getDescribe().fields.getMap().KeySet()) {
            
               //Add field in string to pass in dunamic SOQL
               oppQueryString += oppField + ',';
        }
        
        //List of opportunity going to update
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Dynamic SOQL to get all field detail of current opportunity
        for(Opportunity opportunity : DataBase.query('Select ' + oppQueryString + ' Account.Name From Opportunity Where Id IN : oppIds')){
           
            //Check the condition of field(Quarterly_Renewal__c)
            if(opportunity.Quarterly_Renewal__c != null && opportunity.type == Constants.OPPORTUNITY_TYPE_NEW_BUSINESS) {
            	
                //Variable date
                Date EndDate;
                
                //Integer variable to addmonth in new opportunity
                Integer closeDateMonth = 1;
                
                //iterate loop
                for (integer a = 0; a < 3; a++) {
    			
                    //Instance of opportunity
                    Opportunity opp  = new Opportunity();
                    
                    //Populate new Opportunity with existing opportunity field values using slaesforce standard clone functionality
                    opp = opportunity.clone(false,true);
                    
                    //call the utility class method to populate opportunity fileds
                    opp = Utility.clonOpportunityField(opp , opportunity);
                    
                    //Populate fields in clone opprtunity
                    opp.Quarterly_Renewal__c = string.valueOf(a + 2);
                    opp.Name = opportunity.Name + '-0' + (a + 2) + 'R';
                    opp.CloseDate = opportunity.CloseDate.addmonths(closeDateMonth * 3);
                    
                    //Check the field(Sub_End_Date__c) value
                    if (opp.Sub_End_Date__c != null) {
                        
                        //Populate the values
                        opp.CloseDate = EndDate != null ? EndDate : opportunity.Sub_End_Date__c;
                        opp.Plan_of_Record_Renewal_Date__c = opp.CloseDate;
                        opp.Sub_Start_Date__c = EndDate != null ? EndDate + 1 : opportunity.Sub_End_Date__c + 1;
                        EndDate = EndDate == null ? opportunity.Sub_End_Date__c.addMonths(3) : EndDate.addMonths(3);
                        opp.Sub_End_Date__c = EndDate;
                        
                    } else {
                        
                        opp.CloseDate = opportunity.CloseDate.addmonths(closeDateMonth * 3);
                    }
                    
                    //Check the field(Opportunity_ARR2012__c) value
                    if (opportunity.Opportunity_ARR2012__c != null)
                        opp.Previous_Year_ACV__c = opportunity.Opportunity_ARR2012__c / 4;
                    
                    //Check if map already contains old opportunity(Parent Opportunity) Id and add newly cloned opportunity in map's
                    //list corresponding to old opportunity id
                    if(mapOppIdAndClonedOpps.containsKey(opportunity.Id)) {
                    	mapOppIdAndClonedOpps.get(opportunity.Id).add(opp);
                    } else {
                    	mapOppIdAndClonedOpps.put(opportunity.Id, new List<Opportunity>{opp});
                    }
                    
                    //Increment in the closeDateMonth value
                    closeDateMonth++;
                   
                }
               
            } else if (opportunity.Quarterly_Renewal__c == null){
            	
            	//Instance of opportunity
                Opportunity opp1  = new Opportunity();
                
                //Populate new Opportunity with existing opportunity field values using slaesforce standard clone functionality
                opp1 = opportunity.clone(false,true);
                
                //call the utility class method to populate opportunity fileds
                opp1 = Utility.clonOpportunityField(opp1 , opportunity);
                
                //Check the condititon for Sub_End_Date__c(field) value
                if (opportunity.Sub_End_Date__c != null) {
                	
                	//poulate the field value
                    opp1.CloseDate = opportunity.Sub_End_Date__c;
                    opp1.Plan_of_Record_Renewal_Date__c = opp1.CloseDate;
                    opp1.Sub_Start_Date__c = opportunity.Sub_End_Date__c + 1;
                    opp1.Sub_End_Date__c = opportunity.Sub_End_Date__c.addDays(365);
                    
                } else {
                	
                    opp1.CloseDate = opportunity.CloseDate.adddays(365);
                }
                
                //Check the condition for AccountId
                if(opportunity.AccountID!=null){
                	
                	//Check the condition for Sub_End_Date__c(field)value
                	if (opportunity.Sub_End_Date__c != null)
						
						//Poulate the Name field value in new opportunity
                    	opp1.Name = opportunity.Account.Name +' - Renewal ' + opportunity.Sub_End_Date__c.Year();
               		else
                        opp1.Name = opportunity.Account.Name+ ' - Renewal ' + opportunity.closeDate.adddays(365).Year();
                
                }
                
                //check the condition for Opportunity_ARR2012__c(field) value
                if (opportunity.Opportunity_ARR2012__c != null) {
                	
                   //Poulate the Previous_Year_ACV__c field value in new opportunity
                    opp1.Previous_Year_ACV__c = opportunity.Opportunity_ARR2012__c;
                }
                
                //Check if map already contains old opportunity(Parent Opportunity) Id and add newly cloned opportunity in map's
                //list corresponding to old opportunity id
                if(mapOppIdAndClonedOpps.containsKey(opportunity.Id)) {
                	mapOppIdAndClonedOpps.get(opportunity.Id).add(opp1);
                } else {
                	mapOppIdAndClonedOpps.put(opportunity.Id, new List<Opportunity>{opp1});
                }
            }
            
            //Get Opportunity records for opportunity
            if(mapOppIdAndClonedOpps.containsKey(opportunity.Id))
            	opportunities.addAll(mapOppIdAndClonedOpps.get(opportunity.Id));
        }
        
        //Check for map sizee to insert cloned opportunities
        if (opportunities.size() > 0) 
            insert opportunities;
            
        //Use getDescribe method to get all field of OpportunityLineItem
 	    for(String oppLItemField : OpportunityLineItem.getSobjectType().getDescribe().fields.getMap().KeySet()) {

    		if(oppLItemField != 'TotalPrice')
	    		
	    		//Add field in string
	    		oppLItemQueryString += oppLItemField + ',';
  		}
  		
  		//Set to hold updated opportunity ids
  		Set<Id> setOppIds = new Set<Id>(); 
  		setOppIds.addAll(mapOppIdAndClonedOpps.keySet());
  		
        
        //SOQL string to Pass in Dynamic SOQL query on OpportunityLineItem
        String SOQL = 'Select ' + oppLItemQueryString + ' Opportunity.Quarterly_Renewal__c, Opportunity.Name, Pricebookentry.Product2.Name'
        			  + ' From OpportunityLineItem Where OpportunityId IN : setOppIds Order By OpportunityId';
        
        //Id variable to hold OpportunityLineItem's opportunity id
        Id oppId;
        
        //Intege variable to pass in OpportunityLineItem's 
        Integer counter = 1;
       
        
        //List of opportunity Line Item to insert
        List<OpportunityLineItem> oLineItems = new List<OpportunityLineItem>();
        
        //Loop through OpportunityLineItem related to updated opportunities
        for(OpportunityLineItem oLItem : DataBase.query(SOQL)) {
        	
        	//Check for opportunity line Item's Product family
        	if(oLItem.Product_Family__c != Constants.OPPORTUNITYLINEITEM_PRODUCT_SERVICES) {
        		
        		//Check for key in map
        		if(mapOppIdAndClonedOpps.containsKey(oLItem.OpportunityId)) {
        			
        			//Check for opportunity Id
        			if(oppId != null && oppId != oLItem.OpportunityId) {
        				
        				//Reset Integer counter
        				counter = 1;
        			}
        			
        			//Assign OpportunityLineItem opportunityId in variable
        			oppId = oLItem.OpportunityId;
        			
        			//Loop through new inserted opportunities to clone OpportunityLineItem for each new oppportunity
        			for(Opportunity opp : mapOppIdAndClonedOpps.get(oLItem.OpportunityId)) {
        				
        				//Instance of OpportunityLineItem
        				OpportunityLineItem oLineItem = new OpportunityLineItem();
        				
        				//Populate new Opportunity with existing opportunity field values using slaesforce standard clone functionality
                		oLineItem = oLItem.clone(false,true);
        				
        				//Assign the new values in cloned oppportunity
        				oLineItem.OpportunityId = opp.Id;
        				oLineItem.ServiceDate = oLItem.ServiceEndDate__c;
                		oLineItem.OLI_ID__C = oLItem.ID;
                		oLineItem.Prior_OLI_Name__c = oLItem.pricebookentry.Product2.Name + ' for ' + oLItem.Opportunity.Name;
                		
                		//Check the condition for Quarterly_Renewal__c(field)and populate teh values
                		if (oLItem.Opportunity.Quarterly_Renewal__c == null && oLItem.ServiceEndDate__c != null)
                    		oLineItem.ServiceEndDate__c = oLItem.ServiceEndDate__c.addDays(365);
                    		
                		else if (oLItem.Opportunity.Quarterly_Renewal__c != null && oLItem.ServiceEndDate__c != null)
                    		oLineItem.ServiceEndDate__c = oLItem.ServiceEndDate__c.addDays(counter * 90);
        				
        				//Add in List
        				oLineItems.add(oLineItem);
        			}
        			
        			//Incrise counter
        			counter++;
        		}
        	}
        }
        
        //Check for List size
        if(oLineItems.size() > 0)
        	insert oLineItems;
		
		//String to hold OpportunityContactRole's field
		String oppConRoleFields = '';
		
		//Use getDescribe method to get all field of OpportunityContactRole
 	    for(String oppConField : OpportunityContactRole.getSobjectType().getDescribe().fields.getMap().KeySet()) {
	
	    		//Add field in string
	    		oppConRoleFields += oppConField + ',';
  		}
  		
  		
        //SOQL string to Pass in Dynamic SOQL query on OpportunityLineItem
        String oConRoleSOQL = 'Select ' + oppConRoleFields.removeEnd(',') + ' From OpportunityContactRole Where OpportunityId IN : setOppIds Order By OpportunityId';
        
        //List of opportunity Line Item to insert
        List<OpportunityContactRole> oConRoles = new List<OpportunityContactRole>();
        
        //Loop through OpportunityLineItem related to updated opportunities
        for(OpportunityContactRole oConRole : DataBase.query(oConRoleSOQL)) {
			
			//Check for map
			if(mapOppIdAndClonedOpps.containsKey(oConRole.OpportunityId)) {
				
				//Loop through Cloned opportunities
				for(Opportunity opp : mapOppIdAndClonedOpps.get(oConRole.OpportunityId)) {
				
					//Instance of OppportunityContactRole
					OpportunityContactRole oCRole = new OpportunityContactRole();
					
					//Populate new Opportunity with existing opportunity field values using slaesforce standard clone functionality
                	oCRole = oConRole.clone(false,true);
                	
                	//Populate the values of opportunity id in new cloned opportunity
                	oCRole.OpportunityId = opp.Id;
                	 
		            //Add the opportunity in List
		            oConRoles.add(oCRole);
				}
			}
		}
		
		//Check the size of list
		if(oConRoles.size()>0)
			insert oConRoles;
		
		//List to update the asset
		List<Asset> assets = new List<Asset>();	
		
		//Loop through Related Asset rcords
		for(Asset asst : [SELECT Id, Name, Installdate, UsageEndDate, latest_opportunity__c, Opportunity__c FROM Asset 
								 where latest_opportunity__c IN : mapOppIdAndClonedOpps.keySet()]) {
		
			//Check for map
			if(mapOppIdAndClonedOpps.containsKey(asst.latest_opportunity__c)) {
				
				//Check for Sub Date
				if (mapOppIdAndClonedOpps.get(asst.latest_opportunity__c)[0].Sub_End_Date__c != null)
                    asst.usageEndDate = mapOppIdAndClonedOpps.get(asst.latest_opportunity__c)[0].Sub_End_Date__c;
                   
                //Check for Prior opportunity
				if(mapOppIdAndClonedOpps.get(asst.latest_opportunity__c)[0].Prior_opportunity__c != null)
					asst.Opportunity__c = mapOppIdAndClonedOpps.get(asst.latest_opportunity__c)[0].Prior_opportunity__c;
				
				//Update latest opportunity
				asst.Latest_Opportunity__c = mapOppIdAndClonedOpps.get(asst.latest_opportunity__c)[0].Id;
				 
				//add the asst in list
				assets.add(asst);
			}
		}
		
		//Check the size of list
		if(assets.size() > 0)
			update assets;
   }
   /**
    * @Description  :  Method to create a Deal Transaction Audit Log and Deal Transaction object and also to delete when appropriate condition meet.
    *
    * @args         :  List<Opportunity>, Map<Id,Opportunity>
    *
    * @return       :  void
    *
    **/
    public static void validateDealTransOnOppLineItem(List<Opportunity> newOpps, Map<Id,Opportunity> mapOldOpps){
    	
    	//Set to hold opportunity id
    	Set<Id> setOppIds = new Set<Id>();
    
    	//Set to hold the opportuny Ids which is used for delete
    	Set<Id> setOppDelIds =new Set<Id>();
    	
    	//Set to hold Sales Order Item's Ids related to OpportunityLineItem
    	Set<Id> setOrderItems = new Set<Id>();
    	
    	//Set to hold OpportunityLineItem Id
    	Set<Id> setOppLItemIds = new Set<Id>();
    	
    	//List to upsert the object Deal_Transaction_Audit_Log__c and Deal_Transaction__c
    	List<Deal_Transaction_Audit_Log__c> listDealTransAudit = new List<Deal_Transaction_Audit_Log__c>();
    	List<Deal_Transaction__c> listDealTrans = new List<Deal_Transaction__c>();
    	
    	
    	//Maps to get OpportunityLineItem ids with Deal Transaction Audit Log and Deal Transaction records
        Map<Id, Deal_Transaction_Audit_Log__c> mapExistingDTransAudits = new Map<Id, Deal_Transaction_Audit_Log__c>();
        Map<Id, Deal_Transaction__c> mapExistingDealTrans = new Map<Id, Deal_Transaction__c>();
    	
    	//Loop through Opportunity if update than loop through new opportunity list Or if delete than loop through old values
    	for(Opportunity opp : Trigger.isUpdate ? newOpps : mapOldOpps.values()){
    		
    		//Check the appropriate condition to fire the trigger
    		if(Trigger.isUpdate && opp.Type == Constants.OPPORTUNITY_TYPE_NEW_BUSINESS && opp.StageName == Constants.OPPORTUNITY_STAGE_CLOSED_WON && 
    																		opp.StageName != mapOldOpps.get(opp.id).StageName){
    			
    							
				//add the opportunity id in Set
    			setOppIds.add(opp.Id);
    															
    		} else if(Trigger.isUpdate && opp.Type == Constants.OPPORTUNITY_TYPE_NEW_BUSINESS && opp.StageName != mapOldOpps.get(opp.id).StageName
    					&& mapOldOpps.get(opp.id).StageName == Constants.OPPORTUNITY_STAGE_CLOSED_WON) {
    			
    			//Add values in set
    			setOppDelIds.add(opp.Id);
    		
    		//In case of delete 
    		} else if(Trigger.isDelete && opp.Type == Constants.OPPORTUNITY_TYPE_NEW_BUSINESS && opp.StageName == Constants.OPPORTUNITY_STAGE_CLOSED_WON) {
    			
    			//Add values in set
    			setOppDelIds.add(opp.Id);
    		} 
    	}
    	
    	//Query through Sales Order Item to get related Opp Product Id 
    	for(Sales_Order_Item__c  salesOrder : [Select Id, Opp_Product_id__c, Sales_Order__c, Sales_Order__r.Opportunity__c from Sales_Order_Item__c 
    											Where Sales_Order__r.Opportunity__c != null AND Sales_Order__r.Opportunity__c IN : setOppIds]){
    		
    		//check the value for Opportuity Product
    		if(salesOrder.Opp_Product_id__c != null && salesOrder.Opp_Product_id__c instanceof Id){
    			
    			//Add the Sales order item Id in Set	
    			setOrderItems.add(salesOrder.Opp_Product_id__c);
    		}
    	}
    	
		//Populate map by calling uttility class's methods
    	mapExistingDTransAudits = Utility.getExistingOppTransactionRecords(setOrderItems);
    	mapExistingDealTrans = Utility.getExistingDealTrans(setOrderItems);
    	
    	//List of OpportunityLineItems
    	List<OpportunityLineItem> oppLineItems = [SELECT Id, OpportunityId, Opportunity.AccountId, Opportunity.Type, ARR__c, Opportunity.CloseDate, 
		            									Opportunity.Contact_Database_Size__c, Discount, Product_Edition__c, ServiceEndDate__c, ListPrice, 
		           									    PricebookEntry.Product2Id, Quantity, UnitPrice, Product_Start_Date__c, Months__c, TotalPrice, 
		           									    Users__c, Upgrade_Type__c, Prior_Opportunity_Id__c, OLI_ID__c FROM OpportunityLineItem 
		         									     WHERE Id IN :setOrderItems];
		 
		//Query through opportunity line item
		for(OpportunityLineItem oppLineItem :[Select Id from OpportunityLineItem where OpportunityId IN : setOppDelIds]){
			
            //Add values in set
            setOppLItemIds.add(oppLineItem.Id);
            
        }
       
		//Query through Deal Transaction Audit Log to delele
		List<Deal_Transaction_Audit_Log__c> delDealTransAuditLog = [SELECT Id, Name, Opportunity_Line_Item_Id__c, RecordType.DeveloperName 
																		   FROM Deal_Transaction_Audit_Log__c
        											    				   WHERE  Opportunity_Line_Item_Id__c IN : setOppLItemIds
        											    				   AND RecordType.DeveloperName =: Constants.RECORDTYPE_DEVELOPERNAME_DTO];
        
        //Query through Deal Transaction to delete											    				   
        List<Deal_Transaction__c> delDealTrans = [SELECT Id from Deal_Transaction__c WHERE Opportunity_Line_Item_Id__c IN : setOppLItemIds];
       
    	//Loop through OpportunityLineItem
    	for(OpportunityLineItem oppLineItem : oppLineItems){
       
        	//Instance of Deal Transaction Audit Log
     		Deal_Transaction_Audit_Log__c opportunityTransaction = new Deal_Transaction_Audit_Log__c();
     		
     		//Call utility class method to populate values in fields of Deal_Transaction_Audit_Log__c
     		opportunityTransaction = Utility.createDealTransAuditLog(oppLineItem);
     		
     		//Check value in map if map contains OpportunityLineItem than update exsting Deal Transaction Audit Log other than insert new record 
     		if(mapExistingDTransAudits.containsKey(oppLineItem.Id)) {
     			opportunityTransaction.Id = mapExistingDTransAudits.get(oppLineItem.Id).Id;
     		}
     		
     		//Add the instance of Deal_Transaction_Audit_Log__c in list to upsert
     		listDealTransAudit.add(opportunityTransaction);
     		
     		//Instance of Deal_Transaction__c
     		Deal_Transaction__c opportunityTrans = new Deal_Transaction__c();
     		
     		//Call utility class method to populate values in fields of Deal_Transaction_Audit_Log__c
     		opportunityTrans = Utility.createDealTrans(oppLineItem);
     		
     		//Check value in map if map contains OpportunityLineItem than update exsting Deal Transaction other than insert new record
     		if(mapExistingDealTrans.containsKey(oppLineItem.Id)) {
     			opportunityTrans.Id = mapExistingDealTrans.get(oppLineItem.Id).Id;
     		}
    
     		//List to add instance of Deal_Transaction__c to upsert
     		listDealTrans.add(opportunityTrans);
        }
        
        //Check the size list
        if(delDealTransAuditLog.size() > 0)
			delete delDealTransAuditLog;
		
		//Check the size list
		if(delDealTrans.size() > 0)
			delete delDealTrans;
			
        //use try catch block to usert the list and in case of error show appropriate message to user
        try {
        	
	    	//Check the size of list and upsert
	    	if(listDealTransAudit.size()>0)
	    		upsert listDealTransAudit;
        	
        	//Check the size of list and upsert
        	if(listDealTrans.size() > 0)
        		upsert listDealTrans;  
        		
        } catch(exception e){
        	for(OpportunityLineItem oppLineItem : oppLineItems){
                oppLineItem.addError(e.getMessage());
            }
        }   
    }
    
	/**
     * @Description  : Method to validate Eliet Product on opportunity on the basics of ProductCode on PriceBookEntry related to opportunityLineItem
     *
     * @args         :  List<Opportunity>
     *
     * @return       :  void
     * 
     **/
	public static void validateNoOfElietProduct(List<Opportunity> newOpportunities){
    	
    	//Map to get Opportunity Line Item  Id  with record
    	Map<Id, List<OpportunityLineItem>> mapOppLineItem = new Map<Id, List<OpportunityLineItem>>();
    	
    	//set to hold the Custom setting
		Set<String> setConfig = Utility.ConfigManagerParameterValue(Constants.CONFIG_MANAGER_PARAMETER_KEY_OPPORTUNITYPRICEBOOKENTRYPRODUCTCODE);
		
    	//Loop through Opportunity Line Item
    	for(OpportunityLineItem oppItem : [Select Id, OpportunityId, PriceBookEntry.ProductCode from OpportunityLineItem 
    																		Where OpportunityId IN :newOpportunities]){
    		
    		//Check the condition of map conatins the value of opportunty Id or not ans assign it wth the values
    		if(mapOppLineItem.containsKey(oppItem.OpportunityId)){
    			
    			 mapOppLineItem.get(oppItem.OpportunityId).add(oppItem);
    		} else {
    			mapOppLineItem.put(oppItem.OpportunityId, new List<OpportunityLineItem>{oppItem});
    		}
    	}
    	
    	//Loop through Opportunity to update 
    	for(Opportunity opp : newOpportunities){
    		 
    		 //Integer variable
    		 Integer numberOfEliteProds = 0;
    		 
    		 //Check the opportunity Id in Map
    		 if(mapOppLineItem.containsKey(opp.Id)){
    		 	 
    		 	//Query through OpportunityLineItem
    		 	for(OpportunityLineItem oppLineItem : mapOppLineItem.get(opp.Id)){
    		 	
    		 		//Check OpportunityLineItem's product code in custom setting if custom setting contains product code update Elite Product on opportunity
    		    	if(setConfig.contains(oppLineItem.PriceBookEntry.ProductCode)){
    		    		
    		    		//populate value in variable to assign in Elite Product
    		    		numberOfEliteProds = numberOfEliteProds + 1;
    		    	}
    		 	}
    		 }
    		 
    		 //Assign the new value in filed Elite Product
    		 opp.Number_of_Elite_Products__c = numberOfEliteProds;
    	}
    }
    
	/**
     * @Description  :  Method to create record 'MKT Payment' record according to opportunity, related opportuntyLineItems 
     *					and 'MKT TranslationTable' on opportunityLineItem 
     *
     * @args         :  List<Opportunity>, Map<Id,Opportunity>
     *
     * @return       :  void
     * 
     **/
    public static void validateValuesInMKTPayment(List<Opportunity> newOpportunities, Map<Id,Opportunity> mapOldOpportunities){
    	 
    	//Set to hold Opportunity Id
    	Set<Id> setOppIds = new Set<Id>(); 
    	
    	//Map to hold MKT TranslationTable corresponding to OpportunityLineItem
    	Map<Id, List<MKT_TranslationTable__c>> mapProductIdAndMKTTTabels = new Map<Id,List<MKT_TranslationTable__c>>();
    	
    	//Set to hold product Ids
    	Set<Id> setProductIds = new Set<Id>();
    	
    	//Loop through opportunity
    	for(Opportunity opp : newOpportunities){
    		
    		//Check the appropriate condition to fire the trigger
    		if(opp.StageName == Constants.OPPORTUNITY_STAGE_CLOSED_WON && opp.SFDC_Oppty_Recordtype__c == Constants.SFDC_OPPTY_RECORDTYPE_CLOSED_WON
    				 && opp.Forecast_Category__c == Constants.OPPORTUNITY_STAGE_CLOSED_WON 
    				 &&(mapOldOpportunities.get(opp.Id).StageName != Constants.OPPORTUNITY_STAGE_CLOSED_WON )){
    				
				//add values in set
				setOppIds.add(opp.Id);
    		}
    	}
    	
    	//List of OpportunityLineItems
    	List<OpportunityLineItem> oppLineItems = [SELECT Id, OpportunityId, Quantity, Opportunity.MKT_User__c, Opportunity.AccountId,
    													 Opportunity.MKT_Transaction__c, Opportunity.Name, Opportunity.CreatedById,
    													 PricebookEntry.ProductCode, PricebookEntry.Name, PricebookEntry.Product2Id
    												FROM OpportunityLineItem WHERE PricebookEntry.Product2Id != null And OpportunityId IN : setOppIds];
    	
    	//Loop through OpportunityLineItem
    	for (OpportunityLineItem opportunityLItem : oppLineItems) {
    		
    		//Add values in set
    		setProductIds.add(opportunityLItem.PricebookEntry.Product2Id);    
		}
    	
    	//Loop through MKT_TranslationTable__c
    	for(MKT_TranslationTable__c mKTTTable : [SELECT ChildProduct__c, ParentProduct__c, Total_Seats__c FROM MKT_TranslationTable__c 
    													WHERE ParentProduct__c IN : setProductIds AND ParentProduct__c != null]) {
    														
    		//Check for map if it already contains product as key
    		if(mapProductIdAndMKTTTabels.containsKey(mKTTTable.ParentProduct__c)) {
    			
    			//Add MKT Translation Table in map
    			mapProductIdAndMKTTTabels.get(mKTTTable.ParentProduct__c).add(mKTTTable);
    		} else {
    			
    			//Populate map with values
    			mapProductIdAndMKTTTabels.put(mKTTTable.ParentProduct__c, new List<MKT_TranslationTable__c>{mKTTTable});
    		}
    	}
    	
    	//List of MKT Payment
    	List<MKT_Payment__c> mKTPayment = new List<MKT_Payment__c>();
    	
    	//Loop through OpportunityLineItem
    	for (OpportunityLineItem opportunityLItem : oppLineItems) {
    		
    		//Check if map already contains OpportunityLineItem's product
    		if(mapProductIdAndMKTTTabels.containsKey(opportunityLItem.PricebookEntry.Product2Id)) {
    				
    			//Check the condition for values
    			if(opportunityLItem.Opportunity.MKT_Transaction__c == null) {
	    	
    				//Loop through 
	    			for(MKT_TranslationTable__c mKTTTable : mapProductIdAndMKTTTabels.get(opportunityLItem.PricebookEntry.Product2Id)) {
	    				
	    				//Instance of MKT Payment
	        			MKT_Payment__c payment = new MKT_Payment__c();
	        			
	    				//Populate fields with values
	    				payment.Product__c = mKTTTable.ChildProduct__c;
	    				payment.User__c = (opportunityLItem.Opportunity.MKT_User__c != null) ? opportunityLItem.Opportunity.MKT_User__c : opportunityLItem.Opportunity.CreatedById;
	    				payment.MKT_Opportunity__c = opportunityLItem.OpportunityId;
	    				
	    				//Check for opportunityLItem's Quaantity and MKT Translation Table's Total Seats
	    				//if(opportunityLItem.Quantity != null && mKTTTable.Total_Seats__c != null)
	    				payment.Total_Seats__c = opportunityLItem.Quantity * mKTTTable.Total_Seats__c;

	    				//Check the accountId value and populate the value of accountId
	    				if(opportunityLItem.Opportunity.AccountId != null)
	    					payment.Account__c = opportunityLItem.Opportunity.AccountId;
	    				
	    				//Add payment in list	
	    				mKTPayment.add(payment);
	    				
	    			}
	    			continue;
				}
    		} 
    		
    		//Instance of MKT Payment
			MKT_Payment__c paymentMKT = new MKT_Payment__c();
			
			//Populate field with values
			paymentMKT.Product__c = opportunityLItem.PricebookEntry.Product2Id;
			paymentMKT.User__c = (opportunityLItem.Opportunity.MKT_User__c != null) ? opportunityLItem.Opportunity.MKT_User__c : opportunityLItem.Opportunity.CreatedById;
			paymentMKT.MKT_Opportunity__c = opportunityLItem.OpportunityId;
			paymentMKT.Total_Seats__c = opportunityLItem.Quantity;
			
			//Check the accountId on opportunity and assign assount Id on MKT Payment
    		if(opportunityLItem.Opportunity.AccountId != null)
    			paymentMKT.Account__c = opportunityLItem.Opportunity.AccountId;
			
			//Add pamentMKT inn list
			mKTPayment.add(paymentMKT);
    	}
    	 
    	//Check the size of list and insert the list
    	if(mKTPayment.size() > 0)
    		insert mKTPayment;
    		
    }
   
   /**
    * @Description  :  Method to send HTTP callout request on Opportunity and send status email to user Or 
    *				   update 'Owner Role Mapping' with opportunity owner if opportunity is closed
    *
    * @args         :  List<Opportunity>, Map<Id,Opportunity>
    *
    * @return       :  void
    * 
    **/
    public static void opportunityfuture(List<Opportunity> newOpportunities, Map<Id,Opportunity> mapOldOpportunities){
	
    	//List to hold the opportunity
    	List<Opportunity> opportunities = new List<Opportunity>();
		
		//Get Id of closed Won record type on opportunity
		ID closedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
		
    	//Loop through opportunity
    	for(Opportunity opp : newOpportunities ){
    		
    		//Check for IsClosed field on opportunity
    		if(opp.IsClosed != mapOldOpportunities.get(opp.id).IsClosed && opp.IsClosed == TRUE){
    			
    			//Assign the values of ownerId in Owner_Role_Mapping__c(field)
    			opp.Owner_Role_Mapping__c = opp.OwnerId;
    		}
    		
    		//Check the appropriate condition to fire the trigger
    		if(opp.Processed__c != true && mapOldOpportunities.get(opp.id).RecordTypeId != opp.RecordTypeId
    			 && opp.RecordTypeId  == closedWonId && opp.stagename == Constants.OPPORTUNITY_STAGE_CLOSED_WON && opp.Type == Constants.OPPORTUNITY_TYPE_NEW_BUSINESS ){
    			   	
    			//Add id in set
    			opportunities.add(opp);
   
    			//populate the field value
    			opp.processed__c = true;
    			
    		}
    	}
    	
    	//Check the size of list
    	if(opportunities.Size() > 0) {
    		
    		//Pass opportunities in http callout class's method
    		OpportunityAutoProvisioning.processOpportunities(opportunities);
    	}
    }

   /**
    * @Description  :  Method to update Account Renewals Owner(field) with the Opportunity OwnerId 
    *
    * @args         :  List<Opportunity>
    *
    * @return       :  void
    * 
    **/
    public static void updateAccRenewalOwner(List<Opportunity> newOpportunities){
    	
    	//Map to store account Id as key and opportunity Owner Id as value to update account's Renewals Owner
    	Map<Id,Id> mapAccIdsAndOppOwner = new Map<Id,Id>();
    	
    	//List to update Account
    	List<Account> accounts = new List<Account>();
    	
    	//Loop through Opportunity
    	for(Opportunity opp : newOpportunities){
    		
    		//Check the appropriate condition to fire the trigger
    		if(opp.AccountId != null && opp.Type == Constants.OPPORTUNITY_TYPE_RENEWAL  && opp.OwnerId != opp.Renewals_Owner_Id__c){
    			
    			//add the values in set
    			mapAccIdsAndOppOwner.put(opp.AccountId, opp.OwnerId);
    		}
    	}
    
    	//Loop through Account
		for(Account acc : [Select Id, Renewals_Owner__c from Account Where Id IN : mapAccIdsAndOppOwner.keySet() AND Renewals_Owner__c != null]){

			//Check accountId in map
			if(mapAccIdsAndOppOwner.containsKey(acc.Id) && acc.Renewals_Owner__c != mapAccIdsAndOppOwner.get(acc.Id)){
			
				//Populate the OwnerId value in Renewals Owner(field)
            	acc.Renewals_Owner__c = mapAccIdsAndOppOwner.get(acc.Id);
            	
            	//add values of account in list
            	accounts.add(acc);
			}
		}
		
		//Check for list size and update the list
		if(accounts.size() > 0)
			update accounts; 
    }
   /**
    * @Description  :  Method to update Product Info and Product SVS field based on opportunityLineItem  
    *
    * @args         :  List<Opportunity>
    *
    * @return       :  void
    * 
    **/
    public static void validateProductInfoAndSVS(List<Opportunity> newOpportunities){
    	
    	//Set to hold opportunity id
    	Set<Id> setOppIds = new Set<Id>();
    	
    	//Map to hold list of string corrresponding to opportunity Id to update Product_Info__c and Product_SVS__c field on opportunity
    	Map<Id,String> mapOppIdsAndProductInfo = new Map<Id,string>();
     	Map<Id,String> mapOppIdsAndProductSVS = new Map<Id,string>();
    	
    	//Get the recordTypeId
    	ID closedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
    	
    	//Loop through opportunity
    	for(Opportunity opp : newOpportunities){
    		
    		//Check the value of RecordTypeId of opportunity
        	if(opp.RecordTypeId == closedWonId)
        		
        		//Add the values opportunity Id in set
        		setOppIds.add(opp.id);
    	}
    	
    	//Query through OpportunityLineItem
    	for(OpportunityLineItem oppLItem : [Select Id, PricebookEntry.ProductCode, Product_Family__c, PricebookEntry.Product2.Family,
    											   PricebookEntry.Name, UnitPrice, Quantity, OpportunityId, Discount, TotalPrice, Geography__c,
    											   Rev_Rec_Template__c, MLM_Edition__c From OpportunityLineitem 
    										Where OpportunityId IN : setOppIds order by createddate]){
    		
    		//Check for OpportunityLineItem's Prodduct
    		if(oppLItem.Product_Family__c != null && oppLItem.Product_Family__c == Constants.OPPORTUNITYLINEITEM_PRODUCT_SERVICES 
    			&& oppLItem.PricebookEntryId != null && oppLItem.PricebookEntry.ProductCode != null) {
    		
	    		//Check opportunity Id in map
	    		if(mapOppIdsAndProductSVS.containsKey(oppLItem.OpportunityId)) {
	    			
	    			//String to hold oppportunity Product Info
	    			String productSVS =  mapOppIdsAndProductSVS.get(oppLItem.OpportunityId) + '|' + oppLItem.PricebookEntry.ProductCode;
	    			
	    			//Populate map with values
	    			mapOppIdsAndProductSVS.put(oppLItem.OpportunityId, productSVS);
	    		} else {
	    			
	    			//Populate map with values
	    			mapOppIdsAndProductSVS.put(oppLItem.OpportunityId, oppLItem.PricebookEntry.ProductCode);
	    		}
    		}
    		
    		//Check for PricebookEntry
    		if(oppLItem.PricebookEntryId != null && oppLItem.PricebookEntry.Name != null && oppLItem.Product_Family__c != null) { 
    		
	    		//Check for opportunity
	    		String productInfo = ' | ' + oppLItem.PricebookEntry.Name+' | '+ oppLItem.Product_Family__c + ' | ';	
	    		
	    		//Check if map contains opportunity Id
	    		if(mapOppIdsAndProductInfo.containsKey(oppLItem.OpportunityId)) {
	    			
	    			//String to put map as value
	    			String proInfo = mapOppIdsAndProductInfo.get(oppLItem.OpportunityId) + '\n' + productInfo;
	    			
	    			//Populate map with values
	    			mapOppIdsAndProductInfo.put(oppLItem.OpportunityId, proInfo);
	    		} else {
	    			
	    			//Populate map with values
	    			mapOppIdsAndProductInfo.put(oppLItem.OpportunityId, productInfo);
	    		}
    		}								
    	}
    	
    	//Loop through opportunity
    	for(Opportunity opp : newOpportunities){
    		
    		//Check the value of RecordTypeId of opportunity
        	if(opp.RecordTypeId == closedWonId) {
        		
        		//Check if map contains key
        		if(mapOppIdsAndProductInfo.containsKey(opp.Id)) {
        			
        			//Update Product Info 
        			opp.Product_Info__c = mapOppIdsAndProductInfo.get(opp.Id);
        		}
        		
        		//Check for Product SVS
        		if(mapOppIdsAndProductSVS.containsKey(opp.Id)) {
        			
        			//Update Product SVS
        			opp.Product_SVS__c = mapOppIdsAndProductSVS.get(opp.Id);
        		}
        	}
    	}
    }
    
    /**
     *	@Description	:	Method to create/update Asset and Entitlement records
     *	
     *	@args			:	Map<Id, Opportunity>, Map<Id,Opportunity>
     *
     *	@return			:	void
     *
     **/
	public static void createAssetAndEntitlement(Map<Id, Opportunity> mapnewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
		
		//Set to hold opportunity Ids
		Set<Id> setOppIds = new Set<Id>();
		
		//Set to hold Asset and Account Ids
		Set<Id> setAssetIds = new Set<Id>();
		Set<Id> setAccountIds = new Set<Id>();
		
		//Map to hold list of Asset corresponding to opportunity Id
		Map<Id, List<Asset>> mapOppIdAndAssets = new Map<Id, List<Asset>>();
		Map<Id, Id> mapOppIdAndAssetId = new Map<Id, Id>();
		
		//Map to hold Entitlement records corresponding to opportunty OR Asset
		Map<String, List<Entitlement>> mapOppIdsAndEntitlements = new Map<String, List<Entitlement>>();
		Map<Id, Entitlement> mapAssetIdsAndEntitlements = new Map<Id, Entitlement>();
		Map<Id, Entitlement> mapOppIdAndEntitlement = new Map<Id, Entitlement>();
		
		//Loop through opportunity
		for(Opportunity opp : [Select Id, Name, StageName, AccountId, Latest_Payment_Date__c,
							          (Select Id, Related_Asset__c From OpportunityLineItems Where Related_Asset__c != null LIMIT 200)
							   From Opportunity Where Id IN : mapnewOpportunities.keySet()]) {
			
			//Check the appropriate condition to fire the trigger
			if(opp.StageName == Constants.OPPORTUNITY_STAGE_CLOSED_WON && opp.StageName != mapOldOpportunities.get(opp.Id).StageName
				&& opp.Latest_Payment_Date__c != null && opp.Latest_Payment_Date__c == mapOldOpportunities.get(opp.Id).Latest_Payment_Date__c) {
					
				//Populate set with values
				setOppIds.add(opp.Id);
				
				//Check for Account Id
				if(opp.AccountId != null)
					setAccountIds.add(opp.AccountId);
				
				//Check for Related List size
				if(opp.OpportunityLineItems.size() > 0) {
					
					//Loop through OpportunityLineItem
					for(OpportunityLineItem oppLineItem : opp.OpportunityLineItems) {
						
						if(oppLineItem.Related_Asset__c != null){
							
							//Populate set with values
							setAssetIds.add(oppLineItem.Related_Asset__c);
						}
					}
				}
			} 
		}
		
		//Query through Entitlement
		for(Entitlement entitlement : [SELECT Id, Name, StartDate, EndDate, BusinessHoursId, SlaProcessId, Product_ID__c, AccountId, AssetId, Type, 
											  Asset.Opportunity__c, Support_Region__c From Entitlement where (Asset.Opportunity__c IN : setOppIds 
											  AND Asset.Purpose__c =: Constants.ASSET_PURPOSE_PRODUCTION 
											  AND Asset.Asset_Type__c =: Constants.PRODUCT_CONVERTTO_SUBSCRIPTION AND AccountId IN : setAccountIds) 
											  OR AssetId IN : setAssetIds]) {
		
			//Check for Porduct Id
			if(entitlement.Product_ID__c != null && entitlement.Product_ID__c != '' && entitlement.Product_ID__c instanceof Id
			&& entitlement.Asset != null && entitlement.Asset.Opportunity__c != null ) {
				
				//Unique Key
				String uniqueKey = entitlement.Asset.Opportunity__c + '-' + entitlement.Product_ID__c;
				
				//Check if map contains unique Key
				if(mapOppIdsAndEntitlements.containsKey(uniqueKey)) {
					
					//Add new entitlement records in map
					mapOppIdsAndEntitlements.get(uniqueKey).add(entitlement);
				} else {
					
					//Populate map with value
					mapOppIdsAndEntitlements.put(uniqueKey, new List<Entitlement> {entitlement});
				}
			}
			
			//Check for Product Id
			if((entitlement.Product_ID__c == null || entitlement.Product_ID__c == '') && setOppIds.contains(entitlement.Asset.Opportunity__c)) {
				
				//Populate map with value
				if(!mapOppIdAndEntitlement.containsKey(entitlement.Asset.Opportunity__c))
					mapOppIdAndEntitlement.put(entitlement.Asset.Opportunity__c, entitlement);
			}
			//Check for Asset Id in map
			if(!mapAssetIdsAndEntitlements.containsKey(entitlement.AssetId)) {
				
				//Populate map with values
				mapAssetIdsAndEntitlements.put(entitlement.AssetId, entitlement);
			}	
		} 
		
		//Query through Asset related to opportunity
		for(Asset asst : [Select Id, Name, Product2Id, Parent_Instance__c, Opportunity__c, Parent_Instance__r.Asset_Type__c, Purpose__c,
								 Asset_Type__c, Quantity From Asset	Where Opportunity__c IN : setOppIds]) {
			
			//Check if map already contains opportunity Id
			if(mapOppIdAndAssets.containsKey(asst.Opportunity__c)) {
				
				//Add asset in map corresponding to that opportunty
				mapOppIdAndAssets.get(asst.Opportunity__c).add(asst);
			} else {
				
				//Populate valesin map
				mapOppIdAndAssets.put(asst.Opportunity__c, new List<Asset>{asst});
			}
			
			//Check for Assert Purpose and Asset Type
			if(asst.Purpose__c == Constants.ASSET_PURPOSE_PRODUCTION && asst.Asset_Type__c == Constants.PRODUCT_CONVERTTO_SUBSCRIPTION
				&& !mapOppIdAndAssetId.containsKey(asst.Opportunity__c)) {
					
					//Populate map with values
					mapOppIdAndAssetId.put(asst.Opportunity__c, asst.Id);
			}
		}
		
		//List of Asset
		List<Asset> assets = new List<Asset>();
		
		//Set of Assets
		Set<Asset> setAssets = new Set<Asset>();
		
		//List of Entitlement
		List<Entitlement> entitlements = new List<Entitlement>();
		
		//Set of Entitlement
		Set<Entitlement> setEntitlements = new Set<Entitlement>();
		
		//Query through OpportunityLineItem records
		for(OpportunityLineItem oppLItem : [Select Id, PricebookEntryId , PricebookEntry.Product2Id, PricebookEntry.Product2.ConvertTo__c,
												   PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name, PricebookEntry.Product2.Family,
												   PricebookEntry.Product2.Record_Limitation__c, PricebookEntry.Product2.Subscription_Type__c,
												   OpportunityId, Opportunity.AccountId, Opportunity.Name, Opportunity.Type, Opportunity.Deal_type__c,
												   Opportunity.Account.Name, Opportunity.Account.Business_Unit__c,Opportunity.Account.Type,
												   Opportunity.account.Professional_Edition__c, Opportunity.Account.Partner_Type__c, Opportunity.CRM_System__c,
												   Opportunity.Account.Sales_Region__c, Opportunity.Sub_Start_Date__c, Opportunity.Sub_End_Date__c,
												   Opportunity.Primary_Marketo_User_Lookup__c, Related_asset__c, Related_asset__r.purpose__c,
												   Related_asset__r.Parent_Instance__c, Related_asset__r.Parent_Instance__r.Asset_Type__c,
												   Related_asset__r.Quantity, Related_asset__r.Installdate, Related_asset__r.UsageEndDate, Quantity 
										    From OpportunityLineItem Where OpportunityId IN : setOppIds ]) {
												
			//Check for Product ConvertTo
			if(oppLItem.PricebookEntry.Product2.ConvertTo__c == Constants.PRODUCT_CONVERTTO_ADD_ON 
				|| oppLItem.PricebookEntry.Product2.ConvertTo__c == Constants.PRODUCT_CONVERTTO_SUBSCRIPTION ) {
				
				//Boolean variable to check aset
				Boolean isUpdateAsset = true;
				
				//Check if map contains opportunity Id
				if(mapOppIdAndAssets.containsKey(oppLItem.OpportunityId)) {
					
					//Loop through Assert
					for(Asset asst : mapOppIdAndAssets.get(oppLItem.OpportunityId)) {
						
						//Check if Asset contains same product that is also on Asset
						if(asst.Product2Id == oppLItem.PricebookEntry.Product2Id) {
							
							//Call utility class method to update update Asset field values
							asst = Utility.populateAssetFields(asst, oppLItem, false, mapOppIdAndAssetId);
							
							//Add in set
							setAssets.add(asst);
							
							//Check isUpdateAsset boolean to false to stop updation of realted asset on OpportunityLineItem
							isUpdateAsset = false;
							
							//Break statement to update only one asset
							break;
						}
					}
				}
				
				//Check for related asset
				if(isUpdateAsset && oppLItem.Related_asset__c != null) {
					
					//Instance of Asset
					Asset asset = new Asset();
					
					//Assign Id of Related_asset__c
					asset.Id = oppLItem.Related_asset__c;
					
					//Call Utility class method to populate values
					asset = Utility.populateAssetFields(asset, oppLItem, false, mapOppIdAndAssetId);
					
					//Add in list
					setAssets.add(asset);
					
					
				} else if(isUpdateAsset && oppLItem.Opportunity.Name != null && !(oppLItem.Opportunity.Name.containsIgnorecase(Constants.OPPORTUNITY_TYPE_RENEWAL)
							|| oppLItem.Opportunity.Name.containsIgnorecase(Constants.OPPORTUNITY_NAME_01R)
							|| oppLItem.Opportunity.Name.containsIgnorecase(Constants.OPPORTUNITY_NAME_02R)
							|| oppLItem.Opportunity.Name.containsIgnorecase(Constants.OPPORTUNITY_NAME_03R)
							|| oppLItem.Opportunity.Type == Constants.OPPORTUNITY_TYPE_UPSELL_CROSSELL)) {
								
					
					//Instance of Asset for insert
					Asset asset = new asset();
					
					//Call utiltiy class metod to populate Asset field values
					asset = Utility.populateAssetFields(asset, oppLItem, true, mapOppIdAndAssetId);
					
					//Add in list
					setAssets.add(asset);
					
				}	
			}
			
			//Unique Key
			String uniqueKey = oppLItem.OpportunityId + '-' + oppLItem.PricebookEntry.Product2Id;
			
			//Check critria for Entitlement
			if((oppLItem.PricebookEntry.Product2.ConvertTo__c == Constants.PRODUCT_CONVERTTO_ENTITLEMENT_SPARK
				|| oppLItem.PricebookEntry.Product2.ConvertTo__c == Constants.PRODUCT_CONVERTTO_ENTITLEMENT_PREMIER
				|| oppLItem.PricebookEntry.Product2.ConvertTo__c == Constants.PRODUCT_CONVERTTO_ENTITLEMENT_ELITE)
			    && oppLItem.PricebookEntry.Product2.ProductCode != Constants.PRODUCT_PRODUCTCODE_LM_SAND) {
				
				//Check for Account Type
				if(oppLItem.Opportunity.Account.Partner_Type__c != Constants.ACCOUNT_PARTNER_TYPE_REFERRAL) {
					
					//Check for Product Code and Opportunity Id
					if(oppLItem.PricebookEntry.Product2Id != null && oppLItem.OpportunityId != null) {
						
						//Check if ProductId already associted with Entitlement
						if(mapOppIdsAndEntitlements.containsKey(uniqueKey)) {
							
							//Loop through Entitlement
							for(Entitlement entitlement : mapOppIdsAndEntitlements.get(uniqueKey)) {
								
								//Call utility class method
								entitlement = Utility.populateEntitlementFields(entitlement, oppLItem, mapOppIdAndAssetId.get(oppLItem.OpportunityId), 'No');
								
								//Add in List to update
								setEntitlements.add(entitlement);
								
								//Break statement
								break;
							}
							
							//Remove value from map to avlid duplicate
							mapOppIdsAndEntitlements.remove(uniqueKey);
							
						} else if(mapAssetIdsAndEntitlements.containsKey(oppLItem.Related_Asset__c)) {
							
							//Instance of Entitlement
							Entitlement entitlement = new Entitlement();
							
							//Assign Id of Exsiting Entitlement recortds Id
							entitlement.Id = mapAssetIdsAndEntitlements.get(oppLItem.Related_Asset__c).Id;
							
							//Call Utility class method to populate field value
							entitlement = Utility.populateEntitlementFields(entitlement, oppLItem, mapOppIdAndAssetId.get(oppLItem.OpportunityId), 'No');
							
							//Add in List to update
							setEntitlements.add(entitlement);
							
							//Remove values from map to avoid duplicate
							mapAssetIdsAndEntitlements.remove(oppLItem.Related_Asset__c);
							
						}else if(mapOppIdAndEntitlement.containsKey(oppLItem.OpportunityId)) {
							
							//Instance of Asset
							Entitlement entitlement = new Entitlement();
							
							//Call utility class method
							entitlement = Utility.populateEntitlementFields(mapOppIdAndEntitlement.get(oppLItem.OpportunityId), oppLItem,
																			mapOppIdAndAssetId.get(oppLItem.OpportunityId), 'No');
							
							//Add in list
							setEntitlements.add(entitlement);
							
							//Remove value from map
							mapOppIdAndEntitlement.remove(oppLItem.OpportunityId);
							
						} else if(oppLItem.Opportunity.Name != null && !(oppLItem.Opportunity.Name.containsIgnorecase(Constants.OPPORTUNITY_TYPE_RENEWAL)
									|| oppLItem.Opportunity.Type == Constants.OPPORTUNITY_TYPE_UPSELL_CROSSELL)) {
							
							//Instance of Entitlement
							Entitlement entitlement = new Entitlement();
							
							//Check for AccountId
							if(oppLItem.Opportunity.AccountId != null)
								entitlement.AccountId = oppLItem.Opportunity.AccountId;
							
							//Call Utility class method to populate field value
							entitlement = Utility.populateEntitlementFields(entitlement, oppLItem, mapOppIdAndAssetId.get(oppLItem.OpportunityId), 'No');
							
							//Add in List to update
							setEntitlements.add(entitlement); 			
						}
					}
				}
			}
		}
		
		//Check for set size
		if(setAssets.size() > 0)
			assets.addAll(setAssets);
		
		//Check for set size
		if(setEntitlements.size() > 0)
			entitlements.addAll(setEntitlements);
			
		//Check for list size
		if(assets.size() > 0)
			upsert assets;
		
		//Check for Entitlement list size
		if(entitlements.size() > 0)
			upsert entitlements;
			
	} 
}