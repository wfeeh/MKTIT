/*===========================================================================+

   DATE       DEVELOPER      DESCRIPTION
   ====       =========      ===========
09/10/2013  Pankaj Verma          Trigger for Certification_History__c Object
                                  There is also a field called Account, which is a lookup to Account.
                                  trigger written will update the Account on the record, with the Account
                                  from the Certification Contact on that same record. 
                           

+===========================================================================*/


trigger CertificationHistory_updateAccount on Certification_History__c(before insert, before update) {

    /*varible sdeclaration*/
    set < Certification_History__c > ch_set = new set < Certification_History__c > ();
    set < ID > contact_set = new set < ID > ();

    for (Certification_History__c ch: trigger.new) {

        contact_set.add(ch.Certification_Contact__c);
    }
  //  map < ID, Contact > AccContmap = new map < ID, Contact > ([SELECT ID, NAME, AccountId from Contact where ID IN: contact_set]);
//fix business email request bug no http://eventum.grazitti.com/view.php?id=5578
map < ID, Contact > AccContmap = new map < ID, Contact > ([SELECT ID, NAME,EMAIL, AccountId from Contact where ID IN: contact_set]);

    for (Certification_History__c ch_rec: trigger.new) {

        if (ch_rec.Certification_Contact__c != null) {
            ch_rec.Account__c = AccContmap.get(ch_rec.certification_contact__c).AccountID;
            ch_rec.Business_Email_Address__c=AccContmap.get(ch_rec.certification_contact__c).EMAIL;

        }

    }


}