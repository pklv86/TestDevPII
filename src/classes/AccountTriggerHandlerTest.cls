/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class AccountTriggerHandlerTest {

    public static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
        
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST',
                                                           Active__c = true);
        insert testOperatingCompany;
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',Service_Territory__c = 'AEPOHIO',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        List<Account> testAcctList = new List<Account>();
        
		testAcctList.add(new Account(Name='Test MM Offer',Offer_Code__c = 'UWH-R5438-GFT',Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        
        for(Integer i=1; i<=250; i++){                                
        	testAcctList.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass '+i,LastName = 'MarketIndividualAcct',PersonMailingStreet = '4171 Still Street',
                               	         PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                             	         Billing_Entity__c='Dynegy'));
        }
        insert testAcctList;
        for(Integer i=1; i<=250; i++){
        	testAcctList[i].Business_account__c = testAcctList[0].id;
        }
        update testAcctList;
        testAcctList[0].Name+=system.Now();
        update testAcctList[0];
    }
    
    public static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
        
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST',
                                                           Active__c = true);
        insert testOperatingCompany;
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',Service_Territory__c = 'AEPOHIO',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        List<Account> testAcctList = new List<Account>();
        
		testAcctList.add(new Account(Name='Test MM Offer',Offer_Code__c = 'UWH-R5438-GFT',Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        
        for(Integer i=1; i<=20; i++){                                
        	testAcctList.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass '+i,LastName = 'MarketIndividualAcct',PersonMailingStreet = '4171 Still Street',
                               	         PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                             	         Billing_Entity__c='Dynegy'));
        }
        insert testAcctList;
        for(Integer i=1; i<=20; i++){
        	testAcctList[i].Business_account__c = testAcctList[0].id;
        }
        update testAcctList;
        testAcctList[0].Name+=system.Now();
        update testAcctList[0];
    }
}