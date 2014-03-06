public class AEEmailHandlerController
{
    public static List<Authorized_Contact__c> ListOfAuthorizedContact;
    public static Map<Id,Authorized_Contact__c> AuthMap;
    public static void createFromEmail(string OppID,string Munchkin , string PO,string ProductC,string InstanceNum,string Asse,string AccountPre)
    {

 String OpID = OppID; 
 String MunchkinID =Munchkin;
 String POD=PO;
 String ProductCode = ProductC;
 List<Id> AssetsIds = new List<Id>();
   ListOfAuthorizedContact = new list<Authorized_Contact__c>();
    AuthMap = new Map<Id,Authorized_Contact__c>();
 Decimal InstanceNumber;
 if(InstanceNum != '' && InstanceNum != null)
     InstanceNumber = Decimal.valueOf(InstanceNum);
 String Asset =  Asse;
 String AccountPrefix = AccountPre;
 
 list<asset> ListOfAssetss = new list<asset>();
 list<asset> AssetsToUpdate = new list<asset>();
 
 list<opportunitylineitem> OLI = [select pricebookentry.product2.ConvertTo__c ,
                                Opportunity.Primary_Marketo_User_Lookup__c,
                                Opportunity.Primary_Marketo_User_Lookup__r.Account.Id, 
                                pricebookentry.product2.ProductCode,
                                pricebookentry.product2.Family,
                                pricebookentry.product2.Record_Limitation__c,
                                pricebookentry.product2.id,
                                opportunity.account.id,
                                opportunity.account.name,
                                opportunity.account.type,
                                opportunity.account.Partner_Type__c,
                                opportunity.account.Sales_Region__c,
                                opportunity.CRM_System__c,
                                opportunity.Sub_Start_Date__c,
                                opportunity.Sub_End_Date__c,
                                Quantity,Instance_Number__c
                                from opportunitylineitem where OpportunityId =: OpID 
                                AND Instance_Number__c=:InstanceNumber 
                                AND 
                                pricebookentry.product2.ProductCode =:ProductCode limit 1
                                ];
 if(OLI.size()>0)
 {
 system.debug('yes found');
  ListOfAssetss = [select id,product2.id,Munchkin_ID__c,POD__c,Acct_Prefix__c from asset where opportunity__c =:OpID limit 100];
  if(ListOfAssetss.size()>0)
  {
      for(asset LOA : ListOfAssetss)
      {
          if(LOA.product2.id == OLI[0].pricebookentry.product2.id)
          {
                        system.debug('yeah matched');
                        LOA.Munchkin_ID__c = MunchkinID;
                        LOA.POD__c = POD;
                        LOA.Acct_Prefix__c = AccountPrefix;
                        AssetsToUpdate.add(LOA);
                        AssetsIds.add(LOA.id);
          }
      }
 
  
  }
 }
               List<Entitlement> ExtEntList = [SELECT id,StartDate,EndDate,BusinessHoursId,
               SlaProcessId,Product_ID__c,name,AccountId,AssetId,Type,Support_Region__c from Entitlement where AssetId =: AssetsIds  limit 100];
             
               
              /* CurrentOpp = [select id,accountid,Primary_Marketo_User_Lookup__c,
                                Primary_Marketo_User_Lookup__r.Account.Id 
                               from opportunity where id =: OpID  limit 1];*/
                
               List<Authorized_Contact__c> ExistingAC = [SELECT id,
                                                                   Entitlement__c
                                                              FROM Authorized_Contact__c
                                                              WHERE Entitlement__c in :ExtEntList 
                                                              and Customer_Admin__c = true limit 200]; 
               
                  for(Authorized_Contact__c c: ExistingAC )
                  {
                      AuthMap.put(c.Entitlement__c,c);
                  } 
                 
                 // Calling this method for creating Authorized Contacts
                  CreateAuthorizedContact(ExtEntList,OLI);  
 if(AssetsToUpdate.size()>0)
 {
     update AssetsToUpdate;
 }
}

  private static void CreateAuthorizedContact(List<Entitlement> ListOfEntitlement,List<OpportunityLineItem> Opt)
    {
        Authorized_Contact__c ac ;
            if(ListOfEntitlement.size()>0)
            {
                for(Entitlement ent : ListOfEntitlement)
                {
                        if(AuthMap.keyset().contains(ent.id)){
                            ac = AuthMap.get(ent.id);
                        }
                        else{
                            ac = new Authorized_Contact__c();
                        
                           /* if(CurrentOpp.size()>0)
                            {
                                ac.Contact__c= CurrentOpp[0].Primary_Marketo_User_Lookup__c ;
                            }*/
                            if(Opt.size()>0 && Opt[0].Opportunity.Primary_Marketo_User_Lookup__c != null)
                            {
                                ac.Contact__c= Opt[0].Opportunity.Primary_Marketo_User_Lookup__c ;
                            }
                            ac.Entitlement__c= ent.id;
                            ac.Customer_Admin__c=true;  
                                
                          /*  if(ac.Contact__c !=null && CurrentOpp[0].Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId)
                            {
                                ListOfAuthorizedContact.add(ac);
                                system.debug('ooo2'); 
                                
                            }*/
                            if(ac.Contact__c !=null && Opt[0].Opportunity.Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId)
                            {
                                ListOfAuthorizedContact.add(ac);
                                system.debug('ooo2'); 
                                
                            }
                        }
                }
            }
             system.debug('This is size of ac '+ListOfAuthorizedContact.size());  
            if(ListOfAuthorizedContact.size()>0)
            {
                upsert ListOfAuthorizedContact ;
            }
    }
    @isTest(SeeAllData=true)
    private static void AEEmailController()
    {
        Account a = new Account(Name='Test Acc',Sales_Region__c = 'North America');
         insert a;
         Contact c = new Contact(LastName = 'test Con',LeadSource = 'Blog',AccountId = a.id);
         insert c;       
         Opportunity Opp = new Opportunity(Name='test opp',AccountId=a.id,Type='New Business',CloseDate=Date.today(),stagename='Discovery',Deal_Type__c = 'Standard',NextStep='test',CRM_System__c = 'ACT!',LeadSource = 'Blog',Primary_Marketo_User_Lookup__c = c.id);
         insert Opp; 
         List<Product2> ProList = new List<Product2>();  
         Product2 p =new Product2(Name='test pro',IsActive = true,ConvertTo__c = 'Subscription',family='Dedicated IP',ProductCode='abc');
         ProList.add(p);
         Product2 p2 =new Product2(Name='test pro2',IsActive = true,ConvertTo__c = 'Add On',family='Dedicated IP');
         ProList.add(p2);
         Product2 p3 =new Product2(Name='test pro3',IsActive = true,ConvertTo__c = 'Entitlement-Spark',family='Dedicated IP');
         ProList.add(p3);
         Product2 p4 =new Product2(Name='test pro4',IsActive = true,ConvertTo__c = 'Entitlement-Spark',family='Dedicated IP');
         ProList.add(p4);
         insert ProList;
         List<PriceBook2> PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];
         //Product2 prod = [SELECT p.Id FROM Product2 p WHERE p.Name = 'Lead Management - Professional 100K'];
         List<PriceBookEntry> PBEList = new List<PriceBookEntry>();
         PriceBookEntry Pe = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p.id,UnitPrice=200);
         PBEList.add(Pe); 
         PriceBookEntry Pe2 = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p2.id,UnitPrice=200);
         PBEList.add(Pe2);
         PriceBookEntry Pe3 = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p3.id,UnitPrice=200);
         PBEList.add(Pe3);
          PriceBookEntry Pe4 = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p4.id,UnitPrice=200);
         PBEList.add(Pe4);
         insert PBEList;
        /* List<PriceBookEntry> pbe_list = [Select p.Id, p.Name, p.Pricebook2Id, p.Product2Id , p.CreatedById , p.LastModifiedById From PricebookEntry p WHERE
                p.Pricebook2.Name = 'Standard Price Book' and p.IsActive = true];//and p.Name = 'Lead Management - Professional 100K' and p.IsActive = true];
            PricebookEntry pbe = pbe_list.get(0);*/
            List<OpportunityLineItem> OplList = new List<OpportunityLineItem>();        
            OpportunityLineItem oli = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli.Users__c = 1;
            oli.MLM_Edition__c = 'test edition';
            oli.OpportunityId = Opp.Id;
            oli.PricebookEntryId = pe.Id;
            oli.Instance_Number__c = 123;
            oli.Quantity = 2;
            oli.UnitPrice = 200;
          //  oli.Quantity_1__c = 34;
          //  oli.Sales_Price_1__c = 500; 
            OplList.add(oli);
             OpportunityLineItem oli2 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli2.Users__c = 1;
            oli2.MLM_Edition__c = 'test edition';
            oli2.OpportunityId = Opp.Id;
            oli2.PricebookEntryId = pe2.Id;
            oli2.Quantity = 2;
               oli2.UnitPrice = 200;
         //   oli2.Quantity_1__c = 34;
         //   oli2.Sales_Price_1__c = 500; 
             OplList.add(oli2);
               OpportunityLineItem oli3 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli3.Users__c = 1;
            oli3.MLM_Edition__c = 'test edition';
            oli3.OpportunityId = Opp.Id;
            oli3.PricebookEntryId = pe3.Id;
              oli3.Quantity = 2;
                 oli3.UnitPrice = 200;
          //  oli3.Quantity_1__c = 34;
          //  oli3.Sales_Price_1__c = 500; 
         //  OplList.add(oli3);
                OpportunityLineItem oli4 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli4.Users__c = 1;
            oli4.MLM_Edition__c = 'test edition';
            oli4.OpportunityId = Opp.Id;
            oli4.PricebookEntryId = pe4.Id;
              oli4.Quantity = 2;
                 oli4.UnitPrice = 200;
           // OplList.add(oli4);
           Test.StartTest();
            insert OplList;
            List<RecordType> Rc = [SELECT id from RecordType WHERE Name = 'Closed Won' limit 1];
            Opp.RecordTypeId = Rc[0].id;
            Opp.Stagename = 'Closed Won';
            
            update Opp;
            Test.stopTest();
           // createFromEmail(Opp.id ,'001','','abc','123','','aer');
    }
    
}