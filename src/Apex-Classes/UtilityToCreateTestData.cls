@isTest
public class UtilityToCreateTestData{
    public static Account insertAccount(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        return acc;
    }
    
    public static Contact insertContact(Id accountId){
        Contact con = new Contact(
            AccountId = accountId,
            FirstName = 'Test First Name',
            LastName = 'Test Last Name'
        );
        insert con;
        return con;
    }
    
    public static Opportunity insertOpportunity(Id accountId, String stageName, string type, Date closeDate){
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity', 
            AccountId = accountId, 
            StageName = stageName, 
            Type = type,
            CloseDate=closeDate
        );
         insert opp;
         return opp;
    }
    
    public static Product2 insertProduct(){
        Product2 product = new Product2(
            Name = 'Test Product', 
            ProductCode = 'TESTPROD123321', 
            isActive=TRUE
        );
        insert product;
        return product;
    }
    
    public static PriceBook2 getStandardPriceBook(){
        return  [select id from Pricebook2 where isStandard = TRUE limit 1];
    }
    
    public static PriceBookEntry insertPriceBookEntry(Id ProductId, Id PriceBookId){
        PriceBookEntry pbe = new PriceBookEntry (
            Product2Id =ProductId, 
            PriceBook2Id = PriceBookId, 
            UnitPrice = 10, 
            isActive = TRUE
        );
        insert pbe;
        return pbe;
    }
    
    public static OpportunityLineItem insertOppLineItem(Id oppId, Id priceBookEntryId, integer unitPrice, integer quantity){
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppId, 
            PricebookEntryId = priceBookEntryId, 
            UnitPrice = unitPrice, 
            Quantity = quantity
        );
        insert oli;
        return oli;
    }
    
    public static Sales_Order__c insertSalesOrder(Id oppId){
        Sales_Order__c so = new Sales_Order__c(
            Name = 'Test SO',
            Opportunity__c = oppId
        );
        insert so;
        return so;
    }
    
    public static Sales_Order_Item__c insertSalesOrderItem(Id oppLineItemId, Id salesOrderId){
        Sales_Order_Item__c soi = new Sales_Order_Item__c(
            Name = 'Test SOI',
            Opp_Product_id__c = oppLineItemId,
            Sales_Order__c = salesOrderId
        );
        insert soi;
        return soi;
    }
}