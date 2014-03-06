@isTest(SeeAllData=true)
public class TestClassesforMarketo {

     static testMethod void testMarketoTutorialController() {
        Tutorial__kav Tutorial = new Tutorial__kav();
        Tutorial.title ='testtitle';
        Tutorial.UrlName ='testurl'; 
        Tutorial.IsVisibleInPkb = true;
        insert Tutorial; 
        
        Tutorial__kav tutorial1 = [Select  Id, UrlName, Title, KnowledgeArticleId, IsVisibleInPkb From Tutorial__kav where PublishStatus ='Draft' and language = 'en_US' and Id =:Tutorial.Id ];
        system.debug('knowledgearticleid-->'+tutorial1.knowledgearticleid);
        KbManagement.PublishingService.publishArticle(tutorial1.knowledgearticleid, true);
        
        Tutorial__kav tutorial2 = [Select  Id, UrlName, IsVisibleInPkb, Title, knowledgeArticleId, Language, LastPublishedDate From Tutorial__kav where PublishStatus ='Online' and language = 'en_US' and Id =:Tutorial.Id ];
        system.debug('knowledgearticleid123-->'+tutorial2.knowledgearticleid);
        
        PageReference pageRef = Page.MarketoTutorial;                     
        pageRef.getParameters().put('Id', tutorial2.knowledgearticleid);
        Test.setCurrentPage(pageRef);
        List<KnowledgeArticleViewStat> KnowledgeTutorialViewStatList = [SELECT Id,ParentId,Channel FROM KnowledgeArticleViewStat where ParentId =:tutorial2.knowledgearticleid LIMIT 5];
        
        MarketoTutorialController controller = new MarketoTutorialController(new ApexPages.StandardController(tutorial2));
        MarketoTutorialController.CommentWrapper comment = new MarketoTutorialController.CommentWrapper();
       // User loggedUser = [Select id, email, name from User where Id=:UserInfo.getUserId() and isPortalEnabled = true and Is_Employee__c = true LIMIT 1];
        controller.comment.body ='test';
        controller.comment.title = 'this is test method';
        controller.comment.isEffective ='No';
        Article_FeedBack__c articleFeedback   = new Article_FeedBack__c();
        articleFeedback.Article_Name__c       =  controller.comment.title;
        articleFeedback.Article_Id__c         =  ApexPages.currentPage().getParameters().get('Id');
        articleFeedback.Article_Url__c        = 'http://community.marketo.com/MarketoTutorial?id='+ApexPages.currentPage().getParameters().get('Id');
        Messaging.SingleEmailMessage mail     = new Messaging.SingleEmailMessage();
        String[] toaddress = (new String[]{'articlefeedback@marketo.com'});
        mail.setToAddresses(toaddress );
        mail.setSubject('Knowledge Base Feedback : this is test method');
        mail.setUseSignature(true);
        String mailTextContent = 'Following feedback has been submitted on Marketo knowledgebase:'+'\n\n'+'Title: '+controller.comment.title+'\n\n'+'Comment: '+ controller.comment.body;
        mail.setPlainTextBody(mailTextContent); 
        insert articleFeedback ;
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
        test.starttest();
        controller.getItems();
        controller.sendEmail();
        test.stoptest();
        
     }
    
