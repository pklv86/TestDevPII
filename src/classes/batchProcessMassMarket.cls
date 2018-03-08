/* 
 * Name: batchProcessMassMarket
 * Type: Apex Class
 * Test Class: batchProcessMassMarketTest
 * Description:  This batch class process the stagging data from Mass_Market__c object to create Accounts and LDC accounts. 
 * To schedule the batch to run every hour at 00 minutes use the below comand.
 *      system.schedule('ProcessMassMarket', '0 0 * * * ?', new batchProcessMassMarket()) 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti        03/09/2016       1. Initial Version created
 */
global class batchProcessMassMarket implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    global ID recAccId;
    global String usrEmail;
    global String usrName;
    global Integer recPicked;
    global Integer recProcessed;
    //Static final String billCycle = '1';
    global set<id> ldcset;
        
    global void execute(SchedulableContext SC) {
        batchProcessMassMarket batch = new batchProcessMassMarket(); 
        Id bId = Database.executeBatch(batch,200);           
    }
    
    @RemoteAction
    global static String ProcessMassMarket(){
        String result='';
        batchProcessMassMarket batch = new batchProcessMassMarket(); 
        batch.usrEmail = UserInfo.getUserEmail();
        batch.usrName = UserInfo.getName();
        ID bID = Database.executeBatch(batch,200);
        result = 'Mass Market Batch Initiated Successfully. Batch ID: '+ bID;                                       
        return result;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        recPicked = 0;
        recProcessed = 0;
        recAccId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Mass Market Individual Customer').RecordTypeId;
        
        query = 'SELECT ID, NAME, OWNERID, BILLING_COUNTRY__C, BILLING_STATE_PROVINCE__C, BILLING_STREET__C,Utility_Unique_ID__c,Account_Type_Code__c,'
                        +'BILLING_ZIP_POSTAL_CODE__C, Billing_Address_Line_2__c, Billing_Address_Line_3__c, BILLING__C, EMAIL__C, FIRST_NAME__C, LDC_ACCOUNT_NAME__C,LDC_Receive_Invoices_By__c,'   
                        +'LDC_ACCOUNT_NUMBER__C, LDC_VENDOR__C, Account_Email__c,LAST_NAME__C, PHONE__C, SERVICE_CITY__C,' 
                        +'Mailing_Street__c,   Mailing_Website__c, Mailing_Address_Line_2__c, Mailing_Address_Line_3__c, Mailing_City__c, Mailing_State_Province__c, Mailing_Zip_Postal_Code__c, Mailing_Country__c,'
                        +'SERVICE_COUNTY__C, Grace_CD__c,SERVICE_POSTAL_CODE__C, SERVICE_STATE__C, SERVICE_STREET_1__C,RATE_CODE__C,'  
                        +'SERVICE_STREET_2__C, SERVICE_TERRITORY__C, PROCESSED__C, OFFER_CODE__C, Enrollment_Start_Date__c,'
                        +'Enrollment_Type__c, Promo_Code__c, LDC_Type__c'
                        +' FROM Mass_Market__c WHERE PROCESSED__C = FALSE AND HAS_ERROR__C = FALSE AND OFFER_CODE__C != \'\' AND OFFER_CODE__C != null';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Mass_Market__c> scope) {         
         list<Account> lstSObjAcc = new list<Account>();
         list<LDC_Account__c> lstSObjLDCAcc = new list<LDC_Account__c>();
         list<Contract_LDC__c> lstSObjConLDC = new list<Contract_LDC__c>();
         list<DASR_Request__c> lstSObjDASR = new list<DASR_Request__c>();                  
         list<Mass_Market__c> lstMM = new list<Mass_Market__c>(); 
         list<Mass_Market__c> lstUpdMM = new list<Mass_Market__c>();
         list<LDC_Account__c> rollbackLDCAccount = new list<LDC_Account__c>();
         list<Account> rollbackAccount = new list<Account>();
         list<Contract_LDC__c> rollbackContractLDC = new list<Contract_LDC__c>();
         list<DASR_Request__c> rollbackDASR = new list<DASR_Request__c>();
         map<string,string> mapErrMA = new map<string,string>();
         map<ID,Account> mapParentAcc = new map<ID,Account>();
         list<contract> cntlst = new list<contract>();
         set<id> cntset = new set<id>();
         contract cnt = new contract();
         
         Account refAcc;
         Account recAcc;
         LDC_Account__c recLDC;
         LDC_Account__c refLDC;
         Contract_LDC__c recConLDC;
         set<String> ldcVendorName = new set<String>();
         set<String> ldcAccountNumber = new set<String>();
         set<String> lstOffCode = new set<String>();
         map<ID,ID> mapLDCParentAcc = new map<ID,ID>();         
         set<String> lstCustID = new set<String>();
         map<String,Account> mapAccount = new map<String,Account>();
         map<String,LDC_Vendor__c> mapLDCVendor = new map<String,LDC_Vendor__c>();
         map<String,LDC_Account__c> mapLDCAccount = new map<String,LDC_Account__c>();
         Set<Id> vendorIds=new Set<Id> ();
         ID CustRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Mass Market Offer').RecordTypeId;
         if(ldcset == null)ldcset = new set<id>();
         
         for(Mass_Market__c recMM : scope){
            if(!String.isBlank(recMM.LDC_VENDOR__C) && !ldcVendorName.contains(recMM.LDC_VENDOR__C)) ldcVendorName.add(recMM.LDC_VENDOR__C);
            if(!String.isBlank(recMM.OFFER_CODE__C) && !lstOffCode.contains(recMM.OFFER_CODE__C)) lstOffCode.add(recMM.OFFER_CODE__C);
            if(!String.isBlank(recMM.LDC_ACCOUNT_NUMBER__C) && !ldcAccountNumber.contains(recMM.LDC_ACCOUNT_NUMBER__C)) ldcAccountNumber.add(recMM.LDC_ACCOUNT_NUMBER__C);
         }
         
         system.debug('>>>>> CODE LIST : ' + lstOffCode);
         
         for(Account acc :[select ID, OFFER_CODE__C, Supplier__c,Billing_Entity__c, (select Id,Name,Rate_Code__c,StartDate,End_Date__c,Enrollment_Request_Date__c,Account.RecordType.Name,Account.Billing_Entity__c,Bill_Method__c from Contracts order by createddate desc) from Account where OFFER_CODE__C IN :lstOffCode AND RecordTypeID = :CustRecTypeId]){
            mapAccount.put(acc.OFFER_CODE__C,acc);
         }
         system.debug('>>>>> ACC MAP : ' + mapAccount);
         
         for(LDC_Vendor__c ldcv :[select id, name,Utility_Code__c from LDC_Vendor__c where name IN :ldcVendorName]){
            mapLDCVendor.put(ldcv.name,ldcv);
            vendorIds.add(ldcv.Id);
         }
         
         
         for(LDC_Account__c la :[select Id, LDC_Account_Number__c,LDC_Account_Status__c,External_Reference_ID__c,Bill_Cycle__c,LDC_VENDOR__r.Utility_Code__c,Rate_Code__c,Service_Territory__c,Ldc_Vendor__c,Account__c,Account__r.Billing_Entity__c from LDC_Account__c where LDC_Account_Number__c IN :ldcAccountNumber]){
            mapLDCAccount.put(la.LDC_Account_Number__c,la);
            mapLDCParentAcc.put(la.id, la.Account__c);
            vendorIds.add(la.LDC_VENDOR__C);
         }

        Map<string,Bill_Cycle_Date__c> vendorBillMap=new Map<string,Bill_Cycle_Date__c>(EnrollmentHandler.getBillcycleData(vendorIds));

         //mapParentAcc = new Map<ID, Account>([select ID, Mass_Market_Offer__c, External_Reference_ID__c from Account where ID IN :mapLDCParentAcc.values()]);
         mapParentAcc = new Map<ID, Account>([select ID, Business_Account__c, External_Reference_ID__c from Account where ID IN :mapLDCParentAcc.values()]);
         for(Mass_Market__c recMM : scope){             
             recAcc = new Account();
             recLDC = new LDC_Account__c();
             recMM.Has_Error__c = FALSE;
             try{
                 if(mapAccount.get(recMM.OFFER_CODE__C) == null){
                    recMM.Has_Error__c = TRUE;
                    recMM.Error_Message__c = 'No Mass Market Offer account found for Offer Code:' + recMM.OFFER_CODE__C;
                 }
                 else if(!String.isBlank(recMM.LDC_ACCOUNT_NUMBER__C) && mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C) != null
                    && mapAccount.get(recMM.OFFER_CODE__C) != null){
                     //Create DASR Request and Contract LDC  Related to LDC Account
                    if((mapAccount.get(recMM.OFFER_CODE__C).Contracts.size() > 0)){
                                               
                        if(EnrollmentHandler.LDC_NEW_STATUS.contains(mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C).LDC_Account_Status__C))
                        {
                            lstSObjDASR.add(EnrollmentHandler.createEnrollDASR(mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C),vendorBillMap,mapAccount.get(recMM.OFFER_CODE__C).Contracts[0],true));
                            lstSObjConLDC.add(EnrollmentHandler.createMMarketContractLdc(mapAccount.get(recMM.OFFER_CODE__C).Contracts[0],mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C),recMM));
                        }
                        else if(EnrollmentHandler.LDC_ENROLL_STATUS==mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C).LDC_Account_Status__C)
                        {
                            lstSObjDASR.add(EnrollmentHandler.createChangeDASR(mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C),vendorBillMap,mapAccount.get(recMM.OFFER_CODE__C).Contracts[0],true));
                            lstSObjConLDC.add(EnrollmentHandler.createMMarketContractLdc(mapAccount.get(recMM.OFFER_CODE__C).Contracts[0],mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C),recMM));
                        }
                        system.debug('Test : '+mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].id+' : '+cntset);
                        if(!cntset.contains(mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].id)){
                            cntset.add(mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].id);
                            cnt.id = mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].id;
                            cnt.Enrollment_Request_Date__c = Date.today();
                        }
                        else{
                            cnt.Enrollment_Request_Date__c = Date.today();
                        }
                        cntlst.add(cnt);
                        
                     }else{
                        recMM.Has_Error__c = TRUE;
                        recMM.Error_Message__c = 'No Contract found on the account associated with Offer Code : '+recMM.OFFER_CODE__C;                       
                     }  
                    
                 }
                 else if(recMM.LAST_NAME__C != null && recMM.LAST_NAME__C != ''){
                     refAcc = new Account(External_Reference_ID__c = recMM.Name);
                     recAcc.External_Reference_ID__c = recMM.Name;
                     recAcc.BillingStreet = recMM.BILLING_STREET__C + ', ' + recMM.Billing_Address_Line_2__c +', ' +recMM.Billing_Address_Line_3__c;
                     recAcc.BillingCity = recMM.BILLING__C;
                     recAcc.BillingState = recMM.BILLING_STATE_PROVINCE__C;
                     recAcc.BillingCountry = recMM.BILLING_COUNTRY__C; 
                     recAcc.BillingPostalCode = recMM.BILLING_ZIP_POSTAL_CODE__C;
                     recAcc.PersonMailingStreet = recMM.MAILING_STREET__C;
                     recAcc.Mailing_Address_Line_2__c = recMM.Mailing_Address_Line_2__c;
                     recAcc.Mailing_Address_Line_3__c = recMM.Mailing_Address_Line_3__c ;
                     recAcc.PersonMailingCity = recMM.MAILING_CITY__C;
                     recAcc.PersonMailingState = recMM.MAILING_STATE_PROVINCE__C;
                     recAcc.PersonMailingCountry = recMM.MAILING_COUNTRY__C; 
                     recAcc.PersonMailingPostalCode = recMM.MAILING_ZIP_POSTAL_CODE__C;   
                     recAcc.Mailing_Website__c = recMM.Mailing_Website__c;
                     recAcc.PersonEmail = recMM.EMAIL__C;
                     recAcc.PersonHomePhone = recMM.PHONE__C;
                     recAcc.FirstName = recMM.FIRST_NAME__C;
                     recAcc.LastName = recMM.LAST_NAME__C;
                     recAcc.recordTypeID = recAccId;
                     system.debug('>>>>> Checking For : ' + recMM.OFFER_CODE__C);
                     system.debug('>>>>> Value : ' + mapAccount.get(recMM.OFFER_CODE__C));
                     //recAcc.Mass_Market_Offer__c = mapAccount.get(recMM.OFFER_CODE__C).Id;
                     recAcc.Business_Account__c = mapAccount.get(recMM.OFFER_CODE__C).Id;
                     recAcc.Supplier__c = mapAccount.get(recMM.OFFER_CODE__C).Supplier__c;
                     recAcc.OWNERID = recMM.OWNERID;
                     recAcc.Billing_Entity__c = mapAccount.get(recMM.OFFER_CODE__C).Billing_Entity__c;
                 
                     if((recMM.LDC_ACCOUNT_NUMBER__C != null && recMM.LDC_ACCOUNT_NUMBER__C != '') || (recMM.Utility_Unique_ID__c != null && recMM.Utility_Unique_ID__c != '')){
                         refLDC = new LDC_Account__c(External_Reference_ID__c = recMM.Name);
                         recLDC.External_Reference_ID__c = recMM.Name;
                         recLDC.Account__r = refAcc;
                         if(recMM.FIRST_NAME__C ==null)
                            recLDC.Name = recMM.LAST_NAME__C;
                         else
                            recLDC.Name = recMM.FIRST_NAME__C + ' ' + recMM.LAST_NAME__C;
                         //recLDC.Name = recMM.LDC_ACCOUNT_NUMBER__C;
                         //recLDC.LDC_Account_Number__c = recMM.LDC_ACCOUNT_NUMBER__C;
                          recLDC.LDC_Account_Number__c = (recMM.LDC_ACCOUNT_NUMBER__C != null && recMM.LDC_ACCOUNT_NUMBER__C != '' && !string.isblank(recMM.LDC_ACCOUNT_NUMBER__C))?recMM.LDC_ACCOUNT_NUMBER__C: recMM.Utility_Unique_ID__c;
                         //recLDC.LDC_Account_Number__c = recMM.LDC_ACCOUNT_NUMBER__C;
                         // Added SCR 1289
                         recLDC.Billing_Street__c = recMM.BILLING_STREET__C;
                         recLDC.Billing_Address_Line_2__c = recMM.Billing_Address_Line_2__c;
                         recLDC.Billing_Address_Line_3__c = recMM.Billing_Address_Line_3__c;
                         recLDC.Billing_City__c = recMM.BILLING__C;
                         recLDC.Billing_State_Province__c = recMM.BILLING_STATE_PROVINCE__C;
                         recLDC.Billing_Country__c = recMM.BILLING_COUNTRY__C;
                         recLDC.Billing_Zip_Postal_code__c = recMM.BILLING_ZIP_POSTAL_CODE__C;
                    
                         //SCR 1289 
                         recLDC.Account_Type_Code__c = recMM.Account_Type_Code__c;
                         recLDC.Service_City__c = recMM.SERVICE_CITY__C;
                         recLDC.Service_County__c = recMM.SERVICE_COUNTY__C;
                         recLDC.Service_Postal_Code__c = recMM.SERVICE_POSTAL_CODE__C;
                         recLDC.Service_State__c = recMM.SERVICE_STATE__C;
                         recLDC.Service_Street_1__c = recMM.SERVICE_STREET_1__C;
                         recLDC.Service_Street_2__c = recMM.SERVICE_STREET_2__C;
                         recLDC.Service_Territory__c = recMM.SERVICE_TERRITORY__C;
                         recLDC.LDC_Receive_Invoices_By__c = recMM.LDC_Receive_Invoices_By__c;
                         recLDC.Account_Email__c = recMM.Account_Email__c;
                         recLDC.Grace_CD__c = recMM.Grace_CD__c;
                         recLDC.LDC_Type__c = recMM.LDC_Type__c;
                         recLDC.Utility_Unique_ID__c = recMM.Utility_Unique_ID__c;
                         recLDC.Rate_Code__c = (mapAccount.get(recMM.OFFER_CODE__C).Contracts.size() > 0)?mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].Rate_Code__c:'';
                         
                         if(recMM.LDC_VENDOR__C != null && mapLDCVendor.get(recMM.LDC_VENDOR__C) != null){
                            recLDC.LDC_Vendor__c=mapLDCVendor.get(recMM.LDC_VENDOR__C).Id;
                            recLDC.LDC_Vendor__r = mapLDCVendor.get(recMM.LDC_VENDOR__C); 
                         }
                         else{
                            recMM.Has_Error__c = TRUE;
                            recMM.Error_Message__c = 'LDC Vendor '+recMM.LDC_VENDOR__C+' Does not exist. Please provide a valid LDC Vendor';
                         }  
                         //Create DASR Request and Contract LDC  Related to LDC Account
                         
                         if((mapAccount.get(recMM.OFFER_CODE__C).Contracts.size() > 0)){
                            
                            lstSObjDASR.add(EnrollmentHandler.createEnrollDASR(recLDC,vendorBillMap,mapAccount.get(recMM.OFFER_CODE__C).Contracts[0],true));
                            lstSObjConLDC.add(EnrollmentHandler.createMMarketContractLdc(mapAccount.get(recMM.OFFER_CODE__C).Contracts[0],(recLDC != null?recLDC:mapLDCAccount.get(recMM.LDC_ACCOUNT_NUMBER__C)),recMM));
                            
                            if(!cntset.contains(mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].id)){
                            cntset.add(mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].id);
                            cnt.id = mapAccount.get(recMM.OFFER_CODE__C).Contracts[0].id;
                            cnt.Enrollment_Request_Date__c = Date.today();
                            }
                            else{
                                cnt.Enrollment_Request_Date__c = Date.today();
                            }
                         cntlst.add(cnt);
                         }
                         else{
                            recMM.Has_Error__c = TRUE;
                            recMM.Error_Message__c = 'No Contract found on the account associated with Offer Code : '+recMM.OFFER_CODE__C;                       
                         }  
                     }
                     else{
                        recMM.Has_Error__c = TRUE;
                        recMM.Error_Message__c = 'Invalid LDC Account Number '+recMM.LDC_ACCOUNT_NUMBER__C+'. Please provide a valid value';
                     }
                 }
                 else{
                    recMM.Has_Error__c = TRUE;
                    recMM.Error_Message__c = 'Customer Last Name Missing. It\'s a mandatory Field.';                
                 }
             }
             catch(Exception ex){
                recMM.Has_Error__c = TRUE;
                recMM.Error_Message__c = 'Exception : ' + ex.getMessage();
             }
             
             if(!recMM.Has_Error__c){
                recMM.Processed__c = TRUE;
                recMM.Has_Error__c = False;
                recMM.Error_Message__c = '';
                lstSObjAcc.add(recAcc);
                lstSObjLDCAcc.add(recLDC);
             }
             lstMM.add(recMM);
                        
         }
         system.debug('>>>>> INSERTING ACCOUNTS: ');
         if(!lstSObjAcc.isEmpty()){
            List<Database.UpsertResult> saveResults = Database.upsert(lstSObjAcc, false);
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
            List<Database.UpsertResult> saveResults = Database.upsert(lstSObjLDCAcc, false);
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
            
         if(!lstSObjConLDC.isEmpty()){
            List<Database.UpsertResult> saveResults = Database.upsert(lstSObjConLDC, false);
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
         }
         system.debug('>>>>> ERROR MAP Final: ' + mapErrMA);
         system.debug('*****lstSObjDASR****'+lstSObjDASR);
         if(!lstSObjDASR.isEmpty()){
            List<Database.UpsertResult> saveResults = Database.upsert(lstSObjDASR, false);            
         }
         
       /*  
         // Comented this code since roll back is no more required
         //Search for the Related Account and LDC Accounts and Contract LDC which need to be rolled back due to failed transactions.
         for(Account a :[select ID from Account where External_Reference_ID__c IN :mapErrMA.keySet()]){
            rollbackAccount.add(a);             
         } 
         for(LDC_Account__c la :[select ID from LDC_Account__c where External_Reference_ID__c IN :mapErrMA.keySet()]){
            rollbackLDCAccount.add(la);             
         } 
         for(Contract_LDC__c lc :[select ID from Contract_LDC__c where External_Reference_ID__c IN :mapErrMA.keySet()]){
            rollbackContractLDC.add(lc);            
         }
         for(DASR_Request__c da :[select ID from DASR_Request__c where LDC_Account__c = null AND createdDate = Today]){
            rollbackDASR.add(da);           
         }
         
        
         
         system.debug('>>>> Deleting LDC Accounts : ' + rollbackLDCAccount);
         if(!rollbackLDCAccount.isEmpty()) delete rollbackLDCAccount;
         system.debug('>>>> Deleting Accounts : ' + rollbackAccount);
         if(!rollbackAccount.isEmpty()) delete rollbackAccount;
         system.debug('>>>> Deleting Contract LDC : ' + rollbackContractLDC);
         if(!rollbackContractLDC.isEmpty()) delete rollbackContractLDC;
         system.debug('>>>> Deleting DASR : ' + rollbackDASR);
         if(!rollbackDASR.isEmpty()) delete rollbackDASR;
         */
         
         for(Mass_Market__c recMM : lstMM){
            recPicked += 1;
            if(mapErrMA.get(recMM.Name) != null){
                recMM.Processed__c = False;
                recMM.Has_Error__c = True;
                recMM.Error_Message__c = mapErrMA.get(recMM.Name);
            }
            else{
                recProcessed += 1;
            }
            
            lstUpdMM.add(recMM);    
         }
         
         if(!lstUpdMM.isEmpty())
            update lstUpdMM;                
         
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug('@@@@@@ Finishing Batch');  
        /*
        List<String> batchEmails = new List<String>();
        batchEmails.add(usrEmail);
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        List<Messaging.Singleemailmessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailMessage.setSubject('Batch Completion Intimation');
        emailMessage.setPlainTextBody('Dear '+usrName+','
                                        + '\n\nYour batch has completed successfully.'
                                        + '\nKindly find below the key stats from the batch execution:'
                                        + '\n\tRecords picked for processing: ' + recPicked
                                        + '\n\tRecords processed successfully: ' + recProcessed
                                        + '\n\nThank you,'
                                        + '\nSFDC Admin');
        emailMessage.setToAddresses(batchEmails);
        emailMessage.setSaveAsActivity(false);
        emailList.add(emailMessage);
        system.debug('>>>>>> EMAIL : \n' + emailMessage);
        
        try{    
            if(!emailList.isEmpty() && !Test.isRunningTest()){   
                system.debug('@@@@@@ Sending Email : ' + emailList);                
                Messaging.SendEmailResult [] emailResults = Messaging.sendEmail(emailList);
            }
        }catch(Exception ex){
            system.debug('@@@@@@ Exception : ' + ex.getMessage());
        }*/
        if(!ldcset.isempty()){
            LDCAccountTriggerHandler ldchandler = new LDCAccountTriggerHandler();
            ldchandler.updateLDCIndividualInfo(ldcset);
        }
    }
}