/**
 * This class is designed to provide code coverage for the 
 * Flow_ReparentAccountfromContractLDC class.
 *
 * @author Chris Gary<cgary@cloudperformer.com>
 * @version 1.0
 **/
@isTest
public class Flow_ReparentAccountfromContractLDCTest{
    private static void SetupTestData(){
          //first we need to create a test Account
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
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
        List<Account> testAcctList = new List<Account>();
        testAcctList.add(new Account(
                                        Name='Test MM Offer',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        Billing_Entity__c='Dynegy'
                                        ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMass',
                                        LastName = 'MarketIndividualAcct',
                                        PersonMailingStreet = '4171 Still Street',
                                        PersonMailingPostalCode = '45819',
                                        PersonMailingCity = 'Buckland',
                                        PersonMailingState = 'OH',
                                        PersonEmail='test@test.com',
                                        PersonHomePhone='419-657-2441',
                                        Billing_Entity__c='Dynegy'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        Name='Test MM Offer 2',
                                        Supplier__c = testOperatingCompany.Id,
                                        Billing_Entity__c='Dynegy'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        Name='Test MM Offer 3',
                                        Supplier__c = testOperatingCompany.Id,
                                        Billing_Entity__c='Dynegy'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMass',
                                        LastName = 'MarketIndividualAcct 2',
                                        PersonMailingStreet = '4172 Still Street',
                                        PersonMailingPostalCode = '45820',
                                        PersonMailingCity = 'Buckland',
                                        PersonMailingState = 'OH',
                                        PersonEmail='test@test.com',
                                        PersonHomePhone='419-657-2442',
                                        Billing_Entity__c='Dynegy'
                                        ));
        insert testAcctList;
        testAcctList[1].Business_Account__c = testAcctList[0].Id;
        update testAcctList[1];
        testAcctList[4].Business_Account__c = testAcctList[2].Id;
        update testAcctList[4];
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                            Name = DynegyCommonUtils.generateRandomString(10),
                                                            Account__c=testAcctList[1].Id,
                                                            LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                            Service_Street_1__c = '4048 Vineyard Drive',
                                                            Service_City__c = 'Solon',
                                                            Service_State__c = 'OH',
                                                            Service_Postal_Code__c = '44139'
                                                            );
        insert ldcTestAccount;
        LDC_Account__c ldcTestAccount1 = new LDC_Account__c(
                                                            Name = DynegyCommonUtils.generateRandomString(10),
                                                            Account__c=testAcctList[4].Id,
                                                            LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                            Service_Street_1__c = '4049 Vineyard Drive',
                                                            Service_City__c = 'Solon',
                                                            Service_State__c = 'OH',
                                                            Service_Postal_Code__c = '44140'
                                                            );
        insert ldcTestAccount1;
        
        //create test Contract
        List<Contract> contractTestList = new List<Contract>();
        contractTestList.add(new Contract(
                                                AccountId=testAcctList[0].Id,
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                    //          Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            ));
        contractTestList.add(new Contract(
                                            AccountId = testAcctList[2].Id,
                                            Status = 'Draft',
                                            StartDate = Date.newInstance(Date.today().year()+1,Date.today().month(),1),
                                            ContractTerm = 12,
                                            Bill_Method__c = 'DUAL',
                                            Rate_Code__c = 'TEST456',
                                    //      Contract_Type__c = 'COST_BASED',
                                            Service_Territory__c = 'AEPOHIO'
                                        ));
        contractTestList.add(new Contract(
                                            AccountId = testAcctList[3].Id,
                                            Status = 'Draft',
                                            StartDate = Date.newInstance(Date.today().year()+1,Date.today().month(),1),
                                            ContractTerm = 18,
                                            Bill_Method__c = 'UCB',
                                            Rate_Code__c = 'TEST789',
                                     //     Contract_Type__c = 'COST_BASED',
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
                                                                Active__c = true
                                                              ));
        testContractLDCList.add(new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = contractTestList[1].Id,
                                                                Active__c = false
                                                              )); 
        testContractLDCList.add(new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = contractTestList[2].Id,
                                                                Active__c = false
                                                              ));    
        testContractLDCList.add(new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount1.Id,
                                                                Contract__c = contractTestList[2].Id,
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
    
    @isTest
    public static void ReparentAccount(){
        SetupTestData();
        
        List<Contract_LDC__c> contractList = [SELECT Id FROM Contract_LDC__c WHERE Active__c = false];
        
        Test.startTest();
        
        List<Id> contractLDCIdList = new List<Id>();
        contractLDCIdList.add(contractList[0].Id);
        contractLDCIdList.add(contractList[1].Id);
        contractLDCIdList.add(contractList[2].Id);
        
        Flow_ReparentAccountfromContractLDC.ReparentAccount(contractLDCIdList);
        
        Test.stopTest();
    }
}