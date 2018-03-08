public class StateCountryUtil {
    public static string getStateCodeForVal(String stateName, String country)
    {
        String retVal;
        if(stateName == null || String.isEmpty(stateName))
        {
            return null;
        }
        for(State_Country__c tVal : State_Country__c.getall().values())
        {
            if(tVal.Value__c != null && tVal.Value__c.equalsIgnorecase(stateName) && tVal.Country__c != null && tVal.Country__c.equalsIgnorecase(country))
            {
                retVal = tVal.Code__c.toUpperCase();
                break;
            }
        }
        
        return retVal;
    }
    
}