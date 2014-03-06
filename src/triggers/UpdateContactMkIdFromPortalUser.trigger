trigger UpdateContactMkIdFromPortalUser on User (after insert, after update) {

    Map<String,String> myMnckinLst = new Map<String,String>();
    List<User> myUserList = new List<User>();      
    
    /*@Future
    public void updateContacts(Map<String,String> cntMnkMap) {
        set<string> cntIds = cntMnkMap.keyset();
        List<Contact> cLst = [select Id,Munchkin_ID__c from Contact where Id in: cntIds];
        List<Contact> cntUpdLst = new List<Contact>();
        for(Contact c :cLst)               
        {
            if(c.Munchkin_ID__c != cntMnkMap.get(c.Id))
            {   
                c.Munchkin_ID__c = cntMnkMap.get(c.Id);
                cntUpdLst.add(c);
            }
        }
        if(!cntUpdLst.isEmpty()){ update cntUpdLst;}
    }*/
    List<Id> contactIds = new List<Id>();
    public static boolean runOnce = true;
    for(User u :trigger.new) 
    {
        System.debug('UserTrigger==>' + u.Munchkin_ID__c + u.IsPortalEnabled);
        if(Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
                if (u.ContactId != null && u.Munchkin_ID__c != null) {
                    myMnckinLst.put(u.ContactId,u.Munchkin_ID__c);
                }
            }
            
            else if(Trigger.isUpdate)
            {   
                if(Trigger.newMap.get(u.Id).Munchkin_ID__c != Trigger.oldMap.get(u.Id).Munchkin_ID__c){
                    System.Debug('Update Is Run');
                    System.debug('runOnce'+runOnce);
                    if(runOnce == false){return;}
                    System.Debug('-------------');
                    if (u.ContactId != null && u.Munchkin_ID__c != null && u.IsPortalEnabled == true) {
                        myMnckinLst.put(u.ContactId,u.Munchkin_ID__c);
                        System.Debug('myMnckinLst+++'+myMnckinLst);
                    }
                }
            }            
        }
    }         
    if(!myMnckinLst.isEmpty() && runOnce == true){ 
        //UpdateContactFromPortalUser updCFP = new UpdateContactFromPortalUser();
        ContactTimeZone.updateContacts(myMnckinLst); 
    }
    runOnce = false;
}