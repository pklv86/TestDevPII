@isTest(SeeAllData=false)
public class updateMeterObjectTest {
    static  DASR_Request__c reqGAAC;
    static  LDC_Account__c lacc1;
    
    
   static void createTestData(){
        
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c = 'Dynegy' ;
        insert acc;
        
        account acc2 = [select id,name from account where id =: acc.id];
        system.debug('***FirstAssert' + acc2);
        System.assertEquals(acc.name,'Test Acc');
        
        
        Contract testContr = new Contract(
                                                AccountId=acc.Id,
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert testContr;
        
        contract testContr2 = [select id,Rate_Code__c  from Contract where id =: testContr.id];
        System.assertEquals(testContr.Rate_Code__c ,'TEST123');
        
        testContr.Status = 'Activated';
        testContr.Contract_Counter_Signed_Date__c = datetime.now();
        update testContr;
        
        lacc1 = new LDC_Account__c();
        lacc1.name  ='Test LDC acc';
        lacc1.Account__c = acc.id;
        lacc1.LDC_Account_Number__c = '12345';
        
        insert lacc1;
        
        LDC_Account__c lacc2 = [select id,name from LDC_Account__c where id =: lacc1.id];
        System.assertEquals(lacc2.name ,'Test LDC acc');

        reqGAAC = new DASR_Request__c();
        reqGAAC.Change_Reason__c = 'Test Reason';
        reqGAAC.LDC_Account__c = lacc1.id;
        reqGAAC.Billing_Entity__c = 'Dynegy';
        reqGAAC.Contract__c = testContr.Id;
        reqGAAC.Integration_Status__c = 'Waiting For Response';
        reqGAAC.DASR_Submit_Date__c = date.today();
        reqGAAC.Change_Effective_Date__c = date.today();
        reqGAAC.DASR_Type__c = 'GAAC';
        insert reqGAAC;
        
        DASR_Request__c reqGAAC2 = [select id,DASR_Type__c  from DASR_Request__c where id =: reqGAAC.id];
        System.assertEquals(reqGAAC2.DASR_Type__c ,'GAAC');
    }
    
    private static testmethod void updateMeterObject_UnitTestForUpdate() 
    {
        Test.startTest();
        
        createTestData();
        
        //insert vendor meter
        Vendor_Meter__c meter = new Vendor_Meter__c();
        meter.DASR_Request__c = reqGAAC.id;
        meter.LDC_Account__c = lacc1.id;
        meter.Meter_Number__c = '123456';
        meter.Meter_Type_Code__c = 'KHMON';
        insert meter;
        
        Vendor_Meter__c meter2 = [select id,Meter_Number__c from Vendor_Meter__c where id =: meter.id];
        System.assertEquals(meter2.Meter_Number__c,'123456');
        
        //insert Service_Point__c
        Service_Point__c point = new Service_Point__c();
        point.LDC_Account_Number__c = lacc1.id;
        point.Service_Point_Number__c = 'Test9848484';
        insert point;
        
        Service_Point__c point2 = [select id,Service_Point_Number__c  from Service_Point__c where id =: point.id];
        System.assertEquals(point2.Service_Point_Number__c ,'Test9848484');
        
        //insert meter Meter__c
        
        Meter__c meterObj = new Meter__c();
        meterObj.Service_Point__c = point.id;
        meterObj.Meter_Number__c = '123456';
        insert meterObj;
        
        Meter__c meterObj2 = [select id,Meter_Number__c  from Meter__c where id =: meterObj.id];
        System.assertEquals(meterObj2.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException6 = new Vendor_Meter_Exception__c();
        venException6.DASR_Request__c = reqGAAC.id;
        venException6.LDC_Account__c = lacc1.id;
        venException6.Reason_Code__c = 'REF4P';
        venException6.Meter_Number__c = '123456';
        insert venException6;
               
        Vendor_Meter_Exception__c venExceptionAssert6 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException6.id];
        System.assertEquals(venExceptionAssert6.Meter_Number__c ,'123456');

        venException6.Reason_Code__c = 'REFLO';
        venException6.Meter_Number__c = 'ALL';
        
        update venException6;
        
        Vendor_Meter_Exception__c venExceptionAssert7 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException6.id];
        System.assertEquals(venExceptionAssert7.Meter_Number__c ,'ALL');
       
        
        Test.stopTest();
        
        
      }
    
