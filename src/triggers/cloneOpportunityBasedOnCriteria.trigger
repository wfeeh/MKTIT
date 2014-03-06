trigger cloneOpportunityBasedOnCriteria on Opportunity (after update) {
ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales').getRecordTypeId();

map<ID,string> oppAccountname=new map<ID,string>();
string dealtypes=Label.Deal_types;
List<Id> opp_List=new List<Id>();

                       for(opportunity opp: trigger.new){
                       System.debug('@@@@'+opp.Account.name);
                       opp_list.add(opp.AccountID);
                       }
                       
                    Map<Id,Account> accountMap = new Map<Id,Account>([
        select Id
             , Name
          from Account
         where Id IN: opp_List]);   
                       
List<User> Renewal = [select id
                       FROM User
                       Where Name = 'Renewals Team' limit 1];
   /* map<id,string> recordTypeAndName = new map<id,string>();
List<Recordtype> Rcc =[SELECT id,developername, name
                      FROM RecordType
                      WHERE sObjectType='Opportunity' ];
    for(Recordtype rtype :Rcc)
        {
        recordTypeAndName.put(rtype.id,rtype.name);
        }
        boolean belowCodeRun =true;
        
        for(Opportunity itr : trigger.new)
        {
            if(itr.recordtypeId!=trigger.oldmap.get(itr.id).recordtypeId)
            {
                if(recordTypeAndName.get(itr.recordtypeid) == 'Closed Won')
                {
                belowCodeRun =true;
                }
                else
                belowCodeRun =false;
            }
            else
            belowCodeRun =false;
        }
        */
        
 //       if(belowCodeRun)
//{
    if(OppProQuanPrice_TriggerClass.isFromTriggerCloneOppBasedonCriteria == false)
    {
    OppProQuanPrice_TriggerClass.isFromTriggerCloneOppBasedonCriteria = true;
List<Recordtype> Rc =[SELECT id,
                             name
                      FROM RecordType
                      WHERE sObjectType='Opportunity'
                      and name = 'Closed Won' limit 1];
   List<string> ClosedWonOppList = new List<string>();
   List<opportunity> RenewalOpps = new List<opportunity>();
   Map<Id,List<OpportunityLineItem>> OplMap = new Map<Id,List<OpportunityLineItem>>();
   Map<Id,List<OpportunityContactRole>> OpConRole = new Map<Id,List<OpportunityContactRole>>();
   integer Q;
   List<string> ClosedWonOppList_renew = new List<string>();
   List<opportunity> RenewalOpps_renew = new List<opportunity>();
   Map<Id,List<OpportunityLineItem>> OplMap_renew = new Map<Id,List<OpportunityLineItem>>();
   Map<Id,List<OpportunityContactRole>> OpConRole_renew = new Map<Id,List<OpportunityContactRole>>();
  
if(!test.isrunningtest()){
  for(Opportunity o_re:trigger.new)
   {
   if(Trigger.isupdate && Trigger.oldmap.get(o_re.id).RecordTypeId != o_re.RecordTypeId && !test.isRunningTest())
        {
             if(Rc.size() > 0 && Rc[0].id == o_re.RecordTypeId && o_re.Type =='Renewal')
                {
                // system.debug('SyncedQuoteId update'+o.SyncedQuoteId);
              //  if(o.SyncedQuoteId == null)
              //  {
                  if(o_re.deal_type__c!=null)
        if(!dealtypes.containsIgnorecase(o_re.deal_type__c)){
                 ClosedWonOppList_renew.add(o_re.id);
                 }
              //  }
              /*  else
                {
                 o.adderror('For creating renewals this opportunity should not be in sync mode');
                }*/
                }
        }
   
   for(Opportunity o:trigger.new)
   {
       /* if(Trigger.isinsert)
        {
            if(Rc.size() > 0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business')
            {
            system.debug('SyncedQuoteId insert'+o.SyncedQuoteId);
               // if(o.SyncedQuoteId == null)
               // {
                ClosedWonOppList.add(o.id);                
               // system.debug('ClosedWonOppList'+ClosedWonOppList.size());
              //  }
             
            }
        }*/
        
        if(Trigger.isupdate && Trigger.oldmap.get(o.id).RecordTypeId != o.RecordTypeId)
        {
             if(Rc.size() > 0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business')
                {
                 system.debug('SyncedQuoteId update'+o.SyncedQuoteId);
              //  if(o.SyncedQuoteId == null)
              //  {
                
 if(o.deal_type__c!=null)
        if(!dealtypes.containsIgnorecase(o.deal_type__c)){
                ClosedWonOppList.add(o.id);
                }
              //  }
              /*  else
                {
                 o.adderror('For creating renewals this opportunity should not be in sync mode');
                }*/
                }
        }
        /*
         system.debug('Trigger.isupdate'+Trigger.isupdate);
         system.debug('o.RecordTypeId'+o.RecordTypeId);
         
      system.debug('Trigger.oldmap.get(o.id).RecordTypeId'+Trigger.oldmap.get(o.id).RecordTypeId);
        */
      // system.debug('Trigger.isupdate'+Trigger.isupdate);
       /* else if (Test.isrunningtest() && Trigger.oldmap.get(o.id).RecordTypeId != o.RecordTypeId)
        {
        if(Rc.size() > 0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business')
                {
                ClosedWonOppList.add(o.id);
                }
        }  */
      //  system.debug('Trigger.isupdate'+Trigger.isupdate);
   }
   
   List<OpportunityContactRole> ConRole = [SELECT id,
                                                  OpportunityId,
                                                  IsPrimary,
                                                  contactId
                                          FROM OpportunityContactRole
                                          WHERE OpportunityId in : ClosedWonoppList limit 200];
    for(OpportunityContactRole oc:ConRole)
    {
        if(!OpConRole.keyset().contains(oc.OpportunityId))
         {
             OpConRole.put(oc.OpportunityId, new List<OpportunityContactRole>{oc});
         }
         else
         {
             OpConRole.get(oc.opportunityId).add(oc);
         }
    }   
if(!test.isRunningTest()){
List<OpportunityContactRole> ConRole_renew = [SELECT id,
                                                  OpportunityId,
                                                  IsPrimary,
                                                  contactId
                                          FROM OpportunityContactRole
                                          WHERE OpportunityId in : ClosedWonoppList_renew limit 200];
    for(OpportunityContactRole oc_renew:ConRole_renew)
    {
        if(!OpConRole_renew.keyset().contains(oc_renew.OpportunityId))
         {
             OpConRole_renew.put(oc_renew.OpportunityId, new List<OpportunityContactRole>{oc_renew});
         }
         else
         {
             OpConRole_renew.get(oc_renew.opportunityId).add(oc_renew);
         }
    }   
    
}
   List<OpportunityLineItem> OplList = [SELECT id,
                                               OpportunityId,
                                               PriceBookEntryId,
                                               Total_ARR_for_RUSF__c,
                                               Quantity,                                              
                                               Subtotal,
                                               UnitPrice,                                             
                                               ListPrice,
                                               Description,
                                               Discount,
                                               ServiceDate,                                                                                               
                                               ARR__c,
                                               ARR_Credit_over_12__c,  
                                                ARR_Credit_under_12__c, 
                                                ARR_NB_partial_year__c, 
                                                ARR_Renewal__c  ,
                                                ARR_Spark__c,   
                                                ARR_Spark_SI__c ,
                                                ARR_Upsell__c,                                                  
                                                Calculated_Term__c, 
                                                DiscountAmount__c,
                                                Line_Item_Price__c,
                                                Express_Product_Family__c,
                                                Product_Family__c,
                                                Full_Price__c,  
                                                Geography__c,   
                                                Instance_Number__c, 
                                                Line_Item_Note__c,
                                                Location__c,
                                                MLM_Edition__c, 
                                                Monthly_Price__c,
                                                MRR__c , 
                                                ServiceEndDate__c,OpportunityLineItem.Pricebookentry.Product2.Name      
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId in : ClosedWonOppList limit 200 ];
                                        system.debug('OplList'+OplList.size());

   for(OpportunityLineItem opl:OplList)
   {
         if(!OplMap.keyset().contains(opl.OpportunityId))
         {
             OplMap.put(opl.OpportunityId, new List<OpportunityLineItem>{opl});
         }
         else
         {
             OplMap.get(opl.opportunityId).add(opl);
         }
   }
   if(!test.isRunningTest()){
   List<OpportunityLineItem> OplList_renew = [SELECT id,
                                               OpportunityId,
                                               PriceBookEntryId,
                                               Total_ARR_for_RUSF__c,
                                               Quantity,                                              
                                               Subtotal,
                                               UnitPrice,                                             
                                               ListPrice,
                                               Description,
                                               Discount,
                                               ServiceDate,                                                                                               
                                               ARR__c,
                                               ARR_Credit_over_12__c,  
                                                ARR_Credit_under_12__c, 
                                                ARR_NB_partial_year__c, 
                                                ARR_Renewal__c  ,
                                                ARR_Spark__c,   
                                                ARR_Spark_SI__c ,
                                                ARR_Upsell__c,                                                  
                                                Calculated_Term__c, 
                                                DiscountAmount__c,
                                                Line_Item_Price__c,
                                                Express_Product_Family__c,
                                                Product_Family__c,
                                                Full_Price__c,  
                                                Geography__c,   
                                                Instance_Number__c, 
                                                Line_Item_Note__c,
                                                Location__c,
                                                MLM_Edition__c, 
                                                Monthly_Price__c,
                                                MRR__c , 
                                                ServiceEndDate__c,OpportunityLineItem.Pricebookentry.Product2.Name       
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId in : ClosedWonOppList_renew limit 200 ];
                                        system.debug('OplList'+OplList.size());

   for(OpportunityLineItem opl_renew:OplList_renew)
   {
         if(!OplMap_renew.keyset().contains(opl_renew.OpportunityId))
         {
             OplMap_renew.put(opl_renew.OpportunityId, new List<OpportunityLineItem>{opl_renew});
         }
         else
         {
             OplMap_renew.get(opl_renew.opportunityId).add(opl_renew);
         }
   }
   
   }
   if(ClosedWonOppList.size()>0)
   {
   for(Opportunity o:trigger.new)
   {
         if(o.deal_type__c!=null)
        if(!dealtypes.containsIgnorecase(o.deal_type__c)){
        
        Q=-1;
        if(o.Quarterly_Renewal__c != null)
            Q = integer.valueof(o.Quarterly_Renewal__c);
      // if(Trigger.isinsert)
      // {
        /*    if(Rc.size()>0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business' && Q >=1)
            {
            
            integer aa=1;
                for(integer a=0;a<3;a++)
                {
                
                   // opportunity newOpp= o.clone(false,true);
                    Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                    
                    newopp.Quarterly_Renewal__c=string.valueOf(a+2);
                  //  newopp.Name = o.Name+'-0'+(a+1)+'R';
                   newOpp.Name=o.Accounts.Name + ' - Renewal ' + o.Closedate.Year();
                    if(Renewal.size()>0)
                        newopp.ownerId = Renewal[0].id;
                     
                   if(o.Sub_End_Date__c !=null)
                   {
                    newOpp.CloseDate=o.Sub_End_Date__c.addmonths(aa*3);
                    newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    newOpp.Sub_Start_Date__c =  o.Sub_End_Date__c;
                    newOpp.Sub_End_Date__c =  o.Sub_End_Date__c.addDays(aa*90);
                   }    
                   else
                   {
                   newOpp.CloseDate=o.CloseDate.addmonths(aa*3);
                   }             
                   
                    newOpp.Type='Renewal';
                    newOpp.Prior_Opportunity__c = o.id;
                    newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                    newOpp.RecordTypeId=RenewalSalesId;
                    newOpp.StageName='Discovery';
                     if(o.Opportunity_ARR2012__c != null)
                        newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c;
                    RenewalOpps.add(newOpp);
                    aa++;
                }
                
            }
            else if(Rc.size()>0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business' && o.Quarterly_Renewal__c== null)
            {
                
               list<opportunityLineItem> LOP =  OplMap.get(o.id);
               date HighestDate ;
               for(opportunityLineItem ol : LOP)
               {             
                
                  if(ol.ServiceEndDate__c !=null ) 
                  {
                         if(HighestDate ==null)
                          {
                           HighestDate=ol.ServiceEndDate__c;
                          }
                  
                         else if(HighestDate <= ol.ServiceEndDate__c)
                          {
                           HighestDate=ol.ServiceEndDate__c;
                          }
                          
                 } 
                           
               }
               if(HighestDate==null)
               {
               HighestDate=o.closedate;
               }
               system.debug('HighestDate'+HighestDate);
                //opportunity newOpp= o.clone(false,true);
                Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
               // newopp.Name = o.Name+'-01R';
                newOpp.Name=o.Accounts.Name + ' - Renewal ' + o.Closedate.Year();
                newopp.closeDate=HighestDate;
                if(Renewal.size()>0)
                        newopp.ownerId = Renewal[0].id;
           
                   if(o.Sub_End_Date__c !=null)
                   {
                    newOpp.CloseDate=o.Sub_End_Date__c;
                    newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    newOpp.Sub_Start_Date__c =  o.Sub_End_Date__c;
                    newOpp.Sub_End_Date__c =  o.Sub_End_Date__c.addDays(360);
                   } 
                   else
                   {
                   newOpp.CloseDate=o.CloseDate;
                   }
              
                newOpp.Type='Renewal'; 
                newOpp.Prior_Opportunity__c = o.id;
                newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                newOpp.RecordtypeId=RenewalSalesId;
                newOpp.stageName = 'Discovery';
                if(o.Opportunity_ARR2012__c != null)
                    newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c;
               // newOpp.SyncedQuoteId=null;
                RenewalOpps.add(newOpp);
            }*/
       // }
       Date EndDate;
        if(Trigger.isupdate && Trigger.oldMap.get(o.id).RecordTypeId != o.RecordTypeId && o.stagename=='Closed Won')
        {
           if(Rc.size()>0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business' && Q >=1)
            {
            integer aa=1;
                for(integer a=0;a<3;a++)
                {
                
                   // opportunity newOpp= o.clone(false,true);
                   Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                    newopp.Quarterly_Renewal__c=string.valueOf(a+2);
                    newOpp.Name = o.Name+'-0'+(a+2)+'R';
                     //system.debug('o.Account.Name'+o.Account.Name);
                    // newOpp.Name=o.Account.Name + ' - Renewal ' + o.Closedate.Year();
                    // newOpp.Name=accountMap.get(o.AccountID).Name+ ' - Renewal ' + o.Closedate.Year();
                    newOpp.CloseDate=o.CloseDate.addmonths(aa*3);
                    if(Renewal.size()>0)
                        newopp.ownerId = Renewal[0].id;
                   if(o.Sub_End_Date__c !=null)
                   {
//                    newOpp.CloseDate=o.Sub_End_Date__c.addmonths(aa*3);
                    newOpp.CloseDate=EndDate !=null ? EndDate: o.Sub_End_Date__c;
                  //  newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                     newOpp.Plan_of_Record_Renewal_Date__c = newOpp.CloseDate;
                    
                    /* Added one day to the beginning of the start date for the renewal */
                    newOpp.Sub_Start_Date__c = EndDate !=null ? EndDate + 1 : o.Sub_End_Date__c+1;
                    EndDate = EndDate == null ? o.Sub_End_Date__c.addMonths(3) : EndDate.addMonths(3) ;
                    newOpp.Sub_End_Date__c =  EndDate;
                   } 
                   else
                   {
                   newOpp.CloseDate=o.CloseDate.addmonths(aa*3);
                   }
                    newOpp.Type='Renewal';
                    newOpp.Prior_Opportunity__c = o.id;
                    newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                    newOpp.RecordtypeId=RenewalSalesId;
                 //   newOpp.stageName = 'Discovery';
                    newOpp.stageName = 'Not Contacted';
                    if(o.Opportunity_ARR2012__c != null)
                      newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c/4;
                  // newOpp.SyncedQuoteId=null;
                    RenewalOpps.add(newOpp);
                    aa++;
                }
                
            }
            else if(Rc.size()>0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business' && o.Quarterly_Renewal__c== null)
            {
             date HighestDate ;
               if(OplMap.keyset().contains(o.id)){ 
                   list<opportunityLineItem> LOP =  OplMap.get(o.id);
                  
                   for(opportunityLineItem ol : LOP)
                   {             
                    
                      if(ol.ServiceEndDate__c !=null ) 
                      {
                             if(HighestDate ==null)
                              {
                               HighestDate=ol.ServiceEndDate__c;
                              }
                      
                             else if(HighestDate <= ol.ServiceEndDate__c)
                              {
                               HighestDate=ol.ServiceEndDate__c;
                              }
                     } 
                               
                   }
               }
               if(HighestDate==null)
               {
               HighestDate=o.closedate;
               }
               system.debug('HighestDate'+HighestDate);
                //opportunity newOpp= o.clone(false,true);
                 Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                newopp.closeDate=o.closedate.adddays(365);
                  if(Renewal.size()>0)
                        newopp.ownerId = Renewal[0].id;
                   if(o.Sub_End_Date__c !=null)
                   {
                    newOpp.CloseDate=o.Sub_End_Date__c;
                  //  newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    newOpp.Plan_of_Record_Renewal_Date__c = newOpp.CloseDate ;
                    newOpp.Sub_Start_Date__c =  o.Sub_End_Date__c+1;
                    newOpp.Sub_End_Date__c =  o.Sub_End_Date__c.addDays(365);
                   } 
                   else
                   {
                   newOpp.CloseDate=o.CloseDate.adddays(365);
                   }
                system.debug('o.Account.Name'+o.id);
                System.debug('@@@@'+oppAccountname.get(o.id));
                //newOpp.Name = o.Name+'-01R';
                 if(o.Sub_End_Date__c!=null)
                 
                newOpp.Name=accountMap.get(o.AccountID).Name+ ' - Renewal ' + o.Sub_End_Date__c.Year();
                else
                newOpp.Name=accountMap.get(o.AccountID).Name+ ' - Renewal ' + o.closeDate.adddays(365).Year();
              // newopp.closeDate=o.closedate;
              
                newOpp.Type='Renewal'; 
                newOpp.Prior_Opportunity__c = o.id;
                newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                newOpp.RecordtypeId=RenewalSalesId;
               // newOpp.stageName = 'Discovery';
                newOpp.stageName = 'Not Contacted';
                  if(o.Opportunity_ARR2012__c != null){
                  //newOpp.Opportunity_ARR2012__c=o.Opportunity_ARR2012__c ;
                    newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c;
                    }
             //   newOpp.SyncedQuoteId=null;
                RenewalOpps.add(newOpp);
            }
        }
}    
    } 
   }
   
   if(!test.isRunningTest()){
   if(ClosedWonOppList_renew.size()>0)
   {
   for(Opportunity o_renew:trigger.new)
   {
 if(o_renew.deal_type__c!=null)
        if(!dealtypes.containsIgnorecase(o_renew.deal_type__c)){       
       Q=-1;
        if(o_renew.Quarterly_Renewal__c != null)
            Q = integer.valueof(o_renew.Quarterly_Renewal__c);
      // if(Trigger.isinsert)
      // {
        /*    if(Rc.size()>0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business' && Q >=1)
            {
            
            integer aa=1;
                for(integer a=0;a<3;a++)
                {
                
                   // opportunity newOpp= o.clone(false,true);
                    Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                    
                    newopp.Quarterly_Renewal__c=string.valueOf(a+2);
                  //  newopp.Name = o.Name+'-0'+(a+1)+'R';
                   newOpp.Name=o.Accounts.Name + ' - Renewal ' + o.Closedate.Year();
                    if(Renewal.size()>0)
                        newopp.ownerId = Renewal[0].id;
                     
                   if(o.Sub_End_Date__c !=null)
                   {
                    newOpp.CloseDate=o.Sub_End_Date__c.addmonths(aa*3);
                    newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    newOpp.Sub_Start_Date__c =  o.Sub_End_Date__c;
                    newOpp.Sub_End_Date__c =  o.Sub_End_Date__c.addDays(aa*90);
                   }    
                   else
                   {
                   newOpp.CloseDate=o.CloseDate.addmonths(aa*3);
                   }             
                   
                    newOpp.Type='Renewal';
                    newOpp.Prior_Opportunity__c = o.id;
                    newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                    newOpp.RecordTypeId=RenewalSalesId;
                    newOpp.StageName='Discovery';
                     if(o.Opportunity_ARR2012__c != null)
                        newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c;
                    RenewalOpps.add(newOpp);
                    aa++;
                }
                
            }
            else if(Rc.size()>0 && Rc[0].id == o.RecordTypeId && o.Type =='New Business' && o.Quarterly_Renewal__c== null)
            {
                
               list<opportunityLineItem> LOP =  OplMap.get(o.id);
               date HighestDate ;
               for(opportunityLineItem ol : LOP)
               {             
                
                  if(ol.ServiceEndDate__c !=null ) 
                  {
                         if(HighestDate ==null)
                          {
                           HighestDate=ol.ServiceEndDate__c;
                          }
                  
                         else if(HighestDate <= ol.ServiceEndDate__c)
                          {
                           HighestDate=ol.ServiceEndDate__c;
                          }
                          
                 } 
                           
               }
               if(HighestDate==null)
               {
               HighestDate=o.closedate;
               }
               system.debug('HighestDate'+HighestDate);
                //opportunity newOpp= o.clone(false,true);
                Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
               // newopp.Name = o.Name+'-01R';
                newOpp.Name=o.Accounts.Name + ' - Renewal ' + o.Closedate.Year();
                newopp.closeDate=HighestDate;
                if(Renewal.size()>0)
                        newopp.ownerId = Renewal[0].id;
           
                   if(o.Sub_End_Date__c !=null)
                   {
                    newOpp.CloseDate=o.Sub_End_Date__c;
                    newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    newOpp.Sub_Start_Date__c =  o.Sub_End_Date__c;
                    newOpp.Sub_End_Date__c =  o.Sub_End_Date__c.addDays(360);
                   } 
                   else
                   {
                   newOpp.CloseDate=o.CloseDate;
                   }
              
                newOpp.Type='Renewal'; 
                newOpp.Prior_Opportunity__c = o.id;
                newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                newOpp.RecordtypeId=RenewalSalesId;
                newOpp.stageName = 'Discovery';
                if(o.Opportunity_ARR2012__c != null)
                    newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c;
               // newOpp.SyncedQuoteId=null;
                RenewalOpps.add(newOpp);
            }*/
       // }
       Date EndDate;
        if(Trigger.isupdate && Trigger.oldMap.get(o_renew.id).RecordTypeId != o_renew.RecordTypeId && o_renew.stagename=='Closed Won')
        {
           
             if(Rc.size()>0 && Rc[0].id == o_renew.RecordTypeId && o_renew.Type =='Renewal' && o_renew.Quarterly_Renewal__c== null)
            {
             date HighestDate ;
               if(OplMap_renew.keyset().contains(o_renew.id)){ 
                   list<opportunityLineItem> LOP_renew =  OplMap_renew.get(o_renew.id);
                  
                   for(opportunityLineItem ol_renew : LOP_renew)
                   {             
                    
                      if(ol_renew.ServiceEndDate__c !=null ) 
                      {
                             if(HighestDate ==null)
                              {
                               HighestDate=ol_renew.ServiceEndDate__c;
                              }
                      
                             else if(HighestDate <= ol_renew.ServiceEndDate__c)
                              {
                               HighestDate=ol_renew.ServiceEndDate__c;
                              }
                     } 
                               
                   }
               }
               if(HighestDate==null)
               {
               HighestDate=o_renew.closedate;
               }
               system.debug('HighestDate'+HighestDate);
                //opportunity newOpp= o.clone(false,true);
                 Opportunity newopp_renew = RenewalTriggerMappingController.MapFields(o_renew);
                newopp_renew.closeDate=HighestDate;
                  if(Renewal.size()>0)
                        newopp_renew.ownerId = Renewal[0].id;
                   if(o_renew.Sub_End_Date__c !=null)
                   {
                        newOpp_renew.CloseDate=o_renew.Sub_End_Date__c;
                        //newOpp_renew.Account.Acct_Renewal_Date__c=newOpp_renew.CloseDate;
                    // newOpp_renew.CloseDate=o_renew.CloseDate.addDays(365);
                  //  newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    newOpp_renew.Plan_of_Record_Renewal_Date__c = newOpp_renew.CloseDate ;
                    newOpp_renew.Sub_Start_Date__c = o_renew.Sub_Start_Date__c.addDays(365) ;
                    newOpp_renew.Sub_End_Date__c =  o_renew.Sub_End_Date__c.addDays(365);
                   } 
                   else
                   {
                   newOpp_renew.CloseDate=o_renew.CloseDate.addDays(365);
                   }
                system.debug('o.Account.Name'+o_renew.id);
                System.debug('@@@@'+oppAccountname.get(o_renew.id));
                //newOpp.Name = o.Name+'-01R';
               newOpp_renew.Name=accountMap.get(o_renew.AccountID).Name+ ' - Renewal ' + newOpp_renew.CloseDate.Year();
              // newopp.closeDate=o.closedate;
              
                newOpp_renew.Type='Renewal'; 
                newOpp_renew.Prior_Opportunity__c = o_renew.id;
                newOpp_renew.Parent_Opportunity_Quarterly_Deals__c = o_renew.id;
                //o_renew.Account.Acct_renewal_date__c=newOpp_renew.CloseDate;
                newOpp_renew.RecordtypeId=RenewalSalesId;
               // newOpp.stageName = 'Discovery';
                newOpp_renew.stageName = 'Not Contacted';
                  if(o_renew.Opportunity_ARR2012__c != null){
                  //newOpp_renew.Opportunity_ARR2012__c=o_renew.Opportunity_ARR2012__c;
                    newOpp_renew.Previous_Year_ACV__c = o_renew.Opportunity_ARR2012__c;
                    }
             //   newOpp.SyncedQuoteId=null;
                RenewalOpps_renew.add(newOpp_renew);
            }
        }
     
     }
     } 
   }
   }
   if(RenewalOpps.size()>0)
   {
    insert RenewalOpps;
    system.debug('@@@@'+RenewalOpps);
   }
   List<opportunityLineItem> newOplList = new List<opportunitylineItem>();
   List<opportunityContactRole> newoppConRoles = new List<OpportunityContactRole>();
      integer counter;
   for(Opportunity o:RenewalOpps)
   {
       if(o.Prior_Opportunity__c != null && OplMap.keyset().contains(o.Prior_Opportunity__c))
       {
           List<OpportunityLineItem> Opl = OplMap.get(o.Prior_Opportunity__c);
           counter =1;                             
           for(OpportunityLineItem ol:Opl)
           {
           if(ol.Product_Family__c != 'Services')
              {
                OpportunityLineItem newOpl= ol.clone(false,true);     
                newOpl.OpportunityId =  o.Id;  
                newOpl.ServiceDate = ol.ServiceEndDate__c;
                newOpl.OLI_ID__C=ol.ID;
                
                newOpl.Prior_OLI_Name__c=ol.pricebookentry.product2.name+' for '+o.name;
                if(o.Quarterly_Renewal__c == null && ol.ServiceEndDate__c != null)
                    newOpl.ServiceEndDate__c  =  ol.ServiceEndDate__c.addDays(365);
                else if(o.Quarterly_Renewal__c != null && ol.ServiceEndDate__c !=null)
                    newOpl.ServiceEndDate__c  =  ol.ServiceEndDate__c.addDays(counter*90);                           
                newOplList.add(newOpl);
                counter++;
              }
           }
       }
       if(o.Prior_Opportunity__c != null && OpConRole.keyset().contains(o.Prior_Opportunity__c))
       {
           List<OpportunityContactRole> Opl = OpConRole.get(o.Prior_Opportunity__c);
           for(OpportunityContactRole ol:Opl)
           {          
                OpportunityContactRole newOpConRole= ol.clone(false,true);
                newOpConRole.OpportunityId = o.Id;
                newoppConRoles.add(newOpConRole);               
           }
       }
   }
   insert newOplList;
      insert newoppConRoles;
      update newOplList;
  /* 
list<opportunity> ListOfOpportunity = new list<opportunity>();

for(opportunity opp : Trigger.new)
{
integer QuarterlyRenewal;
if(opp.Quarterly_Renewal__c ==NULL || opp.Quarterly_Renewal__c == '')
{
    QuarterlyRenewal=0;
}
else
{
    QuarterlyRenewal=integer.valueOf(opp.Quarterly_Renewal__c);
}

if(opp.StageName=='Closed Won' && opp.Type =='New Business' && QuarterlyRenewal >=1)
    {
        for(integer a=0;a<3;a++)
        {
          opportunity newOpp= opp.clone(false,true);
          newopp.Type='Renewal'; 
          newopp.Quarterly_Renewal__c=string.valueOf(a+2);
          //newopp.CloseDate = newopp.CloseDate + ((365/12)* (a+1)*3); 
          newopp.CloseDate = newopp.CloseDate.addMonths((a+1)*3);
          ListOfOpportunity.add(newopp);       
           
        }    
    }
else if(opp.StageName=='Closed Won' && opp.Type =='New Business' && QuarterlyRenewal ==0)
    {
      opportunity newOpp= opp.clone(false,true);
      newopp.Type='Renewal'; 
      ListOfOpportunity.add(newopp);
    }

}
system.debug('aaaa'+ListOfOpportunity.size());
insert ListOfOpportunity;*/

//}
}
}
if(!test.isRunningTest()){
if(RenewalOpps_renew.size()>0)
   {
    insert RenewalOpps_renew;
    system.debug('@@@@'+RenewalOpps_renew);
   }
   }
   if(!test.isRunningTest()){
   List<opportunityLineItem> newOplList_renew = new List<opportunitylineItem>();
   List<opportunityContactRole> newoppConRoles_renew = new List<OpportunityContactRole>();
      integer counter;
   for(Opportunity o_renew:RenewalOpps_renew)
   {
       if(o_renew.Prior_Opportunity__c != null && OplMap_renew.keyset().contains(o_renew.Prior_Opportunity__c))
       {
           List<OpportunityLineItem> Opl_renew = OplMap_renew.get(o_renew.Prior_Opportunity__c);
           counter =1;                             
           for(OpportunityLineItem ol_renew:Opl_renew)
           {
           if(ol_renew.Product_Family__c != 'Services')
              {
                OpportunityLineItem newOpl_renew= ol_renew.clone(false,true);     
                newOpl_renew.OpportunityId =  o_renew.Id;  
                newOpl_renew.ServiceDate = ol_renew.ServiceEndDate__c;
                newOpl_renew.OLI_ID__c = ol_renew.ID;
                
                newOpl_renew.Prior_OLI_Name__c=ol_renew.pricebookentry.product2.name+' for '+o_renew.name;
                if(o_renew.Quarterly_Renewal__c == null && ol_renew.ServiceEndDate__c != null)
                    newOpl_renew.ServiceEndDate__c  =  ol_renew.ServiceEndDate__c.addDays(365);
                else if(o_renew.Quarterly_Renewal__c != null && ol_renew.ServiceEndDate__c !=null)
                    newOpl_renew.ServiceEndDate__c  =  ol_renew.ServiceEndDate__c.addDays(counter*90);                           
                newOplList_renew.add(newOpl_renew);
                counter++;
              }
           }
       }
       if(o_renew.Prior_Opportunity__c != null && OpConRole_renew.keyset().contains(o_renew.Prior_Opportunity__c))
       {
           List<OpportunityContactRole> Opl_renew = OpConRole_renew.get(o_renew.Prior_Opportunity__c);
           for(OpportunityContactRole ol_renew:Opl_renew)
           {          
                OpportunityContactRole newOpConRole_renew= ol_renew.clone(false,true);
                newOpConRole_renew.OpportunityId = o_renew.Id;
                newoppConRoles_renew.add(newOpConRole_renew);               
           }
       }
   }
   insert newOplList_renew;
   insert newoppConRoles_renew;
   
   update newOplList_renew;
   }
  /* 
list<opportunity> ListOfOpportunity = new list<opportunity>();

for(opportunity opp : Trigger.new)
{
integer QuarterlyRenewal;
if(opp.Quarterly_Renewal__c ==NULL || opp.Quarterly_Renewal__c == '')
{
    QuarterlyRenewal=0;
}
else
{
    QuarterlyRenewal=integer.valueOf(opp.Quarterly_Renewal__c);
}

if(opp.StageName=='Closed Won' && opp.Type =='New Business' && QuarterlyRenewal >=1)
    {
        for(integer a=0;a<3;a++)
        {
          opportunity newOpp= opp.clone(false,true);
          newopp.Type='Renewal'; 
          newopp.Quarterly_Renewal__c=string.valueOf(a+2);
          //newopp.CloseDate = newopp.CloseDate + ((365/12)* (a+1)*3); 
          newopp.CloseDate = newopp.CloseDate.addMonths((a+1)*3);
          ListOfOpportunity.add(newopp);       
           
        }    
    }
else if(opp.StageName=='Closed Won' && opp.Type =='New Business' && QuarterlyRenewal ==0)
    {
      opportunity newOpp= opp.clone(false,true);
      newopp.Type='Renewal'; 
      ListOfOpportunity.add(newopp);
    }

}
system.debug('aaaa'+ListOfOpportunity.size());
insert ListOfOpportunity;*/

//}
}


}