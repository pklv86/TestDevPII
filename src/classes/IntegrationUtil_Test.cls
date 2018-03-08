@IsTest
private class IntegrationUtil_Test 
{
    @IsTest static void testValidator() 
    {
        Supplier__c        supplier = new Supplier__c();
        supplier.NAme ='Test supplier';
        supplier.Master_DUNS__c  ='1223';
        supplier.Supplier_DUNS__c ='999';
        supplier.Active__c = true;

        Supplier__c        supplier1 = new Supplier__c();
        supplier1.NAme ='Test supplier1';
        supplier1.Master_DUNS__c  ='12231';
        supplier1.Supplier_DUNS__c ='9991';
        supplier1.Active__c = true;        
        
        Database.SaveResult[] srInsert = database.insert(new List<Supplier__c>{supplier,supplier1},false);
        
        Database.UpsertResult[] srUpsert = database.upsert(new List<Supplier__c>{supplier,supplier1},false);
        
        IntegrationUtil.collectErrors(null);
        IntegrationUtil.collectErrors(srInsert);
        
        IntegrationUtil.generateDocId(System.now());
        IntegrationUtil.collectUpsertErrors(null);
        IntegrationUtil.collectUpsertErrors(srUpsert);
        IntegrationUtil.convertDateToString(system.today());
        IntegrationUtil.convertStringToDate('20160101');
        IntegrationUtil.convertStringToDate('2016-01-01');
        IntegrationUtil.convertStringToDate('201611');
        IntegrationUtil.convertStringToDate('201600');
        
        IntegrationUtil.convertTimeToString(System.now());
        IntegrationUtil.generateDateTime(System.now());
        IntegrationUtil.generateDate(System.now());
        IntegrationUtil.generateDocId(System.now());
        IntegrationUtil.generateRandomString(10);
        IntegrationUtil.generateTime(System.now());
        IntegrationUtil.remSpecialChars('2011-11-11');
        IntegrationUtil.remSpecialChars(null);
        
    }
}