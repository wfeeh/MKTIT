@isTest
public class SituationManagementTest {
    
    public static testmethod void testHistoryComponent() {
        Account acc = new Account(Name = 'Default Partner');
        insert acc;
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        insert caseObj;        
        List<CaseHistory> historyList = new List<CaseHistory>();
        CaseHistory caseHistory1 = new CaseHistory(Field = 'Status', CaseId = caseObj.id);
        historyList.add(caseHistory1);
        CaseHistory caseHistory2 = new CaseHistory(Field = 'Created', CaseId = caseObj.id);
        historyList.add(caseHistory2);
        insert historyList;        
        GenericHistoryComponentController history = new GenericHistoryComponentController();
        history.myObject = caseObj;
        history.getObjectHistory();
    }
    
    public static testmethod void testSMController() {                
              
        
        //Contact testcontact = [Select Id, accountid from contact LIMIT 1];
        
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        insert caseObj;          
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(caseObj);   
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);     
        ApexPages.currentPage().getParameters().put('type', 'supp');             
        
        SituationMgmtController situationCtrl = new SituationMgmtController(ctrl);   

        situationCtrl.caseRecord = caseObj;
        // situationCtrl.caseRecord.Situation_Contact__c = '0035000000tSg19';
        //situationCtrl.ContactProperty();       
        situationCtrl.getAlphaRecords();
        situationCtrl.charLink = 'Other';
        situationCtrl.getAlphaRecords();
        situationCtrl.charLink = 'All';
        situationCtrl.getAlphaRecords();
        situationCtrl.viewData();
        situationCtrl.doSave();
        situationCtrl.viewData();
        situationCtrl.viewCaseDetail();
        situationCtrl.createCase();
        situationCtrl.doCancel();
        situationCtrl.caseEdit();
        
        situationCtrl.getSortDirection();
        situationCtrl.redirectToCaseDetail();
        situationCtrl.goToComment();
        situationCtrl.caseComment = 'Test';
        situationCtrl.addComment();
        situationCtrl.first();
        situationCtrl.last();
        situationCtrl.next();
        situationCtrl.previous();
        situationCtrl.doClone();
        situationCtrl.doDelete();
        situationCtrl.redirectToCaseClone();
        situationCtrl.redirectToCaseEdit();
        situationCtrl.redirectToCaseClose();
        situationCtrl.getOptions();
        
        situationCtrl.filterBy = 'All Open Support';
        situationCtrl.filterQuery(); 
        situationCtrl.filterBy = 'All Open Services';
        situationCtrl.filterQuery(); 
        
        ApexPages.currentPage().getParameters().put('type', 'serv');
        
        SituationMgmtController situationCtrl1 = new SituationMgmtController();
        situationCtrl1.caseRecord = caseObj; 
        situationCtrl1.caseEdit();
        
        ApexPages.currentPage().getParameters().put('type', 'feed');
        
        SituationMgmtController situationCtrl2 = new SituationMgmtController();
        situationCtrl2.caseRecord = caseObj; 
        situationCtrl2.caseEdit();
    }
    
    public static testmethod void testSMAccountCtrl() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc); 
        SituationAccountCtrl ctrl = new SituationAccountCtrl(sc);
        ctrl.getURL();
        ctrl.goToURL();
    }
    
    public static testmethod void testSMContactCtrl() {
        Contact con = new Contact(LastName = 'Test Account');
        insert con;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(con); 
        SituationContactCtrl ctrl = new SituationContactCtrl(sc);
        ctrl.getURL();
        ctrl.goToURL();
    }
    
    public static testmethod void testSMNewRedirectCtrl() {
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        insert caseObj;
        
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        SituationNewRedirectCtrl ctrl = new SituationNewRedirectCtrl(sc);
        ctrl.redirect();
    }
    
    public static testmethod void testSMRecordTypeSelectCtrl() {
        SituationRecordTypeSelectCtrl ctrl = new SituationRecordTypeSelectCtrl();
        ctrl.doCancel();
        ctrl.getOptions();
        ctrl.selectedRecType = 'Services';
        ctrl.doContinue();
        ctrl.selectedRecType = 'Support';
        ctrl.doContinue();
        ctrl.doCancel();
        
        ctrl.selectedRecType = 'Feedback';
        ctrl.doContinue();
        ctrl.doCancel();
        
        
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        insert caseObj;        
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        SituationRecordTypeSelectCtrl  ctrl1 = new SituationRecordTypeSelectCtrl();
        ctrl1.doCancel();
            
    }
    
    public static testmethod void testEmailToCase() {
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Con', Email = 'test@test.com');
        insert con;
        
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', SuppliedEmail = 'test@test.com',
                                    Description = 'Test Description', Origin = 'TBD');
        insert caseObj;
    }
}