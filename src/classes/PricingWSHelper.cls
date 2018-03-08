/* 
 * Name: PricingWSHelper
 * Type: Apex Class
 * Test Class: Covered under the respective main classes
 * Description:  This class contains the helper functions for generating VO's and make WS calls. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti        01/17/2016       1. Initial Version created
 */
public with sharing class PricingWSHelper {
    public static void sendQuotesForPricing(List<Retail_Quote__c> lstRetQt,Opportunity opp, Account acc){
        
        system.debug('>>>>>>>> FOR PRICING ENGINE : ' + lstRetQt);
         String quoteRecType = '';
        if(lstRetQt!= null && !lstRetQt.isEmpty() )
        {
          RecordType rec = [select id,name from RecordType where id=:lstRetQt[0].recordtypeid];
          quoteRecType = rec.name;
          opp.Offer_Type__c = quoteRecType;
        }
        
        dynegyComServices_new.SforcePricingRequest reqOppQuote = new dynegyComServices_new.SforcePricingRequest();
        reqOppQuote.Opportunity = getOpportunityVO(opp,acc);
        reqOppQuote.Quotes = getQuotesVO(lstRetQt);        
        reqOppQuote.LDCAccounts = getLDCAccounts(opp);
        
        system.debug('>>>>>>>> getOpportunityVO : ' + reqOppQuote.Opportunity);
        system.debug('>>>>>>>> getQuotesVO : ' + reqOppQuote.Quotes);
        system.debug('>>>>>>>> LDCAccounts : ' + reqOppQuote.LDCAccounts);
        system.debug('****Pricing Request'+reqOppQuote);
        
        dynegyComServices_new.BasicHttpBinding_IRetailWS tOrg = new dynegyComServices_new.BasicHttpBinding_IRetailWS();
        try{
            String pResp = tOrg.RequestPricing(reqOppQuote);
            system.debug('>>>>>>>> pResp : ' + pResp);
        }
        catch(exception e){
            system.debug('>>>> ERROR In Web Service Call: ' + e.getMessage());
        }
        
        
    }

    public static string getQuotesforPricing(List<Retail_Quote__c> lstRetQt,Opportunity opp, Account acc){
        system.debug('>>>>>>>> FOR PRICING ENGINE : ' + lstRetQt);
        
          String quoteRecType = '';
        if(lstRetQt!= null && !lstRetQt.isEmpty() )
        {
        
          RecordType rec = [select id,name from RecordType where id=:lstRetQt[0].recordtypeid];
          quoteRecType = rec.name;
          opp.Offer_Type__c = quoteRecType;
        }
         
        dynegyComServices_new.SforcePricingRequest reqOppQuote = new dynegyComServices_new.SforcePricingRequest();
        reqOppQuote.Opportunity = getOpportunityVO(opp,acc);
        reqOppQuote.Quotes = getQuotesVO(lstRetQt);        
        reqOppQuote.LDCAccounts = getLDCAccounts(opp);
        
        system.debug('>>>>>>>> getOpportunityVO : ' + reqOppQuote.Opportunity);
        system.debug('>>>>>>>> getQuotesVO : ' + reqOppQuote.Quotes);
        system.debug('>>>>>>>> LDCAccounts : ' + reqOppQuote.LDCAccounts);
        system.debug('****Pricing Request'+reqOppQuote);
         system.debug('****Pricing Request JSON '+JSON.serialize(reqOppQuote));
        
       return JSON.serialize(reqOppQuote);

    }

    @future(CallOut=true)
    public  Static void  sendQuotesForPricingFuture(string request){

        dynegyComServices_new.BasicHttpBinding_IRetailWS tOrg = new dynegyComServices_new.BasicHttpBinding_IRetailWS();
        try{
           
            String pResp = tOrg.RequestPricing((dynegyComServices_new.SforcePricingRequest)json.deserialize(request, dynegyComServices_new.SforcePricingRequest.class));
            system.debug('>>>>>>>> pResp : ' + pResp);
           //PricingWSHelper.onPricingFailure(request);
        }
        catch(exception e){
            system.debug('>>>> ERROR In Web Service Call: ' + e.getMessage());
        }
        
        
    }

    public static void onPricingFailure(string request){

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(request);
        system.debug('****'+m);
        Map<string,Object> m2=(Map<String, Object>)m.get('SforceQuote');
        system.debug('****'+m2);
    }
    
    public static dynegyComServices_new.SforceOpportunity getOpportunityVO(Opportunity opp, Account acc){
        dynegyComServices_new.SforceOpportunity opportunityVO = new dynegyComServices_new.SforceOpportunity();
        opportunityVO.OpportunityName = opp.Name;
        opportunityVO.OpportunityId = opp.Id;
        opportunityVO.CustomerName = acc.Name;
        opportunityVO.ContractingEntity = acc.Contracting_Entity__c;
        opportunityVO.SalesforceAccountID = acc.Id;
        opportunityVO.CustomerType = opp.Type;
        opportunityVO.CustomerCategory = acc.Industry;
        opportunityVO.ServiceTerritory = opp.Service_Territory__c;
        opportunityVO.OfferType = opp.Offer_Type__c;
        opportunityVO.PricingType = opp.Pricing_Type__c;
        opportunityVO.SalesExec = opp.CreatedBy.Name;
        opportunityVO.PricingDueDate = opp.Pricing_Due_Date__c;
        opportunityVO.PricingDeskContact = opp.Pricing_Desk_Contact__c;
        opportunityVO.SupplierDUNS = opp.Supplier_DUNS__c;
        opportunityVO.WorkbookLocation = opp.Workbook_Location__c;
        opportunityVO.SpecialPricingInstructions = opp.Special_Pricing_Instructions__c;
        opportunityVO.TargetPrice = opp.Target_Price__c;
        opportunityVO.ContractNumber = opp.Contract.ContractNumber;
        
        return opportunityVO;
    }
    
    public static dynegyComServices_new.ArrayOfSforceQuote getQuotesVO(List<Retail_Quote__c> lstRetQt){
        system.debug('****Retail Quote'+lstRetQt);
        List<dynegyComServices_new.SforceQuote> lstQuotes = new List<dynegyComServices_new.SforceQuote>();
        dynegyComServices_new.ArrayOfSforceQuote arrQuotes = new dynegyComServices_new.ArrayOfSforceQuote();
        dynegyComServices_new.SforceQuote quoteVO;
        for(Retail_Quote__c recQuote :lstRetQt){
            quoteVO = new dynegyComServices_new.SforceQuote();
            quoteVO.ProductCode = recQuote.Product__r.Name;
            System.debug('**** recQuote.Product__r.Name: ' + recQuote.Product__r.Name);
            quoteVO.EndTerm = recQuote.End_Term__c;
            quoteVO.PaymentTerms = (recQuote.Payment_Terms__c != null)?Integer.ValueOf(recQuote.Payment_Terms__c):null;
            quoteVO.StartTerm = recQuote.Start_Term__c;
            quoteVO.BrokerFee = recQuote.Broker_Fee__c;
            quoteVO.IndexMargin = recQuote.Index_Margin__c;
            quoteVO.Margin = recQuote.Margin__c;
            quoteVO.MarketingCost = recQuote.Marketing_Cost__c;
            quoteVO.MuniFee = recQuote.Municipality_Fee__c;
            quoteVO.OffPeakBlockSize = recQuote.Off_Peak_Block_Size__c;
            quoteVO.OnPeakBlockSize = recQuote.On_Peak_Block_Size__c;
            quoteVO.PercentEnergyFixed = recQuote.Energy_Fixed__c;
            quoteVO.VoluntaryRecPercent = recQuote.Voluntary_REC__c;
            quoteVO.QuoteID = recQuote.Id;
            quoteVO.TermLength = Integer.valueOf(recQuote.Term__c);
            quoteVO.BrokerFeeAlloc = recQuote.Broker_Fee_Allocation__c;
            quoteVO.IndexMarginAlloc = recQuote.Index_Margin_Allocation__c;
            quoteVO.MarginAlloc = recQuote.Margin_Allocation__c;
            quoteVO.MarketingCostAlloc = recQuote.Marketing_Cost_Allocation__c;
            quoteVO.MuniFeeAlloc = recQuote.Municipality_Fee_Allocation__c;
            quoteVO.VoluntaryRecGeoLocation = recQuote.Voluntary_REC_Geographic_Location__c;
            quoteVO.VoluntaryRecType = recQuote.Voluntary_REC_Generator_Type__c; 
            quoteVO.HoldingDays = recQuote.Holding_Days__c;                       
            lstQuotes.add(quoteVO);
        }
        arrQuotes.SforceQuote = lstQuotes;        
        return arrQuotes;
    }
    
    public static dynegyComServices_new.ArrayOfSforceAccount getLDCAccounts(Opportunity opp){
        List<dynegyComServices_new.SforceAccount> lstLDCAccount = new List<dynegyComServices_new.SforceAccount>();
        dynegyComServices_new.ArrayOfSforceAccount arrLDCAccount = new dynegyComServices_new.ArrayOfSforceAccount();
        dynegyComServices_new.SforceAccount LDCAccountVO;

        List<Opportunity_LDC__c> oll = new List<Opportunity_LDC__c>([select LDC_Account__c from Opportunity_LDC__c where Opportunity__c =: opp.Id]);
              
        set<String> ldcAccountNumber = new set<String>();
        for(Opportunity_LDC__c ol:oll ){
            ldcAccountNumber.add( ol.LDC_Account__c);
        }
        
        List<LDC_Account__c> ldcList = [select id,LDC_Account_Number__c,LDC_Vendor__c,LDC_Vendor__r.DUNS__c,LDC_Vendor__r.Utility_Code__c  from LDC_Account__c where id in: ldcAccountNumber];
         
        for(LDC_Account__c ldc :ldcList){            
            LDCAccountVO = new dynegyComServices_new.SforceAccount();
            LDCAccountVO.SforceLdcId = ldc.Id;
            LDCAccountVO.LDCAccountNumber = ldc.LDC_Account_Number__c;
            LDCAccountVO.UtilityDUNS = (ldc.LDC_Vendor__r.DUNS__c != null)?String.valueOf(ldc.LDC_Vendor__r.DUNS__c):'';
            LDCAccountVO.UtilityCode = ldc.LDC_Vendor__r.Utility_Code__c;
            lstLDCAccount.add(LDCAccountVO);             
        }
        
        arrLDCAccount.SforceAccount = lstLDCAccount;
        return arrLDCAccount;
    }           


}