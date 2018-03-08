/* 
 * Name: LodeStarTest
 * Type: Test Class
 * Apex Class: LodeStar
 * Description: Test class for code coverage of LodeStar. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde                   04/06/2016       1. Initial Version created
 * 1.1        Prasad                        Aug 2016         1. Modified for code coverage
 */

@isTest
global class LodeStarTest {
  /**
     * Designed to set up test data
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
                                                     DUNS__c = 'TEST DUNS',
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
                                     Billing_Entity__c='Dynegy'
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
                                             LDC_End_Date__c = Date.today().addYears(5),
                                             Enrolled__c = true
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
                                      //     Contract_Type__c = 'COST_BASED',
                                             Service_Territory__c='AEPOHIO',
                                             Product_Name__c='FP-ONE'
                                         );
     insert testContract;
     //activate the Contract
     testContract.Status = 'Activated';
     testContract.Contract_Counter_Signed_Date__c = datetime.now();
     update testContract;
     
     Contract testContract1 = new Contract(
                                             AccountId=testAcctList[2].Id,
                                             Name='',
                                             Status='Draft',
                                             StartDate = Date.newInstance(Date.today().year()+1,Date.today().month(),1),
                                             ContractTerm = 12,
                                             Bill_Method__c = 'DUAL',
                                             Rate_Code__c = 'TEST456',
                                     //      Contract_Type__c = 'COST_BASED',
                                             Service_Territory__c='AEPOHIO',
                                             Product_Name__c='FP-ONE'
                                         );
     insert testContract1;
     //activate the Contract
     testContract1.Status = 'Activated';
     testContract1.Contract_Counter_Signed_Date__c = datetime.now();
     update testContract1;
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
                                                             IsSynchronized__c = false
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
 private static testmethod void LodeStar_UnitTest() 
 {
    SetupTestData();
    Test.startTest();
     LodeStar.LodeStarDataContainer containerTest = new LodeStar.LodeStarDataContainer();
     containerTest.customerName = 'Test Customer';
     containerTest.customerShortCode = '12345QWERTY';
     containerTest.customerSFID = '001000000222345d43j';
     Contract testContract = [SELECT 
                              Id, ContractNumber,ActivatedDate, AccountId, Account.BillingStreet,
                              Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                              Account.BillingCountry, Description, Contract_Counter_Signed_Date__c,
                              Account.Name, Account.Short_Code__c, Offer_Code__c,Contract_Type__c,
                              Product_Name__c,Bill_Method__c,//supplier__r.supplier_code__c,
                              StartDate, End_Date__c,LodeStar_Identifier__c,Parent_Contract__r.ContractNumber 
                             FROM Contract LIMIT 1];
     List<Contract_Term__c> testContractTerms = [SELECT 
                                                 Id, Term_Category__c, Term_Start_Date__c, 
                                                 Term_Stop_Date__c, Term_Type__c, Contract_Term_Value__c,
                                                 Value_String__c 
                                                FROM Contract_Term__c WHERE Contract__c =:testContract.Id];
     containerTest.c = testContract;
     containerTest.contractTermList = testContractTerms;
     Map<Id,LDC_Account__c> accountLDCMap = new Map<Id,LDC_Account__c>([SELECT 
                                                                         Id, Name, Account__c,Account__r.Name, Billing_Zip_Postal_code__c,
                                                                         Bill_Cycle__c, LDC_Account_Number__c,Billing_State_Province__c,Billing_Address_Line_3__c,
                                                                         CRM_Id__c, Billing_Street__c,Billing_Address_Line_2__c,Billing_City__c,
                                                                         CreatedDate, LDC_Type__c, LDC_Vendor__c,Delivery_Voltage__c,
                                                                         LDC_Vendor__r.Name, LDC_Vendor__r.Utility_Code__c, Legacy_ID__c,
                                                                         Acct__c, Utility_Rate_Class__c,Account__r.Business_Account__c,
                                                                         Revenue_Class__c, Service_Street_1__c,
                                                                         Service_Street_2__c, Service_City__c,
                                                                         Service_State__c, Service_Postal_Code__c,
                                                                         LDC_Start_Date__c, LDC_End_Date__c,Service_County__c,
                                                                         LDC_Account_Status__c, Supply_Group__c,
                                                                         Account_Type_Code__c, Account__r.Supplier__c,
                                                                         Account__r.Supplier__r.Supplier_Code__c,FIPS_Code__c
                                                                        FROM LDC_Account__c]);
     containerTest.accountLDCMap = accountLDCMap;
     Map<Id,List<Contract_LDC__c>> contractLDCMap = new Map<Id,List<Contract_LDC__c>>();
     for(Contract_LDC__c contractLDC:[SELECT 
                                       Id, 
                                                        Term_Start_Date__c,Bill_Method__c, Term_Stop_Date__c, Active__c, IsSynchronized__c,Parent_Contract__c,
                                                    Contract__c, 
                                                        Contract__r.ContractNumber, Contract__r.ActivatedDate,Contract__r.AccountId,Contract__r.Account.BillingStreet,
                                                        Contract__r.Account.BillingCity,Contract__r.Account.BillingState, Contract__r.Account.BillingPostalCode,
                                                        Contract__r.Account.BillingCountry, Contract__r.Description,Contract__r.Contract_Type__c,
                                                        Contract__r.Contract_Counter_Signed_Date__c,Contract__r.Bill_Method__c,Contract__r.Product_Name__c, 
                                                        Contract__r.Offer_Code__c, Contract__r.StartDate, Contract__r.End_Date__c,Contract__r.Account.Short_Code__c,
                                                        Contract__r.Account.Name, contract__r.Account.Recordtype.name,Contract__r.Parent_Contract__r.ContractNumber,
                                                        Contract__r.LodeStar_Identifier__c,Contract__r.Account.Legal_Entity_Name__c,
                                                    LDC_Account__c,
                                                        LDC_Account__r.Bill_Cycle__c, LDC_Account__r.LDC_Account_Number__c,LDC_Account__r.CRM_Id__c, 
                                                        LDC_Account__r.Delivery_Voltage__c,LDC_Account__r.CreatedDate, LDC_Account__r.LDC_Type__c,
                                                        LDC_Account__r.LDC_Vendor__r.Name, LDC_Account__r.Legacy_ID__c,LDC_Account__r.Acct__c, 
                                                        LDC_Account__r.Utility_Rate_Class__c,LDC_Account__r.Revenue_Class__c, LDC_Account__r.Service_Street_1__c,
                                                        LDC_Account__r.Service_Street_2__c, LDC_Account__r.Service_City__c,LDC_Account__r.Service_State__c, 
                                                        LDC_Account__r.Service_Postal_Code__c,LDC_Account__r.LDC_Start_Date__c, LDC_Account__r.LDC_Account_Status__c,
                                                        LDC_Account__r.LDC_End_Date__c,LDC_Account__r.Supply_Group__c,LDC_Account__r.Account_Type_Code__c,
                                                        LDC_Account__r.Name,LDC_Account__r.LDC_Vendor__r.Utility_Code__c,LDC_Account__r.FIPS_Code__c,
                                                        LDC_Account__r.Service_County__c,LDC_Account__r.Billing_Street__c,LDC_Account__r.Billing_Address_Line_2__c,
                                                        LDC_Account__r.Billing_City__c,LDC_Account__r.Billing_State_Province__c,LDC_Account__r.Billing_Address_Line_3__c, 
                                                        LDC_Account__r.Billing_Zip_Postal_code__c,
                                                    LDC_Account__r.Account__c,
                                                        LDC_Account__r.Account__r.Name, LDC_Account__r.Account__r.Supplier__c, 
                                                        LDC_Account__r.Account__r.Supplier__r.Supplier_Code__c,LDC_Account__r.Account__r.Business_Account__r.Short_Code__c,
                                                        LDC_Account__r.Account__r.Business_Account__c,LDC_Account__r.Account__r.Business_Account__r.Name,
                                                        LDC_Account__r.Account__r.Business_Account__r.Legal_Entity_Name__c
                                      FROM Contract_LDC__c WHERE LDC_Account__c IN :accountLDCMap.keySet()]){
      List<Contract_LDC__c> tempList;
      if(contractLDCMap.containsKey(contractLDC.LDC_Account__c)){
       tempList = contractLDCMap.get(contractLDC.LDC_Account__c);
      } else {
       tempList = new List<Contract_LDC__c>();
      }
      tempList.add(contractLDC);
      contractLDCMap.put(contractLDC.LDC_Account__c,tempList);
     }
     //get the AccountBIllDeterminate__c records
     Map<Id,List<AccountBillDeterminate__c>> contractLDCIdToABDMap = new Map<Id,List<AccountBillDeterminate__c>>();
     for(AccountBillDeterminate__c abd:[SELECT 
                                        Id, LDC_Account__c, LDC_Account__r.LDC_Account_Number__c,
                                        Contract_LDC__r.Contract__c,
                                        Contract_LDC__c, Contract_LDC__r.Contract__r.ContractNumber,
                                        StartDateTime__c, StopDateTime__c, Determinate_Value__c
                                        FROM AccountBillDeterminate__c WHERE LDC_Account__c IN :contractLDCMap.keySet()]){
      List<AccountBillDeterminate__c> tempList;
      if(contractLDCIdToABDMap.containsKey(abd.Contract_LDC__c)){
       tempList = contractLDCIdToABDMap.get(abd.Contract_LDC__c);
      } else {
       tempList = new List<AccountBillDeterminate__c>();
      }
      tempList.add(abd);
      contractLDCIdToABDMap.put(abd.Contract_LDC__c,tempList);
     }
     containerTest.accountBillDeterminateMap = contractLDCIdToABDMap;
     
     containerTest.contractLDCMap = contractLDCMap;
     dynegyComServicesLodeStar.SforceLstarCustomer testCustomerRes = containerTest.buildWebServiceObject();
     LodeStar.LodeStarException ex = new LodeStar.LodeStarException('This is a test');
    Test.stopTest();
 }
 @isTest private static void TestComparable(){
  SetupTestData();
  Test.startTest();
  LodeStar.LodeStarDataContainer container1 = new LodeStar.LodeStarDataContainer();
  LodeStar.LodeStarDataContainer container2 = new LodeStar.LodeStarDataContainer();
  list<Contract> testContract = [SELECT 
                              Id, ContractNumber,ActivatedDate, AccountId, Account.BillingStreet,
                              Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                              Account.BillingCountry, Description, Contract_Counter_Signed_Date__c,
                              Account.Name, Account.Short_Code__c, Offer_Code__c,Contract_Type__c,
                              StartDate, End_Date__c,Product_Name__c 
                             FROM Contract LIMIT 2];
                             
  
  container1.c = null;
  container2.c = testContract[0];
  Integer compareResult = container1.compareTo(container2);
  
  container1.c = testContract[0];
  container2.c = null;
  compareResult = container1.compareTo(container2);                           
                             
  container1.c = testContract[0];
  container2.c = testContract[1];
  compareResult = container1.compareTo(container2);
  
  container1.c = testContract[1];
  container2.c = testContract[0];
  compareResult = container1.compareTo(container2);
  
  container1.c = testContract[0];
  container2.c = testContract[0];
  compareResult = container1.compareTo(container2);
  
  lodestar.LodeStarException lse = new lodestar.LodeStarException('Test Ex','Prev Ex');
  Test.stopTest();
 }
}