@isTest(SeeAllData=true)
public class DTOTriggerTest{
    static testmethod void mytest(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Sales_Order_Item__c soi = UtilityToCreateTestData.insertSalesOrderItem(opli.id, so.id);
        opp.StageName = 'Discovery';
        update opp;
        Test.StopTest();
    }
    
    static testmethod void mytest2(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Sales_Order_Item__c soi = UtilityToCreateTestData.insertSalesOrderItem(opli.id, so.id);
        delete opli;
        Test.StopTest();
    }
    
    static testmethod void mytest3(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Sales_Order_Item__c soi = UtilityToCreateTestData.insertSalesOrderItem(opli.id, so.id);
        delete opp;
        Test.StopTest();
    }
    
    static testmethod void mytest4(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Sales_Order_Item__c soi = UtilityToCreateTestData.insertSalesOrderItem(opli.id, so.id);
        DTOController.isTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        Test.StopTest();
    }
    
    static testmethod void mytest5(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Sales_Order_Item__c soi = UtilityToCreateTestData.insertSalesOrderItem(opli.id, so.id);
        delete so;
        Test.StopTest();
    }
    
    static testmethod void mytest6(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Sales_Order_Item__c soi = UtilityToCreateTestData.insertSalesOrderItem(opli.id, so.id);
        delete soi;
        Test.StopTest();
    }
    
    static testmethod void mytest7(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business' , System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Sales_Order_Item__c soi = UtilityToCreateTestData.insertSalesOrderItem(opli.id, so.id);
        DTOController.isTriggerExecuted = FALSE;
        opli.quantity = 2;
        update opli;
        Test.StopTest();
    }
}