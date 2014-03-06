global class InvokeUpdateTriggerBatch implements Database.Batchable<sObject> {
 
  private String sObjectName;
  private Set<Id> idsToBeUdpated; 
  private Integer batchSize;
 
  global InvokeUpdateTriggerBatch(String sObjectName, Set<Id> idsToBeUpdated, Integer batchSize) {
    this.sObjectName    = sObjectName;
    this.idsToBeUdpated = idsToBeUpdated;
    this.batchSize      = batchSize;
  }
 
  global Database.QueryLocator start(Database.BatchableContext BC){
 
    String query = '';
    Set<Id> ids = this.idsToBeUdpated;
    if (ids == null) {
        query = 'SELECT Id FROM ' + sObjectName;
    } else {
        query = 'SELECT Id FROM ' + sObjectName +' where id in:ids';
    }
    
    return Database.getQueryLocator(query);   
 
  }
 
  global void execute(Database.BatchableContext BC, List<sObject> scope){   
    //Database.DMLOptions dml = new Database.DMLOptions();
    //dml.optAllOrNone = true; 
    try{
        //Just update the records.  That's all!
        update scope;
        //System.debug('Hello----');
    } catch(Exception ex){
        System.Debug('Issue found');
    }
    
  }
 
  global void finish(Database.BatchableContext BC){
    
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
      
        Set  <Id>     accsToBeUpdated = this.idsToBeUdpated;   
        List <String> accsUpdatedStringList = new LIST<String>();
        Set  <ID>     accsUpdatedSet = new SET<ID>();
        
        List<AccountScorerBatch__c> batches = [Select Accountids__c from AccountScorerBatch__c]; 
        for (AccountScorerBatch__c batch:batches) {
            String idsupdated = batch.Accountids__c.substring(0,batch.Accountids__c.length()-1);
            accsUpdatedStringList.addAll(idsupdated.split(',',-1));
        }
        for (String accStringId:accsUpdatedStringList) {
            try{
                accsUpdatedSet.add(accStringId);
            }catch(Exception ex){
            }
        }
        
        /*FOR FIRST CASE*/
        Set<ID> notUpdatedAccs = new Set<Id>();
        if (accsToBeUpdated == null) {
            List<Account> accNotUpdatedSet = [Select Id from Account where id NOT IN:accsUpdatedSet];
            for (Account acc:accNotUpdatedSet) {
                notUpdatedAccs.add(acc.Id);
            }
        } else {
            this.idsToBeUdpated.removeAll(accsUpdatedSet);
            notUpdatedAccs = this.idsToBeUdpated;
        } 
        
        if (notUpdatedAccs.size() != 0) {
            
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();            
            Integer newBatchSize = 1; 
            if (this.batchSize > 25) {
                newBatchSize = this.batchSize/2;
            } else {
                newBatchSize = 1;
            }
            if (this.batchSize != 1) {
                List<AccountScorerBatch__c> DeleteList = [select Name from AccountScorerBatch__c  limit 5000]; 
                delete DeleteList;         
                AccountBatch2Scheduler acctBatch2Sched = new AccountBatch2Scheduler('Account', notUpdatedAccs, newBatchSize);
                System.schedule('Fallback Batch ' +newBatchSize+' '+sysTime.getTime(),chron_exp,acctBatch2Sched);
            } else {
                //Add the batch-info to Customobject
                List<AccountScorerFailedRecord__c> accRecFailed = new List<AccountScorerFailedRecord__c>();
                for (ID tempFailedID:notUpdatedAccs) {
                    AccountScorerFailedRecord__c failedId = new AccountScorerFailedRecord__c();
                    failedId.failedids__c = (String)tempFailedID;
                    accRecFailed.add(failedId);
                }
                insert accRecFailed;
            }
        }
        // Enable the Settings in trigger
        Map<String, AccountScorerSettings__c> triggerSettings = AccountScorerSettings__c.getAll();
        String triggerSettingsMode  = '';
        String triggerSettingsRunAs = '';      
        
        for (String st:triggerSettings.keyset()) {
            triggerSettings.get(st).settingsMode__c = 'off';
            update triggerSettings.get(st);
        }         
        System.debug('Batch Process Complete');
  }
   @isTest (seeAllData=true)
   public static void testInvokeUpdateTriggerBatch ()
    {
        test.startTest();
        Map<ID,sObject> accIds = new Map<ID,sObject>([SELECT ID FROM Account LIMIT 150]);
        database.executebatch(new InvokeUpdateTriggerBatch('Account', accIds.keyset(), 200));
        test.stopTest();
        
    }
}