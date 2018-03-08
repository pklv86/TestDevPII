/**
 * this class is designed to provide code coverage to the 
 * LodeStarIntegrationQueueJob Class
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 **/
@isTest
private class LodeStarIntegrationQueueJobTest{
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
        //create a test vendor
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
        //create a series of test accounts of different kinds
        List<Account> testAcctList = new List<Account>();
        testAcctList.add(new Account(
                                        Name='Test MM Offer',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
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
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy',Validation__c = 'Validated'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        Name='Test MM Offer 2',
                                        Supplier__c = testOperatingCompany.Id,
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy'
                                    ));
        insert testAcctList;
        testAcctList[1].Business_Account__c = testAcctList[0].Id;
        update testAcctList[1];
        //now we need to create an LDC_Account__c record
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                Name = DynegyCommonUtils.generateRandomString(10),
                                                Account__c=testAcctList[1].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4048 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5)
                                            );
        insert ldcTestAccount;
        //create test Contract
        Contract testContract = new Contract(
                                                AccountId=testAcctList[0].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                    //          Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert testContract;
        //activate the Contract
        testContract.Status = 'Activated';
        testContract.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract;
        //create a phone Contract Term
        Contract_Term__c testContractTerm = new Contract_Term__c(
                                                    Contract__c = testContract.Id,
                                                    Term_Category__c = 'NOTBILLED',
                                                    Term_Type__c = 'CUST_CHRG',
                                                    Contract_Term_Value__c = 5.0,
                                                    Term_Start_Date__c = Datetime.now(),
                                                    Term_Stop_Date__c = Datetime.now().addMonths(11)
                                                );
        insert testContractTerm;
        //create Contract LDC Record
        Contract_LDC__c testContractLDC = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = testContract.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12)
                                                              );
        insert testContractLDC;
        //create an AccountBillDeterminate__c record
        AccountBillDeterminate__c testABD = new AccountBillDeterminate__c(
                                                    Contract_LDC__c = testContractLDC.Id,
                                                    Determinate_Value__c = 2.0,
                                                    LDC_Account__c = ldcTestAccount.Id,
                                                    StartDateTime__c = Datetime.now(),
                                                    StopDateTime__c = Datetime.now().addMonths(11)
                                                );
        insert testABD;
    }
    
    @isTest
    private static void QueueableTest(){
        SetupTestData();
        
        Test.startTest();
        
        Set<Id> idSet = LodeStarActions.ObtainNonSynchronizedAccounts();
        LodeStarIntegrationQueueJob testJob = new LodeStarIntegrationQueueJob(idSet,idset);
        System.enqueueJob(testJob);
        
        Test.stopTest();
    }
}