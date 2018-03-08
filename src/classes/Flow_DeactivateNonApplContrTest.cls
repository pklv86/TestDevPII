/**
 * The purpose of this class is to provide code coverage to the Flow_DeactivateNonApplicableContracts
 * class
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 **/
@isTest
public class Flow_DeactivateNonApplContrTest{
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
        List<Contract> contractTestList = new List<Contract>();
        contractTestList.add(new Contract(
                                                AccountId=testAcct.Id,
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month()-5,1),
                                                //EndDate = Date.newInstance(Date.today().year()+1,Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                        //      Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            ));
        contractTestList.add(new Contract(
                                            AccountId = testAcct.Id,
                                            Status = 'Draft',
                                            StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                            //EndDate = Date.newInstance(Date.today().year()+1,Date.today().month(),1),
                                            ContractTerm = 12,
                                            Bill_Method__c = 'DUAL',
                                            Rate_Code__c = 'TEST456',
                                       //   Contract_Type__c = 'COST_BASED',
                                            Service_Territory__c = 'AEPOHIO'
                                        ));
        insert contractTestList;
        //activate the Contract
        contractTestList[0].Status = 'Activated';
        contractTestList[0].Contract_Counter_Signed_Date__c = datetime.now();
        contractTestList[1].Status = 'Activated';
        contractTestList[1].Contract_Counter_Signed_Date__c = datetime.now();
        update contractTestList;
        //create Contract LDC Record
        List<Contract_LDC__c> testContractLDCList = new List<Contract_LDC__c>();
        testContractLDCList.add(new Contract_LDC__c(
                                                      LDC_Account__c=ldcTestAccount.Id,
                                                      Contract__c = contractTestList[0].Id,
                                                      Term_Start_date__c = contractTestList[0].StartDate,
                                                      Term_stop_date__c = contractTestList[0].EndDate,
                                                      Active__c = true
                                                   ));
        testContractLDCList.add(new Contract_LDC__c(
                                                      LDC_Account__c=ldcTestAccount.Id,
                                                      Contract__c = contractTestList[1].Id,
                                                      Term_Start_date__c = contractTestList[1].StartDate,
                                                      Term_stop_date__c = contractTestList[1].EndDate,
                                                      Active__c = false
                                                   ));                                                              
        insert testContractLDCList;
        //create DASR Record for enrollment
        DASR_Request__c testRequest = new DASR_Request__c(
                                                            Contract__c = contractTestList[1].Id,
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
     * This provides code coverage testing for the DeactivateNonActiveContractLDCRecs method
     **/
    @isTest 
    public static void DeactivateNonActiveContractLDCRecs(){
        
        SetupTestData();
        
        Contract_LDC__c testItem = [SELECT 
                                        Id, Contract__c, LDC_Account__c 
                                    FROM Contract_LDC__c 
                                    WHERE Active__c = false
                                    LIMIT 1];
        Test.startTest();
        
        List<Id> contractTestList = new List<Id>();
        contractTestList.add(testItem.Id);
        
        Flow_DeactivateNonApplicableContracts.DeactivateNonActiveContractLDCRecs(contractTestList);
        
        Test.stopTest();
    }
     
}