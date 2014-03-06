/**
 *    Description  :  Class to hold constant properties.       
 *    
 *    Created By   : 
 *
 *    Created Date :   01/20/2014
 *
 *    Revision Log :   V_1.0 - Created.
 *
 **/
public with sharing class Constants {
	
	//Variables
	public static final String ACCOUNT_TYPE_CUSTOMER_OF_AGENCY = 'Customer of Agency';
	public static final String ASSIGNMENT_RULE_NAME_ACCOUNT_CSM_ASSIGNMENT_REV = 'Account CSM Assignment Rev';
	public Static final String ACCOUNT_BUSINESS_UNIT_SB = 'SB';
	public Static final String ACCOUNT_TEMPERATURE_GREEN = 'Green';
	public Static final String ACCOUNT_TEMPERATURE_RED = 'Red';
	public Static final String ACCOUNT_TEMPERATURE_YELLOW = 'Yellow';
	public Static final String OPPORTUNITY_TYPE_NEW_BUSINESS = 'New Business';
	public Static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
	public Static final String ACCOUNTSCORERSETTINGS_SETTINGSMODE_ON = 'on';
	public Static final String ACCOUNT_CSM_TRIGGER_ELITE_KEY = 'Elite/Key';
	public Static final String ACCOUNT_CSM_TRIGGER_STANDARD = 'Standard';
	public Static final String ACCOUNT_CSM_TRIGGER_ENTERPRISE = 'Enterprise';
	public Static final String ACCOUNT_TYPE_PARTNER = 'Partner';
	public Static final String ACCOUNT_MLM_EDITION_ENTERPRISE = 'Enterprise';
	public Static final String ACCOUNT_MLM_EDITION_SPARK = 'Spark';
	public Static final String ACCOUNT_MLM_EDITION_PROFESSIONAL = 'Professional';
	public Static final String ACCOUNT_MLM_EDITION_SMB = 'SMB';
	public Static final String CONTACT_IS_AUTHORIZED_CONTACT = 'Yes';
	public Static final String CONTACT_JBCXM_CATEGORY_MILESTONE = 'Milestones';
	public Static final String CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_CLASSROOM = 'Foundation Classroom';
	public Static final String CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_VIRTUAL = 'Foundation Virtual';
	public Static final String CONTACT_STRING_SYNCHWITHBOULDERLOGIC = 'synchwithboulderlogic';
	public Static final String OPPORTUNITY_STAGENAME_CLOSED_WON = 'Closed Won';
	public Static final String OPPORTUNITY_USER_NAME_RENEWAL_TEAM = 'Renewals Team';
	public Static final String OPPORTUNITY_TYPE_RENEWAL = 'Renewal';
	public Static final String OPPORTUNITY_TYPE_UPSELL_CROSSELL = 'Upsell/Crossell';
	public Static final String OPPORTUNITY_TYPE_RENEWAL_SALES = 'Renewal Sales';
	public Static final String OPPORTUNITY_TYPE_STAGENAME_NOT_CONTACTED = 'Not Contacted';
	public Static final String OPPORTUNITYLINEITEM_PRODUCT_SERVICES = 'Services';
	public Static final String RECORDTYPE_DEVELOPERNAME_DTO = 'DTO';
	public Static final String SFDC_OPPTY_RECORDTYPE_CLOSED_WON = 'Closed_Won';
	public Static final String CASE_PRIORITY_P1 = 'P1';
	public Static final String PRODUCT_CONVERTTO_ADD_ON = 'Add On';
	public Static final String PRODUCT_CONVERTTO_SUBSCRIPTION = 'Subscription';
	public Static final String BUISNESSHOURS_NAME_P1_ISSUES = 'P1 Issues';
	public Static final String ASSET_PURPOSE_PRODUCTION = 'Production';
	public Static final String OPPORTUNITY_NAME_01R = '-01R';
	public Static final String OPPORTUNITY_NAME_02R = '-02R';
	public Static final String OPPORTUNITY_NAME_03R = '-03R';
	public Static final String OPPORTUNITY_PRODUCT_NAME_SANDBOX = 'Sandbox';
	public Static final String ACCOUNT_NAME_MARKETO = 'Marketo';
	public Static final String ACCOUNT_NAME_MKTO = 'MKTO';
	public Static final String ACCOUNT_NAME_INTERNAL_DEMO = 'Internal Demo';
	public Static final String OPPORTUNITY_DEAL_TYPE_TRAIL = 'Trial';
	public Static final String PRODUCT_FAMILY_SALES_INSIGHT = 'Sales Insight';
	public Static final String PRODUCT_PRODUCTCODE_LM_SAND = 'LM-SAND';
	public Static final String PRODUCT_CONVERTTO_ENTITLEMENT_SPARK = 'Entitlement-Spark';
	public Static final String PRODUCT_CONVERTTO_ENTITLEMENT_PREMIER = 'Entitlement-Premier';
	public Static final String PRODUCT_CONVERTTO_ENTITLEMENT_ELITE = 'Entitlement-Elite';
	public Static final String ACCOUNT_PARTNER_TYPE_REFERRAL = 'Referral';
	public Static final String ACCOUNT_PARTNER_TYPE_AGENCY = 'Agency';
	public Static final String ACCOUNT_PARTNER_TYPE_PREFERRED_SERVICES = 'Preferred Services';
	public Static final String ACCOUNT_PARTNER_TYPE_RESELLER = 'Reseller';
	public Static final String CASE_MILESTONENAME_FIRST_RESPONSE = 'First Response';
	public Static final String CASE_MILESTONENAME_CASE_UPDATE = 'Case Update';
	public Static final String CASE_MILESTONENAME_RESOLUTION = 'Resolution';
	public Static final String Case_ORIGIN_EMAIL = 'Email';
	public Static final String USER_TYPE_STANDARD = 'Standard'; 
	public Static final String CASE_ORIGIN_PHONE = 'Phone';
	public Static final String JBCXM_PICKLIST_SYSTEM_NAME_ALERTSEVERITY = 'alertseverity2';
	public Static final String JBCXM_PICKLIST_SYSTEM_NAME_ID ='ID';
	public Static final String JBCXM_PICKLIST_SYSTEM_NAME_OPENCASE ='OpenCase';
	public Static final String JBCXM_PICKLIST_SYSTEM_NAME_CUSTOMER_CONCERN ='Customer Concern';
	public Static final String CASE_STATUS_CLOSED = 'Closed';
	public Static final String CASE_FIELD_PRIORITY = 'Priority';
	public Static final String CASE_ORGIN_TBD = 'TBD';
	public Static final String CASE_DEFAULT_ENGLISH = 'ENGLISH';
	public Static final String CASE_DEFAULT_ALWAYS = 'ALWAYS';
	public Static final String CASE_DEFAULT_NEVER = 'NEVER';
	public Static final String ORGWIDEEMAILADDRESS_NAME_MARKETO_SUPPORT_FEEDBACK = 'Marketo Support Feedback';
	public Static final String CASE_RECORD_TYPE_NAME_SUPPORT_EMAIL_TO_CASE = 'Support Email to Case';
	public Static final String CASE_ACCOUNT_TYPE_EX_CUSTOMER = 'Ex-Customer';
	public Static final String CASE_ACCOUNT_TYPE_EX_PARTNER = 'Ex-Partner';
	public Static final String NAME_BILL = 'Bill';
	public Static final String CASE_RECORD_TYPE_DEVELOPER_NAME_SUPPORT_CUSTOMER_PORTAL_CASE = 'Support_Customer_Portal_Case';
	public Static final String CASE_RECORD_TYPE_DEVELOPER_NAME_SUPPORT_EMAIL_TO_CASE = 'Support_Email_to_Case';
	public Static final String CASE_PROBLEM_TYPE_CONFIGURATION = 'Configuration/Set Up';
	public Static final String CASE_CATEGORY_CONFIGURATION_OUTREACH = 'Configuration Outreach';
	public Static final String TASK_TYPE_CSM_UPSELL_PRODUCT_ONLY ='CSM – Upsell/Cross sell Product';
	public Static final String TASK_TYPE_CSM_UPSELL_SERVICES = 'CSM - Upsell/Cross sell Services';
	public Static final String ASSET_STATUS_ACTIVE = 'Active';
	public Static final String DEVELOPER_NAME_DUPLICATEUSERNOTIFICATIONTEMPLATE= 'DuplicateUserNotificationTemplate';
	public Static final String USER_TYPE_CUSTOMER = 'customer';
	public Static final String USER_TIME_ZONE_SETTING = 'Setting';
	public Static final String IDEA_STATUS_DONE = 'Done!';
	public Static final String IDEA_STATUS_DONE_PARTIALLY = 'Done (Partially)';
	public Static final String IDEA_DEVELOPER_NAME_MARKETO_STATUS= 'Marketo_Community_Idea_Status';
	public static final String OPPORTUNITY_STAGENAME_CLOSED_LOST = 'Closed Lost';
	
	//Variables for custom settin data
	public static final String CONFIG_MANAGER_PARAMETER_KEY_IGNORENONPORTALADMINFROMCOMPLETEMILESTOTE ='IgnoreNonPortalAdminFromCompleteMilestote';
	public static final String CONFIG_MANAGER_PARAMETER_KEY_CAMPAIGNSTARTDATE = 'CampaignStartDate';
	public static final String CONFIG_MANAGER_PARAMETER_KEY_OPPORTUNITYPRICEBOOKENTRYPRODUCTCODE = 'OpportunityPriceBookEntryProductCode';
	
	//Variables for SlaProcess and BusinessHours name
	public Static final String SlaProcess_Name_Standard_Support = 'Standard Support';
	
	//Variables for Campaign and CampaignMember object
	public Static final String CAMPAIGNMEMBER_STATUS_ATTENDED = 'Attended';
	public Static final String CAMPAIGNMEMBER_STATUS_SENT = 'Sent';
	public Static final String CAMPAIGN_NAME_USER_GROUP_ATTENDEES = 'User Group Attendees';
	
	//Varibale for EmailMessage object
	public static final String EMAILMESSAGE_SUBJECT_REF = 'ref:_';
	public static final String CASE_RECORDTYPE_DEVELPOER_NAME_SUPPORT_CASES = 'Support_Cases';
	public static final String EMAILMESSAGE_COMMENT_BODY_MARKETO_CUSTOMER_SUPPORT = 'Marketo Customer Support <';
	public static final String EMAILMESSAGE_COMMENT_BODY_CONTAINS_ON = 'on';
	public static final String CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT = 'Situation_Management_Support';
	public static final String CASE_RECORDTYPE_DEVELOPERNAME_SITUATION_MANAGEMENT_SUPPORT_FEEDBACK = 'Situation_Management_Support_Feedback';
	public static final String QUEUE_NAME_SUPPORT_FEEDBACK_QUEUE = 'Support Feedback Queue';
	public static final String QUEUE_NAME_SUPPORT_ESCALATIONS_QUEUE = 'Support Escalations Queue';
	public static final String EmailMessage_SUBJECT_CASE = 'Case #';
	
	//Variables for Quote and QuoteLineItem object
	public static final String PRODUCT_EDITION_ENTERPRISE = 'Enterprise';
	public static final String PRODUCT_NAME_LAUNCH_PACK = 'Launch Pack';
	public static final String QUOTE_APPROVAL_APPROVED = 'Approved';
	public static final String QUOTE_APPROVAL_APPROVAL_NEEDED = 'Approval Needed';
	public static final String PRODUCT_PRODUCTCODE_INT_CUST = 'INT-CUST';
	public static final String PRODUCT_PRODUCTCODE_SV_SOW = 'SV-SOW';
	
	//Variables for Idea, Question and Reply object
	public static final String IDEA_LINK_VALUE = '/ideas/viewIdea.apexp?id=';
	public static final String IDEA_TYPE_IDEA = 'Idea';
	public static final String IDEA_TYPE_IDEA_COMMENT = 'IdeaComment';
	public static final String COMMUNITY_ACTIVITY_TYPE = 'Question';
	public static final String COMMUNITY_ACTIVITY_TYPE_QUESTIONCOMMENT = 'QuestionComment';
	public static final String REPLYIDEASCHEDULERLOG_TYPE_REPLYPOSTED = 'ReplyPosted';
	
	//Variables for Approval Request
	public static final String APPROVAL_REQUEST_STATUS_APPROVED = 'Approved';
	public static final String APPROVAL_REQUEST_STATUS_REJECTED = 'Rejected';
	public static final String APPROVAL_REQUEST_STATUS_REDIRECTED = 'Redirected';
	public static final String APPROVAL_REQUEST_STATUS_ASSIGNED = 'Assigned';
	public static final String APPROVAL_REQUEST_STATUS_CANCELLED = 'Cancelled';
	public static final String APPROVAL_REQUEST_AUTO_APPROVED	='Auto-Approved';
	public static final String APPROVAL_REQUEST_LEGAL_APPROVAL ='Legal Approval';
	public static final String APPROVAL_REQUEST_FINANCIAL_APPROVAL ='Finance Approval';
    public static final String APPROVAL_REQUEST_SALES_TERMS_APPROVAL ='Sales Terms Approval' ;
    public static final String APPROVAL_REQUEST_OPERATION_APPROVAL = 'Operations Approval';
    public static final String APPROVAL_REQUEST_PROFESSIONAL_SERIVCES_APPROVAL ='Professional Services Approval';
    public static final String APPROVAL_REQUEST_SUPPORT_APPROVAL = 'Support Approval';
    public static final String APPROVAL_REQUEST_SALES_DISCOUNT_APPROVAL = 'Sales Discount Approval';
    public static final String APPROVAL_REQUEST_SALES_OPERATION_QA = 'Sales Operations QA';
    public static final String APPROVAL_REQUEST_DECLINED = 'Declined';
    public static final String APPROVAL_REQUEST_NOT_SUBMITTED = 'Not Submitted';
    public static final String APPROVAL_REQUEST_APPROVAL_PENDING = 'Approval Pending';
    public static final String APPROVAL_REQUEST_PENDING_APPROVAL = 'Pending Approval';
    public static final String APPROVAL_REQUEST_APPROVAL_NEEDED = 'Approval Needed';
    public static final String APPROVAL_REQUEST_QUOTE = 'Quote';
     
	//variable for Community History object
	public static final String CHISTORY_EXAM_RESULT_PASS = 'Pass';
	public static final String JBCXM_PICKLIST_SYSTEMNAME_MARKETO_CERTIFIED = 'Marketo Certified';
	
	//Variable for Task and TaskClone Object
	public static final String TASK_SUBJECT_ADD_CSM_TO_OPPORTUNITY_TEAM = 'Add CSM to opportunity team';
	public static final String TASK_TYPE_AE_CSM_FOLLOWUP = 'AE- CSM Followup';
	
	//Variable for CSatSurveyFeedback Object
	public static final String CSATSURVEY_SOBJECT = 'case';
	public static final String CSATSURVEY_DEVELOPERNAME = 'Situation Management - Support';
	public static final String CSATSURVEY_SUBJECT_STRING = 'Dissatisfied Survey Response on Case # ';
	public static final String CSATSURVEY_TYPE_SURVEY_FOLLOW_UP = 'Survey Follow-up';
	public static final String CSATSURVEY_JBCXM_SYSTEMNAME_CSAT ='CSAT Support Survey';
	
	//variable for Clarizen Projects
	public static final String CLARIZEN_PROJECT_FAMILY_MLMLP ='MLMLP';
	public static final String CLARIZEN_JBCXM_PICKLIST_PROJ_DUE = 'Proj Due';
	public static final String CLARIZEN_JBCXM_PICKLIST_PROJ_START = 'Proj Start';
	public static final String CLARIZEN_JBCXM_PICKLIST_PROJ_COMPL = 'Proj Compl';
	public static final String CLARIZEN_COMPLETED = 'Completed';
    public static final String CLARIZEN_AMERSB = 'AMER-SB';
    public static final String CLARIZEN_AMERMM = 'AMER-MM';
	
	//Variables for Roster Session,Roster,class and  Support News object
	public static final String ROSTER_SESSION_STATUS_ATTENDED = 'Attended';
	public static final String ROSTER_SESSION_STATUS_NOT_ATTENDED = 'Not Attended';
	public static final String COMMUNITY_SUBSCRIPTION_TYPE_NEWS_AND_ALERTS = 'News and Alerts';
	public static final String SUPPORT_NEWS_TYPE_NEWS = 'News';
	public static final String SUPPORT_NEWS_TYPE_ALERT = 'Alert';
	public static final String CONFIG_MANAGER_PARAMETER_KEY_PARTNERACCOUNT = 'PartnerAccount';
	public static final String ASSET_TYPE_SUBSCRIPTION = 'Subscription';
	
	//Variables for MKT Assign Queue
	public static final String CLASSNAME_MKT_BATCHASSIGN = 'MKT_BatchAssign';
	public static final String CLASSNAME_BATCHREGISTERFORTRAINING = 'BatchRegisterForTraining';
	public static final String CLASSNAME_BATCHUNREGISTERFORTRAINING = 'BatchUnRegisterForTraining';
	public static final String MKT_STATUS_PENDING = 'Pending';
	public static final String ASYNC_JOB_TYPE_BATCHAPEX = 'BatchApex';
	public static final String ASYNC_JOB_TYPE_QUEUED = 'Queued';
	public static final String ASYNC_JOB_TYPE_PROCESSING = 'Processing';
	
	//Variables for Roaster 
	public static final String ROASTER_SEQUENCE_ANYTIME = 'Anytime';
	public static final String ROASTER_SEQUENCE_AFTER = 'After';
	public static final String ROASTER_SEQUENCE_BEFORE = 'Before';
	
	//Variables for Training Path
	public static final String TRAINING_STATUS_IN_CART = 'In Cart'; 
	public static final String  CONFIG_MANAGER_PARAMETER_KEY_EXCLUDEDSALESINVOICEDOCUMENTTYPE = 'ExcludedSalesInvoiceDocumentType';
	
	//Variables for Sales Invoice
	public static final String SALES_INVOICE_DOC_TYPE_REVENUE_RECOGNITION_ACTIVATION = 'Revenue Recognition Activation'; 
	
	//Default Assignment Rule
	public static String DEFAULT_ASSIGNMENTRULE {
		
		get {
			
			//Query through Assignemt Rule
			List<Assignment_Rule__c> assRule = [Select User__c From Assignment_Rule__c where Business_Unit__c = 'n/a' AND Country__c = 'n/a' 
												AND State__c = 'n/a' and Zip5__c = 'n/a' LIMIT 1];
			//Check for list size
			if(assRule.size() > 0)
				return assRule[0].User__c;
			return null;
		}
	}
	
	//Get AccountScorerSettings  data
    public static Map<String,AccountScorerSettings__c> ACCOUNTSCORERSETTINGS {
        get {
			
			//Instalize map
            Map<String,AccountScorerSettings__c> accScoreConfig = new Map<String,AccountScorerSettings__c>();
            
            //Get AccountScorerSettings__c
            accScoreConfig = AccountScorerSettings__c.getAll();
            
            //Return config
            return accScoreConfig;
        }
    }
    
    //Get List_of_Elite_Products__c(custom setting)  data
    public static Map<String,List_of_Elite_Products__c> OPPORTUNITY_ELITE_PRODUCT_CUSTOM_SETTING {
        get {
			//Instalize map
            Map<String,List_of_Elite_Products__c> mapOfEliteProduct = new Map<String, List_of_Elite_Products__c>();
            
            //Get List_of_Elite_Products__c
            mapOfEliteProduct = List_of_Elite_Products__c.getAll();
			
			//Return config
            return mapOfEliteProduct;
        }
    }
    
    //Fetch Ignore and non ignore case Status values from Custom Settings
    public static Map<String,Case_Statuses__c> MAP_CASE_STATUSES {
    	
    	get {
    		
    		//Instalize map
    		Map<String,Case_Statuses__c> mapCaseStatus = new Map<String,Case_Statuses__c>();
    		
    		//Get All values
    		mapCaseStatus = Case_Statuses__c.getAll();
    		
    		//Return
    		return mapCaseStatus;
    	}
    }
    //Get Excluded Sales Order Document Type  data(custom setting)
    public static Map<String,Excluded_Sales_Order_Document_Type__c> SALESORDERSETTINGS {
        get {
			
			//Instalize map
            Map<String,Excluded_Sales_Order_Document_Type__c> salesOrder = new Map<String,Excluded_Sales_Order_Document_Type__c>();
            
            //Get AccountScorerSettings__c
            salesOrder = Excluded_Sales_Order_Document_Type__c.getAll();
            
            //Return config
            return salesOrder;
        }
    }
    
    //Get CSatSurveySettings__c(custom setting)  data
    public static Map<String,CSatSurveySettings__c> CSATSURVEYSETTINGS_CUSTOM_SETTING {
        get {
			//Instalize map
            Map<String,CSatSurveySettings__c> mapCSatSurveySettings = new Map<String, CSatSurveySettings__c>();
            
            //Get List_of_Elite_Products__c
            mapCSatSurveySettings = CSatSurveySettings__c.getAll();
			
			//Return config
            return mapCSatSurveySettings;
        }
    }
    
    //Get CustomMilestoneSettings__c(custom setting)  data
    public static Map<String,CustomMilestoneSettings__c> CUSTOMMILESTONESETTING_CUSTOM_SETTING {
        get {
			//Instalize map
            Map<String,CustomMilestoneSettings__c> mapCustomMileStoneSettings = new Map<String, CustomMilestoneSettings__c>();
            
            //Get List_of_Elite_Products__c
            mapCustomMileStoneSettings = CustomMilestoneSettings__c.getAll();
			
			//Return config
            return mapCustomMileStoneSettings;
        }
    }
    
    //Get CustomMilestoneSettings__c(custom setting)  data
    public static Map<String,UserTimeZoneUpdate__c> USERTIMEZONEUPDATE_CUSTOM_SETTING {
        get {
			//Instalize map
            Map<String,UserTimeZoneUpdate__c> mapUserTimeZoneUpdateSettings = new Map<String, UserTimeZoneUpdate__c>();
            
            //Get List_of_Elite_Products__c
            mapUserTimeZoneUpdateSettings = UserTimeZoneUpdate__c.getAll();
			
			//Return config
            return mapUserTimeZoneUpdateSettings;
        }
    }
    
    //Get Quote_Approvers__c(custom setting)  data
    public static Map<String,Quote_Approvers__c> QUOTE_APPROVERS_CUSTOM_SETTING{
        get {
			//Instalize map
            Map<String,Quote_Approvers__c> mapQuoteApproverCustomSetting = new Map<String, Quote_Approvers__c>();
            
            //Get List User
            mapQuoteApproverCustomSetting = Quote_Approvers__c.getAll();
			
			//Return config
            return mapQuoteApproverCustomSetting;
        }
    }
   
    //Get Product_Family__c(custom setting)  data
    public static Map<String,Product_Family__c> MAP_PRODUCT_FAMILY {
        get {

            //Instalize map
            Map<String,Product_Family__c> mapProductFamily = new Map<String,Product_Family__c>();
            
            //Loop through Product_Family__c
            for(Product_Family__c pFamily : Product_Family__c.getAll().values()) {
            	
            	//Populate map with values
            	mapProductFamily.put(pFamily.Product_Family_key__c, pFamily);
            }
			
			//Return config
            return mapProductFamily;
        }
    }
    
    //Get Sales_region__c(Custom Setting) data
    public static Map<String, Sales_region__c> MAP_SALES_REGION {
    	get {
    		
    		//Instalize map
            Map<String,Sales_region__c> mapSalesRegion = new Map<String,Sales_region__c>();
            
            //Loop through Sales_region__c
            for(Sales_region__c sRegion : Sales_region__c.getAll().values()) {
            	
            	//Populate map with values
            	mapSalesRegion.put(sRegion.Support_region_key__c, sRegion);
            }
            
            //Return
            return mapSalesRegion;
    	}
    }
  
	//Collection of Account's Type to update customer success Manager And New Business Account Executive 
  	public Static final Set<String> SET_ACCOUNT_TYPE = new Set<String> {
  																		'Customer',
  																		'Customer of Reseller Partner',
  																		'Customer & Partner',
  																		'Customer of Agency'
  																		};
  	
  	//Collection of Account's Temperature
  	public static final Set<String> SET_ACCOUNT_TEMPERATURE = new Set<String> {
  																			   'Green',
  																			   'Unknown',
  																			   'Engaging',
  																			   'In Enablement'
  																			  };
	
	//Collection of Account's Type to update customer success Manager And New Business Account Executive 
  	public Static final Set<String> SET_ACCOUNT_TYPE_VALUES = new Set<String> {
  																		'Customer',
  																		'Customer of Reseller Partner',
  																		'Customer & Partner',
  																		'Partner'
  																		};
  	
  	//Collection of Case Cosed reason value 																	
  	public static final Set<String> SET_CASE_CLOSE_REASON = new Set<String>{
  																		'Resolved',
  																		'Referred to KB',
  																		'Referred to Ideas',
  																		'Referred to Other Group',
  																		'No Response from Customer'
  																		};	
  	//Collection of Case Cosed reason value 																	
  	public static final Set<String> SET_CASE_LANGUAGE = new Set<String>{
  																		'ENGLISH',
  																		'GERMAN',
  																		'FRENCH',
  																		'SPANISH',
  																		'PORTUGUESE'
  																		};
  	
  	//Map to hold hold EmailTemplate name corresponding to language
  	public static final Map<String, String> MAP_LANGUAGE_AND_ETemp_NAME = new Map<String, String>{
  																			 'English' => 'CSatSurveyEnglish',
  																			 'French' => 'CSatSurveyFrench',
  																			 'German' => 'CSatSurveyGerman',
  																			 'Spanish' => 'CSatSurveySpanish',
  																			 'Portuguese' => 'CSatSurveyPortuguese'
  																		};
  	//Collection of Case RecordType Developer name
  	public static final Set<String> SET_RECORDTYPE_DEVELOPER_NAME = new Set<String>{
  																			 'Situation_Management_Services',
  																			 'Situation_Management_Support',
  																			 'Situation_Management_Support_Feedback'
  																		};
  																		
	//Set to hold Subscription_type__c value of Asset
	public static final Set<String> SET_SUBSCRIPTION_TYPE = new Set<String> {
																		'SMB Spark',
																		'SMB Select',
																		'SMB Standard'
																	};
	
	//Set to hold QueueSobject Name
	public static final Set<String> SET_QUEUESOBJECT_NAME = new Set<String> {
																		'Support Escalations Queue',
																		'Support Feedback Queue'	
																	};
	
	//Set to hold Accoun Type values
	public static final Set<String> SET_ACCOUNT_TYPE_FOR_IDEA = new Set<String> {
																	'Ex-Customer',
																	'Ex-Partner'	
																};
																
	//Set to hold AsyncApex JobClass name Type values
	public static final Set<String> SET_ASYNCAPEX_JOB = new Set<String> {
																	'MKT_BatchAssign',
																	'BatchRegisterForTraining',
																	'BatchUnRegisterForTraining'	
																};
	//This varibale is to create a static Map of custom Setting, so it is not being queried all the time
    //Key = Parameter Key, Value = List<Parameter Values>
  	public static Map<String, List<Configuration_Manager__c>> MAP_CONFIGURATION_MANAGER {

    	get {
    		if(MAP_CONFIGURATION_MANAGER == null) {

	        	MAP_CONFIGURATION_MANAGER = new Map<String, List<Configuration_Manager__c>>();
	
	        	//Get all values from custom setting
	        	List<Configuration_Manager__c> configs = Configuration_Manager__c.getAll().values();
	
	        	//Loop through all the custom setting records
	        	for(Configuration_Manager__c config : configs) {
	
		          	//check if Parameter Key is not null
		          	if(config.Parameter_Key__c == null || config.Parameter_Key__c == '' || config.Parameter_Value__c == null 
		          		|| config.Parameter_Value__c == '')
		            	continue;
		
		          	//Check if map already has Parameter Key
		          	if(MAP_CONFIGURATION_MANAGER.containsKey(config.Parameter_Key__c))
		            	MAP_CONFIGURATION_MANAGER.get(config.Parameter_Key__c).add(config);
		          	else
		            	MAP_CONFIGURATION_MANAGER.put(config.Parameter_Key__c, new List<Configuration_Manager__c>{config});
	        	}
      		}
      		return MAP_CONFIGURATION_MANAGER;
    	}
  	}

  	/**
   	 *   @description  :  This method is to get the Custom Setting data based on Parameter Key.
     *
     *   @args         :  Parameter Key
     *
     *   @return       :  List<Configuration_Manager__c>
     *
     **/
  	public static List<Configuration_Manager__c> getConfigManagerByParameterKey(String parameterKey) {

	    //Create a list of Configuaration Manager
	    List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();
	
	    //Check if Map has this key
	    if(Constants.MAP_CONFIGURATION_MANAGER.containsKey(parameterKey)) {
	
	    	//return all the related values
	      	configs = Constants.MAP_CONFIGURATION_MANAGER.get(parameterKey);
	    }
	
	    return configs;
  	}
}