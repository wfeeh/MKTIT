public virtual class MarketoBaseController {
    public GlobalFunctions gF {get; protected set;}
    public List<Account> AccountList{get;set;}
    public Account accountResellerL{get;set;}
    List<Community_subscription__c> subscribe{get;set;}
    public String support_Value{get;set;}
    public String support_link{get;set;}
    public Id accId{get;set;}
    public Id profileId{get;set;}
    public User profileUser{get; private set;}
    public string badgeLargeImage{get;set;}
    public string badgeSmallImage{get;set;}
    public Boolean isSubscribed{get;set;}
     public STATIC BOOLEAN IS_PARTNER_SUPPORTED = FALSE; 
    public MarketoBaseController getThis() {
     
        return this;
    }
     
        
    /* Badgeville Selected users only starts  July 24 2012*/         
    
    public BOOLEAN partner_supported_instnce{get;set;}
    
    public void settingbadgeVilleStatusForLogdUser()
    {
        partner_supported_instnce = GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserId());
    }
    public MarketoBaseController ()
    {        
       // partner_supported_instnce = GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserId());        
    }
    /* Badgeville Selected users only ends July 24 2012*/    
    
    public MarketoUserContext context {
        get {System.debug('User context '+MarketoUserContext.getContext());
            return MarketoUserContext.getContext();
        }
        set;
    }
    public String getCheckSupport(){
        String profileUserId = ApexPages.currentPage().getParameters().get('id');
        profileUser = [select Id, FirstName,AccountID, LastName, Is_Consultant__c, Is_Customer__c, Is_Employee__c, Is_Partner__c,
                       Champion__c,Professional__c,Enterprise__c, Spark__c
                       from User Where Id =:UserInfo.getUserId() ];
        System.debug('profileUser -->'+profileUser );
        accId= profileUser.AccountId;
        System.debug('accId-->'+accId);
        profileId = profileUser.Id;
        subscribe = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Question' and Category__c = 'All Categories'];
        System.debug('subscribe -->'+subscribe );    
        If(subscribe.isEmpty() == false){
            isSubscribed = true;
        }
        else{
            isSubscribed =  false;
        }
        Accountlist = [Select ID,Name,ExecutiveSponsor__c,Support_Level__c, Name_of_Reseller__c From Account Where Id =: accId];
        if(Accountlist.size() >= 1 ){
            for(Account a: Accountlist ){
                if(a.Support_Level__c== 'Partner Supported'){
                   if(a.Name_of_Reseller__c== 'ExactTarget') {
                        support_link= 'https://3sixty.exacttarget.com';
                        support_Value = 'ExactTarget Support';
                    } else if(a.Name_of_Reseller__c== 'Datarati') {
                        support_link= 'mailto:support@datarati.com.au';
                        support_Value = 'Datarati Support';
                    }  else if(a.Name_of_Reseller__c== 'LeadMD') {
                        support_link= 'mailto:support@leadmd.com';
                        support_Value = 'LeadMD Support';
                    } else if(a.Name_of_Reseller__c== 'Pedowitz') {
                        support_link= 'mailto:support@pedowitzgroup.com';
                        support_Value = 'Pedowitz Support';
                    } else {
                        support_link= 'https://app.marketo.com/homepage/success?task=ticket';
                        support_Value = 'Support Center';
                    }
                    return support_link;
                }
            }
        }
        support_link= 'https://app.marketo.com/homepage/success?task=ticket';
        support_Value = 'Support Center';
        System.debug('support_link-->'+support_link);
        return support_link; 
    }
 
   
    /* 08-05-11 vishals@grazitti.com Added to show plain text editor on iPad/iPhone*/
    public Boolean getIsRichTextRequired(){
        if(ApexPages.currentPage().getHeaders().containsKey('USER-AGENT') && 
            ((ApexPages.currentPage().getHeaders().get('USER-AGENT')).tolowercase().contains('ipad') ||
             (ApexPages.currentPage().getHeaders().get('USER-AGENT')).tolowercase().contains('iphone')||
             (ApexPages.currentPage().getHeaders().get('USER-AGENT')).tolowercase().contains('android')
            )
           ){
            return false;
        }else{
            return true;
        }   
    }
    
    /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
    public String preserveCarriageReturn(String body){
        return body.replace('\r','<br/>');
    }
    
    
     

    
    public static testMethod void testBaseController() {
        MarketoBaseController c = new MarketoBaseController();
        PageReference pageRef = Page.marketocommunityhome;
        pageRef.getParameters().put('id', UserInfo.getUserType());
        Test.setCurrentPage(pageRef);
        c.getThis();
        system.debug(c.context);
        c.getIsRichTextRequired();
        c.preserveCarriageReturn('test');
        //c.checkPopup();
        c.getCheckSupport();
        c.settingbadgeVilleStatusForLogdUser();
      }    
}