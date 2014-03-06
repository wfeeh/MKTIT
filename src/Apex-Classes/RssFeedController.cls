public class RssFeedController{
    public List<Marketo_News__c> MarketoNewList{get;set;}
    public RssFeedController(){
        MarketoNewList = [SELECT Id,Name, Description__c,Active__c,Publish_Date__c, Link__c,Type__c from Marketo_News__c where Active__c = true];      
    }
     public static testMethod void testController() {
         RssFeedController RssFeed = new RssFeedController();
     }
}