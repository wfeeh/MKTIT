trigger CreateFollowUpTask on TaskClone__c (After insert,After update) {
    List<Task> followUpTaskList = new List<Task>();
    //List<String> accountOwnerEmails = new List<String>();//in case of custom mail template
    for(TaskClone__c taskclone : Trigger.New){
        if(taskclone.Account_Owner__c == null)
            continue;
        Task followUpTask = new Task();
        followUpTask.Subject = 'Add CSM to opportunity team';
        followUpTask.ActivityDate = date.today().addDays(3);
        followUpTask.Type='AE- CSM Followup';
        followUpTask.description = Label.DomainUrl+taskclone.TaskId__c;
        followUpTask.OwnerId = taskclone.Account_Owner__c;
        followUpTaskList.add(followUpTask);
        //accountOwnerEmails.add(taskclone.Account_Owner_Mail__c);
    }
    if(!followUpTaskList.isEmpty()){
        Database.DMLOptions dmlo = new Database.DMLOptions();
        dmlo.EmailHeader.triggerUserEmail = true;
        Database.SaveResult[] lsr = Database.insert(followUpTaskList,dmlo);
        for(Database.SaveResult sr:lsr){
              if(!sr.isSuccess()){Database.Error err = sr.getErrors()[0]; system.debug('::::Error='+ err );}
        }
    }
    
    
}