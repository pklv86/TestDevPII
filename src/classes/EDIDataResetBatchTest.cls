/* 
 * Name: EDIDataResetBatchTest
 * Type: Test Class
 * Apex Class: EDIDataResetBatch
 * Description: Test class for code coverage of EDIDataResetBatch. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde                   04/03/2016       1. Initial Version created
 * 1.1        Prasad                        Aug 2016         1. Modified for code coverage
 */

@isTest(SeeAllData=false)
public class EDIDataResetBatchTest {

    private static testmethod void EDIDataResetBatch_UnitTest() 
    {
        Test.startTest();
        
         RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];

        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
        Contract testContr = new Contract(
                                                AccountId=acc.Id,
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                      //        Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert testContr;
        testContr.Status = 'Activated';
        testContr.Contract_Counter_Signed_Date__c = datetime.now();
        update testContr;
        LDC_Account__c lacc1 = new LDC_Account__c();
        lacc1.name  ='Test LDC acc';
        lacc1.Account__c = acc.id;
        lacc1.LDC_Account_Number__c = '12345';
        insert lacc1;
       
        LDC_Account__c lacc2 = new LDC_Account__c();
        lacc2.name  ='Test LDC acc';
        lacc2.Account__c = acc.id;
        lacc2.LDC_Account_Number__c = '23456';
        insert lacc2;
       
        LDC_Account__c lacc3 = new LDC_Account__c();
        lacc3.name  ='Test LDC acc';
        lacc3.Account__c = acc.id;
        lacc3.LDC_Account_Number__c = '34567';
        insert lacc3;
       
        DASR_Request__c reqGAAC = new DASR_Request__c();
    //    req.name = 'test req';
        reqGAAC.Change_Reason__c = 'Test Reason';
        reqGAAC.LDC_Account__c = lacc1.id;
        reqGAAC.Contract__c = testContr.Id;
        reqGAAC.Integration_Status__c = 'Waiting For Response';
        reqGAAC.DASR_Submit_Date__c = date.today();
        reqGAAC.Change_Effective_Date__c = date.today();
        reqGAAC.DASR_Type__c = 'GAAC';
        reqGAAC.Billing_Entity__c='Dynegy';
        insert reqGAAC;
        
        DASR_Request__c reqGAAE = new DASR_Request__c();
    //    req.name = 'test req';
        reqGAAE.LDC_Account__c = lacc2.id;
        reqGAAE.Contract__c = testContr.Id;
        reqGAAE.Integration_Status__c = 'Waiting For Response';
        reqGAAE.DASR_Submit_Date__c = date.today();
        reqGAAE.Change_Effective_Date__c = date.today();
        reqGAAE.DASR_Type__c = 'GAAE';
        reqGAAE.Billing_Entity__c='Dynegy';
        insert reqGAAE;
        
        DASR_Request__c reqGAAD = new DASR_Request__c();
    //    req.name = 'test req';
        reqGAAD.Drop_Reason__c = 'Contract expired';
        reqGAAD.LDC_Account__c = lacc3.id;
        reqGAAD.Contract__c = testContr.Id;
        reqGAAD.Integration_Status__c = 'Waiting For Response';
        reqGAAD.DASR_Submit_Date__c = date.today();
        reqGAAD.Drop_Date__c = date.today();
        reqGAAD.DASR_Type__c = 'GAAD';
        reqGAAD.Billing_Entity__c='Dynegy';
        insert reqGAAD;
        
        EDIDataResetBatch obj = new EDIDataResetBatch();
        database.executeBatch(obj);
        Test.stopTest();
        
    }  
    
    private static testmethod void EDIDataResetBatch_UnitTest2() 
    {
        Test.startTest();
        
         RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];

        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
        Contract testContr = new Contract(
                                                AccountId=acc.Id,
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                      //        Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert testContr;
        testContr.Status = 'Activated';
        testContr.Contract_Counter_Signed_Date__c = datetime.now();
        update testContr;
        
        LDC_Account__c lacc1 = new LDC_Account__c();
        lacc1.name  ='Test LDC acc';
        lacc1.Account__c = acc.id;
        lacc1.LDC_Account_Number__c = '12345';
        insert lacc1;
       
        DASR_Request__c reqGAAE = new DASR_Request__c();
    //    req.name = 'test req';
        reqGAAE.LDC_Account__c = lacc1.id;
        reqGAAE.Contract__c = testContr.Id;
        reqGAAE.Integration_Status__c = 'Waiting For Response';
        reqGAAE.DASR_Submit_Date__c = date.today();
        reqGAAE.Change_Effective_Date__c = date.today();
        reqGAAE.DASR_Type__c = 'GAAE';
        reqGAAE.Billing_Entity__c='Dynegy';
        insert reqGAAE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(reqGAAE);
        DASRGAAEInboundController dgaae = new DASRGAAEInboundController(sc);
        dgaae.procDASR();
        
        Test.stopTest();
        
    }  
}