/**
 * This class will provide the actions needed for
 * LodeStar processing.
 *
 * version 1.1 - Major enhancement to how data is collected in order to aggregate
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 * @Version 2.0 - Prasad - Added LodeStar Identifier at account level as a unique identifier -Prasad
 * @Version 3.0 - Prasad - Modified in order to handle only active and final ldc accounts 
                           Contract ldc term start date not in future
                           Eliminating the Processing in Account:Lodestar Integration Status 
   @Version 4.0 - Prasad - For Skiping out the accounts that stops lodestar job due to validation failure
   @Version 5.0 - Nanda - Modified to skip accounts with null datetime field 
 **/ 
public class LodeStarActions {   
    /**
     * this method is designed to find and return a list of AccountId's that
     * need to be synchronized with LodeStar.
     *
     * @return List<Id> - list of Account Id's that need to be scynchronized.
     **/
    public static string acctype {get;set;}
    public static set<id> accountstoNotsync{get;set;}
    public static boolean singleacc {get; set;}
    public static ID CntId {get;set;}
    public static boolean syncflag {get; set;} 
    public static map<String,list<String>> accMap {get;set;}
       
    public static Set<Id> ObtainNonSynchronizedAccounts(){
        LodeStarIntegrationSetting__c lodestarSetting = LodeStarIntegrationSetting__c.getOrgDefaults();
        //just in case the Integration Settings are not set....
        Integer accountLimit = (lodestarSetting != null && lodestarSetting.BatchAccountLimit__c != null ? Integer.valueOf(lodestarSetting.BatchAccountLimit__c) : 100);
        Set<Id> accountIdSet = new Set<Id>();
        set<id> cntrSet = new set<id>(); 
    
        for(Contract_LDC__c contractLDCRec:[SELECT 
                                                Id, LDC_Account__c, LodeStar_Identifier__c,IsSynchronized__c,
                                                LDC_Account__r.Account__c,LDC_Account__r.LDC_Account_Number__c,
                                                LDC_Account__r.Account__r.LodeStar_Integration_Status__c,
                                                Contract__c,Contract__r.ContractNumber,Contract__r.LodeStar_Identifier__c
                                                FROM Contract_LDC__c
                                                WHERE LDC_Account__r.Account__r.LodeStar_Integration_Status__c = 'Not Synchronized'
                                             // AND  LDC_Account__r.Account__r.Validation__c = 'Validated'
                                                AND Contract__r.Validation__C = 'Validated'  
                                                AND (LDC_Account__r.LDC_Account_Status__c='ACTIVE' OR LDC_Account__r.LDC_Account_Status__c='FINAL')
                                                AND Term_Start_Date__c != null AND IsSynchronized__c = false   //AND Term_Start_Date__c <= TODAY
                                                LIMIT :accountLimit]){
          accountIdSet.add(contractLDCRec.LDC_Account__r.Account__c);
        }
        
        system.debug(' Account ID Set : '+accountIdSet.size()+' : '+accountIdSet);
        return accountIdSet;
    }
    
    public static Set<Id> ObtainAccountsSet(set<id> accset){
        Set<Id> accountIdSet = new Set<Id>();
        set<id> cntrSet = new set<id>();
        list<Contract_LDC__c> contractLDCLst = new list<contract_ldc__c>();
        system.debug('Accset : '+accset);
        for(Contract_LDC__c contractLDCRec:[SELECT 
                                                Id, LDC_Account__c, LodeStar_Identifier__c,IsSynchronized__c,
                                                LDC_Account__r.Account__c,LDC_Account__r.LDC_Account_Number__c,
                                                LDC_Account__r.Account__r.LodeStar_Integration_Status__c,
                                                Contract__c,Contract__r.ContractNumber,Contract__r.LodeStar_Identifier__c
                                                FROM Contract_LDC__c
                                                WHERE LDC_Account__r.Account__r.LodeStar_Integration_Status__c != 'Synchronized'
                                                AND Contract__r.Validation__C = 'Validated'
                                                AND (LDC_Account__r.LDC_Account_Status__c='ACTIVE' OR LDC_Account__r.LDC_Account_Status__c='FINAL')
                                                AND Term_Start_Date__c != null //AND Term_Start_Date__c <= TODAY
                                                AND (LDC_Account__r.Account__r.Business_account__c IN : accset OR  LDC_Account__r.Account__c IN : accset) 
                                                AND IsSynchronized__c = false ]){
            accountIdSet.add(contractLDCRec.LDC_Account__r.Account__c);
            contractLDCLst.add(contractLDCRec);
        }
        
        system.debug(' Account ID Set : '+accountIdSet.size()+' : '+accountIdSet);
        return accountIdSet;
    }
    