     private static testmethod void updateMeterObject_UnitTest3() 
    {
        Test.startTest();
        
        createTestData();
        
        //insert vendor meter
        Vendor_Meter__c meter = new Vendor_Meter__c();
        meter.DASR_Request__c = reqGAAC.id;
        meter.LDC_Account__c = lacc1.id;
        meter.Meter_Number__c = '123456';
        meter.Meter_Type_Code__c = 'KHMON';
        insert meter;
        
        Vendor_Meter__c meter2 = [select id,Meter_Number__c from Vendor_Meter__c where id =: meter.id];
        System.assertEquals(meter2.Meter_Number__c,'123456');
        
        //insert Service_Point__c
        Service_Point__c point = new Service_Point__c();
        point.LDC_Account_Number__c = lacc1.id;
        point.Service_Point_Number__c = 'Test9848484';
        insert point;
        
        Service_Point__c point2 = [select id,Service_Point_Number__c  from Service_Point__c where id =: point.id];
        System.assertEquals(point2.Service_Point_Number__c ,'Test9848484');
        
        //insert meter Meter__c
        
        Meter__c meterObj = new Meter__c();
        meterObj.Service_Point__c = point.id;
        meterObj.Meter_Number__c = '123456';
        insert meterObj;
        
        Meter__c meterObj2 = [select id,Meter_Number__c  from Meter__c where id =: meterObj.id];
        System.assertEquals(meterObj2.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException6 = new Vendor_Meter_Exception__c();
        venException6.DASR_Request__c = reqGAAC.id;
        venException6.LDC_Account__c = lacc1.id;
        venException6.Reason_Code__c = 'REFTU';
        venException6.Meter_Number__c = '123456';
        insert venException6;
               
        Vendor_Meter_Exception__c venExceptionAssert6 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException6.id];
        System.assertEquals(venExceptionAssert6.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException7 = new Vendor_Meter_Exception__c();
        venException7.DASR_Request__c = reqGAAC.id;
        venException7.LDC_Account__c = lacc1.id;
        venException7.Reason_Code__c = 'REFLF';
        venException7.Meter_Number__c = '123456';
        insert venException7;
        
        Vendor_Meter_Exception__c venExceptionAssert7 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException7.id];
        System.assertEquals(venExceptionAssert7.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException8 = new Vendor_Meter_Exception__c();
        venException8.DASR_Request__c = reqGAAC.id;
        venException8.LDC_Account__c = lacc1.id;
        venException8.Reason_Code__c = 'REFSV';
        venException8.Meter_Number__c = '123456';
        insert venException8;
        
        Vendor_Meter_Exception__c venExceptionAssert8 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException8.id];
        System.assertEquals(venExceptionAssert8.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException9 = new Vendor_Meter_Exception__c();
        venException9.DASR_Request__c = reqGAAC.id;
        venException9.LDC_Account__c = lacc1.id;
        venException9.Reason_Code__c = 'NM1MX';
        venException9.Meter_Number__c = '123456';
        insert venException9;
        
        Vendor_Meter_Exception__c venExceptionAssert9 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException9.id];
        System.assertEquals(venExceptionAssert9.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException10 = new Vendor_Meter_Exception__c();
        venException10.DASR_Request__c = reqGAAC.id;
        venException10.LDC_Account__c = lacc1.id;
        venException10.Reason_Code__c = 'NM1MA';
        venException10.Meter_Number__c = '123456';
        insert venException10;
        
        Vendor_Meter_Exception__c venExceptionAssert10 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException10.id];
        System.assertEquals(venExceptionAssert10.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException11 = new Vendor_Meter_Exception__c();
        venException11.DASR_Request__c = reqGAAC.id;
        venException11.LDC_Account__c = lacc1.id;
        venException11.Reason_Code__c = 'REFMT';
        venException11.Meter_Number__c = '123456';
        insert venException11;
        
        Vendor_Meter_Exception__c venExceptionAssert11 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException11.id];
        System.assertEquals(venExceptionAssert11.Meter_Number__c ,'123456');
        
        
        Vendor_Meter_Exception__c venException5 = new Vendor_Meter_Exception__c();
        venException5.DASR_Request__c = reqGAAC.id;
        venException5.LDC_Account__c = lacc1.id;
        venException5.Reason_Code__c = 'NM1MA';
        venException5.Meter_Number__c = '123456';
        insert venException5;
        
        Vendor_Meter_Exception__c venExceptionAssert5 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException5.id];
        System.assertEquals(venExceptionAssert5.Meter_Number__c ,'123456');
        
