public class MarketoCertificationController{
    public String articleId{get; set;}
    public string artFeedbackUrl{get;set;}
    public String artFeedbackOpt{get;set;}
    
    public MarketoCertificationController(ApexPages.StandardController stdController){
        PageReference pageRef = ApexPages.currentPage();
        artFeedbackUrl = pageRef.geturl();                   
        artFeedbackOpt = '';
        System.debug('stdController->' + stdController);   
        articleId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('articleId--> '+articleId );
    }  
     
    @isTest(SeeAllData=true) 
    public static void testMarketoCertificationController(){
        Article__kav article1 = new Article__kav();
        PageReference pageRef = Page.MarketoCertification;  
        article1=[select URLName, id FROM Article__kav where PublishStatus='online' and language='en_US' limit 1];
        Test.setCurrentPage(pageRef);
        MarketoCertificationController controller = new MarketoCertificationController(new ApexPages.StandardController(article1));
        controller.articleId=article1.id;
        controller.artFeedbackUrl=article1.URLName;
    }
}