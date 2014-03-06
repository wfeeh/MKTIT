@isTest (SeeAllData=true)
public class TestSMB_SendSurveyOnLP_Closed{

     /*****Code for unit testing ---started*****/
    public static testMethod void testTrigger() {
        Account ac = new Account(
                       Name ='AccTestSMB-2',
                       Business_Unit__c = 'AMER-SB'
                     );
        insert ac;
        ac.Business_Unit__c = 'AMER-SB';
        update ac;
        opportunity op = new opportunity(
                        Sub_Start_Date__c = system.today().addDays(-111),
                        SFDC_Edition__c = 'Enterprise',
                        RequestedKickoffDate__c = system.today().addDays(-3),
                        CRM_System__c = 'NetSuite',
                        Name = 'OPPTestSMB-2',
                        StageName = 'Closed Won',
                        CloseDate = system.today()
                        
        );
        insert op;
        
        clzV5__Clarizen_Resource__c cr = new clzV5__Clarizen_Resource__c(
                                              Name ='SMBResourceTestSMB-2',
                                              clzV5__CLZ_State__c = 'Active'
                                          );
        insert cr;
        clzV5__Clarizen_Project__c lpProj = new clzV5__Clarizen_Project__c(
                                                Name = 'SMBProjectTest-2',
                                                clzV5__CLZ_N_ProjectManager__c = cr.Id,
                                                clzV5__CLZ_State__c = 'Active',
                                                CLZ_C_BusinessUnit__c = 'AMER-SB',
                                                CLZ_C_ProjectFamily__c = 'MLMLP',
                                                clzV5__CLZ_Customer__c= ac.Id,
                                                clzV5__CLZ_ProjectType__c = 'BASELP',
                                                clzV5__Opportunity__c = op.Id
                                                
                                               );
        insert lpProj ;    
        system.debug(lpProj+'AFTERINSERT'); 
        SMB_Survey_Util.run = true;
        lpProj.clzV5__CLZ_State__c = 'Completed';
        update lpProj ;
        system.debug(lpProj+'AFTERTRIGGER');
      
    }
    
    
    public static testMethod void testschedule() {
        Test.StartTest();
       
        SMB_ScheduledSurveyMail sh1 = new SMB_ScheduledSurveyMail();
        DateTime timeToSendMail = system.now().addseconds(200);
        String sch = '' + timeToSendMail.second() + ' ' + timeToSendMail.minute() + ' ' + timeToSendMail.hour() + ' ' + timeToSendMail.day() + ' ' + timeToSendMail.month() + ' ? ' + timeToSendMail.year();
        String sId = system.schedule('Test'+system.now(), sch, sh1);
        clzV5__Clarizen_Project__c lpProj = new clzV5__Clarizen_Project__c(
                                                clzV5__CLZ_State__c = 'Active',
                                                CLZ_C_BusinessUnit__c = 'AMER-MM',
                                                CLZ_C_ProjectFamily__c = 'MLMLP'
        
                                                );
        insert lpProj ;  
        SMB_SheduledJobInfo__c  jobProj = new  SMB_SheduledJobInfo__c(
                                           SheduledJobId__c = sId,
                                           ProjectId__c = lpProj.Id
                                          );
        insert jobProj ;
        Test.stopTest();
        
        }
}