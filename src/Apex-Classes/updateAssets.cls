public class updateAssets {

    public static Boolean haveupdatedAccounts = false;
     public static Boolean haveupdatedAssets = false;

    public static void updateAddOnAssetsName(list < Asset > triggerNew) {
        //
        system.debug('@@' + triggerNew);
      list < asset > ast_list= new list<asset>();
      list < asset > as_add_list=new list<asset>();
      map < ID, list < Asset >> ActiveAddons=new  map < ID, list < Asset >>();
      map < ID, list < Asset >> assetsAddOns=new  map < ID, list < Asset >>();
        for (Asset ast_obj: [Select ID,
            asset_type__c, STATUS,
            Acct_Prefix__c, (SELECT ID, Add_On_Product__c,
                Parent_instance__r.Acct_Prefix__c, STATUS,
                Name, Asset.Product2.name, Asset_type__c,
                Parent_Instance__c From Assets__r)
            FROM Asset WHERE ID IN: triggerNew
        ]) {
            system.debug('@@' + ast_obj.Status);

            assetsAddOns.put(ast_obj.ID, ast_obj.Assets__r);

            /* if (ast_obj.status == 'Active') {
                ActiveAddons.put(ast_obj.ID, ast_obj.Assets__r);
            }*/
        }

        for (Asset ast: [SELECT ID, Add_On_Product__c,
            Parent_instance__r.Acct_Prefix__c, STATUS, Name,
            Asset.Product2.name, Asset_type__c,
            Parent_Instance__c FROM Asset WHERE
            Parent_Instance__c IN: assetsAddOns.keyset()
        ]) {
            if (ast.Parent_instance__r.Acct_Prefix__c != null)
                ast.name = ast.Parent_instance__r.Acct_Prefix__c + ' ' + ast.Add_On_Product__c;
            //ast.STATUS='Active';
            ast_list.add(ast);
        }

        /*for (Asset as_add: [SELECT ID, Add_On_Product__c,
            Parent_instance__r.Acct_Prefix__c, STATUS, Name,
            Asset.Product2.name, Asset_type__c,
            Parent_Instance__c FROM Asset WHERE
            Parent_Instance__c IN: ActiveAddons.keyset()
        ]) {

            //as_add.name = ast.Parent_instance__r.Acct_Prefix__c + ' ' + ast.Add_On_Product__c;
            as_add.STATUS = 'Active';
            as_add_list.add(as_add);
        }

        if (!as_add_list.isEmpty()) {
            update as_add_list;

        }*/

        if (!ast_list.isEmpty()) {
            update ast_list;

        }


    }

    public static void updateAddOnAssetsStatus(list < Asset > triggerNew) {
        //
        system.debug('@@' + triggerNew);
        list < asset > ast_list= new list<asset>();
      list < asset > as_add_list=new list<asset>();
      map < ID, list < Asset >> ActiveAddons=new  map < ID, list < Asset >>();
      map < ID, list < Asset >> assetsAddOns=new  map < ID, list < Asset >>();
        for (Asset ast_obj: [Select ID,
            asset_type__c, STATUS,
            Acct_Prefix__c, (SELECT ID, Add_On_Product__c,
                Parent_instance__r.Acct_Prefix__c, STATUS,
                Name, Asset.Product2.name, Asset_type__c,
                Parent_Instance__c From Assets__r)
            FROM Asset WHERE ID IN: triggerNew
        ]) {
            if (ast_obj.Status == 'Active')
                assetsAddOns.put(ast_obj.ID, ast_obj.Assets__r);

            /* if (ast_obj.status == 'Active') {
                ActiveAddons.put(ast_obj.ID, ast_obj.Assets__r);
            }*/
        }

        for (Asset ast: [SELECT ID, Add_On_Product__c,
            Parent_instance__r.Acct_Prefix__c, STATUS, Name,
            Asset.Product2.name, Asset_type__c,
            Parent_Instance__c FROM Asset WHERE
            Parent_Instance__c IN: assetsAddOns.keyset()
        ]) {
            System.debug('@@'+ast.STATUS);
            ast.STATUS = 'Active';
            ast_list.add(ast);
        }

        /*for (Asset as_add: [SELECT ID, Add_On_Product__c,
            Parent_instance__r.Acct_Prefix__c, STATUS, Name,
            Asset.Product2.name, Asset_type__c,
            Parent_Instance__c FROM Asset WHERE
            Parent_Instance__c IN: ActiveAddons.keyset()
        ]) {

            //as_add.name = ast.Parent_instance__r.Acct_Prefix__c + ' ' + ast.Add_On_Product__c;
            as_add.STATUS = 'Active';
            as_add_list.add(as_add);
        }

        if (!as_add_list.isEmpty()) {
            update as_add_list;

        }*/

        if (!ast_list.isEmpty()) {
            update ast_list;

        }


    }
    public static void updateAccount(list < Asset > triggerNew){
         list < asset > new_aset = new list < asset > ();
            list<entitlement> new_ent=new list<entitlement>();
            map <Account, LIST < asset >> acnt_asset_map = new map < Account, LIST < asset >> ();
            map <Account, LIST < Entitlement >> acnt_ent_map = new map < Account, LIST < Entitlement >> ();
            list < account > acnt_list = new list < account > ();
            list < ID > acnt_ID = new list < id > ();
          list<account>acnt_list_update= new list<account>();
        
            //list<asset> new_aset= new list<asset>();
            string edition = '';
            string Add_On = '';
            map < id, string > acnt_edition_map = new map < id, string > ();
          
            map < id, string > acnt_Addon_map = new map < id, string > ();
            //list < account > acnt_list = new list < account > ();
        
            for (asset a: triggerNew) {
                 {
                    acnt_ID.ADD(a.ACCOUNTID);
                }
                SYSTEM.DEBUG('>>>' + a.ACCOUNTID);
            }
        
            for (account a: [SELECT NAME,Add_On_Products__c,Support_level1__c, PRODUCT_EDITIONS__c, (SELECT Asset_type__c,
              Add_On_Product__c, NAME, ID, STATUS, Subscription_type__c FROM ASSETS where status='Active' 
              ),(SELECT Name, ID, STATUS, Type FROM Entitlements WHERE status='Active')
                FROM ACCOUNT WHERE ID IN: acnt_ID
            ]) {
        
                acnt_asset_map.put(a, a.assets);
                acnt_ent_map.put(a,a.entitlements);
              //acnt_edition_map.put(a.ID, a.PRODUCT_EDITIONS__c);
            }
        
        
        
            for (Account acc: acnt_asset_map.keyset()) {
                new_aset = acnt_asset_map.get(acc);
                new_ent=acnt_ent_map.get(acc);
                // s=acnt_edition_map.get(aid);
                acc.Product_Editions__c='';
                acc.Add_on_products__c='';
                acc.support_level1__c='';
                for (asset a: new_aset) {
                  if(a.Asset_type__c=='Subscription'){
                 if(a.Subscription_type__c==null){
                 a.Subscription_type__c='';}
                    
                        if (a.subscription_type__c == 'SMB Spark' ||
                            a.subscription_type__c == 'SMB Select' ||
                            a.subscription_type__c == 'SMB Standard') {
                            A.subscription_type__c = A.subscription_type__c.substring(4);
                        }
                        if(acc.product_editions__c==null || acc.product_editions__c==''){
                               acc.product_editions__c='';
                               }
        
                        if (!acc.Product_Editions__c.containsignorecase(a.Subscription_type__c)) {
        
                            acc.Product_Editions__c = acc.Product_Editions__c + ';' + a.Subscription_type__c + ' Edition;';
                            system.debug('>>>+' + acc.product_editions__c);
        
                            
                        }
                     }  
                     
                     if(a.Asset_type__c=='Add On'){
                 if(a.Add_on_product__c==null){
                 a.Add_on_product__c='';}
                    
                        
                        if(acc.Add_on_Products__c==null || acc.Add_on_Products__c==''){
                               acc.Add_on_Products__c='';
                               }
        
                        if (!acc.Add_on_Products__c.containsignorecase(a.Add_on_Product__c)) {
        
                            acc.Add_on_Products__c = acc.Add_on_Products__c + ';' + a.Add_on_Product__c + ' ;';
                            system.debug('>>>+' + acc.Add_on_Products__c);
        
                            
                        }
                     }
                     
                     
                     
                    }
             
                for(entitlement e: new_ent){
                
                 if(e.Type==null){
                 e.Type='';}
                    
                        
                        if(acc.support_level1__c==null || acc.support_level1__c==''){
                               acc.support_level1__c='';
                               }
        
                        if (!acc.support_level1__c.containsignorecase(e.type)) {
        
                            acc.support_level1__c = acc.support_level1__c + ';' + e.type + ' ;';
                            system.debug('>>>+' + acc.support_level1__c);
        
                            
                        }
                     
                }
                 acnt_list_update.add(acc);
                }
            
            
                if(!acnt_list_update.Isempty()){
                update acnt_list_update;
                
              }
    }
    
    public static void updateEntitlement(list < Asset > triggerNew){
        Map < Asset, List < Entitlement >> Asset_entitlement_map = new map < Asset, List < Entitlement >> ();
    List < entitlement > ent_list = new List < entitlement > ();

    FOR(Asset ass: [SELECT ID, NAME, InstallDate, UsageEndDate, (SELECT ID, NAME, STARTDATE, EndDATE FROM Entitlements) FROM Asset WHERE ID IN: TriggerNew]) {

        Asset_entitlement_map.put(ass, ass.Entitlements);

    }

    For(Asset a: Asset_entitlement_map.Keyset()) {

        ent_list = Asset_entitlement_map.get(a);
        
            for (entitlement el_obj: ent_list) {
                el_obj.startdate = a.installdate;
                el_obj.Enddate = a.UsageEnddate;
            }
        
        
        
            

    }
  if(!ent_list.isempty()){
    try{
    update ent_list;
    }
    
    catch(exception e){
     system.debug('@@Exception is'+e);
    }
  }
        
    }

}