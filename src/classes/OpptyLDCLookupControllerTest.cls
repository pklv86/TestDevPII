/* 
 * Name: OpptyLDCLookupControllerTest
 * Type: Test Class
 * Apex Class: OpptyLDCLookupController
 * Description:  Test class for code coverage of OpptyLDCLookupController. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/20/2016       1. Initial Version created
 */

@isTest(SeeAllData=false)
public class OpptyLDCLookupControllerTest{
  private static testmethod void opptyLDCLookupControllerTest()
    {
       Test.startTest(); 
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];

        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
       Opportunity opp = new Opportunity();
       opp.name = 'Test Opp';
       opp.StageName = 'New';
       opp.CloseDate = date.today().addDays(5);
       opp.Accountid = acc.id;
       opp.RecordTypeId = rec.id;
       opp.Service_Territory__c = 'AEPOHIO';
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.RecordTypeId = ConstantUtility.getRecordTypeIdbyName('Retail_Quote__c','Indicative');
       insert rq;
       
       LDC_Account__c lacc = new LDC_Account__c();
       lacc.name  ='Test LDC acc';
       lacc.Account__c = acc.id;
       lacc.Service_Territory__c = 'AEPOHIO';
       lacc.LDC_Account_Number__c = '12345';
       insert lacc;
       LDC_Account__c lacc1 = new LDC_Account__c();
       lacc1.name  ='Test LDC acc';
       lacc1.Account__c = acc.id;
       lacc1.Service_Territory__c = 'DEOHIO';
       lacc1.LDC_Account_Number__c = '67824';
     /* Opportunity_LDC__c oppLdc = new Opportunity_LDC__c();
      oppLdc.name = 'Test LDC Acc';
      oppLdc.LDC_Account__c = lacc.id;   
      oppLdc.Opportunity__c = opp.id;
      insert oppLdc;*/
      ApexPages.currentPage().getParameters().put('masterId',opp.id);
        System.currentPageReference().getParameters().put('lksrch','Test LDC acc');
      System.currentPageReference().getParameters().put('oppID',opp.id);  
      OpptyLDCLookupController cntrl = new  OpptyLDCLookupController();
       cntrl.cancel();
        cntrl.optyLDC.LDC_Account__c = lacc.id;
       cntrl.save();
       cntrl.setSearchParam();
       cntrl.search(); 
       cntrl.account = lacc1; 
       cntrl.saveAccount(); 
       cntrl.getFormTag();
       cntrl.getTextBox(); 
       Test.stopTest(); 
    }
}