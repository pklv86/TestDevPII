global class lodeStarValidator implements Database.Batchable<SObject>,System.Schedulable,Database.Stateful{
    global set<id> accountsNotsync;
    public lodeStarValidator(){       
        
    }
    
    global void execute (SchedulableContext sc){
        lodeStarValidator lsvsc = new lodeStarValidator();
        Database.executeBatch(lsvsc,1000);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        string query ='SELECT Id, LDC_Account__r.Account__c,Contract__c, ldc_account__r.ldc_start_date__c, ldc_account__r.ldc_end_date__c FROM Contract_LDC__c '+
        				'WHERE LDC_Account__r.Account__r.LodeStar_Integration_Status__c = \'Not Synchronized\' AND  Contract__r.Validation__c = \'Validated\' '+
        				'AND (LDC_Account__r.LDC_Account_Status__c=\'ACTIVE\' OR LDC_Account__r.LDC_Account_Status__c=\'FINAL\') AND Term_Start_Date__c != null '+
        				'and issynchronized__c = false order by LDC_Account__r.Account__c'; //AND Term_Start_Date__c <= TODAY 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        
        list<contract_ldc__c> cldclst = (list<contract_ldc__c>)scope;
        list<Account> accountsToUpdate = new list<Account>();
        list<LodeStar_Errors__c> lodeStarErrors = new list<LodeStar_Errors__c>();     
        set<id> Totalaccounts = new set<id>();
        set<id> ldcAccountsError = new set<id>();
        set<id> conLDCAll= new set<id>();
        set<id> ldcAccounts = new set<id>();
        set<id> cntrSet = new set<id>();
        set<id> cntError = new set<id>();   
        set<id> acntError = new set<id>();
        map<id,string> ldcmap = new map<id,string>(); 
        map<id,string> cntmap = new map<id,string>();
        map<id,string> accmap = new map<id,string>();
        string errstr='';
        if(accountsNotsync  == null)
            accountsNotsync = new set<id>();
        for(contract_ldc__c cldc : cldclst){
            ldcAccounts.add(cldc.ldc_account__C);
            conLDCAll.add(cldc.id);
            Totalaccounts.add(cldc.LDC_Account__r.Account__c);
            cntrset.add(cldc.Contract__c);         
        }
        list<contract_ldc__c> conldclst = [select id, term_start_date__C, ldc_account__c,ldc_account__r.account__r.id, issynchronized__c, contract__c from contract_ldc__c where ldc_account__c in :ldcAccounts and issynchronized__c = false and (contract__r.validation__c != 'Validated' or contract__r.validation__c = null)];
        system.debug('conldclst :'+conldclst);
        for(contract_ldc__c clst: conldclst){
            if(!conLDCAll.contains(clst.id)){
                accountsNotsync.add(clst.ldc_account__r.account__r.id);
            }
        }      
        system.debug('Accounts to set Notsync : '+accountsNotsync);
        system.debug(' Contract Set : '+cntrset);
          
        if(!cntrset.isEmpty()){ // update LodeStar_Identifier__c field for Unique identity
            list<contract> cntidentifier = new list<contract>(); 
            for(contract cnt : [select id,name,status,LodeStar_Identifier__c,accountId,account.name,opportunity__r.accountId,opportunity__r.account.name,contractnumber from contract where ID In : cntrset]){              
                if(cnt.opportunity__r.accountId != null && cnt.accountId != cnt.opportunity__r.accountId){
                    cntError.add(cnt.id);
                    errstr+='Contract\'s Account '+cnt.Account.name+' and Contract\'s Opportunity Account '+cnt.opportunity__r.account.name+'are mismatched for contract '+cnt.contractnumber+'\n';
                    system.debug('Contract Has a error : '+cnt.id+' : '+cnt.contractnumber);
                }
                
                if(cnt.status == 'Draft' || cnt.status == 'Cancelled'){
                    cntError.add(cnt.id);
                    errstr+=cnt.status+' status contracts cannot be sent to lodestar '+cnt.contractnumber+'\n';
                }
                
                if(cnt.LodeStar_Identifier__c == null){
                    cnt.LodeStar_Identifier__c=DynegyCommonUtils.generateRandomString(20);
                    cntidentifier.add(cnt);
                }
                cntmap.put(cnt.id,errstr);
            }
            if(!cntidentifier.isempty())  update cntidentifier;
        }
            
        for(contract_ldc__c cldc : cldclst){
            system.debug('Contract : '+cntError.size()+' : '+cntError+'-->'+cldc.contract__c);
            if(cntError.contains(cldc.contract__c)){
                acntError.add(cldc.LDC_Account__r.Account__c);
                accmap.put(cldc.LDC_Account__r.Account__c,cntmap.get(cldc.contract__c));
            }
        }
        system.debug('AccMap : '+accmap);
        system.debug(' Removing Account ID Set : '+acntError.size()+' : '+acntError);

        for(Account a:[SELECT Id, LodeStar_Integration_Status__c, Short_Code__c FROM Account WHERE Id IN :acntError]){
            string msg = accmap.get(a.id);
            a.LodeStar_Integration_Status__c = 'ERROR';
            accountsToUpdate.add(a);
            lodeStarErrors.add(new LodeStar_Errors__c(
                Name = 'Account Error',
                Account__c = a.Id,
                ErrorMsg__c = 'Errored before payload is generated : \n '+msg,
                ExceptionTime__c = Datetime.now(),
                ShortCode__c = a.Short_Code__c
            ));
        }
        if(!accountsToUpdate.isEmpty()) update accountsToUpdate;
        if(!lodeStarErrors.isEmpty()) insert lodeStarErrors;
       
    }
    
    global void finish(Database.BatchableContext bc){
        set<id> processedAccounts = new set<id>();
        AsyncApexJob aJob = new AsyncApexJob();
        system.debug('bid : '+BC.getJobId());
        aJob = [SELECT CompletedDate,CreatedDate,Id,JobItemsProcessed,JobType,LastProcessed,NumberOfErrors,ParentJobId, Status,TotalJobItems FROM AsyncApexJob WHERE Id =: BC.getJobId() ];
        system.debug('AsyncApexJob : '+aJob);
        if(aJob != null && aJob.status == 'Completed'){
            for(account acc : [select id from account where lastmodifieddate >= : aJob.createddate and lastmodifieddate <= : aJob.completedDate and lodestar_integration_status__c = 'ERROR']){
                processedAccounts.add(acc.id);
            }
            set<id> accToProcess = LodeStarActions.ObtainNonSynchronizedAccounts();
            System.debug('accountsNotsync :'+accountsNotsync);
            processedAccounts.addAll(accToProcess);
            if(!accToProcess.isempty() || accToProcess.size() >0){
                System.enqueueJob(new LodeStarIntegrationQueueJob(accToProcess,processedAccounts,accountsNotsync));
            }
            else{
                LodeStarIntegrationProcessor.sendmail(processedAccounts,false);
            }
        }
        else if(aJob == null){
          LodeStarIntegrationProcessor.sendmail(processedAccounts,false);
        }
    }
}