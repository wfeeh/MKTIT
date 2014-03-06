public class Utility{
    public static Boolean isFutureUpdate = true;
    public static Long updateCounter = 0;
    public static Long updateMaxCounter = 0;
    
	/**
     * @Description  :  Method to populate task field values 
     *
     * @args         :  Id OwnerId , Id WhatId, String Subject, String Description, Date activityDate, Integer
     *
     * @return       :  Task
     *
     **/
     public static Task createTask(Id ownerId, Id whatId, String subject, String description, Date activityDate, Integer decNumber){
     	
     	//Instance of Task
     	Task tsk = new Task();
     	
 		//Populate field with values
 		tsk.OwnerId = ownerId;
 		tsk.WhatId = whatId;
 		tsk.Subject = subject;
 		tsk.Description = description;
     		 
 		//Check for Activity date
 		if(activityDate != null)
 			tsk.ActivityDate = activityDate + decNumber;
 		
 		//Return task
 		return tsk;
     }
     
	/**
     * @Description  :  Method to populate opportunity field value from old opportunity
     *
     * @args         :  Opportunity, Opportunity
     *
     * @return       :  Opportunity
     *
     **/
	public static Opportunity clonOpportunityField(Opportunity newOpp , Opportunity oldOpp ){
     	
    	//Query through user
		List<User> userRenewal = [Select Id FROM User Where Name =: Constants.OPPORTUNITY_USER_NAME_RENEWAL_TEAM LIMIT 1];
		
		//Populate field with values
 		newopp.ownerId = userRenewal[0].Id;
 		newopp.RecordTypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get(Constants.OPPORTUNITY_TYPE_RENEWAL_SALES).getRecordTypeId(); 
 		newOpp.Type =  Constants.OPPORTUNITY_TYPE_RENEWAL;
 		newOpp.Prior_Opportunity__c = oldOpp.id;
 		newOpp.Parent_Opportunity_Quarterly_Deals__c = oldOpp.id;
 		newOpp.stageName =Constants.OPPORTUNITY_TYPE_STAGENAME_NOT_CONTACTED;
 		
 	    //Return opportunity
 	    return newOpp;
    }
     
     /**
     * @Description  :  Method to populate the values of GS 4Weekly Usage Data Contact field values from GS 4Weekly Usage Data record 
     *
     * @args         :  GS_4Weekly_Usage_Data__c
     *
     * @return       :  GS_4Weekly_Usage_Data_Contact__c
     *
     **/
     public static GS_4Weekly_Usage_Data_Contact__c createGSWeeklyContact(GS_4Weekly_Usage_Data__c accGSUsageData) {
     	
     	//Instance of GS_4Weekly_Usage_Data_Contact__c 
     	GS_4Weekly_Usage_Data_Contact__c gSWeeklyDataCon = new GS_4Weekly_Usage_Data_Contact__c();
     	
     	//Populate field values
     	gSWeeklyDataCon.Name = accGSUsageData.Name;
        gSWeeklyDataCon.Account__c = accGSUsageData.Account__c;
        gSWeeklyDataCon.Acct_Prefix__c = accGSUsageData.Acct_Prefix__c;
        gSWeeklyDataCon.Active_Engagement_Count__c = accGSUsageData.Active_Engagement_Count__c;
        gSWeeklyDataCon.anonleadnetcount__c = accGSUsageData.anonleadnetcount__c;
        gSWeeklyDataCon.anonwebvisitcount__c = accGSUsageData.anonwebvisitcount__c;
        gSWeeklyDataCon.Balance_Black_Listed_Leads__c = accGSUsageData.Balance_Black_Listed_Leads__c;
        gSWeeklyDataCon.Balance_Bounced_Leads__c = accGSUsageData.Balance_Bounced_Leads__c;
        gSWeeklyDataCon.Balance_Possible_Duplicates__c = accGSUsageData.Balance_Possible_Duplicates__c;
        gSWeeklyDataCon.Balance_Unsubscribed_Leads__c = accGSUsageData.Balance_Unsubscribed_Leads__c;
        gSWeeklyDataCon.batch_camp_count__c = accGSUsageData.batch_camp_count__c;
        gSWeeklyDataCon.batch_camp_execution_average__c = accGSUsageData.batch_camp_execution_average__c;
        gSWeeklyDataCon.batch_camp_execution_deviation__c = accGSUsageData.batch_camp_execution_deviation__c;
        gSWeeklyDataCon.batch_camp_max_lead_count__c = accGSUsageData.batch_camp_max_lead_count__c;
        gSWeeklyDataCon.batch_camp_max_seconds__c = accGSUsageData.batch_camp_max_seconds__c;
        gSWeeklyDataCon.batch_camp_total_lead_count__c = accGSUsageData.batch_camp_total_lead_count__c;
        gSWeeklyDataCon.batch_camp_total_seconds__c = accGSUsageData.batch_camp_total_seconds__c;
        gSWeeklyDataCon.batchcampcount__c = accGSUsageData.batchcampcount__c;
        gSWeeklyDataCon.Branded_Tracking_Links__c = accGSUsageData.Branded_Tracking_Links__c;
        gSWeeklyDataCon.Campaign_Analysis_Count__c = accGSUsageData.Campaign_Analysis_Count__c;
        gSWeeklyDataCon.changedatavaluecount__c = accGSUsageData.changedatavaluecount__c;
        gSWeeklyDataCon.changescorecount__c = accGSUsageData.changescorecount__c;
        gSWeeklyDataCon.clicklinkcount__c = accGSUsageData.clicklinkcount__c;
        gSWeeklyDataCon.CommunityIdea__c = accGSUsageData.CommunityIdea__c;
        gSWeeklyDataCon.CommunityIdeaComment__c = accGSUsageData.CommunityIdeaComment__c;
        gSWeeklyDataCon.CommunityLogins__c = accGSUsageData.CommunityLogins__c;
        gSWeeklyDataCon.CommunityQuestion__c = accGSUsageData.CommunityQuestion__c;
        gSWeeklyDataCon.CommunityQuestionComment__c = accGSUsageData.CommunityQuestionComment__c;
        gSWeeklyDataCon.createtaskcount__c = accGSUsageData.createtaskcount__c;
        gSWeeklyDataCon.Database_Size__c = accGSUsageData.Database_Size__c;
        gSWeeklyDataCon.DataLoadId__c = accGSUsageData.DataLoadId__c;
        gSWeeklyDataCon.Date__c = accGSUsageData.Date__c;
        gSWeeklyDataCon.DKIM__c = accGSUsageData.DKIM__c;
        gSWeeklyDataCon.Edition__c = accGSUsageData.Edition__c;
        gSWeeklyDataCon.Email_Analysis_Count__c = accGSUsageData.Email_Analysis_Count__c;
        gSWeeklyDataCon.emailbounced__c = accGSUsageData.emailbounced__c;
        gSWeeklyDataCon.emailclicked__c = accGSUsageData.emailclicked__c;
        gSWeeklyDataCon.emaildelivered__c = accGSUsageData.emaildelivered__c;
        gSWeeklyDataCon.emailopened__c = accGSUsageData.emailopened__c;
        gSWeeklyDataCon.emailsentcount__c = accGSUsageData.emailsentcount__c;
        gSWeeklyDataCon.emailsoftbounced__c = accGSUsageData.emailsoftbounced__c;
        gSWeeklyDataCon.emailunsubscribed__c = accGSUsageData.emailunsubscribed__c;
        gSWeeklyDataCon.End_Week__c = accGSUsageData.End_Week__c;
        gSWeeklyDataCon.filloutformcount__c = accGSUsageData.filloutformcount__c;
        gSWeeklyDataCon.Inactive_Engagement_Count__c = accGSUsageData.Inactive_Engagement_Count__c;
        gSWeeklyDataCon.InstanceId__c = accGSUsageData.InstanceId__c;
        gSWeeklyDataCon.InstanceName__c = accGSUsageData.InstanceName__c;
        gSWeeklyDataCon.known_lead_net_count__c = accGSUsageData.known_lead_net_count__c;
        gSWeeklyDataCon.knownleadnetcount__c = accGSUsageData.knownleadnetcount__c;
        gSWeeklyDataCon.Lead_Analysis_Count__c = accGSUsageData.Lead_Analysis_Count__c;
        gSWeeklyDataCon.leadcount__c = accGSUsageData.leadcount__c;
        gSWeeklyDataCon.Marketo_Logins__c = accGSUsageData.Marketo_Logins__c;
        gSWeeklyDataCon.Marketo_Users__c = accGSUsageData.Marketo_Users__c;
        gSWeeklyDataCon.Model_Performance_Company_Analysis_Count__c = accGSUsageData.Model_Performance_Company_Analysis_Count__c;
        gSWeeklyDataCon.Model_Performance_Leads_Analysis_Count__c = accGSUsageData.Model_Performance_Leads_Analysis_Count__c;
        gSWeeklyDataCon.New_Form_Net_Count__c = accGSUsageData.New_Form_Net_Count__c;
        gSWeeklyDataCon.newleadcount__c = accGSUsageData.newleadcount__c;
        gSWeeklyDataCon.Opportunity_Analysis_Count__c = accGSUsageData.Opportunity_Analysis_Count__c;
        gSWeeklyDataCon.Opportunity_Influence_Analyzer_Count__c = accGSUsageData.Opportunity_Influence_Analyzer_Count__c;
        gSWeeklyDataCon.Percent_Change__c = accGSUsageData.Percent_Change__c;
        gSWeeklyDataCon.PrevAvg_Active_Engagement_Count__c = accGSUsageData.PrevAvg_Active_Engagement_Count__c;
        gSWeeklyDataCon.PrevAvg_anonleadnetcount__c = accGSUsageData.PrevAvg_anonleadnetcount__c;
        gSWeeklyDataCon.PrevAvg_anonwebvisitcount__c = accGSUsageData.PrevAvg_anonwebvisitcount__c;
        gSWeeklyDataCon.PrevAvg_Balance_Black_Listed_Leads__c = accGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c;
        gSWeeklyDataCon.PrevAvg_Balance_Bounced_Leads__c = accGSUsageData.PrevAvg_Balance_Bounced_Leads__c;
        gSWeeklyDataCon.PrevAvg_Balance_Possible_Duplicates__c = accGSUsageData.PrevAvg_Balance_Possible_Duplicates__c;
        gSWeeklyDataCon.PrevAvg_Balance_Unsubscribed_Leads__c = accGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c;
        gSWeeklyDataCon.PrevAvg_batch_camp_count__c = accGSUsageData.PrevAvg_batch_camp_count__c;
        gSWeeklyDataCon.PrevAvg_batch_camp_execution_average__c = accGSUsageData.PrevAvg_batch_camp_execution_average__c;
        gSWeeklyDataCon.PrevAvg_batch_camp_execution_deviation__c = accGSUsageData.PrevAvg_batch_camp_execution_deviation__c;
        gSWeeklyDataCon.PrevAvg_batch_camp_max_lead_count__c = accGSUsageData.PrevAvg_batch_camp_max_lead_count__c;
        gSWeeklyDataCon.PrevAvg_batch_camp_max_seconds__c = accGSUsageData.PrevAvg_batch_camp_max_seconds__c;
        gSWeeklyDataCon.PrevAvg_batch_camp_total_lead_count__c = accGSUsageData.PrevAvg_batch_camp_total_lead_count__c;
        gSWeeklyDataCon.PrevAvg_batch_camp_total_seconds__c = accGSUsageData.PrevAvg_batch_camp_total_seconds__c;
        gSWeeklyDataCon.PrevAvg_batchcampcount__c = accGSUsageData.PrevAvg_batchcampcount__c;
        gSWeeklyDataCon.PrevAvg_Campaign_Analysis_Count__c = accGSUsageData.PrevAvg_Campaign_Analysis_Count__c;
        gSWeeklyDataCon.PrevAvg_changedatavaluecount__c = accGSUsageData.PrevAvg_changedatavaluecount__c;
        gSWeeklyDataCon.PrevAvg_changescorecount__c = accGSUsageData.PrevAvg_changescorecount__c;
        gSWeeklyDataCon.PrevAvg_clicklinkcount__c = accGSUsageData.PrevAvg_clicklinkcount__c;
        gSWeeklyDataCon.PrevAvg_CommunityIdea__c = accGSUsageData.PrevAvg_CommunityIdea__c;
        gSWeeklyDataCon.PrevAvg_CommunityIdeaComment__c = accGSUsageData.PrevAvg_CommunityIdeaComment__c;
        gSWeeklyDataCon.PrevAvg_CommunityLogins__c = accGSUsageData.PrevAvg_CommunityLogins__c;
        gSWeeklyDataCon.PrevAvg_CommunityQuestion__c = accGSUsageData.PrevAvg_CommunityQuestion__c;
        gSWeeklyDataCon.PrevAvg_CommunityQuestionComment__c = accGSUsageData.PrevAvg_CommunityQuestionComment__c;
        gSWeeklyDataCon.PrevAvg_createtaskcount__c = accGSUsageData.PrevAvg_createtaskcount__c;
        gSWeeklyDataCon.PrevAvg_Email_Analysis_Count__c = accGSUsageData.PrevAvg_Email_Analysis_Count__c;
        gSWeeklyDataCon.PrevAvg_emailbounced__c = accGSUsageData.PrevAvg_emailbounced__c;
        gSWeeklyDataCon.PrevAvg_emailclicked__c = accGSUsageData.PrevAvg_emailclicked__c;
        gSWeeklyDataCon.PrevAvg_emaildelivered__c = accGSUsageData.PrevAvg_emaildelivered__c;
        gSWeeklyDataCon.PrevAvg_emailopened__c = accGSUsageData.PrevAvg_emailopened__c;
        gSWeeklyDataCon.PrevAvg_emailsentcount__c = accGSUsageData.PrevAvg_emailsentcount__c;
        gSWeeklyDataCon.PrevAvg_emailsoftbounced__c = accGSUsageData.PrevAvg_emailsoftbounced__c;
        gSWeeklyDataCon.PrevAvg_emailunsubscribed__c = accGSUsageData.PrevAvg_emailunsubscribed__c;
        gSWeeklyDataCon.PrevAvg_End_Date__c = accGSUsageData.PrevAvg_End_Date__c;
        gSWeeklyDataCon.PrevAvg_End_Week__c = accGSUsageData.PrevAvg_End_Week__c;
        gSWeeklyDataCon.PrevAvg_filloutformcount__c = accGSUsageData.PrevAvg_filloutformcount__c;
        gSWeeklyDataCon.PrevAvg_Inactive_Engagement_Count__c = accGSUsageData.PrevAvg_Inactive_Engagement_Count__c;
        gSWeeklyDataCon.PrevAvg_known_lead_net_count__c = accGSUsageData.PrevAvg_known_lead_net_count__c;
        gSWeeklyDataCon.PrevAvg_knownleadnetcount__c = accGSUsageData.PrevAvg_knownleadnetcount__c;
        gSWeeklyDataCon.PrevAvg_Lead_Analysis_Count__c = accGSUsageData.PrevAvg_Lead_Analysis_Count__c;
        gSWeeklyDataCon.PrevAvg_leadcount__c = accGSUsageData.PrevAvg_leadcount__c;
        gSWeeklyDataCon.PrevAvg_Marketo_Logins__c = accGSUsageData.PrevAvg_Marketo_Logins__c;
        gSWeeklyDataCon.PrevAvg_Marketo_Users__c = accGSUsageData.PrevAvg_Marketo_Users__c;
        gSWeeklyDataCon.PrevAvg_Model_Performance_Comp_Analysis__c = accGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c;
        gSWeeklyDataCon.PrevAvg_Model_Performance_Leads_Analysis__c = accGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c;
        gSWeeklyDataCon.PrevAvg_New_Form_Net_Count__c = accGSUsageData.PrevAvg_New_Form_Net_Count__c;
        gSWeeklyDataCon.PrevAvg_newleadcount__c = accGSUsageData.PrevAvg_newleadcount__c;
        gSWeeklyDataCon.PrevAvg_Opportunity_Analysis_Count__c = accGSUsageData.PrevAvg_Opportunity_Analysis_Count__c;
        gSWeeklyDataCon.PrevAvg_Opportunity_Influence_Analyzer__c = accGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c;
        gSWeeklyDataCon.PrevAvg_Program_Analyzer_Count__c = accGSUsageData.PrevAvg_Program_Analyzer_Count__c;
        gSWeeklyDataCon.PrevAvg_Program_Cost_Analysis_Count__c = accGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c;
        gSWeeklyDataCon.PrevAvg_programcount__c = accGSUsageData.PrevAvg_programcount__c;
        gSWeeklyDataCon.PrevAvg_Program_Membership_Analysis__c = accGSUsageData.PrevAvg_Program_Membership_Analysis__c;
        gSWeeklyDataCon.PrevAvg_Program_Opportunity_Analysis__c = accGSUsageData.PrevAvg_Program_Opportunity_Analysis__c;
        gSWeeklyDataCon.PrevAvg_Program_Revenue_Stage_Analysis__c = accGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c;
        gSWeeklyDataCon.PrevAvg_programsynccount__c = accGSUsageData.PrevAvg_programsynccount__c;
        gSWeeklyDataCon.PrevAvg_sessioncount__c = accGSUsageData.PrevAvg_sessioncount__c;
        gSWeeklyDataCon.PrevAvg_SFDC_Logins__c = accGSUsageData.PrevAvg_SFDC_Logins__c;
        gSWeeklyDataCon.PrevAvg_Start_Date__c = accGSUsageData.PrevAvg_Start_Date__c;
        gSWeeklyDataCon.PrevAvg_Start_Week__c = accGSUsageData.PrevAvg_Start_Week__c;
        gSWeeklyDataCon.PrevAvg_Success_Path_Analyzer_Count__c = accGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c;
        gSWeeklyDataCon.PrevAvg_syncleadtosfdccount__c = accGSUsageData.PrevAvg_syncleadtosfdccount__c;
        gSWeeklyDataCon.PrevAvg_Tickets_Created__c = accGSUsageData.PrevAvg_Tickets_Created__c;
        gSWeeklyDataCon.PrevAvg_total_session_time__c = accGSUsageData.PrevAvg_total_session_time__c;
        gSWeeklyDataCon.PrevAvg_total_soft_deleted_lead__c = accGSUsageData.PrevAvg_total_soft_deleted_lead__c;
        gSWeeklyDataCon.PrevAvg_total_soft_deleted_pending_lead__c = accGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c;
        gSWeeklyDataCon.PrevAvg_totalanonleadcount__c = accGSUsageData.PrevAvg_totalanonleadcount__c;
        gSWeeklyDataCon.PrevAvg_Total_Engagement_Count__c = accGSUsageData.PrevAvg_Total_Engagement_Count__c;
        gSWeeklyDataCon.PrevAvg_totalknownleadcount__c = accGSUsageData.PrevAvg_totalknownleadcount__c;
        gSWeeklyDataCon.PrevAvg_usingcostperiodcount__c = accGSUsageData.PrevAvg_usingcostperiodcount__c;
        gSWeeklyDataCon.PrevAvg_usingtagsexcludetagcount__c = accGSUsageData.PrevAvg_usingtagsexcludetagcount__c;
        gSWeeklyDataCon.PrevAvg_visitwebpagecount__c = accGSUsageData.PrevAvg_visitwebpagecount__c;
        gSWeeklyDataCon.PrevAvg_workspacecount__c = accGSUsageData.PrevAvg_workspacecount__c;
        gSWeeklyDataCon.Processed__c = accGSUsageData.Processed__c;
        gSWeeklyDataCon.Program_Analyzer_Count__c = accGSUsageData.Program_Analyzer_Count__c;
        gSWeeklyDataCon.Program_Cost_Analysis_Count__c = accGSUsageData.Program_Cost_Analysis_Count__c;
        gSWeeklyDataCon.programcount__c = accGSUsageData.programcount__c;
        gSWeeklyDataCon.Program_Membership_Analysis_Count__c = accGSUsageData.Program_Membership_Analysis_Count__c;
        gSWeeklyDataCon.Program_Opportunity_Analysis_Count__c = accGSUsageData.Program_Opportunity_Analysis_Count__c;
        gSWeeklyDataCon.Program_Revenue_Stage_Analysis_Count__c = accGSUsageData.Program_Revenue_Stage_Analysis_Count__c;
        gSWeeklyDataCon.programsynccount__c = accGSUsageData.programsynccount__c;
        gSWeeklyDataCon.Purpose__c = accGSUsageData.Purpose__c;
        gSWeeklyDataCon.sessioncount__c = accGSUsageData.sessioncount__c;
        gSWeeklyDataCon.SFDC_Logins__c = accGSUsageData.SFDC_Logins__c;
        gSWeeklyDataCon.Start_Date__c = accGSUsageData.Start_Date__c;
        gSWeeklyDataCon.Start_Week__c = accGSUsageData.Start_Week__c;
        gSWeeklyDataCon.Success_Path_Analyzer_Count__c = accGSUsageData.Success_Path_Analyzer_Count__c;
        gSWeeklyDataCon.Support_Engineer__c = accGSUsageData.Support_Engineer__c;
        gSWeeklyDataCon.Support_Level__c = accGSUsageData.Support_Level__c;
        gSWeeklyDataCon.syncleadtosfdccount__c = accGSUsageData.syncleadtosfdccount__c;
        gSWeeklyDataCon.Tickets_Created__c = accGSUsageData.Tickets_Created__c;
        gSWeeklyDataCon.Tickets_Currently_Open__c = accGSUsageData.Tickets_Currently_Open__c;
        gSWeeklyDataCon.total_session_time__c = accGSUsageData.total_session_time__c;
        gSWeeklyDataCon.total_soft_deleted_lead__c = accGSUsageData.total_soft_deleted_lead__c;
        gSWeeklyDataCon.total_soft_deleted_pending_lead__c = accGSUsageData.total_soft_deleted_pending_lead__c;
        gSWeeklyDataCon.totalanonleadcount__c = accGSUsageData.totalanonleadcount__c;
        gSWeeklyDataCon.Total_Certifications__c = accGSUsageData.Total_Certifications__c;
        gSWeeklyDataCon.Total_Courses__c = accGSUsageData.Total_Courses__c;
        gSWeeklyDataCon.Total_Engagement_Count__c = accGSUsageData.Total_Engagement_Count__c;
        gSWeeklyDataCon.totalknownleadcount__c = accGSUsageData.totalknownleadcount__c;
        gSWeeklyDataCon.Usage_Data_Key__c = accGSUsageData.Usage_Data_Key__c;
        gSWeeklyDataCon.User__c = accGSUsageData.User__c;
        gSWeeklyDataCon.usingcostperiodcount__c = accGSUsageData.usingcostperiodcount__c;
        gSWeeklyDataCon.usingtagsexcludetagcount__c = accGSUsageData.usingtagsexcludetagcount__c;
        gSWeeklyDataCon.visitwebpagecount__c = accGSUsageData.visitwebpagecount__c;
        gSWeeklyDataCon.Week_Group4_Number__c = accGSUsageData.Week_Group4_Number__c;
        gSWeeklyDataCon.Week_Start_Year__c = accGSUsageData.Week_Start_Year__c;
        gSWeeklyDataCon.workspacecount__c = accGSUsageData.workspacecount__c;
 		
 		//Return record of GS_4Weekly_Usage_Data_Contact__c
 		return gSWeeklyDataCon;
	}
	
	/**
     * @Description  :  Method to get Map of OpportunityLineItem Ids and Deal_Transaction_Audit_Log__c records
     *
     * @args         :  Set<Id> OpportunityLineItems 
     *
     * @return       :  Map<Id, Deal_Transaction_Audit_Log__c>
     *
     **/ 
    public static Map<Id, Deal_Transaction_Audit_Log__c> getExistingOppTransactionRecords(Set<Id> oppLineItemIds){
        
        //Map of OpportunnityLineItems Ids as key and Deal_Transaction_Audit_Log__c as key
        Map<Id, Deal_Transaction_Audit_Log__c> mapExistingOppTransRecs = new Map<Id, Deal_Transaction_Audit_Log__c>();
        
        //Loop through Deal_Transaction Audit Log
        for(Deal_Transaction_Audit_Log__c dTransAudit :[SELECT Id, Name, Opportunity_Line_Item_Id__c, RecordType.Name FROM Deal_Transaction_Audit_Log__c
        											    WHERE  Opportunity_Line_Item_Id__c IN :oppLineItemIds
        											    AND RecordType.DeveloperName =: Constants.RECORDTYPE_DEVELOPERNAME_DTO LIMIT 1]){
            
        	//Populate map with values
        	mapExistingOppTransRecs.put(dTransAudit.Opportunity_Line_Item_Id__c, dTransAudit);
        }
        
        //Return map
        return mapExistingOppTransRecs;
    }
    
    /**
     * @Description  :  Method to get Map of OpportunityLineItem Ids and Deal_Transaction__c records
     *
     * @args         :  Set<Id> OpportunityLineItems 
     *
     * @return       :  Map<Id, Deal_Transaction__c>
     *
     **/ 
    public static Map<Id, Deal_Transaction__c> getExistingDealTrans(Set<Id> oppLineItemIds){
        
        //Map of OpportunnityLineItems Ids as key and Deal_Transaction_Audit_Log__c as key
        Map<Id, Deal_Transaction__c> mapExistingDealTransRecs = new Map<Id, Deal_Transaction__c>();
        
        //Loop through Deal_Transaction Audit Log
        for(Deal_Transaction__c dTrans :[SELECT Id, Name, Opportunity_Line_Item_Id__c FROM Deal_Transaction__c
        											    WHERE  Opportunity_Line_Item_Id__c IN :oppLineItemIds LIMIT 1]){
            
            //Populate map with values
        	mapExistingDealTransRecs.put(dTrans.Opportunity_Line_Item_Id__c, dTrans);
        }
        
        //Return mapp
        return mapExistingDealTransRecs;
    }
    
    /**
     * @Description  :  Method to create new record of Deal Transaction Audit Log
     *
     * @args         :  Opportunity LineItem
     *
     * @return       :  Deal Transaction Audit Log
     *
     **/
     public static Deal_Transaction_Audit_Log__c createDealTransAuditLog(OpportunityLineItem oppLineItem){
     	 
     	//Query through RecordType
        List<RecordType> recordTypes =[SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType ='Deal_Transaction_Audit_Log__c' And 
        							   DeveloperName =: Constants.RECORDTYPE_DEVELOPERNAME_DTO LIMIT 1];
     	
     	//Instence of Deal_Transaction_Audit_Log__c
     	Deal_Transaction_Audit_Log__c opportunityTransaction = new Deal_Transaction_Audit_Log__c();
        
        //Assigning field Values       
        opportunityTransaction.RecordTypeId = recordTypes[0].Id;
        opportunityTransaction.Opportunity_Line_Item_Id__c = oppLineItem.Id;
        opportunityTransaction.Account__c = oppLineItem.Opportunity.AccountId;
        opportunityTransaction.Opportunity__c = oppLineItem.OpportunityId;
        opportunityTransaction.Opportunity_Type__c = oppLineItem.Opportunity.Type;
        opportunityTransaction.Purchased_ARR__c = oppLineItem.ARR__c; 
        opportunityTransaction.Purchased_Close_Date__c = oppLineItem.Opportunity.CloseDate; 
        opportunityTransaction.Purchased_Database_Size__c = oppLineItem.Opportunity.Contact_Database_Size__c; 
        opportunityTransaction.Purchased_Discount__c = oppLineItem.Discount; 
        opportunityTransaction.Purchased_Edition__c = oppLineItem.Product_Edition__c; 
        opportunityTransaction.Purchased_End_Date__c = oppLineItem.ServiceEndDate__c; 
        opportunityTransaction.Purchased_List_Price__c = oppLineItem.ListPrice; 
        opportunityTransaction.Purchased_Product__c = oppLineItem.PricebookEntry.Product2Id; 
        opportunityTransaction.Purchased_Quantity__c = oppLineItem.Quantity; 
        opportunityTransaction.Purchased_Sales_Price__c = oppLineItem.UnitPrice; 
        opportunityTransaction.Purchased_Start_Date__c = oppLineItem.Product_Start_Date__c; 
        opportunityTransaction.Purchased_Term__c = oppLineItem.Months__c; 
        opportunityTransaction.Purchased_Total_Price__c = oppLineItem.TotalPrice; 
        opportunityTransaction.Purchased_Users__c = oppLineItem.Users__c; 
        opportunityTransaction.Upgrade_Sub_Type__c = oppLineItem.Upgrade_Type__c;
        opportunityTransaction.Effective_Start_Date__c = System.Now();
        opportunityTransaction.Effective_End_Date__c = datetime.newInstance(2099, 12, 31);
        opportunityTransaction.DTO_Unique_Id__c = oppLineItem.OpportunityId + '_' + oppLineItem.Id + '_' + 
                								  oppLineItem.Prior_Opportunity_Id__c + '_' + oppLineItem.OLI_ID__c;
        
        //Return the Deal Transaction Audit Log
        return opportunityTransaction;
     }
     
    /**
     * @Description  :  Method to create new record of Deal_Transaction__c
     *
     * @args         :  Opportunity LineItem
     *
     * @return       :  Deal_Transaction__c
     *
     **/
    public static Deal_Transaction__c createDealTrans(OpportunityLineItem oppLineItem){
     	
    	//Instence of Deal_Transaction_Audit_Log__c
     	Deal_Transaction__c opportunityTrans = new Deal_Transaction__c();
        
		opportunityTrans.Opportunity_Line_Item_Id__c = oppLineItem.id;
        opportunityTrans.Account__c = oppLineItem.Opportunity.AccountId;
        opportunityTrans.Opportunity__c = oppLineItem.OpportunityId;
        opportunityTrans.Opportunity_Type__c = oppLineItem.Opportunity.Type;
        opportunityTrans.Purchased_ARR__c = oppLineItem.ARR__c; 
        opportunityTrans.Purchased_Close_Date__c = oppLineItem.Opportunity.CloseDate; 
        opportunityTrans.Purchased_Database_Size__c = oppLineItem.Opportunity.Contact_Database_Size__c; 
        opportunityTrans.Purchased_Discount__c = oppLineItem.Discount; 
        opportunityTrans.Purchased_Edition__c = oppLineItem.Product_Edition__c; 
        opportunityTrans.Purchased_End_Date__c = oppLineItem.ServiceEndDate__c; 
        opportunityTrans.Purchased_List_Price__c = oppLineItem.ListPrice; 
        opportunityTrans.Purchased_Product__c = oppLineItem.PricebookEntry.Product2Id; 
        opportunityTrans.Purchased_Quantity__c = oppLineItem.Quantity; 
        opportunityTrans.Purchased_Sales_Price__c = oppLineItem.UnitPrice; 
        opportunityTrans.Purchased_Start_Date__c = oppLineItem.Product_Start_Date__c; 
        opportunityTrans.Purchased_Term__c = oppLineItem.Months__c; 
        opportunityTrans.Purchased_Total_Price__c = oppLineItem.TotalPrice; 
        opportunityTrans.Purchased_Users__c = oppLineItem.Users__c; 
        opportunityTrans.Upgrade_Sub_Type__c = oppLineItem.Upgrade_Type__c;
        opportunityTrans.DTO_Unique_Id__c = oppLineItem.OpportunityId + '_' + oppLineItem.Id + '_' + 
                								  oppLineItem.Prior_Opportunity_Id__c + '_' + oppLineItem.OLI_ID__c;
        
        //Return the Deal Transaction Audit Log
        return opportunityTrans;
	}
	
	/**
	 *	@Description	:	Method to fill field values of asset according to opportunityLineItem
	 *	
	 *	@args			:	Asset, OpportunityLineItem, Boolean, Map<Id, Id>
	 *
	 *	@rturn			:	Asset
	 *
	 **/
	public static Asset populateAssetFields(Asset asset, OpportunityLineItem oppLineItem, Boolean isAssetInsert, Map<Id, Id> mapOppIdAndAssetId) {
		
		//Map to hold custom setting data
		Map <String, Product_Family__c> mapProductFamily = Constants.MAP_PRODUCT_FAMILY;
		
		//Check for flag value
		if(isAssetInsert) {
			
			//Populate field value
			asset.InstallDate = oppLineItem.Opportunity.Sub_Start_Date__c != null ? oppLineItem.Opportunity.Sub_Start_Date__c : null;
			asset.UsageEndDate = oppLineItem.Opportunity.Sub_End_Date__c != null ? oppLineItem.Opportunity.Sub_End_Date__c : null;
			
			
			//Check for Product Name
			if (oppLineItem.Opportunity.Deal_Type__c.containsIgnorecase(Constants.OPPORTUNITY_DEAL_TYPE_TRAIL)) {
	            
	            //Assign Value
	            asset.Purpose__c = Constants.OPPORTUNITY_DEAL_TYPE_TRAIL;
	            asset.Name = oppLineItem.opportunity.Account.Name + ' ' + asset.Purpose__c;
            } else if(oppLineItem.opportunity.Account.Name.containsIgnorecase(Constants.ACCOUNT_NAME_MARKETO)
            			|| oppLineItem.opportunity.Account.Name.containsIgnorecase(Constants.ACCOUNT_NAME_INTERNAL_DEMO)
            			|| oppLineItem.opportunity.Account.Name.containsIgnorecase(Constants.ACCOUNT_NAME_MKTO)) {
            	
            	//Assign Value
	            asset.Purpose__c = 'Internal';
	            asset.Name = oppLineItem.opportunity.Account.Name + ' ' + asset.Purpose__c;
            					
            } else if (oppLineItem.PricebookEntry.Product2.Name.containsIgnorecase(Constants.OPPORTUNITY_PRODUCT_NAME_SANDBOX)) {
	        	
	        	//Assign Value
	        	asset.Purpose__c = 'Sandbox';
	            asset.Name = oppLineItem.Opportunity.Account.Name + ' ' + asset.Purpose__c;
			} else if(!oppLineItem.PricebookEntry.Product2.Name.containsIgnorecase(Constants.OPPORTUNITY_PRODUCT_NAME_SANDBOX)) {
				
				//Assign Value
	        	asset.Purpose__c = 'Production';
	            asset.Name = oppLineItem.Opportunity.Account.Name + ' ' + asset.Purpose__c;
			}
		}
		
		//Populate field with values
		asset.Opportunity__c = oppLineItem.OpportunityId;
		asset.AccountId = oppLineItem.Opportunity.AccountId;
		asset.Asset_Type__c = oppLineItem.PricebookEntry.Product2.ConvertTo__c;
		asset.Product2Id = oppLineItem.PricebookEntry.Product2Id;
		
		//Check for 'CRM System' value on opportunity
		if(oppLineItem.Opportunity.CRM_System__c != null)
			asset.CRM_System__c = oppLineItem.Opportunity.CRM_System__c;
		
		//Check for Parent Instance(Asset) and its Asset Type to update Asset's(Child) Quntity field
		if (asset.Parent_Instance__c != null && asset.Parent_Instance__r.Asset_Type__c == Constants.PRODUCT_CONVERTTO_SUBSCRIPTION)
        	asset.Quantity = oppLineItem.PricebookEntry.Product2.Record_Limitation__c;
        
        //Check for Asset purpose field
        if(asset.Purpose__c != null && asset.Purpose__c == Constants.ASSET_PURPOSE_PRODUCTION) {
        	
        	//Populate field values
        	asset.Supported_Instance__c = true;
        	asset.Partner_Supported__c = false;
        }
        
        //Check for Account type
        if(oppLineItem.Opportunity.Account.Type == Constants.ACCOUNT_TYPE_PARTNER)
        	asset.Partner_Supported__c = true;
        
        //Check for subscription type on Product
        if(oppLineItem.PricebookEntry.Product2.Subscription_Type__c != null)
        	asset.Subscription_Type__c = oppLineItem.PricebookEntry.Product2.Subscription_Type__c;
        
        //Check for Product ConvertTo and Family
        if(oppLineItem.PricebookEntry.Product2.ConvertTo__c == Constants.PRODUCT_CONVERTTO_ADD_ON && oppLineItem.PricebookEntry.Product2.Family != null)
        	asset.Add_On_Product__c = oppLineItem.PricebookEntry.Product2.Family;
        
        
        //Check for 
        if(oppLineItem.PricebookEntry.Product2.ConvertTo__c == Constants.PRODUCT_CONVERTTO_ADD_ON) {
        	
        	//Check if map contains key
        	if(mapOppIdAndAssetId.size() >0 && mapOppIdAndAssetId.containsKey(oppLineItem.OpportunityId))
        		asset.Parent_Instance__c = mapOppIdAndAssetId.get(oppLineItem.OpportunityId);
        	
        	//Check for product name in map 
        	if(mapProductFamily.containsKey(oppLineItem.PricebookEntry.Product2.Name))
        		asset.Add_On_Product__c = mapProductFamily.get(oppLineItem.PricebookEntry.Product2.Name).Product_Family_Value__c;
        	
        	//Check for Product family
        	if(oppLineItem.PricebookEntry.Product2.Family == Constants.PRODUCT_FAMILY_SALES_INSIGHT && oppLineItem.Quantity != null)
        		asset.MSI_Seats__c = oppLineItem.Quantity;
        	 	
        }
        //Return Asset
        return asset;
	}
	
	/**
	 *	@Description	:	Method to fill field values for defalut asset 
	 *	
	 *	@args			:	Asset, OpportunityLineItem, String
	 *
	 *	@rturn			:	Asset
	 *
	 **/
	public static Asset populateDefaultAsset(Asset asset, OpportunityLineItem oppLineItem, String str) {
		
		//Query through Product Type
		List<Product2> products =[Select Id, Name from Product2 where ProductCode =: Constants.PRODUCT_PRODUCTCODE_LM_SAND LIMIT 1];
		
		asset.InstallDate = oppLineItem.Opportunity.Sub_Start_Date__c != null ? oppLineItem.Opportunity.Sub_Start_Date__c : null;
        asset.UsageEndDate = oppLineItem.Opportunity.Sub_End_Date__c != null ? oppLineItem.Opportunity.Sub_Start_Date__c : null;
        asset.Purpose__c = Constants.OPPORTUNITY_PRODUCT_NAME_SANDBOX;
        asset.AccountId = oppLineItem.Opportunity.AccountId != null ? oppLineItem.Opportunity.AccountId : null;
        asset.CRM_System__c = oppLineItem.Opportunity.CRM_System__c != null ? oppLineItem.Opportunity.CRM_System__c : null;
        asset.Opportunity__c = oppLineItem.OpportunityId;
        asset.Name = oppLineItem.Opportunity.Account.Name + ' ' + asset.Purpose__c;
        
        //Check for Unique Data
        if(str == 'asset1') {
        
	        //Fill values in fields
	        asset.Asset_Type__c = Constants.PRODUCT_CONVERTTO_SUBSCRIPTION;
	        asset.Product2Id = products[0].Id;
	        asset.Subscription_Type__c = Constants.ACCOUNT_MLM_EDITION_ENTERPRISE;
	        
        } else if(str == 'asset2') {
        	
        	//Fill values in fields
	        asset.Asset_Type__c = Constants.PRODUCT_CONVERTTO_ADD_ON;
	        asset.Product2Id = oppLineItem.PricebookEntry.Product2Id;
	        asset.Add_On_Product__c = 'Advanced Engagement';
        }
        
        //Return
        return asset;
    }
	
	/**
	 *	@Description	:	Method to fill field values of Entitlement according to OpportunityLineItem 
	 *	
	 *	@args			:	Entitlement, OpportunityLineItem, Id(Asset), String
	 *
	 *	@rturn			:	Entitlement
	 *
	 **/
	public static Entitlement populateEntitlementFields(Entitlement entitlement, OpportunityLineItem oppLineItem, Id assetId, String defaultEntitlement) {
		
		//Map to hold SlaProcess(Entitlement Processes) name as key and Id as value
		Map<String, Id> mapSlaProcess = new Map<String, Id>();
		
		//Map to hold BusinessHours(Organization Business Hours) name as key and Id as value
		Map<String, Id> mapBusinessHours = new Map<String, Id>();
		
		//Get Sales Region(Custom Setting) data
		Map <String, Sales_region__c> mapSalesRegions = Constants.MAP_SALES_REGION;
		
		//Query through SlaProcess
		for(SlaProcess sProcess : [Select Id, Name from SlaProcess Where Name IN ('Standard Support', 'Partner Support', 'Spark Support',
																				  'Premier Support', 'Elite Support')]) {
			
			//Populate map with values
			mapSlaProcess.put(sProcess.Name, sProcess.Id);																		  	
		}
		
		
		//Query through BusinessHours
		for(BusinessHours bHours : [Select Id, Name From BusinessHours]) {
			
			//Populate map with values
			mapBusinessHours.put(bHours.Name, bHours.Id);
		}
		
		//Populate field values
		entitlement.Product_ID__c = oppLineItem.PricebookEntry.Product2Id;
		entitlement.Name = oppLineItem.Opportunity.Account.Name;
		entitlement.AccountId = oppLineItem.Opportunity.AccountId;
		
		//Check for String value
		if(defaultEntitlement != 'Yes') {
			
			//Populate field value
			entitlement.StartDate = oppLineItem.Related_Asset__r.Installdate != null ? oppLineItem.Related_Asset__r.Installdate : null;
			entitlement.EndDate = oppLineItem.Related_Asset__r.UsageEndDate != null ? oppLineItem.Related_Asset__r.UsageEndDate : null;
		} else {
			
			//Populate field value
			entitlement.StartDate = oppLineItem.Opportunity.Sub_Start_Date__c != null ? oppLineItem.Opportunity.Sub_Start_Date__c : null;
			entitlement.EndDate = oppLineItem.Opportunity.Sub_End_Date__c != null ? oppLineItem.Opportunity.Sub_End_Date__c : null;
		}
		
		//Check for bussiness houress metting in custom setting
		if(mapSalesRegions.containsKey(oppLineItem.Opportunity.Account.Business_Unit__c))
			entitlement.Support_Region__c = mapSalesRegions.get(oppLineItem.Opportunity.Account.Business_Unit__c).Support_region_value__c;
		
		//Check for assetId
		if(defaultEntitlement == 'No' && assetId != null)
			entitlement.AssetId = assetId;
		
		//Check for Account Type
		if(defaultEntitlement == 'Yes' || (defaultEntitlement == 'No' && oppLineItem.Opportunity.Account.Partner_Type__c == Constants.ACCOUNT_PARTNER_TYPE_RESELLER
			|| oppLineItem.Opportunity.Account.Partner_Type__c == Constants.ACCOUNT_PARTNER_TYPE_AGENCY)) {
			
			//Check for defaultEntitlement Entitlement
			if(defaultEntitlement == 'Yes' && oppLineItem.PricebookEntry.Product2.Name.containsIgnorecase('Spark')) {
				
				//Fill fields value
				entitlement.Type = 'Spark';
				
				if(mapSlaProcess.containsKey('Spark Support'))
					entitlement.SlaProcessId = mapSlaProcess.get('Spark Support');
			} else if(defaultEntitlement == 'Yes') {
				
				//Fill fields value
				entitlement.Type = 'Standard';
				
				if(mapSlaProcess.containsKey(Constants.SlaProcess_Name_Standard_Support))
					entitlement.SlaProcessId = mapSlaProcess.get(Constants.SlaProcess_Name_Standard_Support);
			}
			
			//Fill Entitlement type
			entitlement.Type = Constants.ACCOUNT_TYPE_PARTNER;
			
			//Check for Standard Support SlaProcess
			if(defaultEntitlement == 'No' && oppLineItem.Opportunity.Account.Partner_Type__c == Constants.ACCOUNT_PARTNER_TYPE_AGENCY 
				&& mapSlaProcess.containsKey(Constants.SlaProcess_Name_Standard_Support))
				entitlement.SlaProcessId = mapSlaProcess.get(Constants.SlaProcess_Name_Standard_Support);
			
			//Check for Account Name
			if(oppLineItem.Opportunity.Account.Sales_Region__c == 'EMEA' && mapBusinessHours.containsKey('Local Hours (EMEA)')) {
				entitlement.BusinessHoursId = mapBusinessHours.get('Local Hours (EMEA)');
			} else if(oppLineItem.Opportunity.Account.Sales_Region__c == 'APAC' && mapBusinessHours.containsKey('Local Hours (APAC)')) {
				entitlement.BusinessHoursId = mapBusinessHours.get('Local Hours (APAC)');
			} else if(oppLineItem.Opportunity.Account.Sales_Region__c == 'North America' && mapBusinessHours.containsKey('Local Hours (North America)')) {
				entitlement.BusinessHoursId = mapBusinessHours.get('Local Hours (North America)');
			}
		} else if(defaultEntitlement == 'No' && oppLineItem.Opportunity.Account.Partner_Type__c == Constants.ACCOUNT_PARTNER_TYPE_PREFERRED_SERVICES) {
			
			//Fill Entitlement type
			entitlement.Type = Constants.ACCOUNT_TYPE_PARTNER;
			
			//Check for slaprocess
			if(mapSlaProcess.containsKey('Partner Support'))
				entitlement.SlaProcessId = mapSlaProcess.get('Partner Support');
			
			//Check for BusinessHours
			if(mapBusinessHours.containsKey('24x5'))
				entitlement.BusinessHoursId = mapBusinessHours.get('24x5');
		}
		
		//Return
		return entitlement;
	}
	/**
     * @Description  :  Method to Authorize Contact
     *
     * @args         :  List<Id>
     *
     * @return       :  
     *
     **/
     public static  Map<Id, Boolean> getAuhContactValue(Set<Id> contactIds){
     	
     	//Map to hold the Id of Contact corresponding to the boolean value of contact
     	Map<Id,Boolean> mapCaseContactBooleanValue = new Map<Id,Boolean>();
     	
     	//Loop through Authorize Contact 
     	for(Authorized_Contact__c authCon : [Select Id,Entitlement__r.AssetId, Entitlement__r.Type, Entitlement__c,
     												Contact__c , Entitlement__r.Asset.Purpose__c, Entitlement__r.Asset.AccountId From 
     												Authorized_Contact__c Where Entitlement__r.Status = 'Active' AND  contact__c IN :contactIds]){
     		
     		//Check the value of Purpose value of Aseet field and type of Entitlement
     		if(authCon.Contact__c != null && authCon.Entitlement__r.Asset.Purpose__c == 'Production' && authCon.Entitlement__r.Type != 'internal'){
     			
     			mapCaseContactBooleanValue.put(authCon.Contact__c, true);
     		} else {
     			
     			//Check if map already contains Contact
     			if(authCon.Contact__c != null && !mapCaseContactBooleanValue.containsKey(authCon.Contact__c))
     				mapCaseContactBooleanValue.put(authCon.Contact__c , false);
     		}							     	
     	}  
     	
     	//return the value of Map
     	return mapCaseContactBooleanValue;      
     }
	/**
	 * @Description  :  Method to get the Milestonetype
	 *
	 * @args         :  Set<String>, Set<string>
	 *
	 * @return       :  mapSLAs
	 *
	 **/
	Public static Map<String, SLA__c> mapGetSlaHours(Set<String> setPriority, Set<String> setSupportlevel) {
    	
    	//Map to hold Priority and Support level as key and SLA as value
    	Map<String, SLA__c> mapSLAs = new Map<String, SLA__c>();
    	
	    //Loop through SLA
	    for(SLA__c sla : [Select Id, Priority__c, Support_Level__c , Case_Update_Milestone_NOM__c, First_Response_NOM__c From SLA__c 
	    					Where Priority__c != null AND Priority__c IN : setPriority 
	    						AND Support_Level__c != null AND Support_Level__c IN : setSupportlevel]) {
	    									
	    	//Unique Key
	    	String uniqueKey = sla.Priority__c + '-' + sla.Support_Level__c;
	    	
	    	//Check if map already contains unque key
	    	if(!mapSLAs.containsKey(uniqueKey)) {
	    		
	    		//Populate map with values
	    		mapSLAs.put(uniqueKey, sla);
	    	}
	    }
	    return mapSLAs;
 	}
 	/**
	 * @Description  :  Method to get the Milestonetype
	 *
	 * @args         :  Set<String>, Set<string>, Integer, Boolean
	 *
	 * @return       :  mapSLAs
	 *
	 **/
	 Public static Case_Update_Milestones__c caseUpdateMilestone(Case cse, List<CaseAdmin__c> caseAdmins, Integer minutes, Boolean isUpdate){
	 	 
	 	 //Instance of Case Update Milestones
	 	 Case_Update_Milestones__c cUM = new Case_Update_Milestones__c();
	 	 
	 	
	 	//Check the value of
	 	if(cse.Origin != Constants.CASE_ORIGIN_PHONE || isUpdate){
	 		
	 		//Check for update case
	 		if(isUpdate) {
	 			cUM.Milestone_Type__c = 'Case Update';
	 		} else {
	 			cUM.Milestone_Type__c = Constants.CASE_MILESTONENAME_FIRST_RESPONSE;
	 		}
	 		//Populate the values
	 		cUM.Case__c = cse.id;
            cUM.Start_Date__c = System.now();
            
            //Check for Minuts and Priority
            if(minutes != null && cse.Priority != null && Integer.valueof(cse.Priority.substringAfter('P')) != 1 
            	&& cse.Entitlement.BusinessHoursId != null) {
            	
            	cUM.Target_Date__c = BusinessHours.addGmt(cse.Entitlement.BusinessHoursId, System.now(),minutes*60000);
            } else if(minutes != null){
            	cUM.Target_Date__c = System.now().addMinutes(minutes);
            } else {
            	cUM.Target_Date__c = System.now();
            } 
            
            cUM.Duration__c = minutes != null ? minutes+'':null;
            
            if(caseAdmins != null && caseAdmins.size() > 0 && (cse.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_DEVELOPER_NAME_SUPPORT_CUSTOMER_PORTAL_CASE
            			   || cse.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_DEVELOPER_NAME_SUPPORT_EMAIL_TO_CASE)) {
            	
            	cUM.OwnerId = caseAdmins[0].CaseAdminId__c;
            } else {
            	cUM.OwnerId = cse.OwnerId;    	
            }  
	 	 } else if(!isUpdate){
	 	 	
            cUM.Case__c = cse.id;
            cUM.Milestone_Type__c = Constants.CASE_MILESTONENAME_FIRST_RESPONSE;
            cUM.Start_Date__c = System.now();
            cUM.OwnerId = cse.OwnerId;
            cUM.Completed__c  = true;
            cUM.Completion_Date__c  = System.now();      
        }
        
        return cUM;
	 }
	/**
     * @Description  :  Method to assign the values in task fields
     *
     * @args         :  Task , TaskClone__c
     *
     * @return       :  taskClone
     *
     **/
     public static TaskClone__c taskClone(Task tsk,  TaskClone__c tC, Account account){
     
     	//String to hold Lead and Contact keyPrifix
		String leadKeyPrefix = Lead.SObjectType.getDescribe().getKeyPrefix();
		String contactKeyPrefix = Contact.SObjectType.getDescribe().getKeyPrefix();
		
     	//Check for fields and Populate the values in taskClone
     	if(tsk.Type != null && tC.Type__c != tsk.Type)
     		tC.Type__c = tsk.Type;
     	
     	if(tsk.Id != tC.TaskId__c)
     		tC.TaskId__c = tsk.Id;
     		
     	if(tsk.Subject != null && tsk.Subject != tC.Subject__c)
     		tC.Subject__c = tsk.Subject;
     	
     	if(tsk.Description != null && tC.Comments__c != tsk.Description)
     		tC.Comments__c = tsk.Description;
     	
     	if(tsk.OwnerId != null && tC.Assigned_to_user__c != tsk.OwnerId)
     		tC.Assigned_to_user__c = tsk.OwnerId;
     	
     	if(tsk.What.Name != null && tC.RelatedTo__c != tsk.What.Name  )
     		tC.RelatedTo__c = tsk.What.Name;
     	
     	tC.RelatedTo_Id__c = tsk.WhatId;
     	
     	if(tsk.Who.Name != null && tC.WhoName__c != tsk.Who.Name)
     		tC.WhoName__c = tsk.Who.Name;
     	
     	if(tsk.Status != null && tC.Status__c != tsk.Status)
        	tC.Status__c = tsk.Status;
        
        if(tsk.OwnerId != null && tsk.Owner.Email != null && tc.User_Email__c != tsk.Owner.Email)
        	tc.User_Email__c = tsk.Owner.Email;
     	
     	//Check the value of WhoId in task
     	if(tsk.WhoId != null){
     		
     		//Check the value of contactId and leadId
            if(String.valueOf(tsk.WhoId).startsWith(contactKeyPrefix)){
            	
            	tC.ContactId__c = tsk.WhoId;
            	tC.LeadId__c = null;
            }else if(tsk.WhoId != null && String.valueOf(tsk.WhoId).startsWith(leadKeyPrefix)){
            		
            		tC.LeadId__c = tsk.WhoId;
            		tC.ContactId__c = null;}
        } else {
        	tC.LeadId__c = null;
        	tC.ContactId__c = null;
        }
        
        //Check the values of string
        if(tsk.Type.equalsIgnoreCase(Constants.TASK_TYPE_CSM_UPSELL_PRODUCT_ONLY )){
        	if( account != null && account.OwnerId != null && account.Owner.Email != null && tsk.CreatedBy.Email != null){
        		tC.Email__c =account.Owner.Email;
        		tC.Account_Owner__c = account.OwnerId;
        		tC.Account_Owner_Mail__c =account.Owner.Email;
        		tC.Call_Logged_By__c = tsk.CreatedBy.Email;
        		
        	} else if(tsk.Type.equalsIgnoreCase(Constants.TASK_TYPE_CSM_UPSELL_SERVICES)){
        		tC.Email__c = Label.TASK_CLONE_EMAIL;
        		tC.Account_Owner__c = null;
        		tC.Account_Owner_Mail__c = null;
        		tC.Call_Logged_By__c = null;
        	}
        }
        return tC;
     }
     
     
	/**
	 *	@description	:	Method to populate Case fields
	 *
	 *	@args			:	EmailMessage, Case, Map<Id, Case>
	 *
	 *	@return			:	Case
	 *
	 **/
	public static Case populateFieldValues(EmailMessage eM , Case cse, Map<Id, Case> mapCases) {
		
		//Popuate field with values
		cse.Subject = eM.Subject;
		cse.ParentId = eM.ParentId;
		
		//Check for Text body
		if(eM.TextBody != null && eM.TextBody != '')
			cse.Description = eM.TextBody;
		
		//Check for Account Id
		if(mapCases.get(eM.ParentId).AccountId != null)
			cse.Situation_Account__c = mapCases.get(eM.ParentId).AccountId;
		
		//Check for Contact Id
		if(mapCases.get(eM.ParentId).ContactId != null)
			cse.Situation_Contact__c = mapCases.get(eM.ParentId).ContactId;
		
		//Return 
		return cse;
	}
	
	/**
	 *	@description	:	Method to Show error message to user if Product is also attached to kumocomm__ShoppingCartItem__c.
	 *
	 *	@args			:	List<SObject>, Map<Id, SObject>
	 *
	 *	@return			:	void
	 *
	 **/
	public static void validateProduct(List<SObject> newObjects, Map<Id, SObject> mapOldSobjects) {
		
		//Set to hold Product Id
		Set<Id> setProdIds = new Set<Id>();
		
		//Set to hold Product Ids 
		Set<Id> setSCIProductIds = new Set<Id>(); 
		
		//Loop through SObject
		for(SObject obj : newObjects) {
			
			//Check for product
			if((Id)obj.get('Product__c') != null && (mapOldSobjects == null || (Id)obj.get('Product__c') != (Id) mapOldSobjects.get((Id)obj.get('Id')).get('Product__c')))
				setProdIds.add((Id)obj.get('Product__c'));
		}
		System.debug('######### : ' +setProdIds);
		//Loop through Shopping CartItem
        for(kumocomm__ShoppingCartItem__c sCI : [Select Id, kumocomm__Product__c From kumocomm__ShoppingCartItem__c Where 
                                                            kumocomm__Product__c != null AND kumocomm__Status__c =: Constants.TRAINING_STATUS_IN_CART
                                                            AND kumocomm__Product__c IN : setProdIds]){
            //add the value in set
            setSCIProductIds.add(sCI.kumocomm__Product__c);                                             
        }
        System.debug('######### : ' +setSCIProductIds);
        //Loop through SObject
        for(SObject obj : newObjects) {
        	
        	//Check for product
			if((Id)obj.get('Product__c') != null && (mapOldSobjects == null || (Id)obj.get('Product__c') != (Id) mapOldSobjects.get((Id)obj.get('Id')).get('Product__c'))) {
				
				//Check if Set Contains Product Id
				if(setSCIProductIds.contains((Id)obj.get('Product__c')))
					obj.addError(Label.MKT_CheckProductError);			
			}
        }
	}
	
	/**
	  * @description : Method to get user Name and user role from Configuration_Manager__c(Custom setting) and return set
	  *
	  * @args   : String parameterKey
	  *
	  * @return   : Set<String>
	  *
	 **/
	public static Set<String> ConfigManagerParameterValue(String parameterKey) {
	  
		//Set to return User Role Or User Name
	  	Set<String> setUserRoleOrName = new Set<String>();
	  
	  	//Loop through Configuration_Manager__c
	  	for(Configuration_Manager__c cM : Constants.getConfigManagerByParameterKey(parameterKey)) {
	   
	  		 //Check for Key
	   		if(cM.Parameter_Value__c != null && cM.Parameter_Value__c != '')
				setUserRoleOrName.add(cM.Parameter_Value__c); 
	  	}
	  
	  	//Return set
	  	return setUserRoleOrName;
	}
}