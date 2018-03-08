/* 
 * Name: batchProcessMuniAgg
 * Type: Apex Class
 * Test Class: batchProcessMuniAggTest
 * Description:  This batch class process the stagging data from Muni_Agg__c object to create Accounts and LDC accounts. 
 * To schedule the batch to run every hour at 00 minutes use the below comand.
 *      system.schedule('ProcessMuniAgg', '0 0 * * * ?', new batchProcessMuniAgg()) 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti        02/27/2016       1. Initial Version created
 * 1.1       Prasad             08/17/2016    1. Changed for accepting aggregator code for GAG Muni-agg 
 * 1.2       Chaitanya Kurra    04/17/2017    1.Muni Agg Enrollment form
 */
global class batchProcessMuniAgg implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    global ID recAccId;
    global ID munRecId;
    global String muniAggCustID;
    global String usrEmail;
    global String usrName;
    global Integer recPicked;
    global Integer recProcessed;
    global Integer recError;
    global Integer recDup;
    global Account MuniAggCust;
    global set<id> ldcset;
        
    global void execute(SchedulableContext SC) {
        batchProcessMuniAgg batch = new batchProcessMuniAgg(); 
        Id bId = Database.executeBatch(batch,200);           
    }
    
    webService static String ProcessMuniAgg(String custId){
        String result='';
        if(!String.isBlank(custId)){
            List<Account> lstCustAcc = [Select ID, RecordTypeId from Account where ID = :custId];
            if(!lstCustAcc.isEmpty()){
                ID CustRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Customer').RecordTypeId;
                if(CustRecTypeId != lstCustAcc[0].RecordTypeId){
                    result = 'Invalid Record Type for the selected Record. Please contact administrator.';
                }
                else{
                    batchProcessMuniAgg batch = new batchProcessMuniAgg(); 
                    batch.muniAggCustID = custId; 
                    batch.usrEmail = UserInfo.getUserEmail();
                    batch.usrName = UserInfo.getName();
                    ID bID = Database.executeBatch(batch,200);                  
                    result = 'Muni Agg Batch Initiated Successfully. Batch ID: ' + bID;                                     
                }
            }   
        }
        else{
            result = 'Invalid Customer ID for the selected Record. Please try again or contact administrator.';
        }
        return result;
    }
    
    /* -------------------For  Call Center Access only ------------------------------------------*/
    webService static String MuniAggCC(String custId, ID recId){
        String result='';
        if(!String.isBlank(custId) && recId != null){
            List<Account> lstCustAcc = [Select ID, RecordTypeId from Account where ID = :custId];
            if(!lstCustAcc.isEmpty()){
                ID CustRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Customer').RecordTypeId;
                if(CustRecTypeId != lstCustAcc[0].RecordTypeId){
                    result = 'Invalid Record Type for the selected Record. Please contact administrator.';
                }
                else{
                    batchProcessMuniAgg batch = new batchProcessMuniAgg(); 
                    batch.muniAggCustID = custId; 
                    batch.munRecId = recid;
                    batch.usrEmail = UserInfo.getUserEmail();
                    batch.usrName = UserInfo.getName();
                    ID bID = Database.executeBatch(batch,200);                  
                    result = 'Muni Agg Batch Initiated Successfully. Batch ID: ' + bID;                                     
                }
            }   
        }
        else{
            result = 'Invalid Customer ID for the selected Record. Please try again or contact administrator.';
        }
        return result;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        recPicked = 0;
        recProcessed = 0;
        recError = 0;
        recDup = 0;
        if(String.isBlank(muniAggCustID)){
             query = 'SELECT ID FROM Muni_Agg__c LIMIT 0';
        }
        else{
            recAccId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Individual Customer').RecordTypeId;
            MuniAggCust = [Select id, Supplier__c,Aggregator_Code__c,Muni_Agg_Type__c,Billing_Entity__c from Account where Id = :muniAggCustID];
            query = 'SELECT ID, NAME, OWNERID, BILLING_COUNTRY__C,  BILLING_STATE_PROVINCE__C, Utility_Unique_ID__c, BILLING_STREET__C,Account_Type_Code__c, contract__r.contractnumber,'
                            +'BILLING_ZIP_POSTAL_CODE__C, Billing_Address_Line_2__c,Business_Customer_Name__c, Billing_Address_Line_3__c,  BILLING__C, EMAIL__C,   FIRST_NAME__C,  LDC_ACCOUNT_NAME__C, LDC_Receive_Invoices_By__c,LDC_Account_Name1__c,'   
                            +'LDC_ACCOUNT_NUMBER__C, Opt_Out_Period_Ends__c,  Contract__c, LDC_VENDOR__C, Account_Email__c, LAST_NAME__C,   PHONE__C,   SERVICE_CITY__C,BILL_CYCLE__C,' 
                            +'Mailing_Street__c,   Mailing_Website__c, Mailing_Address_Line_2__c, Mailing_Address_Line_3__c, Mailing_City__c, Mailing_State_Province__c, Mailing_Zip_Postal_Code__c, Mailing_Country__c,'
                            +'SERVICE_COUNTY__C,  Grace_CD__c,  SERVICE_POSTAL_CODE__C, SERVICE_STATE__C, Muni_Agg_CustomerId__c ,  SERVICE_STREET_1__C,RATE_CODE__C,LDC_Type__c,'  
                            +'SERVICE_STREET_2__C,  SERVICE_TERRITORY__C, Service_territory1__c,Rate_CodeContract__c, Legal_Entity_Name__c,  CONTRACT_NUMBER__C, PROCESSED__C, Muni_Agg_Customer_Id__c' 
                            +' FROM Muni_Agg__c WHERE PROCESSED__C = FALSE AND HAS_ERROR__C = FALSE';
            system.debug('munRecId : '+munRecId);
            if(munRecId != null){
              
                query+=' AND ID = :munRecId AND Muni_Agg_CustomerId__c = :muniAggCustID';
                }
            else
                query+=' AND Muni_Agg_Customer_Id__c = :muniAggCustID';
            
        }
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Muni_Agg__c> scope) {         
    	list<Account> lstSObjAcc = new list<Account>();
        list<LDC_Account__c> lstSObjLDCAcc = new list<LDC_Account__c>();
        list<LDC_Account__c> LDCAccDuplst = new list<LDC_Account__c>();
        list<Muni_Agg__c> lstMA = new list<Muni_Agg__c>(); 
        list<Muni_Agg__c> lstUpdMA = new list<Muni_Agg__c>();
        map<string,string> mapErrMA = new map<string,string>();
        list<Account> rollbackAccount = new list<Account>();
        list<LDC_Account__c> rollbackLDCAccount = new list<LDC_Account__c>();
        list<Contract_LDC__c> rollbackContractLDC = new list<Contract_LDC__c>();
        set<String> ldcVendorName = new set<String>();
        set<String> lstContract = new set<String>();
        set<String> lstCustID = new set<String>();
        set<String> ldcAccountNumber = new set<String>();
        set<String> ldcAccountNumberExists = new set<String>();
        map<String,ID> mapLDCVendor = new map<String,ID>();
        map<String,Contract> mapContract = new map<String,Contract>();
        map<String,LDC_Account__c> mapLDC = new map<String,LDC_Account__c>();
         
        Account refAcc;
        Account recAcc;
        LDC_Account__c recLDC;
        LDC_Account__c refLDC;
        string CN;
        boolean duplicateFlag = false;
        
        if(ldcset == null)ldcset = new set<id>();
         
        for(Muni_Agg__c recMA : scope){
        	if(!String.isBlank(recMA.LDC_VENDOR__C) && !ldcVendorName.contains(recMA.LDC_VENDOR__C)) ldcVendorName.add(recMA.LDC_VENDOR__C);
            if(!String.isBlank(recMA.CONTRACT_NUMBER__C) && !lstContract.contains(recMA.CONTRACT_NUMBER__C)) lstContract.add(recMA.CONTRACT_NUMBER__C);
            CN =recMA.Contract__r.ContractNumber;
            system.debug('*** CN***** '+recMA.Contract__r.ContractNumber);
            system.debug('******ContractNumber*****'+CN);
            if((recMA.Contract__c != null) && !lstContract.contains('CN')) lstContract.add(CN);
            if(!String.isBlank(recMA.LDC_ACCOUNT_NUMBER__C) && !ldcAccountNumber.contains(recMA.LDC_ACCOUNT_NUMBER__C)) ldcAccountNumber.add(recMA.LDC_ACCOUNT_NUMBER__C);
            //if(!String.isBlank(recMA.Muni_Agg_Customer_Id__c) && !lstContract.contains(recMA.Muni_Agg_Customer_Id__c)) setMuniAggAccIds.add(recMA.Muni_Agg_Customer_Id__c);
            //if(!lstCustID.contains(recMA.Muni_Agg_Customer_Id__c)) lstCustID.add(recMA.Muni_Agg_Customer_Id__c); 
        }
        system.debug('Test : '+ldcAccountNumber);
        for(LDC_Vendor__c ldcv :[select id, name from LDC_Vendor__c where name IN :ldcVendorName]){
            mapLDCVendor.put(ldcv.name,ldcv.id);
        }
         
        for(Contract c :[select id,ContractNumber,Rate_Code__c,StartDate,EndDate,Opt_Out_End_Date__c from Contract where ContractNumber IN :lstContract]){
            mapContract.put(c.ContractNumber,c);
        } 
         
        for(LDC_Account__c la :[select Id, Account__r.Business_account__c, LDC_Account_Number__c,LDC_Account_Status__c,Contract__c,SERVICE_TERRITORY__C from LDC_Account__c where LDC_Account_Number__c IN :ldcAccountNumber]){
            ldcAccountNumberExists.add(la.LDC_Account_Number__c);
            mapLDC.put(la.LDC_Account_Number__c,la);
        }        
         
        for(Muni_Agg__c recMA : scope){             
        	recAcc = new Account();
            recLDC = new LDC_Account__c();
            recMA.Has_Error__c = FALSE;
            recMA.Duplicate__c = FALSE;
            if(!String.isBlank(recMA.LDC_ACCOUNT_NUMBER__C) && ldcAccountNumberExists.contains(recMA.LDC_ACCOUNT_NUMBER__C) 
                && ((mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).SERVICE_TERRITORY__C == recMA.SERVICE_TERRITORY__C) ||(mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).SERVICE_TERRITORY__C == recMA.Service_territory1__c))) {
            
                recMA.Duplicate__c = TRUE;
           //   recMA.Processed__c = TRUE;
                recMA.Has_Error__c = False;
                recMA.Error_Message__c = 'Duplicate LDC Account';
                if((mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).contract__c == null || mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).contract__c == '') 
                    && (mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).contract__c != recMA.CONTRACT_NUMBER__C || mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).contract__c != CN) && (mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).account__r.business_account__c == recMA.Muni_Agg_Customer_Id__c ||mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C).account__r.business_account__c == recMA.Muni_Agg_CustomerId__c)){
                
                    recMA.Processed__c = TRUE;
                    recMA.Error_Message__c = 'Duplicate LDC Account with different Contract';
                    recLDC = mapLDC.get(recMA.LDC_ACCOUNT_NUMBER__C);
                    if(recLDC.LDC_Account_Status__c == 'FINAL'){
                    	recLDC.LDC_Account_Status__c = 'NEW_ACCOUNT';
                    }
                    recLDC.contract__c = (recMA.CONTRACT_NUMBER__C != null && recMA.CONTRACT_NUMBER__C != '')? recMA.CONTRACT_NUMBER__C : CN ;
                    LDCAccDuplst.add(recLDC);
                }
            }
            else if(recMA.LAST_NAME__C != null && recMA.LAST_NAME__C != ''){
            	refAcc = new Account(External_Reference_ID__c = recMA.Name);
                recAcc.External_Reference_ID__c = recMA.Name;
             // Nanda -03/16/2017- Commented below line and added the code for not populating the null values at Person Account   
             // recAcc.BillingStreet = recMA.BILLING_STREET__C + ', ' + recMA.Billing_Address_Line_2__c +', ' + recMA.Billing_Address_Line_3__c ;                
                if(recMA.Billing_Address_Line_2__c!= null && recMA.Billing_Address_Line_3__c!= null) 
                    recAcc.BillingStreet = recMA.BILLING_STREET__C + ', ' + recMA.Billing_Address_Line_2__c +', ' + recMA.Billing_Address_Line_3__c ;
                else if(recMA.Billing_Address_Line_2__c!= null && recMA.Billing_Address_Line_3__c== null)
                    recAcc.BillingStreet = recMA.BILLING_STREET__C+', ' + recMA.Billing_Address_Line_2__c;
                else if(recMA.Billing_Address_Line_2__c== null && recMA.Billing_Address_Line_3__c!= null)
                    recAcc.BillingStreet = recMA.BILLING_STREET__C+', ' + recMA.Billing_Address_Line_3__c;
                else
                	recAcc.BillingStreet = recMA.BILLING_STREET__C;
                
                recAcc.BillingCity = recMA.BILLING__C;
                recAcc.BillingState = recMA.BILLING_STATE_PROVINCE__C;
                recAcc.BillingCountry = recMA.BILLING_COUNTRY__C;
                recAcc.BillingPostalCode = recMA.BILLING_ZIP_POSTAL_CODE__C;
                recAcc.PersonMailingStreet = recMA.MAILING_STREET__C;
                recAcc.Mailing_Address_Line_2__c = recMA.Mailing_Address_Line_2__c;
                recAcc.Mailing_Address_Line_3__c = recMA.Mailing_Address_Line_3__c ;
                recAcc.PersonMailingCity = recMA.MAILING_CITY__C;
                recAcc.PersonMailingState = recMA.MAILING_STATE_PROVINCE__C;
                recAcc.PersonMailingCountry = recMA.MAILING_COUNTRY__C; 
                recAcc.PersonMailingPostalCode = recMA.MAILING_ZIP_POSTAL_CODE__C;   
                recAcc.Mailing_Website__c = recMA.Mailing_Website__c;
                recAcc.Legal_Entity_Name__c = recMA.Legal_Entity_Name__c ;
                recAcc.PersonEmail = recMA.EMAIL__C;
                recAcc.PersonHomePhone = recMA.PHONE__C;
                recAcc.FirstName = recMA.FIRST_NAME__C;
                recAcc.LastName = recMA.LAST_NAME__C;
                recAcc.recordTypeID = recAccId;
                recAcc.Business_Account__c = (recMA.Muni_Agg_Customer_Id__c != null && recMA.Muni_Agg_Customer_Id__c != '') ? recMA.Muni_Agg_Customer_Id__c : recMA.Muni_Agg_CustomerId__c ;
                //recAcc.Muni_Agg__c = recMA.Muni_Agg_Customer_Id__c;
                recAcc.Supplier__c = MuniAggCust.Supplier__c;
                recAcc.OWNERID = recMA.OWNERID;
                recAcc.Billing_Entity__c = MuniAggCust.Billing_Entity__c;
                recAcc.Aggregator_Code__c = (MuniAggCust.Aggregator_Code__c != null)? MuniAggCust.Aggregator_Code__c : '';
                recAcc.Muni_Agg_Type__c = MuniAggCust.Muni_Agg_Type__c;
             
                if((recMA.LDC_ACCOUNT_NUMBER__C != null && recMA.LDC_ACCOUNT_NUMBER__C != '') || (recMA.Utility_Unique_ID__c != null && recMA.Utility_Unique_ID__c != '')){
                    //refLDC = new LDC_Account__c(LDC_Account_Number__c = recMA.LDC_ACCOUNT_NUMBER__C);
                    refLDC = new LDC_Account__c(External_Reference_ID__c = recMA.Name);
                    recLDC.External_Reference_ID__c = recMA.Name;
                    recLDC.Account__r = refAcc;
                    recLDC.Name = (recMA.LDC_ACCOUNT_NAME__C != null && recMA.LDC_ACCOUNT_NAME__C !='')?recMA.LDC_ACCOUNT_NAME__C : ((recMA.LDC_ACCOUNT_NAME1__C != null && recMA.LDC_ACCOUNT_NAME1__C !='') ? recMA.LDC_Account_Name1__c :recMA.LAST_NAME__C);
                    //recLDC.LDC_Account_Number__c = recMA.LDC_ACCOUNT_NUMBER__C;
                    //recLDC.LDC_Account_Number__c = recMA.LDC_ACCOUNT_NUMBER__C;
                    recLDC.LDC_Account_Number__c = (recMA.LDC_ACCOUNT_NUMBER__C != null && recMA.LDC_ACCOUNT_NUMBER__C != '' && !string.isblank(recMA.LDC_ACCOUNT_NUMBER__C))?recMA.LDC_ACCOUNT_NUMBER__C: recMA.Utility_Unique_ID__c;
                    // Added SCR 1289
                    recLDC.Billing_Street__c = recMA.BILLING_STREET__C;
                    recLDC.Billing_Address_Line_2__c = recMA.Billing_Address_Line_2__c;
                    recLDC.Billing_Address_Line_3__c = recMA.Billing_Address_Line_3__c;
                    recLDC.Billing_City__c = recMA.BILLING__C;
                    recLDC.Billing_State_Province__c = recMA.BILLING_STATE_PROVINCE__C;
                    recLDC.Billing_Country__c = recMA.BILLING_COUNTRY__C;
                    recLDC.Billing_Zip_Postal_code__c = recMA.BILLING_ZIP_POSTAL_CODE__C;
                   
                    //SCR 1289 
                    recLDC.Opt_Out_Period_Ends__c = recMA.Opt_Out_Period_Ends__c != null ? recMA.Opt_Out_Period_Ends__c : ((mapContract.get(recMA.CONTRACT_NUMBER__C) != null ) ? mapContract.get(recMA.CONTRACT_NUMBER__C).Opt_Out_End_Date__c :((mapContract.get(CN) != null)? mapContract.get(CN).Opt_Out_End_Date__c : null));
                    recLDC.Account_Type_Code__c = recMA.Account_Type_Code__c;
                    recLDC.Service_City__c = recMA.SERVICE_CITY__C;
                    recLDC.Service_County__c = recMA.SERVICE_COUNTY__C;
                    recLDC.Service_Postal_Code__c = recMA.SERVICE_POSTAL_CODE__C;
                    recLDC.Service_State__c = recMA.SERVICE_STATE__C;
                    recLDC.Service_Street_1__c = recMA.SERVICE_STREET_1__C;
                    recLDC.Service_Street_2__c = recMA.SERVICE_STREET_2__C;
                    recLDC.Service_Territory__c = (recMA.SERVICE_TERRITORY__C != null && recMA.SERVICE_TERRITORY__C != '') ?  recMA.SERVICE_TERRITORY__C : recMA.SERVICE_TERRITORY1__C;
                    recLDC.Bill_Cycle__c = recMA.Bill_Cycle__c;
                    recLDC.LDC_Receive_Invoices_By__c = recMA.LDC_Receive_Invoices_By__c;
                    recLDC.Account_Email__c = recMA.Account_Email__c;
                    recLDC.Grace_CD__c = recMA.Grace_CD__c;
                    recLDC.LDC_Type__c = recMA.LDC_Type__c;
                    recLDC.Utility_Unique_ID__c = recMA.Utility_Unique_ID__c;
                    recLDC.Rate_Code__c = recMA.Rate_Code__c != null && recMA.Rate_Code__c != '' ? recMA.Rate_Code__c : recMA.Rate_CodeContract__c;   
                    if(recMA.LDC_VENDOR__C != null && mapLDCVendor.get(recMA.LDC_VENDOR__C) != null){
                		recLDC.LDC_Vendor__c = mapLDCVendor.get(recMA.LDC_VENDOR__C);                    
                    }
                    else{
                        recMA.Has_Error__c = TRUE;
                        recMA.Error_Message__c = 'LDC Vendor '+recMA.LDC_VENDOR__C+' Does not exist. Please provide a valid LDC Vendor';
                    }
                    system.debug('Test : '+recMA.CONTRACT_NUMBER__C+' : '+mapContract.get(recMA.CONTRACT_NUMBER__C));
                    system.debug('Test : '+recMA.Contract__c+' : '+mapContract.get(CN));
                    if((recMA.CONTRACT_NUMBER__C != null && mapContract.get(recMA.CONTRACT_NUMBER__C) != null) || (CN != null && CN != '' && mapContract.get(CN) != null)){
                        recLDC.contract__c = recMA.CONTRACT_NUMBER__C != null ? recMA.CONTRACT_NUMBER__C : CN; 
                    }
                    else if((mapContract.get(recMA.CONTRACT_NUMBER__C) == null) && mapContract.get(CN) == null ){
                        recMA.Has_Error__c = TRUE;
                        recMA.Error_Message__c = 'Contract '+recMA.CONTRACT_NUMBER__C+' Does not exist. Please provide a valid contract';
                    }
                    else{
                         recMA.Has_Error__c = TRUE;
                         recMA.Error_Message__c = 'Muni-agg Enrollment requires Contract Number. Please provide a valid contract';
                    }
                    system.debug('recLDC : '+recLDC);
                }
                else{
                    recMA.Has_Error__c = TRUE;
                    recMA.Error_Message__c = 'Invalid LDC Account Number '+recMA.LDC_ACCOUNT_NUMBER__C+'. Please provide a valid value';
                }
            }
            else{
                recMA.Has_Error__c = TRUE;
                recMA.Error_Message__c = 'Customer Last Name Missing. It\'s a mandatory Field.';                
            }
            
            if(!recMA.Has_Error__c && !recMA.Duplicate__c){
                recMA.Processed__c = TRUE;
                recMA.Has_Error__c = False;
                recMA.Error_Message__c = '';
                lstSObjAcc.add(recAcc);
                lstSObjLDCAcc.add(recLDC);
                //lstSObjConLDC.add(recConLDC);
            }
             
            if(recMA.Duplicate__c ){
             	duplicateFlag = true;
            }
            lstMA.add(recMA);
        }
		
		if(duplicateFlag && !LDCAccDuplst.isempty()) update LDCAccDuplst;    
		    
        system.debug('>>>>> INSERTING ACCOUNTS: ');
        if(!lstSObjAcc.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(lstSObjAcc, false);
            for(Integer i=0;i<saveResults.size();i++){
                if(saveResults.get(i).isSuccess()){
                	continue;
                }    
                else{
                    Database.Error error = saveResults.get(i).getErrors().get(0);
                    if(!String.isBlank(lstSObjAcc.get(i).External_Reference_ID__c)) mapErrMA.put(lstSObjAcc.get(i).External_Reference_ID__c, 'Failed Creating Account: ' + error.getMessage());
                }
            }
            //insert lstSObjAcc;
        }
        system.debug('>>>>> ERROR MAP After Account Creation: ' + mapErrMA);
        system.debug('>>>>> INSERTING LDC ACCOUNTS: ');
         
        if(!lstSObjLDCAcc.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(lstSObjLDCAcc, false);
            for(Integer i=0;i<saveResults.size();i++){
                if(saveResults.get(i).isSuccess()){
                    ldcset.add(saveResults.get(i).getId());
                    continue;
                }    
                else{
                    Database.Error error = saveResults.get(i).getErrors().get(0);
                    if(!String.isBlank(lstSObjLDCAcc.get(i).External_Reference_ID__c) && mapErrMA.get(lstSObjLDCAcc.get(i).External_Reference_ID__c) == null)
                        mapErrMA.put(lstSObjLDCAcc.get(i).External_Reference_ID__c, 'Failed Creating LDC Account: ' + error.getMessage());                  
                }
            }           
            //insert lstSObjLDCAcc;
        }
        system.debug('>>>>> ERROR MAP After LDC Account Creation: ' + mapErrMA);        
            
         /*if(!lstSObjConLDC.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(lstSObjConLDC, false);
            for(Integer i=0;i<saveResults.size();i++){
                if(saveResults.get(i).isSuccess()){
                    continue;
                }    
                else{
                    Database.Error error = saveResults.get(i).getErrors().get(0);
                    if(!String.isBlank(lstSObjConLDC.get(i).External_Reference_ID__c) && mapErrMA.get(lstSObjConLDC.get(i).External_Reference_ID__c) == null)
                        mapErrMA.put(lstSObjConLDC.get(i).External_Reference_ID__c, 'Failed Creating Contract LDC: ' + error.getMessage());
                }
            } 
            //insert lstSObjConLDC;
         }*/
        system.debug('>>>>> ERROR MAP Final: ' + mapErrMA);
         
        //Search for the Related Account and LDC Accounts and Contract LDC which need to be rolled back due to failed transactions.
        for(Account a :[select ID from Account where External_Reference_ID__c IN :mapErrMA.keySet()]){
        	rollbackAccount.add(a);             
        } 
        for(LDC_Account__c la :[select ID from LDC_Account__c where External_Reference_ID__c IN :mapErrMA.keySet()]){
            rollbackLDCAccount.add(la);             
        }           
        /*for(Contract_LDC__c lc :[select ID from Contract_LDC__c where External_Reference_ID__c IN :mapErrMA.keySet()]){
            rollbackContractLDC.add(lc);            
        }*/
         
        system.debug('>>>> Deleting LDC Accounts : ' + rollbackLDCAccount);
        if(!rollbackLDCAccount.isEmpty()) delete rollbackLDCAccount;
        system.debug('>>>> Deleting Accounts : ' + rollbackAccount);
        if(!rollbackAccount.isEmpty()) delete rollbackAccount;
        //system.debug('>>>> Deleting Contract LDC : ' + rollbackContractLDC);
        //if(!rollbackContractLDC.isEmpty()) delete rollbackContractLDC;
         
        /*
        if(!lstSObjAcc.isEmpty())
           insert lstSObjAcc;
        if(!lstSObjLDCAcc.isEmpty())
           insert lstSObjLDCAcc; 
        if(!lstSObjConLDC.isEmpty())
           insert lstSObjConLDC;   
        */
        for(Muni_Agg__c recMA : lstMA){
            recPicked += 1;
            if(mapErrMA.get(recMA.Name) != null){
        		recMA.Processed__c = False;
                recMA.Has_Error__c = True;
                recMA.Error_Message__c = mapErrMA.get(recMA.Name);
            }
            else{
                recProcessed += 1;
            }
            if(recMA.Has_Error__c)
                recError++;
            if(recMA.Duplicate__c)  
                recDup++;
                
            lstUpdMA.add(recMA);    
        }
         
        if(!lstUpdMA.isEmpty())
            update lstUpdMA;                
         
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug('@@@@@@ Finishing Batch');  
        List<String> batchEmails = new List<String>();
        batchEmails.add(usrEmail);
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        List<Messaging.Singleemailmessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailMessage.setSubject('Batch Completion Intimation');
        emailMessage.setPlainTextBody('Dear '+usrName+','
                                        + '\n\nYour batch has completed successfully.'
                                        + '\nKindly find below the key stats from the batch execution:'
                                        + '\n\tRecords picked for processing : ' + recPicked
                                        + '\n\tRecords processed successfully : ' + recProcessed
                                        + '\n\tRecords Errored : ' + recError
                                        + '\n\tRecords Duplicated : ' + recDup
                                        + '\n\nThank you,'
                                        + '\nSFDC Admin');
        emailMessage.setToAddresses(batchEmails);
        emailMessage.setSaveAsActivity(false);
        emailList.add(emailMessage);
        
        try{    
            if(!emailList.isEmpty() && !Test.isRunningTest()){   
                system.debug('@@@@@@ Sending Email : ' + emailList);                
                Messaging.SendEmailResult [] emailResults = Messaging.sendEmail(emailList);
            }
        }catch(Exception ex){
            system.debug('@@@@@@ Exception : ' + ex.getMessage());
        }
        
        if(ldcset != null && !ldcset.isempty()){
            LDCAccountTriggerHandler ldchandler = new LDCAccountTriggerHandler();
            ldchandler.updateLDCIndividualInfo(ldcset);
        }
    }
}