public with sharing class FormatDateTime {

    public String getDateFormat() {
        if( dateValue != null ) {
            String localeFormatD = dateValue.format();
            return localeFormatD;
        }
        return null;
    }

    public DateTime dateTimeValue { get; set; }
    public Date dateValue { get; set; }
    
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format();
            return localeFormatDT;
        }
        return null;
    }
    
    /*public String getDateFormat() {
        if( dateValue != null ) {
            String localeFormatDT = dateValue.format('MM-dd-yyyy');
            return localeFormatDT;
        }
        return null;
    }*/
}