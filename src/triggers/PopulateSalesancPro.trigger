trigger PopulateSalesancPro on Opportunity (before update,before insert) 
{
   List<string> OppIds=new List<string>();
   RecordType Rc=[select id from RecordType where SobjectType='Opportunity' and Name='Closed Won' limit 1];
    for(Opportunity o:trigger.new)
    {   
        if(o.RecordTypeId==Rc.id)
        OppIds.add(o.id);
    }
    List<OpportunityLineitem> Opl=[select PricebookEntry.ProductCode,Product_Family__c,PricebookEntry.Product2.Family,PricebookEntry.Name,id,UnitPrice,Quantity,OpportunityId,Discount,TotalPrice,Geography__c,Rev_Rec_Template__c,MLM_Edition__c from OpportunityLineitem where Opportunityid in:OppIds order by createddate];
     Map<Id,list<String>> LineDetail=new Map<Id,list<string>>();
     Map<Id,list<String>> ServiceDetail=new Map<Id,list<string>>();
     string Ldetail='';string SDetail='';
    for(OpportunityLineitem op:Opl)
    {
        //if(op.PricebookEntry.Product2.Family == 'Services')Product_Family__c
        if(op.Product_Family__c == 'Services')
        {
            SDetail = op.PricebookEntry.ProductCode;
              if(!ServiceDetail.keyset().contains(op.OpportunityId))
            {
                ServiceDetail.put(op.OpportunityId,new List<string>{SDetail});
            }
            else
            {
               ServiceDetail.get(op.OpportunityId).add('|'+SDetail);
            }
        }
        //else{
            // Ldetail=op.PricebookEntry.Name+'|'+op.Quantity+'|'+op.UnitPrice+'|'+op.Discount+'|'+op.TotalPrice+'|'+op.Geography__c+'|'+op.Rev_Rec_Template__c+'|'+op.MLM_Edition__c;
             Ldetail=' | ' + op.PricebookEntry.Name+' | '+op.Product_Family__c+ ' | ';
            if(!LineDetail.keyset().contains(op.OpportunityId))
            {
                LineDetail.put(op.OpportunityId,new List<string>{Ldetail});
            }
            else
            {
               LineDetail.get(op.OpportunityId).add('\n'+Ldetail);
            }
        //}
    }
    //Querying Opp line item for services products only
    //List<OpportunityLineitem> OplServices=[select PricebookEntry.Product2.Family,PricebookEntry.Name,PricebookEntry.ProductCode,id,UnitPrice,Quantity,OpportunityId,Discount,TotalPrice,Geography__c,Rev_Rec_Template__c,MLM_Edition__c from OpportunityLineitem where Opportunityid in:OppIds and PricebookEntry.Product2.Family='Services' order by createddate];
   /*List<Sales_Order__c> So=[select id,Name,Opportunity__c from Sales_Order__c where Opportunity__c=:OppIds order by createddate limit 1];
   Map<Id,string> Soids=new Map<Id,string>();
   for(Sales_Order__c s:So)
    {
        Soids.put(s.Opportunity__c,s.Name);       
    }*/
    string line='';String Sline='|';
    for(Opportunity o:trigger.new)
    {
       if(LineDetail.keyset().contains(o.id))
       {
            for(string s:LineDetail.get(o.id))
            {
                line+=s;
            }
            o.Product_Info__c=line;
       }
        if(ServiceDetail.keyset().contains(o.id))
       {
            for(string s:ServiceDetail.get(o.id))
            {
                Sline+=s;
            }
            o.Product_SVS__c=Sline + '|';
       }
      //if(Soids.keyset().contains(o.id))
     // {
         //o.Sales_Order__c=Soids.get(o.id);
      //}
    }
    // o.Product_Info__c
}