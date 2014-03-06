public class MarketoLeftSideBarController  {
    public loggedUser logged_user{get;set;}
    public MarketoLeftSideBarController(){
        logged_user = new loggedUser();
        User user = [select id, companyname, Name, UserRole.Name, Profile.Name, LanguageLocaleKey from User where id = :Userinfo.getUserId()];
        
        logged_user.CompanyName = user.companyname;
        logged_user.name        = user.Name;
        userRole urole          = new userRole();
        urole                   = user.UserRole;
        logged_user.role        = urole.Name;
        logged_user.language    = user.LanguageLocaleKey; 
    }
    
    public class loggedUser{
        public String CompanyName{get;set;}
        public String name{get;set;}
        public String role{get;set;}
        public String language{get;set;}
    }
}