/**
 *  Description    :   Helper class for Trigger_ApprovalRequest trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/13/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public with sharing class ApprovalRequestTriggerHelper {
	
	//Boolean variable for account trigger execution
    public static Boolean execute_ApprovalRequest_Trigger = true;
    
    /**
     *	@Description  :    Method to update Apttus_Approval__Approval_Request__c's related Quote according appropriate field values
     *
     * 	@args         :    List<Apttus_Approval__Approval_Request__c>
     *
     * 	@return       :    void
     *
     **/
    public static void validateQuote(List<Apttus_Approval__Approval_Request__c> newApprovalRequests){
     	 
		//get the label vaue
     	String RoleLabel = Label.AllowedRolesToAddNotesToCEO;
     	 
		//set hold the approval Request's realted quote Id
		Set<Id> setAppReqRltQuoteId  = new set<Id>();

     	//Loop through approval request
     	for(Apttus_Approval__Approval_Request__c appR : newApprovalRequests){
     	 	
     	 	if(appR.Related_Quote__c != null){
     			
     			//Addd the value in set
     			setAppReqRltQuoteId.add(appR.Related_quote__c);
     			
     	 	}
     	} 
     	 
     	//Map to hold the approval request Id as key and List of Quote as values
     	Map<Id, Quote> mapQuoteIds= new Map<Id, Quote>([Select Id, Discount,Approval_Status_Legal__c,
     														    Redirect_Finance_Approval__c, Redirect_Legal_Approval__c,Approval_Status_Finance__c,
     														    Approval_Status_Sales_Terms__c,Approval_Status_Operations__c,Approval_Status_Professional_Services__c,
     	 												 		Redirect_Operations_Approval__c, Redirect_Sales_Discount_Approval__c,
     	 												 		Redirect_Sales_Terms_Approval__c, Redirect_Support_Approval__c, 
           												 		Opportunity_Owner_Manager__r.UserRole.Name, Quote_Notes__c  
           												 From Quote Where Id IN : setAppReqRltQuoteId]);
        
        //Loop through Approval Request  												 
     	for(Apttus_Approval__Approval_Request__c appReq : newApprovalRequests){
     		
     		//Check the values in map
     		if(mapQuoteIds.containsKey(appReq.Related_quote__c)){
     		
     			//check the value of Status field value if Approved
     			if(appReq.Apttus_Approval__Approval_Status__c == Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     				
     				//Check the Approval Step Name value if equal to Legal Approval And Quote's Approval Status Leagl not equal to Approved
     				//Populate the value of Quote's Approval Status Leagl with Approved
     				if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_LEGAL_APPROVAL
     						 && mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Legal__c != Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     				 				
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Legal__c = Constants.APPROVAL_REQUEST_STATUS_APPROVED;
     				
     				//Check the Approval Step Name value if equal to Finacial Approval And Quote's Approval Status finance not equal to Approved 
     				//Populate the value of Quote's Approval Status Finace with Approved	
     				}else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_FINANCIAL_APPROVAL
     							&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Finance__c != Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     						 	
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Finance__c = Constants.APPROVAL_REQUEST_STATUS_APPROVED; 
					
					//Check the Approval Step Name value if equal to Sales term Approval And Quote's Approval Status Sales term  not equal to Approved 
     				//Populate the value of Quote's Approval Status Sales Term with Approved	
     				}else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_TERMS_APPROVAL 
     						&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Terms__c != Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     							
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Terms__c  = Constants.APPROVAL_REQUEST_STATUS_APPROVED; 
     				
     				//Check the Approval Step Name value if equal to Operational Approval And Quote's Approval Status Operation Approval not equal to Approvaed
     				//Populate the value of Quote's Approval Status Operations with Approved	
     				}else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_OPERATION_APPROVAL
     						 && mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Operations__c != Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     						 	
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Operations__c  = Constants.APPROVAL_REQUEST_STATUS_APPROVED;
     				
     				//Check the Approval Step Name value if equal to Professional Services Approval And Quote's Approval Status Services Professional not equal to Approvaed 
     				//Populate the value of Quote's Approval Status Operations with Approved	
     				}else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_PROFESSIONAL_SERIVCES_APPROVAL
     						&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Professional_Services__c != Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     							
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Professional_Services__c = Constants.APPROVAL_REQUEST_STATUS_APPROVED;
     				
     				//Check the Approval Step Name value if equal to Support Approval And Quote's Approval Status Support not equal to Approved
     				//Populate the value of Quote's Approval Status Support with Approved	
     				}else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SUPPORT_APPROVAL
     						&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Support__c != Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     					
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Support__c = Constants.APPROVAL_REQUEST_STATUS_APPROVED;
     					
     				}else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_DISCOUNT_APPROVAL){
     					
     					//Populate the value in field
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Discount__c = Constants.APPROVAL_REQUEST_STATUS_APPROVED;
     					mapQuoteIds.get(appReq.Related_quote__c).Previously_Approved_Discount__c = mapQuoteIds.get(appReq.Related_quote__c).Discount;
     					
     					//check the feld value of appraval comnets
     					if(appReq.Apttus_Approval__Approver_Comments__c != null && appReq.Apttus_Approval__Approver_Comments__c.length() > 0){
                     		
                     		//Check the field value of Quote Notes
                     		if(mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes__c != null && mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes__c.length() > 0){
                     			
                     			//populate the value
                          		mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes__c = appReq.Apttus_Approval__Approver_Comments__c + '<br/>' + 
                          														 mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes__c ;
                     		} else { 
                     			
                     			//Populate the value
                     			mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes__c = appReq.Apttus_Approval__Approver_Comments__c; 
                     		}
                  		}
                  		//Check te value in label
                  		if (RoleLabel.contains(appReq.Actual_approver_role__c)){
                  			
                     		mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes_CEO__c = appReq.Apttus_Approval__Approver_Comments__c;
                  		} else {
                  			
                  			mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes_CEO__c = mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes__c; 
                  		}
     				} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_OPERATION_QA 
     						&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Operations__c != Constants.APPROVAL_REQUEST_STATUS_APPROVED){
     						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Operations__c = Constants.APPROVAL_REQUEST_STATUS_APPROVED ;
     				}
     				
     			//Check the value of Approval Status if Redirected
				} else if(appReq.Apttus_Approval__Approval_Status__c == Constants.APPROVAL_REQUEST_STATUS_REDIRECTED){
     				
     				if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_LEGAL_APPROVAL
     					 && mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Legal__c != Constants.APPROVAL_REQUEST_AUTO_APPROVED)
     					 
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Legal__c = Constants.APPROVAL_REQUEST_AUTO_APPROVED;
     					  
     				else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_FINANCIAL_APPROVAL 
     				 	&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Finance__c != Constants.APPROVAL_REQUEST_AUTO_APPROVED)
     				 	
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Finance__c = Constants.APPROVAL_REQUEST_AUTO_APPROVED;
     					 
     				else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_TERMS_APPROVAL 
     					&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Terms__c != Constants.APPROVAL_REQUEST_AUTO_APPROVED)
     					
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Terms__c = Constants.APPROVAL_REQUEST_AUTO_APPROVED;
     				
     				else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_OPERATION_APPROVAL
     					&& mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Operations__c != Constants.APPROVAL_REQUEST_AUTO_APPROVED)
     						
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Operations__c = Constants.APPROVAL_REQUEST_AUTO_APPROVED;
     					
     				else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SUPPORT_APPROVAL
     				    && mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Support__c != Constants.APPROVAL_REQUEST_AUTO_APPROVED)
     				    
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Support__c = Constants.APPROVAL_REQUEST_AUTO_APPROVED;
     				
     				else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_DISCOUNT_APPROVAL){
     					
     					mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Discount__c = Constants.APPROVAL_REQUEST_AUTO_APPROVED;    
                  		mapQuoteIds.get(appReq.Related_quote__c).Previously_Approved_Discount__c = mapQuoteIds.get(appReq.Related_quote__c).Discount;
                  		
                  		if (RoleLabel.contains(appReq.actual_approver_role__c))
                     		mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes_CEO__c = appReq.Apttus_Approval__Approver_Comments__c;
                  		else 
                  			mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes_CEO__c = mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes__c; 
     				}
     				
     			//Check the value of Approval Status if Rejected
     			} else if(appReq.Apttus_Approval__Approval_Status__c == Constants.APPROVAL_REQUEST_STATUS_REJECTED){
     				 
     				if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_LEGAL_APPROVAL){
     				 	
     				 	mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Legal__c = Constants.APPROVAL_REQUEST_DECLINED;
                  		mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
                  		
     				} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_FINANCIAL_APPROVAL){
     				 	
     				 	mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Finance__c = Constants.APPROVAL_REQUEST_DECLINED;
                  		mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c =  Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
						
     				} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_TERMS_APPROVAL){
     				 	
     				 	mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Terms__c = Constants.APPROVAL_REQUEST_DECLINED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Request_Id__c = appReq.id; 
						
					} else if (appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_OPERATION_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Operations__c = Constants.APPROVAL_REQUEST_DECLINED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_PROFESSIONAL_SERIVCES_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Professional_Services__c = Constants.APPROVAL_REQUEST_DECLINED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SUPPORT_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Support__c = Constants.APPROVAL_REQUEST_DECLINED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_DISCOUNT_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Discount__c = Constants.APPROVAL_REQUEST_DECLINED;
						mapQuoteIds.get(appReq.Related_quote__c).Previously_Approved_Discount__c = 0;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
						mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes_CEO__c = '';
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Request_Id__c = appReq.id;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_OPERATION_QA){
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Operations__c = Constants.APPROVAL_REQUEST_APPROVAL_NEEDED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
					}
					
				//Check the value of Approval Status if Assigned
     			} else if(appReq.Apttus_Approval__Approval_Status__c == Constants.APPROVAL_REQUEST_STATUS_ASSIGNED ){
					
					if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_LEGAL_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Legal__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_FINANCIAL_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Finance__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_TERMS_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Terms__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Request_Id__c = appReq.id;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_OPERATION_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Operations__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
                  		mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
                  		
					}else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_PROFESSIONAL_SERIVCES_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Professional_Services__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SUPPORT_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Support__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_DISCOUNT_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Discount__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						mapQuoteIds.get(appReq.Related_quote__c).Previously_Approved_Discount__c = 0;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Request_Id__c = appReq.id;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_OPERATION_QA){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Operations__c = Constants.APPROVAL_REQUEST_APPROVAL_PENDING;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
					}
					
				//Check the value of Approval Status if Cancelled
				} else if(appReq.Apttus_Approval__Approval_Status__c == Constants.APPROVAL_REQUEST_STATUS_CANCELLED){
					
					if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_LEGAL_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Legal__c = Constants.APPROVAL_REQUEST_STATUS_CANCELLED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_NOT_SUBMITTED;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_FINANCIAL_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Finance__c = Constants.APPROVAL_REQUEST_STATUS_CANCELLED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_TERMS_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Terms__c = Constants.APPROVAL_REQUEST_STATUS_CANCELLED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Request_Id__c = appReq.id;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_TERMS_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Operations__c = Constants.APPROVAL_REQUEST_STATUS_CANCELLED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_PROFESSIONAL_SERIVCES_APPROVAL){
						
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Professional_Services__c = Constants.APPROVAL_REQUEST_APPROVAL_NEEDED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;

					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SUPPORT_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Support__c = Constants.APPROVAL_REQUEST_STATUS_CANCELLED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_DISCOUNT_APPROVAL){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Discount__c = Constants.APPROVAL_REQUEST_STATUS_CANCELLED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
						mapQuoteIds.get(appReq.Related_quote__c).Previously_Approved_Discount__c = 0;
						mapQuoteIds.get(appReq.Related_quote__c).Quote_Notes_CEO__c = '';
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Request_Id__c = appReq.id;
						
					} else if(appReq.Apttus_Approval__Step_Name__c == Constants.APPROVAL_REQUEST_SALES_OPERATION_QA){
					
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status_Sales_Operations__c = Constants.APPROVAL_REQUEST_APPROVAL_NEEDED;
						mapQuoteIds.get(appReq.Related_quote__c).Approval_Status__c = Constants.APPROVAL_REQUEST_PENDING_APPROVAL;
					}
     			}
			}
		}
		
		//Check for map size
		if(mapQuoteIds.size() > 0)
			update mapQuoteIds.values();
    }
    
   /**
    * @Description  :  This method is used to valiadte the Related Quote (field) value by Approval Object(field)value if Approval Object(field )
    *					value is 'Quote'
    *
    * @args         :  List<Apttus_Approval__Approval_Request__c>
    *
    * @return       :  void
    *
    **/
    public static void validateAppReqRelatedQuote(List<Apttus_Approval__Approval_Request__c> newApprovalRequests){
    	
    	//Loop through Approval Request
    	for(Apttus_Approval__Approval_Request__c appReq : newApprovalRequests){
    		
    		//Check the appropriate condition to fire trigger
    		if (appReq.Apttus_Approval__Object_Type__c == Constants.APPROVAL_REQUEST_QUOTE){
    			
    			//Populate the value of Related Quote
    			appReq.Related_Quote__c = appReq.Apttus_Approval__Object_Id__c;
    		}
    	}
    }
}