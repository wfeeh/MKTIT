trigger ApprovalRequestAftUpd on Apttus_Approval__Approval_Request__c (after update, after insert) {

   set <ID> qids = new set<Id>();
   String RoleLabel = Label.AllowedRolesToAddNotesToCEO;

   for (Apttus_Approval__Approval_Request__c ar1 : trigger.new){
      qids.add (ar1.related_quote__c);
   }

   List <Quote> qList = [select id, discount, Redirect_Finance_Approval__c, Redirect_Legal_Approval__c, Redirect_Operations_Approval__c,
           Redirect_Sales_Discount_Approval__c, Redirect_Sales_Terms_Approval__c, Redirect_Support_Approval__c, 
           Opportunity_Owner_Manager__r.UserRole.Name, Quote_Notes__c  from Quote where ID in :qids];

   for (Apttus_Approval__Approval_Request__c ar2 : trigger.new){
      for(Quote q : qList){
            if (ar2.Apttus_Approval__Step_Name__c == 'Legal Approval'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                    q.Approval_Status_Legal__c = 'Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Redirected'){
                    q.Approval_Status_Legal__c = 'Auto-Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Legal__c = 'Declined';
                  q.Approval_Status__c = 'Not Submitted';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Legal__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Legal__c = 'Cancelled';
                  q.Approval_Status__c = 'Not Submitted';
               }
            } else
            if (ar2.Apttus_Approval__Step_Name__c == 'Finance Approval'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                    q.Approval_Status_Finance__c = 'Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Redirected'){
                    q.Approval_Status_Finance__c = 'Auto-Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Finance__c = 'Declined';
                  q.Approval_Status__c = 'Not Submitted';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Finance__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Finance__c = 'Cancelled';
                  q.Approval_Status__c = 'Not Submitted';
               }
            } else
            if (ar2.Apttus_Approval__Step_Name__c == 'Sales Terms Approval'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                    q.Approval_Status_Sales_Terms__c = 'Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Redirected'){
                    q.Approval_Status_Sales_Terms__c = 'Auto-Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Sales_Terms__c = 'Declined';
                  q.Approval_Status__c = 'Not Submitted';
                  q.Approval_Request_Id__c = ar2.id;
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Sales_Terms__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
                  q.Approval_Request_Id__c = ar2.id;
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Sales_Terms__c = 'Cancelled';
                  q.Approval_Status__c = 'Not Submitted';
                  q.Approval_Request_Id__c = ar2.id;
               }
            } else
            if (ar2.Apttus_Approval__Step_Name__c == 'Operations Approval'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                    q.Approval_Status_Operations__c = 'Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Redirected'){
                    q.Approval_Status_Operations__c = 'Auto-Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Operations__c = 'Declined';
                  q.Approval_Status__c = 'Not Submitted';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Operations__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Operations__c = 'Cancelled';
                  q.Approval_Status__c = 'Not Submitted';
               }
            } else
            if (ar2.Apttus_Approval__Step_Name__c == 'Professional Services Approval'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                  q.Approval_Status_Professional_Services__c = 'Approved';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Professional_Services__c = 'Declined';
                  q.Approval_Status__c = 'Not Submitted';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Professional_Services__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Professional_Services__c = 'Approval Needed';
                  q.Approval_Status__c = 'Not Submitted';
               }
            } else
            if (ar2.Apttus_Approval__Step_Name__c == 'Support Approval'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                    q.Approval_Status_Support__c = 'Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Redirected'){
                    q.Approval_Status_Support__c = 'Auto-Approved';    
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Support__c = 'Declined';
                  q.Approval_Status__c = 'Not Submitted';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Support__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Support__c = 'Cancelled';
                  q.Approval_Status__c = 'Not Submitted';
               }
            } else
            if (ar2.Apttus_Approval__Step_Name__c == 'Sales Discount Approval'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                  q.Approval_Status_Sales_Discount__c = 'Approved';    
                  q.Previously_Approved_Discount__c = q.Discount;
                  if(ar2.Apttus_Approval__Approver_Comments__c != null && ar2.Apttus_Approval__Approver_Comments__c.length()>0){
                      if(q.Quote_Notes__c != null && q.Quote_Notes__c.length()>0){
                          q.Quote_Notes__c = ar2.Apttus_Approval__Approver_Comments__c + '<br/>' +  q.Quote_Notes__c ;
                      } else { q.Quote_Notes__c = ar2.Apttus_Approval__Approver_Comments__c; }
                  }
                  if (RoleLabel.contains(ar2.actual_approver_role__c)){
                     q.Quote_Notes_CEO__c = ar2.Apttus_Approval__Approver_Comments__c;
                  } else { q.Quote_Notes_CEO__c = q.Quote_Notes__c; }
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Redirected'){
                  q.Approval_Status_Sales_Discount__c = 'Auto-Approved';    
                  q.Previously_Approved_Discount__c = q.Discount;
                  if (RoleLabel.contains(ar2.actual_approver_role__c)){
                     q.Quote_Notes_CEO__c = ar2.Apttus_Approval__Approver_Comments__c;
                  } else { q.Quote_Notes_CEO__c = q.Quote_Notes__c; }
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Sales_Discount__c = 'Declined';
                  q.Previously_Approved_Discount__c = 0;
                  q.Approval_Status__c = 'Not Submitted';
                  q.Quote_Notes_CEO__c = '';
                  q.Approval_Request_Id__c = ar2.id;
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Sales_Discount__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
                  q.Previously_Approved_Discount__c = 0;
                  q.Approval_Request_Id__c = ar2.id;
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Sales_Discount__c = 'Cancelled';
                  q.Approval_Status__c = 'Not Submitted';
                  q.Previously_Approved_Discount__c = 0;
                  q.Quote_Notes_CEO__c = '';
                  q.Approval_Request_Id__c = ar2.id;
               }
            } else
         if (ar2.related_quote__c == q.id){
            if (ar2.Apttus_Approval__Step_Name__c == 'Sales Operations QA'){
               if (ar2.Apttus_Approval__Approval_Status__c == 'Approved'){
                  q.Approval_Status_Sales_Operations__c = 'Approved';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Rejected'){
                  q.Approval_Status_Sales_Operations__c = 'Approval Needed';
                  q.Approval_Status__c = 'Not Submitted';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Assigned'){
                  q.Approval_Status_Sales_Operations__c = 'Approval Pending';
                  q.Approval_Status__c = 'Pending Approval';
//                  q.Approval_Status_Overall__c = 'In Progress';
               } else
               if (ar2.Apttus_Approval__Approval_Status__c == 'Cancelled'){
                  q.Approval_Status_Sales_Operations__c = 'Approval Needed';
                  q.Approval_Status__c = 'Not Submitted';
               }
            }
         }
      }
   }
   update qList;
}