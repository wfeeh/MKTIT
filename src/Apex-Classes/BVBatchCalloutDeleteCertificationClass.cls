global class BVBatchCalloutDeleteCertificationClass Implements Database.Batchable<Certification_History__c>, Database.AllowsCallouts{
   
    global List<Certification_History__c> certificationToTarget;
    global Map<String,String> contactWithUserMap; 
    
    private BVBatchCalloutDeleteCertificationClass (){}
   
    Global BVBatchCalloutDeleteCertificationClass  (Set<String> certifiedHistRecIds)
    {   
         contactWithUserMap = new Map<String,String> ();
         set<String> conIds = new set<String>();
        
        
        certificationToTarget = [select Certification_Contact__c,Certification_level__c from Certification_History__c where Id IN : certifiedHistRecIds];
        
        for(Certification_History__c ch : certificationToTarget ){
            conIds.add(ch.Certification_Contact__c);
        }
        for(User usr : [select id, ContactId from User where isActive = : true AND IsPortalEnabled = true AND ContactId IN : conIds]){
            contactWithUserMap.put(usr.ContactId, usr.Id);
        }
        
    } 
    
    
    global Iterable<Certification_History__c> start(database.batchablecontext BC){
        return (certificationToTarget);    
    }
    
    global void execute(Database.BatchableContext BC, List<Certification_History__c> scope){
        for(Certification_History__c ch : scope){     
              
            String BehaviourId = '51828004484ce957a30024e7'; //prod manual reward id  
            if(ch.Certification_level__c == 'Marketo Certified Expert'){
                //BehaviourId = '515534cd88b6161f92000024'; //sandbox manual reward id    
                BehaviourId = '51828004484ce957a30024e7'; //prod manual reward id 
            }else If(ch.Certification_level__c == 'Marketo Analytics'){
               // BehaviourId = '5212292088b616236f0050ca'; //sandbox manual reward id   
                BehaviourId = '52604261dc70467b10001573'; //prod manual reward id '527134bd91bc99da3f001b5f'
            }else If(ch.Certification_level__c == 'Marketo Certified Consultant'){
                BehaviourId = '52676bf3d04f7f468a0000a6'; //sandbox manual reward id   
              //  BehaviourId = '52604261dc70467b10001573'; //prod manual reward id '527134bd91bc99da3f001b5f'
            }
            if(contactWithUserMap.containsKey(ch.Certification_Contact__c))
            BadgeVilleWebServiceCalloutBatchable.deleteRewardCallout(contactWithUserMap.get(ch.Certification_Contact__c) ,BehaviourId, ch.Id); 
        }
    }    
    global void finish(Database.BatchableContext info){ }//global void finish loop
    
    
}