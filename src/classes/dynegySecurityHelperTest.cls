/* 
 * Name: dynegySecurityHelperTest
 * Type: Test Class
 * Apex Class: dynegySecurityHelper
 * Description:  This is test class for code coverage of dynegySecurityHelper. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/14/2016       1. Initial Version created
 */

@isTest(SeeAllData=false)
public class dynegySecurityHelperTest {

 private static testmethod void DynegySecurityHelper_UnitTest()
 {
  Test.startTest();
    dynegySecurityHelper.UsernameToken obj = new dynegySecurityHelper.UsernameToken('test','test');
    dynegySecurityHelper.SecurityHeader obj1 = new dynegySecurityHelper.SecurityHeader('test','test'); 
  Test.stopTest();   
 }
}