/**
 * @author Comforth dev team
 * @date 17/12/2020
 * @group
 * @description EmailMessage Management Class TEST
 */
@isTest   

		public class  SM002_EmailMessage_TEST {
   
     static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    
           @testSetup static void setup(){
        
              System.runAs(adminUser){ 
                   
                
                                  
                   
                                
                   //Create 1  case Status closed
                  List<Case> listCaseC = new List<Case>();
                  for(Integer i=0;i<1;i++){
                   listCaseC.add(new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'Closed'));
                   }
                   insert listCaseC;
                   
                            
                   //Create 200 EmailMessage
                   /*List<EmailMessage> listEmailMessage = new List<EmailMessage>();
                   for(Integer i=0;i<1;i++){
                   listEmailMessage.add(new TestFactory.EmailMessageFactory().createEmail(listCaseC[i].Id));
                   
                   }
                    insert listEmailMessage;*/
                    
               }
           }
            @isTest static void testCopyClosedCaseDeterminantValid() { 
        User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
        
               System.runAs(adminUser2){  
                   
                   Case   aCase = [SELECT Id FROM Case Limit 1];
                   
              Case_Qualification_Setting__c cqs = new Case_Qualification_Setting__c();
              cqs.Mailbox__c = 'test@abc.org';
             
              insert cqs;
                   
               
        


                   test.startTest();

        List<EmailMessage> listTest = new List<EmailMessage>();

            EmailMessage em = new EmailMessage();
            em.FromAddress = 'test@abc.org';
            em.Incoming = true; 
            em.ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
            em.Subject = 'Test email';
            em.TextBody = '23456 '; 
          
            em.ParentId = aCase.Id;
            insert em;
            listTest.add(em) ;

            

			// Récuperer tous les case parent ids
             list<Case> cdl =[SELECT id, origin, NewMailInMailBox__c, subject, NewTaskCompleted__c, Policy__c, Type ,status, description,parentid, RecordTypeId, OwnerId, Owner.Name ,   ContactID, AccountID, ContactEmail,TECH_Qualification_Determinant__c, RecordType.Name FROM Case];    
          
             SM002_EmailMessage.copyClosedCase(listTest);
          
          
             System.debug('cdl size : ' + cdl.size());
            System.assertEquals(2,cdl.size(),'Case  size should be 2');
            // récuparation des EmailMessage cases ids
           //list<EmailMessage> emTest =[SELECT Id, parentId from EmailMessage where incoming =: true  and parentId =: cdl[0].Id];

           test.stopTest();
          }

    }
            
            @isTest static void testCopyClosedCase() { 
        User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
        
               System.runAs(adminUser2){  
                   
                   Case   aCase = [SELECT Id FROM Case Limit 1];


                   Case_Qualification_Setting__c cqs = new Case_Qualification_Setting__c();
              cqs.Mailbox__c = 'test@abc.org';
             
              insert cqs;
                   test.startTest();
                   List<EmailMessage> listTest2 = new List<EmailMessage>();
            EmailMessage em = new EmailMessage();
            em.FromAddress = 'test@abc.org';
            em.Incoming = false; 
            em.ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
            em.Subject = 'Test email';
            em.TextBody = '23456 '; 
           
            em.ParentId = aCase.Id;
            insert em;

            listTest2.add(em) ;


            List<EmailMessage> listFromAd = new List<EmailMessage>();
            list <EmailMessage>  lfads = [SELECT Id, FromAddress, Incoming FROM EmailMessage WHERE Incoming = false  Limit 1 ];
        




                  SM002_EmailMessage.copyClosedCase(listTest2);
			// Récuperer tous les case parent ids
             list<Case> cdl =[SELECT id, origin, NewMailInMailBox__c, subject, NewTaskCompleted__c, Policy__c, Type ,status, description,parentid, RecordTypeId, OwnerId, Owner.Name ,   ContactID, AccountID, ContactEmail,TECH_Qualification_Determinant__c, RecordType.Name FROM Case];    
            System.debug('cdl size : ' + cdl.size());
           // System.assertEquals(2,cdl.size(),'Case  size should be 2');
            // récuparation des EmailMessage cases ids
           //list<EmailMessage> emTest =[SELECT Id, parentId from EmailMessage where incoming =: true  and parentId =: cdl[0].Id];
        
        
           test.stopTest();
        
        }

    }             
		}