    public static list<Contract_LDC__c> contractLDCrequest(Set<Id> accountIdSet){
        
        string Query ='SELECT Id,Term_Start_Date__c, Term_Stop_Date__c, Active__c, IsSynchronized__c,Parent_Contract__c,Bill_method__c,Contract__c,'+
              'Contract__r.ContractNumber, Contract__r.ActivatedDate,Contract__r.AccountId,Contract__r.Account.BillingStreet,Contract__r.Account.BillingCity,'+
              'Contract__r.Account.BillingState, Contract__r.Account.BillingPostalCode,Contract__r.Account.BillingCountry,Contract__r.supplier__r.supplier_code__c,'+ 
              'Contract__r.Description,Contract__r.Contract_Type__c,Contract__r.Contract_Counter_Signed_Date__c,Contract__r.Bill_Method__c,Contract__r.Product_Name__c,'+
              'Contract__r.Offer_Code__c, Contract__r.StartDate, Contract__r.End_Date__c,Contract__r.Account.Short_Code__c,Contract__r.Account.Name,'+
              'contract__r.Account.Recordtype.name,Contract__r.Parent_Contract__r.ContractNumber,Contract__r.LodeStar_Identifier__c,Contract__r.Account.Legal_Entity_Name__c,'+
              'Contract__r.Service_Territory__c,LDC_Account__c,LDC_Account__r.Bill_Cycle__c, LDC_Account__r.LDC_Account_Number__c,LDC_Account__r.CRM_Id__c,'+
              'LDC_Account__r.Delivery_Voltage__c,LDC_Account__r.CreatedDate, LDC_Account__r.LDC_Type__c,LDC_Account__r.LDC_Vendor__r.Name, LDC_Account__r.Legacy_ID__c,'+
              'LDC_Account__r.Acct__c,LDC_Account__r.Utility_Rate_Class__c,LDC_Account__r.Revenue_Class__c, LDC_Account__r.Service_Street_1__c,'+
              'LDC_Account__r.Service_Street_2__c, LDC_Account__r.Service_City__c,LDC_Account__r.Service_State__c,LDC_Account__r.Service_Postal_Code__c,'+
              'LDC_Account__r.LDC_Start_Date__c, LDC_Account__r.LDC_Account_Status__c,LDC_Account__r.LDC_End_Date__c,LDC_Account__r.Supply_Group__c,'+
              'LDC_Account__r.Account_Type_Code__c,LDC_Account__r.Name,LDC_Account__r.LDC_Vendor__r.Utility_Code__c,LDC_Account__r.FIPS_Code__c,'+
              'LDC_Account__r.Service_County__c,LDC_Account__r.Billing_Street__c,LDC_Account__r.Billing_Address_Line_2__c,LDC_Account__r.Billing_City__c,'+
              'LDC_Account__r.Billing_State_Province__c,LDC_Account__r.Billing_Address_Line_3__c,LDC_Account__r.Billing_Zip_Postal_code__c,LDC_Account__r.Account__c,'+
              'LDC_Account__r.Account__r.Name, LDC_Account__r.Account__r.Supplier__c,LDC_Account__r.Account__r.Supplier__r.Supplier_Code__c,'+
              'LDC_Account__r.Account__r.Business_Account__r.Short_Code__c,LDC_Account__r.Account__r.Business_Account__c,LDC_Account__r.Account__r.Business_Account__r.Name,'+
              'LDC_Account__r.Account__r.Legal_Entity_Name__c FROM Contract_LDC__c WHERE IsSynchronized__c = false AND LDC_account__r.LDC_vendor__r.name !=\'AMEREN\' '+
              'AND (LDC_Account__r.LDC_Account_Status__c=\'ACTIVE\' OR LDC_Account__r.LDC_Account_Status__c=\'FINAL\') AND Term_Start_Date__c != null AND contract__r.validation__c = \'Validated\''; //AND Term_Start_Date__c <= TODAY
        
        system.debug('Check Single Account : '+singleacc+' Account Type Code : '+acctype+' Selected Contract : '+cntId);
        if(singleacc != null && singleacc){
            Query+=' AND (LDC_Account__r.Account__c IN :accountIdSet OR LDC_Account__r.Account__r.Business_account__c IN :accountIdSet) AND LDC_Account__r.Account__r.LodeStar_Integration_Status__c != \'Synchronized\'';
            if(acctype != Null)
                Query+=' AND LDC_Account__r.Account_Type_Code__c = \''+acctype+'\'';
            if(cntid != null)
                Query+=' AND Contract__c =: Cntid';
        }
        else
            Query+=' AND LDC_Account__r.Account__c IN :accountIdSet';
        system.debug('Formed Query : '+Query);          
        list<contract_ldc__c> contractLDCLst = Database.query(query);
                                                    
        return contractLDCLst;
    }
    
