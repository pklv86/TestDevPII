/* 
 * Name: CreateContractFromQuoteController
 * Type: Apex Class
 * Test Class: CreateContractFromQuoteControllerTest
 * Description:  This class is used to create Contract from Executable Quotes. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         02/10/2016       1. Initial Version created
 */
global with sharing class CreateContractFromQuoteController {
    public Retail_Quote__c recQuote {get; set;}
    public Contract quoteContract {get; set;}
    public final string USER_CONFIRMATION_MESSAGE = 'Please Validate the Following Fields from Signed Contract:'; 
    public final string NO_CODE_FOUND = 'No Code Found';
    public final string ERR_SELECT_VALID_RATE_CODE = 'Please select a valid rate code for contract creation.';
    public final string ERR_CONTRACTNAME_MISSING = 'Contract Name is required.'; 
    //public final string ERR_CONTRACTTYPE_MISSING = 'Contract Type is mandatory for contract creation.';
    public final string ERR_CONTRACTTYPE_MISSING = 'No Contract Type found for the Service Territory and Bill Method selected.';
    public final string ERR_BILLMETHOD_MISSING = 'Bill Method is required.';
    public final string ERR_COUNTERSIGNEDDATE_MISSING = 'Contract Counter Signed Date is required.';
    public string rateCode {get; set;}
    public string contractName {get; set;}
    public string strQuery;   
    
    public CreateContractFromQuoteController(ApexPages.StandardController stdController){
        rateCode = NO_CODE_FOUND;
        strQuery = 'Select ';
        contractName = '';
        quoteContract = new Contract();
        if(stdController.getRecord() != null){
            String recId = ((Retail_Quote__c)stdController.getRecord()).id;
            for(String rtFld : schema.SObjectType.Retail_Quote__c.fields.getMap().keySet()){
                strQuery += rtFld + ',';
            }
            strQuery += 'Product__r.Name,Opportunity__r.Service_Territory__c,Opportunity__r.Account.BillingAddress,Opportunity__r.Account.BillingStreet,Opportunity__r.Account.BillingCity,'+
                        'Opportunity__r.Account.BillingState,Opportunity__r.Account.BillingCountry,Opportunity__r.Account.BillingPostalCode,Opportunity__r.Account.id,Opportunity__r.RecordTypeId,Opportunity__r.Contract.Id,'+
                        'Opportunity__r.Referral_Broker__c FROM Retail_Quote__c WHERE ID = :recId LIMIT 1';
            
            recQuote = Database.query(strQuery);
            recQuote.Request_Status__c = 'Contract Signed';            
            if(recQuote != null && recQuote.Quote_Price_KWH__c != null && recQuote.Opportunity__r.Service_Territory__c != null){
                list<Rate_Code__c> lstRC = [select Id, Name from Rate_Code__c Where Price__c = :recQuote.Quote_Price_KWH__c AND Service_Territory__c = :recQuote.Opportunity__r.Service_Territory__c];
                if(!lstRC.isEmpty()){
                    rateCode = lstRC[0].Name;
                }
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,USER_CONFIRMATION_MESSAGE));
            
        }
    }
    
    public PageReference finishRequest(){
        /*
        if(rateCode == null || rateCode == '' || rateCode == NO_CODE_FOUND){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_SELECT_VALID_RATE_CODE));
            return null;
        }
        */
        Boolean hasErrorMessage = false;
        if(rateCode == null || rateCode == NO_CODE_FOUND){
            rateCode = '';
        }
        if(contractName == null || contractName == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_CONTRACTNAME_MISSING));
            hasErrorMessage = true;
        }
        /* Commented below code for SCR-1341- Nanda
        Contract_Type_Setting__c cts = Contract_Type_Setting__c.getValues(recQuote.Opportunity__r.Service_Territory__c+'-'+quoteContract.Bill_Method__c);
        if(cts!=null)
            quoteContract.Contract_Type__c = cts.Contract_Type__c;
        if(quoteContract.Contract_Type__c == null || quoteContract.Contract_Type__c == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_CONTRACTTYPE_MISSING));
            hasErrorMessage = true;
        }*/
        if(quoteContract.Bill_Method__c == null || quoteContract.Bill_Method__c == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_BILLMETHOD_MISSING));
            hasErrorMessage = true;
        }  
        if(quoteContract.Contract_Counter_Signed_Date__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERR_COUNTERSIGNEDDATE_MISSING));
            hasErrorMessage = true;
        }
        if(hasErrorMessage){             
             return null;
        }
        
        ID OptyAmendRecTypeId;
        try{
          OptyAmendRecTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Amendment').RecordTypeId;
        }
        catch(Exception ex){
          OptyAmendRecTypeId = null;
        }      
        
        //Contract quoteContract;        
        if(recQuote != null && recQuote.Opportunity__r.Account.id != null){
            Map<String, Schema.SObjectField> mapRetQtDescribe = schema.SObjectType.Retail_Quote__c.fields.getMap();
            Map<String, Schema.SObjectField> mapContractDescribe = schema.SObjectType.Contract.fields.getMap();
            //quoteContract = new Contract(Name = contractName);
            //Dynamically populate the contarct fields which are have matching fields in Quote
            for(String retQtField : mapRetQtDescribe.KeySet()){
                Schema.DescribeFieldResult describersult = mapRetQtDescribe.get(retQtField).getDescribe();
                if(!describersult.isCustom() || !describersult.isCreateable() || describersult.isCalculated()){
                    continue;
                }
                else if(mapContractDescribe.containsKey(retQtField))
                {
                    system.debug('Test : '+retQtField+' : '+recQuote.get(retQtField));
                    quoteContract.put(retQtField, recQuote.get(retQtField));
                }
            }
            //Set additional fields which can not be set via fieldmap
            quoteContract.Name = contractName;
            
            //Added for the new fields which salesforce receive from pricing SCR-1287
            //quoteContract.Quote_Index_Adder_Total_Per_KWH__c = recQuote.Quote_Index_Adder_Total_Per_KWH__c;
            quoteContract.ALL_IN_Price__c= recQuote.Total_Priced_KWH__c;
            quoteContract.Total_Priced_MWH__c= recQuote.Total_Priced_MWH__c;
            quoteContract.Quote_Index_Name__c= recQuote.Quote_Index_Name__c;
            quoteContract.Contract_Type__c = recQuote.ContractType__c ;
            
            quoteContract.StartDate = recQuote.Start_Term__c;
            quoteContract.ContractTerm = recQuote.Term__c.intValue();
            quoteContract.Product_Name__c = recQuote.Product__r.Name;
            quoteContract.Retail_Quote__c=recQuote.id;
            quoteContract.Rate_Code__c = rateCode;
            quoteContract.Service_Territory__c=recQuote.Opportunity__r.Service_Territory__c;
            quoteContract.AccountId=recQuote.Opportunity__r.Account.id;
            quoteContract.BillingStreet=recQuote.Opportunity__r.Account.BillingStreet;
            quoteContract.BillingCity=recQuote.Opportunity__r.Account.BillingCity;
            quoteContract.BillingState=recQuote.Opportunity__r.Account.BillingState;
            quoteContract.BillingCountry=recQuote.Opportunity__r.Account.BillingCountry;
            quoteContract.BillingPostalCode=recQuote.Opportunity__r.Account.BillingPostalCode;
            quoteContract.Contract_Broker_Fee__c = recQuote.Contract_Broker_Fee__c;
            quoteContract.Contract_Index_Margin__c = recQuote.Contract_Index_Margin__c;
            quoteContract.Contract_Margin__c = recQuote.Contract_Margin__c;
            quoteContract.Contract_Marketing_Cost__c = recQuote.Contract_Marketing_Cost__c;
            quoteContract.Contract_Municipality_Fee__c = recQuote.Contract_Municipality_Fee__c;
            quoteContract.Referral_Broker__c = recQuote.Opportunity__r.Referral_Broker__c;
            
            if(OptyAmendRecTypeId != null && OptyAmendRecTypeId.equals(recQuote.Opportunity__r.RecordTypeId) 
                && recQuote.Opportunity__r.Contract.Id != null){
                quoteContract.Parent_Contract__c = recQuote.Opportunity__r.Contract.Id;
            }
            try{
                update recQuote;
                insert quoteContract;
                /*
                Opportunity_LDC__c oldc;
                List<Opportunity_LDC__c> lstOLDC = new List<Opportunity_LDC__c>();
                if(recQuote.Opportunity__c != null){
                    for(Opportunity opp:[select id,name,(select id,Name from OpportunityLDCs__r) from opportunity where ID = :recQuote.Opportunity__c]){
                         for(Opportunity_LDC__c ldc: opp.OpportunityLDCs__r){
                             oldc = ldc;
                             oldc.Contract__c=quoteContract.id; 
                             oldc.Rate_Code__c=rateCode;
                             lstOLDC.add(oldc);
                         }
                    }    
                }
                if(!lstOLDC.isEmpty()){
                    update lstOLDC;
                } 
                */
                /* Commented beacue of eliminate duplicate Contract LDC 
                Contract_LDC__c cldc;
                List<Contract_LDC__c> lstCLDC = new List<Contract_LDC__c>();
                if(recQuote.Opportunity__c != null){
                    for(Opportunity opp:[select id,name,(select id,Name,LDC_Account__c from OpportunityLDCs__r) from opportunity where ID = :recQuote.Opportunity__c]){
                         for(Opportunity_LDC__c ldc: opp.OpportunityLDCs__r){
                             if(ldc.LDC_Account__c != null){
                                 cldc = new Contract_LDC__c();
                                 cldc.LDC_Account__c=ldc.LDC_Account__c;
                                 cldc.Contract__c=quoteContract.id; 
                                 cldc.Rate_Code__c=rateCode;
                                 lstCLDC.add(cldc);
                             }
                         }
                    }    
                }
                if(!lstCLDC.isEmpty()){
                    insert lstCLDC;
                } */
                          
            }
            catch(Exception Ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error creating Quote:'+ex.getMessage()));
                return null;
            }
        }
        if(quoteContract != null){
            return getObjectView(quoteContract);
        }
           
        return getObjectView(recQuote);
               
    }
    
    public PageReference exitRequest(){
        return getObjectView(recQuote);       
    }
    
    public PageReference getObjectView(sObject sobj){
        return (new ApexPages.StandardController(sobj)).view();
    }
    
    public PageReference cancelCode(){
        return Page.CreateContractFromQuote;       
    }
    
    public PageReference submitCode(){
        return Page.CreateContractFromQuote;       
    }
    
    public PageReference findRateCode(){
        return Page.SelectRateCodeForContract;
    }
    
    webservice static String contractExists(Id oppId){
    
        if(oppId == null){
            return 'NA';
        }
        
        List<Contract> lstCon = [select Id from Contract where Opportunity__c = :oppId];
        
        if(!lstCon.isEmpty()){
            return 'YES';
        }
        
        return 'NO';
    }
    webservice static String contractExistsOnQuote(Id quoteId){
        if(quoteId == null){
            return 'NA';
        }
        
        List<Contract> lstConQuote = [select Id from Contract where Retail_Quote__c = :quoteId];
        
        if(!lstConQuote.isEmpty()){
            return 'YES';
        }
        
        return 'NO';
    }
}