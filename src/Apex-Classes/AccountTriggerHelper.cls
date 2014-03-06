/**
 *  Description     :   Helper class for Trigger_Account trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Version         :  	V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
 
public without sharing class AccountTriggerHelper {
    
    //Boolean variable for account trigger execution
    public static Boolean Execute_Account_Trigger = true;
     
    /**
     * @Description  :  Method to validate Account's 'Customer Success Manager' and 'New Business Account Executive' on the basis of type
     *                   field on account
     *
     * @args         :  List<Account>, Map<Id,Account>
     *
     * @return       :  void
     *
     **/
    public static void validateSuccessManagerAndExecutive(List<Account> newAccounts, Map<Id,Account> mapOldAccounts) {
        
        //Set to hold Account Ids
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setAccIds = new Set<Id>();
        
        //Set to hold CSM Assignment Rule Key of the account
        Set<String> setCSMARKey = new Set<String>();
        
        //Map to hold assignment key as key and Assignment User as value to hold Assignment Key and User of assignment rule 
        Map<String, Id> mapAssignRuleAndCSM = new Map<String, Id>(); 
        
        //Loop through account records
        for(Account acc : newAccounts) {
            
            //Check for appropriate condition to fire trigger for 'New Business Account Executive'
            if(acc.Type != null && Constants.SET_ACCOUNT_TYPE.contains(acc.Type) && acc.Type != Constants.ACCOUNT_TYPE_CUSTOMER_OF_AGENCY
               && (mapOldAccounts.get(acc.Id).Type == null ||(mapOldAccounts.get(acc.Id).Type == Constants.ACCOUNT_TYPE_CUSTOMER_OF_AGENCY 
                    || !Constants.SET_ACCOUNT_TYPE.contains(mapOldAccounts.get(acc.Id).Type)))) {
                
                //Add Account Id in set
                setAccountIds.add(acc.Id);
                    
            }
            
            //Check for 'Customer Success Manager'
            if(acc.Type != null && Constants.SET_ACCOUNT_TYPE.contains(acc.Type)
                && (!Constants.SET_ACCOUNT_TYPE.contains(mapOldAccounts.get(acc.Id).Type) 
                        && ((acc.Marketo_Elite__c == TRUE || acc.Marketo_Key__c == TRUE)
                            ||((acc.Marketo_Elite__c == FALSE && acc.Marketo_Key__c == FALSE)
                                && ((acc.Business_Unit__c.contains(Constants.ACCOUNT_BUSINESS_UNIT_SB)
                                    && (acc.Temperature__c == null || acc.Temperature__c == '' 
                                        || Constants.SET_ACCOUNT_TEMPERATURE.contains(acc.Temperature__c)))
                                    || (!acc.Business_Unit__c.contains(Constants.ACCOUNT_BUSINESS_UNIT_SB)))
                                    || (acc.Temperature__c == Constants.ACCOUNT_TEMPERATURE_GREEN 
                                        && (mapOldAccounts.get(acc.Id).Temperature__c == Constants.ACCOUNT_TEMPERATURE_RED 
                                            || mapOldAccounts.get(acc.Id).Temperature__c == Constants.ACCOUNT_TEMPERATURE_YELLOW)))))) {
            
                //Add values in set
                setCSMARKey.add(acc.CSM_Assignment_Rule_Key__c);
                setAccIds.add(acc.ParentId);
            }
        }
        
        //Query through assignment rule
        for(Assignment_Rule__c assignmentRule :[select Id, User__c, Rule_Name__c, Assignment_Rule_Key__c from Assignment_Rule__c
                                                        where Assignment_Rule_Key__c IN  : setCSMARKey 
                                                        AND  Rule_Name__c =: Constants.ASSIGNMENT_RULE_NAME_ACCOUNT_CSM_ASSIGNMENT_REV]){
            
            //Populate map with values
            mapAssignRuleAndCSM.put(assignmentRule.Assignment_Rule_Key__c, assignmentRule.User__c);
        }
        
        //Map of Account's Parent Account
        Map<Id, Account> mapParentAccs = new Map<Id, Account>([Select Id, Customer_Success_Manager__c From Account Where Id IN : setAccIds]);
        
        //Map of Account Ids and Opportunity Owner
        Map<Id,Id> mapAccIdAndOppOwner = new Map<Id,Id>();
        
        //Loop through oppportunity records
        for(Opportunity opp : [Select AccountId, Type, CloseDate, StageName, OwnerId From Opportunity 
                                    Where AccountId IN : setAccountIds AND Type =: Constants.OPPORTUNITY_TYPE_NEW_BUSINESS 
                                    AND StageName =: Constants.OPPORTUNITY_STAGE_CLOSED_WON order by AccountId DESC, CloseDate ASC]) {
                                        
            //Populate map with values
            mapAccIdAndOppOwner.put(opp.AccountId, opp.OwnerId); 
        }
        //Loop through account
        for(Account acc : newAccounts) {
            
            //Check for 'Customer Success Manager'
            if(acc.Type != null && Constants.SET_ACCOUNT_TYPE.contains(acc.Type)
                && (!Constants.SET_ACCOUNT_TYPE.contains(mapOldAccounts.get(acc.Id).Type) 
                        && ((acc.Marketo_Elite__c == TRUE || acc.Marketo_Key__c == TRUE)
                            ||((acc.Marketo_Elite__c == FALSE && acc.Marketo_Key__c == FALSE)
                                && ((acc.Business_Unit__c.contains(Constants.ACCOUNT_BUSINESS_UNIT_SB)
                                    && (acc.Temperature__c == null || acc.Temperature__c == '' 
                                        || Constants.SET_ACCOUNT_TEMPERATURE.contains(acc.Temperature__c)))
                                    || (!acc.Business_Unit__c.contains(Constants.ACCOUNT_BUSINESS_UNIT_SB)))
                                    || (acc.Temperature__c == Constants.ACCOUNT_TEMPERATURE_GREEN 
                                        && (mapOldAccounts.get(acc.Id).Temperature__c == Constants.ACCOUNT_TEMPERATURE_RED 
                                            || mapOldAccounts.get(acc.Id).Temperature__c == Constants.ACCOUNT_TEMPERATURE_YELLOW)))))) {
            
                //Check for Account's Parent's customer manager
                if(acc.ParentId != null && mapParentAccs.containsKey(acc.ParentId) && mapParentAccs.get(acc.ParentId).Customer_Success_Manager__c != null) {
                    
                    //Update CSM of account according to it's parent CSM
                    acc.Customer_Success_Manager__c = mapParentAccs.get(acc.ParentId).Customer_Success_Manager__c;
                    
                } else if(mapAssignRuleAndCSM.containsKey(acc.CSM_Assignment_Rule_Key__c)) {
                    
                    //Add CSM to account
                    acc.Customer_Success_Manager__c = mapAssignRuleAndCSM.get(acc.CSM_Assignment_Rule_Key__c); 
                } else
                    //Add default CSM to account
                    acc.Customer_Success_Manager__c = Constants.DEFAULT_ASSIGNMENTRULE;
            }
            
            //Check for appropriate condition to fire trigger for 'New Business Account Executive'
            if(acc.Type != null && Constants.SET_ACCOUNT_TYPE.contains(acc.Type) && acc.Type != Constants.ACCOUNT_TYPE_CUSTOMER_OF_AGENCY
               && (mapOldAccounts.get(acc.Id).Type == null 
                    ||(mapOldAccounts.get(acc.Id).Type == Constants.ACCOUNT_TYPE_CUSTOMER_OF_AGENCY 
                    || !Constants.SET_ACCOUNT_TYPE.contains(mapOldAccounts.get(acc.Id).Type)))) {
                
                //Check if map contains account id
                if(mapAccIdAndOppOwner.containsKey(acc.Id))
                    //Assign opportunity's owner as 'New Business Account Executive' on account
                    acc.New_Business_Account_Executive__c = mapAccIdAndOppOwner.get(acc.Id);                
            }
        }
    }
    
    /**
     * @Description  :  Method to update the value of account History  and account score field on account
     *
     * @args         :  List<Account>, Boolean isInsert
     *
     * @return       :  void
     *
     **/
    public static void validateAccountScorer(List<Account> newAccounts, Boolean isInsert){
     
        //Instance of AccountScoreBatchObject to insert if seting mode is 'On'
        AccountScorerBatch__c accBatch = new AccountScorerBatch__c();
        
        //Check for trigger event
        if(!isInsert)
        	accBatch.Accountids__c = '';
                              
        //Get All org. data of AccountScorerSeting(Custom setting)
        Map<String, AccountScorerSettings__c> mapAccScoreSettings = Constants.ACCOUNTSCORERSETTINGS;
        
        //variables to hold custom setting values
        String settingsMode  = '';
        String executionMode = '';
        String triggerMode   = '';
        
        //Loop through AccountScorerSettings values to get fields values
        for (String st:mapAccScoreSettings.keyset()) {
            
            //assign custom setting values in string variables
            settingsMode  = mapAccScoreSettings.get(st).settingsMode__c;
            executionMode = mapAccScoreSettings.get(st).exceutionMode__c;
            triggerMode   = mapAccScoreSettings.get(st).triggerMode__c;
        }
    
        //variable to hold the value of custom setting mode if setting mode is 'On' else set execution mode according to trigger event  
        String executionType;
    
        //Check the value of settingMode of custom setting is 'on' else asign accoding trigger event
        if (settingsMode == Constants.ACCOUNTSCORERSETTINGS_SETTINGSMODE_ON) {
        
            //Assign the value of execution mode in executionType variable
            executionType = executionMode;
        } else {
            executionType = Trigger.isInsert?'create':'update';
        }
        
        //Group all rules and call subroutines for each group
        Map <String,Map<String, Decimal>> mapRuleGroups = new Map<String, Map<String, Decimal>>();
        Map <String, String> mapRuleNames = new Map<String, String>();    
        
        //Query through Account Scoring Rule States object
        for (Account_Scoring_Rule_States__c accScoringRule: [Select Rule_Group__c,Rule_Name__c, State_name__c, Score__c From Account_Scoring_Rule_States__c
        													 Where Rule_Group__c != null AND State_name__c != null AND Score__c != null]) {
        
            //Check if map contains key
            if(mapRuleGroups.containsKey(accScoringRule.Rule_Group__c)) {
                mapRuleGroups.get(accScoringRule.Rule_Group__c).put(accScoringRule.State_name__c, accScoringRule.Score__c);
                mapRuleNames.put(accScoringRule.State_name__c, accScoringRule.Rule_Name__c);
            } else {
                mapRuleNames.put(accScoringRule.State_name__c, accScoringRule.Rule_Name__c);
                mapRuleGroups.put(accScoringRule.Rule_Group__c, new Map<String, Decimal>{
                                                                                      accScoringRule.State_name__c => accScoringRule.Score__c
                                                                                      });  
            }               
        }
    
        //Instance of helper class to call method
        AccountScorer accScorer = new AccountScorer();
        
        //Map to hold account Id as key and Manual Increment Decrement's Score Update field as value  
        Map<ID,Decimal> mapManualIncDecScore = new Map<ID,Decimal>();
        
        //Check for Trigger event
        if(!isInsert) {
	        
	        //Loop through Manual Increment Decrement corresponding to account(This will only use in case of account update)
	        for(Manual_Increment_Decrement__c  IncDec: [Select Account_ID__c, Score_Update__c From Manual_Increment_Decrement__c  Where Account_ID__c 
	                                                                        IN : newAccounts AND Score_Update__c != null Order By Score_Update__c DESC]){
	            
	            //Populate map with values
	            if(!mapManualIncDecScore.containsKey(IncDec.Account_ID__c))
	            	mapManualIncDecScore.put(IncDec.Account_ID__c,IncDec.Score_Update__c );
	        }
        }  
        
        //Loop through new account reocrds
        for (Account acc: newAccounts) {
                
            //Check for trigger event and Add values in AccountBatch's accountIs field
            if(!isInsert)
            	accBatch.Accountids__c += (String)acc.Id+',';
            
            //Varibale
            Double accScore = 0;
            
            //Set account's Score History field as blank 
            acc.Account_Score_History__c = '';
            
            //String to pass in account history field
            String accScoreHistory = '';
            
            // Check if Manual Increment Decrement on account if yes than add there value to account                  
            if(mapManualIncDecScore.containsKey(acc.Id)) {
                accScore = mapManualIncDecScore.get(acc.Id);
            } else {
                accScore = 0;
            }
            
            //Assign value in account history
            accScoreHistory = 'Manual Increase/Decrease:  ' + accScore + '<br/>' ;
            
            //Loop through rule group name with the help of map's key
            for (String ruleGroup : mapRuleGroups.keySet()) {
                
                //Call AccountScorer class's method to put values in account's Account Score and Account Score History field 
                accScorer.evaluateRule(ruleGroup, mapRuleGroups.get(ruleGroup),mapRuleNames, acc, executionType);
                
                //Check for account Score value and add value in accScore
                if(accScorer.accScore != null)
                	accScore += accScorer.accScore;
                
                //Check for acc History and accScoreHistory from helper class
                if(accScorer.accHistory != null && accScorer.accHistory != '')
                	accScoreHistory += accScorer.accHistory;
            }
            
            //Populate value to account score  and Account Score History field
            acc.Account_Score__c = accScore;
            acc.Account_Score_History__c = accScoreHistory;
        }
        
        //Check for setting mode
        if(!isInsert &&  settingsMode == Constants.ACCOUNTSCORERSETTINGS_SETTINGSMODE_ON) 
            insert accBatch;
    }
    
    /**
     * @Description  :  Method to create task on account
     *
     * @args         :  List<Account> ,Map<Id,Account>
     *
     * @return       :  void
     *
     **/
     public static void accCreateTasks(List<Account> newAccounts,Map<Id,Account> mapOldAccount){
        
        //List of task going to insert
        List<Task> tasks = new List<Task>();
        
        //Boolean variable to create Recurrence Task for 1st account record
        Boolean eliteIsRecurrence = true;
        Boolean enterpriseIsRecurrence = true; 
        
        //Loop through account 
        for(Account acc : newAccounts){
            
            //Check for appropriate condition to fire trigger 
            if(acc.Customer_Success_Manager__c != null && acc.CSM_Trigger__c != null 
                && (mapOldAccount == null || mapOldAccount.get(acc.Id).CSM_Trigger__c != acc.CSM_Trigger__c)) {
                
                //Check for the CSM Trigger value
                if(acc.CSM_Trigger__c == Constants.ACCOUNT_CSM_TRIGGER_ELITE_KEY){
                    
                    //Check for Flag value
                    if(eliteIsRecurrence) {
                        //Check for Date Became a Customer   
                        if(acc.Date_Became_a_Customer__c != null){
	                        
	                        //Instance of task
	                        Task task1 = new Task();
	                        
	                        //add field values of task
	                        task1 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Weekly Meeting Setup Needed', 
	                                                    'Please schedule a weekly meeting with our new Elite/Key Customer!',
	                                                    null, 0);
	                        task1.Isrecurrence = true;
	                        task1.recurrencetype = 'RecursWeekly';
	                        task1.RecurrenceDayOfWeekMask = 1;
	                        task1.RecurrenceInterval= 1;
	                        task1.recurrenceStartDateOnly = acc.Date_Became_a_Customer__c;
	                        task1.recurrenceEndDateOnly = acc.Date_Became_a_Customer__c+364;
	                        
	                        //Add task in tasks
	                        tasks.add(task1);
                        }  
                        //Set flag value to false
                        eliteIsRecurrence = false;
                    } 
                    
                    //Instance of task
                    Task task2 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task2 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review Prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 76);
                    
                    //Add task in tasks
                    tasks.add(task2);
                    
                    //Instance of task
                    Task task3 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task3 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review ', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 90);
                
                    //Add task in tasks
                    tasks.add(task3);
                    
                    //Instance of task
                    Task task4 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task4 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 166);
                
                    //Add task in tasks
                    tasks.add(task4);
                    
                    //Instance of task
                    Task task5 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task5 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 180);
                    
                    //Add task in tasks
                    tasks.add(task5);
                    
                    //Instance of task
                    Task task6 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task6 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 256);
                    
                    //Add task in tasks
                    tasks.add(task6);
                    
                    //Instance of task
                    Task task7 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task7 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 270);
                
                    //Add task in tasks
                    tasks.add(task7);
                    
                    //Instance of task
                    Task task8 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task8 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 346);
                    
                    //Add task in tasks
                    tasks.add(task8);
                    
                    //Instance of task
                    Task task9 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task9 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review ', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 360);
                    
                    //Add task in tasks
                    tasks.add(task9);
                    
                    //Instance of task
                    Task task10 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task10 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Date_Became_a_Customer__c, 180);
                    
                    //Add task in tasks
                    tasks.add(task10);
                    
                    //Instance of task
                    Task task11 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task11 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Date_Became_a_Customer__c, 360);
                    
                    //Add task in tasks
                    tasks.add(task11);
                    
                    //Instance of task
                    Task task12 = new Task();

                    //Check for Acct Renewal Date
                    if(acc.Acct_Renewal_Date__c !=null) {
                        //Call Utility class method to add field values of task
                        task12 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Renewal Discussions', 
                                                    'Start Renewal Discussions with the customer',
                                                    acc.Acct_Renewal_Date__c, -120);
                    }else {
                        //Call Utility class method to add field values of task
                        task12 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Renewal Discussions', 
                                                    'Start Renewal Discussions with the customer',
                                                    acc.Date_Became_a_Customer__c, 240);
                    }
                    //Add task in tasks
                    tasks.add(task12);
                    
                //Check the value of CSM trigger picklist value 
                } else if(acc.CSM_Trigger__c == Constants.ACCOUNT_CSM_TRIGGER_STANDARD){
                    
                    //Instance of task
                    Task task1 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task1 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Meeting', 
                                                'Schedule a Quarterly Meeting with the customer',
                                                acc.Date_Became_a_Customer__c, 90);
                                                
                    //Add task in tasks
                    tasks.add(task1);
                    
                    //Instance of task
                    Task task2 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task2 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Meeting', 
                                                'Schedule a Quarterly Meeting with the customer',
                                                acc.Date_Became_a_Customer__c, 180);
                                                
                    //Add task in tasks
                    tasks.add(task2);
                    
                    //Instance of task
                    Task task3 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task3 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Meeting', 
                                                'Schedule a Quarterly Meeting with the customer',
                                                acc.Date_Became_a_Customer__c, 270);
                                                
                    //Add task in tasks
                    tasks.add(task3);
                    
                    //Instance of task
                    Task task4 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task4 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Meeting', 
                                                'Schedule a Quarterly Meeting with the customer',
                                                acc.Date_Became_a_Customer__c, 360);
                                                
                    //Add task in tasks
                    tasks.add(task4);
                    
                    //Instance of task
                    Task task5 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task5 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Date_Became_a_Customer__c, 180);
                                                
                    //Add task in tasks
                    tasks.add(task5);
                    
                    //Instance of task
                    Task task6 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task6 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Date_Became_a_Customer__c, 360);
                                                
                    //Add task in tasks
                    tasks.add(task6);
                    
                    //Instance of task
                    Task task7 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task7 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Semi Annual Instance Review', 
                                                'Schedule an instance review with the customer',
                                                acc.Date_Became_a_Customer__c, 120);
                                                
                    //Add task in tasks
                    tasks.add(task7);
                    
                    //Instance of task
                    Task task8 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task8 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Semi Annual Instance Review', 
                                                'Schedule an instance review with the customer',
                                                acc.Date_Became_a_Customer__c, 300);
                                                
                    //Add task in tasks
                    tasks.add(task8);
                    
                    //Instance of task
                    Task task9 = new Task();
                    
                    //Check for Acct Renewal date
                    if(acc.Acct_Renewal_Date__c !=null) {
                        //Call Utility class method to add field values of task                 
                        task9 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Semi Annual Instance Review', 
                                                'Schedule an instance review with the customer',
                                                acc.Acct_Renewal_Date__c, -120);
                    } else {
                        //Call Utility class method to add field values of task
                        task9 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Semi Annual Instance Review', 
                                                'Schedule an instance review with the customer',
                                                acc.Date_Became_a_Customer__c, 240);
                    }                           
                    
                    //Add task in tasks
                    tasks.add(task9);
                    
                } else if(acc.CSM_Trigger__c == Constants.ACCOUNT_CSM_TRIGGER_ENTERPRISE){
                    
                    //Check for Recurrence task
                    if(enterpriseIsRecurrence) {
                        
                        //Instance of Task
                        Task tsk = new Task();
                        
                        //Call Utility class method to add field values of task
                        tsk = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Monthly Instance Review', 
                                                'Please schedule a monthly instance review for our Elite/Key Customer!',
                                                null,0);
                        tsk.Isrecurrence = true;
                        tsk.recurrenceStartDateOnly = date.today();
                        tsk.recurrenceEndDateOnly = date.today()+364; 
                        tsk.recurrencetype = 'RecursMonthly' ;
                        tsk.RecurrenceDayOfMonth = 1;
                        tsk.RecurrenceInterval= 1;
                        
                        //Add in list
                        tasks.add(tsk);
                        
                        //Set flag to false
                        enterpriseIsRecurrence = false;
                    }
                    
                    //Instance of task
                    Task task1 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task1 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review Prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 76);
                                                
                    //Add task in tasks
                    tasks.add(task1);
                    
                    //Instance of task
                    Task task2 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task2 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 90);
                                                
                    //Add task in tasks
                    tasks.add(task2);
                    
                    //Instance of task
                    Task task3 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task3 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review Prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 166);
                                                
                    //Add task in tasks
                    tasks.add(task3);
                    
                    //Instance of task
                    Task task4 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task4 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 180);
                                                
                    //Add task in tasks
                    tasks.add(task4);
                    
                    //Instance of task
                    Task task5 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task5 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review Prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 256);
                                                
                    //Add task in tasks
                    tasks.add(task5);
                    
                    //Instance of task
                    Task task6 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task6 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 270);
                                                
                    //Add task in tasks
                    tasks.add(task6);
                    
                    //Instance of task
                    Task task7 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task7 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review prep', 
                                                'Prepare for your Quarterly Review with the Customer',
                                                acc.Date_Became_a_Customer__c, 346);
                                                
                    //Add task in tasks
                    tasks.add(task7);
                    
                    //Instance of task
                    Task task8 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task8 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Quarterly Business Review', 
                                                'Schedule a Business Review with the customer',
                                                acc.Date_Became_a_Customer__c, 360);
                                                
                    //Add task in tasks
                    tasks.add(task8);
                    
                    //Instance of task
                    Task task9 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task9 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Date_Became_a_Customer__c, 180);
                                                
                    //Add task in tasks
                    tasks.add(task9);
                    
                    //Instance of task
                    Task task10 = new Task();
                    
                    //Call Utility class method to add field values of task
                    task10 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Date_Became_a_Customer__c, 360);
                                                
                    //Add task in tasks
                    tasks.add(task10);
                    
                    //Instance of task
                    Task task11 = new Task();
                    
                    //Check for Acct Renewal date 
                    if(acc.Acct_Renewal_Date__c !=null) {
                        //Call Utility class method to add field values of task
                        task11 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Acct_Renewal_Date__c, -120); 
                    } else {
                        //Call Utility class method to add field values of task
                        task11 = Utility.createTask(acc.Customer_Success_Manager__c, acc.id, 'Usage Review and Offers', 
                                                'Discuss Usage and any additional product offers',
                                                acc.Date_Became_a_Customer__c, 240);
                    }
                    
                    //Add task in tasks
                    tasks.add(task11);  
                }
            }
        }
        
        //Check for task list size
        if(tasks.size() > 0)
            insert tasks;
        
    }
    /**
     * @Description  :  Method is uesd to update the portal user fields that are related to account and 
     *                  post Sales Bell message to the Chatter Group, All: Marketo
     *
     * @args         :  List<Account> ,Map<Id,Account>
     *
     * @return       :  void
     *
     **/
     public static void chatterPost(List<Account> newAccounts, Map<Id, Account> mapOldAccounts){
        
        // List to hold the user 
        List<User> users = new List<User>();
        
        //List to hold the FeedItem
        List <FeedItem> feedItems = new List <FeedItem>();
        
        //Set to hold Account Ids
        Set<Id> setAccIds = new Set<Id>();
        
        //Map to hold the account with id
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        
        //Loop iterate through acount
        for (Account acc : newAccounts) {
            
            //Populate the values in map
            mapAccounts.put(acc.Id,acc);
            
            //Check the condition  of type(Field) picklist value
            if(acc.type != null && Constants.SET_ACCOUNT_TYPE_VALUES.contains(acc.type) && acc.Customer_Number__c > 100 
                && acc.Date_Became_a_Customer__c > Date.today()-90 && (mapOldAccounts == null
                    || (!Constants.SET_ACCOUNT_TYPE_VALUES.contains(mapOldAccounts.get(acc.Id).type) 
                    || mapOldAccounts.get(acc.Id).customer_number__c == null || mapOldAccounts.get(acc.Id).Date_Became_a_Customer__c == null))) {
                        
	            //Add account id in set
	            setAccIds.add(acc.Id);
            }
        }
        
        //Iterate loop through user
        for(User usr :[select id, name, Is_Partner__c, Professional__c, AccountId from User where AccountId IN : mapAccounts.keySet()]){
            
            //check for users in map
            if(mapAccounts.containsKey(usr.AccountId)) {
                
                //Check for account type for partner if yes than set uesrs as Is Partner
                if(mapAccounts.get(usr.AccountId).Type == Constants.ACCOUNT_TYPE_PARTNER){
                    usr.Is_Partner__c = true;
                } else {
                    usr.Is_Partner__c = false;
                }
                
                //Check for account type for partner if yes than set uesrs as Is Enterprise
                if(mapAccounts.get(usr.AccountId).MLM_Edition__c == Constants.ACCOUNT_MLM_EDITION_ENTERPRISE){
                    usr.Enterprise__c  = true;
                } else {
                    usr.Enterprise__c  = false;
                }
                
                //Check for account type for partner if yes than set uesrs as Is Spark
                if(mapAccounts.get(usr.AccountId).MLM_Edition__c == Constants.ACCOUNT_MLM_EDITION_SPARK){
                     usr.Spark__c  = true;
                } else {
                     usr.Spark__c  = false;
                }
                
                //Check for account type for partner if yes than set uesrs as Is Professional
                if(mapAccounts.get(usr.AccountId).MLM_Edition__c == Constants.ACCOUNT_MLM_EDITION_PROFESSIONAL 
                    || mapAccounts.get(usr.AccountId).MLM_Edition__c == Constants.ACCOUNT_MLM_EDITION_SMB){
                     usr.Professional__c  = true;
                } else {
                     usr.Professional__c  = false;
                }
                
                //Add user in User list
                users.add(usr);
            }
        }
        
        //Check for user list size
        if(users.size()>0)
            update users;
            
        //Query through CollaborationGroup
        List<CollaborationGroup> collGroups = [Select Id, Name From CollaborationGroup Where Name =: Label.CHATTRER_GROUP_ALL_MARKETO LIMIT 1];
        
        //Loop through  account 
        for(Account acc : [Select Id, ownerId, Owner.Name, Owner.FirstName, Customer_Number__c, Name  from Account where Id IN : setAccIds]) {
            
            //Check for List size
            if(collGroups.size() > 0) {
                
                //Instance of Feed Item
                FeedItem fItempost = new FeedItem();
                
                //Asssign values in Feed Item's fields
                fItempost.ParentId = collGroups[0].Id;
                fItempost.Title = 'COWBELL! ' + acc.Name + ' is a new Marketo Customer!';
                fItempost.Body = '#COWBELL - ' + acc.Owner.Name + ' closed another deal. We just won ' + acc.Name
                                + ' ! Congratulations '+ acc.Owner.FirstName + '! Customer# ' +acc.Customer_Number__c + '.';
                fItempost.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id;
                fItempost.Type = 'LinkPost';
                
                //Add in list
                feedItems.add(fItempost);
            }
        }
        
        //Check for Feed Item List size
        if(feedItems.size() > 0)
            insert feedItems;
    }
}