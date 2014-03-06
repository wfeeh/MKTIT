trigger updateEntitlementStartdate on Asset(after insert, after update) {
    Map < Asset, List < Entitlement >> Asset_entitlement_map = new map < Asset, List < Entitlement >> ();
    List < entitlement > ent_list = new List < entitlement > ();

    FOR(entitlement e: [SELECT ID, NAME, STARTDATE, AssetID,EndDATE FROM Entitlement WHERE AssetID IN: Trigger.New]) {

        e.enddate=Trigger.newmap.get(e.AssetId).UsageEnddate;
        ent_list.add(e);

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