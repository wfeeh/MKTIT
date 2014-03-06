@isTest
public class testResourceController{
    static testMethod void validateResourceController() {
        Resources__kav Resource = new Resources__kav();
        Resource.Title ='testtitle';
        Resource.Article_Text__c ='this is test method';
        Resource.UrlName ='testtitle';
        Resource.Allow_Comments__c ='No';
        insert Resource ;
        
        Resources__kav  Resource1 = new Resources__kav();
        Resource1 = [select id, Allow_Comments__c,LastPublishedDate , UrlName, knowledgearticleid, Title, Attachment1__Name__s,Attachment2__Name__s,Attachment3__Name__s,Attachment4__Name__s,Attachment5__Name__s, Article_Text__c from Resources__kav where PublishStatus ='Draft' and language = 'en_US'and Id =:Resource.Id limit 1];
        KbManagement.PublishingService.publishArticle(Resource1.knowledgearticleid, true);
       
        Resources__kav  Resource2 = new Resources__kav();
        Resource2 = [select id,LastPublishedDate ,UrlName, knowledgearticleid, Title, Attachment1__Name__s,Attachment2__Name__s,Attachment3__Name__s,Attachment4__Name__s,Attachment5__Name__s,Allow_Comments__c, Article_Text__c from Resources__kav where PublishStatus ='Online' and language = 'en_US' and Id =:Resource1.Id limit 1];
        
        PageReference pageRef = Page.marketoresource;                     
        pageRef.getParameters().put('Id', Resource2.knowledgearticleid);
        Test.setCurrentPage(pageRef);
       
        MarketoResourceController controller = new MarketoResourceController (new ApexPages.StandardController(Resource2));
        controller.body        = 'testbody';
        String knbID      = '' + Resource2.knowledgeArticleId;
        test.starttest();
        controller.toggleSubscription();        
        controller.getSubscribedToQuestion();        
        controller.getdeepDiveCatgsOfArt();        
        
        Article_FeedBack__c articleFeedback   = new Article_FeedBack__c();
        articleFeedback.Comment_On_Article__c ='this is test method';
        articleFeedback.Article_Id__c         =  knbID;
        articleFeedback.Article_Url__c        = 'http://community.marketo.com/MarketoResource?id='+ApexPages.currentPage().getParameters().get('Id');
        articleFeedback.Article_Name__c       = Resource2.title;
        insert articleFeedback ;   
              
        articleFeedback   = new Article_FeedBack__c();
        articleFeedback.Comment_On_Article__c ='this is test method 1';
        articleFeedback.Article_Id__c         =  knbID;
        articleFeedback.Article_Url__c        = 'http://community.marketo.com/MarketoResource?id='+ApexPages.currentPage().getParameters().get('Id');
        articleFeedback.Article_Name__c       = Resource2.title;
        insert articleFeedback ;  
        
        controller.getdisplay_list();   
        controller.saveComments();                      
        /*
        

        //Article_FeedBack__c myFeedbackDetails = [Select id, CreatedById, Comment_On_Article__c, Article_Id__c, createdDate From Article_FeedBack__c a where Article_Id__c =: Resource2.knowledgeArticleId order by createddate];

        controller.saveComments();
        controller.getdisplay_list();


        */
        test.stoptest();
    }
    
}