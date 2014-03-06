@istest(SeeAllData=true)
public class GetNumberOfEliteProductsTriggerTest{
     static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         insert TestAcc1;
         
         List_of_Elite_Products__c lep = new List_of_Elite_Products__c(Name = 'TESTPROD123321');
         insert lep;
         
         Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD123321', isActive=TRUE);
         insert product;
         
         Pricebook2 pb = [select id from Pricebook2 where isStandard = TRUE limit 1]; 
         
         PriceBookEntry pbe = new PriceBookEntry (Product2Id = product.id, PriceBook2Id = pb.id, UnitPrice = 10, isActive = TRUE);
         insert pbe;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp;
         
         Opportunity opp2 = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp2;
         
         system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c == 0);
         
         OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = pbe.id, UnitPrice = 10, Quantity = 1);
         insert oli;
         
         OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = pbe.id, UnitPrice = 10, Quantity = 1);
         insert oli2;
        
         opp.Name = 'Test Opportunity Updated';
         opp2.Name = 'Test Opportunity Updated';
         List<Opportunity> oppList = new List<Opportunity>();
         oppList.add(opp);
         oppList.add(opp2);
         
         test.StartTest();
         update oppList;
         test.StopTest();
         
         system.debug('sssss'+[select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c);
         
         system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c == 2);
         system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp2.id].Number_of_Elite_Products__c == 0);
     }
}