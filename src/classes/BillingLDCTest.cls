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
public class BillingLDCTest {

    public static testMethod void BillingLDCTest_1() {
        // TO DO: implement unit test
       
       RecordType rec =[select id,name from RecordType where sObjectType = 'Account' and name = 'C&I Customer']; 
       Account acc = new Account();
       acc.name = 'Test Acc';
       acc.Billing_Entity__c = 'Dynegy';
       acc.RecordTypeId = rec.id;
       insert acc;
       
       Contract cnt = new Contract(AccountId=acc.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = 'DK98',Service_Territory__c='AEPOHIO');        //,Contract_Type__c = 'COST_BASED'
       insert cnt;
       
       cnt.status='Activated';
       update cnt;
       
       Contract cnt2 = new Contract(AccountId=acc.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().addyears(-1).year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = 'DK98',Service_Territory__c='AEPOHIO');        //,Contract_Type__c = 'COST_BASED'
       insert cnt2;
       
       cnt2.status='Activated';
       update cnt2;
       
       Contract cnt3 = new Contract(AccountId=acc.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().addyears(1).year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = 'DK98',Service_Territory__c='AEPOHIO');        //,Contract_Type__c = 'COST_BASED'
       insert cnt3;
       
       cnt3.status='Activated';
       update cnt3;
       
       Billing_Group__c bg1 = new Billing_Group__c();
       bg1.Name = 'Test BG 1';
       bg1.account__c = acc.id;
       bg1.contract__c = cnt.id;  
       bg1.Group_Address_Line1__c='Test add1';
       bg1.start_Date__c = date.today(); 
       
       Billing_Group__c bg2 = new Billing_Group__c();
       bg2.Name = 'Test BG 2';
       bg2.account__c = acc.id;
       bg2.contract__c = cnt.id;  
       bg2.Group_Address_Line1__c='Test add1';
       bg2.start_Date__c = date.today();  
       
       Billing_Group__c bg3 = new Billing_Group__c();
       bg3.Name = 'Test BG 3';
       bg3.account__c = acc.id;
       bg3.contract__c = cnt2.id;  
       bg3.Group_Address_Line1__c='Test add1';
       bg3.start_Date__c = date.today();
       
       Billing_Group__c bg4 = new Billing_Group__c();
       bg4.Name = 'Test BG 4';
       bg4.account__c = acc.id;
       bg4.contract__c = cnt3.id;  
       bg4.Group_Address_Line1__c='Test add1';
       bg4.start_Date__c = date.today();
       
       insert new list<Billing_Group__c>{bg1,bg2,bg3,bg4};   
       
       ApexPages.currentPage().getParameters().put('BGID',bg1.id);
       BillingLDC bg = new BillingLDC();
       ApexPages.currentPage().getParameters().put('BGID',null);
       ApexPages.currentPage().getParameters().put('UBGID',bg2.id);
       BillingLDC bgd = new BillingLDC();
       ApexPages.currentPage().getParameters().put('UBGID',null);
       BillingLDC bgd1 = new BillingLDC();
       
       LDC_Account__c lacc1 = new LDC_Account__c();
       lacc1.name  ='Test LDC acc';
       lacc1.Account__c = acc.id;
       lacc1.Service_Territory__c = 'AEPOHIO';
       lacc1.LDC_Account_Number__c = '1234';
       
       LDC_Account__c lacc2 = new LDC_Account__c();
       lacc2.name  ='Test LDC acc1';
       lacc2.Account__c = acc.id;
       lacc2.Service_Territory__c = 'AEPOHIO';
       lacc2.LDC_Account_Number__c = '2345';
       
       LDC_Account__c lacc3 = new LDC_Account__c();
       lacc3.name  ='Test LDC acc';
       lacc3.Account__c = acc.id;
       lacc3.Service_Territory__c = 'AEPOHIO';
       lacc3.LDC_Account_Number__c = '3456';
       
       LDC_Account__c lacc4 = new LDC_Account__c();
       lacc4.name  ='Test LDC acc1';
       lacc4.Account__c = acc.id;
       lacc4.Service_Territory__c = 'AEPOHIO';
       lacc4.LDC_Account_Number__c = '4567';
       
       insert new list<ldc_account__c>{lacc1,lacc2,lacc3,lacc4};
       
       contract_ldc__c cldc1 = new contract_ldc__c();
       cldc1.name='Test Cldc1';
       cldc1.ldc_account__c = lacc1.id;
       cldc1.contract__c = cnt.id;
       
       contract_ldc__c cldc2 = new contract_ldc__c();
       cldc2.name='Test Cldc2';
       cldc2.ldc_account__c = lacc2.id;
       cldc2.contract__c = cnt.id;
       
       contract_ldc__c cldc3 = new contract_ldc__c();
       cldc3.name='Test Cldc3';
       cldc3.ldc_account__c = lacc3.id;
       cldc3.contract__c = cnt.id;
       
       contract_ldc__c cldc4 = new contract_ldc__c();
       cldc4.name='Test Cldc4';
       cldc4.ldc_account__c = lacc4.id;
       cldc4.contract__c = cnt.id;
       
       insert new list<contract_ldc__c>{cldc1,cldc2,cldc3,cldc4};
       
       ApexPages.currentPage().getParameters().put('BGID',bg1.id);
       BillingLDC bgadd = new BillingLDC();
       bgadd.selectionId = lacc1.id;
       bgadd.selectionId = lacc2.id;
       bgadd.addSelectedId();
       bgadd.addAccounts();
       bgadd.getLDCAccounts(); 
       bgadd.setHeaderValue();
       bgadd.cancel();
       bgadd.getSelectedCount();
       bgadd.getPagenumber();
       bgadd.getTotalpages();
       bgadd.getHasPrevious();
       bgadd.getHasNext();
       bgadd.doNext();
       bgadd.doPrevious();
       
       bgadd.selectionId = null;
       bgadd.addSelectedId();
       bgadd.addAccounts();
       
       ApexPages.currentPage().getParameters().put('BGID',null);
       ApexPages.currentPage().getParameters().put('UBGID',bg1.id);
       BillingLDC bgdel = new BillingLDC();
       bgdel.selectionId = lacc2.id;
       bgdel.addSelectedId();
       bgdel.addAccounts();
       bgdel.delAccounts();
       bgdel.removeSelectedId();
       
       bgdel.selectionId = lacc2.id;
       bgdel.addSelectedId();
       bgdel.addAccounts();
       bgdel.selectionId = null;
       bgdel.removeSelectedId();
       bgdel.delAccounts();
       
       Billing_Group_Ldc__c bgldc = new Billing_Group_Ldc__c();
       bgldc.billing_group__c = bg2.id;
       bgldc.ldc_account__c = lacc4.id;
       bgldc.synchronized__c = true;
       insert bgldc;
       
       bg2.Group_Address_Line3__c = 'In Care of # Billing group 2';
       update bg2;
       
       ApexPages.currentPage().getParameters().put('BGID',bg3.id);
       BillingLDC bgadd1 = new BillingLDC();
       bgadd1.selectionId = lacc1.id;
       bgadd1.selectionId = lacc2.id;
       bgadd1.addSelectedId();
       bgadd1.addAccounts();
       
       ApexPages.currentPage().getParameters().put('BGID',bg4.id);
       BillingLDC bgadd2 = new BillingLDC();
       bgadd2.selectionId = lacc1.id;
       bgadd2.selectionId = lacc2.id;
       bgadd2.addSelectedId();
       bgadd2.addAccounts();
        
    }
}