/****************************************************
Class Name: SituationUtil
Author: ClearTeask
Created Date: 16/09/2012
Usage: This class is used as util class for situation management.
*****************************************************/
public with sharing class SituationUtil {
    
    // returns true if case is createable else false
    public static Boolean caseIsCreateable() {
        if(Schema.sObjectType.Case.isCreateable()) {
            return true;
        }
        return false;
    }
    
    // returns true if case is updateable else false
    public static Boolean caseIsUpdateable() {
        if(Schema.sObjectType.Case.isUpdateable()) {
            return true;
        }
        return false;
    }
    
    // returns true if case is deleteable else false
    public static Boolean caseIsDeletable() {
        if(Schema.sObjectType.Case.isDeletable()) {
            return true;
        }
        return false;
    }
    
    // query case record
    public static Case queryCase(String caseId) {
        Id casId = caseId;
        String query = 'select ';     
        Schema.SObjectType ot = Schema.getGlobalDescribe().get('Case');
        Map<String,Schema.SObjectField> fields = ot.getDescribe().fields.getMap();
        
        for (String fn : fields.keySet()){
            Schema.DescribeFieldResult f = fields.get(fn).getDescribe();
            query += f.getName() + ', ';
        }
        
        query = query.substring(0, query.length() - 2);
        
        query += ' From Case where id = :caseId';
                
        Case caseRec = Database.query(query); 
        return caseRec;
    }
    
    // update SM Account and Contact when email to case
    @future
    public static void updateCase(Map<Id, String> mapCaseEmail) {
        
        Map<String, Id> mapEmailAccount = new Map<String, Id>();
        mapEmailAccount = accountMap(mapCaseEmail);
        
        Map<String, Contact> mapEmailContact = new Map<String, Contact>();
        mapEmailContact = contactMap(mapCaseEmail);
        
        List<Case> caseList = new List<Case>();
        for(Id cId :mapCaseEmail.keySet()) {
            Case c = new Case(id = cId);
            
            if(mapCaseEmail != null && mapCaseEmail.containsKey(cId) && mapCaseEmail.get(cId) != null) {
                if(mapEmailContact != null && mapEmailContact.containsKey(mapCaseEmail.get(cId))) {
                    c.Situation_Contact__c = mapEmailContact.get(mapCaseEmail.get(cId)).id;
                    c.Situation_Account__c = mapEmailContact.get(mapCaseEmail.get(cId)).AccountId;
                }
                if(c.Situation_Account__c == null && mapEmailAccount != null 
                                    && mapEmailAccount.containsKey(mapCaseEmail.get(cId))) {
                    c.Situation_Account__c = mapEmailAccount.get(mapCaseEmail.get(cId));
                }
            }
            c.AccountId = null;
            c.ContactId = null;
            caseList.add(c);
        }
        
        try {
            if(caseList != null && caseList.size() > 0)
                update caseList;
        } catch(Exception e) {
            System.debug('---- ERROR MESSAGE ----' + e.getMessage());
        }
    }
    
    // create account map
    public static Map<String, Id> accountMap(Map<Id, String> mapCaseEmail) {
        List<Account> accList = [select Accounting_Email__c from Account
                                     where Accounting_Email__c in :mapCaseEmail.values()];
    
        Map<String, Id> mapEmailAccount = new Map<String, Id>();
        
        for(Account acc :accList) {
            if(mapEmailAccount != null && mapEmailAccount.containsKey(acc.Accounting_Email__c)) {
                continue;
            } else {
                mapEmailAccount.put(acc.Accounting_Email__c, acc.id);
            }
        }
        
        return mapEmailAccount;
    }
    
    // create contact map
    public static Map<String, Contact> contactMap(Map<Id, String> mapCaseEmail) {
        List<Contact> conList = [select Email, AccountId from Contact
                                     where Email in :mapCaseEmail.values()];
    
        Map<String, Contact> mapEmailContact = new Map<String, Contact>();
        
        for(Contact con :conList) {
            if(mapEmailContact != null && mapEmailContact.containsKey(con.Email)) {
                continue;
            } else {
                mapEmailContact.put(con.Email, con);
            }
        }
        
        return mapEmailContact;
    }
}