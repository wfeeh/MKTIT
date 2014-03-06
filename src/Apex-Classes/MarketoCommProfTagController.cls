public with sharing class MarketoCommProfTagController {
    public String getSimilar() {
        String query = apexpages.currentpage().getparameters().get('q'); 
        String alreadyAddedTag =  apexpages.currentpage().getparameters().get('existTag')!=null?apexpages.currentpage().getparameters().get('existTag'):''; 
        String calledFromArrow =  apexpages.currentpage().getparameters().get('calledFromArrow')!=null?apexpages.currentpage().getparameters().get('calledFromArrow'):''; 
        String marketingTag =  apexpages.currentpage().getparameters().get('marketingTag')!=null?apexpages.currentpage().getparameters().get('marketingTag'):''; 
        System.Debug('TERM'+apexpages.currentpage().getparameters().get('term'));
        //create an SOBject list with the results from our query
        //SObject[] objs = Database.query('Select TagValue__c, sort_order__c from CommProfileTag__c where TagValue__c LIKE' + '\'' + query + '%\' order by sort_order__c limit 10');        
        
        Set<CommProfileTag__c> commProfTags = new Set<CommProfileTag__c>();
        Set<CommMarketingTags__c> commMarkTags = new Set<CommMarketingTags__c>();
        
        if(!marketingTag.containsOnly('WhoIammarketingto')){
            string OnlineStatus = 'Online';
            String EngUS= 'en_US';
            string textQuery =  ' and Title LIKE' + '\'' + query + '%\' order by Title limit 30';
            SObject[] objs = Database.query('SELECT Title FROM MarketoDeepDive__kav where PublishStatus =: OnlineStatus' + ' AND Language =: EngUS' + textQuery );        
            
            for (sObject obj:objs) {
                CommProfileTag__c commProfTag = new CommProfileTag__c(); 
                commProfTag.TagValue__c =  String.valueOf(obj.Get('Title'));
                //string tmpSortOrder = String.valueOf(obj.Get('Sort_Order__c'));
                //commProfTag.sort_order__c =  integer.valueof(tmpSortOrder);
                commProfTags.add(commProfTag);
                system.debug('*****Internal***' + commProfTags);
            }
                
            If(query != ''){
                List<CommProfileTag__c> commProfTagsNew = Database.query('Select TagValue__c from CommProfileTag__c where TagValue__c LIKE' + '\'' + query + '%\'  limit 1000'); 
                system.debug('*****commProfTagsNew***' + commProfTagsNew);
                for ( CommProfileTag__c CommProfileTag : commProfTagsNew)
                {
                   CommProfileTag__c commProfTag = new CommProfileTag__c(); 
                   CommProfTag.TagValue__c = String.valueOf(CommProfileTag.Get('TagValue__c'));
                   commProfTags.add(CommProfTag);
                   system.debug('*****outer***' + commProfTags);
                }
            }
            List<CommProfileTag__c> commProfTagsList = new List<CommProfileTag__c>();
            For(CommProfileTag__c CommProfileTag : commProfTags){
                commProfTagsList.add(CommProfileTag);
            }
            commProfTagsList.sort();
            
            //Return if (No Existing) || (Existing + q)
            //    String jsonString = JSON.serialize(commProfTagsList);
            //    return jsonString ;        
            if (alreadyAddedTag.trim() == '' || calledFromArrow.trim() == 'true' || (alreadyAddedTag.trim() != '' && query.trim() != '')) {
                String jsonString = JSON.serialize(commProfTagsList);
                return jsonString ;
            } else {
                return JSON.serialize(new List<CommProfileTag__c>());
            }
           }else{
               If(query != ''){
                    List<CommMarketingTags__c> commMarkTagsNew = Database.query('Select TagValue__c from CommMarketingTags__c where TagValue__c LIKE' + '\'' + query + '%\'  limit 1000'); 
                    system.debug('*****commMarkTagsNew ***' + commMarkTagsNew);
                    for ( CommMarketingTags__c CommMarketingTag : commMarkTagsNew)
                    {
                       CommMarketingTags__c commMarkTag = new CommMarketingTags__c(); 
                       commMarkTag.TagValue__c = String.valueOf(CommMarketingTag.Get('TagValue__c'));
                       commMarkTags.add(commMarkTag);
                       system.debug('*****outer***' + commMarkTags);
                    }
                }
                List<CommMarketingTags__c> commMarkTagsList = new List<CommMarketingTags__c>();
                For(CommMarketingTags__c CommMarketingTag : commMarkTags){
                    commMarkTagsList.add(CommMarketingTag);
                }
                commMarkTagsList.sort();
            
            //Return if (No Existing) || (Existing + q)
            //    String jsonString = JSON.serialize(commProfTagsList);
            //    return jsonString ;        
            if (alreadyAddedTag.trim() == '' || calledFromArrow.trim() == 'true' || (alreadyAddedTag.trim() != '' && query.trim() != '')) {
                String jsonString = JSON.serialize(commMarkTagsList);
                return jsonString ;
            } else {
                return JSON.serialize(new List<CommMarketingTags__c>());
            }
           }
     
        
    }  
    
    public static testMethod void testMethod1()
    {
        //PageReference pageRef = Page.MarketoCommunityProfileEdit;
        //Test.setCurrentPage(pageRef);
        Test.startTest();
        CommProfileTag__c c1 = new CommProfileTag__c();
        c1.TagValue__c = 'test';
        c1.sort_order__c = 0;
        c1.counter__c = 1;
        insert c1;
        
        ApexPages.currentPage().getParameters().put('q', 'admin');
        MarketoCommProfTagController  controller = new MarketoCommProfTagController ();
        controller.getSimilar();        
        ApexPages.currentPage().getParameters().put('q', 'test');
        controller.getSimilar();  
        Test.stopTest();
              
    
    
    }
    
}