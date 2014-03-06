/****************************************************
Class Name: NewsController
Author: ClearTeask
Created Date: 5/18/2012
Usage: This class is used query records from News object for various types. 
*****************************************************/
global with sharing class NewsController {
    
    public static String ALERT = 'Alert';
    public static String INITIATIVES = 'Initiatives';
    public static String CUSTOMER = 'Customer Hero';
    public static String NEWS = 'News';
    public Integer initiativeLimit {get; set;}
    public Integer newsLimit {get; set;}
    public List<Marketo_News__c> newsRecordList {get; set;}
    public List<Marketo_News__c> initiativesRecordList {get; set;}
    public Boolean isSite {get; set;}
    public Boolean newsShowMore{get;set;}
    public String selectedCategory {get; set;}
    public String myPodName{get;set;}
    
    public String typeOfMember{get;set;}
    public List<SupportTeam> supportTeamList {get;set;}
    public Map<Decimal,Support_Quick_Access_Gallery__c> sortOrderToArtNameFirstFive{get;set;}
    public Map<Decimal,Support_Quick_Access_Gallery__c> sortOrderToArtNameLastFive{get;set;}
    public String currentPage{get;set;}
    public List<CSatAdminPanelData__c> CSatSurveyList{get;set;}
    public string CSatMonth{get;set;}
    public string CSatPercentage{get;set;}
        

    
    public newsController(){
        newsShowMore = false;
        isSite = Utils.isSite;
        newsRecordList = new List<Marketo_News__c>();
        initiativesRecordList = new List<Marketo_News__c>();
        queryNewsRecords();
        queryInitiativeRecords();        
    }
    
    public String myStatusSet{
      get{
       return '<=New=><=Working=><=Awaiting Customer Input=><=Pending Marketo Response=><=Pending Response=><=Suggestion Provided=><=Escalated=><=Awaiting Fix=><=Closed=><=Referred to Ideas=><=Resolved=><=Spark Email Reroute=><=Routed to Tier 2=>';
      }
      set{}
    }
  
    public Map<String,String> statuses{
     get {        
        return new Map<String, String> {        
        '' => '',
        'New' => 'New case that has not been assigned to a Support Engineer.',
        'Working' => 'Assigned to Support Engineer and work is in progress.',
        'Awaiting Customer Input' => 'Assigned Support Engineer has sent a question or request for information to the Case submitter and is waiting for a response.  If we do not hear back after two weeks and 3 email attempts, the Case will be closed via workflow.  If you feel the issue is not resolved, you can reopen the case within 10 days.',
        'Pending Marketo Response' => 'Updated by Case submitter waiting for a response from the assigned Support Engineer.  Cases that have been reopened by you will go into the Pending Marketo Response Status.',
        'Pending Response' => 'Updated by Case submitter waiting for a response from the assigned Support Engineer. Cases that have been reopened by you will also go into the Pending Response Status.',
        'Suggestion Provided' => 'Assigned Support Engineer provided a suggestion that should resolve the issue and is waiting for verification from the Case submitter.  If we do not hear back after 10 days and 3 email attempts, the case will be closed via workflow.  If you feel the issue is not resolved, you can reopen the case within 10 days.',
        'Escalated' => 'Escalated to Engineering for a patch to be applied before the next monthly release.  The Support Case will remain open until the patch has been applied and validated by the Case submitter.',
        'Awaiting Fix' => 'Submitted to Engineering and waiting for the fix to be delivered in the Marketo monthly release.',
        'Closed' => 'Case has been Closed and confirmed by the case submitter or workflow changed to Closed after email attempts from Suggestion Provided or Awaiting Customer Input.',
        'Referred to Ideas' => 'Referred to Ideas',
        'Resolved' =>'Resolved',
        'Spark Email Reroute' => 'Spark Email Reroute',
        'Routed to Tier 2' => 'Reassigned to a Senior Support Engineer or Subject Matter Expert for resolution.'
        
        };
    }
    set;
    }
    
    List<User> usrList = [Select u.Username, u.UserType, u.LanguageLocaleKey, u.UserRole.Name, u.UserRoleId, u.Name, u.Contact.Name, u.Contact.FirstName, 
            u.Contact.LastName, u.Contact.AccountId, u.Contact.Is_Authorized_Contact__c, u.ContactId, u.AccountId 
            From User u where Id =: UserInfo.getUserId()];
    
    Id userContactId = usrList[0].ContactId;
    
    /* news records on home page */
    public List<Marketo_News__c> getNewsList(){
        List<Marketo_News__c> newsRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Publish_Date__c 
        from Marketo_News__c where Type__c = :NEWS and Active__c = true Order By Publish_Date__c DESC Limit 3];      
        return newsRecordList ;
    }
    
    /* news records on news and initiatives page */
    public PageReference queryNewsRecords(){
     System.debug('===newsLimit =====>>>>>>>'+newsLimit );
        if(newsLimit != null) {
            newsRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Publish_Date__c 
            from Marketo_News__c where Type__c = :NEWS and Active__c = true Order By Publish_Date__c DESC limit :newsLimit];
            newsLimit = null;
            newsShowMore = true;
        } else {
            newsRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Publish_Date__c 
            from Marketo_News__c where Type__c = :NEWS and Active__c = true Order By Publish_Date__c DESC];            
            newsShowMore = False;
        }
        return null;
    }    
    /* query alert shown on home page */
    /*
    public List<Marketo_News__c> getAlertList(){
        List<Marketo_News__c> alertRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, POD__c 
        from Marketo_News__c where Type__c = :ALERT and Active__c = true Order By CreatedDate Limit 1];
        return alertRecordList;
    }*/
    public List<Marketo_News__c> getAlertList(){
        List<Marketo_News__c> alertRecordList = new List<Marketo_News__c> ();        
        alertRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c,POD__c 
        from Marketo_News__c where Type__c = :ALERT and Active__c = true and POD__c = NULL Order By CreatedDate Limit 1];
        if(myPodName != null && myPodName.trim() != '') {
            string tmpPodName = myPodName;
            List<Marketo_News__c> alertRecordList2 = [select id, Name, Description__c, Type__c, Image__c, Link__c, POD__c 
            from Marketo_News__c where Type__c = :ALERT and Active__c = true AND POD__c includes (:tmpPodName) Order By CreatedDate Limit 1];                    
            if(!alertRecordList2.IsEmpty()){
                System.debug('alertRecordList2===>' + alertRecordList2);
                alertRecordList.addAll(alertRecordList2);
            }
        }                        
        System.debug('alertRecordList===>' + ALERT +  alertRecordList);        
        return alertRecordList;
    }    
    
    
    
    
    // steffi update this on 26 oct
    public PageReference toggleSubscription() {
        try{           
            // Delete existing subscription if there is one.
            Community_Subscription__c subscription = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'News and Alerts'];
            delete subscription;            
        }catch (Exception e) {
            Community_Subscription__c subscription = new Community_Subscription__c();
            subscription.User__c = UserInfo.getUserId();
            subscription.Type__c = 'News and Alerts';           
            insert subscription;
        }
        return null;
    }
    public PageReference toggleSubscriptionLink() {
        try {
            // Delete existing subscription if there is one.
            Community_Subscription__c subscription = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'News and Alerts'];
            delete subscription;
        }catch (Exception e) {
            // An exception is thrown if no subscription exists yet.
            // Setup subscription.
            Community_Subscription__c subscription = new Community_Subscription__c();
            subscription.User__c = UserInfo.getUserId();
            subscription.Type__c = 'News and Alerts';
            insert subscription;
        }
         pageReference pr= new pageReference('/apex/MarketoCommunityProfileEditSubscriptions');
            pr.setRedirect(true);
            return pr;
    }
    /* check whether alert record exist or not */
    public Boolean getAlertExist() {
        Boolean alertExist;
        List<Marketo_News__c> alertRecordList = new List<Marketo_News__c> ();        
        alertRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c,POD__c 
        from Marketo_News__c where Type__c = :ALERT and Active__c = true and POD__c = NULL Order By CreatedDate Limit 1];
        if(myPodName != null && myPodName.trim() != '') {
            string tmpPodName = myPodName;
            List<Marketo_News__c> alertRecordList2 = [select id, Name, Description__c, Type__c, Image__c, Link__c, POD__c 
            from Marketo_News__c where Type__c = :ALERT and Active__c = true AND POD__c includes (:tmpPodName) Order By CreatedDate Limit 1];                    
            if(!alertRecordList2.IsEmpty()){
                System.debug('alertRecordList2===>' + alertRecordList2);
                alertRecordList.addAll(alertRecordList2);
            }
        }                        
        System.debug('alertRecordList===>' + ALERT +  alertRecordList);        
        if(alertRecordList != null && alertRecordList.size() > 0) {
            alertExist = true;
        }        
        return alertExist;
    }
    
    /* query customer hero awards shown on right component */
    public List<Marketo_News__c> getCustomersList(){
    /*  commented by vishals@grazitti.com on 03-08-12
        List<Marketo_News__c> customerRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Quarter__c 
        from Marketo_News__c where Type__c = :CUSTOMER and Active__c = true Limit 2];
    */
        List<Marketo_News__c> customerRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Quarter__c 
        from Marketo_News__c where Type__c = :CUSTOMER and Active__c = true order by Quarter__c Desc Limit 2];      
        return customerRecordList;
    }
    
    /* query last 4 quarters customer hero awards */
    /*public List<Marketo_News__c> getCustomersRecordsList(){
        List<Marketo_News__c> customerRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Quarter__c 
        from Marketo_News__c where Type__c = :CUSTOMER and Active__c = true and CreatedDate > LAST_N_QUARTERS:4];
        return customerRecordList;
    }*/
    
    /* query last 4 quarters customer hero awards */
    public List<Marketo_News__c> getCustomersRecordsList(){
        /* commented by vishals@grazitti.com on 03-08-12
        List<Marketo_News__c> customerRecordList = [select id, Name, Description__c, Publish_Date__c, Type__c, Image__c, Link__c, Quarter__c 
        from Marketo_News__c where Type__c = :CUSTOMER and Active__c = true ORDER BY Publish_Date__c Desc];
        */
        List<Marketo_News__c> customerRecordList = [select id, Name, Description__c, Publish_Date__c, Type__c, Image__c, Link__c, Quarter__c 
        from Marketo_News__c where Type__c = :CUSTOMER and Active__c = true ORDER BY Quarter__c Desc limit 4];       
        return customerRecordList;
    }
        public List<SupportTeam> getTeamTypeToObjectmap(){
        Map<String,String> urlSupportNameToActualNameMap = new Map<String,String>();
        
        urlSupportNameToActualNameMap.put('SupportLeadership','Support Leadership');
        urlSupportNameToActualNameMap.put('SanMateo','San Mateo');
        urlSupportNameToActualNameMap.put('Portland','Portland');
        urlSupportNameToActualNameMap.put('APAC','APAC');
        urlSupportNameToActualNameMap.put('EMEA','EMEA');
        
        supportTeamList = new List<SupportTeam>();
        List<Support_Teams__c> tempsupportTeamList = [select id, Name, Description__c, Type__c, Image__c,Position__c,Active__c 
        from Support_Teams__c Where Active__c = true And Type__c = : urlSupportNameToActualNameMap.get(ApexPages.currentPage().getUrl().replace('/apex/MarketoSupportHome_','')) ];
        typeOfMember = urlSupportNameToActualNameMap.get(ApexPages.currentPage().getUrl().replace('/apex/MarketoSupportHome_',''));
        Map<String,List<Support_Teams__c>> suppTypeToObject = new Map<String,List<Support_Teams__c>>();
        System.debug('tempsupportTeamList.size('+tempsupportTeamList.size());
        System.debug('tempsupportTeamLis'+tempsupportTeamList);   
        for(Support_Teams__c suppTeam : tempsupportTeamList){  
            System.Debug('suppTeam.Position__c+++++'+suppTeam.Position__c);
            integer position = suppTeam.Position__c == null?0:suppTeam.Position__c.intValue();
            supportTeamList.add(new SupportTeam(suppTeam.Image__c, suppTeam.Name, suppTeam.Description__c, position, suppTeam.id, suppTeam.Type__c));    
        }
        supportTeamList.sort();
        return supportTeamList;
    }
     
    global  class SupportTeam implements Comparable{
        public String  urlForImage{get;set;}
        public String  memberName{get;set;}
        public String  memberDesc{get;set;}
        public Integer position{get;set;}
        public String  id{get;set;}
        public String  Type{get;set;}
        public Boolean isActive{get;set;}
        
        //Constructor  
        public SupportTeam(String urlForImage,String memberName,String memberDesc,Integer position, String Id, String type){
            this.urlForImage    = urlForImage;
            this.memberName     = memberName;
            this.memberDesc     = memberDesc;
            this.position       = position;
            this.id             = Id;
            this.type           = type;

        }
        public SupportTeam(){
        
        }
        global integer compareTo(Object compareToItem) {
            SupportTeam compareToPos = (SupportTeam)compareToItem;
            if (this.position >= compareToPos.Position) {
                 return 1;
            } else {
                 return -1;                    
            }
        }  
    }
    
    

    
    /* initiatives records on news and initiatives page */
    public PageReference queryInitiativeRecords(){
        if(initiativeLimit != null) {
            initiativesRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Publish_Date__c  
            from Marketo_News__c where Type__c = :INITIATIVES and Active__c = true Limit :initiativeLimit];
            initiativeLimit = null;
             newsShowMore = true;
        } else {
            initiativesRecordList = [select id, Name, Description__c, Type__c, Image__c, Link__c, Publish_Date__c  
            from Marketo_News__c where Type__c = :INITIATIVES and Active__c = true];
             newsShowMore = false;
        }
        return null;
    }
    public Boolean getSubscribedToCurrentCategory() {
        return (Database.countQuery('select count() from Community_Subscription__c where User__c = \'' + UserInfo.getUserId() + '\' and Type__c = \'News and Alerts\'') > 0);
    }
    
    /* query cases shown on hom page */
    public List<Case> getMyCasesList(){
        List<Case> caseRecordList = [Select c.Subject, c.Status,c.Case_Status__c, c.Description, c.CaseNumber From Case c 
        where ContactId = :userContactId and isClosed = false Order By LastModifiedDate DESC Limit 4];
        return caseRecordList;
    } 
            public Map<Decimal,Support_Quick_Access_Gallery__c> getSupportArticlesToLeft(){
        List<Support_Quick_Access_Gallery__c> supportArticleList   = [Select Name_Of_The_Article__c,Url_For_Article__c,Sort_Order__c From Support_Quick_Access_Gallery__c 
        where Is_Featured_Article__c = false AND Sort_Order__c < 6 Limit 5];
        System.Debug('supportArticleList'+supportArticleList);
        sortOrderToArtNameFirstFive = new Map<Decimal,Support_Quick_Access_Gallery__c>();
        for(Support_Quick_Access_Gallery__c tempStr: supportArticleList ){
            sortOrderToArtNameFirstFive.put(tempStr.Sort_Order__c,tempStr);
        }
        return sortOrderToArtNameFirstFive;
    }
    public Map<Decimal,Support_Quick_Access_Gallery__c> getSupportArticlesToRight(){
        List<Support_Quick_Access_Gallery__c> supportArticleList   = [Select Name_Of_The_Article__c,Url_For_Article__c,Sort_Order__c From Support_Quick_Access_Gallery__c 
        where Is_Featured_Article__c = false AND Sort_Order__c > 5 Limit 5];
        System.Debug('supportArticleList'+supportArticleList);
        sortOrderToArtNameLastFive = new Map<Decimal,Support_Quick_Access_Gallery__c>();
        for(Support_Quick_Access_Gallery__c tempStr: supportArticleList ){
            sortOrderToArtNameLastFive.put(tempStr.Sort_Order__c,tempStr);
        }
        return sortOrderToArtNameLastFive;
    }    
    public List<Support_Quick_Access_Gallery__c> getFeaturedArt(){
        List<Support_Quick_Access_Gallery__c> featuredSuppArticles = [Select Name_Of_The_Article__c,Url_For_Article__c,Description__c,Featured_Support_Image__c From Support_Quick_Access_Gallery__c 
        where Is_Featured_Article__c = true Limit 3];
        
        System.Debug('featuredSuppArticles'+featuredSuppArticles);
        return featuredSuppArticles; 
    }

    Public string getCSatSurveyMonth(){
       List<CSatAdminPanelData__c> CSatSurveyList = [SELECT Month__c, CSatPercentage__c  FROM CSatAdminPanelData__c LIMIT 1];
        If (CSatSurveyList.size() > 0){ 
            CSatMonth = CSatSurveyList[0].Month__c;
        }
        return CSatMonth;            
    }
    
    Public string getCSatSurveyPercentage(){
        List<CSatAdminPanelData__c> CSatSurveyList = [SELECT Month__c, CSatPercentage__c  FROM CSatAdminPanelData__c LIMIT 1];
        If (CSatSurveyList.size() > 0){ 
            CSatPercentage = CSatSurveyList[0].CSatPercentage__c ;
        }
        return CSatPercentage ;    
    }
   
}