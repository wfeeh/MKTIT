@isTest
private class SetApprovalRequestStatusTriggerTest{
    static testmethod void test1() {
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
               
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
        insert opp;
         
        Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id);
        insert quote;
        
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        Apttus_Approval__Approval_Request__c request1 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Finance Approval', Related_Quote__c = quote.id);
        requestList.add(request1);
        
        Apttus_Approval__Approval_Request__c request2 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Legal Approval', Related_Quote__c = quote.id);
        requestList.add(request2);
        
        Apttus_Approval__Approval_Request__c request3 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Terms Approval', Related_Quote__c = quote.id);
        requestList.add(request3);
        
        Apttus_Approval__Approval_Request__c request4 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Discount Approval', Related_Quote__c = quote.id);
        requestList.add(request4);
        
        Apttus_Approval__Approval_Request__c request5 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Operations Approval', Related_Quote__c = quote.id);
        requestList.add(request5);
        
        Apttus_Approval__Approval_Request__c request6 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Support Approval', Related_Quote__c = quote.id);
        requestList.add(request6);
        
        insert requestList;
        
        Test.StartTest();
        quote.Redirect_Finance_Approval__c = TRUE;
        quote.Redirect_Legal_Approval__c = TRUE;
        quote.Redirect_Operations_Approval__c = TRUE;
        quote.Redirect_Sales_Discount_Approval__c = TRUE;
        quote.Redirect_Sales_Terms_Approval__c = TRUE;
        quote.Redirect_Support_Approval__c = TRUE;
        quote.Redirect_Reason_Code__c = 'Test Redirect';
        update quote;
        Test.StopTest();
    }
    
    static testmethod void test2() {
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
               
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
        insert opp;
         
        Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id,
                        Approval_Status_Finance__c = 'Auto-Approved', Approval_Status_Legal__c = 'Auto-Approved', 
                        Approval_Status_Operations__c = 'Auto-Approved', Approval_Status_Sales_Discount__c = 'Auto-Approved',
                        Approval_Status_Sales_Terms__c = 'Auto-Approved', Approval_Status_Support__c = 'Auto-Approved'
                        );
        insert quote;
        
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        Apttus_Approval__Approval_Request__c request1 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Finance Approval', Related_Quote__c = quote.id);
        requestList.add(request1);
        
        Apttus_Approval__Approval_Request__c request2 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Legal Approval', Related_Quote__c = quote.id);
        requestList.add(request2);
        
        Apttus_Approval__Approval_Request__c request3 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Terms Approval', Related_Quote__c = quote.id);
        requestList.add(request3);
        
        Apttus_Approval__Approval_Request__c request4 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Discount Approval', Related_Quote__c = quote.id);
        requestList.add(request4);
        
        Apttus_Approval__Approval_Request__c request5 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Operations Approval', Related_Quote__c = quote.id);
        requestList.add(request5);
        
        Apttus_Approval__Approval_Request__c request6 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Support Approval', Related_Quote__c = quote.id);
        requestList.add(request6);
        
        insert requestList;
        
        Test.StartTest();
        quote.Approval_Status_Finance__c = 'Approval Needed'; 
        quote.Approval_Status_Legal__c = 'Approval Needed'; 
        quote.Approval_Status_Operations__c = 'Approval Needed'; 
        quote.Approval_Status_Sales_Discount__c = 'Approval Needed';
        quote.Approval_Status_Sales_Terms__c = 'Approval Needed'; 
        quote.Approval_Status_Support__c = 'Approval Needed';
        update quote;
        Test.StopTest();
    }
    
    static testmethod void rejectedTest() {
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
               
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
        insert opp;
         
        Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id,
                        Approval_Status_Finance__c = 'Auto-Approved', Approval_Status_Legal__c = 'Auto-Approved', 
                        Approval_Status_Operations__c = 'Auto-Approved', Approval_Status_Sales_Discount__c = 'Auto-Approved',
                        Approval_Status_Sales_Terms__c = 'Auto-Approved', Approval_Status_Support__c = 'Auto-Approved'
                        );
        insert quote;
        
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        Apttus_Approval__Approval_Request__c request1 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Finance Approval', Related_Quote__c = quote.id);
        requestList.add(request1);
        
        Apttus_Approval__Approval_Request__c request2 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Legal Approval', Related_Quote__c = quote.id);
        requestList.add(request2);
        
        Apttus_Approval__Approval_Request__c request3 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Terms Approval', Related_Quote__c = quote.id);
        requestList.add(request3);
        
        Apttus_Approval__Approval_Request__c request4 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Discount Approval', Related_Quote__c = quote.id);
        requestList.add(request4);
        
        Apttus_Approval__Approval_Request__c request5 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Operations Approval', Related_Quote__c = quote.id);
        requestList.add(request5);
        
        Apttus_Approval__Approval_Request__c request6 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Support Approval', Related_Quote__c = quote.id);
        requestList.add(request6);
        
        insert requestList;
        
        Test.StartTest();
        List<Apttus_Approval__Approval_Request__c> requestList2 = new List<Apttus_Approval__Approval_Request__c>();
        request1.Apttus_Approval__Approval_Status__c = 'Rejected';
        requestList2.add(request1);
        request2.Apttus_Approval__Approval_Status__c = 'Rejected';
        requestList2.add(request2);
        request3.Apttus_Approval__Approval_Status__c = 'Rejected';
        requestList2.add(request3);
        request4.Apttus_Approval__Approval_Status__c = 'Rejected';
        requestList2.add(request4);
        request5.Apttus_Approval__Approval_Status__c = 'Rejected';
        requestList2.add(request5);
        request6.Apttus_Approval__Approval_Status__c = 'Rejected';
        requestList2.add(request6);
        update requestList2;
        Test.StopTest();
    }
    
    static testmethod void approvedTest() {
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
               
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
        insert opp;
         
        Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id,
                        Approval_Status_Finance__c = 'Auto-Approved', Approval_Status_Legal__c = 'Auto-Approved', 
                        Approval_Status_Operations__c = 'Auto-Approved', Approval_Status_Sales_Discount__c = 'Auto-Approved',
                        Approval_Status_Sales_Terms__c = 'Auto-Approved', Approval_Status_Support__c = 'Auto-Approved'
                        );
        insert quote;
        
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        Apttus_Approval__Approval_Request__c request1 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Finance Approval', Related_Quote__c = quote.id);
        requestList.add(request1);
        
        Apttus_Approval__Approval_Request__c request2 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Legal Approval', Related_Quote__c = quote.id);
        requestList.add(request2);
        
        Apttus_Approval__Approval_Request__c request3 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Terms Approval', Related_Quote__c = quote.id);
        requestList.add(request3);
        
        Apttus_Approval__Approval_Request__c request4 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Discount Approval', Related_Quote__c = quote.id);
        requestList.add(request4);
        
        Apttus_Approval__Approval_Request__c request5 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Operations Approval', Related_Quote__c = quote.id);
        requestList.add(request5);
        
        Apttus_Approval__Approval_Request__c request6 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Support Approval', Related_Quote__c = quote.id);
        requestList.add(request6);
        
        insert requestList;
        
        Test.StartTest();
        List<Apttus_Approval__Approval_Request__c> requestList2 = new List<Apttus_Approval__Approval_Request__c>();
        request1.Apttus_Approval__Approval_Status__c = 'Approved';
        requestList2.add(request1);
        request2.Apttus_Approval__Approval_Status__c = 'Approved';
        requestList2.add(request2);
        request3.Apttus_Approval__Approval_Status__c = 'Approved';
        requestList2.add(request3);
        request4.Apttus_Approval__Approval_Status__c = 'Approved';
        request4.Apttus_Approval__Actual_Approver__c = UserInfo.getUserId();
        request4.Apttus_Approval__Approver_Comments__c = 'Test Comments';
        requestList2.add(request4);
        request5.Apttus_Approval__Approval_Status__c = 'Approved';
        requestList2.add(request5);
        request6.Apttus_Approval__Approval_Status__c = 'Approved';
        requestList2.add(request6);
        update requestList2;
        Test.StopTest();
    }
    
    static testmethod void cancelledTest() {
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
               
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
        insert opp;
         
        Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id,
                        Approval_Status_Finance__c = 'Auto-Approved', Approval_Status_Legal__c = 'Auto-Approved', 
                        Approval_Status_Operations__c = 'Auto-Approved', Approval_Status_Sales_Discount__c = 'Auto-Approved',
                        Approval_Status_Sales_Terms__c = 'Auto-Approved', Approval_Status_Support__c = 'Auto-Approved'
                        );
        insert quote;
        
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        Apttus_Approval__Approval_Request__c request1 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Finance Approval', Related_Quote__c = quote.id);
        requestList.add(request1);
        
        Apttus_Approval__Approval_Request__c request2 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Legal Approval', Related_Quote__c = quote.id);
        requestList.add(request2);
        
        Apttus_Approval__Approval_Request__c request3 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Terms Approval', Related_Quote__c = quote.id);
        requestList.add(request3);
        
        Apttus_Approval__Approval_Request__c request4 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Discount Approval', Related_Quote__c = quote.id);
        requestList.add(request4);
        
        Apttus_Approval__Approval_Request__c request5 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Operations Approval', Related_Quote__c = quote.id);
        requestList.add(request5);
        
        Apttus_Approval__Approval_Request__c request6 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Support Approval', Related_Quote__c = quote.id);
        requestList.add(request6);
        
        insert requestList;
        
        Test.StartTest();
        List<Apttus_Approval__Approval_Request__c> requestList2 = new List<Apttus_Approval__Approval_Request__c>();
        request1.Apttus_Approval__Approval_Status__c = 'Cancelled';
        requestList2.add(request1);
        request2.Apttus_Approval__Approval_Status__c = 'Cancelled';
        requestList2.add(request2);
        request3.Apttus_Approval__Approval_Status__c = 'Cancelled';
        requestList2.add(request3);
        request4.Apttus_Approval__Approval_Status__c = 'Cancelled';
        requestList2.add(request4);
        request5.Apttus_Approval__Approval_Status__c = 'Cancelled';
        requestList2.add(request5);
        request6.Apttus_Approval__Approval_Status__c = 'Cancelled';
        requestList2.add(request6);
        update requestList2;
        Test.StopTest();
    }
    
    static testmethod void assignedTest() {
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
               
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
        insert opp;
         
        Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id,
                        Approval_Status_Finance__c = 'Auto-Approved', Approval_Status_Legal__c = 'Auto-Approved', 
                        Approval_Status_Operations__c = 'Auto-Approved', Approval_Status_Sales_Discount__c = 'Auto-Approved',
                        Approval_Status_Sales_Terms__c = 'Auto-Approved', Approval_Status_Support__c = 'Auto-Approved'
                        );
        insert quote;
        
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        Apttus_Approval__Approval_Request__c request1 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Finance Approval', Related_Quote__c = quote.id);
        requestList.add(request1);
        
        Apttus_Approval__Approval_Request__c request2 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Legal Approval', Related_Quote__c = quote.id);
        requestList.add(request2);
        
        Apttus_Approval__Approval_Request__c request3 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Terms Approval', Related_Quote__c = quote.id);
        requestList.add(request3);
        
        Apttus_Approval__Approval_Request__c request4 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Sales Discount Approval', Related_Quote__c = quote.id);
        requestList.add(request4);
        
        Apttus_Approval__Approval_Request__c request5 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Operations Approval', Related_Quote__c = quote.id);
        requestList.add(request5);
        
        Apttus_Approval__Approval_Request__c request6 = new Apttus_Approval__Approval_Request__c(
                        Apttus_Approval__Step_Name__c = 'Support Approval', Related_Quote__c = quote.id);
        requestList.add(request6);
        
        insert requestList;
        
        Test.StartTest();
        List<Apttus_Approval__Approval_Request__c> requestList2 = new List<Apttus_Approval__Approval_Request__c>();
        request1.Apttus_Approval__Approval_Status__c = 'Assigned';
        requestList2.add(request1);
        request2.Apttus_Approval__Approval_Status__c = 'Assigned';
        requestList2.add(request2);
        request3.Apttus_Approval__Approval_Status__c = 'Assigned';
        requestList2.add(request3);
        request4.Apttus_Approval__Approval_Status__c = 'Assigned';
        requestList2.add(request4);
        request5.Apttus_Approval__Approval_Status__c = 'Assigned';
        requestList2.add(request5);
        request6.Apttus_Approval__Approval_Status__c = 'Assigned';
        requestList2.add(request6);
        update requestList2;
        Test.StopTest();
    }
}