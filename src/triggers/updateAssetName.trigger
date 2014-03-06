trigger updateAssetName on Asset(after insert, after update) {
    list<asset> ast_list= new list<asset>();

    map < ID, list < Asset >> assetsAddOns = new map < ID, List < Asset >> ();
    for(Asset ast_obj: Trigger.new){
           if(ast_obj.asset_type__c=='Subscription')
           ast_list.add(ast_obj);
       }


    for (Asset a: [Select ID, Acct_Prefix__c,(SELECT ID,Add_On_Product__c,Parent_instance__r.Acct_Prefix__c, Name, Asset.Product2.name, Asset_type__c,
                    Parent_Instance__c From Assets__r) FROM Asset WHERE 
                 ID IN: ast_list]) {
            assetsAddOns.put(a.id, a.Assets__r);
        }
        
        List < Asset > subassets_list = new List < Asset > ();
        List < Asset > up_list = new List < Asset > ();
       for(ID ast_id :assetsAddOns.keyset()){
       subassets_list = assetsAddOns.get(ast_id);
               for(asset sub_ast : subassets_list){
                   sub_ast.name = sub_ast.Parent_instance__r.Acct_Prefix__c + ' ' + sub_ast.Add_On_Product__c; 
                   up_list.add(sub_ast);
               }
       
       }
        System.debug('@@'+up_list);
        if(!up_list.isEmpty())
        update up_list;


}