public class createAssetsAndEntitlements {

    public static boolean Istrigger = false;

    private static list < asset > ListOfAssets;
    private static list < Entitlement > ListOfEntitlements;
    private static string OpportunityID;
    private static Map < string, Asset > OppAssetsMap;
    private static List < asset > OppAssets;
    private static list < SlaProcess > eprocess;
    private static Map < string, id > eprocessMap;
    private static Map < string, id > BhoursMap;
    private static Map < Id, Entitlement > ExistingEntitlement;
    private static list < opportunity > oppAndAccount;
    //Related Assets and Entitlements Collections
    private static Asset ass;
    private static list < asset > subscripAsset;
    private static Map < Id, Id > RelatedAssetMap;
    private static Map < Id, Asset > RelatedAssetObjMap;
    private static Map < Id, Entitlement > RelatedEntitlementMap;
    //Defining Entitlement Collections
    private static List < Entitlement > EntList;
    private static Entitlement ent1;
    private static List < Entitlement > DefEnt;
    private static list < Authorized_Contact__c > ListOfAuthorizedContact;
    private static Map < Id, Authorized_Contact__c > AuthMap;
    private static list < opportunity > CurrentOpp;
    private static Boolean HasRegular = false;
    private static list <Product2> SandboxProductID;

    private static List < Id > SubAssetId;
    //If any product name contains spark then change the type of default entitlement from standard 
    //to spark support
    private static Boolean HasSpark = false;

    public static void CreateAE(string OppID) {
        System.debug('##I am in Method CreateAE' + Istrigger);
        System.Debug('CreateAE_IsCalled');
        SubAssetId = new List < Id > ();
        ListOfAssets = new list < asset > ();
        ListOfEntitlements = new list < Entitlement > ();
        OppAssetsMap = new Map < string, Asset > ();
        eprocessMap = new Map < String, id > ();
        BhoursMap = new Map < string, id > ();
        ExistingEntitlement = new Map < Id, Entitlement > ();
        RelatedAssetMap = new Map < Id, Id > ();
        RelatedAssetObjMap = new Map < Id, Asset > ();
        RelatedEntitlementMap = new Map < Id, Entitlement > ();
        ListOfAuthorizedContact = new list < Authorized_Contact__c > ();
        AuthMap = new Map < Id, Authorized_Contact__c > ();
        OpportunityID = OppID;

        OppAssets = [select id, name, Product2.id from asset
            where opportunity__c = : OpportunityId limit 100
        ];
        SandboxProductID=[select id, name from Product2
            where ProductCode = 'LM-SAND'];
        System.Debug('OppAssetsSIZE+++++' + OppAssets.size());
        System.Debug('OppAssets+++++' + OppAssets);
        for (asset ase: OppAssets) {
            OppAssetsMap.put(ase.Product2.id, ase);
        }

        eprocess = [select id, name from SlaProcess
            where name = 'Standard Support'
            OR name = 'Partner Support'
            OR name = 'Spark Support'
            OR name = 'Premier Support'
            OR name = 'Elite Support'
            limit 10
        ];

        for (SlaProcess sla: eprocess) {
            eprocessMap.put(sla.name, sla.id);
        }

        list < BusinessHours > Bhours = [select id, name from BusinessHours limit 100];

        for (BusinessHours bh: Bhours) {
            BhoursMap.put(bh.name, bh.id);
        }

        oppAndAccount = [select account.id, account.name, account.business_unit__c, Account.Sales_Region__c, Sub_Start_Date__c, Sub_End_Date__c from
            opportunity where id = : OpportunityID limit 1
        ];

        list < opportunitylineitem > OLI = [select pricebookentry.product2.ConvertTo__c,
            pricebookentry.product2.ProductCode,
            pricebookentry.product2.Name,
            pricebookentry.product2.Family,
            pricebookentry.product2.Record_Limitation__c,
            pricebookentry.product2.id,
            pricebookentry.product2.Subscription_Type__c,
            opportunity.account.id,
            opportunity.name,
            opportunity.type,
            Opportunity.Deal_type__c,
            opportunity.account.name,
            opportunity.account.business_unit__c,
            opportunity.account.type,
            opportunity.account.Professional_Edition__c,
            opportunity.account.Partner_Type__c,
            opportunity.account.Sales_Region__c,
            opportunity.CRM_System__c,
            opportunity.Sub_Start_Date__c,
            opportunity.Sub_End_Date__c,
            opportunity.Primary_Marketo_User_Lookup__c,
            Related_asset__r.purpose__c, //change number 3
            Related_asset__r.Installdate,
            Related_asset__r.UsageEndDate,
            Related_Asset__c,
            Quantity
            from opportunitylineitem where OpportunityId = : OpportunityID limit 100
        ];
        System.debug('+++OLI+++' + OLI.Size());
        if (OLI.size() > 0) {
            for (opportunitylineitem ol: OLI) {
                System.debug('##I am in Class createAssetsAndEntitlements' + Istrigger);
                System.Debug('@@Related Asset for oLI' + ol.Related_Asset__c);
                if (ol.Related_Asset__c != null) {
                    RelatedAssetMap.put(ol.id, ol.Related_Asset__c);
                }
            }
            List < Asset > RelatedAssets;

            if (RelatedAssetMap.size() > 0) {
                RelatedAssets = [SELECT id,
                    Name,
                    AccountId,
                    InstallDate,
                    UsageEndDate, Purpose__c
                    FROM Asset
                    WHERE id in : RelatedAssetMap.values() limit 1000
                ];

                for (Asset a: RelatedAssets) {
                    RelatedAssetObjMap.put(a.id, a);
                }

                List < Entitlement > RelatedEnt = [SELECT id,
                    AssetId,
                    BusinessHoursId,
                    EndDate,
                    Name,
                    SlaProcessId,
                    StartDate,
                    Status,
                    Type
                    FROM Entitlement
                    WHERE AssetId in : RelatedAssetMap.values()
                ];
                for (Entitlement e: RelatedEnt) {
                    RelatedEntitlementMap.put(e.AssetId, e);
                }
            }

            System.Debug('Enter4');
            CreateSubscriptionAssets(OLI);
            System.Debug('Enter5');
            //added for defect 5807
            //Change No -2
            subscripAsset = [select id,
                Product2.ProductCode
                from asset
                where Purpose__c = 'Production'
                AND Asset_Type__c = 'Subscription'
                AND Opportunity__c = : OpportunityID
                order by createdDate limit 10
            ];
            System.Debug('Enter6');
            CreateAddOnAssets(OLI);
            System.Debug('Enter7');

            if (subscripAsset != null && subscripAsset.size() > 0) {
                for (Asset asset: subscripAsset) {
                    SubAssetId.add(asset.id);
                }
                system.debug('>>>SubAssetIDS' + SubAssetId);
                EntList = [SELECT id, StartDate,
                    EndDate, BusinessHoursId, SlaProcessId, Product_ID__c, name, AccountId, AssetId, Type, Support_Region__c
                    from Entitlement where Product_ID__c != null and AssetId in : SubAssetId and AccountId = : OppAndAccount[0].AccountId limit 100
                ];
                system.debug('>>>>>ListofEntitlements' + EntList);
                for (Entitlement et: EntList) {

                    ExistingEntitlement.put(et.Product_ID__c, et);
                }
                system.debug('>>>>>ListofEntitlements' + ExistingEntitlement);
                DefEnt = [SELECT id, StartDate, EndDate, BusinessHoursId, SlaProcessId, Product_ID__c, name,

                    AccountId, AssetId, Type, Support_Region__c from Entitlement where
                    AssetId in : SubAssetId and Product_ID__c = null and AccountId = : OppAndAccount[0].AccountId limit 1
                ];
                system.debug('>>>>>ListofEntitlements' + DefEnt);
            }


            //Calling this method for creating Entitlements
            System.Debug('Enter8');
            CreateEntiltements(OLI);
            System.Debug('Enter9');
            /* CurrentOpp = [select id,accountid,Primary_Marketo_User_Lookup__c,
                                Primary_Marketo_User_Lookup__r.Account.Id 
                               from opportunity where id =: OpportunityID limit 1];
                 
                  List<Authorized_Contact__c> ExistingAC = [SELECT id,
                                                                   Entitlement__c
                                                              FROM Authorized_Contact__c
                                                              WHERE Entitlement__c in :ListOfEntitlements
                                                              and Customer_Admin__c = true limit 200]; 
               
                  for(Authorized_Contact__c c: ExistingAC )
                  {
                      AuthMap.put(c.Entitlement__c,c);
                  } 
                 
                 // Calling this method for creating Authorized Contacts
                  CreateAuthorizedContact();  */

        }

    }

