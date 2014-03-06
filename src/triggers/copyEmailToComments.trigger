Trigger copyEmailToComments on EmailMessage (after insert) {

  EmailMessageActions actions = new EmailMessageActions();
  
  if (trigger.isAfter) {
    if (Trigger.isInsert) {
        //for(EmailMessage e: Trigger.new) {
            //if (e.Incoming = false) {
            actions.doAfterInsert(trigger.new);
            //}
       //}
    }  
  }
  
}