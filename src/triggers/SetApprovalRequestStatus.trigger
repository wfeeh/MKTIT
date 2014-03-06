trigger SetApprovalRequestStatus on Quote (after update) {
    SetApprovalRequestStatusController sa = new SetApprovalRequestStatusController();
    sa.setApprovalRequestStatus(Trigger.new, Trigger.newMap, Trigger.oldMap);
    sa.reSetApprovalRequestStatus(Trigger.new, Trigger.newMap, Trigger.oldMap);
}