public class EDITransformationUtil {
    public static final String VAL_ELECTRIC = 'Electric';
    public static final String VAL_UNITED_STATES = 'UNITED STATES';
    public static final String VAL_USA = 'USA';
    public static final String VAL_GAS = 'Gas';
    public static final String VAL_INTERVAL = 'Interval';
    public static final String VAL_SUMMARY = 'Summary';
    public static final String CODE_US = 'US';
    public static final String CODE_INTERVAL = 'N';
    public static final String CODE_SUMMARY = 'Y';
    public static final String CODE_ELECTRIC = 'E';
    public static final String CODE_GAS = 'G';
    public static final String CHNG_RSN_CODE_SERV_IND = 'REF17';

    public static String convUSAValToCode(String countryName)
    {
        String val;
        if(countryName == null || String.isEmpty(countryName))
        {
            return CODE_US;
        }
        if(countryName.trim().length() == 2)
        {
            return countryName.toUpperCase();
        }
        if(countryName.equalsIgnoreCase(VAL_UNITED_STATES) || countryName.equalsIgnoreCase(VAL_USA))
        {
           val = CODE_US; 
        }
        return val;
    }
    
    public static String convStateValToCode(String stateName)
    {
        String val;
        if(stateName == null || String.isEmpty(stateName))
        {
            return null;
        }
        if(stateName.trim().length() == 2)
        {
            return stateName.toUpperCase();
        }
        val = StateCountryUtil.getStateCodeForVal(val,'United States');
        return val;
    }
    public static String convCommodityCodeToVal(String code)
    {
        String val;
        if(code == null || String.isEmpty(code))
        {
            return null;
        }
        if(code.trim().equalsIgnoreCase(CODE_ELECTRIC))
        {
            val = EDITransformationUtil.VAL_ELECTRIC;
        }else if(code.trim().equalsIgnoreCase(CODE_GAS))
        {
            val = EDITransformationUtil.VAL_GAS;
        }
        return val;
    }
    public static String convCommodityValToCode(String val)
    {
        String code;
        if(val == null || String.isEmpty(val))
        {
            return null;
        }
        if(val.trim().equalsIgnoreCase(VAL_ELECTRIC))
        {
            code = EDITransformationUtil.CODE_ELECTRIC;
        }else if(val.trim().equalsIgnoreCase(VAL_GAS))
        {
            code = EDITransformationUtil.CODE_GAS;
        }
        return code;
    }
    
    public static String convUsageCodeToVal(String code)
    {
        String val;
        if(code == null || String.isEmpty(code))
        {
            return null;
        }
        if(code.trim().equalsIgnoreCase(CODE_SUMMARY))
        {
            val = EDITransformationUtil.VAL_SUMMARY;
        }else if(code.trim().equalsIgnoreCase(CODE_INTERVAL))
        {
            val = EDITransformationUtil.VAL_INTERVAL;
        }
        return val;
    }
    public static String convUsageValToCode(String val)
    {
        String code;
        if(val == null || String.isEmpty(val))
        {
            return null;
        }
        if(val.trim().equalsIgnoreCase(VAL_INTERVAL))
        {
            code = EDITransformationUtil.CODE_INTERVAL;
        }else if(val.trim().equalsIgnoreCase(VAL_SUMMARY))
        {
            code = EDITransformationUtil.CODE_SUMMARY;
        }
        return code;
    }
    public static String getUsageValue(DASR_Request__c vDASR, LDC_Account__c vldcAccnt,Supplier__c vSupplier,LDC_Vendor__c vVendor,List<Meter__c> vMeterList,Account vCustomer,Contract vContract, List<Contract_Term__c> vContractTerm)
    {
        String val = EDIIntegrationConfigUtil.getIntRequestCode();
        if(vDASR == null)
        {
            return val;
        }
        String dasrUsageType = vDASR.Interval_Usage__c != null && vDASR.Interval_Usage__c != '' ? vDASR.Interval_Usage__c : vldcAccnt.Interval_Usage__c;
		String contUsageType = vContract != null ? vContract.Interval_Usage__c : null;
        String contBillMethod = vContract != null ? vContract.Bill_Method__c : null;
        String chngRsnCode = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c,'LDC_Account__c');
        if(contBillMethod != null && contBillMethod.equalsIgnoreCase('DUAL') && (chngRsnCode == null || !chngRsnCode.equalsIgnoreCase(CHNG_RSN_CODE_SERV_IND)))
        {
            return val;
        }        
        if(contUsageType != null && !string.isEmpty(contUsageType) && (chngRsnCode == null || !chngRsnCode.equalsIgnoreCase(CHNG_RSN_CODE_SERV_IND)))
        {
            val = convUsageValToCode(contUsageType);
        }
        if(chngRsnCode != null && chngRsnCode.equalsIgnoreCase(CHNG_RSN_CODE_SERV_IND))
        {
         	val = dasrUsageType != null ? convUsageValToCode(dasrUsageType) : null;   
        }
        if(val == null || String.isEmpty(val))
        {
            val = EDIIntegrationConfigUtil.getIntRequestCode();
        }
        
        return val;
        
    }
}