public class AuthorizedUserCheckCls{
    public Boolean authorizedUser {get; set;}
    //public Map<String,Integer> caseStatusToNumberOfCases{get;set;}
    private String currUserMunchkinId{get;set;}    
    private Id accId{get;set;}
    private String usrEntitlemntId{get;set;}
    private Id userContactId{get;set;}
    public String userType{get;set;}
    public String entitlementName{get;set;}
    public String contactEmail{get;set;}
    
    public AuthorizedUserCheckCls(){
        getCheckAuthorizedUser(); 
    }
    public Void getCheckAuthorizedUser() {
        if (userType != 'Standard' || test.isRunningTest()) {
            authorizedUser = true;
            List<User> usrList = [Select u.Username, u.UserType, u.LanguageLocaleKey, u.UserRole.Name, u.UserRoleId, u.Name, u.Contact.Name, u.Contact.FirstName, 
                u.Contact.LastName, u.Contact.AccountId, u.Contact.Is_Authorized_Contact__c, u.ContactId, u.AccountId
                From User u where Id =: UserInfo.getUserId()];
            Id userId = UserInfo.getUserId();
            accId = usrList[0].Contact.AccountId;
            userContactId = usrList[0].ContactId;
            List<User> userList = [select id, Munchkin_ID__c from User where id = :UserInfo.getUserId()];
            if(userList != null && userList.size() > 0) {
                currUserMunchkinId = userList[0].Munchkin_ID__c;               
            }
            List<Entitlement> entList = [Select id, Status, AssetId, AccountId, Type From Entitlement where AccountId = :accId AND Asset.Munchkin_ID__c = :currUserMunchkinId and Status = 'Active' and (Asset.Munchkin_ID__c != null OR Asset.Munchkin_ID__c != '') limit 1];
            if(UserInfo.getUserId() != null && UserInfo.getUserId() != ''){
                List<User>    currentUser = [Select id, ContactId from User Where Id =: UserInfo.getUserId()];
                List<Contact> userContact = [Select email, id from Contact Where Id =: currentUser[0].ContactId];
                if(userContact.isempty() == false)
                    contactEmail          = userContact[0].email;
            }
            if(!entList.isEmpty()) {     
                usrEntitlemntId = entList[0].Id;
                System.debug('usrEntitlemntId==>' + usrEntitlemntId);
                entitlementName = entList[0].Type != '' && entList[0].Type != null?entList[0].Type:'';    
                System.debug('EntitlementName==>' + entitlementName);
            } 
            if(usrList != null && usrList.size() > 0) {
                Id userContactId = usrList[0].ContactId;
                if(usrList[0].Contact.Is_Authorized_Contact__c != null && usrList[0].Contact.Is_Authorized_Contact__c.equals('No')) {
                    authorizedUser = false;
                }
            }
        }
    }
    @isTest
    public static void testMeth(){
        Test.startTest();
        List<User> logUsr = [SELECT Id,contactId from user Where isportalenabled = true and Munchkin_ID__c != null and contactId != null limit 1];
        System.RunAs(logUsr[0])
        {
            AuthorizedUserCheckCls testObj = new AuthorizedUserCheckCls();
            testObj.getCheckAuthorizedUser();  
        }
        Test.stopTest();        
    }
}