     static testMethod void testMarketoArticleControllerPositive(){
        
        Article__kav Article= new Article__kav();
        Article.title ='testtitle';
        Article.UrlName ='testurl'; 
        Article.IsVisibleInPkb = true;
        Article.Article_Text__c ='this is test <a href="http://community.marketo.com/MarketoArticle?id=123&test=12">test</a> article';
        insert Article; 
               
        Article__kav Article1 = [Select  Id, Article_Text__c, UrlName, Title, KnowledgeArticleId, IsVisibleInPkb From Article__kav where PublishStatus ='Draft' and  Id =:Article.Id ];
        
        Article__kav Article3 = [Select  Id, Article_Text__c, UrlName, Title, KnowledgeArticleId, IsVisibleInPkb From Article__kav where PublishStatus ='Draft' and KnowledgeArticleId =:Article1.knowledgearticleid];
       
        KbManagement.PublishingService.publishArticle(Article1.knowledgearticleid, true);
       
        PageReference pageRef = Page.MarketoTutorial;                     
        pageRef.getParameters().put('Id', Article1.knowledgearticleid);
        pageRef.getParameters().put('type', 'Tutorial');
        pageRef.getParameters().put('name', 'marketopkbarticle');
        Test.setCurrentPage(pageRef);
        
        Article__kav Article2 = [Select  Id,Article_Text__c, UrlName, IsVisibleInPkb, Title, knowledgeArticleId, Language, LastPublishedDate From Article__kav where PublishStatus ='Online' and KnowledgeArticleId =:Article1.knowledgearticleid];
        
        Article__DataCategorySelection datacatergory = new Article__DataCategorySelection();
        datacatergory.DataCategoryGroupName = 'Articles';
        datacatergory.DataCategoryName = 'LIsts';
        datacatergory.ParentId = Article2.id;
        insert datacatergory;
         
        List<KnowledgeArticleViewStat> KnowledgeTutorialViewStatList = [SELECT Id,ParentId,Channel FROM KnowledgeArticleViewStat where ParentId =:Article2.knowledgearticleid LIMIT 5];
        
        MarketoArticleController controller = new MarketoArticleController(new ApexPages.StandardController(Article2));
        MarketoArticleController.CommentWrapper comment = new MarketoArticleController.CommentWrapper();
        MarketoArticleController.LanguageWrapper lang    = new MarketoArticleController.LanguageWrapper();
        list<Article__kav> currentArticle  = [select id, Language, title, SubTitle__c,Article_Text__c, LastPublishedDate, Add_File__Name__s from Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online'];
        system.debug('currentArticle--->'+currentArticle.size());   
        controller.comment.isEffective = 'Yes';
        controller.comment.body        = 'testbody';
        controller.lang.langName       = 'en_US';
        controller.preferredLanguage   ='English';
        controller.comment.artFeedbackTitle = 'this is test method';
        Article_FeedBack__c articleFeedback   = new Article_FeedBack__c();
        articleFeedback.Article_Name__c       =  controller.comment.artFeedbackTitle;
        articleFeedback.Article_Id__c         =  ApexPages.currentPage().getParameters().get('Id');
        articleFeedback.Article_Url__c        = 'http://community.marketo.com/MarketoTutorial?id='+ApexPages.currentPage().getParameters().get('Id');
        Messaging.SingleEmailMessage mail     = new Messaging.SingleEmailMessage();
        String[] toaddress = (new String[]{'articlefeedback@marketo.com'});
        mail.setToAddresses(toaddress );
        mail.setSubject('Knowledge Base Feedback : this is test method');
        mail.setUseSignature(true);
        String mailTextContent = 'Following feedback has been submitted on Marketo knowledgebase:'+'\n\n'+'Title: '+controller.comment.artFeedbackTitle+'\n\n'+'Comment: '+ controller.comment.body;
        mail.setPlainTextBody(mailTextContent); 
        insert articleFeedback ;
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
        list<user> u = [select id, contactid, contact.Preferred_Language__c from user where IsPortalEnabled = true and contact.Preferred_Language__c != null   limit 1];
        contact contant = [select id, Preferred_Language__c from contact where id=:u[0].contactid];
        system.debug('123445highiag-->'+u[0] + u[0].contact.Preferred_Language__c);
        test.starttest();
        if(u.size() > 0){
            System.RunAs(u[0]){
                controller.preferredLanguage   = 'English';
                controller.langSpecificArticle();
            }
        }
        controller.getItems();
        controller.sendEmail();
        controller.redirectToTutorial();
        controller.replaceLinks(Article2);
        Map<String, Boolean> testMap = new Map<String, Boolean>();
        testMap.put('test', true); 
        controller.articlesPKB(testMap); 
        test.stoptest();
        
     }
   
     static testMethod void testMarketoArticleControllerNegative(){
         Article__kav Article= new Article__kav();
        Article.title ='testtitle';
        Article.UrlName ='testurl'; 
        Article.IsVisibleInPkb = true;
        Article.Article_Text__c ='this is test <a href="http://community.marketo.com/MarketoArticle?id=123&test=12">test</a> article';
        insert Article; 
               
        Article__kav Article1 = [Select  Id, Article_Text__c, UrlName, Title, KnowledgeArticleId, IsVisibleInPkb From Article__kav where PublishStatus ='Draft' and  Id =:Article.Id ];
        
        Article__kav Article3 = [Select  Id, Article_Text__c, UrlName, Title, KnowledgeArticleId, IsVisibleInPkb From Article__kav where PublishStatus ='Draft' and KnowledgeArticleId =:Article1.knowledgearticleid];
       
        KbManagement.PublishingService.publishArticle(Article1.knowledgearticleid, true);
       
        PageReference pageRef = Page.MarketoTutorial;                     
        pageRef.getParameters().put('Id', Article1.knowledgearticleid);
        pageRef.getParameters().put('type', 'Tutorial');
        pageRef.getParameters().put('name', 'marketopkbarticle');
        Test.setCurrentPage(pageRef);
        
        Article__kav Article2 = [Select  Id,Article_Text__c, UrlName, IsVisibleInPkb, Title, knowledgeArticleId, Language, LastPublishedDate From Article__kav where PublishStatus ='Online' and KnowledgeArticleId =:Article1.knowledgearticleid];
        MarketoArticleController controller = new MarketoArticleController(new ApexPages.StandardController(Article2));
        MarketoArticleController.CommentWrapper comment = new MarketoArticleController.CommentWrapper();
        test.starttest();
        controller.comment.body        = ''; 
        controller.comment.isEffective = 'NO';
        controller.sendEmail();
        test.stoptest();
       
     }

    static testMethod void testCertificationRegistrationController(){
        PageReference pageRef = Page.certificationregistration;     
        Test.setCurrentPage(pageRef);
        CertificationRegistrationController con = new CertificationRegistrationController();
        test.starttest();
        con.savePayment();
        con.confirmPayment();  
        test.stoptest();
    }
    static testMethod void testMarketoKnowledgeNavigateController(){
      PageReference pg = Page.MarketoKnowledgeArticles; 
      pg.getParameters().put('topcategory', 'root');
      pg.getParameters().put('category', '');
      pg.getParameters().put('category2', '');
      pg.getParameters().put('tab', 'recent');
      pg.getParameters().put('knowledgePg', '4');
      Test.setCurrentPage(pg);
         
      MarketoKnowledgeNavigateController c = new MarketoKnowledgeNavigateController();    
      
      PageReference pg1 = Page.MarketoKnowledgeArticles; 
          pg1.getParameters().put('topcategory', 'All');
          pg1.getParameters().put('category', '');
          pg1.getParameters().put('category2', '');
          pg1.getParameters().put('tab', 'mostviewed');
          pg1.getParameters().put('knowledgePg', '2');
          Test.setCurrentPage(pg1);   
          MarketoKnowledgeNavigateController c1 = new MarketoKnowledgeNavigateController();    
          c1.getVideos(); 
          c1.updateType();      
          String testcateg = c1.selectedCategory; 
    }
   
}