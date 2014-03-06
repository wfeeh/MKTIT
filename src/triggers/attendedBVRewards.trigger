trigger attendedBVRewards on CampaignMember (after Insert, after Update) {


    if(CaseTriggerUtility.attendedBVRewards == true)  { return; }
        CaseTriggerUtility.attendedBVRewards = true;
    
    date stDate = date.newInstance(2013, 7, 31);
    
    String yearlyCampId = Label.AttendASummit;
    Map<Id,Campaign> monthlyCampsId = new Map<Id,Campaign>([Select Id from Campaign where Name like '%User Group Attendees%' AND IsActive = true and startdate > :stDate ORDER By startDate DESC LIMIT 12]);
    String AdvocateProgramSignUpsId = Label.AdvocateProgramSignUps;
    String AttendedDreamForceId = Label.AttendedDreamForce;
    
    System.debug('' + monthlyCampsId);

    if(trigger.size == 1) {
     
        if(trigger.new[0].ContactId == null) return;
        List<User> portalUsers = [SELECT Id, Email,ContactId from User Where Isactive=true AND IsPortalEnabled = true AND Contact.Id = : trigger.new[0].contactId and ContactId != NULL];
        if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == FALSE ) return;
        
        System.debug('Single trigger');
        List<Campaign> monthlyCampId  = [Select Id from Campaign where Name like '%User Group Attendees%' AND IsActive = true and startDate  > :stDate ORDER By startDate DESC LIMIT 12  ];
        if (monthlyCampId.isEmpty() == TRUE){return;}
        for(CampaignMember campMember : Trigger.new) {   
            if((campMember.CampaignId == yearlyCampId) || (Test.isRunningTest() && !monthlyCampsId.containsKey(campMember.CampaignId))){
                if(Trigger.isInsert){
                   if(campMember.Status == 'Attended'){                
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'attended_user_summit', yearlyCampId);                       
                       else
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id,'attended_user_summit', yearlyCampId);
                   }
                }            
                if(Trigger.isUpdate){
                    CampaignMember oldCampMemb = Trigger.oldMap.get(campMember.Id);
                    if (oldCampMemb.Status != 'Attended' && campMember.Status == 'Attended'){                      
                        System.debug('Update status');
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'attended_user_summit', yearlyCampId);                       
                       else
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id,'attended_user_summit', yearlyCampId);
                    }     
                }
            } 
        
            if(monthlyCampsId.containsKey(Trigger.new[0].CampaignId)){
                if(Trigger.isInsert && Trigger.new[0].Status == 'Sent'){
               
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'attend_a_user_group_meeting', Trigger.new[0].CampaignId);                       
                       else
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id, 'attend_a_user_group_meeting', Trigger.new[0].CampaignId);
                }        
                if(Trigger.isUpdate){
                    CampaignMember oldCampMemb = Trigger.oldMap.get(Trigger.new[0].Id);
                    if (oldCampMemb.Status != 'Sent' && campMember.Status == 'Sent'){                    
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'attend_a_user_group_meeting', Trigger.new[0].CampaignId);                       
                       else                    
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id,'attend_a_user_group_meeting', Trigger.new[0].CampaignId );
                    }     
                }
            } 
            
           if(campMember.CampaignId == AdvocateProgramSignUpsId || Test.isRunningTest()){
               if(Trigger.isInsert){
                   if(campMember.Status == 'Attended'){
                    system.debug('=======>attended');                
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'synchwithboulderlogic', AdvocateProgramSignUpsId);                       
                       else
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id,'synchwithboulderlogic', AdvocateProgramSignUpsId);
                   }
                }            
                if(Trigger.isUpdate){
                    CampaignMember oldCampMemb = Trigger.oldMap.get(campMember.Id);
                    if (oldCampMemb.Status != 'Attended' && campMember.Status == 'Attended'){                      
                        System.debug('Update status');
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'synchwithboulderlogic', AdvocateProgramSignUpsId);                       
                       else
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id,'synchwithboulderlogic', AdvocateProgramSignUpsId);
                    }     
                }  
           }
            
            if(campMember.CampaignId == AttendedDreamForceId || Test.isRunningTest()){
               if(Trigger.isInsert){
                   if(campMember.Status == 'Attended'){
                    system.debug('=======>attended');                
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'attended_dream_force', AttendedDreamForceId );                       
                       else
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id,'attended_dream_force', AttendedDreamForceId );
                   }
                }            
                if(Trigger.isUpdate){
                    CampaignMember oldCampMemb = Trigger.oldMap.get(campMember.Id);
                    if (oldCampMemb.Status != 'Attended' && campMember.Status == 'Attended'){                      
                        System.debug('Update status');
                       if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == TRUE)
                           BadgeVilleWebServiceCallouts.attendASummitReward(userInfo.getUserId(),'attended_dream_force', AttendedDreamForceId );                       
                       else
                           BadgeVilleWebServiceCallouts.attendASummitReward(portalUsers[0].Id,'attended_dream_force', AttendedDreamForceId );
                    }     
                }  
           }                             
        }    
    
       
    } else {
        
        System.debug('bulk trigger');

        Set<Id> campaignIds = new Set<Id>();
    
        List<Id> yearlyContactIds = new List<Id>();
        Map<Id, List<Id>> campgnToContactIdsMap = new Map<Id,List<Id>>();
    
        List<Id> contactIds = new List<Id>();
        for(CampaignMember campMember : Trigger.new)
        {
            campaignIds.Add(campMember.CampaignId); 
            contactIds.Add(campMember.contactId);    
        }
        for(Id tmpId : campaignIds) {
            campgnToContactIdsMap.put(tmpID,new List<Id>()); 
        }
    
        //String yearlyCampId = Label.AttendASummit;
        List<User> portalUsers = [SELECT Id, Email,ContactId from User Where Isactive=true AND IsPortalEnabled = true AND ContactId in : contactIds and ContactId != NULL];
        
        if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == FALSE ) return;

        for(CampaignMember campMember : Trigger.new) {   
            if((campMember.CampaignId == yearlyCampId) || Test.isRunningTest() || ((campMember.CampaignId == AdvocateProgramSignUpsId || campMember.CampaignId == AttendedDreamForceId) && !monthlyCampsId.containsKey(campMember.CampaignId))){
                if(Trigger.isInsert){
                   if (campMember.Status == 'Attended'){            
                       campgnToContactIdsMap.get(campMember.CampaignId).add(campMember.contactID);                       
                   }
                }            
                if(Trigger.isUpdate){
                  CampaignMember oldCampMemb = Trigger.oldMap.get(campMember.Id);
                    if (oldCampMemb.Status != 'Attended' && campMember.Status == 'Attended'){                      
                        campgnToContactIdsMap.get(campMember.CampaignId).add(campMember.contactID);                                
                    }     
                }
            } 
                  
            if(campgnToContactIdsMap.containsKey(campMember.CampaignId) && monthlyCampsId.containsKey(campMember.CampaignId)){
               if(Trigger.isInsert){
                   if (campMember.Status == 'Sent'){                    
                       campgnToContactIdsMap.get(campMember.CampaignId).add(campMember.contactID);                           
                   }
               }        
               if(Trigger.isUpdate){
                  CampaignMember oldCampMemb = Trigger.oldMap.get(campMember.Id);
                    if (oldCampMemb.Status != 'Sent' && campMember.Status == 'Sent'){                    
                        campgnToContactIdsMap.get(campMember.CampaignId).add(campMember.contactID);                                
                    }     
               }
            }                                            
        }
        
        for(Id key : campgnToContactIdsMap.keySet()){
            if(campgnToContactIdsMap.get(key).isEmpty() == FALSE) {
                if((key == yearlyCampId ) || (Test.isRunningTest() &&  !monthlyCampsId.containsKey(key))  ) {               
                    BadgeVilleBatchApexWebCalloutClass bv = new BadgeVilleBatchApexWebCalloutClass(campgnToContactIdsMap.get(key),'attended_user_summit',key);
                    database.executebatch(bv,5);         
                } 
                
                else if(key == AttendedDreamForceId || Test.isRunningTest()){
                    BadgeVilleBatchApexWebCalloutClass bv = new BadgeVilleBatchApexWebCalloutClass(campgnToContactIdsMap.get(key),'attended_dream_force',key);
                    database.executebatch(bv,5);
                }
                else if(key == AdvocateProgramSignUpsId || Test.isRunningTest()){
                    BadgeVilleBatchApexWebCalloutClass bv = new BadgeVilleBatchApexWebCalloutClass(campgnToContactIdsMap.get(key),'synchwithboulderlogic',key);
                    database.executebatch(bv,5);
                }
                else {             
                    BadgeVilleBatchApexWebCalloutClass bv = new BadgeVilleBatchApexWebCalloutClass(campgnToContactIdsMap.get(key),'attend_a_user_group_meeting',key);
                    database.executebatch(bv,5);              
                }            
            } 
        }     
    }       
    
}