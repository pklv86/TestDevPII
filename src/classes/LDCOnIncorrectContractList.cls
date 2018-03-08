/**
 * This class is designed to provide a report for lDCs on incorrect contract wrt DASR
 *
 * @
 * @version 1.0
 **/

global class LDCOnIncorrectContractList implements Database.Batchable <sobject>,Database.Stateful{

    string query;
    global Document objD1 = new Document();
    
    global String filecontent;
    //fileContent = 'LDCId' + ','+'LDCNumber'+','+'LDC_Account_Status'+','+'DASR.Name'+','+'Change_Effective_Date'+','+'DASR_Type'+','+'DASR.Contract'+','+'Current Contract'+'\n';
    global LDCOnIncorrectContractList( ){
        
    }
 
    global Database.QueryLocator start (Database.BatchableContext bc){
        fileContent = 'LDCId' + ','+'LDCNumber'+','+'LDC_Account_Status'+','+'DASR.Name'+','+'Change_Effective_Date'+','+'DASR_Type'+','+'DASR.Contract'+','+'Current Contract'+'\n';
        query='select id,(select id FROM DASRs__r where Change_Effective_Date__c <= Today and Dynegy_Initiated__c = true AND Accepted__c = true AND Integration_Status__c = \'Complete\' and contract__c != null and DASR_Type__c != null order by Change_Effective_Date__c DESC,DASR_Submit_Date__c DESC LIMIT 1),(select Id from Contract_LDCs__r where Active__C = true LIMIT 1 ) from LDC_Account__C where id IN (select LDC_Account__c from DASR_REQUEST__C where Change_Effective_Date__c <= Today and Dynegy_Initiated__c = true AND Accepted__c = true AND Integration_Status__c = \'Complete\' and contract__c != null and DASR_Type__c != null)';
        
        return Database.getQueryLocator(query);
    }
   
    global void execute (Database.BatchableContext bc, list<sobject> scope ){
        list<LDC_Account__c> LDCList =  (list<LDC_Account__c>) scope;
        set<ID> DASRIds = new set<ID>();
        set<Id> CLDCIds = new set<Id>();
        set<Id> MissingActiveCLDC = new set<Id>();
        Map<Id,DASR_Request__c> LDCIdToDasR = new Map<Id,DASR_Request__c>();
        Map<Id,Contract_LDC__C> LDCIdToCLDC = new Map<Id,Contract_LDC__C>();
        
        for(LDC_Account__c LDC: LDCList)
        {
            Contract_LDC__C CLDC;
            DASR_Request__c DASR = LDC.DASRs__R;
            DASRIds.add(DASR.Id);
            if(LDC.Contract_LDCs__r.size() > 0)
            {
                CLDC = LDC.Contract_LDCs__r;
                CLDCIds.add(CLDC.Id);
            }
            else
            {
                MissingActiveCLDC.add(LDC.Id);
            }
        }
        for(DASR_Request__c DR: [select LDC_Account__c,LDC_Account__r.LDC_Account_Status__C,LDC_Account__r.LDC_Account_Number__C,name,Change_Effective_Date__c,DASR_Type__c,contract__r.contractnumber from DASR_Request__c where Id IN:DASRIds] )
        {
            LDCIdToDasR.put(DR.LDC_Account__c,DR);  
        }
        for(Contract_LDC__C CL:[select LDC_Account__c,contract__r.contractnumber from Contract_LDC__C where Id IN:CLDCIds])
        {
            if(LDCIdToDasR.containskey(CL.LDC_Account__c))
            {
                if(LDCIdToDasR.get(CL.LDC_Account__c).contract__r.contractnumber != CL.contract__r.contractnumber)
                {
                    fileContent+= LDCIdToDasR.get(CL.LDC_Account__c).LDC_Account__c+','+'A'+LDCIdToDasR.get(CL.LDC_Account__c).LDC_Account__r.LDC_Account_Number__C+','+LDCIdToDasR.get(CL.LDC_Account__c).LDC_Account__r.LDC_Account_Status__C+','+LDCIdToDasR.get(CL.LDC_Account__c).Name+','+LDCIdToDasR.get(CL.LDC_Account__c).Change_Effective_Date__c+','+LDCIdToDasR.get(CL.LDC_Account__c).DASR_Type__c+','+LDCIdToDasR.get(CL.LDC_Account__c).contract__r.contractnumber+','+CL.contract__r.contractnumber+'\n';
                }
            }
            
        }
        for(Id LDCid:MissingActiveCLDC)
        {
            fileContent+= LDCIdToDasR.get(LDCid).LDC_Account__c+','+'A'+LDCIdToDasR.get(LDCid).LDC_Account__r.LDC_Account_Number__C+','+LDCIdToDasR.get(LDCid).LDC_Account__r.LDC_Account_Status__C+','+LDCIdToDasR.get(LDCid).Name+','+LDCIdToDasR.get(LDCid).Change_Effective_Date__c+','+LDCIdToDasR.get(LDCid).DASR_Type__c+','+LDCIdToDasR.get(LDCid).contract__r.contractnumber+','+' '+'\n';
        }
        
        
        
    }
    global void finish (Database.BatchableContext bc){
        system.debug('BatchableContext : '+bc);
        objD1.name = 'LDCContractMismatch.csv';
        objD1.body = blob.valueof(fileContent);
        objD1.folderId = UserInfo.getUserId();
        insert objD1;
  
    }
}