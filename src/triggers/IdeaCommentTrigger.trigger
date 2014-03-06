// Trigger to send email notification on new comment on an idea
trigger IdeaCommentTrigger on IdeaComment (after insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        Set<Id> ids = new Set<Id>();
        for (IdeaComment ideaComm : Trigger.new) {
            ids.add(ideaComm.Id);
        }
        GlobalFunctions.sendCommentNotifications(ids);
    }
}