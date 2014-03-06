trigger updateOpportunity on Opportunity(after update) {

    Set < Opportunity > oppSet= new set < opportunity > ();
    
   
    for (Integer i = 0; i < trigger.New.size(); i++) {
    if(trigger.new[i].frm_payment__c!=true){
        if (trigger.Old[i].latest_payment_date__c == trigger.New[i].latest_payment_date__c && trigger.New[i].StageName == 'Closed Won')
            oppSet.add(trigger.New[i]);
            
            }
    }

    for (opportunity op: oppSet) {


        if (createAssetsAndEntitlements.Istrigger == false) {
            createAssetsAndEntitlements.Istrigger = true;
            createAssetsAndEntitlements.CreateAE(op.ID);

        }

    }

}


/*trigger updateOpportunity on Opportunity (after update) {

    System.Debug('Enter1 ' + Trigger.new[0].StageName);
    System.Debug('createAssetsAndEntitlements.Istrigger'+createAssetsAndEntitlements.Istrigger);
    if(Trigger.new[0].StageName == 'Closed Won' && createAssetsAndEntitlements.Istrigger == false)
    {
        System.Debug('Enter2');
        createAssetsAndEntitlements.Istrigger = true;
        if((Trigger.new[0].StageName == 'Closed Won')) //&& (Trigger.old[0].StageName != 'Closed Won')) // Bikram added for 4949
            createAssetsAndEntitlements.CreateAE(Trigger.new[0].id);
    }
}*/