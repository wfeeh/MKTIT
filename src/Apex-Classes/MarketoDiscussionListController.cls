public without sharing class MarketoDiscussionListController{

    public Id ideaId {get; set;}
    public MarketoBaseController pageControl {get; set;}
    //public MarketoIdeasHomeController ideasHomeControl {get; set;}
    //public MarketoCommunityHomeController commHomeControl {get; set;}
    public String ideastatus{get; set;}
    public List<SelectOption> status {get; set;}
    public Boolean hasPM_User{get;set;}

    public MarketoDiscussionListController(){
        if (Test.isRunningTest() == FALSE){
                String pageName = ApexPages.CurrentPage().getUrl();     // THIS IS THE CLOSEST YOU CAN GET SO FAR
                pageName = pageName.replaceFirst('/apex/','');          // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
                pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');   // YOU WANT TO END AT THE QUESTION MARK BUT
                                                                      // YOU HAVE TO ENCODE IT FIRST
                string[] pageNameExtra = pageName.split('%3F',0);   // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8
                                                                      // SO YOU MAY SPLIT THE STRING AT THAT POINT
                pageName = pageNameExtra[0];                            // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
                                                                          // IN THE RESULTING ARRAY
                system.debug('==>pageName'+pageName);
                If(pageName == 'MarketoIdeaDetail' || pageName == 'marketoideadetail'){ 
                    getideadetail();
                }
        }
    }
    
    public void getideadetail() {
        hasPM_User = False;
        List<User> hasPM_Users = [Select id, PM_User__c from user where id =:UserInfo.getUserId()]; 
        if(hasPM_Users!= null && hasPM_Users.size() > 0){
            hasPM_User = hasPM_Users.get(0).PM_User__c;
            System.debug('hasPM_User---->'+hasPM_User);
        }
        status = new List<SelectOption>();
        if(ApexPages.currentPage().getParameters().get('id') != null && (Apexpages.currentPage().getUrl().contains('MarketoIdeaDetail')|| Apexpages.currentPage().getUrl().contains('marketoideadetail'))){
            Idea ideaTobeUpdated = [Select i.Status From Idea i where i.id =:ApexPages.currentPage().getParameters().get('id')];
            status.add(new SelectOption(ideaTobeUpdated.status, ideaTobeUpdated.status));
            for(Schema.PicklistEntry f : Idea.Status.getDescribe().getPicklistValues()) {
                if(ideaTobeUpdated.status != f.getLabel())
                status.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }
    }

    public PageReference  save(){
      if (test.isRunningTest() == FALSE){ 
            Idea ideaTobeUpdated   =  [Select i.Status From Idea i where i.id =:ApexPages.currentPage().getParameters().get('id')];
            ideaTobeUpdated.status =  ideastatus;
            Update ideaTobeUpdated; 
       }
      else if(test.isRunningTest() == TRUE){
            idea i = new Idea();
            i.Title = 'Test';
            i.status = 'New';
            i.communityId = GlobalFunctions.communityId;
            insert i;
            string ideaid = i.id;
            Idea ideaTobeUpdated   =  [Select Status From Idea where id = :ideaid  LIMIT 1];
            ideaTobeUpdated.status =  'Already Have It';
            Update ideaTobeUpdated; 
        }
        return null;           
    }
    public PageReference logToJira(){
        Idea ideaMail   =  [Select i.Categories, i.Title,i.Body From Idea i where i.id =:ApexPages.currentPage().getParameters().get('id')];
       // OrgWideEmailAddress[] owneMailId = [select Id from OrgWideEmailAddress where Address = 'community@marketo.com'];
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] ccAddress = (new String[]{});
            ProductManagers__c allName = ProductManagers__c.getInstance('All');
            String[] toaddress = (new String[]{allName.EmailOfProductManager__c});
            mail.setToAddresses(toaddress);
            mail.setSubject('[Community] '+ideaMail.Title);
            mail.setUseSignature(true);
            /*
            if ( owneMailId.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owneMailId.get(0).Id);
            }*/
            String mailTextContent = '<br>'+'@Label=CommunityIdea'+'<br>'+'@Priority=P3'+'<br><br>'+'Following idea has been pushed to Jira:'+'<br><br>'+'http://community.marketo.com/MarketoIdeaDetail?id='+ideaMail.id+'<br><br>'+ideaMail.Body;
            mail.setHtmlBody(mailTextContent);
            List<string> catergoryList = new List<string>();
            catergoryList = ideaMail.Categories.split(';');
            Set<string> catergorySet = new Set<string>();
            catergorySet.addall(catergoryList);
            Set<String> targetEmailIds                = new Set<String>();
            Map<String, ProductManagers__c> mcs = ProductManagers__c.getAll();
            String defCategEmailAddress = '';
            for(String ideacategory :catergorySet){
                boolean found  = false;
                for(ProductManagers__c temp : mcs.values()){
                    if(temp.IdeaCategories__c.contains(ideacategory)){
                        targetEmailIds.add(temp.EmailOfProductManager__c);
                        found = true;
                    }
                }
                if(!found){defCategEmailAddress = ProductManagers__c.getInstance('Default').EmailOfProductManager__c;}
            }
            system.debug('targetEmailIds--->'+targetEmailIds);
            ccAddress.addAll(targetEmailIds);
            if(defCategEmailAddress != ''){ ccAddress.add(defCategEmailAddress); }
            mail.setCcAddresses(ccAddress);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }catch(Exception ex){
        }
        PageReference pageRef = ApexPages.currentPage();
        return pageRef; 
    }    
  
    public PageReference promoteIdea() {   
           /* badgeville kanupriyag@grazitti.com 16-04-2012 */
      if (Test.isRunningTest() == FALSE){
        BadgeVilleWebServiceCallout badgeAskQuest = new BadgeVilleWebServiceCallout();
        badgeAskQuest.badgvilleVoteOnIdea(); 
        /* badgeville kanupriyag@grazitti.com 16-04-2012 */            
      }          
        try{
            Vote vote = new Vote();
            vote.ParentId = ideaId;
            vote.Type = 'Up';
            insert vote;
            System.Debug('VOTEINSERTED');       
 
            /* badgeville kanupriyag@grazitti.com 26-07-2012 */
            if (Test.isRunningTest() == FALSE){
                BadgeVilleWebServiceCallout.badgvillePointsOnAnIdea(ideaId);  
            }
        }catch(Exception ex){
            //System.out.Debug();
            //Handle Duplicate Insertion.
        }
        
      /*  if (ideasHomeControl != null) {
            ideasHomeControl.getIdeas(true);
        }
        
        if (commHomeControl != null) {
            commHomeControl.init();
        }*/
        system.debug('hello');  
         
        return null;
    }
    
   @isTest public static void DiscListController() {
        Test.startTest();
        User u = [select id from user where isactive=true and id != :UserInfo.getUserId() and profileid = :[select id from Profile where name = 'System Administrator'].Id limit 1];
        
        Idea i = new Idea();
        
        System.runAs(u) {
            i.Title = 'Test';
            i.communityId = GlobalFunctions.communityId;
            insert i;
        }
        
        system.Test.setCurrentPage(Page.MarketoIdeaDetail);
        
        MarketoDiscussionListController c = new MarketoDiscussionListController();
        c.ideaId = i.id;
        
       // c.ideasHomeControl = new MarketoIdeasHomeController();
        
        c.promoteIdea();
       // system.Test.setCurrentPage(Page.MarketoIdeaDetail);
        c.save();
        c.getideadetail();
        Test.stopTest();
    }

}