/* 
 * Name: SelectRateCodeControllerTest
 * Type: Test Class
 * Apex Class: SelectRateCodeController
 * Description: Test class for code coverage of SelectRateCodeController. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/18/2016       1. Initial Version created
 */
 
 @isTest(SeeAllData=false)
public class SelectRateCodeControllerTest {
private static testmethod void selectRateCode_UnitTest() 
 {
     Test.startTest();
       Rate_Code__c rc = new Rate_Code__c();
       rc.name  ='test rc';
       rc.Price__c = 100.00;
       rc.Service_Territory__c  = 'AEPOHIO';
       insert rc;
       ApexPages.currentPage().getParameters().put('serviceTeritory','AEPOHIO');
       ApexPages.currentPage().getParameters().put('quotePrice','100.00');
       
      SelectRateCodeController cntrl = new SelectRateCodeController();
      cntrl.searchRateCode();
      cntrl.getListItems();
      cntrl.setListSize(); 
      cntrl.Newratecode();
      cntrl.createratecode();
      cntrl.cancelcreateratecode();
      
      ApexPages.currentPage().getParameters().put('serviceTeritory','AEPOHIO');
      ApexPages.currentPage().getParameters().put('quotePrice','00.00');
       
      SelectRateCodeController cntrl1 = new SelectRateCodeController();
      cntrl1.searchRateCode(); 
    
     Test.stopTest();
 }  
 private static testmethod void selectRateCodeTest1()
 {
     Test.startTest();
       Rate_Code__c rc = new Rate_Code__c();
       rc.name  ='test rc';
       rc.Price__c = 15.2345;
       rc.Service_Territory__c  = 'AEPOHIO';
       insert rc;
       ApexPages.currentPage().getParameters().put('serviceTeritory','AEPOHIO');
       ApexPages.currentPage().getParameters().put('quotePrice','15');
       
      SelectRateCodeController cntrl = new SelectRateCodeController();
      cntrl.searchRateCode();
      cntrl.getListItems();
      cntrl.setListSize();  
    
     Test.stopTest();
 }     
    
 
    
}