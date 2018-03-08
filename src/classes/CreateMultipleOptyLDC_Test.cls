@isTest
public class CreateMultipleOptyLDC_Test {
 private static testmethod void createMultipleOptyLDCTest()
 {
    Test.startTest(); 
      RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
      List<Account> accLst = new List<Account>();
       Account acc = new Account();
       acc.name = 'Test Acc';
       acc.Billing_Entity__c='Dynegy';
       Account acc1 = new Account();
       acc1.name = 'Test Acc1';
       acc1.Billing_Entity__c='Dynegy';
       accLst.add(acc);
       accLst.add(acc1);
       insert accLst;
     
       Opportunity opp = new Opportunity();
       opp.name = 'Test Opp';
       opp.StageName = 'New';
       opp.CloseDate = date.today().addDays(5);
       opp.Accountid = acc.id;
       opp.Service_Territory__c = 'AEPOHIO';
       opp.RecordTypeId = rec.id;
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.RecordTypeId = ConstantUtility.getRecordTypeIdbyName('Retail_Quote__c','Indicative');
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
       
       LDC_Account__c lacc = new LDC_Account__c();
       lacc.name  ='Test LDC acc';
       lacc.Account__c = acc.id;
       lacc.Service_Territory__c = 'AEPOHIO';
       lacc.LDC_Account_Number__c = '1234';
       insert lacc;
       LDC_Account__c lacc1 = new LDC_Account__c();
       lacc1.name  ='Test LDC acc1';
       lacc1.Account__c = acc.id;
       lacc1.Service_Territory__c = 'AEPOHIO';
       lacc1.LDC_Account_Number__c = '2345';
       insert lacc1;
       /*Opportunity_LDC__c oppLdc = new Opportunity_LDC__c();
       oppLdc.name = 'Test LDC Acc';
       oppLdc.LDC_Account__c = lacc1.id;   
       oppLdc.Opportunity__c = opp.id;
       insert oppLdc;*/
       ApexPages.currentPage().getParameters().put('masterId',opp.id);
       CreateMultipleOptyLDC cntrl = new CreateMultipleOptyLDC();
       cntrl.cancel();
       cntrl.doNext();
       cntrl.doPrevious();
       cntrl.selectionId = lacc.id;
       cntrl.addSelectedId();
       cntrl.save();
       cntrl.removeSelectedId();
       cntrl.getSelectedCount();
      
       cntrl.getLDCAccounts(); 
       cntrl.getHasPrevious();
       cntrl.getHasNext();
       cntrl.getPageNumber();
       cntrl.getTotalPages();
       cntrl.setHeaderValue();
      cntrl.selectionId = null;
       cntrl.addSelectedId();
       cntrl.removeSelectedId();
    Test.stopTest(); 
 }
  private static testmethod void createMultipleOptyLDCTest1()
 {
    Test.startTest(); 
      RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
      List<Account> accLst = new List<Account>();
       Account acc = new Account();
       acc.name = 'Test Acc';
       acc.Billing_Entity__c='Dynegy';
       Account acc1 = new Account();
       acc1.name = 'Test Acc1';
       acc1.Billing_Entity__c='Dynegy';
       accLst.add(acc);
       accLst.add(acc1);
       insert accLst;
     
       Opportunity opp = new Opportunity();
       opp.name = 'Test Opp';
       opp.StageName = 'New';
       opp.CloseDate = date.today().addDays(5);
       opp.Accountid = acc.id;
       opp.Service_Territory__c = 'AEPOHIO';
       opp.RecordTypeId = rec.id;
       insert opp;
       
       ApexPages.currentPage().getParameters().put('masterId',opp.id);
       CreateMultipleOptyLDC cntrl = new CreateMultipleOptyLDC();
      
    Test.stopTest(); 
 }
}