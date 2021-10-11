/**
 * @author Comforth dev team
 * @date 17/12/2020
 * @group
 * @description EmailMessage Management Class
 */
public with sharing class SM002_EmailMessage {

  /**
  * @author Comforth dev team
  * @date 17/12/2020
  * @description
  * @param 
  * @return
  */
  public static void copyClosedCase(List<EmailMessage> listEmailMessage){
    //TO DO
    List<case> openCaseList =new  List<case>();
    Set<ID> caseSet = new Set<ID>();
    Map<String,Group> mapQueues = new Map<String,Group>();
    Map<String,Group> mpQ = new Map<String,Group>();
    Map<String,RecordType> mapRecordTypes = new Map<String,RecordType>();
    List<Case> cloneList = new List<Case>();

    //Map<Id, String> emailBodyMap = new Map<Id, String>{};  
    Map<Id, EmailMessage> emailBodyMap = new Map<Id, EmailMessage>{};
    for (EmailMessage so : listEmailMessage) {
      if(so.ParentId.getSObjectType() == Case.sObjectType  ) {
        // Incoming == true
        System.debug('email message : ' + so);
        System.debug('email message incoming : ' + so.Incoming);
        System.debug('email message related to : ' + so.RelatedToId);
        System.debug('email message parent id : ' + so.ParentId);
        caseSet.add(so.ParentId);
        emailBodyMap.put(so.ParentId, so);
        if(so.Incoming){
          String fromAdressString = so.FromAddress;
          //	Map<Id,case> caseMAP = new Map<Id,case> ();   
          //for(Case caz : [SELECT id, origin, NewMailInMailBox__c, subject, NewTaskCompleted__c, Policy__c, Type ,status, description,parentid, RecordTypeId, OwnerId,    ContactID, AccountID, ContactEmail FROM Case WHERE id in: caseSet  ]) {
          //   caseMAP.put(caz.Id, caz);
              
          //system.debug('taille caseMap : ' + caseMap.size());
          //emailBodyMap.keyset();
          Map<Id,case> caseMAP = new Map<Id,case>([SELECT id, origin, NewMailInMailBox__c, subject, NewTaskCompleted__c, Policy__c, Type ,status, description,parentid, RecordTypeId, OwnerId, Owner.Name ,   ContactID, AccountID, ContactEmail,TECH_Qualification_Determinant__c, RecordType.Name, MemberUniqueID__c,Member__c FROM Case WHERE id in: caseSet  ]);
          System.debug('mapcase  ' + caseMAP);
          for(Case c:caseMAP.values()){
            List<Case_Qualification_Setting__c> listQlSender = new List<Case_Qualification_Setting__c>();
            for(Case_Qualification_Setting__c lcqs : [SELECT id, Sender__c, Name, OwnerId ,Case_Record_Type__c, Case_Queue__c, Case_Subtype_FR__c  from Case_Qualification_Setting__c where Sender__c =: fromAdressString]){
              listQlSender.add(lcqs);
            }
            System.debug('listQlSender : ' + listQlSender);
            boolean isvip = ( listQlSender.size() != 0);
            for(Group q: [SELECT id,NAme,DeveloperName  FROM GROUP WHERE Type = 'Queue'  and  DeveloperName = 'GestionDediee' limit 1]){
              mpQ.put(q.DeveloperName, q);
            }
            String qOwnerId = mpQ.get('GestionDediee').Id;
            if(c.Status=='Closed') {
              system.debug('@@@@@@@@@@@@@@@'+c.Id);
              system.debug('##############'+c.subject);       
              // requet
              List<String> listFrom = new List<String>();
              for(EmailMessage lfad : [select Id, FromAddress, Incoming from EmailMessage where RelatedToId in:caseSet and Incoming = false order by CreatedDate desc limit 1]) {
                listFrom.add(lfad.FromAddress);
              }

              EmailMessage em = emailBodyMap.get(c.Id);
              //String fromAdress = lfad.FromAddress;	
              //system.debug('FROMADRESS'+ fromAdress );
              // Vérifirer si l'adresse est présente dabs dans la table des adresses autorisées
              List<Case_Qualification_Setting__c> listQualification = new List<Case_Qualification_Setting__c>();
              for(Case_Qualification_Setting__c lcqf : [SELECT id, Mailbox__c, Name, OwnerId ,Case_Record_Type__c, Case_Queue__c  from Case_Qualification_Setting__c where Mailbox__c in:listFrom]){
                listQualification.add(lcqf);
              }
              boolean Qualification_Determinant_Valid   = (listQualification.size() != 0);
                  
              if(Qualification_Determinant_Valid) {
                String ThecQuaDet = listQualification[0].Mailbox__c;
                String newOwnerDeveloperName = listQualification[0].Case_Queue__c;
                String newRecordType = listQualification[0].Case_Record_Type__c;
                // No 
                // Qualification_Determinant_Valid == true
                system.debug('Qualification_Determinant_Valid == true');
                for(Group queue : [SELECT id,NAme,DeveloperName  FROM GROUP WHERE Type = 'Queue']){
                    mapQueues.put(queue.DeveloperName,queue);
                }
                String newOwnerId;
                if(mapQueues != null && mapQueues.values().size() > 0 && mapQueues.get(newOwnerDeveloperName) != null){
                  newOwnerId = mapQueues.get(newOwnerDeveloperName).Id;
                }
                
                for(RecordType recordT : [SELECT id, NAme, DeveloperName  FROM RecordType]){
                  mapRecordTypes.put(recordT.DeveloperName, recordT);
                }
                String newrecordtypeId;
                if(mapRecordTypes != null && mapRecordTypes.values().size() > 0 && mapRecordTypes.get(newRecordType) != null){
                  newrecordtypeId = mapRecordTypes.get(newRecordType).Id;
                }
                Case cloneCase = c.clone();
                cloneCase.parentid=c.id;
                if(isvip){
                  cloneCase.CaseSubtypeFR__c = 'VIP';
                  if( c.OwnerId == qOwnerId){
                    cloneCase.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('ClaimCase').getRecordTypeId();
                  }
                  if(newOwnerId != null){
                    cloneCase.OwnerId = newOwnerId ;
                  }
                  if(newrecordtypeId != null){
                    cloneCase.RecordTypeId = newrecordtypeId ;
                  }
                }
                else {  
                  if(newOwnerId != null){
                    cloneCase.OwnerId = newOwnerId ;
                  }
                  if(newrecordtypeId != null){
                    cloneCase.RecordTypeId = newrecordtypeId ;
                  }
                }

                //cloneCase.RecordType.DeveloperName = newRecordType; // newOwnerId;
                cloneCase.TECH_Qualification_Determinant__c = ThecQuaDet;
                cloneCase.Origin='Email';  
                cloneCase.Priority = 'TBC';
                cloneCase.NewMailInMailBox__c = true;
                cloneCase.subject=c.subject;
                cloneCase.NewTaskCompleted__c = false;
                  
                cloneCase.ContactID = c.ContactID;
                cloneCase.AccountID = c.AccountID;
                cloneCase.MemberUniqueID__c = c.MemberUniqueID__c;
                cloneCase.Member__c = c.Member__c;
                    
                //cloneCase.ContactEmail = c.ContactEmail;
                  
                cloneCase.Policy__c=c.Policy__c;
                cloneCase.Type=c.Type;
                cloneCase.Status='New';
                //cloneCase.Description= emailBodyMap.get(c.Id).TextBody;
                //cloneCase.Description= em.TextBody;
                cloneCase.Description= em.TextBody;
                //cloneCase.SuppliedEmail= em.TextBody;
                //cloneCase.SuppliedEmail= em.TextBody;
                cloneCase.LastMailEntry__c= DateTime.now();
                cloneCase.SuppliedEmail = em.FromAddress;
                system.debug('cloneCase.LastMailEntry__c : ' +cloneCase.LastMailEntry__c);
                cloneList.add(cloneCase);
                system.debug('*********************' +cloneList);
              }
              else {
                // YES
                system.debug('Determinant == false');
                Case cloneCase = c.clone();
                cloneCase.parentid=c.id;
                cloneCase.Origin='Email';  
                cloneCase.Priority = 'TBC';
                cloneCase.NewMailInMailBox__c = true;
                cloneCase.subject=c.subject;
                cloneCase.NewTaskCompleted__c = false;
                
                cloneCase.Policy__c= c.Policy__c;
                cloneCase.Type=c.Type;
                cloneCase.Status='New';
                cloneCase.Description= em.TextBody;
                     
                if(isvip){
                  cloneCase.CaseSubtypeFR__c = 'VIP';
                  if( c.OwnerId == qOwnerId ){                           
                    cloneCase.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('ClaimCase').getRecordTypeId();
                  }
                }
                cloneList.add(cloneCase);
                system.debug('*********************' + cloneList.size());
              }       
            } 
            else {
              // isClosed == false
              System.debug('isClosed = false, case status ? : ' + c.Status);
              System.debug('isvip ? : ' + isvip);
              c.LastMailEntry__c =DateTime.now();
              c.NewMailInMailBox__c = true; 
              if(isvip){                       
                c.CaseSubtypeFR__c = 'VIP';
                if( c.OwnerId == qOwnerId ){
                  c.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('ClaimCase').getRecordTypeId();
                }
              } 
              openCaseList.add(c);
            }
            update openCaseList;
            try { 
              system.debug('New cases to be created : ' + cloneList.size());
              insert cloneList ;  
            }
            catch(DMLException e) {   
              System.debug('The following exception has occurred: ' + e.getMessage()); 
            } 
          }
        }
        else {
          // incoming == false
          // ... END
        }
      }
    }
  }
}