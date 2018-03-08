public class BillMethodUtil {
    public static Bill_Method__c getBillMethodByName(String strBillMethod)
    {
        Bill_Method__c retObj;
        if(String.isBlank(strBillMethod))
        {
            return null;
        }
        for(Bill_Method__c tVal : Bill_Method__c.getall().values())
        {
            if(tVal.Name  != null && tVal.Name.equalsIgnorecase(strBillMethod))
            {
                return tVal;
            }
        }
        return retObj;
    }
}