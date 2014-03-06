trigger CreateContactUsageData on Contact (after insert, after update){
    List<Contact> contactList = new List<Contact>();
    if(Trigger.isInsert){
        for(Contact con :Trigger.new){
            if(
                con.User_Type_Admin__c == TRUE || con.User_Type_System_Admin__c == TRUE || 
                con.Is_Authorized_Contact__c == 'Yes' || con.Marketo_Usage_Report_Opt_In__c == TRUE
            ){
                contactList.add(con);
            }
        }
    }
    
    if(Trigger.isUpdate){
        for(Contact con :Trigger.new){
            if(
                con.User_Type_Admin__c != Trigger.oldMap.get(con.id).User_Type_Admin__c ||
                con.User_Type_System_Admin__c != Trigger.oldMap.get(con.id).User_Type_System_Admin__c || 
                con.Is_Authorized_Contact__c != Trigger.oldMap.get(con.id).Is_Authorized_Contact__c ||
                con.Marketo_Usage_Report_Opt_In__c != Trigger.oldMap.get(con.id).Marketo_Usage_Report_Opt_In__c
            ){
                if(
                    con.User_Type_Admin__c == TRUE || con.User_Type_System_Admin__c == TRUE || 
                    con.Is_Authorized_Contact__c == 'Yes' || con.Marketo_Usage_Report_Opt_In__c == TRUE
                ){
                    contactList.add(con);
                }
            }    
        }
    }
    
    CreateConUsageDataFromAccUsageData ccud = new CreateConUsageDataFromAccUsageData();
    ccud.CreateConUsageData(contactList);
}