/*
@Description:
@Author: vishals@grazitti.com
*/

public class reCalculateScore{

    public Account Id{get;set;}
    public reCalculateScore(){}
    public Id batchId{get;set;}
    
    public pageReference recalucate(){
        String accId = ApexPages.currentPage().getParameters().get('id');
        String scoreType = ApexPages.currentPage().getParameters().get('type');
        Map<String, AccountScorerSettings__c> triggerSettings = AccountScorerSettings__c.getAll();
        String triggerSettingsMode  = '';
        String triggerSettingsRunAs = '';    
        Manual_Increment_Decrement__c[] incDec = [Select Account_ID__r.Id, Score_Update__c From Manual_Increment_Decrement__c  Where Account_ID__r.Id = :accId ];
        if(accId != null) {
            Account accounts = new Account();
            accounts  = [Select ID,Account_Score__c, Account_Score_History__c from Account where ID =: accId];
            //System.debug('accounts.Account_Score__c --> '+accounts.Account_Score__c);
            if(incDec.size() == 0){
                Manual_Increment_Decrement__c inc = new Manual_Increment_Decrement__c();
                inc.Account_ID__c = accId;
                If(scoreType == 'increment'){
                    //accounts.Account_Score__c += 50;
                    inc.Score_Update__c  = 50;
                }else if(scoreType == 'decrement'){
                    //accounts.Account_Score__c -= 50;
                    inc.Score_Update__c  = -50;
                }
                insert inc;
            } else{
                If(scoreType == 'increment'){
                    //accounts.Account_Score__c += 50;
                    incDec[0].Score_Update__c  +=50;
                }else if(scoreType == 'decrement'){
                    //accounts.Account_Score__c -= 50;
                    incDec[0].Score_Update__c  -=50;
                }
                update incDec;             
            }
            //System.debug('accounts.Account_Score_History__c---->'+accounts.Account_Score_History__c);
            update accounts;
            //System.debug('accounts.Account_Score__c --> '+accounts.Account_Score__c);
     
            //System.debug('accounts.Account_Score_History__c ==========='+accounts.Account_Score_History__c);
            // update accounts;
            pageReference pg = new pageReference('/'+accId) ;
            pg.setRedirect(true);
            return pg;
        } else {
            List<AccountScorerFailedRecord__c> DeleteFailedIdsList = [select Id from AccountScorerFailedRecord__c  limit 5000]; 
            delete DeleteFailedIdsList;
            List<AccountScorerBatch__c> oldBatchesList = [select Name from AccountScorerBatch__c  limit 5000]; 
            delete oldBatchesList;                    
            for (String st:triggerSettings.keyset()) {
                triggerSettings.get(st).settingsMode__c = 'on';
                update triggerSettings.get(st);
            }
            //Map<ID,sObject> accIds = new Map<ID,sObject>([SELECT ID FROM Account where ID = '001W0000005zRdR']);
            
            InvokeUpdateTriggerBatch batch = new InvokeUpdateTriggerBatch('Account', null, 200);
            batchId = Database.executeBatch(batch);
            // pageReference pg = new pageReference('/apex/AccountListView?msg=1'); 
            //   pg.setRedirect(true);
            //   return pg;
         return null;
        }
    }
    
    @isTest (seeAllData=true)
    public static void testRecalculateScoreController() {
        Account accounts = new Account(Name = 'TestAccount');
        insert accounts;
        Id tempId = accounts.ID;
        
        PageReference pageRef = Page.reCalculateScore;  
        pageRef.getParameters().put('Id', accounts.id);
        pageRef.getParameters().put('type', 'increment');
        pageRef.getParameters().put('type', 'decrement');
        Test.setCurrentPage(pageRef);
        
        reCalculateScore controller = new reCalculateScore();
        pageReference p = controller.recalucate();
        
        Manual_Increment_Decrement__c incDec = new Manual_Increment_Decrement__c(Account_ID__c = tempId );
        incDec.Score_Update__c =50;
        insert incDec;
    
        incDec.Score_Update__c =60;
        update incDec;
    
        accounts.Name = 'test account1';
        update accounts;
        
        PageReference pageRef1 = Page.reCalculateScore;  
        pageRef1.getParameters().put('Id', accounts.id);
        pageRef1.getParameters().put('type', 'increment');
        pageRef1.getParameters().put('type', 'decrement');
        Test.setCurrentPage(pageRef1);
        //Test.StartTest();
        
        reCalculateScore controller1 = new reCalculateScore();
        pageReference p1 = controller1.recalucate();
        // Test.StopTest();
    } 
    
    public static testMethod void testRecalculateScoreController1() {
        PageReference pageRef = Page.AccountListView;     
        Test.setCurrentPage(pageRef);
        
        reCalculateScore controller = new reCalculateScore();
        pageReference p = controller.recalucate();  
    }
}