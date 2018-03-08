/**
 * This class is designed to provide code coverage to
 * the LodeStarIntegrationProcessor Class
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 * @version 1.1 - Prasad - Modified for code coverage
 **/
@isTest
private class LodeStarIntegrationProcessorTest{
    /**
     * Setup Test Data 
     **/
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
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMass',
                                        LastName = 'MarketIndividualAcct2',
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
                                        RecordTypeId = massMarketIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMass',
                                        LastName = 'MarketIndividualAcct2',
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
                                        Name='Test C&I',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = ciAcctRecType.getRecordTypeId(),
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Validation__c = 'Validated',
                                        Legal_Entity_Name__c ='22oh587t3t324rj834r8yr^&$@*88cwr83253t8t83t*Y$NUY*%*#*8m84u8t83hfht7',
                                        Billing_Entity__c='Dynegy'
                                        ));
        insert testAcctList;
        testAcctList[1].Business_Account__c = testAcctList[0].Id;
        testAcctList[3].Business_Account__c = testAcctList[0].Id;
        testAcctList[4].Business_Account__c = testAcctList[0].Id;
        update new list<account>{testAcctList[1],testAcctList[3],testAcctList[4]};
        //now we need to create an LDC_Account__c record
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                Name = 'Test LDC MM1',
                                                Account__c=testAcctList[1].Id,
                                                LDC_Account_Number__c = 'LDCMM000001',
                                                Service_Street_1__c = '4048 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_Status__c = 'Active',
                                                Crm_Id__c ='HH321J45JOL321',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(
                                                Name = 'Test LDC MM2',
                                                Account__c=testAcctList[3].Id,
                                                LDC_Account_Number__c = 'LDCMM000002',
                                                Service_Street_1__c = '4050 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_Status__c = 'Active',
                                                Crm_Id__c ='HH321J45JOL322',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount3 = new LDC_Account__c(
                                                Name = 'Test LDC MM3',
                                                Account__c=testAcctList[4].Id,
                                                LDC_Account_Number__c = 'LDCMM000003',
                                                Service_Street_1__c = '4053 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_Status__c = 'Active',
                                                Crm_Id__c ='HH321J45JOL323',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount4 = new LDC_Account__c(
                                                Name = 'Test LDC CI1',
                                                Account__c=testAcctList[5].Id,
                                                LDC_Account_Number__c = 'LDCCI000001',
                                                Service_Street_1__c = '4053 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_Account_Status__c = 'Active',
                                                Crm_Id__c ='HH321J45JOL324',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount5 = new LDC_Account__c(
                                                Name = 'Test LDC CI2',
                                                Account__c=testAcctList[5].Id,
                                                LDC_Account_Number__c = 'LDCCI000002',
                                                Service_Street_1__c = '4053 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_Status__c = 'Final',
                                                Crm_Id__c ='HH321J45JOL325',
                                                Enrolled__c = true
                                            );
        insert new list<ldc_account__C>{ldcTestAccount,ldcTestAccount2,ldcTestAccount3,ldcTestAccount4,ldcTestAccount5};
        
        Peak_Load_Information__c plc = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc2 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount2.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc2 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount2.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc3 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount3.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc3 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount3.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc4 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount4.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc4 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount4.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc5 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount5.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc5 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount5.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		insert new list<Peak_Load_Information__c>{plc,nsplc,plc2,nsplc2,plc3,nsplc3,plc4,nsplc4,plc5,nsplc5};
        
        opportunity op = new opportunity(Name = 'Test opp',accountId=testAcctList[2].Id,type='C&I',service_territory__c='AEPOHIO',CloseDate=date.today(),
											StageName='New',Pricing_Due_Date__c=date.today());
		insert op;
        //create test Contract
        Contract testContract = new Contract(
                                                AccountId=testAcctList[0].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'Bill Ready',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        Contract testContract2 = new Contract(
                                                AccountId=testAcctList[2].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        Contract testContract3 = new Contract(
                                                AccountId=testAcctList[5].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Block and Index',
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert new list<contract>{testContract,testContract2,testContract3};
        //activate the Contract
        testContract.Status = 'Activated';
        testContract.Contract_Counter_Signed_Date__c = datetime.now();
        testContract2.Status = 'Activated';
        testContract2.Contract_Counter_Signed_Date__c = datetime.now();
        testContract3.Status = 'Activated';
        testContract3.Contract_Counter_Signed_Date__c = datetime.now();
        update new list<contract>{testContract,testContract2,testContract3};
        
        Contract_Type_Setting__c cts1 = new Contract_Type_Setting__c(Name='AEPOHIO-DUAL-CT1',Contract_Type__c='TIER_1_2',New_Contract_Type__c='Block and Index',Bill_Method__c='DUAL',Contract_Code__c='CT1',Service_Territory__c='AEPOHIO');
		Contract_Type_Setting__c cts2 = new Contract_Type_Setting__c(Name='AEPOHIO-DUAL-CT2',Contract_Type__c='UCBPOR',New_Contract_Type__c='Small Stable Contract - Evergreen',Bill_Method__c='Bill Ready',Contract_Code__c='CT2',Service_Territory__c='AEPOHIO');
		Contract_Type_Setting__c cts3 = new Contract_Type_Setting__c(Name='AEPOHIO-RateReady-CT3',Contract_Type__c='UCBNONPOR',New_Contract_Type__c='Large Stable Contract',Bill_Method__c='RateReady',Contract_Code__c='CT3',Service_Territory__c='AEPOHIO');
		insert new list<Contract_Type_Setting__c>{cts1,cts2,cts3};
        
        Billing_Group__c bg = new Billing_Group__c(Name='Test Billing Group',Account__c=testAcctList[5].Id,contract__c=testContract3.id,synchronized__c=false);
		insert bg;
		
		Billing_Group_Ldc__c bgldc = new Billing_Group_Ldc__c(billing_group__C = bg.id,ldc_account__c = ldcTestAccount4.id,synchronized__c = false,Billing_Start_Date__c=system.now(),Billing_Stop_Date__c=system.now().addyears(1));
		Billing_Group_Ldc__c bgldc2 = new Billing_Group_Ldc__c(billing_group__C = bg.id,ldc_account__c = ldcTestAccount5.id,synchronized__c = false,Billing_Start_Date__c=system.now(),Billing_Stop_Date__c=system.now().addyears(1));
		insert new list<Billing_Group_Ldc__c>{bgldc,bgldc2};
		
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
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                isSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC2 = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount2.Id,
                                                                Contract__c = testContract.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                isSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC3 = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount3.Id,
                                                                Contract__c = testContract2.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                isSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC4 = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount4.Id,
                                                                Contract__c = testContract3.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                isSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC5 = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount5.Id,
                                                                Contract__c = testContract3.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                isSynchronized__c = false
                                                              );
        
        insert new list<contract_ldc__c>{testContractLDC,testContractLDC2,testContractLDC3,testContractLDC4,testContractLDC5};
        //create an AccountBillDeterminate__c record
        AccountBillDeterminate__c testABD = new AccountBillDeterminate__c(
                                                    Contract_LDC__c = testContractLDC.Id,
                                                    Determinate_Value__c = 2.0,
                                                    LDC_Account__c = ldcTestAccount.Id,
                                                    StartDateTime__c = Datetime.now(),
                                                    StopDateTime__c = Datetime.now().addMonths(11)
                                                );
        insert testABD;
        
        testAcctList[1].Validation__c = 'Validated';
        testAcctList[3].Validation__c = 'Validated';
        testAcctList[4].Validation__c = 'Validated';
        testAcctList[5].Validation__c = 'Validated';
        update new list<account>{testAcctList[1],testAcctList[3],testAcctList[4],testAcctList[5]};
    }
    
    @isTest
    private static void TestBatchable(){
        SetupTestData();
        
        Test.startTest();
        
        Set<Id> idSet = LodeStarActions.ObtainNonSynchronizedAccounts();
        LodeStarIntegrationProcessor testProc = new LodeStarIntegrationProcessor(idSet,idset);
        Database.executeBatch(testProc,10);
              
        Test.stopTest();
    }
    
    @isTest
    private static void TestSchedulable(){
        SetupTestData();
        Test.startTest();
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('TestLodeStarProcessSchedule',CRON_EXP,new LodeStarIntegrationProcessor());
        
        Test.stopTest();
    }
}