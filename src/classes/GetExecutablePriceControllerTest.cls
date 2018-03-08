/* 
 * Name: GetExecutablePriceControllerTest
 * Type: Test Class
 * Apex Class: GetExecutablePriceController
 * Description: Test class for code coverage of GetExecutablePriceController. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/14/2016       1. Initial Version created
 */

@isTest(SeeAllData=false)
public class GetExecutablePriceControllerTest {

 private static testmethod void ExecutablePriceController_UnitTest()
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
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.Request_Status__c = ConstantUtility.STATUS_PRICING_COMPLETE;
       rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_EXECUTABLE); 
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
     
     
      ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      GetExecutablePriceController cntrl = new GetExecutablePriceController(sc);
      cntrl.cancelRequest();
      cntrl.sendNewQuotes();
       rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_INDICATIVE);
       update rq;
      cntrl.createRequest();
    
     
      cntrl.getOptyView();
     Set<id> qtIdLst = new Set<id>();
     qtIdLst.add(rq.id);
     GetExecutablePriceController.sendQuotesForPricing(qtIdLst,opp.id);
     
   Test.stopTest();  
 }
     private static testmethod void testExecutablePriceController1()
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
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.Request_Status__c = ConstantUtility.STATUS_PRICING_COMPLETE;
       rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_INDICATIVE); 
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
     
     
      ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      GetExecutablePriceController cntrl = new GetExecutablePriceController(sc);
      cntrl.cancelRequest();
      cntrl.sendNewQuotes();
     List<GetExecutablePriceController.RetailQuoteWrapper> retQuoteWrapList = new List<GetExecutablePriceController.RetailQuoteWrapper>();
     GetExecutablePriceController.RetailQuoteWrapper rtquoteWrapper = new GetExecutablePriceController.RetailQuoteWrapper(rq);
     rtquoteWrapper.selected = true;
     
     retQuoteWrapList.add(rtquoteWrapper);
     cntrl.retQuoteWrapList = retQuoteWrapList;
        cntrl.createRequest();   
     Map<id,Retail_Quote__c> rqMap = new Map<id,Retail_Quote__c>([select id,name from Retail_Quote__c]);
  
     GetExecutablePriceController.sendQuotesForPricing(rqMap.keySet(),opp.id);
   Test.stopTest();  
 }
    
}