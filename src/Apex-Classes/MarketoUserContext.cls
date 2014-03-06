public class MarketoUserContext {
  
    public String currentSection {get; set;} 
    public String currentArticleCategory {get; set;} 
    public MarketoBaseController baseController {get;} 
    public Boolean inHome { get {return currentSection == 'Community';} }
    public Boolean inIdeas { get {return currentSection == 'Ideas';} }
    public Boolean inDiscussion { get {return currentSection == 'Discussion';} }
    public Boolean inKnowledge { get {return currentSection == 'Knowledge';} }
    public Boolean inSearch { get {return currentSection == 'Search';} }
    public Boolean inUniversity { get {return currentSection == 'University';} }
    public Boolean inNewRelease { get {return currentSection == 'NewRelease';} }
        
    private static MarketoUserContext context = null;
    
    private MarketoUserContext() {
        init();
    }
                  
    public void init() {
        currentSection = 'Community';
        
        String url = ApexPages.currentPage().getUrl() != null ? ApexPages.currentPage().getUrl().toLowerCase() : '';
        
        for (String t : templatesIdeas) {
            if (url.contains(t.toLowerCase())) {
                currentSection = 'Ideas';
            }
        }
        for (String t : templatesDiscuss) {
            if (url.contains(t.toLowerCase())) {
                currentSection = 'Discussion';
            }
        }
        for (String t : templatesKnowledge) {
            if (url.contains(t.toLowerCase())) {
                currentSection = 'Knowledge';
            }
        }
        for (String t : templatesSearch) {
            if (url.contains(t.toLowerCase())) {
                currentSection = 'Search';
            }
        }
        for (String t : templatesUniversity) {
            if (url.contains(t.toLowerCase())) {
                currentSection = 'University';
            }
        }
        for (String t : templatesNewRelease) {
            if (url.contains(t.toLowerCase())) {
                currentSection = 'NewRelease';
            }
        }
        String id = ApexPages.currentPage().getParameters().get('id');
        
        if (url.contains(Page.MarketoArticle.getUrl().toLowerCase()) && id != null) {  
            SObject a = GlobalFunctions.getArticle(id);
            
            if (a != null) {    
                DataCategoryHelper helper = DataCategoryHelper.getHelper('KnowledgeArticleVersion');
                for (Article__DataCategorySelection dc : ((Article__kav) GlobalFunctions.getArticle(id)).DataCategorySelections) {
                    currentArticleCategory = helper.getNameToLabelMap().get(dc.DataCategoryName);
                    if (helper.isChildCategoryOf(dc.DataCategoryName, 'University_Materials')) {
                        currentSection = 'University';
                    }
                }
            }
        }
    }  
    
    public Boolean inDetail { 
        get {
            String pg = ApexPages.currentPage().getUrl() != null ? ApexPages.currentPage().getUrl().toLowerCase() : '';
            return (pg.contains(Page.MarketoIdeaDetail.getUrl()) || pg.contains(Page.MarketoDiscussionDetail.getUrl())) ; 
        }
    }  
    
    public static transient Set<String> templatesIdeas = new Set<String>{
                                                Page.MarketoIdeasHome.getUrl(),
                                                Page.MarketoIdeaDetail.getUrl(),
                                                Page.MarketoIdeaNew.getUrl()};
                                        
    public static transient Set<String> templatesDiscuss = new Set<String>{
                                                Page.MarketoDiscussionHome.getUrl(),
                                                Page.MarketoDiscussionNew.getUrl(),
                                                Page.MarketoDiscussionDetail.getUrl()};
                                             
    public static transient Set<String> templatesKnowledge = new Set<String>{
                                                Page.MarketoKnowledgeHome.getUrl(),
                                                Page.MarketoKnowledgeArticles.getUrl(),
                                                Page.MarketoArticle.getUrl()}; 
                                                
    public static transient Set<String> templatesUniversity = new Set<String>{
                                                Page.MarketoUniversityHome.getUrl()};  
    
    public static transient Set<String> templatesNewRelease = new Set<String>{
                                                Page.MarketoNewRelease.getUrl()};                                                
                                                
    public static transient Set<String> templatesSearch = new Set<String>{
                                                Page.MarketoSearchResults.getUrl()};
                                                
    public static MarketoUserContext getContext() {
        if (context == null) {
            context = new MarketoUserContext();
        }
        return context;
    }    
                                                   
    public static testMethod void testMarketoUserContext() {
        MarketoUserContext c = MarketoUserContext.getContext();
        c.init();
        
        system.debug(c.inDetail);
        system.debug(c.inIdeas);
        system.debug(c.inDiscussion);
        system.debug(c.inKnowledge);
        system.debug(c.inSearch);
        system.debug(c.inUniversity);
        system.debug(c.inNewRelease);
    }
    
    /* 15-03-11 vishals@grazitti.com Added to increase code coverage */
    public static testMethod void testMarketoUserContext1() {
        Test.setCurrentPage(Page.MarketoIdeasHome);
        MarketoUserContext c = MarketoUserContext.getContext();
        c.init();
    }
    
    /* 15-03-11 vishals@grazitti.com Added to increase code coverage */
    public static testMethod void testMarketoUserContext2() {
        Test.setCurrentPage(Page.MarketoDiscussionHome);
        MarketoUserContext c = MarketoUserContext.getContext();
        c.init();
    }
    
    /* 15-03-11 vishals@grazitti.com Added to increase code coverage */
    public static testMethod void testMarketoUserContext3() {
        Test.setCurrentPage(Page.MarketoKnowledgeHome);
        MarketoUserContext c = MarketoUserContext.getContext();
        c.init();
    }
    
    /* 15-03-11 vishals@grazitti.com Added to increase code coverage */
    public static testMethod void testMarketoUserContext4() {
        Test.setCurrentPage(Page.MarketoUniversityHome);
        MarketoUserContext c = MarketoUserContext.getContext();
        c.init();
    }
    
    /* 15-03-11 vishals@grazitti.com Added to increase code coverage */
    public static testMethod void testMarketoUserContext5() {
        Test.setCurrentPage(Page.MarketoSearchResults);
        MarketoUserContext c = MarketoUserContext.getContext();
        c.init();
    }
    public static testMethod void testMarketoUserContext6() {
        Test.setCurrentPage(Page.MarketoNewRelease);
        MarketoUserContext c = MarketoUserContext.getContext();
        c.init();
    }
}