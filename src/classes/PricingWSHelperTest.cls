/* 
 * Name: PricingWSHelperTest
 * Type: Test Class
 * Apex Class: PricingWSHelper
 * Description:  This is test class for code coverage of PricingWSHelper. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/14/2016       1. Initial Version created
 */


@isTest(SeeAllData=false)
public class PricingWSHelperTest {

  private static testmethod void PricingWSHelper_UnitTest()
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
       rq.RecordTypeId = ConstantUtility.getRecordTypeIdbyName('Retail_Quote__c','Indicative');
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
       
       LDC_Account__c lacc = new LDC_Account__c();
       lacc.name  ='Test LDC acc';
       lacc.Account__c = acc.id;
       lacc.LDC_Account_Number__c = '123456';
       insert lacc;
      Opportunity_LDC__c oppLdc = new Opportunity_LDC__c();
     // oppLdc.name = 'Test LDC Acc';
      oppLdc.LDC_Account__c = lacc.id;   
      oppLdc.Opportunity__c = opp.id;
      insert oppLdc;
      List<Retail_Quote__c> rqLst = new List<Retail_Quote__c>();
      rqLst.add(rq);
      Opportunity opp1 = [select Id,Name,Refresh_Expiration_Date__c,AccountId,recordType.name,(Select Id, Name, LDC_Account__r.name,LDC_Account__r.LDC_Account_Number__c,LDC_Account__r.LDC_Vendor__r.DUNS__c,LDC_Account__r.LDC_Vendor__r.Utility_Code__c from OpportunityLDCs__r) from Opportunity where id=:opp.id];
      PricingWSHelper.sendQuotesForPricing(rqLst,opp1,acc);
      //PricingWSHelper.onPricingFailure('None');
      PricingWSHelper.sendQuotesForPricingFuture(PricingWSHelper.getQuotesforPricing(rqLst,opp1,acc));
      PricingWSHelper.onPricingFailure(PricingWSHelper.getQuotesforPricing(rqLst,opp1,acc));
    Test.stopTest();  
  }
    
}