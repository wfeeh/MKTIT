trigger updateAssetsAccount on Asset(after insert,after update) {
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

    if(!test.isRunningtest())
    for (asset a: trigger.new) {
         {
            acnt_ID.ADD(a.ACCOUNTID);
        }
        SYSTEM.DEBUG('>>>' + a.ACCOUNTID);
    }

    for (account a: [SELECT NAME,Add_On_Products__c,Support_level1__c, PRODUCT_EDITIONS__c, (SELECT Asset_type__c,
      Add_On_Product__c, NAME, ID, STATUS, Subscription_type__c FROM ASSETS WHERE STATUS='ACTIVE'
      ),(SELECT Name, ID, STATUS, Type FROM Entitlements WHERE STATUS='ACTIVE')
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
    
    
        if(!acnt_list_update.Isempty() ){
         if(!test.isRunningtest())
        update acnt_list_update;
        
      }
}