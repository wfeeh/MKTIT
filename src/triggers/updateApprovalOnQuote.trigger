trigger updateApprovalOnQuote on QuoteLineItem (after insert,after update ,after delete) {
 set<id> QIds = new set<id>();
 if(Trigger.isInsert || trigger.isupdate)
 {
   
   for(QuoteLineItem  Q : trigger.new)
   {
       QIds.add(Q.Quoteid);
   }
 }
 else if(Trigger.isDelete)
 {
   for(QuoteLineItem  Q : trigger.Old)
   {
       QIds.add(Q.Quoteid);
   }  
     
 }
 
    List<Quote> QuotesANdQuoteLineItems = [SELECT  id,Sales_Approval__c,
                                          PS_Approval__c,Support_Approval__c,
                                            (
                                                select id,QuoteID,Discount,
                                                pricebookentry.product2.Edition__c,
                                                pricebookentry.product2.ProductCode,
                                                pricebookentry.product2.Family,
                                                pricebookentry.product2.Name
                                                from QuoteLineItems  
                                            )
                                            FROM Quote WHERE Id IN: QIds];
     string Sales_Approval ;//= '';
     string PS_Approval ;//= '';
     string Support_Approval ;//= '';  
     Boolean HasEnterprise;
     for(Quote quo : QuotesANdQuoteLineItems )
     {
         Sales_Approval = '';
         PS_Approval = '';
         Support_Approval = '';
         HasEnterprise = false; 
         for(Quotelineitem ql : quo.Quotelineitems)
         {
             if(ql.pricebookentry.product2.Edition__c=='Enterprise')
                 HasEnterprise = true;
             
         } 
         for(Quotelineitem ql : quo.Quotelineitems)
         {
              //Quote sales approval start body 
            if((ql.pricebookentry.product2.Edition__c=='Enterprise' && ql.Discount >= 30) || (ql.pricebookentry.product2.Edition__c!='Enterprise' && ql.Discount >0))
            {        
               // quo.Sales_Approval__c = 'Approval Needed';
               Sales_Approval = 'Approval Needed';
            }
            
         /*   else if(ql.pricebookentry.product2.Edition__c!='Enterprise' && ql.Discount >0)
            {
                quo.Sales_Approval__c = 'Approval Needed';    
            }*/
            //Quote sales approval end body 

        //Quote PS Approval start body
    
        if(ql.pricebookentry.product2.ProductCode=='INT-CUST' ||
           ql.pricebookentry.product2.ProductCode=='SV-SOW'   ||
           (ql.pricebookentry.product2.Family == 'Services' && ql.Discount >0) ||
           (ql.pricebookentry.product2.Name.contains('Launch Pack')  && HasEnterprise))                      
            {
               // quo.PS_Approval__c = 'Approval Needed';
               PS_Approval = 'Approval Needed';
            }
        //Quote PS Approval end body
    
        //Quote Support Approval start body
    
        if(ql.pricebookentry.product2.Family == 'Services')
        {
            //quo.Support_Approval__c = 'Approval Needed';
            Support_Approval = 'Approval Needed';  
        }
        //Quote Support Approval end body    
                
    }
         
         if(Sales_Approval != '')
             quo.Sales_Approval__c = 'Approval Needed';
         else
              quo.Sales_Approval__c = 'Approved';
              
         if(PS_Approval != '') 
              quo.PS_Approval__c = 'Approval Needed'; 
         else
              quo.PS_Approval__c = 'Approved';
              
         if(Support_Approval != '')
              quo.Support_Approval__c = 'Approval Needed'; 
         else
              quo.Support_Approval__c = 'Approved';        
       
     }   
     if(QuotesANdQuoteLineItems .size()>0)
     {
         update QuotesANdQuoteLineItems ;
     }                                      
// }            
             /*    List<Opportunity> mlmOps = [
        SELECT  o.Id, o.Name, o.Account.Name, o.Account.Website, o.Primary_Marketo_User_Email__c, o.Primary_Marketo_User_Lookup__r.FirstName, 
            o.Primary_Marketo_User_Lookup__r.LastName, o.MP_Purpose__c, o.MP_Reseller_Partner__c,
            o.Subscription_Language__c,o.Subscription_Locale__c,Subscription_Time_Zone__c,
            (SELECT ol.Id, ol.Product_Family__c, ol.Users__c, ol.MLM_Edition__c, ol.Instance_Number__c, ol.Related_Asset__c,Subscription_Language__c,Subscription_Locale__c,Subscription_Time_Zone__c,   
            ol.PricebookEntry.Product2.Name, ol.PricebookEntry.Product2.Family, ol.PricebookEntry.Product2.ProductCode
            FROM o.OpportunityLineItems ol 
            WHERE 
                ol.PricebookEntry.Product2.Family = 'Lead Management' 
                OR ol.PricebookEntry.Product2.Family = 'Sales Insight'
                OR ol.PricebookEntry.Product2.Family = 'Select Edition' 
                OR ol.PricebookEntry.Product2.Family = 'Spark Edition' 
                OR ol.PricebookEntry.Product2.Family = 'Standard Edition'
                
            )
             FROM Opportunity o WHERE o.Id IN :oppIds and o.Type = 'New Business' ]; */
/* Runs when QuoteLineItem  is inserted or updated start body*/ 
/*
if(Trigger.isupdate || trigger.isInsert)
{
list<Quote> QuotesToUpdate = new list<Quote>();
QuotesToUpdate .clear();
set<id> QuoteIds = new set<id>();
for(QuoteLineItem QLineItem : trigger.new)
{
    QuoteIds.add(QLineItem.QuoteID); 
}

Map<id,Quote> QuoteIdAndQuote = new MAp<id,Quote>();
for(Quote q : [select id,Sales_Approval__c,PS_Approval__c,Support_Approval__c from quote where id in:QuoteIds ])
{
    QuoteIdAndQuote.put(q.id,q);
}

for(QuoteLineItem  QLI : [select id,QuoteID,Discount,
                          pricebookentry.product2.Edition__c,
                          pricebookentry.product2.ProductCode,
                          pricebookentry.product2.Family,
                          pricebookentry.product2.Name
                          from QuoteLineItem  where id in: trigger.new])
{
quote q = QuoteIdAndQuote.get(QLI.QuoteID);
//Quote sales approval start body 
    if(QLI.pricebookentry.product2.Edition__c=='Enterprise' && QLI.Discount >= 30)
    {        
        q.Sales_Approval__c = 'Approval Needed';
    }
    else if(QLI.pricebookentry.product2.Edition__c!='Enterprise' && QLI.Discount >0)
    {
        q.Sales_Approval__c = 'Approval Needed';    
    }
//Quote sales approval end body 

//Quote PS Approval start body

    if(QLI.pricebookentry.product2.ProductCode=='INT-CUST' ||
       QLI.pricebookentry.product2.ProductCode=='SV-SOW'   ||
       (QLI.pricebookentry.product2.Family == 'Services' && QLI.Discount >0) ||
       QLI.pricebookentry.product2.Name=='Launch pack'   ||
       QLI.pricebookentry.product2.Edition__c=='Enterprise'
       )
        {
            q.PS_Approval__c = 'Approval Needed';
        }
//Quote PS Approval end body

//Quote Support Approval start body

    if(QLI.pricebookentry.product2.Family == 'Services')
    {
        q.Support_Approval__c = 'Approval Needed';  
    }
//Quote Support Approval end body    
    
//adding in list to update
QuotesToUpdate.add(q); 
}

if(QuotesToUpdate.size()>0)
{
    update QuotesToUpdate ;
}

} */
 /* Runs when QuoteLineItem  is inserted or updated End body*/
 
/* Runs when QuoteLineItem  is deleted start body*/
/*
if(Trigger.isdelete)
{
List<Quote> QuotesToUpdate = new List<Quote>();
set<id> QuoteIds = new set<id>();
for(QuoteLineItem QLineItem : trigger.old)
{
    QuoteIds.add(QLineItem.QuoteID); 
}

Map<id,Quote> QuoteIdAndQuote = new MAp<id,Quote>();
for(Quote q : [select id,Sales_Approval__c from quote where id in:QuoteIds ])
{
    QuoteIdAndQuote.put(q.id,q);
}

for(QuoteLineItem  QLI :  [select id,QuoteID,Discount,
                          pricebookentry.product2.Edition__c,
                          pricebookentry.product2.ProductCode,
                          pricebookentry.product2.Family,
                          pricebookentry.product2.Name from QuoteLineItem  where id in: trigger.old])
{
quote q = QuoteIdAndQuote.get(QLI.QuoteID);

//Quote sales approval start body 
    if(QLI.pricebookentry.product2.Edition__c=='Enterprise' && QLI.Discount >= 30)
    {        
        q.Sales_Approval__c = null;        
    }
    else if(QLI.pricebookentry.product2.Edition__c!='Enterprise' && QLI.Discount >0)
    {
        q.Sales_Approval__c = null;      
    }
//Quote sales approval end body 
    
//Quote PS Approval start body

    if(QLI.pricebookentry.product2.ProductCode=='INT-CUST' ||
       QLI.pricebookentry.product2.ProductCode=='SV-SOW'   ||
       (QLI.pricebookentry.product2.Family == 'Services' && QLI.Discount >0) ||
       QLI.pricebookentry.product2.Name=='Launch pack'   ||
       QLI.pricebookentry.product2.Edition__c=='Enterprise'
       )
        {
            q.PS_Approval__c = null;
        }
//Quote PS Approval end body

//Quote Support Approval start body

    if(QLI.pricebookentry.product2.Family == 'Services')
    {
        q.Support_Approval__c = 'Approved';  
    }
//Quote Support Approval end body 
    
    
QuotesToUpdate.add(q);
}

if(QuotesToUpdate.size()>0)
{
    update QuotesToUpdate ;
}

} */
/* Runs when QuoteLineItem is deleted end body*/

}