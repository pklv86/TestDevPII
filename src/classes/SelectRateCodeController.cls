/* 
 * Name: SelectRateCodeController
 * Type: Apex Class
 * Test Class: SelectRateCodeControllerTest
 * Description:  This class is used to fetch the Rate Codes basis Quote Price and Service Teritory. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         02/12/2016       1. Initial Version created
 */
public with sharing class SelectRateCodeController { 
    



    public boolean newratecode_PB { get; set; }

    
    public String serviceTeritory {get; set;}
    public Decimal quotePrice {get; set;}   
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public string listSize {get;set;}
    public string queryString;
    public decimal maxQp;
    public decimal minQp;
    public Rate_Code__c ratecode{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
    
    public SelectRateCodeController(){
        listSize = '5';
        size = Integer.valueof(listSize);
        serviceTeritory = ApexPages.currentPage().getParameters().get('serviceTeritory');
        quotePrice = (ApexPages.currentPage().getParameters().get('quotePrice') != null && ApexPages.currentPage().getParameters().get('quotePrice') != '')?Decimal.valueOf(ApexPages.currentPage().getParameters().get('quotePrice')):0;       
    }
    
    public List<Rate_Code__c> getRateCodes(){
        queryString = 'SELECT ID, NAME, Price__c, Service_Territory__c FROM Rate_Code__c';                
        
        try{
            if(serviceTeritory != null && serviceTeritory != '' && quotePrice != null && quotePrice != 0){  
                        
                queryString += ' WHERE Service_Territory__c = :serviceTeritory';
                if(quotePrice != null && quotePrice != 0){
                    queryString += ' AND' + getQuoteFilter(String.Valueof(quotePrice));
                }
            }
            //else if(quotePrice != null && quotePrice != 0){                                   
            //      queryString += ' WHERE' + getQuoteFilter(String.Valueof(quotePrice));               
            //}
            else {
                queryString += ' WHERE Service_Territory__c = null';
            }
        }
        catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        List<Rate_Code__c> rcList = new List<Rate_Code__c>();
        for(Rate_Code__c rc : (List<Rate_Code__c>)setCon.getRecords())
            rcList.add(rc);
        return rcList;
    }
    
    private string getQuoteFilter(string strQuotePrice){        
        maxQp = 0;
        minQp = 0;
        if(strQuotePrice.indexOf('.') >= 0){
            maxQp = decimal.valueOf(strQuotePrice+'99999');
            minQp = decimal.valueOf(strQuotePrice+'00000');
        }
        else{
            maxQp = decimal.valueOf(strQuotePrice+'.99999');
            minQp = decimal.valueOf(strQuotePrice+'.00000');
        }
        
        return ' Price__c >= :minQp AND Price__c <= :maxQp';
    }
    
    public PageReference searchRateCode(){      
        setCon = null;
        getRateCodes();
        setCon.setPageNumber(1);
        return null;
    }
    
    public List<SelectOption> getListItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('20', '20'));
        options.add(new SelectOption('50', '50'));
        return options;
    }
    
    public PageReference setListSize(){
        size = Integer.valueof(listSize);
        searchRateCode();
        return null;
    }
    public PageReference Newratecode() {
    ratecode=new rate_code__c();
    newratecode_PB =true;
    
        return null;
    }
    public PageReference createratecode() {
    
    newratecode_PB =false;
        insert ratecode;
        serviceTeritory =ratecode.Service_Territory__c;
        quoteprice=ratecode.price__c;
        searchRateCode();
        return null;
    }
    public PageReference cancelcreateratecode() {
    newratecode_PB =false;
        return null;
    }

}