trigger Asset_BI_BU_AI_AU on Asset( after insert, after update,
    before insert, before update) {
    
        
    if(Trigger.isAfter){
       if (!UpdateAssets.haveupdatedAccounts) {
              UpdateAssets.haveupdatedAccounts = true;
      System.debug('AA'+trigger.new);
      
      if (Trigger.isUpdate || Trigger.isInsert){
                 
                UpdateAssets.updateAccount(Trigger.new);
           
           UpdateAssets.updateAddOnAssetsName(Trigger.new);
           UpdateAssets.updateAddOnAssetsStatus(Trigger.new);
           // UpdateAssets.updateEntitlement(Trigger.new);
          }
      
       }
    }
    
}