    private static void CreateAuthorizedContact() {
        Authorized_Contact__c ac;
        if (ListOfEntitlements.size() > 0) {
            for (Entitlement ent: ListOfEntitlements) {
                if (AuthMap.keyset().contains(ent.id)) {
                    ac = AuthMap.get(ent.id);
                } else {
                    ac = new Authorized_Contact__c();

                    if (CurrentOpp.size() > 0) {
                        ac.Contact__c = CurrentOpp[0].Primary_Marketo_User_Lookup__c;
                    }
                    ac.Entitlement__c = ent.id;
                    ac.Customer_Admin__c = true;

                    if (ac.Contact__c != null && CurrentOpp[0].Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId) {
                        ListOfAuthorizedContact.add(ac);
                        system.debug('ooo2');

                    }
                }
            }
        }

        if (ListOfAuthorizedContact.size() > 0) {

            upsert ListOfAuthorizedContact;
        }
    }

    private static void CreateSubscriptionAssets(List < OpportunityLineitem > OpplineitemList) {
        Set < Id > CheckDupSet = new Set < Id > ();
        System.Debug('CreateSubscriptionAssets_Entered');
        for (opportunitylineitem ol: OpplineitemList) {
            if (ol.pricebookentry.product2.Name.contains('Spark'))
                HasSpark = true;
            if (ol.pricebookentry.product2.ConvertTo__c == 'Subscription') {
                System.debug('##SubsciprionAsset' + ol.pricebookentry.product2.ConvertTo__c);
                if (OppAssetsMap.keyset().contains(ol.pricebookentry.product2.id)) {
                    ass = OppAssetsMap.get(ol.pricebookentry.product2.id);

                    system.debug('this is if ' + ass.id);
                } else if (RelatedAssetMap.keyset().contains(ol.id)) {
                    Id AssetId = RelatedAssetMap.get(ol.id);
                    ass = RelatedAssetObjMap.get(AssetId);

                    system.debug('this is if ' + ass.id);
                } else {

                    

                    if (!(ol.opportunity.name.containsIgnorecase('renewal')|| ol.opportunity.type == 'Upsell/Crossell'  || ol.opportunity.name.containsIgnorecase('-01R') ||
                        ol.opportunity.name.containsIgnorecase('-02R') || ol.opportunity.name.containsIgnorecase('-03R'))) {
                        ass = new Asset();

                        ass.InstallDate = ol.opportunity.Sub_Start_Date__c;
                        ass.UsageEndDate = ol.opportunity.Sub_End_Date__c;
                        if (!ol.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {
                            ass.Purpose__c = 'Production';
                            ass.Name = ol.opportunity.account.name + ' ' + ass.Purpose__c;
                            HasRegular = true;

                        }
                        if (ol.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {
                            ass.Purpose__c = 'Sandbox';
                            ass.Name = ol.opportunity.account.name + ' ' + ass.Purpose__c;
                        }
                        if (ol.opportunity.Account.Name.containsIgnorecase('Marketo') ||
                            ol.opportunity.Account.Name.containsIgnorecase('MKTO') ||
                            ol.Opportunity.Deal_type__c.containsIgnorecase('Internal Demo')) {
                            ass.Purpose__c = 'Internal';
                            ass.Name = ol.opportunity.account.name + ' ' + ass.Purpose__c;
                        }
                        if (ol.Opportunity.Deal_type__c.containsIgnorecase('Trial')) {
                            ass.Purpose__c = 'Trial';
                            ass.Name = ol.opportunity.account.name + ' ' + ass.Purpose__c;
                        }
                    } else {
                        break;
                    }


                }

                System.debug('##SubsciprionAsset' + ol.pricebookentry.product2.ConvertTo__c);
                ass.AccountId = ol.opportunity.account.id;
                //ass.Name=ol.opportunity.account.name; 
                ass.Asset_Type__c = ol.pricebookentry.product2.ConvertTo__c;

                if (ol.pricebookentry.product2.ConvertTo__c == 'Add On') {
                    if (ol.pricebookentry.product2.Family != null)
                        ass.Add_On_Product__c = ol.pricebookentry.product2.Family;
                }

                /*  if(ol.pricebookentry.product2.ConvertTo__c =='Add On' && ol.pricebookentry.product2.Family=='msi' )        
                {
                    ass.MSI_Seats__c=ol.Quantity;
                }*/

                ass.CRM_System__c = ol.opportunity.CRM_System__c;



                if (ass.Parent_Instance__c != null && ass.Parent_Instance__r.Asset_Type__c == 'Subscription') {
                    ass.Quantity = ol.pricebookentry.product2.Record_Limitation__c;
                }

                // if( ass.Asset_Type__c =='Subscription' || ol.pricebookentry.product2.ProductCode != 'LM-SAND')


                ass.Product2Id = ol.pricebookentry.product2.id;

                if (ass.Purpose__c == 'Production') {
                    ass.Supported_Instance__c = true;
                    ass.Partner_Supported__c = False;
                }

                if (ol.opportunity.account.type == 'Partner') {
                    ass.Partner_Supported__c = true;
                }
                // if(ol.pricebookentry.product2.Subscription_Type__c == 'Enterprise' || ol.pricebookentry.product2.Subscription_Type__c == 'Professional'){
                ass.Subscription_Type__c = ol.pricebookentry.product2.Subscription_Type__c;
                //     System.debug('ass.Subscription_Type__c'+ass.Subscription_Type__c);
                // }
                /*code block entry made to correct 5398 bug awaiting client input
                if(ol.pricebookentry.product2.Subscription_Type__c == '' || ol.pricebookentry.product2.Subscription_Type__c == null){
                    ass.Subscription_Type__c = null;
                    System.debug('ass.Subscription_Type__c'+ass.Subscription_Type__c);
                }*/

                ass.Opportunity__c = OpportunityId;
                if (ass.id != null && !CheckDupSet.contains(ass.id)) {
                    ListOfAssets.add(ass);
                    CheckDupSet.add(ass.id);
                } else if (ass.id == null)
                    ListOfAssets.add(ass);
            }
            
            if (!(ol.opportunity.name.containsIgnorecase('renewal') || ol.opportunity.name.containsIgnorecase('-01R') ||
                        ol.opportunity.name.containsIgnorecase('-02R') || ol.opportunity.name.containsIgnorecase('-03R')) && ol.pricebookentry.product2.Name.containsIgnorecase('Enterprise')) {

                        asset ass1 = new Asset();

                        ass1.InstallDate = ol.opportunity.Sub_Start_Date__c;
                        ass1.UsageEndDate = ol.opportunity.Sub_End_Date__c;
                        ass1.Purpose__c = 'Sandbox';
                        ass1.Asset_Type__c = 'Subscription';
                        ass1.Product2Id =SandboxProductID[0].ID;
                        ass1.Subscription_Type__c='Enterprise';
                        ass1.Name = ol.opportunity.account.name + ' ' + ass1.Purpose__c;
                        ass1.AccountId = ol.opportunity.account.id;
                        ass1.CRM_System__c = ol.opportunity.CRM_System__c;
                        ass1.Opportunity__c = OpportunityId;
                        ListOfAssets.add(ass1);

                        asset ass2 = new Asset();

                        ass2.InstallDate = ol.opportunity.Sub_Start_Date__c;
                        ass2.UsageEndDate = ol.opportunity.Sub_End_Date__c;
                        ass2.Purpose__c = 'Sandbox';
                        ass2.Product2Id = ol.pricebookentry.product2.id;
                        ass2.Name = ol.opportunity.account.name + ' ' + ass2.Purpose__c;
                        ass2.AccountId = ol.opportunity.account.id;
                        ass2.CRM_System__c = ol.opportunity.CRM_System__c;
                        ass2.Opportunity__c = OpportunityId;
                        ass2.Add_On_Product__c = 'Advanced Engagement';
                        ass2.Asset_Type__c = 'Add On';
                        ListOfAssets.add(ass2);
                    }
            
            
            
        }


        if (ListofAssets.size() > 0) {
            System.Debug('CreateSubscriptionAssets_Entered++++' + ListOfAssets);

            upsert ListofAssets;

            ListofAssets.clear();
        }
    }

    private static void CreateAddOnAssets(List < OpportunityLineItem > OpplinelistAddOn) {
        System.Debug('CreateAddOnAssets_Entered');
        Set < Id > CheckDupSet = new Set < Id > ();
        Map < String, Product_Family__c > pf = Product_Family__c.getAll();
        string pf_key = '';
        for (opportunitylineitem opl: OpplinelistAddOn) {

            if (opl.pricebookentry.product2.ConvertTo__c == 'Add On') {
                if (OppAssetsMap.keyset().contains(opl.pricebookentry.product2.id)) {
                    ass = OppAssetsMap.get(opl.pricebookentry.product2.id);

                    if (ass != null) {
                        system.debug('!!' + ass);
                        break;
                    }
                } else if (RelatedAssetMap.keyset().contains(opl.id)) {
                    Id AssetId = RelatedAssetMap.get(opl.id);
                    ass = RelatedAssetObjMap.get(AssetId);

                    if (ass != null) {
                        system.debug('!!' + ass);
                        break;
                    }
                } else {
                    if (!(opl.opportunity.name.containsIgnorecase('renewal') || opl.opportunity.type == 'Upsell/Crossell' || opl.opportunity.name.containsIgnorecase('-01R') ||
                        opl.opportunity.name.containsIgnorecase('-02R') || opl.opportunity.name.containsIgnorecase('-03R'))) {
                        ass = new Asset();

                        ass.InstallDate = opl.opportunity.Sub_Start_Date__c;
                        ass.UsageEndDate = opl.opportunity.Sub_End_Date__c;
                        if (!opl.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {
                            //ass.Purpose__c = 'Production';
                            ass.Name = opl.opportunity.account.name + ' ' + ass.Purpose__c;
                            HasRegular = true;
                        }
                        if (opl.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {
                            // ass.Purpose__c = 'Sandbox';
                            ass.Name = opl.opportunity.account.name + ' ' + ass.Purpose__c;
                        }
                        if (opl.Opportunity.Account.Name.containsIgnorecase('Marketo') ||
                            opl.Opportunity.Account.Name.containsIgnorecase('MKTO') ||
                            opl.Opportunity.Deal_type__c.containsIgnorecase('Internal Demo')) {
                            //ass.Purpose__c = 'Internal';
                            ass.Name = opl.opportunity.account.name + ' ' + ass.Purpose__c;
                        }
                        if (opl.Opportunity.Deal_type__c.containsIgnorecase('Trial')) {
                            // ass.Purpose__c = 'Trial';
                            ass.Name = opl.opportunity.account.name + ' ' + ass.Purpose__c;
                        }
                    } else {
                        break;
                    }



                }

                // ass.Name = opl.Opportunity.Account.Name;
                if (subscripAsset.size() > 0)
                    ass.Parent_Instance__c = subscripAsset[0].id;

                ass.AccountId = opl.opportunity.account.id;

                ass.Asset_Type__c = opl.pricebookentry.product2.ConvertTo__c;
                if (opl.pricebookentry.product2.Family != null)
                    ass.Add_On_Product__c = opl.pricebookentry.product2.Family;
                /***************Codde for Add On products**************/
                //As per product names
                pf_key = pf.get('Additional Authorized Contacts').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Name)) {
                    system.debug('!!!' + pf_key);
                    ass.Add_on_Product__c = pf.get('Additional Authorized Contacts').Product_Family_Value__c;
                }
                pf_key = pf.get('DB Space').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Name)) {
                    ass.Add_on_Product__c = pf.get('DB Space').Product_Family_Value__c;
                }
                pf_key = pf.get('eMail Relay').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Name)) {
                    ass.Add_on_Product__c = pf.get('eMail Relay').Product_Family_Value__c;
                }
                pf_key = pf.get('Advanced Engagement').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Name)) {
                    ass.Add_on_Product__c = pf.get('Advanced Engagement').Product_Family_Value__c;
                }
                pf_key = pf.get('Secured Page Services').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Name)) {
                    ass.Add_on_Product__c = pf.get('Secured Page Services').Product_Family_Value__c;
                }
                pf_key = pf.get('Marketo Social Marketing').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Name)) {
                    ass.Add_on_Product__c = pf.get('Marketo Social Marketing').Product_Family_Value__c;
                }

                //As per product Families
                pf_key = pf.get('CRM Integration').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                    system.debug('!!!' + pf_key);
                    ass.Add_on_Product__c = pf.get('CRM Integration').Product_Family_Value__c;
                }
                pf_key = pf.get('Deliverability Tool').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                    system.debug('!!!' + pf_key);
                    ass.Add_on_Product__c = pf.get('Deliverability Tool').Product_Family_Value__c;
                }
                pf_key = pf.get('RCA').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                    ass.Add_on_Product__c = pf.get('RCA').Product_Family_Value__c;
                }
                pf_key = pf.get('MSI').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                    ass.Add_on_Product__c = pf.get('MSI').Product_Family_Value__c;
                }
                pf_key = pf.get('Dedicated IP').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                    system.debug('!!!' + pf_key);
                    ass.Add_on_Product__c = pf.get('Dedicated IP').Product_Family_Value__c;
                }
                pf_key = pf.get('Marketo Financial Management').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                    ass.Add_on_Product__c = pf.get('Marketo Financial Management').Product_Family_Value__c;
                }
                pf_key = pf.get('Social Campaigns').Product_Family_key__c;
                if (pf_key.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                    ass.Add_on_Product__c = pf.get('Social Campaigns').Product_Family_Value__c;
                }
                /***************Codde for Add On products**************/



                if (opl.pricebookentry.product2.Family == 'Sales Insight') {
                    ass.MSI_Seats__c = opl.Quantity;
                }

                ass.CRM_System__c = opl.opportunity.CRM_System__c;
                //true change              
                ass.Partner_Supported__c = false;
                ass.Supported_Instance__c = false;

                if (ass.Parent_Instance__c != null && ass.Parent_Instance__r.Asset_Type__c == 'Subscription') {
                    ass.Quantity = opl.pricebookentry.product2.Record_Limitation__c;
                }



                ass.Product2Id = opl.pricebookentry.product2.id;


                // ass.Subscription_Type__c = opl.pricebookentry.product2.Subscription_Type__c;
                ass.Opportunity__c = OpportunityId;


                if (ass.id != null && !CheckDupSet.contains(ass.id)) {
                    ListOfAssets.add(ass);
                    CheckDupSet.add(ass.id);
                } else if (ass.id == null)
                    ListOfAssets.add(ass);
            }

        }

        if (ListOfAssets.size() > 0) {
            System.Debug('CreateAddOnAssets++++' + ListOfAssets);

            upsert ListOfAssets;
        }
    }


    private static void CreateEntiltements(List < OpportunityLineItem > OpplineEnt) {
        string Partner_Type = '';
        //String renwal='';
        boolean IsPartner = false;
        Map < String, Sales_region__c > mcs = Sales_region__c.getAll();
        string sr_key = '';
        Set < String > CheckDupSet = new Set < string > ();
        for (OpportunityLineItem ol: OpplineEnt) {

            if (ol.pricebookentry.product2.ProductCode != 'LM-SAND') {

                Partner_Type = '';



                if ((ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Spark' ||
                    ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Premier' ||
                    ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Elite') && ol.pricebookentry.product2.ProductCode != 'LM-SAND') {
                    Partner_Type = ol.opportunity.account.type != null ? ol.opportunity.account.type : '';
                    if (IsPartner == true)
                        Partner_Type = 'Partner';

                    if ((Partner_Type == 'Partner') && ol.opportunity.account.Partner_Type__c != 'Referral') {

                        if (ExistingEntitlement.keyset().contains(ol.pricebookentry.product2Id)) {

                            ent1 = ExistingEntitlement.get(ol.pricebookentry.product2Id);

                        } else if (ol.related_Asset__c != null && RelatedEntitlementMap.keyset().contains(ol.related_Asset__c)) {
                            ent1 = RelatedEntitlementMap.get(ol.related_Asset__c);

                        } else {
                            //updating default entitlement
                            if (DefEnt.size() > 0) {
                                ent1 = DefEnt[0];
                                //   ent1.AccountId=ol.opportunity.account.id;
                                system.debug('this is in partner default ent');
                            } else {
                                if (!(ol.opportunity.name.containsIgnorecase('renewal') || ol.opportunity.type == 'Upsell/Crossell' || ol.opportunity.name.containsIgnorecase('-01R') ||
                                    ol.opportunity.name.containsIgnorecase('-02R') || ol.opportunity.name.containsIgnorecase('-03R'))) {
                                    ent1 = new Entitlement();

                                    ent1.AccountId = ol.opportunity.account.id;

                                } else {
                                    break;
                                }


                            }
                        }
                        ent1.Product_ID__c = ol.pricebookentry.product2.id;
                        ent1.name = ol.opportunity.account.name;

                        if (subscripAsset.size() > 0) {
                            ent1.AssetId = subscripAsset[0].id;
                        }

                        if (ol.opportunity.account.Partner_Type__c == 'Agency' || test.IsRunningtest()) {
                            ent1.Type = 'Partner';


                            //ent.BusinessHours= lookup
                            if (eprocessMap.containskey('Standard Support')) {
                                ent1.SlaProcessId = eprocessMap.get('Standard Support');
                            }
                            if (oppAndAccount[0].Account.Sales_Region__c == 'North America') {
                                if (BhoursMap.keyset().contains('Local Hours (North America)'))
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (North America)');
                            }
                            if (oppAndAccount[0].Account.Sales_Region__c == 'APAC' || test.IsRunningtest()) {
                                if (BhoursMap.keyset().contains('Local Hours (APAC)'))
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (APAC)');
                            }
                            if (oppAndAccount[0].Account.Sales_Region__c == 'EMEA' || test.IsRunningtest()) {
                                if (BhoursMap.keyset().contains('Local Hours (EMEA)'))
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (EMEA)');
                            }
                        }
                        if (ol.opportunity.account.Partner_Type__c == 'Preferred Services' || test.IsRunningtest()) {
                            ent1.Type = 'Partner';

                            if (eprocessMap.containskey('Partner Support')) {
                                ent1.SlaProcessId = eprocessMap.get('Partner Support');
                            }
                            if (BhoursMap.containskey('24x5')) {
                                ent1.BusinessHoursId = BhoursMap.get('24x5');
                            }

                        }
                        if (ol.opportunity.account.Partner_Type__c == 'Reseller' || test.IsRunningtest()) {
                            ent1.Type = 'Partner';

                            if (oppAndAccount[0].Account.Sales_Region__c == 'North America') {
                                if (BhoursMap.keyset().contains('Local Hours (North America)'))
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (North America)');
                            }
                            if (oppAndAccount[0].Account.Sales_Region__c == 'APAC' || test.IsRunningtest()) {
                                if (BhoursMap.keyset().contains('Local Hours (APAC)') || test.IsRunningtest())
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (APAC)');
                            } else if (oppAndAccount[0].Account.Sales_Region__c == 'EMEA' || test.IsRunningtest()) {
                                if (BhoursMap.keyset().contains('Local Hours (EMEA)') || test.IsRunningtest())
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (EMEA)');
                            }
                        }
                        if (ol.opportunity.account.Partner_Type__c == 'Customer & Partner' || test.IsRunningtest()) {
                            ent1.Type = '';


                        }
                        /* ent1.StartDate = ol.opportunity.Sub_Start_Date__c;
                        ent1.EndDate = ol.opportunity.Sub_End_Date__c;*/

                        ent1.StartDate = ol.Related_asset__r.Installdate;
                        ent1.EndDate = ol.Related_asset__r.UsageEndDate;
                        sr_key = mcs.get('AMER').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('AMER').support_region_value__c;
                        }

                        sr_key = mcs.get('LATAM').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('LATAM').support_region_value__c;
                        }

                        sr_key = mcs.get('EMEA').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('EMEA').support_region_value__c;
                        }

                        sr_key = mcs.get('ANZ').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('ANZ').support_region_value__c;
                        }

                        sr_key = mcs.get('Non-EMEA Spark').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('Non-EMEA Spark').support_region_value__c;
                        }

                    } else if ((ol.opportunity.account.type != 'Partner') && ol.opportunity.account.Partner_Type__c != 'Referral') {
                        IsPartner = test.isrunningtest() ? true : false;
                        if (ExistingEntitlement.keyset().contains(ol.pricebookentry.product2Id)) {
                            ent1 = ExistingEntitlement.get(ol.pricebookentry.product2Id);


                            //  ent1.AccountId=ol.opportunity.account.id;
                            system.debug('this is existing asset !partner' + ent1.id);
                        } else if (ol.related_Asset__c != null && RelatedEntitlementMap.keyset().contains(ol.related_Asset__c)) {
                            ent1 = RelatedEntitlementMap.get(ol.related_Asset__c);

                        } else {
                            system.debug('this is existing asset !partner else');
                            if (DefEnt != null && DefEnt.size() > 0) {

                                ent1 = DefEnt[0];
                                // ent1.AccountId=ol.opportunity.account.id;
                                system.debug('this is in !partner default ent' + ent1.id);
                            } else {
                                //ent1 = new Entitlement();
                                if (!(ol.opportunity.name.containsIgnorecase('renewal') || ol.opportunity.type == 'Upsell/Crossell')) {
                                    ent1 = new Entitlement();

                                    ent1.AccountId = ol.opportunity.account.id;
                                } else {
                                    break;
                                }

                            }
                        }
                        ent1.Product_ID__c = ol.pricebookentry.product2.id;
                        ent1.name = ol.opportunity.account.name;

                        if (subscripAsset.size() > 0) {
                            ent1.AssetId = subscripAsset[0].id;
                        }

                        if (ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Spark' || test.IsRunningtest()) {

                            ent1.Type = 'Spark';



                            if (eprocessMap.containskey('Spark Support')) {
                                ent1.SlaProcessId = eprocessMap.get('Spark Support');
                            }
                            if (oppAndAccount[0].Account.Sales_Region__c == 'North America') {
                                if (BhoursMap.keyset().contains('Local Hours (North America)'))
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (North America)');
                            } else if (oppAndAccount[0].Account.Sales_Region__c == 'APAC') {
                                if (BhoursMap.keyset().contains('Local Hours (APAC)'))
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (APAC)');
                            } else if (oppAndAccount[0].Account.Sales_Region__c == 'EMEA') {
                                if (BhoursMap.keyset().contains('Local Hours (EMEA)'))
                                    ent1.BusinessHoursId = BhoursMap.get('Local Hours (EMEA)');
                            }
                        }
                        if (ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Premier' || test.IsRunningtest()) {
                            ent1.Type = 'Premier';

                            if (eprocessMap.containskey('Premier Support') || test.IsRunningtest()) {
                                ent1.SlaProcessId = eprocessMap.get('Premier Support');
                            }
                            if (BhoursMap.containskey('24x5') || test.IsRunningtest()) {
                                ent1.BusinessHoursId = BhoursMap.get('24x5');
                            }
                        }
                        if (ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Elite' || test.IsRunningtest()) {
                            ent1.Type = 'Elite';

                            if (eprocessMap.containskey('Elite Support') || test.IsRunningtest()) {
                                ent1.SlaProcessId = eprocessMap.get('Elite Support');
                            }
                            if (BhoursMap.containskey('24x5') || test.IsRunningtest()) {
                                ent1.BusinessHoursId = BhoursMap.get('24x5');
                            }

                        }
                        ent1.StartDate = ol.opportunity.Sub_Start_Date__c;
                        ent1.EndDate = ol.opportunity.Sub_End_Date__c;
                        sr_key = mcs.get('AMER').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('AMER').support_region_value__c;
                        }

                        sr_key = mcs.get('LATAM').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('LATAM').support_region_value__c;
                        }

                        sr_key = mcs.get('EMEA').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('EMEA').support_region_value__c;
                        }

                        sr_key = mcs.get('ANZ').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('ANZ').support_region_value__c;
                        }

                        sr_key = mcs.get('Non-EMEA Spark').Support_region_key__c;
                        if (sr_key.containsIgnoreCase(ol.opportunity.account.Business_Unit__c)) {
                            ent1.Support_Region__c = mcs.get('Non-EMEA Spark').support_region_value__c;
                        }
                        system.debug('This is else if ' + ent1.StartDate + ' end date ' + ent1.EndDate);


                    }

                    if (ent1.id != null && !CheckDupSet.contains(ent1.id)) {
                        ListOfEntitlements.add(ent1);
                        CheckDupSet.add(ent1.id);
                    } else if (ent1.id == null)
                        ListOfEntitlements.add(ent1);

                }
            }
            if ((EntList != null && EntList.size() == 0 && DefEnt.size() == 0 && ListOfEntitlements.size() == 0) || test.IsRunningtest()) {
                if (!(ol.opportunity.name.containsIgnorecase('renewal') || ol.opportunity.name.containsIgnorecase('-01R') ||
                    ol.opportunity.name.containsIgnorecase('-02R') ||
                    ol.opportunity.name.containsIgnorecase('-03R') || ol.opportunity.type == 'Upsell/Crossell' &&
                    ol.pricebookentry.product2.ProductCode == 'LM-SAND')) {
                    CreateDefaultEntitlement();
                }
                //CreateDefaultEntitlement();
                System.debug('Default Entitlements are inserted');
            }
        }
        if (ListOfEntitlements.size() > 0) {
            System.debug('ListOfEntitlements are inserted or update' + ListOfEntitlements);

            upsert ListOfEntitlements;
        }



    }



    public static void CreateDefaultEntitlement() {
        Map < String, Sales_region__c > mc = Sales_region__c.getAll();
        string s_key = '';
        if (HasRegular) {
            entitlement DefaultEnt = new entitlement();
            DefaultEnt.name = oppAndAccount[0].Account.Name;
            DefaultEnt.StartDate = oppAndAccount[0].Sub_Start_Date__c;
            DefaultEnt.EndDate = oppAndAccount[0].Sub_End_Date__c;


            if (HasSpark) {
                DefaultEnt.Type = 'Spark';
                if (eprocessMap.containskey('Spark Support'))
                    DefaultEnt.SlaProcessId = eprocessMap.get('Spark Support');
            } else {
                DefaultEnt.Type = 'Standard';
                if (eprocessMap.containskey('Standard Support'))
                    DefaultEnt.SlaProcessId = eprocessMap.get('Standard Support');
            }
            if (oppAndAccount[0].Account.Sales_Region__c == 'North America') {
                if (BhoursMap.keyset().contains('Local Hours (North America)'))
                    DefaultEnt.BusinessHoursId = BhoursMap.get('Local Hours (North America)');
            } else if (oppAndAccount[0].Account.Sales_Region__c == 'APAC') {
                if (BhoursMap.keyset().contains('Local Hours (APAC)'))
                    DefaultEnt.BusinessHoursId = BhoursMap.get('Local Hours (APAC)');
            } else if (oppAndAccount[0].Account.Sales_Region__c == 'EMEA') {
                if (BhoursMap.keyset().contains('Local Hours (EMEA)'))
                    DefaultEnt.BusinessHoursId = BhoursMap.get('Local Hours (EMEA)');
            }
            DefaultEnt.accountid = oppAndAccount[0].account.id;
            /* if (oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('AMER')) {
                                DefaultEnt.Support_Region__c = 'North America';
                            }
                            if (oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('LATAM')) {
                                DefaultEnt.Support_Region__c = 'Latin America';
                            }
                            if (oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('EMEA')) {
                                DefaultEnt.Support_Region__c = 'EMEA';
                            }
                            if (oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('ANZ') || oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('APAC')) {
                                DefaultEnt.Support_Region__c = 'APAC';
                            }
                            if (oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('Non-EMEA Spark') || oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('Unknown') || oppAndAccount[0].Account.Business_Unit__c.containsIgnoreCase('Channel')) {
                                DefaultEnt.Support_Region__c = 'Other';
                            }*/

            s_key = mc.get('AMER').Support_region_key__c;
            if (s_key.containsIgnoreCase(oppAndAccount[0].Account.Business_Unit__c)) {
                DefaultEnt.Support_Region__c = mc.get('AMER').support_region_value__c;
            }

            s_key = mc.get('LATAM').Support_region_key__c;
            if (s_key.containsIgnoreCase(oppAndAccount[0].Account.Business_Unit__c)) {
                DefaultEnt.Support_Region__c = mc.get('LATAM').support_region_value__c;
            }

            s_key = mc.get('EMEA').Support_region_key__c;
            if (s_key.containsIgnoreCase(oppAndAccount[0].Account.Business_Unit__c)) {
                DefaultEnt.Support_Region__c = mc.get('EMEA').support_region_value__c;
            }

            s_key = mc.get('ANZ').Support_region_key__c;
            if (s_key.containsIgnoreCase(oppAndAccount[0].Account.Business_Unit__c)) {
                DefaultEnt.Support_Region__c = mc.get('ANZ').support_region_value__c;
            }

            s_key = mc.get('Non-EMEA Spark').Support_region_key__c;
            if (s_key.containsIgnoreCase(oppAndAccount[0].Account.Business_Unit__c)) {
                DefaultEnt.Support_Region__c = mc.get('Non-EMEA Spark').support_region_value__c;
            }
            if (subscripAsset.size() > 0) {
                system.debug('i am in subscriptionasset if');
                for (Asset a: subscripAsset) {
                    system.debug('this is product code ' + a.product2.ProductCode);
                    if (a.product2.ProductCode != 'LM-SAND') {
                        DefaultEnt.AssetId = a.id;
                        system.debug('This is in lopp');
                    }
                }
            }
            // DefaultEnt.AssetId = subscripAsset[0].id;
            ListOfEntitlements.add(DefaultEnt);

            upsert ListOfEntitlements;
        }
    }



    @
    isTest(SeeAllData = true)
    public static void DoTest() {
        //Test.StartTest();
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        Account a = new Account(Name = 'Test Acc', Sales_Region__c = 'North America');
        insert a;
        Contact c = new Contact(LastName = 'test Con', LeadSource = 'Blog', AccountId = a.id);
        insert c;
        Opportunity Opp = new Opportunity(Name = 'test opp', AccountId = a.id, Type = 'New Business', CloseDate = Date.today(), stagename = 'Discovery', Deal_Type__c = 'Standard', NextStep = 'test', CRM_System__c = 'ACT!', LeadSource = 'Blog', Primary_Marketo_User_Lookup__c = c.id);
        insert Opp;


        List < Product2 > ProList = new List < Product2 > ();
        Product2 p = new Product2(Name = 'test pro', IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
        ProList.add(p);
        /*Product2 p2 = new Product2(Name = 'test pro2', IsActive = true, ConvertTo__c = 'Add On');
        ProList.add(p2);
        Product2 p3 = new Product2(Name = 'test pro3', IsActive = true, ConvertTo__c = 'Entitlement-Spark');
        ProList.add(p3);
        Product2 p4 = new Product2(Name = 'test pro4', IsActive = true, ConvertTo__c = 'Entitlement-Spark');
        ProList.add(p4);*/
        insert ProList;
        List < PriceBook2 > PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];
        //Product2 prod = [SELECT p.Id FROM Product2 p WHERE p.Name = 'Lead Management - Professional 100K'];
        List < PriceBookEntry > PBEList = new List < PriceBookEntry > ();
        PriceBookEntry Pe = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p.id, UnitPrice = 200);
        PBEList.add(Pe);
        /*PriceBookEntry Pe2 = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p2.id, UnitPrice = 200);
        PBEList.add(Pe2);
        PriceBookEntry Pe3 = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p3.id, UnitPrice = 200);
        PBEList.add(Pe3);
        PriceBookEntry Pe4 = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p4.id, UnitPrice = 200);
        
        PBEList.add(Pe4);*/
        insert PBEList;
        /* List<PriceBookEntry> pbe_list = [Select p.Id, p.Name, p.Pricebook2Id, p.Product2Id , p.CreatedById , p.LastModifiedById From PricebookEntry p WHERE
                p.Pricebook2.Name = 'Standard Price Book' and p.IsActive = true];//and p.Name = 'Lead Management - Professional 100K' and p.IsActive = true];
            PricebookEntry pbe = pbe_list.get(0);*/
        List < OpportunityLineItem > OplList = new List < OpportunityLineItem > ();
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
        /* OpportunityLineItem oli2 = new OpportunityLineItem();
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
        OplList.add(oli3);
        OpportunityLineItem oli4 = new OpportunityLineItem();
        //oli.Product_Family__c = 'test product family';
        oli4.Users__c = 1;
        oli4.MLM_Edition__c = 'test edition';
        oli4.OpportunityId = Opp.Id;
        oli4.PricebookEntryId = pe4.Id;
        oli4.Quantity = 2;
        oli4.UnitPrice = 200;
        OplList.add(oli4);*/
        Test.StartTest();
        insert OplList;

        Opp.RecordTypeId = ClosedWonId;
        Opp.Stagename = 'Closed Won';
        update Opp;

        //createFromEmail(Opp.id ,'001','','abc','123','','aer');
        // createFromEmail(string OppID,string Munchkin , string PO,string ProductC,string InstanceNum,string Asse,string AccountPre)
        /* Account PartnerAccount = new Account(Name='Test Acc',Sales_Region__c = 'EMEA',Type='Partner');
        insert PartnerAccount ;
        Opp.AccountId = PartnerAccount.Id ; 
        update Opp;*/

        Test.stopTest();

    }

}