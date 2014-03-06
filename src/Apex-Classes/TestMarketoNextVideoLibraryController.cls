/**
 * This class contains unit tests for apex class MarketoNextVideoLibraryController.
 */
@isTest
private class TestMarketoNextVideoLibraryController {

    static testMethod void myUnitTest() {
    	/*
       List<Video__kav> videoList = [select Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' order by Sort_Order__c asc limit 1];
       Video__kav testVideo;
       if(videoList.size() > 0){
       	testVideo = videoList.get(0);
       }
       Test.startTest();
       Test.setCurrentPage(Page.MarketoVideoLibrary);
       if(testVIdeo != null)
       ApexPages.currentPage().getParameters().put('id',testVideo.Id);
       MarketoNextVideoLibraryController controller = new MarketoNextVideoLibraryController();
       Test.stopTest();
       */
    }
}