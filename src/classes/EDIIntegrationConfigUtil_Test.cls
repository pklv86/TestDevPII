@IsTest
private class EDIIntegrationConfigUtil_Test 
{
    @testSetup static void setupData() 
    {
        EDIIntegrationConfiguration__c config = new EDIIntegrationConfiguration__c(name ='Default',Notify_Email__c='anands1775@gmail.com',User_Name__c='dynsfdev', Password__c='u7SBbSIG',EDI_Outbound_End_Point__c='https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG',Interval_Request_Code__c='N',Default_Meter_Number__c='ALL',Recipient_Name__c='ESG',Receipient_DUNS__c='049050839');
        insert config;
    }
    @IsTest private static void testConfigUtil()
    {
        EDIIntegrationConfigUtil.getEDIEndPoint();
        EDIIntegrationConfigUtil.getESGRecpDuns();
        EDIIntegrationConfigUtil.getESGRecpName();
        EDIIntegrationConfigUtil.getIntDefMeterNumber();
        EDIIntegrationConfigUtil.getIntRequestCode();
        EDIIntegrationConfigUtil.getIntUserName();
        EDIIntegrationConfigUtil.getIntUserPwd();
        EDIIntegrationConfigUtil.getNotificationUserId();
    }
}