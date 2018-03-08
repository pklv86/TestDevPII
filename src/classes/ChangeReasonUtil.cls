public class ChangeReasonUtil {

    public static ChangeReason__c getChgRsnCodeForVal(String strVal)
    {
        ChangeReason__c retVal;
        if(strVal == null || String.IsEmpty(strVal))
        {
            return null;
        }
        for(ChangeReason__c tVal : ChangeReason__c.getall().values())
        {
            if(tVal.Reason_Value__c  != null && tVal.Reason_Value__c.equalsIgnorecase(strVal))
            {
                retVal = tVal;
                break;
            }
        }

        return retVal;
    }
    public static ChangeReason__c getChgRsnCodeForCode(String strCode)
    {
        ChangeReason__c retVal;
        if(strCode == null || String.IsEmpty(strCode))
        {
            return null;
        }
        for(ChangeReason__c tVal : ChangeReason__c.getall().values())
        {
            if(tVal.Reason_Code__c  != null && tVal.Reason_Code__c.equalsIgnorecase(strCode))
            {
                retVal = tVal;
                break;
            }
        }
        
        return retVal;
    }
    public static string getChgRsnCodeForVal(String strVal, String objName)
    {
        String retVal;
        if(strVal == null || strVal == '' || objName == null || objName == '')
        {
            return null;
        }
        for(ChangeReason__c tVal : ChangeReason__c.getall().values())
        {
            if(tVal.Reason_Value__c  != null && tVal.Reason_Value__c.equalsIgnorecase(strVal) && tVal.Object_API_Name__c != null && tVal.Object_API_Name__c.equalsIgnorecase(objName))
            {
                retVal = tVal.Reason_Code__c;
                break;
            }
        }
        if(retVal == null || retVal == '')
        {
            for(ChangeReason__c tVal : ChangeReason__c.getall().values())
            {
                if(tVal.Reason_Value__c  != null && tVal.Reason_Value__c.equalsIgnorecase(strVal))
                {
                    retVal = tVal.Reason_Code__c;
                    break;
                }
            }
        }
        return retVal;
    }
    public static string getDropCodeForVal(String strVal, String objName)
    {
        String retVal;
        if(strVal == null || strVal == '' || objName == null || objName == '')
        {
            return null;
        }
        for(ChangeReason__c tVal : ChangeReason__c.getall().values())
        {
            if(tVal.Valid_For_Drop__c  == true && tVal.Reason_Value__c  != null && tVal.Reason_Value__c.equalsIgnorecase(strVal) && tVal.Object_API_Name__c != null && tVal.Object_API_Name__c.equalsIgnorecase(objName))
            {
                retVal = tVal.Reason_Code__c;
                break;
            }
        }
        if(retVal == null || retVal == '')
        {
            for(ChangeReason__c tVal : ChangeReason__c.getall().values())
            {
                if(tVal.Reason_Value__c  != null && tVal.Reason_Value__c.equalsIgnorecase(strVal))
                {
                    retVal = tVal.Reason_Code__c;
                    break;
                }
            }
        }
        return retVal;
    }
    public static string getChgRsnValForCode(String strCode, String objName)
    {
        String retVal;
        if(strCode == null || strCode == '' || objName == null || objName == '')
        {
            return null;
        }
        for(ChangeReason__c tVal : ChangeReason__c.getall().values())
        {
            if(tVal.Reason_Code__c  != null && tVal.Reason_Code__c.equalsIgnorecase(strCode) && tVal.Object_API_Name__c != null && tVal.Object_API_Name__c.equalsIgnorecase(objName))
            {
                retVal = tVal.Reason_Value__c;
                break;
            }
        }
        return retVal;
    }
    
    public static boolean isRsnAllowOutbound(String strVal, String objName)
    {
        boolean rsnAllw = false;
        if(strVal == null || strVal == '' || objName == null || objName == '')
        {
            return false;
        }
        for(ChangeReason__c tVal : ChangeReason__c.getall().values())
        {
            if(tVal.Allow_On_Outbound__c == true && tVal.Reason_Value__c  != null && tVal.Reason_Value__c.equalsIgnorecase(strVal) && tVal.Object_API_Name__c != null && tVal.Object_API_Name__c.equalsIgnorecase(objName))
            {
                rsnAllw = true;
                break;
            }
        }
        return rsnAllw;
    }
    
}