    /**
     * Specially Created to deliver WebServiceCallout Objects 
     *
     * @param Set<Id> - accountIdSet - set of Account Ids to process
     * @return Map dynegyComServices.ArrayOfSforceLstarCustomer - an Array of SforceLstarCustomer
     **/
    public static List<LodeStar.LodeStarDataContainer> ObtainDataObjectsForWSSynchronization(Set<Id> accountIdSet){
        //now lets build the list of Objects that will be returned
        //List<LodeStar.LodeStarDataContainer> dataContainerList = new List<LodeStar.LodeStarDataContainer>();
        Map<Id,LodeStar.LodeStarDataContainer> contractIdToDataContainerMap = new Map<Id,LodeStar.LodeStarDataContainer>();
        system.debug('Map : '+contractIdToDataContainerMap); 
        Set<Id> ldcAccountIdSet = new Set<Id>();
        Set<Id> AccIdSet = new Set<Id>();
        Set<Id> LdcIdSet = new Set<Id>();
        set<id> plSet = new set<id>();
        set<id> ldcplc = new set<id>();
        
        map<id,list<Peak_Load_Information__c>> plcmap = new map<id,list<Peak_Load_Information__c>>();

        list<Contract_LDC__c> contractLDCLst = contractLDCrequest(accountIdSet);
        
        //Added to error out accounts before the call out is made
         set<id> setErrorRecs = new set<id>();         
         set<id> setLDCRecs = new set<id>(); 
         set<id> setBillingError = new set<id>(); 
         boolean isBlankFieldFound = false;     
         List<Contract_LDC__c> lstCLDCProcessAccount = new List<Contract_LDC__c>();                
         List<Contract_LDC__c> tempcldcAccount = new List<Contract_LDC__c>();
         set<string> setValidatefieldLDC = new set<string>();
         set<string> setValidateFieldBillingGroup = new set<string>();         
         for(LodeStar_Error__c ldError:LodeStar_Error__c.getall().values()){
              if(ldError.Object__c =='Billing_group__c'){
                setValidateFieldBillingGroup.add(ldError.name);
              }
              else if(ldError.Object__c == 'LDC_Account__C'){
                setValidatefieldLDC.add(ldError.name);
              }
         }        
         List<String> acclst;
         accMap = new map<String,list<string>>();  
         for(sObject con : contractLDCLst ){
            Contract_LDC__c conLDCRec = (Contract_LDC__c) con;
            if(conLDCRec.LDC_Account__r.Account__r.business_account__c == null)
                setLDCRecs.add(conLDCRec.LDC_Account__r.Account__c);
         }
         if(!setLDCRecs.isEmpty()){    
             for(Billing_group__c bRec:[select id,name, Account__c,contract__c,Contract_Number__c,Group_Address_Line1__c,
                                                Group_Address_Line2__c, Group_Address_Line3__c,Group_City__c,Group_Postal_Code__c,
                                                Group_State__c, Synchronized__c,Pseudo_Contract__c,start_date__c, stop_date__c 
                                                from billing_group__c where Account__c in :setLDCRecs]){
                 for(String fieldname :setValidateFieldBillingGroup){    
                     if(string.valueOf(bRec.get(fieldname)) == null || string.valueOf(bRec.get(fieldname)) == ''){
                         if(!setBillingError.contains(bRec.id)){
                             setBillingError.add(bRec.id);
                             acclst = accMap.get(bRec.Account__c);
                             if(acclst == null){
                                 acclst = new list<String>();
                             }
                             acclst.add(bRec.name);
                             accMap.put(bRec.Account__c, acclst);
                             isBlankFieldFound = true;
                         }
                     }
                 }                
             }
         }
         Boolean fnlAcc = false;
         for(sObject rec : contractLDCLst){  
             Contract_LDC__c LDCRec = (Contract_LDC__c) rec;             
             for(string fieldName : setValidatefieldLDC){                     
                 if(string.valueOf(rec.getSobject('LDC_Account__r').get('LDC_Account_Status__C')) == 'FINAL'
                  && (string.valueOf(rec.getSobject('LDC_Account__r').get(fieldName)) == null 
                  || string.valueOf(rec.getSobject('LDC_Account__r').get(fieldName)) == '')){                           
                    fnlAcc = true;
                  }
                  else if(string.valueOf(rec.getSobject('LDC_Account__r').get('LDC_Account_Status__C')) == 'ACTIVE'
                  && (string.valueOf(rec.getSobject('LDC_Account__r').get(fieldName)) == null 
                  || string.valueOf(rec.getSobject('LDC_Account__r').get(fieldName)) == '') && fieldName != 'LDC_End_date__C'){
                    fnlAcc = true;
                  }  
                  if(fnlAcc){ 
                    system.debug('\n===setErrorRecs==='+setErrorRecs+'\n===Account==='+LDCRec.LDC_Account__r.Account__c);
                    if(!setErrorRecs.contains(LDCRec.LDC_Account__c) ){                           
                        setErrorRecs.add(LDCRec.LDC_Account__c);
                        acclst = accMap.get(LDCRec.LDC_Account__r.Account__c);
                        if(acclst == null){
                            acclst = new list<String>();
                        }
                        acclst.add(LDCRec.LDC_Account__r.LDC_Account_number__c);
                        accMap.put(LDCRec.LDC_Account__r.Account__c,acclst); 
                        fnlAcc = false;                      
                        isBlankFieldFound = true;
                    }
                 }
             }
             if(!isBlankFieldFound){
                 tempcldcAccount.add(LDCRec);
             }                                
         }
         for(Contract_LDC__c conrec : tempcldcAccount){
            if(!accMap.containskey(conrec.LDC_Account__r.Account__c)){
                lstCLDCProcessAccount.add(conrec);
            }
         }
         system.debug('\n===accMap==='+accMap);
         if(!lstCLDCProcessAccount.isEmpty()){
             contractLDCLst = lstCLDCProcessAccount;
         }
         else{
             contractLDCLst = new list<Contract_LDC__c>();
         }
         system.debug('\n===contractLDCLst==='+contractLDCLst);
        
    
        
        
        /*****************************GENERATING Information FOR Peak Load Information *******************************************/
        for(Contract_LDC__c contractLDC:contractLDCLst){
            ldcplc.add(contractLDC.ldc_account__c);
        }
        system.debug('LDC PLC : '+ldcplc);
        //Moved Query here to eliminate Too Many SOQL : 201 
        list<Peak_Load_Information__c> plclsttmp = [select id,name,Load_Type__c,Load_Value__c,Start_Date__c,EndDate__c,ldc_account__c from Peak_Load_Information__c 
                                                        where ldc_account__c IN : ldcplc and active__c = true];
        list<Peak_Load_Information__c> plclst;
        for(Peak_Load_Information__c pl : plclsttmp){
            system.debug('PeakLoad : '+plset+' : '+pl.id);
            if(!plset.contains(pl.id) ){
                plclst = new list<Peak_Load_Information__c>();
                if(PlcMap.containskey(pl.ldc_account__c)){
                    plclst = PlcMap.get(pl.ldc_account__c);
                    plclst.add(pl);
                    PlcMap.put(pl.ldc_account__c,plclst);
                }
                else{
                    plclst.add(pl);
                    PlcMap.put(pl.ldc_account__c,plclst);
                }
                plset.add(pl.id);
            }
        }
        system.debug('PLC Map : '+plcmap);        
            
        for(Contract_LDC__c contractLDC:contractLDCLst){
            
            //creating / or finding the data container object
            system.debug('Container Loading');
            system.debug('Identifier : '+contractLDC.Contract__r.LodeStar_Identifier__c);
            LodeStar.LodeStarDataContainer container;
            if(contractIdToDataContainerMap.containsKey(contractLDC.Contract__c)){
                container = contractIdToDataContainerMap.get(contractLDC.Contract__c);
            } else {
                container = new LodeStar.LodeStarDataContainer();
            }
            //now lets put the Contract Object in the container
            container.c = contractLDC.Contract__r;
            container.customerSFID = contractLDC.Contract__c;
            //container.customerName = contractLDC.Contract__r.Account.Name;
            container.customerShortCode = contractLDC.Contract__r.Account.Short_Code__c;
            if(contractLDC.Contract__r.Bill_Method__c == 'DUAL' || contractLDC.Contract__r.Bill_Method__c == 'SBO/ESP'){
                if(contractLDC.Contract__r.Account.Legal_Entity_Name__c != null && contractLDC.Contract__r.Account.Name != null){                  
                    String legalName = removeSpecialCharacters(contractLDC.Contract__r.Account.Legal_Entity_Name__c);
                    if(legalName.length()>39){
                        legalName = legalName.left(39);
                    }
                    container.customerName = legalName;          
                }
                else{
                    container.customerName = removeSpecialCharacters(contractLDC.Contract__r.Account.Name);
                }
            }
            else{
                container.customerName = removeSpecialCharacters(contractLDC.Contract__r.Account.Name);
            }
            system.debug('===Customer name==='+container.customerName);
            //now we need to add the LDC_Account__c record to the container
            contractLDC.LDC_Account__r.Account__r.name = removeSpecialCharacters(contractLDC.LDC_Account__r.Account__r.name);
            container.accountLDCMap.put(contractLDC.LDC_Account__c,contractLDC.LDC_Account__r);
            //now we need to add the Contract LDC Item itself to the Container
            List<Contract_LDC__c> tempContractLDCList;
            if(container.contractLDCMap.containsKey(contractLDC.LDC_Account__c) && container.contractLDCMap.containsKey(contractLDC.Contract__c)){
                tempContractLDCList = container.contractLDCMap.get(contractLDC.LDC_Account__c);
                system.debug(' check : '+tempContractLDCList+' : '+contractLDC.LDC_Account__r.name); 
            } else {
                tempContractLDCList = new List<Contract_LDC__c>();
                system.debug(' check : '+tempContractLDCList+' : '+contractLDC.LDC_Account__r.name);
            }
            tempContractLDCList.add(contractLDC);
            container.contractLDCMap.put(contractLDC.LDC_Account__c,tempContractLDCList);
            system.debug(' check contractLDCMap : '+container.contractLDCMap);
            //add ldcAccountToIdSet
            ldcAccountIdSet.add(contractLDC.LDC_Account__c);
            
            /*****************************ADDITIONAL PAYLOAD FOR Peak Load Information *******************************************/
            container.PlcLDCMap.put(contractLDC.LDC_Account__c,plcmap.get(contractLDC.LDC_Account__c));
            
            //finally we put the container to the map
            contractIdToDataContainerMap.put(contractLDC.Contract__c,container);
            system.debug('Container :: '+container);
            system.debug('RecordType : '+contractldc.contract__r.Account.Recordtype.name);
            if(contractldc.contract__r.Account.Recordtype.name == 'C&I Customer'){
                AccIdSet.add(contractLDC.Contract__r.AccountId);
                LdcIdSet.add(contractLDC.ldc_account__c);
            }
        }
        system.debug('contractIdToDataContainerMap : '+contractIdToDataContainerMap.size()+' : '+contractIdToDataContainerMap); 
      
        //lets get the Contract_Terms__c related to the Contracts involved
        Map<Id,List<Contract_Term__c>> ctTermMap = new Map<Id,List<Contract_Term__c>>();
        for(Contract_Term__c ctObj:[SELECT
                                        Id, Contract__c, Contract_Term_Value__c, Term_Category__c,
                                        Term_Start_Date__c, Term_Stop_Date__c, Term_Type__c,
                                        Value_Num__c, Value_String__c
                                    FROM Contract_Term__c WHERE Contract__c IN :contractIdToDataContainerMap.keySet()]){
            List<Contract_Term__c> tempList;
            if(ctTermMap.containsKey(ctObj.Contract__c)){
                tempList = ctTermMap.get(ctObj.Contract__c);
            } else {
                tempList = new List<Contract_Term__c>();
            }
            tempList.add(ctObj);
            ctTermMap.put(ctObj.Contract__c,tempList);
        }
        for(Id contractId:contractIdToDataContainerMap.keySet()){
            if(ctTermMap.containsKey(contractId)){
                LodeStar.LodeStarDataContainer container = contractIdToDataContainerMap.get(contractId);
                container.contractTermList = ctTermMap.get(contractId);
                contractIdToDataContainerMap.put(contractId,container);
            }
        }
        //lets get the AccountBillDeterminates related to the LDC Accounts involved
        system.debug('contractIdToDataContainerMap : '+contractIdToDataContainerMap.size()+' : '+contractIdToDataContainerMap); 
        
        /*****************************ADDITIONAL PAYLOAD FOR BILLING GROUP *******************************************/
        system.debug('AccIdSet : '+AccIdset+' LdcIdSet : '+LdcIdSet);
        for(Billing_Group_Ldc__c bgldc : [select id,name,Billing_Group__c,Billing_Group__r.Name,Pseudo_Contract__c,Billing_Start_Date__c,Billing_Stop_Date__c,LDC_Account_Number__c,
                                    LDC_Account__c,LDC_Account__r.account__c,Billing_Group__r.Contract_Number__c,Billing_Group__r.Pseudo_Contract__c,Billing_Group__r.Group_Address_Line1__c,
                                    Billing_Group__r.Group_Address_Line2__c,Billing_Group__r.contract__c,Billing_Group__r.Group_Address_Line3__c,Billing_Group__r.Group_City__c,
                                    Billing_Group__r.Group_State__c,Billing_Group__r.Group_Postal_Code__c,Billing_Group__r.Start_Date__c,Billing_Group__r.Stop_date__c 
                                    from Billing_Group_Ldc__c where Ldc_Account__c IN : LdcIdSet and Synchronized__c = false ]){ //and active__c = true
            
            LodeStar.LodeStarDataContainer container = contractIdToDataContainerMap.get(bgldc.Billing_Group__r.contract__c);
            if(container != null){
                List<Billing_Group_Ldc__c> bgldclst;
                if(container.BillingGroupLDCMap.containskey(bgldc.Billing_Group__c))
                    bgldclst = container.BillingGroupLDCMap.get(bgldc.Billing_Group__c);
                else
                    bgldclst = new list<Billing_Group_Ldc__c>();
                bgldclst.add(bgldc);    
                container.BillingGroupLDCMap.put(bgldc.ldc_account__c,bgldclst);
                contractIdToDataContainerMap.put(bgldc.Billing_Group__r.contract__c,container);
                
                if(!container.BillingGroupMap.containskey(bgldc.Billing_Group__c)){
                    container.BillingGroupMap.put(bgldc.Billing_Group__c,bgldc.Billing_Group__r);
                    system.debug('Billing Group : '+bgldc.Billing_Group__r);
                }
                contractIdToDataContainerMap.put(bgldc.Billing_Group__r.contract__c,container);
            }                           
        }
        
        return contractIdToDataContainerMap.values();
    } 
    
    
    /**
     * This method is designed to process data from the Custom Object Containers to send to LodeStar
     * for integration purposes.  All of the Data that was successfully sent will have the corresponding
     * Account record updated in Salesforce to Synchronized.
     *
     * @param Map<Id,LodeStar.Customer> the Map of data Containing the Custom Object Containers. It
     *                                  is sorted by the AccountID of the account the data is related to.
     **/
    public static void BuildAndSendPayload(List<LodeStar.LodeStarDataContainer> dataContainerList){
        system.debug('Test : '+acctype);
        System.debug(LoggingLevel.INFO,'\n\nBuildAndSendPayload Entered.\n\n');
        dataContainerList.sort();
        System.debug(LoggingLevel.INFO,'\n\nNumber Of dataContainers to send: ' + dataContainerList.size() + '\n\n');
        LodeStarIntegrationSetting__c setting = LodeStarIntegrationSetting__c.getOrgDefaults();
        Integer accountLimit = (setting.BatchAccountLimit__c == null ? 10 : Integer.valueOf(setting.BatchAccountLimit__c));
        Integer webserviceCalloutMax = Limits.getLimitCallouts();
        Integer dataContainerCount = 0;
        Set<Id> successfulAccountIdSet = new Set<Id>();
        Set<Id> successfulContractLDCIdSet = new Set<Id>();
        Set<Id> successfulAccountLDCIdSet = new Set<Id>();
        Set<Id> successfulBGroupSet = new Set<Id>();
        Set<Id> successfulBGroupLDCSet = new Set<Id>();
        Map<Id,String> failedAccountIdSet = new Map<Id,String>();
        Map<Id,String> failedContractLDCIdSet = new Map<Id,String>();
        Map<Id,String> failedAccountLDCIdSet = new Map<Id,String>();
        
        while(webserviceCalloutMax > 0){
            dynegyComServicesLodeStar.SforceLstarData dataToSend = new dynegyComServicesLodeStar.SforceLstarData();
            dataToSend.Customers = new dynegyComServicesLodeStar.ArrayOfSforceLstarCustomer();
            dataToSend.Customers.SforceLstarCustomer = new List<dynegyComServicesLodeStar.SforceLstarCustomer>();
            Integer loopcount = 0;
            Set<Id> processedAccountIdSet = new Set<Id>();
            Set<Id> processedContractLDCIdSet = new Set<Id>();
            Set<Id> processedLDCAccountIdSet = new Set<Id>();
            Set<Id> processedBGroupIdSet = new Set<Id>();
            Set<Id> processedBGroupLDCIdSet = new Set<Id>();
            while(dataContainerCount < dataContainerList.size()){
                LodeStar.LodeStarDataContainer dataContainer = dataContainerList[dataContainerCount];
                dataToSend.Customers.SforceLstarCustomer.add(dataContainer.buildWebServiceObject()); 
                processedAccountIdSet.addAll(dataContainer.processedAccountIdSet);
                processedContractLDCIdSet.addAll(dataContainer.processedContractLDCIdSet);
                processedLDCAccountIdSet.addAll(dataContainer.processedLDCAccountIdSet);
                processedBGroupIdSet.addAll(dataContainer.processedBGroupIdSet);
                processedBGroupLDCIdSet.addAll(dataContainer.processedBGroupLDCIdSet);
                loopCount++;
                dataContainerCount++;
                if(loopCount >= accountLimit) break;
                system.debug('****data container****'+dataContainer);           
                system.debug('****processed Accounts data container****'+dataContainer.processedAccountIdSet);
                system.debug('****processed Accounts****'+processedAccountIdSet);
            }
            if(!dataToSend.Customers.SforceLstarCustomer.isEmpty()){
                System.debug(LoggingLevel.INFO,'\n\nNumber Of Customers Being sent: ' + dataToSend.Customers.SforceLstarCustomer.size() + '\n\n');
                //.debug(LoggingLevel.INFO,'\n\nMessage: ' + dataToSend + '\n\n');
                dynegyComServicesLodeStar.BasicHttpBinding_ISforceLstar svc = new dynegyComServicesLodeStar.BasicHttpBinding_ISforceLstar();
                svc.timeout_x = 60000;
                try{
                    String response = svc.LoadstarInterface(dataToSend);
                    System.debug(LoggingLevel.INFO,'\n\nWeb Service Response: ' + response + '\n\n');
                    successfulAccountIdSet.addAll(processedAccountIdSet);
                    successfulContractLDCIdSet.addAll(processedContractLDCIdSet);
                    successfulAccountLDCIdSet.addAll(processedLDCAccountIdSet);
                    successfulBGroupSet.addALL(processedBGroupIdSet);
                    successfulBGroupLDCSet.addAll(processedBGroupLDCIdSet);
                } catch(System.Exception ex) {
                    System.debug(LoggingLevel.INFO,'The Webservice Call failed. The error was: ' + ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString());
                    for(Id failedAccountId:processedAccountIdSet){
                        failedAccountIdSet.put(failedAccountId,ex.getMessage() + ' : ' + ex.getStackTraceString());
                    }
                    for(Id failedContractLDCId:processedContractLDCIdSet){
                        failedContractLDCIdSet.put(failedContractLDCId,ex.getMessage() + ' : ' + ex.getStackTraceString());
                    }
                    for(Id failedAccountLDCId : ProcessedLDCAccountIdSet){
                      failedAccountLDCIdSet.put(failedAccountLDCId,ex.getMessage() + ' : ' + ex.getStackTraceString());  
                    }
                    system.debug('***Failed Account***'+failedAccountIdSet);
                    system.debug('***Failed Contract LDC Account***'+failedContractLDCIdSet);
                    system.debug('***Failed LDC Account***'+failedAccountLDCIdSet);
                }
            }
            webserviceCalloutMax--;
        }
        
        //Added to insert error with null value fields  
        if(accMap.size() > 0){
            String msg = 'Date Time Fields can not be null for the accounts\n';
            NewExceptionBlock(accMap, msg);
        }
       
        
        //now we need to log successes and errors.
        Set<Id> accountIdSetToUpdate = new Set<Id>();
        accountIdSetToUpdate.addAll(successfulAccountIdSet);
        accountIdSetToUpdate.addAll(failedAccountIdSet.keySet());
        List<Account> accountsToUpdate = new List<Account>();
        List<LodeStar_Errors__c> errorsToCreate = new List<LodeStar_Errors__c>();
        system.debug('Accounts to Update : '+accountIdSetToUpdate.size()+' : '+accountIdSetToUpdate);
        
        //update the Accounts Accordingly
        for(Account a:[SELECT Id, Short_Code__c, LodeStar_Integration_Status__c,Recordtype.name FROM Account WHERE Id IN :accountIdSetToUpdate]){
            system.debug('Test Inside : '+acctype+' : '+a.recordtype.name);
            if(successfulAccountIdSet.contains(a.Id) && !accountstoNotsync.contains(a.id)){
                if(acctype != null && a.recordtype.name == 'C&I Customer' && !syncflag){
                    a.LodeStar_Integration_Status__c = 'Not Synchronized';
                }
                else if(Cntid != null && !syncflag){
                    a.LodeStar_Integration_Status__c = 'Not Synchronized';
                }
                else if(!syncflag){
                    a.LodeStar_Integration_Status__c = 'Not Synchronized';
                }
                else{
                    a.LodeStar_Integration_Status__c = 'Synchronized';
                }
            } 
            else if(failedAccountIdSet.containsKey(a.Id)) {
                a.LodeStar_Integration_Status__c = 'ERROR';
                errorsToCreate.add(new LodeStar_Errors__c(
                    Account__c = a.Id,
                    ErrorMsg__c = failedAccountIdSet.get(a.Id),
                    ExceptionTime__c = Datetime.now(),
                    ShortCode__c = a.Short_Code__c
                ));
            }             
            else{
              a.LodeStar_Integration_Status__c = 'Not Synchronized';
            }
            accountsToUpdate.add(a);
        }
        if(!accountsToUpdate.isEmpty()) update accountsToUpdate;
        
        //update Last sent to Lode Star Status Date in LDC Accounts
        Set<Id> LDCaccountIdSetToUpdate = new Set<Id>();
        LDCaccountIdSetToUpdate.addAll(successfulAccountLDCIdSet);
        LDCaccountIdSetToUpdate.addAll(failedAccountLDCIdSet.keySet());
        List<LDC_Account__c> LDCaccountsToUpdate = new List<LDC_Account__c>();
        system.debug('processedLDCAccountIdSet : '+successfulAccountLDCIdSet);
        for(LDC_Account__c ldca:[SELECT Id, Short_Code__c,Account__c, LastSent_to_Lodestar__c,LoadStar_Executed__c FROM LDC_Account__c WHERE Id IN :LDCaccountIdSetToUpdate]){
          if(successfulAccountLDCIdSet.contains(ldca.Id)){
                ldca.LoadStar_Executed__c = true;
                ldca.LastSent_to_Lodestar__c = system.now();
                LDCaccountsToUpdate.add(ldca);
            }
        }
        system.debug('LDCaccountsToUpdate : '+LDCaccountsToUpdate.size()+' : '+LDCaccountsToUpdate);
        if(!LDCaccountsToUpdate.isempty()) update LDCaccountsToUpdate; 
        
        //update the ContracT LDC's Accordingly.
        system.debug('Contract LDC to Update : '+successfulContractLDCIdSet.size()+' : '+successfulContractLDCIdSet);
        List<Contract_LDC__c> contractLDCsToUpdate = new List<Contract_LDC__c>();
        for(Contract_LDC__c contractLDC:[SELECT Id, IsSynchronized__c FROM Contract_LDC__c WHERE Id IN :successfulContractLDCIdSet]){
            contractLDC.IsSynchronized__c = true;
            contractLDCsToUpdate.add(contractLDC);
        }
        if(!contractLDCsToUpdate.isEmpty()) update contractLDCsToUpdate;
        if(!errorsToCreate.isEmpty()) insert errorsToCreate;
        
        Set<Id> contractIdSetToUpdate = new Set<Id>();
        contractIdSetToUpdate.addAll(successfulContractLDCIdSet);
        contractIdSetToUpdate.addAll(failedContractLDCIdSet.keySet());
        List<Contract> ContractsToUpdate = new List<Contract>();
        List<ID> ContractsTemp = new List<ID>();
        system.debug('Contract LDC to contract : '+contractIdSetToUpdate.size()+' : '+contractIdSetToUpdate);
        for(Contract_LDC__c cnt: [select Contract__c FROM Contract_LDC__c WHERE Id IN :contractIdSetToUpdate]){
          ContractsTemp.add(cnt.Contract__c);
        }
        for(contract cnts : [select id,name,Lodestar_Sent_Date__c from contract where Id IN : ContractsTemp]){
          cnts.Lodestar_Sent_Date__c=system.now();
          ContractsToUpdate.add(cnts); 
        }
        system.debug('Contracts to update : '+ContractsToUpdate.size()+' : '+ContractsToUpdate);
        if(!ContractsToUpdate.isEmpty()) update ContractsToUpdate;  
        
        list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
        for(Billing_Group_Ldc__c bgldc : [select id,Synchronized__c from Billing_Group_Ldc__c where id IN : successfulBGroupLDCSet]){
            bgldc.Synchronized__c = true;
            bgldclst.add(bgldc);
        }
        if(!bgldclst.isEmpty()) update bgldclst;
        
        list<Billing_Group__c> bglst = new list<Billing_Group__c>();
        for(Billing_Group__c bg : [select id,Synchronized__c from Billing_Group__c where id IN : successfulBGroupSet]){
            bg.Synchronized__c = true;
            bglst.add(bg);
        }
        if(!bglst.isEmpty()) update bglst;
    }
    
    
    /**
      * This method is designed to wrap up the process of Gathering the Data needed to send to LodeStar
      * and actually sending it all in one method. This should be the primary method called from this
      * class.
      *
      * @param Set<Id> - the set of account Ids to send to LodeStar
      **/
    public static void MainProcess(Set<Id> accountIdSet,set<id> accountsNotsync){
        List<LodeStar.LodeStarDataContainer> dataObjList;
        syncflag = true;
        if(accountstoNotsync == null)
            accountstoNotsync = new set<id>();
        try{
            for(Id acc : accountsNotsync){
                accountstoNotsync.add(acc);
            }
            dataObjList = ObtainDataObjectsForWSSynchronization(accountIdSet);
            system.debug('Data Object : '+dataObjList.size()+' : '+dataObjList);
            BuildAndSendPayload(dataObjList);
        } catch(System.Exception ex){
            //at this point, if an exception is thrown at this level, all of the items need to be set to error.
            ExceptionBlock(accountIdSet,ex);
        }
    }
    
