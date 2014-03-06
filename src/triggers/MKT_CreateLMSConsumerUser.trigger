trigger MKT_CreateLMSConsumerUser on User (after insert) {
    final Integer PACK_SIZE  = 10;

    List<Id> usersIdsToAddToCyberU = new List<Id>();


    for (User u : Trigger.new) {
        if (u.lmscons__Cornerstone_ID__c == null && (u.UserType.toLowerCase().contains('customer') || u.IsPortalEnabled)) {
            usersIdsToAddToCyberU.add(u.Id);
        }
    }

    if (usersIdsToAddToCyberU.size() <= 0 || usersIdsToAddToCyberU.size() > 5) {
        return;
    }

    Id[] usrsPack = new Id[]{};
    Integer iterLeft = usersIdsToAddToCyberU.size();
    for (Id i : usersIdsToAddToCyberU) {
        iterLeft--;
        usrsPack.add(i);
        if (usrsPack.size() < PACK_SIZE && iterLeft > 0) {
            continue;
        }
        MKT_LMSConsumerUserController.SetUsersAsConsumer(usrsPack);
        usrsPack = new Id[]{};
    }
}