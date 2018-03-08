/* 
 * Name: IntegrationUtilTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the IntegrationUtil Apex Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sneha Gadde        03/27/2016       1. Initial Version created
 */
@isTest(SeeAllData=false)
private class IntegrationUtilTest{
private static testmethod void IntegrationUtil_UnitTest() 
 {
   Test.startTest();
   
   DateTime dt = DateTime.now();
    IntegrationUtil.generateDocId(dt);
    IntegrationUtil.generateDate(dt);
    IntegrationUtil.generateDateTime(dt);
    IntegrationUtil.generateTime(dt);
    IntegrationUtil.convertStringToDate('20170601');
    IntegrationUtil.convertStringToDate('201761');
    IntegrationUtil.convertDateToString(Date.today());
    IntegrationUtil.convertTimeToString(Datetime.now());
    IntegrationUtil.remSpecialChars('wefwf325325');
    IntegrationUtil.generateRandomString(6);
    Opportunity opp = new Opportunity();
    Database.SaveResult sr = DataBase.insert(opp,false); 
    List<Database.SaveResult> srResult = new List<Database.SaveResult>();
    srResult.add(sr);
    IntegrationUtil.collectErrors(srResult);
    Opportunity opp1 = new Opportunity();
    Database.UpsertResult sr1 = DataBase.upsert(opp1,false); 
    List<Database.UpsertResult> srResult1 = new List<Database.UpsertResult>();
    srResult1.add(sr1);
    IntegrationUtil.collectUpsertErrors(srResult1);

   Test.stopTest();  
 }
 
}