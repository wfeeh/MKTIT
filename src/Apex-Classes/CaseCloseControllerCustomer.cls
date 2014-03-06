/****************************************************
Class Name: CaseCloseControllerCustomer
Author: ClearTeask
Created Date: 7/9/2012
Usage: This class is used to allow customers to close cases.
*****************************************************/
public class CaseCloseControllerCustomer {

    /*variable for StandardSetController */
    ApexPages.StandardController con;
    public Case caseRec{get;set;}
    public String closingReason{get;set;}
    public Boolean caseSelected{get;set;}
    public List<Case> caseList {get; set;}
    public List<SelectOption> caseClose {get; set;}
    
    /*Constructor */ 
    public CaseCloseControllerCustomer(ApexPages.StandardController controller) {
        caseSelected = true;
        con = controller;
        caseClose = new List<SelectOption>();
        caseList = new List<Case>();
        this.caseRec = (Case)controller.getRecord();
        caseList.add(caseRec);
        
        if(caseList == null || caseList.size() == 0) {
            caseSelected = false;
        }
        caseCloseOptions();
    }
    
    /* add closing options */
    public void caseCloseOptions() {
        caseClose.add(new SelectOption('Resolved', 'Resolved'));
        caseClose.add(new SelectOption('Self-Service/No Agent', 'Fix no longer needed'));
        caseClose.add(new SelectOption('Duplicate', 'Duplicate'));
    }
    
    /* method to close cases */
    public PageReference closeCase() {
        //this.caseRec = (Case)controller.getRecord();
        for(Case c :caseList) {
            c.Status = 'Closed';
            c.Close_Reason__c = closingReason;
        }
        
        try {
            update caseList;
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRec.Id);
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRec.id);
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public PageReference doCancel() {
        PageReference pgRef;
        
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRec.Id);
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRec.id);
        }
        
        pgRef.setRedirect(true);
        return pgRef;
    }
}