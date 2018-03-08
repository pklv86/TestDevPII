/* 
 * Name: RequestPricingInfo
 * Type: Apex Class
 * Test Class: RequestPricingInfoTest
 * Description:  This class is used to request for the pricing information based on the Quote attached to opportunity. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti        01/10/2016       1. Initial Version created
 */
global with sharing class RequestPricingInfo {  
    
        webservice static String requestPriceStatus(Id oppId){
        String status = '';     
        String reload = 'NO';
        String quoteStatus = '';        
        String strQuery = '';
        Opportunity opp;
        Account acc;
        List<String> lstFields = new List<String>();
        Set<String> setQuoteWaitingUpdate = new Set<String>{'Manual Pricing in Process','Waiting on Load Data'};
        Set<String> setQuoteSendForPricing = new Set<String>{'New','Request Rejected','Pricing Complete','Error Utility Web-Service Unresponsive','Error-Invalid Account','Error - Price Curve Invalid','Error - Invalid Term Selected'};
        Set<Id> idsToClone = new Set<Id>();
        List<Retail_Quote__c> lstQuoteWaitingUpdate = new List<Retail_Quote__c>();
        List<Retail_Quote__c> lstQuoteSendForPricing = new List<Retail_Quote__c>();
        List<Retail_Quote__c> lstFinalQuoteForPricing = new List<Retail_Quote__c>();
        List<Retail_Quote__c> lstQuoteExpired = new List<Retail_Quote__c>();        
        
        Id retID = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_INDICATIVE);
        strQuery = ConstantUtility.getObjectFieldsQuery(ConstantUtility.RT_OBJECT);
        strQuery += ' FROM Retail_Quote__c WHERE RecordTypeId = :retID and Opportunity__c = :oppId' ;
        system.debug('>>>>>>>> QUERY : ' + strQuery);
        List<Retail_Quote__c> lstRTQT = Database.query(strQuery);
        
        if(lstRTQT.size() == 0){
            status = ConstantUtility.ERR_NO_QUOTES;
            reload = 'NO';
            return status+':'+reload; 
        }

        if(label.OppQueryFields != null && label.OppQueryFields !=''){
          opp = (Opportunity)ConstantUtility.getObject('Opportunity',label.OppQueryFields,oppId);
        }
        else{
          //opp = (Opportunity)ConstantUtility.getObject('Opportunity','Id:Name:Refresh_Expiration_Date__c',oppId);   
        }
        
        
        
        for(Retail_Quote__c recRTQT :lstRTQT){
            quoteStatus = recRTQT.Request_Status__c;
            if(quoteStatus == null){
                status = ConstantUtility.ERR_INVALID_QUOTE_STATUS;
                reload = 'NO';
                return status+':'+reload;
            }
            if(opp.Refresh_Expiration_Date__c >= System.TODAY() || opp.Refresh_Expiration_Date__c == null){
                if(setQuoteSendForPricing.contains(quoteStatus)) {
                    recRTQT.Request_Status__c = ConstantUtility.STATUS_WAITING;
                    lstQuoteSendForPricing.add(recRTQT);    
                }
                if(setQuoteWaitingUpdate.contains(quoteStatus)) {
                    lstQuoteWaitingUpdate.add(recRTQT); 
                }
                if(quoteStatus.equals(ConstantUtility.STATUS_EXPIRED)){
                    lstQuoteExpired.add(recRTQT);   
                    idsToClone.add(recRTQT.id);
                }
            }
            else{
                    lstQuoteExpired.add(recRTQT);   
                    idsToClone.add(recRTQT.id);
            }
        }
        
        system.debug('>>>>>>>> lstQuoteSendForPricing : ' + lstQuoteSendForPricing);
        system.debug('>>>>>>>> lstQuoteWaitingUpdate : ' + lstQuoteWaitingUpdate);
        system.debug('>>>>>>>> lstQuoteExpired : ' + lstQuoteExpired);
       
                    
        lstFinalQuoteForPricing.addAll(lstQuoteSendForPricing);
        List<Retail_Quote__c> clonedquotelst = new List<Retail_Quote__c>();
        if(!lstQuoteExpired.isEmpty()){
           clonedquotelst = RetailQuoteHandler.cloneAndCreateQuoteHistory(lstQuoteExpired, idsToClone, ConstantUtility.RT_INDICATIVE, ConstantUtility.RT_INDICATIVE);   
        }
        if(clonedquotelst != null && !clonedquotelst.isEmpty())
        lstFinalQuoteForPricing.addAll(clonedquotelst);
        
        if(!lstFinalQuoteForPricing.isEmpty()){
         Set<id> rtQuoteIdLst = new Set<id>();
          for(Retail_Quote__c recRTQT :lstFinalQuoteForPricing) 
            rtQuoteIdLst.add(recRTQT.id);  
            sendQuotesForPricing(rtQuoteIdLst,oppId);
        }    
            
       /* if(!lstFinalQuoteForPricing.isEmpty()){
           PricingWSHelper.sendQuotesForPricing(lstFinalQuoteForPricing,opp,acc); 
        }
        
        
        if(!lstQuoteSendForPricing.isEmpty()){
            Database.SaveResult[] srList = Database.update(lstQuoteSendForPricing, false);          
        }*/
        
        if(!setQuoteWaitingUpdate.isEmpty()){
            status = ConstantUtility.ERR_PRICE_VALID;
            reload = 'NO';
        } 
        
        if(!lstFinalQuoteForPricing.isEmpty()){           
            status = ConstantUtility.ERR_VALID_QUOTES_SUBMITTED;
            reload = 'YES';
        } 
        
        return status+':'+reload;       
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
           system.debug('Sent quote to pricing system.');
          for(Retail_Quote__c recRTQT : lstQuoteSendForPricing)  
           recRTQT.Request_Status__c = ConstantUtility.STATUS_WAITING;
            
           Database.SaveResult[] srList = Database.update(lstQuoteSendForPricing, false);
        }
     }
   
  }