trigger updateUserBadgeTag on Account (after insert, after update) {
    public String MLM_edition;
    public String user;
    public String badge_type;
    public Id accId{get;set;}
    // The below initialization to post cowbells to chatter feed
    List<User> UsersList = new List<User>();
    List<Account> Acc = new List<Account>();
    List <Id> UsersIds = new List<Id>();
    Integer i = 0;

    for (Account a: trigger.new) {
        MLM_edition = a.MLM_Edition__c;
        accId       = a.Id;
        badge_type  = a.Type;

       // The below if-loop added to post cowbells to chatter feed
       if (trigger.isupdate){
          if ((trigger.old[i].type <> 'Customer' && trigger.old[i].type <> 'Partner' && 
             trigger.old[i].type <> 'Customer of Reseller Partner' && trigger.old[i].type <> 'Customer & Partner') ||
             trigger.old[i].customer_number__c == null || trigger.old[i].Date_Became_a_Customer__c == null)
          {
             if (a.type == 'Customer' || a.type == 'Partner' || a.type == 'Customer of Reseller Partner' || a.type == 'Customer & Partner') {
                if (a.customer_number__c > 100 && a.Date_Became_a_Customer__c > Date.today()-90) {
                   Acc.add(a);
                   UsersIds.add(a.ownerid);
                }
             }
          }
       } else if (trigger.isinsert){
          if (a.type == 'Customer' || a.type == 'Partner' || a.type == 'Customer of Reseller Partner' || a.type == 'Customer & Partner') {
             if (a.customer_number__c > 100 && a.Date_Became_a_Customer__c > Date.today()-90) {
                Acc.add(a);
                UsersIds.add(a.ownerid);
             }
          }
       }
       i++;
    }

    UsersList =[select id, name, Is_Partner__c, Professional__c, AccountId from User where AccountId =: accId];
    for(User us: UsersList ) {
       // If Partner then check the partner in user
       // If any of the field of MLM then check that and un-check all others     
       us.Is_Partner__c   = false;
       us.Professional__c = false;
       us.Enterprise__c   = false;
       us.Spark__c        = false;  
         
       if (badge_type == 'Partner') {
           us.Is_Partner__c = true;
       } 
       
       if(MLM_edition== 'Professional' || MLM_edition == 'SMB') {
           us.Professional__c = true;
       }
       
       if(MLM_edition== 'Enterprise') {
           us.Enterprise__c = true;
       }
       
       if(MLM_edition== 'Spark') {
           us.Spark__c = true;
       }
     // update UsersList ;         
    }
    update UsersList ;
    // The below line added to post cowbells to chatter feed
   if (!PostToChatter.FirstPass){
       if (Acc.size() > 0) {
          PostToChatter.PostSalesBellToChatter(Acc,UsersIds);
          PostToChatter.FirstPass = True;
   }}
}