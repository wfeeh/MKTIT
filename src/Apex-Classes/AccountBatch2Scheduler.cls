global class AccountBatch2Scheduler implements Schedulable 
{  
  private String sObjectName;
  private Set<Id> idsToBeUdpated; 
  private Integer batchSize;
 
  global AccountBatch2Scheduler(String sObjectName, Set<Id> idsToBeUpdated, Integer batchSize) {
    this.sObjectName    = sObjectName;
    this.idsToBeUdpated = idsToBeUpdated;
    this.batchSize      = batchSize;
  }    
  global void execute(SchedulableContext ctx) {
        
        // Disable the Settings in trigger
        Map<String, AccountScorerSettings__c> triggerSettings = AccountScorerSettings__c.getAll();
        String triggerSettingsMode  = '';
        String triggerSettingsRunAs = '';      
        
        for (String st:triggerSettings.keyset()) {
            triggerSettings.get(st).settingsMode__c = 'on';
            update triggerSettings.get(st);
        }           
  
       InvokeUpdateTriggerBatch batch = new InvokeUpdateTriggerBatch('Account', this.idsToBeUdpated, this.batchSize);
       Database.executeBatch(batch,this.batchSize);
  }
  
    @isTest (seeAllData=true)
    public static void testAccountBatch2Scheduler () {
        PageReference pageRef = Page.AccountListView;     
        Test.setCurrentPage(pageRef);
        
        Map<ID,sObject> accIds = new Map<ID,sObject>([SELECT ID FROM Account LIMIT 1]);
        
        AccountBatch2Scheduler schd = new AccountBatch2Scheduler ('Account',accIds.keySet(),200);
Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(10);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();      
        System.schedule('Test Fallback Batch'+sysTime.getTime(),chron_exp,schd );
    }
    
}