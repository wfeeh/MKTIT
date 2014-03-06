public class MarketoNewReleaseController{
   public Article__kav  newReleaseLink{get;set;}
   
   public MarketoNewReleaseController() {
        newReleaseLink = new Article__kav();
        List<Article__kav> newReleaseLinkList = new List<Article__kav>();
        newReleaseLinkList =[Select id, Title, KnowledgeArticleId, Whats_New_Content__c From Article__kav  where publishstatus='Online' and language='en_US' and Whats_New_Content__c = 'New Release' ORDER BY LastModifiedDate  DESC limit 1];
        if(newReleaseLinkList.size()> 0){
            newReleaseLink = newReleaseLinkList[0];
        }else{
           newReleaseLink = null; 
        }
   }
   public static testMethod void testMarketoNewReleaseController() {
       MarketoNewReleaseController mtc = new MarketoNewReleaseController();

    }   
}