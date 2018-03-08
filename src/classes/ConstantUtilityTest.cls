/* 
 * Name: TestConstantUtility
 * Type: Test Class
 * Apex Class: ConstantUtility
 * Description:  This is test class for code coverage of ConstantUtility. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/14/2016       1. Initial Version created
 */

@isTest(SeeAllData=false)
public class ConstantUtilityTest {

 private static testmethod void ConstantUtility_UnitTest() 
 {
   Test.startTest();  
     ConstantUtility.getObject('Opportunity','name:stagename',null);
     Opportunity opp = new Opportunity();
     opp.name = 'Test Opp';
     opp.StageName = 'New';
     opp.CloseDate = date.today().addDays(5);
     insert opp;
     
     ConstantUtility.getRecordTypeId('Opportunity','Standard Opportunity');
     ConstantUtility.getRecordTypeIdbyName('Opportunity','Standard Opportunity');
     ConstantUtility.getObjectFieldsQuery('Retail_Quote__c');
     ConstantUtility.getObject('Opportunity','name:stagename',opp.id);
     ConstantUtility.IsSobjectType('Opportunity',opp.id);
     
     Opportunity opp1 = new Opportunity();
     opp1.name = 'Test opp1';
     List<Opportunity> oppLst = new List<Opportunity>();
     oppLst.add(opp1);
     List<Database.SaveResult> results = Database.insert(oppLst, false);
     ConstantUtility.CheckDatabaseResults(results);
    Test.stopTest(); 
 }
    
}