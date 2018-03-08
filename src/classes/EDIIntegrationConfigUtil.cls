public class EDIIntegrationConfigUtil {
    public static EDIIntegrationConfiguration__c  intConfig;
    static {
        intConfig = EDIIntegrationConfiguration__c.getInstance('Default');
    }
    public static String getNotificationUserId() {
        return intConfig != null && intConfig.Notify_Email__c  != null ? intConfig.Notify_Email__c : 'anandmishra@kpmg.com';
    }  
    public static String getIntUserName() {
        return intConfig != null && intConfig.User_Name__c   != null ? intConfig.User_Name__c  : 'dynsfdev';
    }  
    public static String getIntUserPwd() {
        return intConfig != null && intConfig.Password__c    != null ? intConfig.Password__c   : 'u7SBbSIG';
    }
    public static String getEDIEndPoint() {
        return intConfig != null && intConfig.EDI_Outbound_End_Point__c  != null ? intConfig.EDI_Outbound_End_Point__c : 'https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG';
    }
    public static String getIntRequestCode() {
        return intConfig != null && intConfig.Interval_Request_Code__c != null ? intConfig.Interval_Request_Code__c : 'N';
    }
    public static String getIntDefMeterNumber() {
        return intConfig != null && intConfig.Default_Meter_Number__c  != null ? intConfig.Default_Meter_Number__c  : 'ALL';
    }
    public static String getESGRecpName() {
        return intConfig != null && intConfig.Recipient_Name__c     != null ? intConfig.Recipient_Name__c    : 'ESG';
    }
    public static String getESGRecpDuns() {
        return intConfig != null && intConfig.Receipient_DUNS__c     != null ? intConfig.Receipient_DUNS__c    : '049050839';
    }
}