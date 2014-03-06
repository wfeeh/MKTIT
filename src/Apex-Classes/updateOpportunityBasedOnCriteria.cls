public class updateOpportunityBasedOnCriteria {

    public static Boolean isFromTriggerCloneOppBasedonCriteria = false;
    
    public static Map < Id, List < OpportunityContactRole >> OpConRole;
    public static Map < Id, List < OpportunityLineItem >> oplMap;
    public static Map < Id, List < asset >> oppAssets;
    public static void updateOpportunity_NewBusiness(map < Id, opportunity > triggerNewMap) {
        integer Q;
        List < User > Renewal = [select id
            FROM User
            Where Name = 'Renewals Team'
            limit 1
        ];
        ID RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales').getRecordTypeId();
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        OpConRole = new Map < Id, List < OpportunityContactRole >> ();
        map < ID, string > oppAccountname = new map < ID, string > ();
        oppAssets = new map < ID, list < asset >> ();
        map < ID, list < asset >> oppAssets_renew = new map < ID, list < asset >> ();
        list < asset > asset_lst = new list < asset > ();
        List < Opportunity > ClosedWonOppList = new List < Opportunity > ();
        List < Opportunity > RenewalOpps = new List < Opportunity > ();
        string dealtypes = Label.Deal_types;
        Set < ID > Acc_Set = new set < ID > ();
        List < string> ClosedWonOppSet = new List< string> ();
        oplMap = new Map < Id, List < OpportunityLineItem >> ();
        for (opportunity o: triggerNewMap.values()) {
            if (o.deal_type__c != null)
                if (!dealtypes.containsIgnorecase(o.deal_type__c)) {
                    
                        ClosedWonOppList.add(o);
                        ClosedWonOppSet.add(o.id);
                        Acc_Set.add(o.AccountID);
                    
                }
        }
        
        Map < Id, Account > accountMap = new Map < Id, Account > ([
            select Id, Name
            from Account
            where Id IN: Acc_Set
        ]);

        List < OpportunityContactRole > ConRole = [SELECT id,
            OpportunityId,
            IsPrimary,
            contactId
            FROM OpportunityContactRole
            WHERE OpportunityId in : ClosedWonOppSet limit 200
        ];
        for (OpportunityContactRole oc: ConRole) {
            if (!OpConRole.keyset().contains(oc.OpportunityId)) {
                OpConRole.put(oc.OpportunityId, new List < OpportunityContactRole > {
                    oc
                });
            } else {
                OpConRole.get(oc.opportunityId).add(oc);
            }
        }


        List < Asset > Asset_List = [SELECT ID, NAME, installdate, UsageEndDate, Opportunity__c FROM ASSET where Opportunity__c IN: ClosedWonOppSet LIMIT 100];

        for (Asset a: Asset_List) {
            if (!oppAssets.keyset().contains(a.Opportunity__c)) {
                oppAssets.put(a.Opportunity__c, new List < asset > {
                    a
                });
            } else {
                oppAssets.get(a.Opportunity__c).add(a);
            }
        }
             System.debug('oppAssets.Keyset'+oppAssets.Keyset());
             System.debug('oppAssets.Values'+oppAssets.Values());
        List < OpportunityLineItem > OplList = [SELECT id,
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
            ARR_Renewal__c,
            ARR_Spark__c,
            ARR_Spark_SI__c,
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
            MRR__c,
            ServiceEndDate__c, OpportunityLineItem.Opportunity.Quarterly_Renewal__c, OpportunityLineItem.Opportunity.Name, OpportunityLineItem.Pricebookentry.Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId in : ClosedWonOppSet limit 100
        ];
        system.debug('OplList' + OplList.size());

        for (OpportunityLineItem opl: OplList) {
            if (!OplMap.keyset().contains(opl.OpportunityId)) {
                OplMap.put(opl.OpportunityId, new List < OpportunityLineItem > {
                    opl
                });
            } else {
                OplMap.get(opl.opportunityId).add(opl);
            }
        }


        for (Opportunity o: ClosedWonOppList) {

            Q = -1;
            if (o.Quarterly_Renewal__c != null)
                Q = integer.valueof(o.Quarterly_Renewal__c);

            Date EndDate;

            if (Q >= 1) {
                integer aa = 1;
                for (integer a = 0; a < 3; a++) {
                    Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                    newopp.Quarterly_Renewal__c = string.valueOf(a + 2);
                    newOpp.Name = o.Name + '-0' + (a + 2) + 'R';
                    newOpp.CloseDate = o.CloseDate.addmonths(aa * 3);

                    newopp.ownerId = RenewalSalesId;
                    if (o.Sub_End_Date__c != null) {
                        //                    newOpp.CloseDate=o.Sub_End_Date__c.addmonths(aa*3);
                        newOpp.CloseDate = EndDate != null ? EndDate : o.Sub_End_Date__c;
                        //  newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                        newOpp.Plan_of_Record_Renewal_Date__c = newOpp.CloseDate;

                        /* Added one day to the beginning of the start date for the renewal */
                        newOpp.Sub_Start_Date__c = EndDate != null ? EndDate + 1 : o.Sub_End_Date__c + 1;
                        EndDate = EndDate == null ? o.Sub_End_Date__c.addMonths(3) : EndDate.addMonths(3);
                        newOpp.Sub_End_Date__c = EndDate;
                    } else {
                        newOpp.CloseDate = o.CloseDate.addmonths(aa * 3);
                    }
                    newOpp.Type = 'Renewal';
                    newOpp.Prior_Opportunity__c = o.id;
                    newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                    newOpp.RecordtypeId = RenewalSalesId;
                    //   newOpp.stageName = 'Discovery';
                    newOpp.stageName = 'Not Contacted';
                    if (o.Opportunity_ARR2012__c != null)
                        newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c / 4;
                    // newOpp.SyncedQuoteId=null;
                    RenewalOpps.add(newOpp);
                    aa++;
                }

            } else if (o.Quarterly_Renewal__c == null) {
                date HighestDate;
                if (OplMap.keyset().contains(o.id)) {
                    list < opportunityLineItem > LOP = OplMap.get(o.id);

                    for (opportunityLineItem ol: LOP) {

                        if (ol.ServiceEndDate__c != null) {
                            if (HighestDate == null) {
                                HighestDate = ol.ServiceEndDate__c;
                            } else if (HighestDate <= ol.ServiceEndDate__c) {
                                HighestDate = ol.ServiceEndDate__c;
                            }
                        }

                    }
                }
                if (HighestDate == null) {
                    HighestDate = o.closedate;
                }

                Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                newopp.closeDate = o.closedate.adddays(365);

                newopp.ownerId = Renewal[0].ID;
                if (o.Sub_End_Date__c != null) {
                    newOpp.CloseDate = o.Sub_End_Date__c;
                    //  newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    newOpp.Plan_of_Record_Renewal_Date__c = newOpp.CloseDate;
                    newOpp.Sub_Start_Date__c = o.Sub_End_Date__c + 1;
                    newOpp.Sub_End_Date__c = o.Sub_End_Date__c.addDays(365);
                } else {
                    newOpp.CloseDate = o.CloseDate.adddays(365);
                }
                system.debug('o.Account.Name' + o.id);
                System.debug('@@@@' + oppAccountname.get(o.id));
                //newOpp.Name = o.Name+'-01R';
              if(o.AccountID!=null){
                if (o.Sub_End_Date__c != null)

                    newOpp.Name = accountMap.get(o.AccountID).Name + ' - Renewal ' + o.Sub_End_Date__c.Year();
                else
                    newOpp.Name = accountMap.get(o.AccountID).Name + ' - Renewal ' + o.closeDate.adddays(365).Year();
                
                }
                else{
                if(test.isrunningtest())
                newOpp.Name='Test Class';
                }
                // newopp.closeDate=o.closedate;

                newOpp.Type = 'Renewal';
                newOpp.Prior_Opportunity__c = o.id;
                newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                newOpp.RecordtypeId = RenewalSalesId;
                // newOpp.stageName = 'Discovery';
                newOpp.stageName = 'Not Contacted';
                if (o.Opportunity_ARR2012__c != null) {
                    //newOpp.Opportunity_ARR2012__c=o.Opportunity_ARR2012__c ;
                    newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c;
                }
                //   newOpp.SyncedQuoteId=null;
                RenewalOpps.add(newOpp);
            }


        }

        if (RenewalOpps.size() > 0) {
            insert RenewalOpps;

        }
        //updateOpportunityBasedOnCriteria up=new updateOpportunityBasedOnCriteria ();
       
     
        createOlis(RenewalOpps);
        createOppContacts(RenewalOpps);
        UpdateAssets(RenewalOpps);

    }


    public static void createOlis(List < Opportunity > Renewal_Opps) {

        System.debug('>>Keyset' + OplMap.keyset());
        map < ID, ID > oppNewmap = new map < ID, ID > ();
        for (opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.ID);

        }
        List < OpportunityLineItem > newOplList = new List < OpportunityLineItem > ();

        integer counter = 1;
        for (OpportunityLineItem ol: [SELECT id,
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
            ARR_Renewal__c,
            ARR_Spark__c,
            ARR_Spark_SI__c,
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
            MRR__c,
            ServiceEndDate__c, OpportunityLineItem.Opportunity.Quarterly_Renewal__c, OpportunityLineItem.Opportunity.Name, OpportunityLineItem.Pricebookentry.Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId in : OplMap.keyset()
        ]) {
            if (ol.Product_Family__c != 'Services') {
                OpportunityLineItem newOpl = ol.clone(false, true);
                newOpl.OpportunityId = oppNewmap.get(ol.OpportunityId);
                newOpl.ServiceDate = ol.ServiceEndDate__c;
                newOpl.OLI_ID__C = ol.ID;

                newOpl.Prior_OLI_Name__c = ol.pricebookentry.product2.name + ' for ' + ol.Opportunity.name;
                if (ol.Opportunity.Quarterly_Renewal__c == null && ol.ServiceEndDate__c != null)
                    newOpl.ServiceEndDate__c = ol.ServiceEndDate__c.addDays(365);
                else if (ol.Opportunity.Quarterly_Renewal__c != null && ol.ServiceEndDate__c != null)
                    newOpl.ServiceEndDate__c = ol.ServiceEndDate__c.addDays(counter * 90);
                newOplList.add(newOpl);
                counter++;
            }
        }
        if (newOplList.size() > 0) {
            insert newOplList;
            //update newOplList; 
        }



    }





  public static void UpdateAssets2(List < Opportunity > Renewal_Opps) {

      //  System.debug('>>Keyset' + OplMap.keyset());
        map < ID, Opportunity > oppNewmap = new map < ID, Opportunity > ();
        for (opportunity opp_new: Renewal_Opps) {
        if(opp_new.Prior_Opportunity__c!=null){
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new);

               }
        }
        List < Asset> newAstList = new List < Asset> ();

        //integer counter = 1;
        if(!oppNewmap.keyset().IsEmpty()){
        for (Asset a: [SELECT ID, NAME, installdate, UsageEndDate, latest_opportunity__c ,
        Opportunity__c FROM ASSET WHERE Opportunity__c in : OplMap.keyset()
        ]) {
            a.latest_opportunity__c =  oppNewmap.get(a.Opportunity__c).ID;
            a.usageEndDate = oppNewmap.get(a.Opportunity__c).Sub_End_Date__c;
           // if (oppNewOppMap.get(ab.Opportunity__c).Sub_Start_Date__c != null)
           // ab.InstallDate = oppNewOppMap.get(ab.Opportunity__c).Sub_Start_Date__c;
            newAstList.add(a);
            }
            
            }
        
        if (newAstList.size() > 0) {
            Update newAstList ;
            //update newOplList; 
        }



    }






    public static void UpdateAssets(List < Opportunity > Renewal_Opps) {
        System.debug('Renewal_Opps.size'+Renewal_Opps.Size());
        System.debug('>>Keyset' + OplMap.keyset());
        map < ID, ID > oppNewmap = new map < ID, ID > ();
        map < ID, Opportunity> oppNewOppMap= new map < ID, Opportunity> ();
        for (opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.ID);
            oppNewOppMap.put(opp_new.Prior_Opportunity__c,opp_new);
        }
        
        System.debug('oppNewmap'+oppNewmap.Values());
           System.debug('oppNewmap'+oppNewmap.Keyset());
        List < Asset > as_lst = new list < asset > ();
        System.debug('oppAssets.Keyset'+oppAssets.Keyset());
        for (asset ab: [SELECT ID, NAME, installdate, UsageEndDate, latest_opportunity__c ,
        Opportunity__c FROM ASSET where
            Opportunity__c IN:oppAssets.Keyset()]) {
            ab.latest_opportunity__c =  oppNewmap.get(ab.Opportunity__c);
            if (oppNewOppMap.get(ab.Opportunity__c).Sub_End_Date__c != null)
            ab.usageEndDate = oppNewOppMap.get(ab.Opportunity__c).Sub_End_Date__c;
           // if (oppNewOppMap.get(ab.Opportunity__c).Sub_Start_Date__c != null)
           // ab.InstallDate = oppNewOppMap.get(ab.Opportunity__c).Sub_Start_Date__c;
            as_lst.add(ab);
        }

        if (as_lst.size() > 0) {
            update as_lst;

        }



    }

    public static void createOppContacts(List < Opportunity > Renewal_Opps) {

        System.debug('>>Keyset' + OplMap.keyset());
        map < ID, ID > oppNewmap = new map < ID, ID > ();
        for (opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.ID);

        }
        List < opportunityContactRole > newoppConRoles = new List < OpportunityContactRole > ();

        for (OpportunityContactRole ol: [SELECT id,
            OpportunityId,
            IsPrimary,
            contactId
            FROM OpportunityContactRole
            WHERE OpportunityId in : OpConRole.Keyset()
        ]) {
            OpportunityContactRole newOpConRole = ol.clone(false, true);
            newOpConRole.OpportunityId = oppNewmap.get(ol.OpportunityId);
            newoppConRoles.add(newOpConRole);
        }

        if (newoppConRoles.size() > 0) {
            insert newoppConRoles;

        }



    }


}