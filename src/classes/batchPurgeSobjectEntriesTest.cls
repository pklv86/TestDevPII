/* 
 * Name: batchPurgeSobjectEntriesTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the batchPurgeSobjectEntries Apex Batch Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         03/21/2016       1. Initial Version created
 */
@isTest(SeeAllData=false) 
private class batchPurgeSobjectEntriesTest {

    static testMethod void batchPurgeSobjectEntries_UnitTest() {
      
        PurgeSobjectSettings__c tstPSRec = new PurgeSobjectSettings__c(Name='Account',Enable_Purge__c=true,Save_History__c=0,Where_Clause__c='Name Like \'TSTBPS%\'',order__c=1);
        Insert tstPSRec;

        List<Account> lstAccTst = new List<Account>();
        for(Integer i=0;i<1500;i++){
            Account acc = new Account(Name='TSTBPS'+i,Billing_Entity__c='Dynegy');
            lstAccTst.add(acc);
        }
        insert lstAccTst;
        
        String CRON_EXP = '0 0 * * * ?';
        Test.startTest();                
        String jobId = System.schedule('batchPurgeSobjectEntriesTest',CRON_EXP,new batchPurgeSobjectEntries(1));    
        Test.stopTest(); 
    }
}