@IsTest(SeeAllData=true)
private class accountScorerTest {
    static testMethod void myTest() {
        //String executionType = Trigger.isInsert?'create':'update';
        String executionType = 'create'; 

        test.startTest();
        AccountScorer accScorer = new AccountScorer();
        //accScorer.setTestExecution();
        if (!AccountScorer.hasAlreadyRunTrigger()) {
            // Fetch all rules
            List <Account_Scoring_Rule_States__c> scoringRules = [Select Rule_Group__c,Rule_Name__c, State_name__c, Score__c from Account_Scoring_Rule_States__c LIMIT 50];

            // Group all rules and call subroutines for each group
            Map <String,Map<String, Decimal>> ruleGroups = new Map<String, Map<String, Decimal>>();
            Map <String, String> rulenames = new Map<String, String>();   
            for (Account_Scoring_Rule_States__c scoringRule:scoringRules) {
                if(ruleGroups.containsKey(scoringRule.Rule_Group__c)) {
                    Map <String, Decimal> states = ruleGroups.get(scoringRule.Rule_Group__c);
                    states.put(scoringRule.State_name__c, scoringRule.Score__c);
                    rulenames.put(scoringRule.State_name__c, scoringRule.Rule_Name__c);
                    ruleGroups.put(scoringRule.Rule_Group__c, states);  
                } else {
                    Map <String, Decimal> states = new Map<String, Decimal>();
                    states.put(scoringRule.State_name__c, scoringRule.Score__c);
                    rulenames.put(scoringRule.State_name__c, scoringRule.Rule_Name__c);
                    ruleGroups.put(scoringRule.Rule_Group__c, states);  
                }               
            }
            
            Map<String,Decimal> manualIncDecScoreMap = new Map<String,Decimal>();
            List<Manual_Increment_Decrement__c > manualIncDecScoreList = [Select Account_ID__r.Id, Score_Update__c From Manual_Increment_Decrement__c limit 10];
            for(Manual_Increment_Decrement__c  IncDec: manualIncDecScoreList ){
                manualIncDecScoreMap.put(IncDec.Account_ID__r.Id,IncDec.Score_Update__c );
            }

            // Evaluate all rule groups
            Account account = new Account();
            account.Current_ESP_Solution__c = 'Lyris';

            System.Debug('Rule Group__'+ruleGroups);
            for (String ruleGroup : ruleGroups.keySet()) {
                accScorer.evaluateRule(ruleGroup, ruleGroups.get(ruleGroup),rulenames,account, executionType);
                
                //accScore = accScore+ruleResult;
            }   
        
            executionType = 'update';
            // Evaluate all rule groups
            List<Account> acc = [SELECT ID,CRM_System__c,Current_MRM_MA_Solution__c,Type,Hoovers_Employee_Number__c,
            Global_Number_of_Employees__c,NumberOfEmployees,BillingCountry,Phone,Current_ESP_Solution__c,
            SicDesc,NAICS_Name__c,Competes_with_Current_Marketo_Customer__c from Account LIMIT 1];
            //CHange Requested by kim Stites on Jan 22-2013
            //Removing jigsaw_clean__Sync_Status_Summary__c field from above query 
            
            Account newAccount = new Account();
            account.Current_ESP_Solution__c = 'Lyris';
            System.Debug('Rule Group__'+ruleGroups);
            acc.get(0).Phone = '411';
            for (String ruleGroup : ruleGroups.keySet()) {
                accScorer.evaluateRule(ruleGroup, ruleGroups.get(ruleGroup),rulenames, acc.get(0), executionType);
               
                //accScore = accScore+ruleResult;
            }
            AccountScorer.setAlreadyRunTrigger();
        }             
        test.stopTest();
    }
}