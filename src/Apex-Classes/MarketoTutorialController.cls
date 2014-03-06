public class MarketoTutorialController  {

    public Map<String,MarketoDeepDive__kav> deepDiveCatgsOfTut {get; set;}
    public String category{get;set;}

    public CommentWrapper comment{get;set;}
    public String tutorialId;
    public Boolean showTutorialViewCount{get;set;}
    public Integer tutorialViewsCount{get;set;}   
    
    public String TextContent{get;set;}

    public MarketoTutorialController(ApexPages.StandardController stdController) {
        TextContent = '';
        PageReference pageRef = ApexPages.currentPage();
        tutorialId = ApexPages.currentPage().getParameters().get('Id');

        //Id tutorialId = ApexPages.currentPage().getParameters().get('Id');
        Tutorial__kav currTutorialSoql = [select Id, IsVisibleInPkb, Title, knowledgeArticleId, Language, LastPublishedDate from Tutorial__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online' and Language='en_US' limit 1];

        try{
             User loggedUser =  new User();
            if(Test.IsRunningTest())
             loggedUser  = [Select id, email, name, contact.account.name from User where isPortalEnabled = true and isActive = true LIMIT 1];
        else
            loggedUser = [Select id, email, name from User where  Id=:UserInfo.getUserId() and isPortalEnabled = true and Is_Employee__c = true LIMIT 1];
            tutorialViewsCount = 0;
            if (loggedUser != null) {
                showTutorialViewCount = true;
                // Fetch the article view count
                List<KnowledgeArticleViewStat> KnowledgeTutorialViewStatList = [SELECT Id,ParentId,Channel,ViewCount FROM KnowledgeArticleViewStat where ParentId =:tutorialId LIMIT 5];
                for(KnowledgeArticleViewStat knbTutViewStat : KnowledgeTutorialViewStatList){
                    if(knbTutViewStat.Channel == 'App') {  
                        tutorialViewsCount += knbTutViewStat.ViewCount;
                        //system.debug('==Internalcount=='+Internalcount);
                    }
                    if(knbTutViewStat.Channel == 'Csp'){
                        tutorialViewsCount += knbTutViewStat.ViewCount;
                        //system.debug('==Customercount =='+Customercount );   
                    }
                }                
            } else {
                showTutorialViewCount = false;
            }
        } catch(Exception ex) {   }  

        comment = new CommentWrapper();

        comment.title = currTutorialSoql.Title;

        /* Link article categories to deepdive articles */       
        List<MarketoDeepDive__kav> deepDiveArticles = [select KnowledgeArticleId, Title from MarketoDeepDive__kav where Language = 'en_US' and publishstatus='Online' and DeepDiveCategory__c != null];
        System.Debug('deepDiveArticles+++++'+deepDiveArticles);
        List<Tutorial__DataCategorySelection> currentTutDataCatList = [Select ParentId, Id, DataCategoryName, DataCategoryGroupName From Tutorial__DataCategorySelection Where ParentId =:currTutorialSoql.Id];
        System.Debug('currentArtDataCatList+++++'+currentTutDataCatList);
        Map<String,MarketoDeepDive__kav> deepDiveTitlesToLinks = new Map<String,MarketoDeepDive__kav>();
        
        for(MarketoDeepDive__kav tempdeepDiveObj : deepDiveArticles ){
            deepDiveTitlesToLinks.put(tempdeepDiveObj.title,tempdeepDiveObj);
        }
       
        deepDiveCatgsOfTut = new Map<String,MarketoDeepDive__kav>();
        
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        
        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');
        pair1.setDataCategoryGroupName('Articles');
        
        pairs.add(pair1);
        
        List<Schema.DescribeDataCategoryGroupStructureResult> results = Schema.describeDataCategoryGroupStructures(pairs, false);       
        DataCategory[] topCategs = results.get(0).getTopCategories().get(0).getChildCategories();
        DataCategoryHelper helper = DataCategoryHelper.getHelper('KnowledgeArticleVersion');
        
        for (Tutorial__DataCategorySelection tempCatgry : currentTutDataCatList){
            String catgLabel = helper.getNameToLabelMap().get(tempCatgry.DataCategoryName);
            String parentCateg = helper.getTopCategory(topCategs, tempCatgry.DataCategoryName, 'All');
            if (deepDiveTitlesToLinks.containsKey(catgLabel)){
                deepDiveCatgsOfTut.put(catgLabel, deepDiveTitlesToLinks.get(catgLabel)); 
            }
            if (deepDiveTitlesToLinks.containsKey(parentCateg)) {
                /*deepDiveCatgsOfTut.put(catgLabel, deepDiveTitlesToLinks.get(parentCateg)); ONLY PARENT CATEGS REQUIRED NOW*/
                deepDiveCatgsOfTut.put(parentCateg, deepDiveTitlesToLinks.get(parentCateg));       
            }
        }
        System.debug('size====='+deepDiveCatgsOfTut.size());
        If (deepDiveCatgsOfTut.size()== 0) {
            String categLabel = '';
            if (currentTutDataCatList.size() > 0) {
              categLabel = helper.getNameToLabelMap().get(currentTutDataCatList.get(0).DataCategoryName);
              category = categLabel == null?currentTutDataCatList.get(0).DataCategoryName:categLabel;
            }
        }
        System.Debug('Category============='+category);
        /* Link article categories to deepdive articles */   
        
        try {
            User loggedUser1 =  new User();
            if(Test.IsRunningTest())
                loggedUser1 = [Select id, email, name, contact.account.name from User where isPortalEnabled = true and isActive = true LIMIT 1];
            else
                loggedUser1 = [Select id, email, name, contact.account.name from User where Id=:UserInfo.getUserId() and isPortalEnabled = true LIMIT 1];
            if (loggedUser1 != null) {
                PageReference pg = Page.MarketoCommunityProfile;                     
                pg.getParameters().put('Id', loggedUser1.Id);
                String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();                       
                TextContent += '\n\nPosted By: ' + loggedUser1.name;
                String hostname = ApexPages.currentPage().getHeaders().get('Host');
                String currURL ='';
                Map<String,String> headerInfo = new Map<String,String>();
                headerInfo = ApexPages.currentPage().getHeaders();
                if(headerInfo.containsKey('CipherSuite'))
                    currURL = 'https://' + hostname + pg.getURL();                 
                else 
                    currURL =  'http://' + hostname + pg.getURL();                              
                TextContent += '\n\nProfile: ' + currURL;            
                TextContent += '\n\nAccount: ' + loggedUser1.contact.account.name;
                TextContent += '\n\nKnowledgebase Article: ' + currentRequestURL;                                                            
                System.debug('TestContest==>' + TextContent); 
            }  
        } catch(Exception ex) {
            System.Debug('Exception==>' + ex); 
        }
            
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); return options; 
    }  
    
    public pageReference sendEmail(){

        //create a mail object to send email 
        String msg2 = 'Please enter your Feedback';
        Article_FeedBack__c myFeedbackDetails = new Article_FeedBack__c();
        comment.body = comment.body.trim();
        System.Debug('commentISEffective'+comment.isEffective);
        myFeedbackDetails.Is_Article_Effective__c = true;
        if(comment.body == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2 ));
            return null;
        }           
      
        if(comment.body != '') {
            //Comment Section
            myFeedbackDetails.Comment_On_Article__c = comment.body; // __WILL_FIX_IT_LATER__            
            myFeedbackDetails.Article_Name__c       = comment.Title;
            myFeedbackDetails.Article_Url__c        = 'http://community.marketo.com/MarketoTutorial?id='+ApexPages.currentPage().getParameters().get('Id');
            myFeedbackDetails.Article_Id__c         = ApexPages.currentPage().getParameters().get('Id');
            List<Tutorial__kav> ArticleDetail = [SELECT Id, KnowledgeArticleId, Article_Version__c FROM Tutorial__kav where PublishStatus ='Online' and KnowledgeArticleId = :myFeedbackDetails.Article_Id__c]; 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            //String[] toaddress = (new String[]{'muditg@grazitti.com'});
            String[] toaddress = (new String[]{'articlefeedback@marketo.com'});
            
            //email properties
            mail.setToAddresses(toaddress );
            if(ArticleDetail[0].Article_Version__c == null){
                    ArticleDetail[0].Article_Version__c = 'V1';
            }
            mail.setSubject(ArticleDetail[0].Article_Version__c+' - ' +'Knowledge Base Feedback - '+comment.title);
            //mail.setSubject('Knowledge Base Feedback : '+comment.title);
            mail.setUseSignature(true);
            //mail.setPlainTextBody('Following feedback has been submitted on Marketo knowledgebase:'+'\n\n'+'Title:  '+comment.title+'\n\n'+'Comment: '+ comment.body); 
            String mailTextContent = 'Following feedback has been submitted on Marketo knowledgebase:'+'\n\n'+'Title: '+comment.title+'\n\n'+'Comment: '+ comment.body;
            mailTextContent += TextContent;
            mail.setPlainTextBody(mailTextContent);   
            
            insert myFeedbackDetails;                
            //BadgeVillePoints
            BadgeVilleWebServiceCallouts.badgvilleGiveAFeedback(tutorialId);                
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Thank you for submitting the feedback'));
         } else {
            //system.debug('====artFeedbackOpt===='+tutFeedbackOpt);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2 ));
            return null;
        }
        return null;
       //return(redirectToTutorial());       
   }  
  
   public class CommentWrapper {
       public String id          {get;set;}
       public String url         {get;set;}
       public String body        {get;set;}
       public String title       {get;set;}
       public String isEffective {get;set;}
       public String subject     {get;set;}
   }
    
    
    
}