    public static void SingleAccountProcess(Set<Id> accountIdSet, string typecode, ID Cid, boolean sflag, boolean sacc){
        List<LodeStar.LodeStarDataContainer> dataObjList;
        acctype =  typecode;
        singleacc = sacc;
        syncflag = sflag;
        CntID = cid;
        try{
          accountstoNotsync = new set<id>();
            dataObjList = ObtainDataObjectsForWSSynchronization(accountIdSet);
            system.debug('Data Object : '+dataObjList.size()+' : '+dataObjList);
            BuildAndSendPayload(dataObjList);
        } catch(System.Exception ex){
            //at this point, if an exception is thrown at this level, all of the items need to be set to error.
            ExceptionBlock(accountIdSet,ex);
        }
    }
    
    //Added for inserting errors on the accounts which are errored out before paylaod is generated  
    public static void NewExceptionBlock(map<string,list<string>> accset, String msg){
        
        List<Account> lstErrorError = new List<Account>();
        List<LodeStar_Errors__c> lodeStarErrors = new List<LodeStar_Errors__c>();
        list<String> errorAcclst ;
        
        for(Account a:[SELECT 
                        Id, LodeStar_Integration_Status__c, Short_Code__c, RecordType.name
                      FROM Account
                      WHERE Id IN :accset.keyset()]){
            a.LodeStar_Integration_Status__c = 'ERROR';
            lstErrorError.add(a);
            errorAcclst = accset.get(a.id);
            String errorSep ='';
            Integer i = 1;
            for(String str : errorAcclst){
                if(a.RecordType.name == 'C&I Customer'){
                    errorSep += i+'.'+str + '\n' ;
                    i++;
                }
                else{
                    errorSep += str;
                }
            }
            lodeStarErrors.add(new LodeStar_Errors__c(
                Account__c = a.Id,
                ErrorMsg__c = msg+''+errorSep,
                ExceptionTime__c = Datetime.now(),
                ShortCode__c = a.Short_Code__c
            ));
        }
        if(!lstErrorError.isEmpty()) update lstErrorError;
        if(!lodeStarErrors.isEmpty()) insert lodeStarErrors;
    }
    
