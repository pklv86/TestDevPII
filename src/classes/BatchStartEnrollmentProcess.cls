/* 
 * Name: BatchStartEnrollmentProcess
 * Type: Apex Class
 * Test Class: BatchSetEnrollmentProcessTest
 * Description:  This batch job populates the Enrollment Date on LDC Accounts when contracts are set to Process. 
 * Change History: Bindu: modified to send batch statistics to send thru mail
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Kartheek Akkineni         02/05/2016       1. Initial Version created
 */
global class BatchStartEnrollmentProcess implements Database.Batchable<sObject>,Database.Stateful {
    
     String query;
     global final set<Id> IdstoEnroll;
     global boolean IsMuniAgg;
     global final Map<Id,Contract> enrollCntrctMap;
     global Integer dasrListcount;
     global Integer LDCListcount;
     global map<String,String> LDCBillErrorMap;
     global integer LDCProcessCount;
     //global final set<string> LDC_STATUS =new Set<string> {'NEW_ACCOUNT','ACTIVE'};
    
    global BatchStartEnrollmentProcess(Set<id> enrollIds, Boolean IsMuni, Map<Id,Contract> cntrctMap) {
        enrollCntrctMap=cntrctMap;
        IdstoEnroll=enrollIds;
        IsMuniAgg=IsMuni;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query=EnrollmentHandler.LDC_ENROLL_QUERY;
        system.debug('Test : '+enrollCntrctMap+' : '+IdstoEnroll);
        if(IsMuniAgg){
            query+=' Where Opt_Out__c=false and Account__r.Business_Account__c in :IdstoEnroll and (contract__c!=null or contract__c != \'\')';//and LDC_Account_Status__c in : LDC_STATUS 
        }else{
            query+=' Where Id in :IdstoEnroll';
        }
        system.debug('Query : '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        set<string> cntset = new set<string>();
        string cntsetstr = '(\'';
        for(Contract cnt : enrollCntrctMap.values()){
            cntset.add(cnt.contractnumber);
            cntsetstr += cnt.contractnumber+'\',\'';
        }
        cntsetstr = cntsetstr.substring(0,cntsetstr.length()-2);
        cntsetstr += ')';
        system.debug('Contract set : '+cntset+' : '+cntsetstr);
        
        List<LDC_Account__c> Lst=(List<LDC_Account__c>)scope; 
        system.debug('Before LDC : '+Lst.size());
        List<LDC_Account__c> ldcList = new list<LDC_Account__c>();
        if(IsMuniAgg){
            for(Ldc_account__c ldc : Lst){
                if(cntset.contains(ldc.contract__c)){
                    ldcList.add(ldc);
                }
            }
        }
        else{
            ldcList.addAll(Lst);
        }
        system.debug('After LDC : '+ldcList.size());
        EnrollmentHandler.DASRBillErrorListSend dasrListBillError=new EnrollmentHandler.DASRBillErrorListSend();
        
        dasrListBillError = EnrollmentHandler.CreateDASRRequestforLDCs(ldcList,enrollCntrctMap);
        List<DASR_Request__c> dasrList=new List<DASR_Request__c>();
        dasrList.addall(dasrListBillError.dasrsList);
        
        if(dasrListcount==null)
            dasrListcount=0;
        if(LDCListcount==null)
            LDCListcount=0;
        if(LDCBillErrorMap==null)
            LDCBillErrorMap = new map<String,String>();
        if(LDCProcessCount==null)
            LDCProcessCount = 0;
   
        dasrListcount+= (integer)dasrList.size();
        LDCListcount+=ldcList.size();
        LDCBillErrorMap.putall(dasrListBillError.LDCToBillCycleErrorMap);
        LDCProcessCount+=dasrListBillError.LDCsProcessedCount;
        if(!dasrList.isEmpty())
            Database.Upsert(dasrList);

        for(contract ct:enrollCntrctMap.values()){
            ct.Enrollment_Stage__c='Processed';
            
        }
        Database.update(enrollCntrctMap.values());
        
        if(IsMuniAgg){
            List<ldc_account__c> ldclst=new List<ldc_account__c>();
            set<id> ldcset =new set<id>();
            if(!dasrList.isEmpty()){
                for(dasr_request__c dasr : dasrList){
                    ldcset.add(dasr.ldc_account__c);
                }
            }
            if(!ldcset.isempty()){
                for(ldc_account__c ldc : [select id,name,contract__c,Opt_out__c from ldc_account__c where id IN : ldcset]){
                    ldc.contract__c = '';
                    ldc.opt_out__c = false;
                    ldclst.add(ldc);
                }
            }
            if(!ldclst.isempty()) update ldclst;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        BatchUtility.sendAsyncApexJobExceptionEmails( BC.getJobId());
        system.debug('@@@@@@ Finishing Batch'); 
        system.debug('@@@@@@ ldc size'+LDCListcount); 
        system.debug('@@@@@@ dasr size'+dasrListcount);
        String billErrorMsg;
        if(LDCBillErrorMap.size()>0)
        {
            billErrorMsg = 'Please note for below LDC accounts ContractLDC/DASR not created as Bill Cycle key not found'+'\n\t '+'Count : '+LDCBillErrorMap.size()+'\n\t ';
            for(String LDCNumber: LDCBillErrorMap.Keyset())
            {
            billErrorMsg+=LDCNumber+' : '+LDCBillErrorMap.get(LDCNumber)+'\n\t';
            }
        }
        else
        {
            billErrorMsg = '';
        }   
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Enrollment Batch Completion Intimation');
        mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 


        mail.setPlainTextBody('Dear '+UserInfo.getName()+','
                                + '\n\nYour Enrollment batch for contract Number:'+ enrollCntrctMap.values().ContractNumber+' has been completed successfully.'
                                +'\n\tPlease note below key stats from process:'
                                +'\n\t Total LDC records picked by Job:'+ LDCListcount
                                +'\n\t Total LDC records picked for Processing : '+ LDCProcessCount
                                +'\n\t Total DASR/ContractLDC created:' + dasrListcount
                                + '\n\t'+billErrorMsg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        }
}