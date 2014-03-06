/****************************************************
Trigger Name: SituationEmailToCase 
Author: ClearTeask
Created Date: 20/09/2012
Usage: This trigger is used to map SM Account and SM Contact related to email in email to case.
*****************************************************/
trigger SituationEmailToCase on Case (after insert) {
    
    Map<Id, String> mapCaseEmail = new Map<Id, String>();    
    for(Case c :trigger.new) {

        if(c.Origin != null && c.Origin.equals('TBD'))
            mapCaseEmail.put(c.id, c.SuppliedEmail);
    }
    
    if(mapCaseEmail != null && mapCaseEmail.keySet().size() > 0)
        SituationUtil.updateCase(mapCaseEmail);
    
}