         Vendor_Meter_Exception__c venException4 = new Vendor_Meter_Exception__c();
        venException4.DASR_Request__c = reqGAAC.id;
        venException4.LDC_Account__c = lacc1.id;
        venException4.Reason_Code__c = 'NM1MX';
        venException4.Meter_Number__c = '123456';
        insert venException4;
        
        Vendor_Meter_Exception__c venExceptionAssert4 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException4.id];
        System.assertEquals(venExceptionAssert4.Meter_Number__c ,'123456');
        
                   
        Test.stopTest();
    }
    
    private static testmethod void updateMeterObject_UnitTest7() 
    {
        Test.startTest();
        
        createTestData();
        
        //insert vendor meter
        Vendor_Meter__c meter = new Vendor_Meter__c();
        meter.DASR_Request__c = reqGAAC.id;
        meter.LDC_Account__c = lacc1.id;
        meter.Meter_Number__c = '123456';
        meter.Meter_Type_Code__c = 'KHMON';
        insert meter;
        
        Vendor_Meter__c meter2 = [select id,Meter_Number__c from Vendor_Meter__c where id =: meter.id];
        System.assertEquals(meter2.Meter_Number__c,'123456');
        
        //insert Service_Point__c
        Service_Point__c point = new Service_Point__c();
        point.LDC_Account_Number__c = lacc1.id;
        point.Service_Point_Number__c = 'Test9848484';
        insert point;
        
        Service_Point__c point2 = [select id,Service_Point_Number__c  from Service_Point__c where id =: point.id];
        System.assertEquals(point2.Service_Point_Number__c ,'Test9848484');
        
        //insert meter Meter__c
        
        Meter__c meterObj = new Meter__c();
        meterObj.Service_Point__c = point.id;
        meterObj.Meter_Number__c = '123456';
        insert meterObj;
        
        Meter__c meterObj2 = [select id,Meter_Number__c  from Meter__c where id =: meterObj.id];
        System.assertEquals(meterObj2.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException6 = new Vendor_Meter_Exception__c();
        venException6.DASR_Request__c = reqGAAC.id;
        venException6.LDC_Account__c = lacc1.id;
        venException6.Reason_Code__c = 'REFTU';
        venException6.Meter_Number__c = '123456';
        
               
        
        
        Vendor_Meter_Exception__c venException7 = new Vendor_Meter_Exception__c();
        venException7.DASR_Request__c = reqGAAC.id;
        venException7.LDC_Account__c = lacc1.id;
        venException7.Reason_Code__c = 'REFLF';
        venException7.Meter_Number__c = '123456';
        
        
        
        
        Vendor_Meter_Exception__c venException8 = new Vendor_Meter_Exception__c();
        venException8.DASR_Request__c = reqGAAC.id;
        venException8.LDC_Account__c = lacc1.id;
        venException8.Reason_Code__c = 'REFSV';
        venException8.Meter_Number__c = '123456';
        
        
        
        
        Vendor_Meter_Exception__c venException9 = new Vendor_Meter_Exception__c();
        venException9.DASR_Request__c = reqGAAC.id;
        venException9.LDC_Account__c = lacc1.id;
        venException9.Reason_Code__c = 'NM1MX';
        venException9.Meter_Number__c = '123456';
       
        
        
        
        Vendor_Meter_Exception__c venException10 = new Vendor_Meter_Exception__c();
        venException10.DASR_Request__c = reqGAAC.id;
        venException10.LDC_Account__c = lacc1.id;
        venException10.Reason_Code__c = 'NM1MA';
        venException10.Meter_Number__c = '123456';
        
        
        
        
        Vendor_Meter_Exception__c venException11 = new Vendor_Meter_Exception__c();
        venException11.DASR_Request__c = reqGAAC.id;
        venException11.LDC_Account__c = lacc1.id;
        venException11.Reason_Code__c = 'REFMT';
        venException11.Meter_Number__c = '123456';
        
        
        
        
        
        Vendor_Meter_Exception__c venException5 = new Vendor_Meter_Exception__c();
        venException5.DASR_Request__c = reqGAAC.id;
        venException5.LDC_Account__c = lacc1.id;
        venException5.Reason_Code__c = 'NM1MA';
        venException5.Meter_Number__c = '123456';
        
        
        
        
         Vendor_Meter_Exception__c venException4 = new Vendor_Meter_Exception__c();
        venException4.DASR_Request__c = reqGAAC.id;
        venException4.LDC_Account__c = lacc1.id;
        venException4.Reason_Code__c = 'NM1MX';
        venException4.Meter_Number__c = '123456';
        
        
        insert new List<Vendor_Meter_Exception__c> {venException6,venException7,venException8,venException9,venException10,venException11,venException5,venException4};
        
                   
        Test.stopTest();
    }
    
    // This test method to test any meter number on vendor meter and meter objects
    private static testmethod void updateMeterObject_UnitTest2() 
    {
        Test.startTest();
        
        createTestData();
        
        //insert vendor meter
        Vendor_Meter__c meter = new Vendor_Meter__c();
        meter.DASR_Request__c = reqGAAC.id;
        meter.LDC_Account__c = lacc1.id;
        meter.Meter_Number__c = '123456';
        meter.Meter_Type_Code__c = 'KHMON';
        insert meter;
        
        Vendor_Meter__c meter2 = [select id,Meter_Number__c from Vendor_Meter__c where id =: meter.id];
        System.assertEquals(meter2.Meter_Number__c,'123456');
        
        //insert Service_Point__c
        Service_Point__c point = new Service_Point__c();
        point.LDC_Account_Number__c = lacc1.id;
        point.Service_Point_Number__c = 'Test9848484';
        insert point;
        
        Service_Point__c point2 = [select id,Service_Point_Number__c  from Service_Point__c where id =: point.id];
        System.assertEquals(point2.Service_Point_Number__c ,'Test9848484');
        
        //insert meter Meter__c
        
        Meter__c meterObj = new Meter__c();
        meterObj.Service_Point__c = point.id;
        meterObj.Meter_Number__c = '123456';
        insert meterObj;
        
        Meter__c meterObj2 = [select id,Meter_Number__c  from Meter__c where id =: meterObj.id];
        System.assertEquals(meterObj2.Meter_Number__c ,'123456');
        
        // insert vendor meter exception
        
        Vendor_Meter_Exception__c venException = new Vendor_Meter_Exception__c();
        venException.DASR_Request__c = reqGAAC.id;
        venException.LDC_Account__c = lacc1.id;
        venException.Reason_Code__c = 'REFTZ';
        venException.Meter_Number__c = '123456';
        insert venException;
        
        Vendor_Meter_Exception__c venExceptionAssert1 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException.id];
        System.assertEquals(venExceptionAssert1.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException2 = new Vendor_Meter_Exception__c();
        venException2.DASR_Request__c = reqGAAC.id;
        venException2.LDC_Account__c = lacc1.id;
        venException2.Reason_Code__c = 'REFNH';
        venException2.Meter_Number__c = '123456';
        insert venException2;
        
        Vendor_Meter_Exception__c venExceptionAssert2 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException2.id];
        System.assertEquals(venExceptionAssert2.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException3 = new Vendor_Meter_Exception__c();
        venException3.DASR_Request__c = reqGAAC.id;
        venException3.LDC_Account__c = lacc1.id;
        venException3.Reason_Code__c = 'REFPR';
        venException3.Meter_Number__c = '123456';
        insert venException3;
        
        Vendor_Meter_Exception__c venExceptionAssert3 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException3.id];
        System.assertEquals(venExceptionAssert3.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException4 = new Vendor_Meter_Exception__c();
        venException4.DASR_Request__c = reqGAAC.id;
        venException4.LDC_Account__c = lacc1.id;
        venException4.Reason_Code__c = 'REFLO';
        venException4.Meter_Number__c = '123456';
        insert venException4;
        
        Vendor_Meter_Exception__c venExceptionAssert4 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException4.id];
        System.assertEquals(venExceptionAssert4.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException5 = new Vendor_Meter_Exception__c();
        venException5.DASR_Request__c = reqGAAC.id;
        venException5.LDC_Account__c = lacc1.id;
        venException5.Reason_Code__c = 'NM1MQ';
        venException5.Meter_Number__c = '123456';
        insert venException5;
        
        Vendor_Meter_Exception__c venExceptionAssert5 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException5.id];
        System.assertEquals(venExceptionAssert5.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException6 = new Vendor_Meter_Exception__c();
        venException6.DASR_Request__c = reqGAAC.id;
        venException6.LDC_Account__c = lacc1.id;
        venException6.Reason_Code__c = 'REF4P';
        venException6.Meter_Number__c = '123456';
        insert venException6;
        
        Vendor_Meter_Exception__c venException11 = new Vendor_Meter_Exception__c();
        venException11.DASR_Request__c = reqGAAC.id;
        venException11.LDC_Account__c = lacc1.id;
        venException11.Reason_Code__c = 'REFIX';
        venException11.Meter_Number__c = '123456';
        insert venException11;
        
        Vendor_Meter_Exception__c venExceptionAssert11 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException11.id];
        System.assertEquals(venExceptionAssert11.Meter_Number__c ,'123456');
        
        
        Vendor_Meter_Exception__c venException12 = new Vendor_Meter_Exception__c();
        venException12.DASR_Request__c = reqGAAC.id;
        venException12.LDC_Account__c = lacc1.id;
        venException12.Reason_Code__c = 'NM1MR';
        venException12.Meter_Number__c = '123456';
        insert venException12;
        
        Vendor_Meter_Exception__c venExceptionAssert12 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException12.id];
        System.assertEquals(venExceptionAssert12.Meter_Number__c ,'123456');       
        
        
                  
        Test.stopTest();
    }
    
    
    private static testmethod void updateMeterObject_UnitTest4() 
    {
        Test.startTest();
        
        createTestData();
        
        //insert vendor meter
        Vendor_Meter__c meter = new Vendor_Meter__c();
        meter.DASR_Request__c = reqGAAC.id;
        meter.LDC_Account__c = lacc1.id;
        meter.Meter_Number__c = 'ALL';
        insert meter;
        
        Vendor_Meter__c meter2 = [select id,Meter_Number__c from Vendor_Meter__c where id =: meter.id];
        System.assertEquals(meter2.Meter_Number__c,'ALL');
        
        //insert Service_Point__c
        Service_Point__c point = new Service_Point__c();
        point.LDC_Account_Number__c = lacc1.id;
        point.Service_Point_Number__c = 'Test9848484';
        insert point;
        
        Service_Point__c point2 = [select id,Service_Point_Number__c  from Service_Point__c where id =: point.id];
        System.assertEquals(point2.Service_Point_Number__c ,'Test9848484');
        
        //insert meter Meter__c
        
        Meter__c meterObj = new Meter__c();
        meterObj.Service_Point__c = point.id;
        meterObj.Meter_Number__c = '123456';
        insert meterObj;
        
        Meter__c meterObj2 = [select id,Meter_Number__c  from Meter__c where id =: meterObj.id];
        System.assertEquals(meterObj2.Meter_Number__c ,'123456');
        
        Vendor_Meter_Exception__c venException5 = new Vendor_Meter_Exception__c();
        venException5.DASR_Request__c = reqGAAC.id;
        venException5.LDC_Account__c = lacc1.id;
        venException5.Reason_Code__c = 'NM1MQ';
        venException5.Meter_Number__c = 'ALL';
        insert venException5;
        
        Vendor_Meter_Exception__c venExceptionAssert5 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException5.id];
        System.assertEquals(venExceptionAssert5.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException6 = new Vendor_Meter_Exception__c();
        venException6.DASR_Request__c = reqGAAC.id;
        venException6.LDC_Account__c = lacc1.id;
        venException6.Reason_Code__c = 'REF4P';
        venException6.Meter_Number__c = 'ALL';
        insert venException6;
        
        Vendor_Meter_Exception__c venExceptionAssert6 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException6.id];
        System.assertEquals(venExceptionAssert6.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException7 = new Vendor_Meter_Exception__c();
        venException7.DASR_Request__c = reqGAAC.id;
        venException7.LDC_Account__c = lacc1.id;
        venException7.Reason_Code__c = 'REFLF';
        venException7.Meter_Number__c = 'ALL';
        insert venException7;
        
        Vendor_Meter_Exception__c venExceptionAssert7 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException7.id];
        System.assertEquals(venExceptionAssert7.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException8 = new Vendor_Meter_Exception__c();
        venException8.DASR_Request__c = reqGAAC.id;
        venException8.LDC_Account__c = lacc1.id;
        venException8.Reason_Code__c = 'REFSV';
        venException8.Meter_Number__c = 'ALL';
        insert venException8;
        
        Vendor_Meter_Exception__c venExceptionAssert8 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException8.id];
        System.assertEquals(venExceptionAssert8.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException9 = new Vendor_Meter_Exception__c();
        venException9.DASR_Request__c = reqGAAC.id;
        venException9.LDC_Account__c = lacc1.id;
        venException9.Reason_Code__c = 'REFMT';
        venException9.Meter_Number__c = 'ALL';
        insert venException9;
        
        Vendor_Meter_Exception__c venExceptionAssert9 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException9.id];
        System.assertEquals(venExceptionAssert9.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException10 = new Vendor_Meter_Exception__c();
        venException10.DASR_Request__c = reqGAAC.id;
        venException10.LDC_Account__c = lacc1.id;
        venException10.Reason_Code__c = 'REFTU';
        venException10.Meter_Number__c = 'ALL';
        insert venException10;
        
        Vendor_Meter_Exception__c venExceptionAssert10 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException10.id];
        System.assertEquals(venExceptionAssert10.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException11 = new Vendor_Meter_Exception__c();
        venException11.DASR_Request__c = reqGAAC.id;
        venException11.LDC_Account__c = lacc1.id;
        venException11.Reason_Code__c = 'REFIX';
        venException11.Meter_Number__c = 'ALL';
        insert venException11;
        
        Vendor_Meter_Exception__c venExceptionAssert11 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException11.id];
        System.assertEquals(venExceptionAssert11.Meter_Number__c ,'ALL');
        
        
        Vendor_Meter_Exception__c venException12 = new Vendor_Meter_Exception__c();
        venException12.DASR_Request__c = reqGAAC.id;
        venException12.LDC_Account__c = lacc1.id;
        venException12.Reason_Code__c = 'NM1MR';
        venException12.Meter_Number__c = 'ALL';
        insert venException12;
        
        Vendor_Meter_Exception__c venExceptionAssert12 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException12.id];
        System.assertEquals(venExceptionAssert12.Meter_Number__c ,'ALL');
        
                   
        Test.stopTest();
    }
    
    // This test method to test where meter number equals ALL on vendor meter
    private static testmethod void updateMeterObject_UnitTest() 
    {
        Test.startTest();
        
        createTestData();
        
        //insert vendor meter
        Vendor_Meter__c meter = new Vendor_Meter__c();
        meter.DASR_Request__c = reqGAAC.id;
        meter.LDC_Account__c = lacc1.id;
        meter.Meter_Number__c = 'ALL';
        insert meter;
        
        Vendor_Meter__c meter2 = [select id,Meter_Number__c from Vendor_Meter__c where id =: meter.id];
        System.assertEquals(meter2.Meter_Number__c,'ALL');
        
        //insert Service_Point__c
        Service_Point__c point = new Service_Point__c();
        point.LDC_Account_Number__c = lacc1.id;
        point.Service_Point_Number__c = 'Test9848484';
        insert point;
        
        Service_Point__c point2 = [select id,Service_Point_Number__c  from Service_Point__c where id =: point.id];
        System.assertEquals(point2.Service_Point_Number__c ,'Test9848484');
        
        //insert meter Meter__c
        
        Meter__c meterObj = new Meter__c();
        meterObj.Service_Point__c = point.id;
        meterObj.Meter_Number__c = '123456';
        insert meterObj;
        
        Meter__c meterObj2 = [select id,Meter_Number__c  from Meter__c where id =: meterObj.id];
        System.assertEquals(meterObj2.Meter_Number__c ,'123456');
        
        // insert vendor meter exception
        
        Vendor_Meter_Exception__c venException = new Vendor_Meter_Exception__c();
        venException.DASR_Request__c = reqGAAC.id;
        venException.LDC_Account__c = lacc1.id;
        venException.Reason_Code__c = 'REFNH';
        venException.Meter_Number__c = 'ALL';
        insert venException;
        
        Vendor_Meter_Exception__c venExceptionAssert1 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException.id];
        System.assertEquals(venExceptionAssert1.Meter_Number__c ,'ALL');
        
               
        Vendor_Meter_Exception__c venException2 = new Vendor_Meter_Exception__c();
        venException2.DASR_Request__c = reqGAAC.id;
        venException2.LDC_Account__c = lacc1.id;
        venException2.Reason_Code__c = 'REFTZ';
        venException2.Meter_Number__c = 'ALL';
        insert venException2;
        
        Vendor_Meter_Exception__c venExceptionAssert2 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException2.id];
        System.assertEquals(venExceptionAssert2.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException3 = new Vendor_Meter_Exception__c();
        venException3.DASR_Request__c = reqGAAC.id;
        venException3.LDC_Account__c = lacc1.id;
        venException3.Reason_Code__c = 'REFPR';
        venException3.Meter_Number__c = 'ALL';
        insert venException3;
        
        Vendor_Meter_Exception__c venExceptionAssert3 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException3.id];
        System.assertEquals(venExceptionAssert3.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException4 = new Vendor_Meter_Exception__c();
        venException4.DASR_Request__c = reqGAAC.id;
        venException4.LDC_Account__c = lacc1.id;
        venException4.Reason_Code__c = 'REFLO';
        venException4.Meter_Number__c = 'ALL';
        insert venException4;
        
        Vendor_Meter_Exception__c venExceptionAssert4 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException4.id];
        System.assertEquals(venExceptionAssert4.Meter_Number__c ,'ALL');
        
        Vendor_Meter_Exception__c venException5 = new Vendor_Meter_Exception__c();
        venException5.DASR_Request__c = reqGAAC.id;
        venException5.LDC_Account__c = lacc1.id;
        venException5.Reason_Code__c = 'NM1MA';
        venException5.Meter_Number__c = 'ALL';
        insert venException5;
        
        Vendor_Meter_Exception__c venExceptionAssert5 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException5.id];
        System.assertEquals(venExceptionAssert5.Meter_Number__c ,'ALL');
        
         Vendor_Meter_Exception__c venException6 = new Vendor_Meter_Exception__c();
        venException6.DASR_Request__c = reqGAAC.id;
        venException6.LDC_Account__c = lacc1.id;
        venException6.Reason_Code__c = 'NM1MX';
        venException6.Meter_Number__c = 'ALL';
        insert venException6;
        
        Vendor_Meter_Exception__c venExceptionAssert6 = [select id,Meter_Number__c from Vendor_Meter_Exception__c where id =: venException6.id];
        System.assertEquals(venExceptionAssert6.Meter_Number__c ,'ALL');
               
        
        Test.stopTest();
        
    }    
}