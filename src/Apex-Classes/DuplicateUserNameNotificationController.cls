public class DuplicateUserNameNotificationController{
    public static Set<Id> userIDSet = new Set<Id>();
    public List<User> userList{get;set;}
    
    public DuplicateUserNameNotificationController(){
        userList = new List<User>();
        if(userIDSet.size() > 0){
            userList = [select id, FirstName, LastName from User where id in :userIDSet];
        }
    }
}