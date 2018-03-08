/* 
 * Name: DynegyCommonUtilsTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the DynegyCommonUtils Apex Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sneha Gadde        03/25/2016       1. Initial Version created
 */
@isTest(SeeAllData=false)
private class DynegyCommonUtilsTest{
private static testmethod void DynegyCommonUtils_UnitTest() 
 {
   Test.startTest();
      DynegyCommonUtils.generateRandomString(5);
      DynegyCommonUtils.generateRandomString('A63G',10);
   Test.stopTest();  
 }
 
}