@isTest
public class PeakLoadTrigger_Test {
    static Account acc;
    static LDC_Account__c lacc;
    static LDC_Account__c lacc1;
    static LDC_Account__c lacc2;
    static Supplier__c supplier;
    static Peak_Load_Information__c pli;
    static Peak_Load_Information__c pli1;
    static Peak_Load_Information__c pli2;
    static Peak_Load_Information__c pli3;
    static Peak_Load_Information__c pli4;
    static testmethod void PLItestMethod(){
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        String query = 'Select id, DASR_Request__c, LDC_Account__c, Load_Type__c, Load_Value__c, Start_date__c, EndDate__c from Peak_Load_Information__c where id in: Trigger.new';
        supplier = new Supplier__c();
        supplier.NAme ='Test supplier';
        supplier.Master_DUNS__c  ='1223';
        supplier.Supplier_DUNS__c ='999';
        supplier.Active__c = true;
        insert supplier;
        
        acc = new Account();
        acc.name = 'Test Acc';
        acc.Supplier__c = supplier.Id;
        acc.Billing_Entity__c='Dynegy';
        insert acc;
         
        lacc = new LDC_Account__c();
        lacc.name  ='Test LDC acc';
        lacc.Account__c = acc.id;
        lacc.LDC_Account_Number__c = '00040621040044404';
        lacc.enrolled__c = true;
        insert lacc;
        
        lacc1 = new LDC_Account__c();
        lacc1.name  ='Test LDC acc1';
        lacc1.Account__c = acc.id;
        lacc1.LDC_Account_Number__c = '00040621040044444';
        lacc1.opt_out__c = true;
        lacc1.enrolled__c = true;
        lacc1.LDC_Account_Status__c = 'Pending_Final';
        insert lacc1;
        
        lacc2 = new LDC_Account__c();
        lacc2.name  ='Test LDC acc2';
        lacc2.Account__c = acc.id;
        lacc2.enrolled__c = true;
        lacc2.LDC_Account_Number__c = '00040621044444444';
        insert lacc2;
        
        pli = new Peak_Load_Information__c();
        pli.Load_Type__c = 'PLC';
        pli.ldc_account__c = lacc.id;
        pli.Load_Value__c = 2;
        pli.Start_Date__c = System.today();
        pli.EndDate__c = System.today()+2;
        insert pli;
        
        pli1 = new Peak_Load_Information__c();
        pli1.Load_Type__c = 'PLC';
        pli1.ldc_account__c = lacc.id;
        pli1.Load_Value__c = 2.5;
        pli1.Start_Date__c = System.today()+1;
        pli1.EndDate__c = System.today()+1;
        try{
            insert pli1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Record of type already exist in the time period') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        pli2 = new Peak_Load_Information__c();
        pli2.ldc_account__c = lacc2.id;
        pli2.Load_Type__c = 'NSPLC';
        pli2.Load_Value__c = 3;
        pli2.Start_Date__c = System.today();
        pli2.EndDate__c = System.today()+1;
        insert pli2;
        
        pli3 = new Peak_Load_Information__c();
        pli3.ldc_account__c = lacc2.id;
        pli3.Load_Type__c = 'NSPLC';
        pli3.Load_Value__c = 3.5;
        pli3.Start_Date__c = System.today();
        pli3.EndDate__c = System.today()+1;
        try{
            insert pli3;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Record of type already exist in the time period') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        pli4 = new Peak_Load_Information__c();
        pli4.ldc_account__c = lacc2.id;
        pli4.Load_Type__c = 'NSPLC';
        pli4.Load_Value__c = 4;
        pli4.Start_Date__c = System.today()+10;
        pli4.EndDate__c = System.today()+20;
        insert pli4;
    }
}