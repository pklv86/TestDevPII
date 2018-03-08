/* 
 * Name: GetExecutablePriceController
 * Type: Apex Class
 * Test Class: GetExecutablePriceControllerTest
 * Description:  This class is used to request for the Executable pricing information based on the Quote selected from "Pricing Complete" list. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         01/30/2016       1. Initial Version created
 */
public class GetExecutablePriceController {

    public List<RetailQuoteWrapper> retQuoteWrapList {get; set;}
    public ApexPages.StandardController oppCntrlr {get;Set;}
    public Boolean quotesAvailable {get; set;} 
    public static final String STATUS_CONTRACT_SIGNED = 'Contract Signed';
    public ID RetQuoteIndivativeId;
    public ID RetQuoteExecutableId;
    private final Opportunity opty;
      Opportunity opp;
        Account acc;
    Set<Id> idsToClone = new Set<Id>();
         
    public GetExecutablePriceController(ApexPages.StandardController stdController){
        oppCntrlr=stdController;
        Opportunity recOpp = (Opportunity)stdController.getRecord(); 
        quotesAvailable = true;        
        RetQuoteIndivativeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_INDICATIVE);
        RetQuoteExecutableId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_EXECUTABLE);
        retQuoteWrapList = new List<RetailQuoteWrapper>();
        if(recOpp != null && recOpp.id != null){
           if(label.OppQueryFields != null && label.OppQueryFields !=''){
              this.opty = (Opportunity)ConstantUtility.getObject('Opportunity',label.OppQueryFields,recOpp.id);
            }
            else{
              this.opty = (Opportunity)ConstantUtility.getObject('Opportunity','Id:Name:Refresh_Expiration_Date__c:Executable_Quote_Generated__c',recOpp.id);   
           }
           if((opty.Refresh_Expiration_Date__c >= System.TODAY() || opty.Refresh_Expiration_Date__c == null)){
                if(retQuoteWrapList == null) {
                    retQuoteWrapList = new List<RetailQuoteWrapper>();
                }
                 for(Retail_Quote__c rq : [SELECT id,Name,Request_Status__c,Term__c,Quote_Price_KWH__c,Product__c,Credit_Check_Required__c,Opportunity__r.Credit_Approved__c
                                        FROM  Retail_Quote__c WHERE Request_Status__c = :ConstantUtility.STATUS_PRICING_COMPLETE 
                                        AND RecordTypeId = :RetQuoteIndivativeId AND Opportunity__c = :opty.Id]){                
                    retQuoteWrapList.add(new RetailQuoteWrapper(rq));                   
                }   
            }
        }
        if(retQuoteWrapList.isEmpty()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantUtility.ERR_NO_EXECUTABLE_QUOTES_AVAILABLE));            
            quotesAvailable = false;
        }
        
    }
    
    public PageReference cancelRequest(){
        return getOptyView();       
    }
     
    public PageReference createRequest(){
    System.Debug('Test:*****');
        Set<Id> idsToClone = new Set<Id>();     
        Id oppId = opty.id;
        String strQuery = ConstantUtility.getObjectFieldsQuery(ConstantUtility.RT_OBJECT);
        strQuery += ' FROM '+ConstantUtility.RT_OBJECT+' WHERE RecordTypeId = :RetQuoteIndivativeId and Opportunity__c = :oppId' ;
        List<Retail_Quote__c> lstRTQT = Database.query(strQuery);
        
        for(RetailQuoteWrapper rqw :retQuoteWrapList){
            if(rqw.selected){
                if(rqw.retQuote.Credit_Check_Required__c && !rqw.retQuote.Opportunity__r.Credit_Approved__c ){
                   ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantUtility.ERR_CHECK_CREDIT_APPROVAL));
                    quotesAvailable = false;
                    return null;
                }
                else {						
                    idsToClone.add(rqw.retQuote.id);
                }       
            }
        }
         if(label.OppQueryFields != null && label.OppQueryFields !=''){
          opp = (Opportunity)ConstantUtility.getObject('Opportunity',label.OppQueryFields,oppId);
        }
        else{
          opp = (Opportunity)ConstantUtility.getObject('Opportunity','Id:Name:Refresh_Expiration_Date__c:Executable_Quote_Generated__c',oppId);   
        }
        
        if(opp.AccountId != null){
            if(label.AccQueryFields != null && label.AccQueryFields !=''){
                acc = (Account)ConstantUtility.getObject('Account',label.AccQueryFields,opp.AccountId);
            }
         else{
                acc = (Account)ConstantUtility.getObject('Account','Id:Name',opp.AccountId);    
            }
        }
        
        RetailQuoteHandler.cloneAndCreateQuoteHistory(lstRTQT, idsToClone, ConstantUtility.RT_EXECUTABLE, ConstantUtility.RT_INDICATIVE);
        opp.Executable_Quote_Generated__c=true;
        update opp;
        String strQuery1 = ConstantUtility.getObjectFieldsQuery(ConstantUtility.RT_OBJECT);
        string qtStatus=ConstantUtility.STATUS_WAITING;
        strQuery1 += ' FROM '+ConstantUtility.RT_OBJECT+' WHERE RecordTypeId = :RetQuoteExecutableId and Request_Status__c =:qtStatus and Opportunity__c = :oppId' ;
        List<Retail_Quote__c> lstRTQT1 = Database.query(strQuery1); 
        //PricingWSHelper.sendQuotesForPricing(lstRTQT1,opp,acc); 
       
        PricingWSHelper.sendQuotesForPricingFuture(PricingWSHelper.getQuotesforPricing(lstRTQT1,opp,acc));
        
        return getOptyView();     
    }
    
    public PageReference sendNewQuotes(){
        checkQuoteExpiry();
         String oppId = opty.Id;
        List<Retail_Quote__c> newExecutableQuotesLst = new List<Retail_Quote__c>();
        
        System.Debug('Quotes are being sent ... ******');
         String strQuery = ConstantUtility.getObjectFieldsQuery(ConstantUtility.RT_OBJECT);
        strQuery += ' FROM Retail_Quote__c WHERE (RecordTypeId = :RetQuoteExecutableId or (RecordTypeId = :RetQuoteIndivativeId and Request_Status__c =\''+ ConstantUtility.STATUS_NEW+'\')) and Request_Status__c !=\''+STATUS_CONTRACT_SIGNED+'\' and Opportunity__c = :oppId'; //New Quotes::
        newExecutableQuotesLst =  Database.query(strQuery);
        system.debug('New Quotes::'+newExecutableQuotesLst);
       if(!newExecutableQuotesLst.isEmpty()){
         Set<id> rtQuoteIdLst = new Set<id>();
          for(Retail_Quote__c recRTQT :newExecutableQuotesLst) 
            rtQuoteIdLst.add(recRTQT.id);  
            sendQuotesForPricing(rtQuoteIdLst,oppId);
           return getOptyView();
        } 
        
        
       /* for(Retail_Quote__c rq : newExecutableQuotesLst){
                rq.Request_Status__c = ConstantUtility.STATUS_WAITING;                      
                newExecutableQuotesLst.add(rq);
                
        }
        if(!newExecutableQuotesLst.isEmpty()){
            update newExecutableQuotesLst;
            return getOptyView();
        }*/
        if(!quotesAvailable)
            return getOptyView();
        else    
            return null; 
    } 
    
    @future(callout=true)
    public static void sendQuotesForPricing(Set<id> rtQuoteIdLst, id oppId)
    {
        Opportunity opp;
        Account acc;
        String strQuery = ConstantUtility.getObjectFieldsQuery(ConstantUtility.RT_OBJECT);
        strQuery += ' FROM Retail_Quote__c WHERE id=:rtQuoteIdLst' ;
         List<Retail_Quote__c> lstQuoteSendForPricing =  Database.query(strQuery);
         if(label.OppQueryFields != null && label.OppQueryFields !=''){
          opp = (Opportunity)ConstantUtility.getObject('Opportunity',label.OppQueryFields,oppId);
        }
        else{
          opp = (Opportunity)ConstantUtility.getObject('Opportunity','Id:Name:Refresh_Expiration_Date__c:AccountId',oppId);   
        }
        
        if(opp.AccountId != null){
            if(label.AccQueryFields != null && label.AccQueryFields !=''){
                acc = (Account)ConstantUtility.getObject('Account',label.AccQueryFields,opp.AccountId);
            }
            else{
                acc = (Account)ConstantUtility.getObject('Account','Id:Name',opp.AccountId);    
            }
        }
        
        if(!lstQuoteSendForPricing.isEmpty()){
           PricingWSHelper.sendQuotesForPricing(lstQuoteSendForPricing,opp,acc);
           system.debug('Response sent');
          for(Retail_Quote__c recRTQT : lstQuoteSendForPricing)  
           recRTQT.Request_Status__c = ConstantUtility.STATUS_WAITING;
            
           Database.SaveResult[] srList = Database.update(lstQuoteSendForPricing, false);
        }
        
    }
    
    public void checkQuoteExpiry(){
        String quoteStatus = '';
        String oppId = opty.Id;
        String strQuery = ConstantUtility.getObjectFieldsQuery(ConstantUtility.RT_OBJECT);
        strQuery += ' FROM Retail_Quote__c WHERE RecordTypeId = :RetQuoteExecutableId and Opportunity__c = :oppId' ;
        //List<Retail_Quote__c> lstRTQT = ; 
        List<Retail_Quote__c> lstQuoteExpired = new List<Retail_Quote__c>(); 
        if(opty != null && opty.id != null){                       
            for(Retail_Quote__c rq : Database.query(strQuery)){
                quoteStatus = rq.Request_Status__c;
                if(opty.Refresh_Expiration_Date__c >= System.TODAY() || opty.Refresh_Expiration_Date__c == null){
                    /*
                    if(setQuoteSendForPricing.contains(quoteStatus)) {
                        rq.Request_Status__c = ConstantUtility.STATUS_WAITING;
                        lstQuoteSendForPricing.add(rq);    
                    }
                    if(setQuoteWaitingUpdate.contains(quoteStatus)) {
                        lstQuoteWaitingUpdate.add(rq); 
                    }*/
                    if(quoteStatus.equals(ConstantUtility.STATUS_EXPIRED)){
                        lstQuoteExpired.add(rq);   
                        idsToClone.add(rq.id);
                    }
                }
                else {               	
	                 if(quoteStatus != STATUS_CONTRACT_SIGNED){
	                        lstQuoteExpired.add(rq);   
	                        idsToClone.add(rq.id);
	                 }
                }
            }
           
            if(!lstQuoteExpired.isEmpty()){
               RetailQuoteHandler.cloneAndCreateQuoteHistory(lstQuoteExpired, idsToClone,ConstantUtility.RT_INDICATIVE, ConstantUtility.RT_EXECUTABLE);   
            }
        }
    }
    
    public class RetailQuoteWrapper {
        public Retail_Quote__c retQuote {get; set;}
        public Boolean selected {get; set;}
 
        public RetailQuoteWrapper(Retail_Quote__c q) {
            retQuote = q;
            selected = false;
        }
    }
    
    public PageReference getOptyView(){
        
        return (new ApexPages.StandardController(opty)).view();
    }
}