public class MarketoIssueSolutionController  {
    
    public String category {get; set;}
    public Boolean isUniversityArticle {get; set;}
    public transient Issue_Solution_Article__kav issueSolArticle{get; set;}
    public string articleText{get;set;}
    public MarketoIssueSolutionController(ApexPages.StandardController stdController) {
        
        String articleId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('articleId -->'+articleId );
        issueSolArticle = (Issue_Solution_Article__kav)stdController.getRecord();
        System.debug('issueSolArticle-->'+issueSolArticle);
        init();
       
    }
    private void init() {
       MarketoUserContext context = MarketoUserContext.getContext();
        category = context.currentArticleCategory;
        isUniversityArticle = context.inUniversity;
    }   
    
    public String getCategoryName() {
        return DataCategoryHelper.getHelper('KnowledgeArticleVersion').getNameToLabelMap().get(ApexPages.currentPage().getParameters().get('category'));
    }
    
    public String getCategory2Name() {
        return DataCategoryHelper.getHelper('KnowledgeArticleVersion').getNameToLabelMap().get(ApexPages.currentPage().getParameters().get('category2'));
    }
    
    public Long getCacheMaxAge() {
        return null;
    }
   
    /* 16-06-11 vishals@grazitti.com Added for redirection */
    public PageReference redirectToTutorial(){
      
    
        if(ApexPages.currentPage().getParameters().get('articleName') != null){
            return null;
        }
        DataCategoryHelper helper = DataCategoryHelper.getHelper('KnowledgeArticleVersion');
        String currentType;
        String currentArticleCategory;
        /*Set<String> tutorials = new Set<String>{'Create_and_Manage_a_Program',''};
        for (Article__DataCategorySelection dc : ((Article__kav) GlobalFunctions.getArticle(ApexPages.currentPage().getParameters().get('Id'))).DataCategorySelections) {
            currentArticleCategory = helper.getNameToLabelMap().get(dc.DataCategoryName);
            system.debug('====currentArticleCategory======'+currentArticleCategory);
            system.debug('====dc.DataCategoryName======'+dc.DataCategoryName);
            if (helper.isChildCategoryOf(dc.DataCategoryName, 'Tutorials')) {
                currentType = 'Tutorial';
            }
        }*/
        currentType = ApexPages.currentPage().getParameters().get('type');
        system.debug('====currentType======'+ currentType);
        PageReference pg = null;
        if(currentType != null && 'Tutorial'.equalsIgnoreCase(currentType)){
            Issue_Solution_Article__kav currentArticle;
            List<Issue_Solution_Article__kav> articleList = [select  URLName, id, Issue__c,Solution__c, (select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Issue_Solution_Article__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online'];
            system.debug('=========articleList ========='+articleList );
            if(articleList != null && articleList.size() > 0){
                currentArticle = articleList.get(0);
                if(currentArticle.DataCategorySelections.size() > 0){
                    currentArticleCategory = currentArticle.DataCategorySelections.get(0).DataCategoryName;
                }
            }
            system.debug('=========currentArticleCategory ========='+currentArticleCategory );
            pg = Page.MarketoissueSolution;
            pg.getParameters().put('Id', ApexPages.currentPage().getParameters().get('Id'));
            pg.getParameters().put('articleName', currentArticle.URLName);
            pg.getParameters().put('tutorialName', currentArticleCategory);
            system.debug('=================='+pg);
            return pg.setRedirect(true);
        }   
        return pg;
    }
    
    public static testMethod void testKnowledgeController() {
       /*  09-03-11 vishals@grazitti.com Commented because of test failure */
        Issue_Solution_Article__kav article = new Issue_Solution_Article__kav();
        article.Title = 'test';
        article.UrlName = 'test123321';
        insert article;
        //PageReference pageRef = Page.marketocommunityhome;
        PageReference pageRef = Page.marketopkbarticle;     
        pageRef.getParameters().put('Id', 'kA3P00000004CJx');
        Test.setCurrentPage(pageRef);
        MarketoIssueSolutionController controller = new MarketoIssueSolutionController(new ApexPages.StandardController(article));
        controller.getCategoryName();
        controller.getCategory2Name();
        controller.getCacheMaxAge();
        
        
        Issue_Solution_Article__kav article1 = new Issue_Solution_Article__kav();
        article1.Title = 'test123';
        article1.UrlName = 'test1321';
        insert article1;
        //PageReference pageRef = Page.marketoArticle;
        PageReference pageRef1 = Page.marketopkbarticle;        
        pageRef1.getParameters().put('Id', 'kA3P00000004CJx');
        pageRef1.getParameters().put('type', 'Issue/ Solution Article');        
        Test.setCurrentPage(pageRef1);
        MarketoIssueSolutionController controller1 = new MarketoIssueSolutionController(new ApexPages.StandardController(article1));
        controller1.getCategoryName();
        controller1.getCategory2Name();
        controller1.getCacheMaxAge();
        controller1.redirectToTutorial();       
        
    }

}