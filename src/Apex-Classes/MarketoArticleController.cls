public class MarketoArticleController  {
    
    public String category {get; set;}
    public Map<String,MarketoDeepDive__kav> deepDiveCatgsOfArt {get; set;}
    public Article__kav article {get; set;}
    public Boolean showArticleViewCount{get;set;}
    public Integer articleViewsCount{get;set;}
    public LanguageWrapper lang{get;set;}
    public CommentWrapper comment{get;set;} 
    public Boolean toperrmsg{get;set;}
    public String preferredLanguage{get;set;}
    Public Map<String,String> languageKeyToLabel = new Map<String,String>{'en_US'=>'English','fr'=>'French','de'=>'German','pt_BR'=>'Portuguese','es'=>'Spanish'};   
    Public Map<String,String> labelTolangKey = new Map<String,String>{'English'=>'en_US','French'=>'fr','German'=>'de','Portuguese'=>'pt_BR','Spanish'=>'es'};
    public MarketoArticleController(ApexPages.StandardController stdController) {
    
        toperrmsg = false;
        comment = new CommentWrapper ();
        lang = new LanguageWrapper ();
        comment.TextContent = ' ';
        PageReference pageRef = ApexPages.currentPage();
        //comment.artFeedbackUrl = pageRef.geturl();                   
        System.debug('stdController->' + stdController);   
        showArticleViewCount = false;    
        articleViewsCount = 0;        
        list<Article__kav> currentArticle  = [select id, Language, title, SubTitle__c,Article_Text__c, LastPublishedDate, Add_File__Name__s from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online'];
        lang.langShow = false;
        if(currentArticle.size() > 1){
            string preferredLanguageName ='';  
            lang.langShow = true;
            Map<String, String> labelToUniqueCurrentArticle = new Map<String, String>();
            for(Article__kav temp :  currentArticle ){
                labelToUniqueCurrentArticle.put(languageKeyToLabel.get(temp.Language),temp.Language);
            }
            user usr = [select id, contactid from user where id=:UserInfo.getUserId()];
            list<Contact> con = [select id , Preferred_Language__c from contact where id=:usr.contactid limit 1];
            if(con.size() > 0){
                preferredLanguage = con[0].Preferred_Language__c;
                system.debug('preferredLanguage-->'+preferredLanguage);
                if(preferredLanguage != null){
                    if(labelToUniqueCurrentArticle.containsKey(preferredLanguage)){
                         preferredLanguageName = labelTolangKey.get(preferredLanguage);
                    }else{
                       preferredLanguageName = labelTolangKey.get('English');
                    }
                }else{
                    preferredLanguage = 'English';
                    if(labelTolangKey.containsKey(preferredLanguage)){
                    preferredLanguageName = labelTolangKey.get(preferredLanguage); 
                    } 
                }
            }
            article = new Article__kav();
            list<Article__kav> changeArticle = [select id, language, title, SubTitle__c,Article_Text__c, LastPublishedDate, Add_File__Name__s from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online' and language = :preferredLanguageName limit 1];
            article.title = changeArticle [0].title;
            article.Article_Text__c = changeArticle [0].Article_Text__c;
            article.SubTitle__c = changeArticle [0].SubTitle__c;
            article.language =  changeArticle [0].language;
            article.Add_File__Name__s = changeArticle [0].Add_File__Name__s; 
            comment.subject = changeArticle[0].title;
            comment.artFeedbackTitle = changeArticle[0].title;
        }
        else{
            article = new Article__kav();
                if(currentArticle[0].language == 'en_US') {
                    article.title = currentArticle[0].title;
                    article.Article_Text__c = currentArticle[0].Article_Text__c;
                    article.SubTitle__c = currentArticle[0].SubTitle__c;
                    article.language =  currentArticle[0].language;
                    article.Add_File__Name__s = currentArticle[0].Add_File__Name__s; 
                    comment.subject = currentArticle[0].title;
                    comment.artFeedbackTitle = currentArticle[0].title;
                }
        }       
        try {
            User loggedUser =  new User();
            if(Test.IsRunningTest())
                loggedUser  = [Select id, email, name, contact.account.name from User where  isPortalEnabled = true and Is_Employee__c = true LIMIT 1];
            else {
                loggedUser  = [Select id, email, name, contact.account.name from User where  Id=:UserInfo.getUserId() and isPortalEnabled = true and Is_Employee__c = true LIMIT 1];
            }
            if (loggedUser != null) {
                
 
                showArticleViewCount = true;
                // Fetch the article view count
                List<KnowledgeArticleViewStat> KnowledgeArticleViewStatList = [SELECT Id,ParentId,Channel,ViewCount FROM KnowledgeArticleViewStat where ParentId =:ApexPages.currentPage().getParameters().get('Id') LIMIT 5];
                //system.debug('====KnowledgeArticle==='+KnowledgeArticle); 
                for(KnowledgeArticleViewStat knbArtViewStat : KnowledgeArticleViewStatList){
                    if(knbArtViewStat.Channel == 'App') {  
                        articleViewsCount += knbArtViewStat.ViewCount;
                        //system.debug('==Internalcount=='+Internalcount);
                    }
                    if(knbArtViewStat.Channel == 'Csp'){
                        articleViewsCount += knbArtViewStat.ViewCount;
                        //system.debug('==Customercount =='+Customercount );   
                    }
                }                            
            }                
            
 
            
        } catch(Exception ex) {
        
        }       
          
        
        System.debug('article --> '+ApexPages.currentPage().getParameters().get('Id'));
        List<Article__kav> articleListNew = [select  IsVisibleInPkb ,id, Article_Text__c from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online'];
        init();
        /* 29-04-11 vishals@grazitti.com Added below code to parse pkb articles*/
        if(ApexPages.currentPage().getUrl().toLowerCase().contains('marketopkbarticle')){
            List<Article__kav> articleList = [select  IsVisibleInPkb ,id, Article_Text__c from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online'];
            
            if(articleList != null && articleList.size() > 0)
                replaceLinks(articleList[0]);
        }      
              
        try 
        {                    
            User loggedUser1 =  new User();
            if(Test.IsRunningTest())
                loggedUser1  = [Select id, email, name, contact.account.name from User where isPortalEnabled = true LIMIT 1];
            else
                loggedUser1  = [Select id, email, name, contact.account.name from User where  Id=:UserInfo.getUserId() and isPortalEnabled = true LIMIT 1];
            if (loggedUser1 != null) 
            {
                PageReference pg = Page.MarketoCommunityProfile;                     
                pg.getParameters().put('Id', loggedUser1.Id);
                String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();                       
                comment.TextContent += '\n\nPosted By: ' + loggedUser1.name;
                String hostname = ApexPages.currentPage().getHeaders().get('Host');
                String currURL ='';
                Map<String,String> headerInfo = new Map<String,String>();
                headerInfo = ApexPages.currentPage().getHeaders();
                if(headerInfo.containsKey('CipherSuite'))
                    currURL = 'https://' + hostname + pg.getURL();                 
                else 
                    currURL =  'http://' + hostname + pg.getURL();                              
                comment.TextContent += '\n\nProfile: ' + currURL;   
                comment.TextContent += '\n\nAccount: ' + loggedUser1.contact.account.name;            
                comment.TextContent += '\n\nKnowledgebase Article: ' + currentRequestURL;                                                            
                System.debug('TextContent==>' + comment.TextContent);    
            }     
        } catch(Exception ex) {
            System.Debug('Exception==>' + ex);        
        }                      
        
 
 
    }
    
    public List<SelectOption> getpreferredLanguageOfArticle(){
        List<SelectOption> langOfArticle = new List<SelectOption>();
        List<String> langDropDownList  = new List<String>();
       // Map<String, Article_kav> langKeyToArticleMap = new  Map<String, Article_kav>();
        list<Article__kav> currentArticle  = [select id, Language, title, SubTitle__c,Article_Text__c, LastPublishedDate, Add_File__Name__s from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online'];
        if(currentArticle.size() > 1){
           for(Article__kav temp :  currentArticle ){
               langDropDownList.add(languageKeyToLabel.get(temp.Language));
           } 
           langDropDownList.sort();
           for(String langSelectionList : langDropDownList){
               langOfArticle.add(new SelectOption(langSelectionList ,langSelectionList ));
           }
        }
        return langOfArticle; 
    }
    
    public pageReference langSpecificArticle(){
        article = new Article__kav();
        system.debug('preferredLanguage-->'+preferredLanguage);
        string preferredLanguageName =''; 
        if(labelTolangKey.containsKey(preferredLanguage)){
            preferredLanguageName = labelTolangKey.get(preferredLanguage);
        }
        system.debug('preferredLanguageName-->'+preferredLanguageName);
        list<Article__kav> changeArticle = [select id, language, title, SubTitle__c,Article_Text__c, LastPublishedDate, Add_File__Name__s from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online' and language = :preferredLanguageName limit 1];
        if(changeArticle.size() >0){
        article.title = changeArticle [0].title;
        article.Article_Text__c = changeArticle [0].Article_Text__c;
        article.SubTitle__c = changeArticle [0].SubTitle__c;
        article.language =  changeArticle [0].language;
        article.Add_File__Name__s = changeArticle [0].Add_File__Name__s; 
        comment.subject = changeArticle[0].title;
        comment.artFeedbackTitle = changeArticle[0].title;
        user usr = [select id, contactid, contact.Preferred_Language__c from user where id=:UserInfo.getUserId()];
        contact contant = [select id, Preferred_Language__c from contact where id=:usr.contactid];
        list<Community_Profile__c > con = [select id , user__r.contact.Preferred_Language__c, user__c from Community_Profile__c where user__c=:UserInfo.getUserId() limit 1];
          if(con.isEmpty()){
             Community_Profile__c cmmPrf = new  Community_Profile__c();
               cmmPrf.user__c  =  UserInfo.getUserId();
               insert cmmPrf ;
          }
          contant.Preferred_Language__c = preferredLanguage;
          update contant; 
          
        }
        return null;
    } 
     
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); return options; 
    }
   
    /* 29-04-11 vishals@grazitti.com Added below code to parse pkb articles*/
    public void replaceLinks(Article__kav article){
        String peopleRegex = '<a(.*?)>'; 
        Pattern MyPattern = Pattern.compile(peopleRegex);
        String articleText = article.Article_Text__c;
        
        Matcher MyMatcher = MyPattern.matcher(articleText);
        Matcher MyMatcher1 = MyPattern.matcher(articleText);
        Map<String, Boolean> articleIds = new Map<String, Boolean>();
        while(MyMatcher.find()){ 
            String[] linkParts = MyMatcher.group(1).split('(?i)id=');
            if(linkParts != null && linkParts.size() == 2){
                if(linkParts[1].contains('&')){
                    articleIds.put(linkParts[1].substring(0,linkParts[1].indexOf('&')), false);
                }else{
                    articleIds.put(linkParts[1].substring(0,linkParts[1].indexOf('"')), false);
                }
            }
        }
        
        if(articleIds.size() == 0){
            return;
        }
        
        articleIds = articlesPKB(articleIds);
        while(MyMatcher1.find()){
            String[] linkParts = MyMatcher1.group(1).split('(?i)id=');
            if(linkParts != null && linkParts.size() ==2){
                String recId;
                if(linkParts[1].contains('&')){
                    recId = linkParts[1].substring(0,linkParts[1].indexOf('&'));
                }else{
                    recId = linkParts[1].substring(0,linkParts[1].indexOf('"'));
                }
                if(articleIds.containsKey(recId) && articleIds.get(recId)){
                        linkParts[0] = linkParts[0].replace('http://community.marketo.com/MarketoArticle', '/articles/MarketoPKBArticle');                  
                } 
                articleText = articleText.replace(MyMatcher1.group(1), linkParts[0]+'id='+linkParts[1]);
            }           
        }
    }
    
    /* 29-04-11 vishals@grazitti.com Added below code to parse pkb articles*/
    public Map<String, Boolean> articlesPKB(Map<String, Boolean> articleIds){
        for(Article__kav article : [select  knowledgeArticleId, IsVisibleInPkb ,id, Article_Text__c from Article__kav where knowledgeArticleId IN :articleIds.keyset() and publishstatus='Online']){
            if(article.IsVisibleInPkb && articleIds.containsKey(String.valueOf(article.knowledgeArticleId).substring(0,15)))
                articleIds.put(String.valueOf(article.knowledgeArticleId).substring(0,15), true);
        }
        return articleIds;
    }
    
    private void init() {
        Boolean refresh = true;
        MarketoUserContext context = MarketoUserContext.getContext();
              
         //sahil
        DataCategoryHelper helper = DataCategoryHelper.getHelper('KnowledgeArticleVersion');
        List<MarketoDeepDive__kav> deepDiveArticles = [select KnowledgeArticleId, Title from MarketoDeepDive__kav where Language = 'en_US' and publishstatus='Online' and DeepDiveCategory__c != null];
        
        System.Debug('ApexPages.currentPage().getParameters().get(Id)+++++'+ ApexPages.currentPage().getParameters().get('Id'));
        Article__kav  currArticleSoql = [select Id, IsVisibleInPkb, Title, knowledgeArticleId, Language, LastPublishedDate from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online' and Language='en_US' limit 1];
        List<Article__DataCategorySelection> currentArtDataCatList = [Select ParentId, Id, DataCategoryName, DataCategoryGroupName From Article__DataCategorySelection Where ParentId =:currArticleSoql.Id];
        System.Debug('currentArtDataCatList1+++++'+currentArtDataCatList);
        Map<String,MarketoDeepDive__kav> deepDiveTitlesToLinks     = new Map<String,MarketoDeepDive__kav>();
        
        for(MarketoDeepDive__kav tempdeepDiveObj : deepDiveArticles ){
            deepDiveTitlesToLinks.put(tempdeepDiveObj.title,tempdeepDiveObj);
        }
       
        deepDiveCatgsOfArt = new Map<String,MarketoDeepDive__kav>();
        
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        
        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');
        pair1.setDataCategoryGroupName('Articles');
        
        pairs.add(pair1);
        
        List<Schema.DescribeDataCategoryGroupStructureResult> results = Schema.describeDataCategoryGroupStructures(pairs, false);       
        DataCategory[] topCategs = results.get(0).getTopCategories().get(0).getChildCategories();
 
        System.Debug('Size==========='+deepDiveCatgsOfArt.size());
        System.Debug('currentArtDataCatList===='+currentArtDataCatList);
        
        for (Article__DataCategorySelection tempCatgry : currentArtDataCatList){
            String catgLabel = helper.getNameToLabelMap().get(tempCatgry.DataCategoryName);
            //System.Debug('MYPARENT '+tempCatgry.DataCategoryName+' '+helper.getTopCategory(topCategs, tempCatgry.DataCategoryName, 'All'));
            String parentCateg = helper.getTopCategory(topCategs, tempCatgry.DataCategoryName, 'All');
            
            If (deepDiveTitlesToLinks.containsKey(catgLabel)){
                deepDiveCatgsOfArt.put(catgLabel, deepDiveTitlesToLinks.get(catgLabel)); 
            }
            if (deepDiveTitlesToLinks.containsKey(parentCateg)) {
                /*deepDiveCatgsOfArt.put(catgLabel, deepDiveTitlesToLinks.get(parentCateg)); ONLY PARENT CATEGS REQUIRED NOW*/
                deepDiveCatgsOfArt.put(parentCateg, deepDiveTitlesToLinks.get(parentCateg)); 
            }
            
            System.Debug('COUNTER_'+parentCateg);
        }
        System.Debug('Size==========='+deepDiveCatgsOfArt.size());
        System.Debug('currentArtDataCatList===='+currentArtDataCatList);
        If (deepDiveCatgsOfArt.size()== 0){
          String categLabel = '';
          if (currentArtDataCatList.size() > 0) {
              categLabel = helper.getNameToLabelMap().get(currentArtDataCatList.get(0).DataCategoryName);
              //category = categLabel == null?currentArtDataCatList.get(0).DataCategoryName:categLabel;
          }
        }
        //System.Debug('Category============='+category);
        //end
      
      
        
    }   
     
  
    public pageReference sendEmail(){    
       toperrmsg  = false;  
       Integer abc = comment.body.length();
       system.debug('abc--->'+abc);
        //create a mail object to send email 
        String msg2 = 'Please enter your Feedback';
        Article_FeedBack__c myFeedbackDetails = new Article_FeedBack__c();
        System.Debug('commentISEffective'+comment.isEffective);
        myFeedbackDetails.Is_Article_Effective__c = true;
        if(comment.body == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2 ));
            return null;
        }  
                
        if(comment.body != ''){
            try{
                //Comment Section
                myFeedbackDetails.Comment_On_Article__c = comment.body;             
                myFeedbackDetails.Article_Name__c = comment.artFeedbackTitle;
                myFeedbackDetails.Article_Url__c = 'http://community.marketo.com/MarketoArticle?id='+ApexPages.currentPage().getParameters().get('Id');
                myFeedbackDetails.Article_Id__c = ApexPages.currentPage().getParameters().get('Id');
                List<Article__kav> ArticleDetail = [SELECT Id, KnowledgeArticleId, Article_Version__c FROM Article__kav where PublishStatus ='Online' and KnowledgeArticleId = :myFeedbackDetails.Article_Id__c ];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toaddress = (new String[]{'articlefeedback@marketo.com'});
                //String[] toaddress = (new String[]{'muditg@grazitti.com'});
               
                //email properties
                mail.setToAddresses(toaddress );
                if(ArticleDetail[0].Article_Version__c == null){
                    ArticleDetail[0].Article_Version__c = 'V1';
                }
                mail.setSubject(ArticleDetail[0].Article_Version__c+' - ' +'Knowledge Base Feedback - '+comment.subject);
                //mail.setSubject('Knowledge Base Feedback : '+comment.subject);
                mail.setUseSignature(true);
                String mailTextContent = 'Following feedback has been submitted on Marketo knowledgebase:'+'\n\n'+'Title: '+comment.subject+'\n\n'+'Comment: '+ comment.body;
                mailTextContent += comment.TextContent;
                mail.setPlainTextBody(mailTextContent);             
                string tmpNameofCustomer = '';
                string tmpLinkToProfile = '';
                string AccountId = '';
                string LinkToKbArticle = '';                
                insert myFeedbackDetails;              
                BadgeVilleWebServiceCallouts.badgvilleGiveAFeedback(article.Id);  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Thank you for submitting the feedback'));
                           
            }catch(Exception e) {               
                string tmpSTr = e.getmessage();
                if(tmpStr.contains('(max length=32768)')) { 
                    
                    toperrmsg = true;
                }
                
                return null;
            } 
            
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2 ));
                return null;
            }                
            
           //return null;
           return(redirectToTutorial());
       
   }
   
   /* 16-06-11 vishals@grazitti.com Added for redirection */
    public PageReference redirectToTutorial(){
     
        String curId = ApexPages.currentPage().getParameters().get('Id');
        if (curId == 'kA050000000KyvF'){  
            PageReference pageRef = new PageReference('/apex/MarketoTutorialPage?id=kA250000000KzWo');
            pageRef.setRedirect(false);
            return pageRef;
        }
           
        if(ApexPages.currentPage().getParameters().get('articleName') != null){
            return null;
        }
        DataCategoryHelper helper = DataCategoryHelper.getHelper('KnowledgeArticleVersion');
        String currentType;
        String currentArticleCategory;
        currentType = ApexPages.currentPage().getParameters().get('type');
        system.debug('====currentType======'+ currentType);
        PageReference pg = null;
        if(currentType != null && 'Tutorial'.equalsIgnoreCase(currentType)){
            Article__kav currentArticle;
            List<Article__kav> articleList = [select  URLName, id, Article_Text__c,(select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online' and Language = 'en_US'];
            if(articleList != null && articleList.size() > 0){
                currentArticle = articleList.get(0);
                if(currentArticle.DataCategorySelections.size() > 0){
                    currentArticleCategory = currentArticle.DataCategorySelections.get(0).DataCategoryName;
                }
            }
            pg = Page.MarketoArticle;
            pg.getParameters().put('Id', ApexPages.currentPage().getParameters().get('Id'));
            pg.getParameters().put('articleName', currentArticle.URLName);
            pg.getParameters().put('tutorialName', currentArticleCategory);
            system.debug('=================='+pg);
            return pg.setRedirect(true);
        }   
        return pg;
    }  
   
    public class LanguageWrapper{
        public List<SelectOption> langOfArticle{get; set;}
        public String langName{get; set;}
        public Boolean langShow{get;set;}
       // Public Map<String,String> languageKeyToLabel = new Map<String,String>{'en_US'=>'English','fr'=>'Francais','de'=>'Deutsch','nl_NL'=>'Nederlands','it'=>'italiano'};
        
    }
    
    public class CommentWrapper{
    
        public String body {get;set;}
        public String TextContent{get;set;}
        public String subject {get;set;}
        public String artFeedbackTitle{get;set;}
        public String isEffective {get;set;}
       
    }
      
   
 
 
}