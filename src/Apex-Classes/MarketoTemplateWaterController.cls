public class MarketoTemplateWaterController extends MarketoBaseController {
    public String profile_pic {get;set;}
    public String profile_nick_name {get;set;}
    public String badgeVille_player_id {get;set;}
    public String badgvilleJsApiKey{get;set;}
    public String badgvilleJsApiUrlSrc {get;set;}
    public String badgvilleSite {get;set;}
    //public BOOLEAN partner_supported_instnce{get;set;}    
    //public String badgevilleLogStr{get; set;}
    Public Boolean isCompanyFiveYearCompleted{get;set;}
    Public Boolean isCustomerFiveYearCompleted{get;set;} 
       
     
    public MarketoTemplateWaterController(){
        //String popupStatus = checkPopup();
        //partner_supported_instnce = false;
        Id userdid = Userinfo.getUserId();
        System.debug('userdid --->'+userdid );        
        try{
                     
            
            settingbadgeVilleStatusForLogdUser();
            badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;
            badgvilleJsApiUrlSrc = BadgvilleUrls__c.getAll().get('badgvilleJsApiUrlSrc').Badgville_Urls__c;
            badgvilleJsApiKey= BadgvilleUrls__c.getAll().get('badgvilleJsApiKey').Badgville_Urls__c; 
            List<Community_Profile__c> userProfile = [select id,Profile_Picture_ID__c,Display_Name__c,Date_I_became_customer__c from Community_Profile__c where User__c = :userdid Limit 1];
            
            if(userProfile.size() > 0)
            {
                profile_pic = userProfile[0].Profile_Picture_ID__c;
                profile_nick_name = userProfile[0].Display_Name__c;                                           
                if(ApexPages.currentPage().getParameters().get('cf_provider') != null && ApexPages.currentPage().getParameters().get('token') != null) {
                    System.debug('BadgeVilleWebServiceCallout Called');
                   // BadgeVilleWebServiceCallout.badgvilleSurveygatePoll(); //LATER UNCOMMENT IT FOR BADGEVILLE POLL REWARD
                }
    
                
            }   
            //Added by Nishtha on 13-05-2013 for issue : 4449
            //*********************************************//
            isCustomerFiveYearCompleted = FALSE;
            isCompanyFiveYearCompleted = FALSE;
            List<user> tmpUser =  [select CreatedDate,AccountId from User Where Id =:userdid LIMIT 1];
    
            List<account> tmpAccount = [select CreatedDate from Account Where Id =:tmpUser [0].AccountId LIMIT 1];
            system.debug('****tmpaccount ****' + tmpaccount ); 
            If (tmpAccount.size() > 0 ) {
                DateTime tmpDate = tmpAccount[0].CreatedDate;                      
                If (Date.Today() >= tmpDate.addYears(5)) {
                    isCompanyFiveYearCompleted = TRUE;                     
                }             
            }         
            If (userProfile[0].Date_I_became_customer__c  != null)
            {
                If (Date.Today() >=userProfile[0].Date_I_became_customer__c.addYears(5)){
                    isCustomerFiveYearCompleted = TRUE;                     
                }         
            }
            //**********************END*************//                                                                       
            
        } catch(exception ex){
        }        
    }
       
    /*public void saveBadgevilleLogStr()   
    {
        BVilleSetPlayerLog__c myLogger = new BVilleSetPlayerLog__c();
        myLogger.LogText__c = badgevilleLogStr;
        insert myLogger;               
    }
    */
    public static testMethod void testMarketoCommunityTemplateController() {
       MarketoTemplateWaterController mtc = new MarketoTemplateWaterController();

    }
    
}