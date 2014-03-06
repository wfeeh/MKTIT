public class MarketoUniversityController extends MarketoBaseController {

Public list<searchQuery__c>  topSearches{get;set;}

    public MarketoUniversityController() {
        getSearchRecords();
    }
    
    public list<searchQuery__c> getSearchRecords(){
    topSearches = new List<searchQuery__c>();
    topSearches = [SELECT  searchString__c,relevancy__c FROM searchQuery__c  WHERE CreatedDate = LAST_N_DAYS:30 order by relevancy__c desc limit 10];
    System.debug('topSearches --->'+topSearches );
    
        return topSearches;
    }
    public Boolean inHome {
        get {
            return ApexPages.currentPage().getParameters().get('LearningCenter') == null;
        }
    }
    
    public Boolean inLearning {
        get {
            return ApexPages.currentPage().getParameters().get('LearningCenter') != null;
        }
    }
    /* kanupriyag@grazitti.com */
    public PageReference redirectToUniversity(){
        pageReference pg = new pageReference('/apex/MarketoUniversityHome');
        pg.setRedirect(true);
        return pg;
    }
       
    public static testMethod void testUniversityController() {
        
        MarketoUniversityController c = new MarketoUniversityController();
        c.getSearchRecords();
        system.assertEquals(c.inHome, true);
        system.assertEquals(c.inLearning, false);
        
        ApexPages.currentPage().getParameters().put('LearningCenter', 'true');
        system.assertEquals(c.inHome, false);
        system.assertEquals(c.inLearning, true);
    }
}