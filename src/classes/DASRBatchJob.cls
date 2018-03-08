/* 
 * Name: DASRBatchJob
 * Type: Apex Class
 * Test Class: DASRBatchJob_test
 * Description:  This batch job is to check the change effective dates & back dated DASR submit dates are triggered. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu         06/16/2016       1. Initial Version created
 * 2.0         Prasad Paladugu         07/22/2016       1. Automate the Process based on change effective date
 * 3.0         Prasad Paladugu         10/10/2017       1. Upgrade the process for more effeciency
 */
global class DASRBatchJob implements System.Schedulable,Database.Batchable<sObject>,Database.Stateful{
    
    String Query;
    String QueryDate;
    list<id> DasrId;
    global final Date DatetoProcess;
    global final Integer recordstotal;
    global set<id> errset;
    Integer counter=0;
    global integer aggregatesize;
    
    global void execute (SchedulableContext sc){
        system.debug('Starting auto.......');
        list<aggregateresult> result = [select count(id),Change_Effective_Date__c from dasr_request__c where Accepted__c = true and Dynegy_Initiated__c = true and ((Integration_Status__c = 'Complete'
                                            and Most_recent_gaad__c = true) or (Integration_Status__c = 'Manually Fulfilled' and ldc_account__r.service_territory__c = 'ComEd-IL')) 
                                            and createdby.name != 'Integration User' and DASR_Type__c = 'GAAC' and DASR_Activated__c = false and Change_Effective_Date__c <= today 
                                            group by Change_Effective_Date__c
                                            order by Change_Effective_Date__c limit 20 ];
        system.debug('Result : '+result.size()+' : '+result);
        if(!result.isempty()){
            string dateres =string.valueof(result[0].get('Change_Effective_Date__c'));
            system.debug('dateres : '+dateres);
            DASRBatchJob Dasr = new DASRBatchJob(Date.valueof(result[0].get('Change_Effective_Date__c')),1,new set<id>());//Integer.valueof(result[0].get('expr0'))
            Database.executeBatch(Dasr,100);
            system.debug('dateres : '+dateres);
        }
    }
     
    public DASRBatchJob(){ 
        
    }
    
    public DASRBatchJob(Date dt, Integer total,set<id> idset){
        DatetoProcess = dt;
        recordstotal = total;
        errset = idset;
    }
    
    global Database.QueryLocator Start(Database.BatchableContext bc){ 
        
        system.debug('Date : '+DatetoProcess);
        Query  = ConstantUtility.getObjectFieldsQuery('DASR_Request__c') + ',ldc_account__r.LDC_Account_Status__c,ldc_account__r.service_territory__c From DASR_Request__c  where Dynegy_Initiated__c = true AND Accepted__c = true AND ';
        Query += '((Integration_Status__c = \'Complete\' and Most_recent_gaad__c = true)  OR (Integration_Status__c = \'Manually Fulfilled\'  and ldc_account__r.service_territory__c = \'ComEd-IL\')) AND createdby.name != \'Integration User\' AND DASR_Type__c = \'GAAC\' AND DASR_Activated__c = false AND Change_Effective_Date__c = : DatetoProcess';
        system.debug('Query : '+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, list<sObject> scope){
        
        dasrId = new list<id>();
        set<id> cntid = new set<id>();
        set<id> accldcid = new set<id>();
        set<id> cntsetInActive = new set<id>();
        list<contract_ldc__c> cntsetActive = new list<contract_ldc__c>();
        list<DASR_Request__c> dasrlst = (list<DASR_Request__c>)scope;
        list<DASR_Request__c> finaldasrlst = new list<DASR_Request__c>();
        list<DASR_Request__c> dasrreload = new list<DASR_Request__c>();
        list<DASR_Request__c> dasrignorelst = new list<DASR_Request__c>();
        set<id> dasrignore = new set<id>();
        set<id> ldcaccountstoupdateset = new set<id>();
        list<LDC_Account__c> ldcaccountstoupdate = new list<LDC_Account__c>();
        list<id> cLDCTempId = new list<id>();
        map <id,Dasr_Request__c> dasrmap = new map<id,Dasr_request__c>();
        map <id,Date> dasrContractEffectiveDate = new map<id,Date>();
        if(errset == null)
            errset = new set<id>();
            
        system.debug('List size : '+ dasrlst.size());
        for(DASR_Request__C dasr : dasrlst){
            
            if(dasr.ldc_account__r.LDC_Account_Status__c == 'PENDING_FINAL' || dasr.ldc_account__r.LDC_Account_Status__c == 'FINAL'){
                dasrignore.add(dasr.id);
            }
            else{
                if(dasr.Integration_Status__c == 'Complete'){
                    cntid.add(dasr.contract__c);
                    accldcid.add(dasr.LDC_Account__c);
                }
                if(dasr.Integration_Status__c == 'Manually Fulfilled' && dasr.ldc_account__r.service_territory__c == 'ComEd-IL'){
                    cntid.add(dasr.contract__c);
                    accldcid.add(dasr.LDC_Account__c);
                }
                dasrmap.put(dasr.id,dasr);
                string currentldcaccount = dasr.ldc_account__c;
                dasrContractEffectiveDate.put(dasr.contract__c,dasr.Change_Effective_Date__c);
                for(dasr_request__c innerdasr : [select id,name,Change_Effective_Date__c,DASR_Activated__c,Most_recent_gaad__c from dasr_request__c 
                                                    where ldc_account__c =: currentldcaccount AND createdby.name != 'Integration User'  AND Dynegy_Initiated__c = true 
                                                    AND Accepted__c = true AND ((Integration_Status__c = 'Complete' and Most_recent_gaad__c = true) 
                                                    OR (Integration_Status__c = 'Manually Fulfilled' and ldc_account__r.service_territory__c = 'ComEd-IL'))]){
                    if(innerdasr.Change_Effective_Date__c > dasr.Change_Effective_Date__c){
                        innerdasr.DASR_Activated__c=false;
                        innerdasr.Most_recent_gaad__c = true;
                        dasrreload.add(innerdasr);
                    }                                       
                }
                system.debug('dasrreload : '+dasrreload.size()+' : '+dasrreload);
            }
        }
        
        system.debug('Dasr lst : '+dasrlst.size());
        for(Integer i=0;i<dasrlst.size();i++){
            if(dasrignore.contains(dasrlst[i].id)){
                dasrlst[i].DASR_Activated__c = true;
                dasrlst[i].Most_recent_gaad__c = false;
                dasrignorelst.add(dasrlst[i]);
                system.debug('Removing DASR : '+dasrlst[i]);
                dasrlst.remove(i);
                i--;
            }
        }
        if(!dasrignorelst.isempty()) update dasrignorelst;
        system.debug('Dasr lst : '+dasrlst.size());
        
        if(!dasrreload.isempty()) update dasrreload;
        system.debug('Contract size : '+cntid.size()+' : '+cntid);
        system.debug('LDC Account size : '+accldcid.size()+' : '+accldcid);
        system.debug('DASR Map  size : '+dasrmap.size()+' : '+dasrmap);
        for(Contract_LDC__c cLDC : [select id,name,Contract__c,Active__c,IsSynchronized__c,LDC_Account__c,Rate_Code__c,Term_Start_Date__c,Term_Stop_Date__c,Contract__r.End_Date__c 
                                        From Contract_LDC__c  
                                        where Contract__c IN : cntid AND LDC_Account__c IN : accldcid]){
            if(cLDC.Active__c == false){
                cntsetInActive.add(cLDC.Contract__c); 
            }
            else{
                system.debug('Term_Start_Date__c : '+cLDC.Term_Start_Date__c+' : '+dasrContractEffectiveDate.get(cLDC.contract__c));
                if(cLDC.Term_Start_Date__c != dasrContractEffectiveDate.get(cLDC.contract__c) && dasrContractEffectiveDate.get(cLDC.contract__c) != null){
                    cLDC.Term_Start_Date__c =  DateTime.newInstance(dasrContractEffectiveDate.get(cLDC.contract__c),Time.newInstance(0,0,0,0));
                    if(cLDC.Term_Stop_Date__c != cLDC.contract__r.End_Date__c){
                        system.debug('Term_Stop_Date__c : '+cLDC.Term_Stop_Date__c+' : '+cLDC.contract__r.End_Date__c);
                        cLDC.Term_Stop_Date__c = cLDC.contract__r.End_Date__c;  
                    }
                    cntsetActive.add(cLDC);
                    cLDCTempId.add(cLDC.contract__c);
                    system.debug('Term_Start_Date__c : '+cLDC.Term_Start_Date__c);
                }
            }
        }
        system.debug(' Cnt size InActive : '+cntsetInActive.size()+' Active : '+cntsetActive.size());
        
        for(DASR_Request__C dasr : [select id,name,Contract__c,LDC_Account__c from DASR_Request__c where contract__c IN : cntsetInActive AND LDC_Account__c IN : accldcid]){
            system.debug('Current DASR : '+dasr.id+' : '+dasr.name);
            if(dasrmap.containsKey(dasr.id)){
                dasrId.add(dasr.id);
            }
        }
        system.debug('Final Dasr List : '+dasrId.size()+' : '+dasrId);
        if(!dasrId.isEmpty()) Flow_SetActiveContractLDC.setActiveContractFromDASR(dasrId);
        
        for(DASR_Request__C dasr : [select id,name,Contract__c,LDC_Account__c from DASR_Request__c where contract__c IN : cLDCTempId AND LDC_Account__c IN : accldcid]){
            system.debug(' Active Contract LDC Current DASR : '+dasr.id+' : '+dasr.name);
            if(dasrmap.containsKey(dasr.id)){
                dasrId.add(dasr.id);
            }
        }
        
        //Boolean ldcaccountsmodified;
        for(Dasr_request__c dasr : [select id,name,Contract__c,Contract__r.Bill_Method__c,Contract__r.Interval_Usage__c,Contract__r.Rate_Code__c,ldc_account__r.LDC_Account_Status__c,
                                        LDC_Account__c,LDC_Account__r.Bill_Method__c,LDC_Account__r.Interval_Usage__c,LDC_Account__r.Rate_Code__c,DASR_Activated__c,Most_recent_gaad__c 
                                        From DASR_Request__c where Id IN : dasrId]){
                                        
            dasr.LDC_Account__r.Bill_Method__c = dasr.Contract__r.Bill_Method__c;
            dasr.LDC_Account__r.Interval_Usage__c = dasr.Contract__r.Interval_Usage__c;
            dasr.LDC_Account__r.Rate_Code__c = dasr.Contract__r.Rate_Code__c;
            if(!ldcaccountstoupdateset.contains(dasr.LDC_Account__c)){
                ldcaccountstoupdateset.add(dasr.LDC_Account__c);
                ldcaccountstoupdate.add(dasr.LDC_Account__r);
            }
            dasr.DASR_Activated__c = false;
            dasr.Most_recent_gaad__c = false;
            finaldasrlst.add(dasr);
            //ldcaccountsmodified = true;  
        }
        system.debug('ldcaccountstoupdate : '+ldcaccountstoupdate.size()+' finaldasrlst : '+finaldasrlst.size());
        
        if(!cntsetActive.isEmpty()){
           //update cntsetActive;
           boolean hasError = false;
           list<Database.SaveResult> sResults = Database.update(cntsetActive,false);
           for(Integer i=0;i<sResults.size();i++){
                if(sResults.get(i).isSuccess()){
                    continue;
                }    
                else{
                    Database.Error error = sResults.get(i).getErrors().get(0);
                    system.debug('Error : '+error);
                    hasError = true;
                }
            } 
            
            if(!hasError){
              if(!ldcaccountstoupdate.isempty()) update ldcaccountstoupdate;
            if(!finaldasrlst.isempty()) update finaldasrlst;
            }
        }
       
    }
    
    global void finish(Database.BatchableContext bc){
        
        system.debug('Finish : '+DatetoProcess+' Errset : '+errset+' Loop : '+recordstotal);
        list<aggregateresult> result = [select count(id),Change_Effective_Date__c from dasr_request__c where Accepted__c = true and Dynegy_Initiated__c = true and ((Integration_Status__c = 'Complete'
                                            and Most_recent_gaad__c = true) or (Integration_Status__c = 'Manually Fulfilled'  and ldc_account__r.service_territory__c = 'ComEd-IL')) 
                                            and createdby.name != 'Integration User' and DASR_Type__c = 'GAAC' and DASR_Activated__c = false and Change_Effective_Date__c <= today  
                                            group by Change_Effective_Date__c
                                            order by Change_Effective_Date__c limit 20];
        system.debug('Result : '+result.size()+' : '+result);
        aggregatesize=result.size(); 
        if(!result.isempty()){ 
            System.enqueueJob(new DASRBatchJobAuto(DatetoProcess,recordstotal,errset));
        }
        else{
            if(!errset.isempty()){
                string res='<table border="1"><tr><th>Dasr ID</th><th>Dasr Name</th><th>Change Effective Date</th><th>LDC Account Number</th><th>Contract NUmber</th><th></th></tr><br/>';
                for(dasr_request__c dasr : [select id,name,ldc_account__r.ldc_account_number__c,contract__r.contractnumber,Change_Effective_Date__c from dasr_request__c where id IN : errset]){
                    res+='<tr><td>'+dasr.id+'</td><td>'+dasr.name+'</td><td>'+dasr.Change_Effective_Date__c+'</td><td>'+dasr.ldc_account__r.ldc_account_number__c+'</td><td>'+dasr.contract__r.contractnumber+'</td><td></td></tr>';
                }
                res+='</table>';
                string mailerslst = label.Team_Mail;
                list<string> mailerstr = mailerslst.split(';');
                mailerstr.add(UserInfo.getName());
                    
                list<user> usr = [select id,name,email from user where name IN : mailerstr];
                list<string> mailers = new list<string>();
                for(User U : Usr){
                    mailers.add(u.email);
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(mailers);
                mail.setSubject('Dasr Job result');
                mail.setTargetObjectId(userinfo.getuserid());
                mail.setsaveAsActivity(false); 
                mail.setHtmlBody('Today\'s ('+system.now()+') Dasr Batch Job results are :: \n'+res);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    } 
}