    /**
     *This method is to remove special characters from name 
    **/
    public static string removeSpecialCharacters(String tempName){
        tempName = tempName.replaceAll('\\t',' ');
        tempName = tempName.replaceAll('\\s{2,}',' ');
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s-&\']');
        Matcher matcher = nonAlphanumeric.matcher(tempName);
        tempName= matcher.replaceAll('').trim();       
        return tempName;
    } 
    
    public static void ExceptionBlock(set<id> accset,System.Exception ex){
        List<LodeStar_Errors__c> lodeStarErrors = new List<LodeStar_Errors__c>();
        List<Account> accountsToUpdate = new List<Account>();
        for(Account a:[SELECT 
                        Id, LodeStar_Integration_Status__c, Short_Code__c
                      FROM Account
                      WHERE Id IN :accset]){
            a.LodeStar_Integration_Status__c = 'ERROR';
            accountsToUpdate.add(a);
            lodeStarErrors.add(new LodeStar_Errors__c(
                Account__c = a.Id,
                ErrorMsg__c = ex.getMessage() + ' - ' + ex.getStackTraceString(),
                ExceptionTime__c = Datetime.now(),
                ShortCode__c = a.Short_Code__c
            ));
        }
        if(!accountsToUpdate.isEmpty()) update accountsToUpdate;
        if(!lodeStarErrors.isEmpty()) insert lodeStarErrors;
        
        throw new LodeStar.LodeStarException(ex.getMessage(),ex);
    }
    
    /**
     * This method is exposed to determine if there are other Accounts to be synchronized from 
     * the service.
     **/
    public static Boolean NonSynchronizedRecsExist(){
        Set<Id> accountIdSetRemaining = LodeStarActions.ObtainNonSynchronizedAccounts();
        if(accountIdSetRemaining != null && !accountIdSetRemaining.isEmpty())
            return true;
        else
            return false;
    }
    
}