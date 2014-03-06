public Class CertificationRegistrationController{

   

    public String recId{get;set;}
    public String transactionId{get;set;}
    
    public Certification_History__c certificate{get;set;}
        
    public CertificationRegistrationController() {

            List<Community_Profile__c> profile    = [select Id, Company_Name__c from Community_Profile__c where User__c = :UserInfo.getUserId() Limit 1];
            User userDetail                       = [select Id,ContactId, FirstName, LastName, Email, CompanyName from User where Id = :UserInfo.getUserId()];
            
            certificate                           = new Certification_History__c();
            certificate.First_Name__c             = userDetail.FirstName; 
            certificate.Last_Name__c              = userDetail.LastName;  
            certificate.Personal_Email_Address__c = userDetail.Email;
            certificate.Company__c                = profile.size() != 0?profile[0].Company_Name__c:null;
    }
    
    public void savePayment() {
        User loggedUser = [Select id, contactid from User where id=:UserInfo.getUserId() limit 1];
        certificate.Transaction_Status__c     = false;
        certificate.Certification_Contact__c  = loggedUser.contactid;
        certificate.Transaction_Id__c         = null;
        insert certificate;
        recId                                 = certificate.Id;
        
        System.Debug('recId'+recId);
    }
    
    public void confirmPayment(){
    
        Certification_History__c updateObject = [Select Id from Certification_History__c where id =: recId Limit 1];
        updateObject.Transaction_Status__c = true;
        updateObject.Transaction_Id__c     = transactionId;
        update updateObject;
    
    }
    
    @isTest(SeeAllData=true)
    public static void testCertification() {
        PageReference pageRef = Page.certificationregistration;     
        Test.setCurrentPage(pageRef);
        CertificationRegistrationController con = new CertificationRegistrationController();    
    }
}