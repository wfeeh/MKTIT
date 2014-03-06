public class MarketoCommunityProfileEditController extends MarketoBaseController {

    private static Id communityProfilePicturesFolderId = [select Id from Folder where Name = 'Community Profile Pictures'].Id;
    public Community_Profile__c profile     {get; set;}
    public ProfileWrapper       wrapper     {get;set;}
    public User                 profileUser {get;set;}
    
    public PageReference init() {
        wrapper = new  ProfileWrapper();
        profile = new Community_Profile__c();
       
        profileUser = [select Id,ContactId, Country__c, TimezoneSidKey, state, City, FirstName, LastName from User where Id = :UserInfo.getUserId()];
                      
        try {
        
            profile = [select Id, CSatSurveyPreferences__c, Display_Name__c, Company_Name__c, Title__c, Location__c, Website__c,CRM__c,User__c, About_Me__c, Facebook__c,LinkedIn__c, Twitter__c, Profile_Picture_ID__c,Date_I_Started_Using_Marketo__c,Member_Of_User_Group__c,Date_I_became_customer__c,Expertise_in_Marketo__c,What_I_want_to_learn_more_about__c,Who_I_am_marketing_to__c,User__r.ContactId, User__r.Contact.Preferred_Language__c 
                       from Community_Profile__c where User__c = :UserInfo.getUserId()];
                     
            // If request for unsubscribe from case survey mails
            if ((ApexPages.currentPage().getParameters().get('unsub') != null) && (ApexPages.currentPage().getParameters().get('unsub') == 'csurvey')) {
                unsusbscribeFromCaseSurvey();
            }
            if(profile.CSatSurveyPreferences__c == null) profile.CSatSurveyPreferences__c = 'All';  
            
            if(profile.Date_I_became_customer__c != null)  {                
                wrapper.monthofDate = profile.Date_I_became_customer__c.Month();
                wrapper.yearofDate = profile.Date_I_became_customer__c.Year();
            }         
           
            wrapper.whatIWantToLearnOldValue = profile.What_I_want_to_learn_more_about__c;
            wrapper.expertiseOldValue  = profile.Expertise_in_Marketo__c;
            wrapper.whoIAmMarketingTo   = profile.Who_I_am_marketing_to__c;
            wrapper.PreferredLanguage = profile.User__r.Contact.Preferred_Language__c == null?'':profile.User__r.Contact.Preferred_Language__c;
                      
        } catch (Exception e) {
           
            // An exception will be thrown if no record exists yet.
            profile = new Community_Profile__c();
            profile.User__c = UserInfo.getUserId();
            profile.Display_Name__c = profileUser.FirstName + ' ' + profileUser.LastName.substring(0, 1);
            profile.CSatSurveyPreferences__c = 'All';
            wrapper.whatIWantToLearnOldValue = '';           
            wrapper.expertiseOldValue = ''; 
            wrapper.whoIAmMarketingTo = '';
        }

        // If no display name, default to User's First Name + first character of Last Name.
        if (profile.Display_Name__c == null || profile.Display_Name__c.trim().length() < 1) {
            profile.Display_Name__c = profileUser.FirstName + ' ' + profileUser.LastName.substring(0, 1);
        }        
        if(profileUser.ContactId <> null){            
            Contact contactsName = [Select Name,Id,Title,Department,Email,Phone,MobilePhone from Contact where Id = :profileUser.ContactId LIMIT 1];            
            wrapper.CntctID = profileUser.ContactId;
            wrapper.phone = contactsName.Phone;
            wrapper.mobileNo = contactsName.MobilePhone;                     
        } else { wrapper.phone = ''; wrapper.mobileNo = ''; }
            return null;
    }
     
     public list<SelectOption> getPreferredLanguage(){
        list<SelectOption> languageOptions = new list<SelectOption>();
        try{
            languageOptions.add(new SelectOption('' , '--None--'));
            for (Schema.PicklistEntry f : Contact.Preferred_Language__c.getDescribe().getPicklistValues()) {
                languageOptions.add(new SelectOption(f.getLabel(), f.getValue()));
 
 
            }
        System.Debug('slcOption+++++++'+languageOptions);
        }catch (Exception e){
                 return null;
        }   
        return languageOptions;
    }   
    public list<SelectOption> getYearsForDate(){
        list<SelectOption> options = new list<SelectOption>();      
        options.add(new SelectOption('', ''));         
        Date now =  Date.Today();
        for(integer i = 2007; i <= now.year();i++){
          String tmpStr = '' + i;     
          options.add(new SelectOption(tmpStr, tmpStr)); 
        }
        return options;
    }    
       
    public list<SelectOption> getMonthsForDate(){
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', ''));        
        options.add(new SelectOption('1', 'Jan')); 
        options.add(new SelectOption('2', 'Feb')); 
        options.add(new SelectOption('3', 'Mar')); 
        options.add(new SelectOption('4', 'Apr')); 
        options.add(new SelectOption('5', 'May')); 
        options.add(new SelectOption('6', 'Jun')); 
        options.add(new SelectOption('7', 'Jul')); 
        options.add(new SelectOption('8', 'Aug')); 
        options.add(new SelectOption('9', 'Sep')); 
        options.add(new SelectOption('10', 'Oct')); 
        options.add(new SelectOption('11', 'Nov')); 
        options.add(new SelectOption('12', 'Dec')); 
        /*for(integer i = 1; i <= 12;i++){        
          String tmpStr = '' + i;               
          options.add(new SelectOption(tmpStr, tmpStr)); 
        }*/
        return options;
    }  
    
    
    public void unsusbscribeFromCaseSurvey() {
        if (profile != null) {
            profile.CSatSurveyPreferences__c = 'never';
            update profile;
        } else {
            profile = new Community_Profile__c(user__c=UserInfo.getUserId(),CSatSurveyPreferences__c = 'never');
            insert profile;
        }        
    }
    
    public Boolean getHasPicture() {
        Boolean hasPicture = false;
        
        if (profile.Profile_Picture_ID__c != null) {
            try {
                Document profilePicture = [select Id from Document where Id = :profile.Profile_Picture_ID__c];
                hasPicture = true;
            } catch (Exception e) {
            }
        }        
        return hasPicture;
    }
   
    public PageReference deletePicture() {
        
        delete [select Id from Document where Id = :profile.Profile_Picture_ID__c];         
        // Remove the Document reference for the current picture if there is one.
        //System.Debug('IMAGE DELETED FOR '+profile.Id);
        if (profile.Id != null) {
            profile.Profile_Picture_ID__c = null;            
            Community_Profile__c p = new Community_Profile__c(Id=profile.Id);
            p.Profile_Picture_ID__c = null;
            update p;
            System.Debug('PROFILE_PICTURE_GONE'+p);
        }
        return null;
    }
    
    public class ProfileWrapper{
        Public Id      CntctID                   {get;set;}
        Public String  phone                     {get;set;}
        Public String  mobileNo                  {get;set;}
        Public String  expertiseOldValue         {get;set;}
        Public String  whatIWantToLearnOldValue  {get;set;}
        Public String  whoIAmMarketingTo         {get;set;}
        Public Integer monthofDate               {get;set;}
        Public Integer yearofDate                {get;set;} 
        Public String  PreferredLanguage         {get;set;}       

        // NOTE: The uploaded image has to be stored in these fields instead of
        // directly into a Document object to get around portal user permissions limitations.
        // The documentBody Blob is made transient so it doesn't get stored in view state
        // which has size limitations.
        public transient Blob documentBody       {get;set;}
        public transient String documentName     {get;set;}
        public String documentType               {get;set;} 
        
    }
         
   public PageReference cropProfilePic() {
 
        Community_Profile__c profile = [select Id,  Profile_Picture_ID__c from Community_Profile__c  where User__c = :UserInfo.getUserId()];
        Document profilePicture = [select Id,body, ContentType from Document where Id = :profile.Profile_Picture_ID__c];
        String ImageManupulationAPI = System.Label.ImageManupulationAPI;
        string typeOfPic = profilePicture.ContentType;
        system.debug('typeOfPic-->'+typeOfPic);
        String x1 =ApexPages.currentPage().getParameters().get('x1');
        String y1 =ApexPages.currentPage().getParameters().get('y1');
        String w =ApexPages.currentPage().getParameters().get('w');
        String h =ApexPages.currentPage().getParameters().get('h');
        system.debug('x1--->'+x1);
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ImageManupulationAPI);
            //req.setEndpoint('http://202.164.49.146/clients/marketo/jcrop/index.php');
            req.setMethod('POST');
            Http http = new Http();
            // req.setBody('img='+EncodingUtil.base64Encode(profilePicture.Body)+'&x1='+x1+'&y1='+y1);
            req.setBody('img='+EncodingUtil.base64Encode(profilePicture.Body)+'&x1='+x1+'&y1='+y1+'&w='+w+'&h='+h+'&typeOfPic='+typeOfPic);
            System.Debug('__Req_Body__'+req.getBody());
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());  
            profilePicture.body =  EncodingUtil.base64Decode(res.getBody());
            update  profilePicture;
 
        }catch (Exception ex ){
             System.debug('ERROR:' + ex);
             return null;
        }
        return null;     
    }

    public PageReference saveProfilePic() {
       string cropImage;
       try {
       system.debug('this.wrapper.documentName--->'+wrapper.documentName);
            if (wrapper.documentBody != null && wrapper.documentName != null && wrapper.documentType != null ) {
                system.debug('hello');
                Document profilePicture;
                
                // If there is already a picture, load it to validate it still exists.
                if (profile.Profile_Picture_ID__c != null) {
                    try {
                        profilePicture = [select Id, ContentType  from Document where Id = :profile.Profile_Picture_ID__c];
                        cropImage = 'True'; 
                        system.debug('type--->'+profilePicture.ContentType  );
                    } catch (Exception e) {
                        // Do nothing. This would occur if the profile picture's Document ID is no longer valid.
                    }
                }
                
                // If no existing profile picture, create a new one.
                if (profilePicture == null) {
                    profilePicture = new Document();
                    profilePicture.FolderId = communityProfilePicturesFolderId;
                }
                
                profilePicture.Body = wrapper.documentBody;
                profilePicture.Name = wrapper.documentName;
                profilePicture.ContentType = wrapper.documentType;
                System.Debug('PICTURE'+wrapper.documentBody.size());
                
                if (wrapper.documentBody.size()>=1048576 && wrapper.documentType != 'application/pdf') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please upload profile image less than 1MB'));
                    return null;
                } 
                if (wrapper.documentType =='image/jpeg' || wrapper.documentType =='image/png' || wrapper.documentType =='image/gif' ) {
                    upsert profilePicture;
                    profile.Profile_Picture_ID__c = profilePicture.Id;
                    cropImage = 'True';
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please upload a correct format'));
                    return null;
                }
               
               
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a file'));
                return null; 
            }
            upsert profile;
            if( wrapper.documentName != null){
                 cropImage = 'True';
                
            }else{
                 cropImage = 'false';
            } 
                             
        } catch (Exception ex) {
            system.debug('Exception--->'+ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving Profile'));
            return null;
        }
        PageReference profilePage = Page.MarketoProfilePicCropPage;
        profilePage.getParameters().put('cropimage', cropImage);
        profilePage.getParameters().put('id', UserInfo.getUserId());
        profilePage.setRedirect(true);
        system.debug('cropImage-->'+cropImage);
        return profilePage;
        
    }
    
    public PageReference save() {
        
        if (profile.Facebook__c != null && profile.Facebook__c.trim().length() > 0 &&
            !profile.Facebook__c.trim().toLowerCase().contains('facebook.com')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Facebook link is not valid. It must contain "facebook.com".'));
        }
        
        if (profile.Twitter__c != null && profile.Twitter__c.trim().length() > 0 &&
            !profile.Twitter__c.trim().toLowerCase().contains('twitter.com')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Twitter link is not valid. It must contain "twitter.com".'));
        }
        
        if (profile.LinkedIn__c != null && profile.LinkedIn__c.trim().length() > 0 &&
            !profile.LinkedIn__c.trim().toLowerCase().contains('linkedin.com')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'LinkedIn link is not valid. It must contain "linkedin.com".'));
        }
        if (profile.About_Me__c != null && profile.About_Me__c.length() > 255 ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter upto 255 characters in "About Me" field.'));
        }
       
        
        if(wrapper.CntctID <> null)
        {
            wrapper.mobileNo = wrapper.mobileNo.trim();
            if(wrapper.mobileNo != ''){                
                if(!validatePhone(wrapper.mobileNo))          
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add mobile number in correct format( US/Can : (123)456-7890 ; International : +123456789123 )!'));
                    return null; 
                }  
            }                  
            wrapper.phone = wrapper.phone.trim();
            if(wrapper.phone.trim() == '' || wrapper.phone == null)    {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add a phone number!'));
                return null;            
            }         
            if(!validatePhone(wrapper.Phone))          
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add a phone number in correct format( US/Can : (123)456-7890 ; International : +123456789123 )!'));
                return null; 
            }
        }                        
           
        if (ApexPages.hasMessages()) {
            return null;
        }
        
        if(wrapper.monthofDate != null && wrapper.yearofDate != null && wrapper.monthofDate != 0 && wrapper.yearofDate != 0){
            profile.Date_I_became_customer__c = Date.parse(wrapper.monthofDate + '/01/' + wrapper.yearofDate);                     
        }
        
        try{
             system.debug('updatefillprof');
             update profileUser; 
             upsert profile; 
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving Profile'));
            return null;
        }
       
        system.debug('profile.Display_Name__c====' + profile.Display_Name__c);
        system.debug('profile.Title__c====' + profile.Title__c);
        system.debug('profile.Profile_Picture_ID__c ====' + profile.Profile_Picture_ID__c );
        system.debug('profile.Website__c ====' + profile.Website__c );
        system.debug('profile.CRM__c ====' + profile.CRM__c );
        system.debug('profile.Date_I_became_customer__c ====' + profile.Date_I_became_customer__c );
        system.debug('profile.Location__c ====' + profile.Location__c );
        system.debug('profile.Expertise_in_Marketo__c ====' + profile.Expertise_in_Marketo__c );
        system.debug('profile.What_I_want_to_learn_more_about__c ====' + profile.What_I_want_to_learn_more_about__c );
       system.debug('profileUser.Country__c=====>*'+ profileUser.Country__c);
        system.debug('profileUser.City__c====' + profileUser.City);
        system.debug('profileUser.State__c====' + profileUser.State);
        
        if((profile.Display_Name__c != Null || profile.Display_Name__c != '') && (profile.Company_Name__c != Null || profile.Company_Name__c != '') && (profile.Title__c != Null || profile.Title__c != '') && profile.Profile_Picture_ID__c != Null 
         && (profile.Website__c != Null || profile.Website__c != '') && (profile.CRM__c != Null || profile.CRM__c != '') && profile.Date_I_became_customer__c != Null && profile.Expertise_in_Marketo__c != Null && profile.What_I_want_to_learn_more_about__c != Null
         && (profileUser.City != null || profileUser.City != '' ) && (profileUser.State != null ||  profileUser.State != '') && (profileUser.Country__c == null || profileUser.Country__c != '' )
        ) {
            /* badgeville kanupriyag@grazitti.com 16-04-2012 */
           
            BadgeVilleWebServiceCallouts.badgvilleFillProfile();
            /* badgeville kanupriyag@grazitti.com 16-04-2012 */
            System.debug('test-------');
        }

        /* for who I am Marketing to */
        List<String > old_mark_tags = wrapper.whoIAmMarketingTo !=null && wrapper.whoIAmMarketingTo.trim() !=''? wrapper.whoIAmMarketingTo.split(' ## '):new List<String>();
        List<CommMarketingTags__c> commMarkTags = new List<CommMarketingTags__c>();
        List<String > markTags = profile.Who_I_am_marketing_to__c !=null && profile.Who_I_am_marketing_to__c.trim() !=''?profile.Who_I_am_marketing_to__c.split(' ## '):new List<String>();
        
        set<String> setMarkListOld = new Set<String>();setMarkListOld.AddAll(old_mark_tags);
        set<String> setMarkListNew = new Set<String>();setMarkListNew.addAll(markTags);
        set<String> setMarkMaster = new Set<String>();setMarkMaster.addAll(markTags);setMarkMaster.addAll(old_mark_tags);
        List<String> tobeDeletedMarkTag = new List<String>();
        List<String> tobeAddedMarkTag = new List<String>();
        for(String strEle : setMarkMaster)
        {
           if(!setMarkListNew.contains(strEle)) {
               tobeDeletedMarkTag.add(strEle);           
           }
           if(!setMarkListOld.contains(strEle)) {
               tobeAddedMarkTag.add(strEle);           
           }
        }
        
        List<CommMarketingTags__c> existingMarkTagList = [SELECT TagValue__c,sort_order__c,counter__c from CommMarketingTags__c WHERE sort_order__c = 0 and ( TagValue__c in :tobeAddedMarkTag Or TagValue__c in :tobeDeletedMarkTag) ];
        Map<String,CommMarketingTags__c> existingMarkTagMap = new Map<String,CommMarketingTags__c>();
        for(CommMarketingTags__c tmpExst : existingMarkTagList )       
            existingMarkTagMap.put(tmpExst.TagValue__c,tmpExst);            
         for (String tag:tobeAddedMarkTag) {
            if(existingMarkTagMap.containsKey(tag))         
            {
                existingMarkTagMap.get(tag).counter__c++;
                commMarkTags.add(existingMarkTagMap.get(tag));                                            
            } else {
                CommMarketingTags__c commMarkTag = new CommMarketingTags__c();
                commMarkTag.TagValue__c = tag;            
                commMarkTags.add(commMarkTag);
            }    
        }
        System.debug('commMarkTags===='+commMarkTags.size()); 
        if(commMarkTags.size()>0){
            upsert commMarkTags TagValue__c; 
        }
        system.debug('tobeAddedMarkTag==>' + tobeAddedMarkTag);
        commMarkTags = new List<CommMarketingTags__c>();
        List<CommMarketingTags__c> delMarkTags = new List<CommMarketingTags__c>();
        for (String tag:tobeDeletedMarkTag) {
            if(existingMarkTagMap.containsKey(tag))         
            {
                if(existingMarkTagMap.get(tag).counter__c <= 1){
                    delMarkTags.add(existingMarkTagMap.get(tag));
                }                                            
                 else {
                   existingMarkTagMap.get(tag).counter__c--; 
                   commMarkTags.add(existingMarkTagMap.get(tag));  
                }
            }    
        }
        
        System.debug('commMarkTags===='+commMarkTags.size()); 
        if(commMarkTags.size()>0){
            upsert commMarkTags TagValue__c; 
        }
        System.debug('delMarkTags===='+delMarkTags.size()); 
        if(delMarkTags.size()>0){
            delete delMarkTags ; 
        }      
      
       /* for who I am Marketing to */
        List<String> old_tags = wrapper.expertiseOldValue !=null && wrapper.expertiseOldValue.trim() !='' ? wrapper.expertiseOldValue.split(' ## '):new List<String>(); 
        old_tags.addAll(wrapper.whatIWantToLearnOldValue !=null && wrapper.whatIWantToLearnOldValue.trim() !=''? wrapper.whatIWantToLearnOldValue.split(' ## '):new List<String>());
        
        List<CommProfileTag__c> commProfTags = new List<CommProfileTag__c>();
        List<String> tags = profile.Expertise_in_Marketo__c !=null && profile.Expertise_in_Marketo__c.trim() !='' ?profile.Expertise_in_Marketo__c.split(' ## '):new List<String>(); 
        tags.addAll(profile.What_I_want_to_learn_more_about__c !=null && profile.What_I_want_to_learn_more_about__c.trim() !=''?profile.What_I_want_to_learn_more_about__c.split(' ## '):new List<String>());
        
        set<String> setListOld = new Set<String>();setListOld.AddAll(old_tags);
        set<String> setListNew = new Set<String>();setListNew.addAll(tags);
        set<String> setMaster = new Set<String>();setMaster.addAll(tags);setMaster.addAll(old_tags);
        List<String> tobeDeletedTag = new List<String>();
        List<String> tobeAddedTag = new List<String>();
        for(String strEle : setMaster)
        {
           if(!setListNew.contains(strEle)) {
               tobeDeletedTag.add(strEle);           
           }
           if(!setListOld.contains(strEle)) {
               tobeAddedTag.add(strEle);           
           }
        }
        
        system.debug('tobeAddedTag==>' + tobeAddedTag);
                                
        List<CommProfileTag__c> ExistingList = [SELECT TagValue__c,sort_order__c,counter__c from CommProfileTag__c WHERE sort_order__c = 0 and ( TagValue__c in :tobeAddedTag Or TagValue__c in :tobeDeletedTag ) ];
        Map<String,CommProfileTag__c> existingTagMap = new Map<String,CommProfileTag__c>();
        for(CommProfileTag__c tmpExst : ExistingList)       
            existingTagMap.put(tmpExst.TagValue__c,tmpExst);            
            
        for (String tag:tobeAddedTag) {
            if(existingTagMap.containsKey(tag))         
            {
                existingTagMap.get(tag).counter__c++;
                commProfTags.add(existingTagMap.get(tag));                                            
            } else {
                CommProfileTag__c comProfTag = new CommProfileTag__c();
                comProfTag.TagValue__c = tag;            
                commProfTags.add(comProfTag);
            }    
        }
        System.debug('commProfTags===='+commProfTags.size()); 
        if(commProfTags.size()>0){
            upsert commProfTags TagValue__c; 
        }
        
        commProfTags = new List<CommProfileTag__c>();
        List<CommProfileTag__c> delProfTags = new List<CommProfileTag__c>();
        for (String tag:tobeDeletedTag) {
            if(existingTagMap.containsKey(tag))         
            {
                if(existingTagMap.get(tag).counter__c <= 1){
                    delProfTags.add(existingTagMap.get(tag));
                }                                            
                 else {
                   existingTagMap.get(tag).counter__c--; 
                   commProfTags.add(existingTagMap.get(tag));  
                }
            }    
        }
        
        System.debug('commProfTags===='+commProfTags.size()); 
        if(commProfTags.size()>0){
            upsert commProfTags TagValue__c; 
        }
        System.debug('delProfTags===='+delProfTags.size()); 
        if(delProfTags.size()>0){
            delete delProfTags; 
        }      
      
        if(wrapper.CntctID <> null){                             
            Contact myCnt = [SELECT Phone,preferred_language__c,MobilePhone from contact where id =:wrapper.CntctID];
            Community_Profile__c usrgroup = [Select Member_of_User_group__c from Community_Profile__c where User__c = :UserInfo.getUserId() LIMIT 1];           
            myCnt.Phone=wrapper.phone;    
            myCnt.MobilePhone = wrapper.mobileNo;
            myCnt.User_Group_Comments__c = usrgroup.Member_of_User_group__c;
            myCnt.preferred_language__c   = wrapper.PreferredLanguage;
            upsert myCnt ;  
        } 
        
        //ImageCrop();
        //PageReference profilePage = Page.MarketoCommunityProfile;
        PageReference profilePage = Page.MarketoCommunityProfile;
        profilePage.getParameters().put('id', UserInfo.getUserId());
        profilePage.getParameters().put('msg','message');
        profilePage.setRedirect(true);
        return profilePage;
    }
    
    public PageReference cancel() {
        PageReference profilePage = Page.MarketoCommunityProfile;
        profilePage.getParameters().put('id', UserInfo.getUserId());
        profilePage.setRedirect(true);
        return profilePage;
    }   
    
    public Boolean validatePhone(String phoneNumber)
    {
        if (phoneNumber != null)
        {
            String regxPattern = ''; String numPattern = '';            
            if(phoneNumber.startsWith('+'))     
            {                                   
                regxPattern = '^[+][0-9]\\d{9,12}$';//'^[2-9]\\d{9}$''^([2-9]\\d{2})\\d{3}\\d{4}$';
                numPattern = '[0-9]{12,13}';
            }
            else
            {                   
                regxPattern = '^\\(?([0-9]{3})\\)\\s{0,1}([0-9]{3})-([0-9]{4})$';// '^([2-9]\\d{2})\\d{3}\\d{4}$'
                numPattern = '[0-9]{10}';             
            }
            Pattern phonePattern = Pattern.compile(regxPattern);//'\\D*?(\\d\\D*?){10}');
            Pattern numericPattern = Pattern.compile(numPattern);
            Matcher phoneMatcher = phonePattern.matcher(phoneNumber); 
            Matcher numericMatcher = numericPattern.matcher(phoneNumber);                    
            if(phoneMatcher.matches())
            { 
                System.debug('validatePhone'+ phoneNumber);                                   
                return true;               
            }            
        }                   
        return false;
    }
    
    public static testMethod void testController() {
       
        PageReference pageRef = Page.MarketoCommunityProfileEdit;
        Test.setCurrentPage(pageRef);
        
        MarketoCommunityProfileEditController controller = new MarketoCommunityProfileEditController();
        /* 09-03-11 vishals@grazitti.com Added/Modified below lines to increase code coverage */
        controller.wrapper = new ProfileWrapper();
        controller.wrapper.documentBody = Blob.valueOf('Test attach');
        controller.wrapper.documentName = 'Test attach';
        controller.init();
       
        controller.wrapper.phone = '(819)555-5555';
        controller.wrapper.mobileno = '+919417268760';
        controller.save();
        List<Document> listDocuments = [select Id from Document limit 1];
       // system.debug('listDocuments-->'+listDocuments);
        if(listDocuments.size() > 0){
            controller.profile.Profile_Picture_ID__c = listDocuments.get(0).Id;
        }
        update controller.profile;
        
        controller.validatePhone(controller.wrapper.phone );
        controller.getHasPicture();     
       // controller.deletePicture();
        controller.cancel();
        controller.getMonthsForDate();
        controller.getYearsForDate();        
        controller.unsusbscribeFromCaseSurvey();
    }
    
    /* 14-03-11 vishals@grazitti.com Added below method to increase code coverage */
    @isTest
    public static void testController1() {
    
        Test.startTest();
        List<Community_Profile__c> validUser = [select Id, CSatSurveyPreferences__c, Display_Name__c, Company_Name__c, Title__c, Location__c, Website__c,CRM__c,User__c,
                              About_Me__c, Facebook__c, LinkedIn__c, Twitter__c, Profile_Picture_ID__c,Date_I_Started_Using_Marketo__c,Member_Of_User_Group__c,Date_I_became_customer__c,Expertise_in_Marketo__c,What_I_want_to_learn_more_about__c
                       from Community_Profile__c
                       where Profile_Picture_ID__c != null Limit 1];        
        if(validUser.isEmpty() ==false) 
        {
            User u2  = new User();
            try {
                u2  = [SELECT ID from User where Id =:validUser[0].User__c limit 1];
            } catch (Exception ex) {
                System.debug('Exception==>'+ ex);
            }            
            if(u2 != null){        
                System.runAs(u2) {
                    PageReference pageRef = Page.MarketoCommunityProfileEdit;
                    Test.setCurrentPage(pageRef);
                    ProfileWrapper  wrapper  = new ProfileWrapper();
                    wrapper.documentBody = Blob.valueOf('Test attach');
                    wrapper.documentName = 'Test attach';

                    MarketoCommunityProfileEditController controller = new MarketoCommunityProfileEditController();
                    controller.wrapper = wrapper;
                    //controller.wrapper.documentBody = Blob.valueOf('Test attach');
                    //controller.wrapper.documentName = 'Test attach';

                    controller.init();
                    controller.saveProfilePic();
                    controller.cropProfilePic();
                   // controller.getStateName();
                    controller.wrapper.phone = '(819)555-5555';
                    controller.wrapper.mobileno = '+18195555555';
                    controller.save();
                    List<Document> listDocuments = [select Id from Document limit 1];
                    system.debug('listDocuments-->'+listDocuments);
                    if(listDocuments.size() > 0){
                        controller.profile.Profile_Picture_ID__c =  validuser[0].Profile_Picture_ID__c; //listDocuments.get(0).Id;
                    }
                    controller.profile.Facebook__c = 'abc@fbook.com';
                    controller.profile.Twitter__c = 'abc@twitte.com';
                    controller.profile.LinkedIn__c = 'abc@linked.com';
            
                    CommProfileTag__c c1 = new CommProfileTag__c();
                    CommProfileTag__c c2 = new CommProfileTag__c();
                    CommProfileTag__c c3 = new CommProfileTag__c();
                    CommProfileTag__c c4 = new CommProfileTag__c();
                    CommProfileTag__c c5 = new CommProfileTag__c();
                    c1.TagValue__c = 'test1'; c1.sort_order__c = 0; c1.counter__c = 1; insert c1; 
                    c2.TagValue__c = 'test2'; c2.sort_order__c = 0; c2.counter__c = 2; insert c2; 
                    c3.TagValue__c = 'test3'; c3.sort_order__c = 0; c3.counter__c = 3; insert c3; 
                    c4.TagValue__c = 'test4'; c4.sort_order__c = 0; c4.counter__c = 1; insert c4; 
                    c5.TagValue__c = 'test5'; c5.sort_order__c = 0; c5.counter__c = 2; insert c5; 
                           
                                               
                    controller.wrapper.expertiseOldValue = 'test3 ## test2';
                    controller.wrapper.whatIWantToLearnOldValue = 'test1 ## test4 ##test5';
                    
                    Community_Profile__c profile = new Community_Profile__c();
                    profile.Expertise_in_Marketo__c = 'test1 ## test2';
                    profile.What_I_want_to_learn_more_about__c ='test3 ## test5';
                     
                    
                    update controller.profile;
                    controller.save();
                   // controller.deletePicture();
                    controller.unsusbscribeFromCaseSurvey();
                }
            }
        }
        
        Test.stopTest();
            
    }

}