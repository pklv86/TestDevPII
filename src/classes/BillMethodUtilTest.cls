/* 
 * Name: BillMethodUtilTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the BillMethodUtil Apex Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sneha Gadde        03/25/2016       1. Initial Version created
 */
@isTest(SeeAllData=false)
private class BillMethodUtilTest{
private static testmethod void BillMethodUtil_UnitTest() 
 {
   Test.startTest();
      Bill_Method__c bm = new Bill_Method__c();
      bm.name = 'Test';
      bm.Bill_Calculator__c = 'Calc';
      bm.Bill_Presenter__c = 'Presenter';   
      insert bm;
      
      BillMethodUtil.getBillMethodByName('Test');
      BillMethodUtil.getBillMethodByName(null);
      BillMethodUtil.getBillMethodByName('Test1');
      
   Test.stopTest();  
 }
 
}