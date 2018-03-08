/* 
 * Name: ChangeReasonUtilTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ChangeReasonUtil Apex Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sneha Gadde        03/25/2016       1. Initial Version created
 */
@isTest(SeeAllData=false)
private class ChangeReasonUtilTest{
private static testmethod void ChangeReasonUtil_UnitTest() 
 {
   Test.startTest();
   ChangeReason__c cr = new ChangeReason__c();
      cr.name = 'Test CR';
      cr.Reason_Value__c = 'Test Val';
      cr.Reason_Code__c = 'Test Code';
      cr.Object_API_Name__c = 'ChangeReason__c';
      cr.Valid_For_Drop__c = true;
      cr.Allow_On_Outbound__c = true;
      insert cr;
      
      ChangeReasonUtil cntrl = new ChangeReasonUtil();
      ChangeReasonUtil.getChgRsnCodeForVal('Test Val');
      ChangeReasonUtil.getChgRsnCodeForCode('Test Code');
      ChangeReasonUtil.getChgRsnCodeForVal(null);
      ChangeReasonUtil.getChgRsnCodeForCode(null);
          
      ChangeReasonUtil.getChgRsnCodeForVal('Test Val','ChangeReason__c');
      ChangeReasonUtil.getDropCodeForVal('Test Val','ChangeReason__c');
      ChangeReasonUtil.getChgRsnValForCode('Test Val','ChangeReason__c');
      ChangeReasonUtil.isRsnAllowOutbound('Test Val','ChangeReason__c');
      ChangeReasonUtil.getChgRsnCodeForVal('Test Code','ChangeReason__c');
      ChangeReasonUtil.getChgRsnCodeForVal(null,'');
      ChangeReasonUtil.getDropCodeForVal('Test Code','ChangeReason__c');
      ChangeReasonUtil.getDropCodeForVal(null,'');
      ChangeReasonUtil.getChgRsnValForCode('Test Code','ChangeReason__c');
      ChangeReasonUtil.getChgRsnValForCode(null,'');
      ChangeReasonUtil.isRsnAllowOutbound('Test Code','ChangeReason__c');
      ChangeReasonUtil.isRsnAllowOutbound(null,'');
   Test.stopTest();  
 }
 
}