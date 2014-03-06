trigger accountScorerTrigger on Account (before insert, before update) {

   // System.Debug('_BATCH_RUNNING_'+Trigger.new); 

    //Add the batch-info to Customobject
    AccountScorerBatch__c accBatch = new AccountScorerBatch__c();
    accBatch.Accountids__c = '';
    
    // Check the Trigger execution mode manual settings
    Map<String, AccountScorerSettings__c> triggerSettings = AccountScorerSettings__c.getAll();
    String settingsMode  = '';
    String executionMode = '';
    String triggerMode   = '';
    for (String st:triggerSettings.keyset()) {
        settingsMode  = triggerSettings.get(st).settingsMode__c;
        executionMode = triggerSettings.get(st).exceutionMode__c;
        triggerMode   = triggerSettings.get(st).triggerMode__c;
    }
    //System.Debug('TRIGGER_SETTINGS'+triggerSettings);
    String executionType;
    if (settingsMode == 'on') {
        executionType = executionMode;
    } else {
        executionType = Trigger.isInsert?'create':'update';
    }
    
    // Fetch all rules
    List <Account_Scoring_Rule_States__c> scoringRules = [Select Rule_Group__c,Rule_Name__c, State_name__c, Score__c from Account_Scoring_Rule_States__c];
    // Group all rules and call subroutines for each group
    Map <String,Map<String, Decimal>> ruleGroups = new Map<String, Map<String, Decimal>>();
    Map <String, String> rulenames = new Map<String, String>();    
    
    for (Account_Scoring_Rule_States__c scoringRule: scoringRules) {
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
    
    if(Trigger.isUpdate || Trigger.isInsert) {               
        // Check if the trigger has already executed to avoid infinite loop      
        if(Utility.isFutureUpdate){
            AccountScorer accScorer = new AccountScorer();
            Set<Id> triggerAccIds = new Set<Id>();
            for (Account acc:Trigger.new) {
                triggerAccIds.add(acc.Id);
            }
            Map<ID,Decimal> manualIncDecScoreMap = new Map<ID,Decimal>();
            List<Manual_Increment_Decrement__c > manualIncDecScoreList = [Select Account_ID__r.Id, Score_Update__c From Manual_Increment_Decrement__c  Where Account_ID__r.Id IN :triggerAccIds];
            for(Manual_Increment_Decrement__c  IncDec: manualIncDecScoreList ){
                manualIncDecScoreMap.put(IncDec.Account_ID__r.Id,IncDec.Score_Update__c );
            }
            List<Account> accList = new List<Account>();
            // Iterate through all records 
       
            for (Account newAccount:Trigger.new) {
                try {
                    accBatch.Accountids__c += (String)newAccount.Id+',';
                    //Account tempAcc = new Account(id = newAccount.id);
                    //System.debug('Number of script statements used so far : ' +  Limits.getDmlStatements());
                    Double accScore = 0;
                    newAccount.Account_Score_History__c = '';
                    String accScoreHistory = '';
                    // Restore the +50/-50 increments                 
                    if(manualIncDecScoreMap.containsKey(newAccount.Id)) {
                            accScore = manualIncDecScoreMap.get(newAccount.Id);
                    } else {
                            accScore = 0;
                    }
                    accScoreHistory = 'Manual Increase/Decrease:  ' + accScore + '<br/>' ;                  
                    
                    // Evaluate all rule groups
                    
                    for (String ruleGroup : ruleGroups.keySet()) {
                        accScorer.evaluateRule(ruleGroup, ruleGroups.get(ruleGroup),rulenames, newAccount, executionType);
                        accScore += accScorer.accScore;
                        accScoreHistory += accScorer.accHistory;
                        //System.Debug('Rule_Result__'+ruleResult+' GRP_'+ruleGroup +'grp_name___'+ruleGroups.get(ruleGroup));
                    }
                    
                    //System.Debug('__NEW_ACCOUNT_SCORE__'+accScore);
                    //System.Debug('ACCSCORE'+accScore);
                    // Update new Score if its not coming from manual increment decrement
                    // Run trigger if its enabled
                    /*
                    if (triggerMode == 'on') {
                        newAccount.Account_Score__c = accScore;
                    }*/
                    newAccount.Account_Score__c         = accScore;
                    newAccount.Account_Score_History__c = accScoreHistory;
                    
                    //System.Debug('__NEW_ACCOUNT_SCORE__'+accScore);
                    //newAccount.Account_Score_History__c = 'SCORING TEST 16';
                    //accList.add(tempAcc);
                
                } catch (Exception ex) {
                    System.Debug('EXCEPTION__________'+ex);
                }
            }
            if(settingsMode == 'on') { //recalculation batch mode
                insert accBatch;  
            }
            Utility.isFutureUpdate = false;
        }
    }
            
}