public class RenewalTriggerMappingController
{

    public static Opportunity MapFields(Opportunity o)
    {
        Opportunity newOpp = new Opportunity();
         newOpp.AccountId = o.AccountId;
                   // newOpp.Amount = o.Amount;
                    newOpp.Description = o.Description;
                  //  newOpp.ExpectedRevenue = o.ExpectedRevenue;
                    newOpp.LeadSource = o.LeadSource;
                    newOpp.NextStep = o.NextStep;
                    newOpp.CurrencyIsoCode = o.CurrencyIsoCode;
                    newOpp.CampaignId = o.CampaignId;
                    newOpp.IsPrivate = o.IsPrivate;
                    newOpp.X3_9_End_Date__c = o.X3_9_End_Date__c;
                    newOpp.Accounting_Contact__c = o.Accounting_Contact__c;
                    newOpp.Accounting_Email__c = o.Accounting_Email__c;
                    newOpp.Accounting_Phone__c = o.Accounting_Phone__c;
                    newOpp.Account_String__c = o.Account_String__c;
                    newOpp.Actual_Close_Date__c = o.Actual_Close_Date__c;
                    newOpp.Actual_Create_Date__c = o.Actual_Create_Date__c;
                    newOpp.Additional_Requests__c = o.Additional_Requests__c;
                    newOpp.Assigned_CEM__c = o.Assigned_CEM__c;
                    newOpp.Assigned_Consultant_Email__c =o.Assigned_Consultant_Email__c;
                    newOpp.Assignment_Email_Project_Type__c = o.Assignment_Email_Project_Type__c;
                    newOpp.Assignment_Email_Sent__c = o.Assignment_Email_Sent__c;
                    newOpp.Average_Monthly_Email_Volume__c = o.Average_Monthly_Email_Volume__c;
                    newOpp.Billed_Services__c = o.Billed_Services__c;
                    newOpp.Payment_Frequency__c = o.Payment_Frequency__c;
                    newOpp.CF_Opp_Id__c = o.CF_Opp_Id__c;
                    newOpp.Channel__c = o.Channel__c;
                    newOpp.Compelling_Event__c = o.Compelling_Event__c;
                    newopp.MainCompetitor__c = o.MainCompetitor__c;
                    newOpp.Competitor_Swap__c = o.Competitor_Swap__c;
                    newOpp.Contract_Sign_Date__c = o.Contract_Sign_Date__c;
                    newOpp.Corp_Currency_Amount__c = o.Corp_Currency_Amount__c;
                    newOpp.CRM_System__c = o.CRM_System__c;
                    newopp.Contact_Database_Size__c = o.Contact_Database_Size__c;
                    newOpp.Days_Since_Lead_Created__c = o.Days_Since_Lead_Created__c;
                    newopp.Days_Since_Lead_Promotion__c = o.Days_Since_Lead_Promotion__c;
                    newOpp.Days_to_Sales_Lead__c = o.Days_to_Sales_Lead__c;
                    newOpp.DealLostReason__c = o.DealLostReason__c;
                    newOpp.Deal_Type__c = o.Deal_Type__c;
                    newOpp.Deal_Won_By__c = o.Deal_Won_By__c;
                    newOpp.Demo_Type__c = o.Demo_Type__c;
                    //newOpp.Discount_RUSF__c = o.Discount_RUSF__c;
                    newOpp.Discount_Type__c = o.Discount_Type__c;
                    newOpp.Ease_of_Renewal__c = o.Ease_of_Renewal__c;
                    newOpp.Employee_Range_Summary__c = o.Employee_Range_Summary__c;
                    newOpp.Enablement_Close_Notes__c = o.Enablement_Close_Notes__c;
                    newOpp.Enablement_Project_Stage__c = o.Enablement_Project_Stage__c;
                    newOpp.ExistingLandingPage__c = o.ExistingLandingPage__c;
                    newopp.Forecast_Category__c = o.Forecast_Category__c;
                    newOpp.Forecast_Category_Probability__c = o.Forecast_Category_Probability__c;
                    newopp.Service_Only__c = o.Service_Only__c;
                    newOpp.Intacct_Entity__c = o.Intacct_Entity__c;
                    newopp.Intacct_Sales_Region__c = o.Intacct_Sales_Region__c;
                    
                    newOpp.Lead_Buying_Behavior__c = o.Lead_Buying_Behavior__c;
                    newopp.Lead_Category__c = o.Lead_Category__c;
                    newOpp.Lead_Promotion_Date__c = o.Lead_Promotion_Date__c;
                    newOpp.Lead_Source_Comments__c = o.Lead_Source_Comments__c;
                    newOpp.Lead_Source_Summary__c = o.Lead_Source_Summary__c;
                    newOpp.Loss_Description__c = o.Loss_Description__c;
                    newOpp.Primary_Enablement_Partner__c = o.Primary_Enablement_Partner__c;
                    newOpp.Marketo_Login__c = o.Marketo_Login__c;
                    newOpp.Marketo_Password__c = o.Marketo_Password__c;
                    newOpp.Marketo_Subscription_Plan__c = o.Marketo_Subscription_Plan__c;
                    newOpp.Marketo_Subscription_Subplan__c = o.Marketo_Subscription_Subplan__c;
                    newOpp.Maximum_Database_Size__c = o.Maximum_Database_Size__c;
                    newOpp.MP_Purpose__c = o.MP_Purpose__c;
                    newopp.MP_Reseller_Partner__c = o.MP_Reseller_Partner__c;
                    newOpp.MP_Sandbox__c = o.MP_Sandbox__c;
                    newOpp.Munchkin_ID__c = o.Munchkin_ID__c;
                    newOpp.Needs_Pains__c = o.Needs_Pains__c;
                    newOpp.Needs_Internal_Kickoff_Meeting__c = o.Needs_Internal_Kickoff_Meeting__c;
                    newOpp.Non_standard_Payment_Terms__c = o.Non_standard_Payment_Terms__c;
                    newopp.Lead_Notes__c = o.Lead_Notes__c;
                    newOpp.Partner_Involved_del__c = o.Partner_Involved_del__c;
                    newOpp.OA_Product_Purchased_del__c = o.OA_Product_Purchased_del__c;
                    newopp.OpenAir_Percent_Complete_del__c = o.OpenAir_Percent_Complete_del__c;
                    newopp.Opportunity_ARR__c = o.Opportunity_ARR__c;
                    newOpp.Opportunity_Count__c = o.Opportunity_Count__c;
                    
                    newOpp.Opportunity_Source__c = o.Opportunity_Source__c;
                    newOpp.Original_Lead_Created_Date__c     = o.Original_Lead_Created_Date__c  ;
                    newopp.OA_Partner_Involved__c = o.OA_Partner_Involved__c;
                    newOpp.Payment_Terms__c = o.Payment_Terms__c;
                    newOpp.Pay_Referral__c = o.Pay_Referral__c;
                    newOpp.Perceived_Customer_Value__c = o.Perceived_Customer_Value__c;
                    newOpp.POC_Prov_Email_Sent__c = o.POC_Prov_Email_Sent__c;
                    newOpp.POD__c = o.POD__c;
                    newOpp.PO_Number__c = o.PO_Number__c;
                    newOpp.Primary_Marketo_User_Email__c = o.Primary_Marketo_User_Email__c ;
                    newOpp.Primary_Marketo_User_Lookup__c = o.Primary_Marketo_User_Lookup__c ;
                    newOpp.Primary_Marketo_User_Phone__c  = o.Primary_Marketo_User_Phone__c  ;
                    newOpp.Product_SVS__c   = o.Product_SVS__c   ;
                    newOpp.Product_Info__c = o.Product_Info__c;
                    newOpp.Product_Interest__c = o.Product_Interest__c;
                    newOpp.Project_Classification__c = o.Project_Classification__c  ;
                    newOpp.Enablement_Completion_Date__c = o.Enablement_Completion_Date__c;
                    newOpp.ServicesNotes__c = o.ServicesNotes__c;
                    newopp.Enablement_Percent_Completed__c = o.Enablement_Percent_Completed__c;
                    newOpp.Project_Stage__c = o.Project_Stage__c;
                    newOpp.Project_Start_Date__c = o.Project_Start_Date__c;
                    newOpp.Project_Temperature__c = o.Project_Temperature__c;
                    newOpp.ProjectType__c = o.ProjectType__c;
                    newopp.Project_Type__c = o.Project_Type__c;
                    newOpp.Provisioning_Email_Sent__c = o.Provisioning_Email_Sent__c;
                    newOpp.Qualified_Meeting__c = o.Qualified_Meeting__c;
                    newOpp.Quarterly_Renewal__c = o.Quarterly_Renewal__c;
                    newOpp.Quote_Expiration_Date__c = o.Quote_Expiration_Date__c;
                    newOpp.Referral_Partner__c = o.Referral_Partner__c;
                    newopp.RequestedKickoffDate__c = o.RequestedKickoffDate__c;
                    newOpp.RT__c = o.RT__c;
                    newOpp.Sales_Lead_Date__c = o.Sales_Lead_Date__c;
                    newOpp.Sales_Lead_Type__c = o.Sales_Lead_Type__c;
                    newOpp.Sales_Outbound_Notes__c = o.Sales_Outbound_Notes__c;
                    newOpp.Sales_Probability__c = o.Sales_Probability__c;
                    newOpp.SC_Enablement_Notes__c = o.SC_Enablement_Notes__c;
                    newOpp.SDR_Owner__c = o.SDR_Owner__c;
                    newOpp.SDR_Owner_Look_Up__c = o.SDR_Owner_Look_Up__c;
                    newOpp.Search_String__c = o.Search_String__c;
                    newOpp.Sent_to_Clarizen__c = o.Sent_to_Clarizen__c;
                    newopp.Services_Required__c = o.Services_Required__c;
                    newOpp.SFDC_Edition__c = o.SFDC_Edition__c;
                    newOpp.SFDC_User__c =o.SFDC_User__c;
                    newOpp.SFDC_Users__c = o.SFDC_Users__c;
                    newOpp.Solutions_Consultant_Email__c = o.Solutions_Consultant_Email__c;
                    newOpp.Solutions_Consultant_Lookup__c = o.Solutions_Consultant_Lookup__c;
                    newOpp.Split_Opportunities__c = o.Split_Opportunities__c;
                    newOpp.Tracking_URL__c = o.Tracking_URL__c;
                    newOpp.Web_Traffic__c = o.Web_Traffic__c;
                   return newOpp;
    }
    public static testmethod void Dotest()
    {
        Opportunity  o = new Opportunity();
        RenewalTriggerMappingController.Mapfields(o);
        
    }
}