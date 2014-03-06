public class CreateConUsageDataFromAccUsageData{
    public CreateConUsageDataFromAccUsageData(){}
    
    public void CreateConUsageData(List<Contact> contactList){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact con :contactList){
            accountIdSet.add(con.AccountId);
            contactIdSet.add(con.Id);
        }
        
        Map<Id,List<GS_4Weekly_Usage_Data__c>> accountUsageDataMap = new Map<Id,List<GS_4Weekly_Usage_Data__c>>();
        accountUsageDataMap = getAccountUsageDataMap(accountIdSet);
        
        Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>> contactUsageDataMap = new Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>>();
        contactUsageDataMap = getContactUsageDataMap(contactIdSet);
        
        List<GS_4Weekly_Usage_Data_Contact__c> contactUsageDataListToUpsert = new List<GS_4Weekly_Usage_Data_Contact__c>();
        
        for(Contact con :contactList){
            if(accountUsageDataMap.get(con.AccountId) != null){
                for(GS_4Weekly_Usage_Data__c accountUsageData :accountUsageDataMap.get(con.AccountId)){
                    Id conUsageDataId = null;
                    if(contactUsageDataMap.get(con.Id) != null){
                        for(GS_4Weekly_Usage_Data_Contact__c existingConUsageData :contactUsageDataMap.get(con.Id)){
                            if(existingConUsageData.Usage_Data_Key__c == accountUsageData.Usage_Data_Key__c){
                                conUsageDataId = existingConUsageData.Id;
                                break;
                            } 
                        }
                    }
                
                    GS_4Weekly_Usage_Data_Contact__c tempContactUsageData = new GS_4Weekly_Usage_Data_Contact__c();
                    tempContactUsageData = getTempContactUsageData(accountUsageData);
                    if(conUsageDataId != null){
                        tempContactUsageData.Id = conUsageDataId;
                    }
                    tempContactUsageData.Contact__c = con.Id;
                    contactUsageDataListToUpsert.add(tempContactUsageData);
                }
            }
        }
        
        if(contactUsageDataListToUpsert.size() > 0){
            upsert contactUsageDataListToUpsert;
        }
    }
    
    
    private Map<Id,List<GS_4Weekly_Usage_Data__c>> getAccountUsageDataMap(Set<Id> accountIdSet){
        Map<Id,List<GS_4Weekly_Usage_Data__c>> accountUsageDataMap = new Map<Id,List<GS_4Weekly_Usage_Data__c>>();
        for(GS_4Weekly_Usage_Data__c gsAccountUsageData :getGS4WeeklyUsageDataList(accountIdSet)){
            if(accountUsageDataMap.get(gsAccountUsageData.Account__c) != null){
                accountUsageDataMap.get(gsAccountUsageData.Account__c).add(gsAccountUsageData);
            }
            else{
                List<GS_4Weekly_Usage_Data__c> tempAccUsageDataList = new List<GS_4Weekly_Usage_Data__c>();
                tempAccUsageDataList.add(gsAccountUsageData);
                accountUsageDataMap.put(gsAccountUsageData.Account__c, tempAccUsageDataList);
            }
        }
        return accountUsageDataMap;
    }
    
    
    private List<GS_4Weekly_Usage_Data__c> getGS4WeeklyUsageDataList(Set<Id> accountIdSet){
        return  [SELECT Id, Name, Account__c, Active_Engagement_Count__c, anonleadnetcount__c, anonwebvisitcount__c, 
                Balance_Black_Listed_Leads__c, Balance_Bounced_Leads__c, Balance_Possible_Duplicates__c, Acct_Prefix__c,  
                Balance_Unsubscribed_Leads__c, batch_camp_count__c, batch_camp_execution_average__c, batch_camp_execution_deviation__c, 
                batch_camp_max_lead_count__c, batch_camp_max_seconds__c, batch_camp_total_lead_count__c, batch_camp_total_seconds__c, 
                batchcampcount__c, BatchCampZero__c, Campaign_Analysis_Count__c, changedatavaluecount__c, changescorecount__c, 
                clicklinkcount__c, CommunityIdea__c, CommunityIdeaComment__c, CommunityLogins__c, Start_Date__c, 
                Branded_Tracking_Links__c, DKIM__c, End_Week__c, Percent_Change__c, Start_Week__c, 
                CommunityQuestion__c, CommunityQuestionComment__c, Contact__c, createtaskcount__c, DataLoadId__c, Date__c, 
                Email_Analysis_Count__c, emailbounced__c, emailclicked__c, emaildelivered__c, emailopened__c, emailsentcount__c, 
                emailsoftbounced__c, emailunsubscribed__c, filloutformcount__c, Inactive_Engagement_Count__c, InstanceId__c, 
                InstanceName__c, known_lead_net_count__c, knownleadnetcount__c, Lead_Analysis_Count__c, leadcount__c, 
                Model_Performance_Company_Analysis_Count__c, Model_Performance_Leads_Analysis_Count__c, New_Form_Net_Count__c, 
                newleadcount__c, Opportunity_Analysis_Count__c, Opportunity_Influence_Analyzer_Count__c, Processed__c, 
                Program_Analyzer_Count__c, Program_Cost_Analysis_Count__c, programcount__c, Program_Membership_Analysis_Count__c, 
                Program_Opportunity_Analysis_Count__c, Program_Revenue_Stage_Analysis_Count__c, programsynccount__c, 
                sessioncount__c, Success_Path_Analyzer_Count__c, syncleadtosfdccount__c, total_session_time__c, 
                total_soft_deleted_lead__c, total_soft_deleted_pending_lead__c, totalanonleadcount__c, Total_Engagement_Count__c, 
                totalknownleadcount__c, Usage_Data_Key__c, User__c, usingcostperiodcount__c, usingtagsexcludetagcount__c, 
                visitwebpagecount__c, Week_Group4_Number__c, workspacecount__c, Edition__c, Database_Size__c, Support_Level__c,     
                Support_Engineer__c, Account_Executive__c, Purpose__c, Marketo_Users__c, Marketo_Logins__c, Tickets_Created__c, 
                Tickets_Currently_Open__c, Total_Certifications__c, Total_Courses__c, SFDC_Logins__c,  
                PrevAvg_Active_Engagement_Count__c, PrevAvg_anonleadnetcount__c, PrevAvg_anonwebvisitcount__c,
                PrevAvg_Balance_Black_Listed_Leads__c, PrevAvg_Balance_Bounced_Leads__c, PrevAvg_Balance_Possible_Duplicates__c,
                PrevAvg_Balance_Unsubscribed_Leads__c, PrevAvg_batch_camp_count__c, PrevAvg_batch_camp_execution_average__c,
                PrevAvg_batch_camp_execution_deviation__c, PrevAvg_batch_camp_max_lead_count__c, PrevAvg_batch_camp_max_seconds__c,
                PrevAvg_batch_camp_total_lead_count__c, PrevAvg_batch_camp_total_seconds__c, PrevAvg_batchcampcount__c,
                PrevAvg_Campaign_Analysis_Count__c, PrevAvg_changedatavaluecount__c, PrevAvg_changescorecount__c,
                PrevAvg_clicklinkcount__c, PrevAvg_CommunityIdea__c, PrevAvg_CommunityIdeaComment__c,
                PrevAvg_CommunityLogins__c, PrevAvg_CommunityQuestion__c, PrevAvg_CommunityQuestionComment__c,
                PrevAvg_createtaskcount__c, PrevAvg_Email_Analysis_Count__c, PrevAvg_emailbounced__c,
                PrevAvg_emailclicked__c, PrevAvg_emaildelivered__c, PrevAvg_emailopened__c,
                PrevAvg_emailsentcount__c, PrevAvg_emailsoftbounced__c, PrevAvg_emailunsubscribed__c,
                PrevAvg_End_Date__c, PrevAvg_End_Week__c, PrevAvg_filloutformcount__c,
                PrevAvg_Inactive_Engagement_Count__c, PrevAvg_known_lead_net_count__c, PrevAvg_knownleadnetcount__c,
                PrevAvg_Lead_Analysis_Count__c, PrevAvg_leadcount__c, PrevAvg_Marketo_Logins__c,
                PrevAvg_Marketo_Users__c, PrevAvg_Model_Performance_Comp_Analysis__c, PrevAvg_Model_Performance_Leads_Analysis__c,
                PrevAvg_New_Form_Net_Count__c, PrevAvg_newleadcount__c, PrevAvg_Opportunity_Analysis_Count__c,
                PrevAvg_Opportunity_Influence_Analyzer__c, PrevAvg_Program_Analyzer_Count__c, PrevAvg_Program_Cost_Analysis_Count__c,
                PrevAvg_programcount__c, PrevAvg_Program_Membership_Analysis__c, PrevAvg_Program_Opportunity_Analysis__c,
                PrevAvg_Program_Revenue_Stage_Analysis__c, PrevAvg_programsynccount__c, PrevAvg_sessioncount__c,
                PrevAvg_SFDC_Logins__c, PrevAvg_Start_Date__c, PrevAvg_Start_Week__c,
                PrevAvg_Success_Path_Analyzer_Count__c, PrevAvg_syncleadtosfdccount__c, PrevAvg_Tickets_Created__c,
                PrevAvg_total_session_time__c, PrevAvg_total_soft_deleted_lead__c, PrevAvg_total_soft_deleted_pending_lead__c,
                PrevAvg_totalanonleadcount__c, PrevAvg_Total_Engagement_Count__c, PrevAvg_totalknownleadcount__c, 
                PrevAvg_usingcostperiodcount__c, PrevAvg_usingtagsexcludetagcount__c, PrevAvg_visitwebpagecount__c,
                PrevAvg_workspacecount__c, Week_Start_Year__c
                FROM GS_4Weekly_Usage_Data__c 
                WHERE Account__c in :accountIdSet];
    }
    
    
    private Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>> getContactUsageDataMap(Set<Id> contactIdSet){
        Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>> contactUsageDataMap = new Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>>();
        for(GS_4Weekly_Usage_Data_Contact__c conUsageData :getContactUsageDataList(contactIdSet)){
            if(contactUsageDataMap.get(conUsageData.Contact__c) != null){
                contactUsageDataMap.get(conUsageData.Contact__c).add(conUsageData);
            }
            else{
                List<GS_4Weekly_Usage_Data_Contact__c> tempConUsageDataList = new List<GS_4Weekly_Usage_Data_Contact__c>();
                tempConUsageDataList.add(conUsageData);
                contactUsageDataMap.put(conUsageData.Contact__c, tempConUsageDataList);
            }
        }
        return contactUsageDataMap;
    } 
    
    
    private List<GS_4Weekly_Usage_Data_Contact__c> getContactUsageDataList(Set<Id> contactIdSet){
        return [SELECT Id, Usage_Data_Key__c, Contact__c, Account__c
                FROM GS_4Weekly_Usage_Data_Contact__c 
                WHERE Contact__c in :contactIdSet];
    }
    
    
    private GS_4Weekly_Usage_Data_Contact__c getTempContactUsageData(GS_4Weekly_Usage_Data__c accountGSUsageData){
         GS_4Weekly_Usage_Data_Contact__c tempContactUsageData = new GS_4Weekly_Usage_Data_Contact__c(
            Name = accountGSUsageData.Name,
            Account__c = accountGSUsageData.Account__c,
            Acct_Prefix__c = accountGSUsageData.Acct_Prefix__c,
            Active_Engagement_Count__c = accountGSUsageData.Active_Engagement_Count__c,
            anonleadnetcount__c = accountGSUsageData.anonleadnetcount__c,
            anonwebvisitcount__c = accountGSUsageData.anonwebvisitcount__c,
            Balance_Black_Listed_Leads__c = accountGSUsageData.Balance_Black_Listed_Leads__c,
            Balance_Bounced_Leads__c = accountGSUsageData.Balance_Bounced_Leads__c,
            Balance_Possible_Duplicates__c = accountGSUsageData.Balance_Possible_Duplicates__c,
            Balance_Unsubscribed_Leads__c = accountGSUsageData.Balance_Unsubscribed_Leads__c,
            batch_camp_count__c = accountGSUsageData.batch_camp_count__c,
            batch_camp_execution_average__c = accountGSUsageData.batch_camp_execution_average__c,
            batch_camp_execution_deviation__c = accountGSUsageData.batch_camp_execution_deviation__c,
            batch_camp_max_lead_count__c = accountGSUsageData.batch_camp_max_lead_count__c,
            batch_camp_max_seconds__c = accountGSUsageData.batch_camp_max_seconds__c,
            batch_camp_total_lead_count__c = accountGSUsageData.batch_camp_total_lead_count__c,
            batch_camp_total_seconds__c = accountGSUsageData.batch_camp_total_seconds__c,
            batchcampcount__c = accountGSUsageData.batchcampcount__c,
            Branded_Tracking_Links__c = accountGSUsageData.Branded_Tracking_Links__c,
            Campaign_Analysis_Count__c = accountGSUsageData.Campaign_Analysis_Count__c,
            changedatavaluecount__c = accountGSUsageData.changedatavaluecount__c,
            changescorecount__c = accountGSUsageData.changescorecount__c,
            clicklinkcount__c = accountGSUsageData.clicklinkcount__c,
            CommunityIdea__c = accountGSUsageData.CommunityIdea__c,
            CommunityIdeaComment__c = accountGSUsageData.CommunityIdeaComment__c,
            CommunityLogins__c = accountGSUsageData.CommunityLogins__c,
            CommunityQuestion__c = accountGSUsageData.CommunityQuestion__c,
            CommunityQuestionComment__c = accountGSUsageData.CommunityQuestionComment__c,
            createtaskcount__c = accountGSUsageData.createtaskcount__c,
            Database_Size__c = accountGSUsageData.Database_Size__c,
            DataLoadId__c = accountGSUsageData.DataLoadId__c,
            Date__c = accountGSUsageData.Date__c,
            DKIM__c = accountGSUsageData.DKIM__c,
            Edition__c = accountGSUsageData.Edition__c,
            Email_Analysis_Count__c = accountGSUsageData.Email_Analysis_Count__c,
            emailbounced__c = accountGSUsageData.emailbounced__c,
            emailclicked__c = accountGSUsageData.emailclicked__c,
            emaildelivered__c = accountGSUsageData.emaildelivered__c,
            emailopened__c = accountGSUsageData.emailopened__c,
            emailsentcount__c = accountGSUsageData.emailsentcount__c,
            emailsoftbounced__c = accountGSUsageData.emailsoftbounced__c,
            emailunsubscribed__c = accountGSUsageData.emailunsubscribed__c,
            End_Week__c = accountGSUsageData.End_Week__c,
            filloutformcount__c = accountGSUsageData.filloutformcount__c,
            Inactive_Engagement_Count__c = accountGSUsageData.Inactive_Engagement_Count__c,
            InstanceId__c = accountGSUsageData.InstanceId__c,
            InstanceName__c = accountGSUsageData.InstanceName__c,
            known_lead_net_count__c = accountGSUsageData.known_lead_net_count__c,
            knownleadnetcount__c = accountGSUsageData.knownleadnetcount__c,
            Lead_Analysis_Count__c = accountGSUsageData.Lead_Analysis_Count__c,
            leadcount__c = accountGSUsageData.leadcount__c,
            Marketo_Logins__c = accountGSUsageData.Marketo_Logins__c,
            Marketo_Users__c = accountGSUsageData.Marketo_Users__c,
            Model_Performance_Company_Analysis_Count__c = accountGSUsageData.Model_Performance_Company_Analysis_Count__c,
            Model_Performance_Leads_Analysis_Count__c = accountGSUsageData.Model_Performance_Leads_Analysis_Count__c,
            New_Form_Net_Count__c = accountGSUsageData.New_Form_Net_Count__c,
            newleadcount__c = accountGSUsageData.newleadcount__c,
            Opportunity_Analysis_Count__c = accountGSUsageData.Opportunity_Analysis_Count__c,
            Opportunity_Influence_Analyzer_Count__c = accountGSUsageData.Opportunity_Influence_Analyzer_Count__c,
            Percent_Change__c = accountGSUsageData.Percent_Change__c,
            PrevAvg_Active_Engagement_Count__c = accountGSUsageData.PrevAvg_Active_Engagement_Count__c,
            PrevAvg_anonleadnetcount__c = accountGSUsageData.PrevAvg_anonleadnetcount__c,
            PrevAvg_anonwebvisitcount__c = accountGSUsageData.PrevAvg_anonwebvisitcount__c,
            PrevAvg_Balance_Black_Listed_Leads__c = accountGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c,
            PrevAvg_Balance_Bounced_Leads__c = accountGSUsageData.PrevAvg_Balance_Bounced_Leads__c,
            PrevAvg_Balance_Possible_Duplicates__c = accountGSUsageData.PrevAvg_Balance_Possible_Duplicates__c,
            PrevAvg_Balance_Unsubscribed_Leads__c = accountGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c,
            PrevAvg_batch_camp_count__c = accountGSUsageData.PrevAvg_batch_camp_count__c,
            PrevAvg_batch_camp_execution_average__c = accountGSUsageData.PrevAvg_batch_camp_execution_average__c,
            PrevAvg_batch_camp_execution_deviation__c = accountGSUsageData.PrevAvg_batch_camp_execution_deviation__c,
            PrevAvg_batch_camp_max_lead_count__c = accountGSUsageData.PrevAvg_batch_camp_max_lead_count__c,
            PrevAvg_batch_camp_max_seconds__c = accountGSUsageData.PrevAvg_batch_camp_max_seconds__c,
            PrevAvg_batch_camp_total_lead_count__c = accountGSUsageData.PrevAvg_batch_camp_total_lead_count__c,
            PrevAvg_batch_camp_total_seconds__c = accountGSUsageData.PrevAvg_batch_camp_total_seconds__c,
            PrevAvg_batchcampcount__c = accountGSUsageData.PrevAvg_batchcampcount__c,
            PrevAvg_Campaign_Analysis_Count__c = accountGSUsageData.PrevAvg_Campaign_Analysis_Count__c,
            PrevAvg_changedatavaluecount__c = accountGSUsageData.PrevAvg_changedatavaluecount__c,
            PrevAvg_changescorecount__c = accountGSUsageData.PrevAvg_changescorecount__c,
            PrevAvg_clicklinkcount__c = accountGSUsageData.PrevAvg_clicklinkcount__c,
            PrevAvg_CommunityIdea__c = accountGSUsageData.PrevAvg_CommunityIdea__c,
            PrevAvg_CommunityIdeaComment__c = accountGSUsageData.PrevAvg_CommunityIdeaComment__c,
            PrevAvg_CommunityLogins__c = accountGSUsageData.PrevAvg_CommunityLogins__c,
            PrevAvg_CommunityQuestion__c = accountGSUsageData.PrevAvg_CommunityQuestion__c,
            PrevAvg_CommunityQuestionComment__c = accountGSUsageData.PrevAvg_CommunityQuestionComment__c,
            PrevAvg_createtaskcount__c = accountGSUsageData.PrevAvg_createtaskcount__c,
            PrevAvg_Email_Analysis_Count__c = accountGSUsageData.PrevAvg_Email_Analysis_Count__c,
            PrevAvg_emailbounced__c = accountGSUsageData.PrevAvg_emailbounced__c,
            PrevAvg_emailclicked__c = accountGSUsageData.PrevAvg_emailclicked__c,
            PrevAvg_emaildelivered__c = accountGSUsageData.PrevAvg_emaildelivered__c,
            PrevAvg_emailopened__c = accountGSUsageData.PrevAvg_emailopened__c,
            PrevAvg_emailsentcount__c = accountGSUsageData.PrevAvg_emailsentcount__c,
            PrevAvg_emailsoftbounced__c = accountGSUsageData.PrevAvg_emailsoftbounced__c,
            PrevAvg_emailunsubscribed__c = accountGSUsageData.PrevAvg_emailunsubscribed__c,
            PrevAvg_End_Date__c = accountGSUsageData.PrevAvg_End_Date__c,
            PrevAvg_End_Week__c = accountGSUsageData.PrevAvg_End_Week__c,
            PrevAvg_filloutformcount__c = accountGSUsageData.PrevAvg_filloutformcount__c,
            PrevAvg_Inactive_Engagement_Count__c = accountGSUsageData.PrevAvg_Inactive_Engagement_Count__c,
            PrevAvg_known_lead_net_count__c = accountGSUsageData.PrevAvg_known_lead_net_count__c,
            PrevAvg_knownleadnetcount__c = accountGSUsageData.PrevAvg_knownleadnetcount__c,
            PrevAvg_Lead_Analysis_Count__c = accountGSUsageData.PrevAvg_Lead_Analysis_Count__c,
            PrevAvg_leadcount__c = accountGSUsageData.PrevAvg_leadcount__c,
            PrevAvg_Marketo_Logins__c = accountGSUsageData.PrevAvg_Marketo_Logins__c,
            PrevAvg_Marketo_Users__c = accountGSUsageData.PrevAvg_Marketo_Users__c,
            PrevAvg_Model_Performance_Comp_Analysis__c = accountGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c,
            PrevAvg_Model_Performance_Leads_Analysis__c = accountGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c,
            PrevAvg_New_Form_Net_Count__c = accountGSUsageData.PrevAvg_New_Form_Net_Count__c,
            PrevAvg_newleadcount__c = accountGSUsageData.PrevAvg_newleadcount__c,
            PrevAvg_Opportunity_Analysis_Count__c = accountGSUsageData.PrevAvg_Opportunity_Analysis_Count__c,
            PrevAvg_Opportunity_Influence_Analyzer__c = accountGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c,
            PrevAvg_Program_Analyzer_Count__c = accountGSUsageData.PrevAvg_Program_Analyzer_Count__c,
            PrevAvg_Program_Cost_Analysis_Count__c = accountGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c,
            PrevAvg_programcount__c = accountGSUsageData.PrevAvg_programcount__c,
            PrevAvg_Program_Membership_Analysis__c = accountGSUsageData.PrevAvg_Program_Membership_Analysis__c,
            PrevAvg_Program_Opportunity_Analysis__c = accountGSUsageData.PrevAvg_Program_Opportunity_Analysis__c,
            PrevAvg_Program_Revenue_Stage_Analysis__c = accountGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c,
            PrevAvg_programsynccount__c = accountGSUsageData.PrevAvg_programsynccount__c,
            PrevAvg_sessioncount__c = accountGSUsageData.PrevAvg_sessioncount__c,
            PrevAvg_SFDC_Logins__c = accountGSUsageData.PrevAvg_SFDC_Logins__c,
            PrevAvg_Start_Date__c = accountGSUsageData.PrevAvg_Start_Date__c,
            PrevAvg_Start_Week__c = accountGSUsageData.PrevAvg_Start_Week__c,
            PrevAvg_Success_Path_Analyzer_Count__c = accountGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c,
            PrevAvg_syncleadtosfdccount__c = accountGSUsageData.PrevAvg_syncleadtosfdccount__c,
            PrevAvg_Tickets_Created__c = accountGSUsageData.PrevAvg_Tickets_Created__c,
            PrevAvg_total_session_time__c = accountGSUsageData.PrevAvg_total_session_time__c,
            PrevAvg_total_soft_deleted_lead__c = accountGSUsageData.PrevAvg_total_soft_deleted_lead__c,
            PrevAvg_total_soft_deleted_pending_lead__c = accountGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c,
            PrevAvg_totalanonleadcount__c = accountGSUsageData.PrevAvg_totalanonleadcount__c,
            PrevAvg_Total_Engagement_Count__c = accountGSUsageData.PrevAvg_Total_Engagement_Count__c,
            PrevAvg_totalknownleadcount__c = accountGSUsageData.PrevAvg_totalknownleadcount__c,
            PrevAvg_usingcostperiodcount__c = accountGSUsageData.PrevAvg_usingcostperiodcount__c,
            PrevAvg_usingtagsexcludetagcount__c = accountGSUsageData.PrevAvg_usingtagsexcludetagcount__c,
            PrevAvg_visitwebpagecount__c = accountGSUsageData.PrevAvg_visitwebpagecount__c,
            PrevAvg_workspacecount__c = accountGSUsageData.PrevAvg_workspacecount__c,
            Processed__c = accountGSUsageData.Processed__c,
            Program_Analyzer_Count__c = accountGSUsageData.Program_Analyzer_Count__c,
            Program_Cost_Analysis_Count__c = accountGSUsageData.Program_Cost_Analysis_Count__c,
            programcount__c = accountGSUsageData.programcount__c,
            Program_Membership_Analysis_Count__c = accountGSUsageData.Program_Membership_Analysis_Count__c,
            Program_Opportunity_Analysis_Count__c = accountGSUsageData.Program_Opportunity_Analysis_Count__c,
            Program_Revenue_Stage_Analysis_Count__c = accountGSUsageData.Program_Revenue_Stage_Analysis_Count__c,
            programsynccount__c = accountGSUsageData.programsynccount__c,
            Purpose__c = accountGSUsageData.Purpose__c,
            sessioncount__c = accountGSUsageData.sessioncount__c,
            SFDC_Logins__c = accountGSUsageData.SFDC_Logins__c,
            Start_Date__c = accountGSUsageData.Start_Date__c,
            Start_Week__c = accountGSUsageData.Start_Week__c,
            Success_Path_Analyzer_Count__c = accountGSUsageData.Success_Path_Analyzer_Count__c,
            Support_Engineer__c = accountGSUsageData.Support_Engineer__c,
            Support_Level__c = accountGSUsageData.Support_Level__c,
            syncleadtosfdccount__c = accountGSUsageData.syncleadtosfdccount__c,
            Tickets_Created__c = accountGSUsageData.Tickets_Created__c,
            Tickets_Currently_Open__c = accountGSUsageData.Tickets_Currently_Open__c,
            total_session_time__c = accountGSUsageData.total_session_time__c,
            total_soft_deleted_lead__c = accountGSUsageData.total_soft_deleted_lead__c,
            total_soft_deleted_pending_lead__c = accountGSUsageData.total_soft_deleted_pending_lead__c,
            totalanonleadcount__c = accountGSUsageData.totalanonleadcount__c,
            Total_Certifications__c = accountGSUsageData.Total_Certifications__c,
            Total_Courses__c = accountGSUsageData.Total_Courses__c,
            Total_Engagement_Count__c = accountGSUsageData.Total_Engagement_Count__c,
            totalknownleadcount__c = accountGSUsageData.totalknownleadcount__c,
            Usage_Data_Key__c = accountGSUsageData.Usage_Data_Key__c,
            User__c = accountGSUsageData.User__c,
            usingcostperiodcount__c = accountGSUsageData.usingcostperiodcount__c,
            usingtagsexcludetagcount__c = accountGSUsageData.usingtagsexcludetagcount__c,
            visitwebpagecount__c = accountGSUsageData.visitwebpagecount__c,
            Week_Group4_Number__c = accountGSUsageData.Week_Group4_Number__c,
            Week_Start_Year__c = accountGSUsageData.Week_Start_Year__c,
            workspacecount__c = accountGSUsageData.workspacecount__c
         );
         return tempContactUsageData;
     } 
}