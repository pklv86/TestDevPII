global with sharing class Customersavebutton_c
{
    public Boolean displayPopup {get;set;}
    public Boolean recall{get;set;}
    public list<LDC_Account__c> listldcaccount{get;set;}
    public account acc{get;set;}
    public account ac{get;set;}
    private ApexPages.StandardController sc;
    public Customersavebutton_c(ApexPages.StandardController sc) 
    {
         acc= (Account)sc.getRecord();
         listldcaccount=[select id,Opt_out__c from LDC_Account__c where account__C=:acc.id and Opt_out__c=true];
          ac=[select id from account where id=:acc.id];
        
        if(listldcaccount.size()!=0 && listldcaccount.size()!=null)
        {
            displayPopup =true;
            
        }
        else
        {
            displayPopup = false;
            sort();
        }            
        
        this.sc = sc;
    
    }
    
    public PageReference sort()
    {
        //recall=true;
        
        displayPopup = false;
        
        return null;
   
    }

    webservice static string alertresponse(String accId){
        string result = '';
        list<ldc_account__c> ldc = new list<ldc_account__c>();
        account ac = new account();
        if(!String.isBlank(accId)){
            system.debug('*****accId'+accId);
            ldc=[select id,Opt_out__c from LDC_Account__c where account__c=:accId and Opt_out__c=true];
            ac=[select id,short_code__c from account where id=:accid];
            if(ldc.size()!=0 && ldc.size()!=null){
                result='Customer Opted out';
            }
            else if((ldc.size()==0 && ldc.size()==null) && ac.short_code__c != null){
                result=''+ac.short_code__c+' choosed for alert';
            }
            else{
                result='No Opt out Customers';
            }   
            
        }       
        else{
            result = 'Invalid Contract ID for the selected Record. Please try again or contact administrator.';
        }
        return result;
    }
    
}