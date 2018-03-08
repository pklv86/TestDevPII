/* 
 * Name: PricingResponseWebServiceTest
 * Type: Test Class
 * Apex Class: PricingResponseWebService
 * Description: Test class for code coverage of PricingResponseWebService. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/14/2016       1. Initial Version created
 */

@isTest(SeeAllData=false)
public class PricingResponseWebServiceTest {

   private static testMethod void PricingResponseWebService_UnitTest()
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
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
       
       LDC_Account__c lacc = new LDC_Account__c();
       lacc.name  ='Test LDC acc';
       lacc.Account__c = acc.id;
       lacc.LDC_Account_Number__c = '12345';
       insert lacc;

       PricingResponseWebService.Customer cust = new PricingResponseWebService.Customer();
       cust.accid = acc.id;
       cust.oppid = opp.id;
       cust.accName = 'Test Acc 1';
       cust.oppType = 'Test opp';
       List<PricingResponseWebService.RetailQuote> rtQuoteLst = new List<PricingResponseWebService.RetailQuote>();
       List<PricingResponseWebService.LDCAccount> ldcAccLst = new List<PricingResponseWebService.LDCAccount>();
       PricingResponseWebService.RetailQuote rtQuote = new PricingResponseWebService.RetailQuote();
       rtQuote.oppid = opp.id;
       rtQuote.rtQuoteId = rq.id;
       
       PricingResponseWebService.LDCAccount ldcAcc = new PricingResponseWebService.LDCAccount();
       ldcAcc.ldaccountId = lacc.id;
       rtQuoteLst.add(rtQuote);
       ldcAccLst.add(ldcAcc);
       
       PricingResponseWebService.PricingResponse res = new PricingResponseWebService.PricingResponse();
       res.customer = cust;
       res.rtQuoteLst = rtQuoteLst;
       res.ldcAccLst = ldcAccLst;
       PricingResponseWebService.ResponseProcess(res);
       Test.stopTest();
       
   }
     private static testMethod void testPricingResponseWebService1()
   {
       Test.startTest();
       PricingResponseWebService.ResponseProcess(null);
       Test.stopTest();
       
   }
}