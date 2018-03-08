/**
 * The purpose of this class is to provide code coverage for the Flow_SetActiveContractLDCTest
 * class
 * 
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 **/
@isTest
public class Flow_SetActiveContractLDCTest {
    /**
     * This method creates test data for this class to execute
     * test methods on.
     **/
    private static void SetupTestData(){
        //first we need to create a test Account
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(
                                                        Name='Test Supplier',
                                                        Supplier_DUNS__c = 'DUNSTEST',
                                                        Legacy_ID__c = 'TEST',
                                                        Master_DUNS__c = 'DUNSTEST',
                                                        Organization_Identifier_Code__c = 'TESTSUP',
                                                        Supplier_Code__c = 'TEST',
                                                        ESP_Account_Number__c = 'TEST',
                                                        Active__c = true
                                                      );
        insert testOperatingCompany;
        LDC_Vendor__c testVendor = new LDC_Vendor__c(
                                                        Name='Test Vendor',
                                                        DUNS__c = DynegyCommonUtils.generateRandomString(8),
                                                        Legacy_ID__c = 'TVNDR',
                                                        Service_Territory__c = 'AEPOHIO',
                                                        Utility_Code__c = 'TST',
                                                        Vendor_Type__c = 'LDC',
                                                        Service_State__c = 'OH'
                                                    );
        insert testVendor;
        Account testAcct = new Account(
                                        Name='Test CnI',
                                        Supplier__c = testOperatingCompany.Id,
                                        BillingStreet = '2114 Bates Brothers Road',
                                        BillingCity = 'Westerville',
                                        BillingState = 'OH',
                                        BillingPostalCode = '43081',
                                        Billing_Entity__c='Dynegy'
                                        );
        insert testAcct;
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                            Name = DynegyCommonUtils.generateRandomString(10),
                                                            Account__c=testAcct.Id,
                                                            LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                            Service_Street_1__c = '4048 Vineyard Drive',
                                                            Service_City__c = 'Solon',
                                                            Service_State__c = 'OH',
                                                            Service_Postal_Code__c = '44139'
                                                            );
        insert ldcTestAccount;
        
        //create test Contract
        Contract testContract = new Contract(
                                                AccountId=testAcct.Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                  //            Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert testContract;
        //activate the Contract
        testContract.Status = 'Activated';
        testContract.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract;
        //create Contract LDC Record
        Contract_LDC__c testContractLDC = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = testContract.Id
                                                              );
        insert testContractLDC;
        //create DASR Record for enrollment
        DASR_Request__c testRequest = new DASR_Request__c(
                                                            Contract__c = testContract.Id,
                                                            LDC_Account__c = ldcTestAccount.Id,
                                                            DASR_Type__c = 'GAAE',
                                                            DASR_Submit_Date__c = Datetime.now(),
                                                            Integration_Status__c = 'Pending',
                                                            Change_Effective_Date__c = Date.today(),
                                                            Billing_Entity__c='Dynegy'
                                                        );
        insert testRequest;
    }
    
    /**
     * Testing the Main mathod in the class - setActiveContractFromDASR
     **/
    @isTest
    public static void setActiveContractFromDASR(){
        SetupTestData();
        DASR_Request__c testRequest = [SELECT Id FROM DASR_Request__c LIMIT 1];
        
        List<Id> idList = new List<Id>();
        idList.add(testRequest.Id);
        
        Test.startTest();
        
        Flow_SetActiveContractLDC.setActiveContractFromDASR(idList);
        
        Test.stopTest();
    }
}