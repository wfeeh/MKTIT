trigger MKT_CreateEmailWorkflowInCyberU on lmsilt__Roster__c (after insert, after update) {
    List<MKT_Email_Workflow_in_CyberU__c> eWorkflowList = new List<MKT_Email_Workflow_in_CyberU__c>();
    Set<Id> RosterIdSet = new Set<Id>();
    Map<Id, lmsilt__Class__c> EventIdClassMap = new Map<Id, lmsilt__Class__c>();
    Map<Id, Id> ClassIdUserMap = new Map<Id, Id>();
    Map<Id, String> ClassIdUserNameMap = new Map<Id, String>();
    Set<Id> ClassIdSet = new Set<Id>();
    Set<Id> ProductSet = new Set<Id>();
    Set<Id> UserSet = new Set<Id>();
    List<lmsilt__Roster__c> rostersForUpdate = new List<lmsilt__Roster__c>();
    Map<Id, lmsilt__Roster__c> RosterIdObjectMap = new Map<Id, lmsilt__Roster__c>();
    if (Trigger.isInsert && Trigger.isAfter) {
        for (lmsilt__Roster__c newRoster : trigger.new) {
                RosterIdSet.Add(newRoster.Id);
                ClassIdSet.add(newRoster.lmsilt__Class__c);
                ClassIdUserMap.put(newRoster.lmsilt__Class__c, newRoster.lmsilt__Student__c);
        }
        List<lmsilt__Roster__c> rosters = [SELECT ID, lmsilt__Class__c, lmsilt__Student__c, lmsilt__Student__r.Name, lmsilt__Class__r.lmsilt__Event__c, lmsilt__Class__r.lmsilt__Event__r.Product__c, MKT_Opportunity__c FROM lmsilt__Roster__c WHERE ID IN :RosterIdSet];
        for (lmsilt__Roster__c RosterItem : rosters) {
            ClassIdUserNameMap.put(RosterItem.lmsilt__Class__c, RosterItem.lmsilt__Student__r.Name);
            ProductSet.Add(rosterItem.lmsilt__Class__r.lmsilt__Event__r.Product__c);
            UserSet.Add(rosterItem.lmsilt__Student__c);
        }
        List<MKT_PaymentLicense__c> PaymentLicenseList = [Select User__c, MKT_Payment__r.MKT_Opportunity__c, MKT_Payment__r.Product__c, MKT_Payment__r.Account__c,MKT_Payment__c From MKT_PaymentLicense__c WHERE User__c IN :UserSet AND MKT_Payment__r.Product__c IN :ProductSet AND Canceled__c = false AND MKT_Payment__r.MKT_Opportunity__c != NULL];
        for (lmsilt__Roster__c rosterItem :rosters) {
            for(MKT_PaymentLicense__c pl : PaymentLicenseList) {
                if (rosterItem.MKT_Opportunity__c == NULL && rosterItem.lmsilt__Student__c == pl.User__c && rosterItem.lmsilt__Class__r.lmsilt__Event__r.Product__c == pl.MKT_Payment__r.Product__c) {
                    rosterItem.MKT_Opportunity__c = pl.MKT_Payment__r.MKT_Opportunity__c;
                    rostersForUpdate.Add(rosterItem);
                    break;
                }
            }
        }
        List<lmsilt__Class__c> ClassesList =[SELECT Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Event__r.lmsilt__Description__c, lmsilt__Location__r.Name, lmsilt__Location__r.lmsilt__City__c, lmsilt__Location__r.lmsilt__Contact_Phone__c, lmsilt__Location__r.lmsilt__Country__c,
                                                lmsilt__Location__r.lmsilt__Postal_code__c, lmsilt__Location__r.lmsilt__Region__c, lmsilt__Location__r.lmsilt__Room__c, lmsilt__Location__r.lmsilt__State__c, lmsilt__Location__r.lmsilt__Street_Address__c,lmsilt__Location__r.lmsilt__Type__c, lmsilt__Location__r.lmsilt__ZIP__c,lmsilt__Location__r.ArrivalText__c,lmsilt__Location__r.Accommodations__c,
                                                (SELECT Id, IsDeleted, Name, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Class__c, lmsilt__Event__c, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c, MKT_MultiDaySession__c FROM lmsilt__Sessions__r ORDER BY lmsilt__Start_Date_Time__c),
                                                (SELECT lmsilt__Error__c, lmsilt__JoinUrl__c, lmsilt__confirmationUrl__c, lmsilt__registrantKey__c FROM lmsilt__GoToTraining_Sessions__r)
                                                FROM lmsilt__Class__c WHERE Id IN :ClassIdSet];

        List<lmsilt__Material__c> MaterialsList = [SELECT Id, lmsilt__Class__c, lmsilt__Sequence__c, lmsilt__Description__c, lmsilt__Instructions__c, Name, (SELECT Id, Name FROM Attachments) FROM lmsilt__Material__c WHERE lmsilt__Class__c IN :ClassIdSet /*OR lmsilt__Event__c IN :EventIdSet*/];
        Map<Id, List<lmsilt__Material__c>> ClassIdMaterialsBeforeMap = new Map<Id, List<lmsilt__Material__c>>();
        Map<Id, List<lmsilt__Material__c>> ClassIdMaterialsAfterMap = new Map<Id, List<lmsilt__Material__c>>();

        for (lmsilt__Material__c MaterialItem : MaterialsList) {
            if (MaterialItem.lmsilt__Sequence__c == 'Anytime' || MaterialItem.lmsilt__Sequence__c == NULL || MaterialItem.lmsilt__Sequence__c == 'Before') {
                List<lmsilt__Material__c> MaterialsListBefore = new List<lmsilt__Material__c>();
                if (ClassIdMaterialsBeforeMap.containsKey(MaterialItem.lmsilt__Class__c)) {
                    MaterialsListBefore = ClassIdMaterialsBeforeMap.get(MaterialItem.lmsilt__Class__c);
                    MaterialsListBefore.Add(MaterialItem);
                }
                else {
                    MaterialsListBefore.Add(MaterialItem);
                }
                ClassIdMaterialsBeforeMap.put(MaterialItem.lmsilt__Class__c, MaterialsListBefore);
            }
            else if (MaterialItem.lmsilt__Sequence__c == 'after') {
                List<lmsilt__Material__c> MaterialsListAfter = new List<lmsilt__Material__c>();
                if (ClassIdMaterialsBeforeMap.containsKey(MaterialItem.lmsilt__Class__c)) {
                    MaterialsListAfter = ClassIdMaterialsAfterMap.get(MaterialItem.lmsilt__Class__c);
                    MaterialsListAfter.Add(MaterialItem);
                }
                else {
                    MaterialsListAfter.Add(MaterialItem);
                }
                ClassIdMaterialsAfterMap.put(MaterialItem.lmsilt__Class__c, MaterialsListAfter);
            }
        }
        for(lmsilt__Class__c ClassItem : ClassesList) {
            //Datetime ClassStartDate = newInstanceGmt(ClassItem.lmsilt__Start_Date__c.year(), ClassItem.lmsilt__Start_Date__c.month(), ClassItem.lmsilt__Start_Date__c.day(), ClassItem.lmsilt__Start_Date__c.hour(), ClassItem.lmsilt__Start_Date__c.minute(), ClassItem.lmsilt__Start_Date__c.second());
            //Datetime ClassEndDate = newInstanceGmt(ClassItem.lmsilt__End_Date__c.year(), ClassItem.lmsilt__End_Date__c.month(), ClassItem.lmsilt__End_Date__c.day(), ClassItem.lmsilt__End_Date__c.hour(), ClassItem.lmsilt__End_Date__c.minute(), ClassItem.lmsilt__End_Date__c.second());
            MKT_Email_Workflow_in_CyberU__c eWorkflow = new MKT_Email_Workflow_in_CyberU__c();
            eWorkflow.User__c = ClassIdUserMap.get(ClassItem.Id);
            eWorkflow.Class__c = ClassItem.Id;
            eWorkflow.ClassName__c = ClassItem.Name;
            eWorkflow.ClassStartTime__c = ClassItem.lmsilt__Start_Date__c.format('h:mm a', 'PST');
            eWorkflow.ClassStartDate__c = ClassItem.lmsilt__Start_Date__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', 'PST') + ' PST';
            eWorkflow.ClassEndTime__c = ClassItem.lmsilt__End_Date__c.format('h:mm a', 'PST');
            eWorkflow.LocationRoom__c = ClassItem.lmsilt__Location__r.lmsilt__Room__c;
            eWorkflow.LocationName__c = ClassItem.lmsilt__Location__r.Name;
            eWorkflow.ArrivalText__c = ClassItem.lmsilt__Location__r.ArrivalText__c;
            eWorkflow.Accommodations__c = ClassItem.lmsilt__Location__r.Accommodations__c;
            eWorkflow.Location__c = ' ';
            eWorkflow.MKT_Username__c = ClassIdUserNameMap.get(ClassItem.Id);
            if (ClassItem.lmsilt__Location__r.Name != NULL && ClassItem.lmsilt__Location__r.Name != '') {
                eWorkflow.Location__c += ClassItem.lmsilt__Location__r.Name;
            }
            if (ClassItem.lmsilt__Location__r.lmsilt__Street_Address__c != NULL && ClassItem.lmsilt__Location__r.lmsilt__Street_Address__c != '') {
                eWorkflow.Location__c +=', ' + ClassItem.lmsilt__Location__r.lmsilt__Street_Address__c;
            }
            if (ClassItem.lmsilt__Location__r.lmsilt__State__c != NULL && ClassItem.lmsilt__Location__r.lmsilt__State__c != '') {
                eWorkflow.Location__c +=', ' + ClassItem.lmsilt__Location__r.lmsilt__State__c ;
            }
            if (ClassItem.lmsilt__Location__r.lmsilt__Postal_code__c != NULL && ClassItem.lmsilt__Location__r.lmsilt__Postal_code__c != '') {
                eWorkflow.Location__c +=', ' + ClassItem.lmsilt__Location__r.lmsilt__Postal_code__c;
            }

            eWorkflow.EventName__c = ClassItem.lmsilt__Event__r.Name;
            eWorkflow.CourseDescription__c = (ClassItem.lmsilt__Event__r.lmsilt__Description__c != NULL) ? ('<pre><span style = "font-size: 10pt; font-family:\'Arial\',\'Helvetica\',\'sans-serif\'">• ' + ClassItem.lmsilt__Event__r.lmsilt__Description__c + '</span></pre>') : '';

            DateTime Reminder3 = ClassItem.lmsilt__Start_Date__c.addHours(-2);
            DateTime Reminder2;
            DateTime Reminder1;
            String dayOfWeek = ClassItem.lmsilt__Start_Date__c.format('EEE', 'PST');
            if (dayOfWeek == 'Mon') {
                Reminder2 = ClassItem.lmsilt__Start_Date__c.addDays(-3);
                Reminder1 = ClassItem.lmsilt__Start_Date__c.addDays(-5);
            }
            else if (dayOfWeek == 'Tue') {
                Reminder2 = ClassItem.lmsilt__Start_Date__c.addDays(-4);
                Reminder1 = ClassItem.lmsilt__Start_Date__c.addDays(-6);
            }
            else if (dayOfWeek == 'Wed') {
                Reminder2 = ClassItem.lmsilt__Start_Date__c.addDays(-2);
                Reminder1 = ClassItem.lmsilt__Start_Date__c.addDays(-5);
            }
            else if (dayOfWeek == 'Thu') {
                Reminder2 = ClassItem.lmsilt__Start_Date__c.addDays(-2);
                Reminder1 = ClassItem.lmsilt__Start_Date__c.addDays(-6);
            }
            else if (dayOfWeek == 'Fri') {
                Reminder2 = ClassItem.lmsilt__Start_Date__c.addDays(-2);
                Reminder1 = ClassItem.lmsilt__Start_Date__c.addDays(-4);
            }
            else {
                Reminder2 = ClassItem.lmsilt__Start_Date__c.addDays(-2);
                Reminder1 = ClassItem.lmsilt__Start_Date__c.addDays(-4);
            }
            eWorkflow.RegistrationReminders1Date__c = (Reminder1 > system.now()) ? Reminder1 : NULL;
            eWorkflow.RegistrationReminders2Date__c = (Reminder2 > system.now()) ? Reminder2 : NULL;
            eWorkflow.RegistrationReminders3Date__c = Reminder3;
            eWorkflow.Sessions__c = '<ul>';
            eWorkflow.SessionsVirtual__c = '<ul>';
            Integer NumberOfSessionsVirtual = 0;
            Integer NumberOfSessions = 0;
            for (lmsilt__Session__c SessionItem : ClassItem.lmsilt__Sessions__r) {
                Integer NumberOfSessionsTemp = 1;
                String DatesSession = '<li><span><b>' + SessionItem.lmsilt__Start_Date_Time__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', 'PST') + ' ' + SessionItem.lmsilt__Start_Date_Time__c.format('h:mm a', 'PST') + ' - ' + SessionItem.lmsilt__End_Date_Time__c.format('h:mm a', 'PST') + ' PST</b></span></li>';
                if (SessionItem.MKT_MultiDaySession__c) {
                    Integer SessionDays = SessionItem.lmsilt__End_Date_Time__c.Day() -  SessionItem.lmsilt__Start_Date_Time__c.Day();
                    for (Integer i = 1; i <= SessionDays; i++) {
                        DatesSession += '<li><span><b>' + SessionItem.lmsilt__Start_Date_Time__c.addDays(i).format('EEEEEEEEE, MMMMMMMMM dd, yyyy', 'PST') + ' ' + SessionItem.lmsilt__Start_Date_Time__c.format('h:mm a', 'PST') + ' - ' + SessionItem.lmsilt__End_Date_Time__c.format('h:mm a', 'PST') + ' PST</b></span></li>';
                        NumberOfSessionsTemp++;
                    }
                }

                if (SessionItem.lmsilt__ILT_vILT__c == 'vILT') {
                    eWorkflow.IsVirtual__c = true;
                    eWorkflow.SessionsVirtual__c += DatesSession;
                    NumberOfSessionsVirtual += NumberOfSessionsTemp;
                }
                if (SessionItem.lmsilt__ILT_vILT__c == 'ILT') {
                    eWorkflow.IsClassroom__c = true;
                    eWorkflow.Sessions__c += DatesSession;
                    NumberOfSessions += NumberOfSessionsTemp;
                }
            }
            eWorkflow.Sessions__c += '</ul>';
            eWorkflow.SessionsVirtual__c += '</ul>';
            eWorkflow.NumberOfSessions__c = String.valueOf(NumberOfSessions);
            eWorkflow.NumberOfSessionsVirtual__c = String.valueOf(NumberOfSessionsVirtual);
            if (eWorkflow.IsVirtual__c == true && eWorkflow.IsClassroom__c == false) {
                eWorkflow.ClassType__c = Label.MKT_Virtual;
            }
            if (eWorkflow.IsVirtual__c == true && eWorkflow.IsClassroom__c == true) {
                eWorkflow.ClassType__c = Label.MKT_ClassroomVirtual;
            }
            if (eWorkflow.IsVirtual__c == false && eWorkflow.IsClassroom__c == true) {
                eWorkflow.ClassType__c = Label.MKT_Classroom;
            }
            if (ClassIdMaterialsBeforeMap.containsKey(ClassItem.Id)) {
                eWorkflow.ClassMaterials__c = '<ul>';
                for (lmsilt__Material__c MaterialsBefore : ClassIdMaterialsBeforeMap.get(ClassItem.Id)) {
                    for (Attachment attachmentItem : MaterialsBefore.Attachments) {
                        eWorkflow.ClassMaterials__c += '<li><a href = "' + Label.MKT_LinkFileDownload+'?file='+ attachmentItem.id + '">' + attachmentItem.Name + '</a></li>';
                    }
                }
                eWorkflow.ClassMaterials__c += '</ul>';
            }
            if (ClassIdMaterialsAfterMap.containsKey(ClassItem.Id)) {
                eWorkflow.ClassMaterialsAfter__c = '<ul>';
                for (lmsilt__Material__c MaterialsAfter : ClassIdMaterialsAfterMap.get(ClassItem.Id)) {
                    for (Attachment attachmentItem : MaterialsAfter.Attachments) {
                        eWorkflow.ClassMaterialsAfter__c += '<li><a href = "' + Label.MKT_LinkFileDownload+'?file='+ attachmentItem.id + '">' + attachmentItem.Name + '</a></li>';
                    }
                }
                eWorkflow.ClassMaterialsAfter__c += '</ul>';
            }
            eWorkflowList.Add(eWorkflow);
        }
        if (eWorkflowList.size() > 0) {
            insert eWorkflowList;
        }
        if (!rostersForUpdate.isEmpty()) update rostersForUpdate;
    }

    if (Trigger.isUpdate) {
        Set<Id> RosterOldIdSet = new Set<Id>();
        for (lmsilt__Roster__c oldRoster : trigger.old) {
            if (!oldRoster.lmsilt__Attended__c) {
                RosterOldIdSet.add(oldRoster.Id);
            }
        }
        for (lmsilt__Roster__c newRoster : trigger.new) {
            if (newRoster.lmsilt__Attended__c && RosterOldIdSet.contains(newRoster.Id)) {
                RosterIdSet.add(newRoster.Id);
                ClassIdSet.add(newRoster.lmsilt__Class__c);
                ClassIdUserMap.put(newRoster.lmsilt__Class__c, newRoster.lmsilt__Student__c);
            }
        }
        for (lmsilt__Roster__c RosterItem : [SELECT ID, lmsilt__Class__c, lmsilt__Student__c, lmsilt__Student__r.Name FROM lmsilt__Roster__c WHERE ID IN :RosterIdSet]) {
            ClassIdUserNameMap.put(RosterItem.lmsilt__Class__c, RosterItem.lmsilt__Student__r.Name);
        }
        for (lmsilt__Class__c ClassItem : [SELECT Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Event__r.lmsilt__Description__c FROM lmsilt__Class__c WHERE Id IN :ClassIdSet]) {
            MKT_Email_Workflow_in_CyberU__c eWorkflow = new MKT_Email_Workflow_in_CyberU__c();
            eWorkflow.User__c = ClassIdUserMap.get(ClassItem.Id);
            eWorkflow.ClassName__c = ClassItem.Name;
            eWorkflow.Class__c = ClassItem.Id;
            eWorkflow.ClassStartTime__c = ClassItem.lmsilt__Start_Date__c.format('h:mm a', 'PST');
            eWorkflow.ClassStartDate__c = ClassItem.lmsilt__Start_Date__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', 'PST') + ' PST';
            eWorkflow.ClassEndTime__c = ClassItem.lmsilt__End_Date__c.format('h:mm a', 'PST');
            eWorkflow.EventName__c = ClassItem.lmsilt__Event__r.Name;
            eWorkflow.CourseDescription__c = (ClassItem.lmsilt__Event__r.lmsilt__Description__c!= NULL) ? ('<pre><span style = "font-size: 10pt; font-family:\'Arial\',\'Helvetica\',\'sans-serif\'">• ' + ClassItem.lmsilt__Event__r.lmsilt__Description__c + '</span></pre>') : '';
            eWorkflow.IsAttended__c = true;
            eWorkflow.MKT_Username__c = ClassIdUserNameMap.get(ClassItem.Id);
            eWorkflowList.add(eWorkflow);
        }
        if (eWorkflowList.size() > 0) {
            insert eWorkflowList;
        }
    }
}