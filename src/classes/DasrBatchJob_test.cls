/**
 * This class is designed to provide code coverage for the 
 * AccountTrigger and AccountTriggerHandlerBatch classes.
 *
 * @CreatedBy Prasad Paladugu
 * @version 1.0
 **/

@isTest
public class DasrBatchJob_test{
    
    public static testmethod void DasrBatchJob_Test1(){
        
         Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST', Active__c = true);
        insert testOperatingCompany;
        
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',
                                   Service_Territory__c = 'AEPOHIO',Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        Account testAcct = new Account(Name='Test CnI',Supplier__c = testOperatingCompany.Id,BillingStreet = '2114 Bates Brothers Road',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy');
        insert testAcct;
        
        LDC_Account__c ldcTestAccount1 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4048 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount1;
        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount2;
        LDC_Account__c ldcTestAccount3 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,LDC_Account_Status__c='Final',
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount3;
        
        //create test Contract
        Contract testContract1 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = 'DK98',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO');
        insert testContract1;
        Contract testContract2 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = '0611R3732',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO');
        insert testContract2;
        
        //activate the Contract
        testContract1.Status = 'Activated';
        testContract1.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract1;
        testContract2.Status = 'Activated';
        testContract2.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract2;
        //create Contract LDC Record
        
        Contract_LDC__c testContractLDC1 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount1.Id,Contract__c = testContract1.Id,Active__c=true,IsSynchronized__c=true);
        insert testContractLDC1;
        Contract_LDC__c testContractLDC2 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount2.Id,Contract__c = testContract2.Id);
        insert testContractLDC2;
        //create DASR Record for enrollment
        
        DASR_Request__c testRequest = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy');
        insert testRequest;
        
        DASR_Request__c testRequest1 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = date.valueof('2016-06-26'),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy');
        insert testRequest1;
        
        DASR_Request__c testRequest3 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount3.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = date.valueof('2016-06-26'),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy');
        insert testRequest3;
        
       /* testRequest.Accepted__c = true;
        testRequest.Integration_Status__c = 'Complete';
        update testRequest;*/
        
        Date dt = date.today();
        time t =datetime.now().time();
        String schTime = '0 0 '+t.hour()+' * * ?';
        DasrBatchJob dasrjobsch = new DasrBatchJob();
        system.schedule('Test DASR', schTime, dasrjobsch);
        Database.executeBatch(dasrjobsch);
        //DasrBatchJob dasrjobcons = new DasrBatchJob();
        //testContractLDC2.active__c = false;
        //update testContractLDC2;
        
        DASR_Request__c testRequest2 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy');
        insert testRequest2;
        string query = ConstantUtility.getObjectFieldsQuery('DASR_Request__c') + ' From DASR_Request__c  where Dynegy_Initiated__c = true AND Accepted__c = true AND Integration_Status__c = \'Complete\'';
        Query += 'AND createdby.name != \'Integration User\' AND DASR_Type__c = \'GAAC\' AND DASR_Activated__c = false AND Change_Effective_Date__c = : DatetoProcess';
        DasrBatchJob dasrjob = new DasrBatchJob(dt,1);
        Database.executeBatch(dasrjob);
    }
    
}