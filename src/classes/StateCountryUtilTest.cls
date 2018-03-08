/* 
 * Name: StateCountryUtilTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the StateCountryUtil Apex Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sneha Gadde        03/23/2016       1. Initial Version created
 */
@isTest(SeeAllData=false)
private class StateCountryUtilTest {
private static testmethod void StateCountryUtil_UnitTest() 
 {
   Test.startTest();
      State_Country__c sc = new State_Country__c();
      sc.name = 'Test';
      sc.Value__c = 'state1';
      sc.Country__c = 'country1';
      sc.Code__c  = 'test1';
      insert sc;
       
      StateCountryUtil.getStateCodeForVal('state1','country1');
      StateCountryUtil.getStateCodeForVal(null,'country1');
        
   Test.stopTest();   
    
 }
}