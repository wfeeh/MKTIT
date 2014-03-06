/*
 * This class needs to be scheduled in order for it to run.
 *
 * The following code can be executed anonymously via the
 * System Log to schedule this class to run:
 *
 * // Run Monday - Friday at 6AM.
 * System.Schedule('Certification Expiration Scheduler',  '0 0 6 ? * MON-FRI', new CertificationRewardExpirationSchedulable());
 *
 * // Run on demand.
 * CertificationRewardExpirationSchedulable schedulable = new CertificationRewardExpirationSchedulable();
 * schedulable.execute(null);
 */
global class CertificationRewardExpirationSchedulable implements Schedulable {

    global void execute(SchedulableContext context) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String typeCustomer;
        Set<String> certificationsIds = new Set<String>();
        Date Today = Date.Today();
        List<Certification_History__c> certHistoryRecs = [SELECT Id, Name, Certification_Expiration_Date__c,Certification_Contact__c, Date_Passed_Exam__c, Related_MCE_Record__c, Certification_Level__c, BadgeVilleReward_Status__c   FROM Certification_History__c where Certification_Expiration_Date__c = :Today and BadgeVilleReward_Status__c = true];
        system.debug('*****CertHistoryRecs******'+certHistoryRecs.size());
      
        
        for (Certification_History__c certRec: CertHistoryRecs) { 
            If(certRec.Certification_Expiration_Date__c == Date.Today() && certRec.BadgeVilleReward_Status__c == true){
                 certificationsIds.add(certRec.Id);
                 system.debug('**********CERT ID********'+certificationsIds);
            }
        }
      if(!certHistoryRecs.isEmpty()){
       
        BVBatchCalloutDeleteCertificationClass bv = new BVBatchCalloutDeleteCertificationClass(certificationsIds);
        
        database.executebatch(bv,1);
    
        }
    }
    
}