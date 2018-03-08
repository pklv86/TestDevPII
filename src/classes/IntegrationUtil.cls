public class IntegrationUtil {

    public static String generateDocId(DateTime inputDT)
    {
        return  'C'+inputDT.year() + inputDT.month()+inputDT.day()+inputDT.hour()+inputDT.minute() + inputDT.second();
    }
    public static String generateDate(DateTime inputDT)
    {
        return  ''+inputDT.year() + inputDT.month()+inputDT.day();
    }
    public static String generateDateTime(DateTime inputDT)
    {
        return  ''+inputDT.year() + inputDT.month()+inputDT.day() + inputDT.hour()+inputDT.minute() + inputDT.second();
    }
    public static String generateTime(DateTime inputDT)
    {
        return  ''+ inputDT.hour()+inputDT.minute() + inputDT.second();
    }
    public static Date convertStringToDate(String strDate)
    {
        Date retDate = System.today();
        try{
            if(strDate != null && strDate.length() == 8)
            {
                Integer sYear = Integer.valueOf(strDate.substring(0, 4));
                Integer sMonth = Integer.valueOf(strDate.substring(4, 6));
                Integer sDay = Integer.valueOf(strDate.substring(6, 8));
                retDate = Date.newInstance(sYear,sMonth,sDay);
            }else if(strDate != null && strDate.length() == 6)
            {
                Integer sYear = Integer.valueOf(strDate.substring(0, 4));
                Integer sMonth = Integer.valueOf(strDate.substring(4, 5));
                Integer sDay = Integer.valueOf(strDate.substring(5, 6));
                retDate = Date.newInstance(sYear,sMonth,sDay);
            }
            
        }catch(Exception ex)
        {
            retDate = System.today();
        }
        
        return retDate;
    }
    
    public static String convertDateToString(Date subDate)
    {
        String myMonth = ''+subDate.month();
        String myDay = ''+subDate.day();
        
        myMonth = myMonth.length() < 2 ? '0'+myMonth : myMonth;
        myDay = myDay.length() < 2 ? '0'+myDay : myDay;
        
        String retDate = '' + subDate.year() + myMonth + myDay;
        
        
        return retDate;
    }
    public static String convertTimeToString(DateTime subDateTime)
    {
        String myHour = ''+subDateTime.hour();
        String myMin = ''+subDateTime.minute();
        String mySec = ''+subDateTime.second();
        
        myHour = myHour.length() < 2 ? '0'+myHour : myHour;
        myMin = myMin.length() < 2 ? '0'+myMin : myMin;
        mySec = mySec.length() < 2 ? '0'+mySec : mySec;
        
        String retTime = '' + myHour + myMin + mySec;
        
        
        return retTime;
    }
    public static List<String> collectErrors(Database.SaveResult[] srList)
    {
        List<String> errList = new List<String>();
        if(srList != null)
        {
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errList.add(err.getStatusCode() + ': ' + err.getMessage());

                    }
                }
            }            
        }   
        return errList;
    }
    public static List<String> collectUpsertErrors(Database.UpsertResult[] srList)
    {
        List<String> errList = new List<String>();
        if(srList != null)
        {
            // Iterate through each returned result
            for (Database.UpsertResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errList.add(err.getStatusCode() + ': ' + err.getMessage());
                        
                    }
                }
            }            
        }   
        return errList;
    }
    public static String remSpecialChars(String inputString)
    {
        if(inputString == null || inputString == '')
        {
            return '';
        }
        return inputString.replaceAll('(?i)[^a-z0-9]', '');
        
    }
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}