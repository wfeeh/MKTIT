trigger createTasl on Account (after insert,after update) {
 integer a = 0;
    integer b = 0 ;
     list<Task> Tasklist = new list<Task>();
    Map<Id,Id> RecurringTasks = new Map<Id,Id>();
    Map<Id,Id> RecurringTasks2 = new Map<Id,Id>();
    for(Account record : trigger.new){
   // a++;
  //  b++;
      if(trigger.isinsert || ( trigger.isupdate && trigger.OldMap.get(record.id).CSM_Trigger__c != record.CSM_Trigger__c)){ 
        if(record.Customer_Success_Manager__c != null && record.CSM_Trigger__c != null){  
            if(record.CSM_Trigger__c == 'Elite/Key'){
            a++;
            if(a==1)
            {
               Task obj1 = new Task();
                obj1.Ownerid=record.Customer_Success_Manager__c;
                obj1.whatid=record.id;
                obj1.Subject = 'Weekly Meeting Setup Needed';
                obj1.Description='Please schedule a weekly meeting with our new Elite/Key Customer!';
           //   obj1.ActivityDate=record.Date_Became_a_Customer__c+7; 
                obj1.Isrecurrence = true;
                obj1.recurrenceStartDateOnly = record.Date_Became_a_Customer__c;
                
            //    obj1.recurrenceStartDateOnly = record.Date_Became_a_Customer__c;
                obj1.recurrenceEndDateOnly = record.Date_Became_a_Customer__c+364; 
                obj1.recurrencetype = 'RecursWeekly';
                obj1.RecurrenceDayOfWeekMask = 1;
                obj1.RecurrenceInterval= 1;
                Tasklist.add(obj1); 
              }  
            
                Task obj3 = new Task();
                obj3.whatid=record.id;
                obj3.Ownerid=record.Customer_Success_Manager__c;
                obj3.Subject = 'Quarterly Business Review Prep';
                obj3.Description='Prepare for your Quarterly Review with the Customer';
                obj3.ActivityDate=record.Date_Became_a_Customer__c+76;
                Tasklist.add(obj3);
                
                Task obj4 = new Task();
                obj4.whatid=record.id;
                obj4.Ownerid=record.Customer_Success_Manager__c;
                obj4.Subject = 'Quarterly Business Review';
                obj4.Description='Schedule a Business Review with the customer';
                obj4.ActivityDate=record.Date_Became_a_Customer__c+90;
                Tasklist.add(obj4);
                
                Task obj5 = new Task();
                obj5.whatid=record.id;
                obj5.Ownerid=record.Customer_Success_Manager__c;
                obj5.Subject = 'Quarterly Business Review Prep';
                obj5.Description='Prepare for your Quarterly Review with the Customer';
                obj5.ActivityDate=record.Date_Became_a_Customer__c+166;
                Tasklist.add(obj5);
                
                Task obj6 = new Task();
                obj6.whatid=record.id;
                obj6.Ownerid=record.Customer_Success_Manager__c;
                obj6.Subject = 'Quarterly Business Review';
                obj6.Description='Schedule a Business Review with the customer';
                obj6.ActivityDate=record.Date_Became_a_Customer__c+180;
                Tasklist.add(obj6);
                
                Task obj7 = new Task();
                obj7.whatid=record.id;
                obj7.Ownerid=record.Customer_Success_Manager__c;
                obj7.Subject = 'Quarterly Business Review Prep';
                obj7.Description='Prepare for your Quarterly Review with the Customer';
                obj7.ActivityDate=record.Date_Became_a_Customer__c+256;
                Tasklist.add(obj7);
                
                Task obj8 = new Task();
                obj8.whatid=record.id;
                obj8.Ownerid=record.Customer_Success_Manager__c;
                obj8.Subject = 'Quarterly Business Review';
                obj8.Description='Schedule a Business Review with the customer';
                obj8.ActivityDate=record.Date_Became_a_Customer__c+270;
                Tasklist.add(obj8);
               
                Task obj9 = new Task();
                obj9.whatid=record.id;
                obj9.Ownerid=record.Customer_Success_Manager__c;
                obj9.Subject = 'Quarterly Business Review Prep';
                obj9.Description='Prepare for your Quarterly Review with the Customer';
                obj9.ActivityDate=record.Date_Became_a_Customer__c+346;
                Tasklist.add(obj9);
                
                Task obj10 = new Task();
                obj10.whatid=record.id;
                obj10.Ownerid=record.Customer_Success_Manager__c;
                obj10.Subject = 'Quarterly Business Review';
                obj10.Description='Schedule a Business Review with the customer';
                obj10.ActivityDate=record.Date_Became_a_Customer__c+360;
                Tasklist.add(obj10);
                
                Task obj11 = new Task();
                obj11.Ownerid=record.Customer_Success_Manager__c;
                obj11.whatid=record.id;
                obj11.Subject = 'Renewal Discussions';
                obj11.Description='Start Renewal Discussions with the customer';
                if(record.Acct_Renewal_Date__c !=null)
              //  obj11.ActivityDate=record.Acct_Renewal_Date__c ;
                 obj11.ActivityDate=record.Acct_Renewal_Date__c-120 ;
                else
                 obj11.ActivityDate=record.Date_Became_a_Customer__c+240;
             
                Tasklist.add(obj11);
                
                Task obj12 = new Task();
                obj12.whatid=record.id;
                obj12.Ownerid=record.Customer_Success_Manager__c;
                obj12.Subject = 'Usage Review and Offers';
                obj12.Description='Discuss Usage and any additional product offers';
                obj12.ActivityDate=record.Date_Became_a_Customer__c+180;
                Tasklist.add(obj12);
                
                Task obj13 = new Task();
                obj13.whatid=record.id;
                obj13.Ownerid=record.Customer_Success_Manager__c;
                obj13.Subject = 'Usage Review and Offers';
                obj13.Description='Discuss Usage and any additional product offers';
                obj13.ActivityDate=record.Date_Became_a_Customer__c+360;
                Tasklist.add(obj13);  
                
            } else if(record.CSM_Trigger__c == 'Enterprise'){
                b++;
          
                 if(b==1)
                 {
                  RecurringTasks2.put(record.id,record.Customer_Success_Manager__c); 
                 }
                Task obj3 = new Task();
                obj3.whatid=record.id;
                obj3.Ownerid=record.Customer_Success_Manager__c;
                obj3.Subject = 'Quarterly Business Review Prep';
                obj3.Description='Prepare for your Quarterly Review with the Customer';
                obj3.ActivityDate=record.Date_Became_a_Customer__c+76;
                Tasklist.add(obj3);
                
                Task obj4 = new Task();
                obj4.whatid=record.id;
                obj4.Ownerid=record.Customer_Success_Manager__c;
                obj4.Subject = 'Quarterly Business Review';
                obj4.Description='Schedule a Business Review with the customer';
                obj4.ActivityDate=record.Date_Became_a_Customer__c+90;
                Tasklist.add(obj4);
                
                Task obj5 = new Task();
                obj5.whatid=record.id;
                obj5.Ownerid=record.Customer_Success_Manager__c;
                obj5.Subject = 'Quarterly Business Review Prep';
                obj5.Description='Prepare for your Quarterly Review with the Customer';
                obj5.ActivityDate=record.Date_Became_a_Customer__c+166;
                Tasklist.add(obj5);
                
                Task obj6 = new Task();
                obj6.whatid=record.id;
                obj6.Ownerid=record.Customer_Success_Manager__c;
                obj6.Subject = 'Quarterly Business Review';
                obj6.Description='Schedule a Business Review with the customer';
                obj6.ActivityDate=record.Date_Became_a_Customer__c+180;
                Tasklist.add(obj6);
                
                Task obj7 = new Task();
                obj7.whatid=record.id;
                obj7.Ownerid=record.Customer_Success_Manager__c;
                obj7.Subject = 'Quarterly Business Review Prep';
                obj7.Description='Prepare for your Quarterly Review with the Customer';
                obj7.ActivityDate=record.Date_Became_a_Customer__c+256;
                Tasklist.add(obj7);
                
                Task obj8 = new Task();
                obj8.whatid=record.id;
                obj8.Ownerid=record.Customer_Success_Manager__c;
                obj8.Subject = 'Quarterly Business Review';
                obj8.Description='Schedule a Business Review with the customer';
                obj8.ActivityDate=record.Date_Became_a_Customer__c+270;
                Tasklist.add(obj8);
               
                Task obj9 = new Task();
                obj9.whatid=record.id;
                obj9.Ownerid=record.Customer_Success_Manager__c;
                obj9.Subject = 'Quarterly Business Review Prep';
                obj9.Description='Prepare for your Quarterly Review with the Customer';
                obj9.ActivityDate=record.Date_Became_a_Customer__c+346;
                Tasklist.add(obj9);
                
                Task obj10 = new Task();
                obj10.whatid=record.id;
                obj10.Ownerid=record.Customer_Success_Manager__c;
                obj10.Subject = 'Quarterly Business Review';
                obj10.Description='Schedule a Business Review with the customer';
                obj10.ActivityDate=record.Date_Became_a_Customer__c+360;
                Tasklist.add(obj10);
                
                Task obj11 = new Task();
                obj11.whatid=record.id;
                obj11.Ownerid=record.Customer_Success_Manager__c;
                obj11.Subject = 'Renewal Discussions';
                obj11.Description='Start Renewal Discussions with the customer';
                if(record.Acct_Renewal_Date__c !=null)             
                 obj11.ActivityDate=record.Acct_Renewal_Date__c-120 ;
                else
                 obj11.ActivityDate=record.Date_Became_a_Customer__c+240;
                Tasklist.add(obj11);
                
                Task obj12 = new Task();
                obj12.whatid=record.id;
                obj12.Ownerid=record.Customer_Success_Manager__c;
                obj12.Subject = 'Usage Review and Offers';
                obj12.Description='Discuss Usage and any additional product offers';
                obj12.ActivityDate=record.Date_Became_a_Customer__c+180;
                Tasklist.add(obj12);
                
                Task obj13 = new Task();
                obj13.whatid=record.id;
                obj13.Ownerid=record.Customer_Success_Manager__c;
                obj13.Subject = 'Usage Review and Offers';
                obj13.Description='Discuss Usage and any additional product offers';
                obj13.ActivityDate=record.Date_Became_a_Customer__c+360;
                Tasklist.add(obj13);
                 
            }
            else if(record.CSM_Trigger__c == 'Standard'){
                
                Task obj1 = new Task();
                obj1.whatid=record.id;
                obj1.Ownerid=record.Customer_Success_Manager__c;
                obj1.Subject = 'Quarterly Meeting';
                obj1.Description='Schedule a Quarterly Meeting with the customer';
                obj1.ActivityDate=record.Date_Became_a_Customer__c+90;
                Tasklist.add(obj1);
                
                Task obj2 = new Task();
                obj2.whatid=record.id;
                obj2.Ownerid=record.Customer_Success_Manager__c;
                obj2.Subject = 'Quarterly Meeting';
                obj2.Description='Schedule a Quarterly Meeting with the customer';
                obj2.ActivityDate=record.Date_Became_a_Customer__c+180;
                Tasklist.add(obj2);
                
                Task obj3 = new Task();
                obj3.whatid=record.id;
                obj3.Ownerid=record.Customer_Success_Manager__c;
                obj3.Subject = 'Quarterly Meeting';
                obj3.Description='Schedule a Quarterly Meeting with the customer';
                obj3.ActivityDate=record.Date_Became_a_Customer__c+270;
                Tasklist.add(obj3);
                
                Task obj4 = new Task();
                obj4.whatid=record.id;
                obj4.Ownerid=record.Customer_Success_Manager__c;
                obj4.Subject = 'Quarterly Meeting';
                obj4.Description='Schedule a Quarterly Meeting with the customer';
                obj4.ActivityDate=record.Date_Became_a_Customer__c+360;
                Tasklist.add(obj4);
                
                Task obj5 = new Task();
                obj5.whatid=record.id;
                obj5.Ownerid=record.Customer_Success_Manager__c;
                obj5.Subject = 'Renewal Discussions';
                obj5.Description='Start Renewal Discussions with the customer';
                if(record.Acct_Renewal_Date__c !=null)
                obj5.ActivityDate=record.Acct_Renewal_Date__c-120;
              //  obj5.ActivityDate=record.Date_Became_a_Customer__c+240;
                else
                obj5.ActivityDate=record.Date_Became_a_Customer__c+240;
                Tasklist.add(obj5);
                
                Task obj6 = new Task();
                obj6.whatid=record.id;
                obj6.Ownerid=record.Customer_Success_Manager__c;
                obj6.Subject = 'Usage Review and Offers';
                obj6.Description='Discuss Usage and any additional product offers';
                obj6.ActivityDate=record.Date_Became_a_Customer__c+180;
                Tasklist.add(obj6);
                
                Task obj7 = new Task();
                obj7.whatid=record.id;
                obj7.Ownerid=record.Customer_Success_Manager__c;
                obj7.Subject = 'Usage Review and Offers';
                obj7.Description='Discuss Usage and any additional product offers';
                obj7.ActivityDate=record.Date_Became_a_Customer__c+360;
                Tasklist.add(obj7);
                
                
                Task obj8 = new Task();
                obj8.whatid=record.id;
                obj8.Ownerid=record.Customer_Success_Manager__c;
                obj8.Subject = 'Semi Annual Instance Review';
                obj8.Description='Schedule an instance review with the customer';
                obj8.ActivityDate=record.Date_Became_a_Customer__c+120;
                Tasklist.add(obj8);
                
                
                Task obj9 = new Task();
                obj9.whatid=record.id;
                obj9.Ownerid=record.Customer_Success_Manager__c;
                obj9.Subject = 'Semi Annual Instance Review';
                obj9.Description='Schedule an instance review with the customer';
                obj9.ActivityDate=record.Date_Became_a_Customer__c+300;
                Tasklist.add(obj9);
            }
        }
      }  
    }
    
    insert Tasklist;
    if(RecurringTasks.size()>0)
        CreateTaskTriggerController.CreateRecurringTasks(RecurringTasks,'Elite/Key');
     if(RecurringTasks2.size()>0)
        CreateTaskTriggerController.CreateRecurringTasks(RecurringTasks2,'Enterprise');
  
}