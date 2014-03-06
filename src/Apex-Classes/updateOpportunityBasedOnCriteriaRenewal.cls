public class updateOpportunityBasedOnCriteriaRenewal {

    public static Boolean isFromTriggerCloneOppBasedonCriteriaRenewal = false;
    public static Map < Id, List < OpportunityContactRole >> OpConRoleRenewal;
    public static Map < Id, List < OpportunityLineItem >> oplMapRenewal;
    public static Map < Id, List < asset >> oppAssetsRenewal;
    public static Set < ID > ClosedWonOppSet = new Set < ID > ();
    public static void updateOpportunity_Renewal(map < Id, opportunity > triggerNewMap) {
        integer Q;
        List < User > Renewal = [select id
            FROM User
            Where Name = 'Renewals Team'
            limit 1
        ];
        ID RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal Sales').getRecordTypeId();
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        OpConRoleRenewal = new Map < Id, List < OpportunityContactRole >> ();
        map < ID, string > oppAccountname = new map < ID, string > ();
        oppAssetsRenewal = new map < ID, list < asset >> ();
        map < ID, list < asset >> oppAssetsRenewal_renew = new map < ID, list < asset >> ();
        list < asset > asset_lst = new list < asset > ();
        List < Opportunity > ClosedWonOppList = new List < Opportunity > ();
        List < Opportunity > RenewalOpps = new List < Opportunity > ();
        string dealtypes = Label.Deal_types;
        Set < ID > Acc_Set = new set < ID > ();
       
        Set < ID > PriorOppSet = new Set < ID > ();
        oplMapRenewal = new Map < Id, List < OpportunityLineItem >> ();
        for (opportunity o: triggerNewMap.values()) {
            if (o.deal_type__c != null)
                if (!dealtypes.containsIgnorecase(o.deal_type__c)) {
                    
                        ClosedWonOppList.add(o);
                        ClosedWonOppSet.add(o.id);
                        Acc_Set.add(o.AccountID);
                        PriorOppSet.add(o.Prior_Opportunity__c);
                    
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
            if (!OpConRoleRenewal.keyset().contains(oc.OpportunityId)) {
                OpConRoleRenewal.put(oc.OpportunityId, new List < OpportunityContactRole > {
                    oc
                });
            } else {
                OpConRoleRenewal.get(oc.opportunityId).add(oc);
            }
        }


        List < Asset > Asset_List = [SELECT ID, NAME, installdate, UsageEndDate,
            Opportunity__c, latest_opportunity__c FROM ASSET where latest_opportunity__c IN: ClosedWonOppSet LIMIT 100
        ];

        for (Asset a: Asset_List) {
            if (!oppAssetsRenewal.keyset().contains(a.Opportunity__c)) {
                oppAssetsRenewal.put(a.Opportunity__c, new List < asset > {
                    a
                });
            } else {
                oppAssetsRenewal.get(a.Opportunity__c).add(a);
            }
        }


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
            if (!oplMapRenewal.keyset().contains(opl.OpportunityId)) {
                oplMapRenewal.put(opl.OpportunityId, new List < OpportunityLineItem > {
                    opl
                });
            } else {
                oplMapRenewal.get(opl.opportunityId).add(opl);
            }
        }


        for (Opportunity o: ClosedWonOppList) {

            Q = -1;
            if (o.Quarterly_Renewal__c != null)
                Q = integer.valueof(o.Quarterly_Renewal__c);

            Date EndDate;



            if (o.Quarterly_Renewal__c == null) {
                date HighestDate;
                if (oplMapRenewal.keyset().contains(o.id)) {
                    list < opportunityLineItem > LOP = oplMapRenewal.get(o.id);

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
                    newOpp.Sub_Start_Date__c = o.Sub_Start_Date__c.addDays(365);
                    newOpp.Sub_End_Date__c = o.Sub_End_Date__c.addDays(365);
                } else {
                    newOpp.CloseDate = o.CloseDate.adddays(365);
                }
                system.debug('o.Account.Name' + o.id);
                System.debug('@@@@' + oppAccountname.get(o.id));
                //newOpp.Name = o.Name+'-01R';
                if (o.Sub_End_Date__c != null)

                    newOpp.Name = accountMap.get(o.AccountID).Name + ' - Renewal ' + o.Sub_End_Date__c.Year();
                else
                    newOpp.Name = accountMap.get(o.AccountID).Name + ' - Renewal ' + o.closeDate.adddays(365).Year();
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
        createOlis_Renewal(RenewalOpps);
        createOppContacts_Renewal(RenewalOpps);
        UpdateAssets_Renewal(RenewalOpps);
        //updateOlis_ClosedWon();

    }


    public static void createOlis_Renewal(List < Opportunity > Renewal_Opps) {

        System.debug('>>Keyset' + oplMapRenewal.keyset());
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
            WHERE OpportunityId in : oplMapRenewal.keyset()
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

        }



    }


    public static void UpdateAssets_Renewal(List < Opportunity > Renewal_Opps) {

        System.debug('>>Keyset' + oplMapRenewal.keyset());
        map < ID, ID > oppNewmap = new map < ID, ID > ();
        map < ID, Opportunity > oppNewOppMap = new map < ID, Opportunity > ();
        for (opportunity opp_new: Renewal_Opps) {

            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.ID);
            oppNewOppMap.put(opp_new.Prior_Opportunity__c, opp_new);
        }
        List < Asset > as_lst = new list < asset > ();

        for (asset ab: [SELECT ID, NAME, installdate, UsageEndDate, latest_opportunity__c, Opportunity__c
            FROM ASSET where
            Opportunity__c IN: oppAssetsRenewal.Keyset()
        ]) {
            if (ab.latest_Opportunity__c != null) {
                OPPORTUNITY OPP = oppNewOppMap.get(ab.latest_Opportunity__c);
                if (Opp.Prior_opportunity__c != null)
                    ab.opportunity__c = OPP.Prior_Opportunity__c;
                ab.latest_Opportunity__c = OPP.ID;
                if (oppNewOppMap.get(ab.Opportunity__c).Sub_End_Date__c != null)
                    ab.usageEndDate = oppNewOppMap.get(ab.Opportunity__c).Sub_End_Date__c;

                as_lst.add(ab);
            }
        }

        if (as_lst.size() > 0) {
            update as_lst;

        }



    }

    public static void createOppContacts_Renewal(List < Opportunity > Renewal_Opps) {

        System.debug('>>Keyset' + oplMapRenewal.keyset());
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
            WHERE OpportunityId in : OpConRoleRenewal.Keyset()
        ]) {
            OpportunityContactRole newOpConRoleRenewal = ol.clone(false, true);
            newOpConRoleRenewal.OpportunityId = oppNewmap.get(ol.OpportunityId);
            newoppConRoles.add(newOpConRoleRenewal);
        }

        if (newoppConRoles.size() > 0) {
            insert newoppConRoles;

        }



    }


    public static void updateOlis_ClosedWon() {

        List < OpportunityLineItem > newOplLis = new List < OpportunityLineItem > ();
        List < asset > alst = new list < asset > ();

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
            MRR__c,related_asset__c,Pricebookentry.Product2ID,
            ServiceEndDate__c, OpportunityLineItem.Opportunity.Quarterly_Renewal__c, OpportunityLineItem.Opportunity.Name, OpportunityLineItem.Pricebookentry.Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId in : ClosedWonOppSet]) {
            alst = oppAssetsRenewal.get(ol.OpportunityID);
            for (asset a: alst) {
                if (a.product2ID == ol.Pricebookentry.Product2ID) {

                    ol.related_asset__c = a.ID;
                }

            }

            newOplLis.add(ol);


        }
        if (newOplLis.size() > 0) {
            update newOplLis;

        }



    }


}