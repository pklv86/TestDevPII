/* 
 * Name: batchPurgeSobjectEntries
 * Type: Apex Class
 * Test Class: batchPurgeSobjectEntriesTest
 * Description:  This batch class purges the sObject records based on the custom setting 'PurgeSobjectSettings'. 
 * To schedule the batch to run every hour at 15 minutes use the below comand.
 *      system.schedule('PurgeSobjectEntries', '0 15 * * * ?', new batchPurgeSobjectEntries()) 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti        02/27/2016       1. Initial Version created
 */

global class batchPurgeSobjectEntries implements Schedulable, Database.Batchable<sobject>, Database.Stateful  {
    
    global boolean reRun = false;
    global  integer sequence;
    global string strQuery = '';
    global String sObjectName='';
    
    global void execute(SchedulableContext SC) {
        batchPurgeSobjectEntries batch = new batchPurgeSobjectEntries(1); 
        Id batchId = Database.executeBatch(batch,2000);          
    }
    
    public batchPurgeSobjectEntries(Integer option){
        sequence = option;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        sObjectName='';
        strQuery = '';
        String whereClause = '';
        Integer historyDays; 
        for (PurgeSobjectSettings__c item : PurgeSobjectSettings__c.getAll().values()) {
            if(item.Enable_Purge__c && item.order__c == sequence) 
                sObjectName = item.Name;
        }
        if(sObjectName !=''){
            PurgeSobjectSettings__c psRec = PurgeSobjectSettings__c.getInstance(sObjectName);
            if(psRec != null){
                historyDays = (psRec != null && psRec.Save_History__c != null)?Integer.ValueOf(psRec.Save_History__c):30;
                whereClause = (psRec != null && psRec.Where_Clause__c != null)?String.ValueOf(psRec.Where_Clause__c):'';
                
                strQuery = 'Select Id from ' + sObjectName;             
                whereClause = (whereClause != '')?((historyDays > 0)?(' Where '+whereClause+ ' AND CreatedDate != LAST_N_DAYS:'+historyDays):(' Where '+whereClause)):((historyDays > 0)?' where CreatedDate != LAST_N_DAYS:'+historyDays:'');
                strQuery += whereClause;
                system.debug('Query : '+strQuery);
                return database.getQueryLocator(strQuery);
            }
        }
        return database.getQueryLocator('Select id from muni_agg__c where id=\'a0H000000000000\'');
        
    }
    
    global void execute(Database.BatchableContext ctx, list<sObject> scope) {
        /*list<sObject> lstDeleteRecords = new list<sObject>();
        
        PurgeSobjectSettings__c psRec;
        String strQuery = '';
        String whereClause = '';
        Integer historyDays;        
        
        for(string strObjectName : lstsObjectName) {
            psRec = PurgeSobjectSettings__c.getInstance(strObjectName);
            historyDays = (psRec != null && psRec.Save_History__c != null)?Integer.ValueOf(psRec.Save_History__c):30;
            whereClause = (psRec != null && psRec.Where_Clause__c != null)?String.ValueOf(psRec.Where_Clause__c):'';
            
            strQuery = 'Select Id from ' + strObjectName;               
            whereClause = (whereClause != '')?(historyDays > 0)?' Where '+whereClause+ ' AND CreatedDate != LAST_N_DAYS:'+historyDays:' Where '+whereClause:(historyDays > 0)?' where CreatedDate != LAST_N_DAYS:'+historyDays:'';
            strQuery += whereClause;
                                    
            list<sObject> slst = database.query(strQuery);
            if(slst.size() < 1000){
                lstDeleteRecords.addAll(slst);
            }
            else{
                for(integer i=0 ; i< 1000 ; i++)
                    lstDeleteRecords.add(slst[i]);
                reRun = true;
                break;
            }
        }
        delete lstDeleteRecords;*/
        /*if(sObjectName == 'Muni_Agg__c'){
            list<muni_agg__c> malst =(list<muni_agg__c>)scope;
            system.debug('MA batch'+malst.size());
            delete malst;
        }
        else if(sObjectName == 'Mass_Market__c'){
            list<Mass_Market__c> mmlst =(list<Mass_Market__c>)scope;
            system.debug('MA batch'+mmlst.size());
            delete mmlst;
        }*/
        delete scope;
    }
    
    global void finish(Database.BatchableContext ctx) {
        
        system.debug('Test Finish : '+strQuery);
        integer sobjectcount = integer.valueof(system.label.Purge_Sobject_Count);
        system.debug('sobjectcount : '+sobjectcount);
        if(sequence < sobjectcount){
        	sequence++;
        	system.debug('sequence : '+sequence);
            batchPurgeSobjectEntries batch = new batchPurgeSobjectEntries(sequence); 
            Id batchId = Database.executeBatch(batch,2000);
        }
        
        /*if(reRun) {
             Database.executebatch(new batchPurgeSobjectEntries());
        }*/
    }
} 
 
/* 
global class batchPurgeSobjectEntries implements Database.Batchable<string>, Database.Stateful  {
    
    global boolean reRun = false;
    global String strSObjectList;
    
    global batchPurgeSobjectEntries(string strPurgeList){
        strSObjectList = strPurgeList;
    }
    
    global Iterable<string> start(Database.BatchableContext ctx) {
        list<String> sObjectNameLst = new list<String>();
        sObjectNameLst = (strSObjectList != null && strSObjectList != '')?strSObjectList.split(';'):null;
        return sObjectNameLst;
    }
    
    global void execute(Database.BatchableContext ctx, list<string> lstsObjectName) {
        list<sObject> lstDeleteRecords = new list<sObject>();
        
        PurgeSobjectSettings__c psRec;
        String strQuery = '';
        Integer historyDays;        
        
        for(string strObjectName : lstsObjectName) {
            psRec = PurgeSobjectSettings__c.getInstance(strObjectName);
            historyDays = (psRec != null && psRec.Save_History__c != null)?Integer.ValueOf(psRec.Save_History__c):30;
            if(!Test.isRunningTest()){              
                strQuery = (historyDays > 0)?'Select Id from ' + strObjectName + ' where CreatedDate != LAST_N_DAYS:'+historyDays:'Select Id from ' + strObjectName;                    
            }           
            else{
                strQuery = 'Select Id from ' + strObjectName + ' LIMIT 1';
            }
            for(sObject objsObject : database.query(strQuery)) {
                if(lstDeleteRecords.size() < 9)
                    lstDeleteRecords.add(objsObject);
                else {
                    reRun = true;
                    break;
                }
            }
        }       
        delete lstDeleteRecords;
    }
    
    global void finish(Database.BatchableContext ctx) {
        if(reRun) {
             Database.executebatch(new batchPurgeSobjectEntries(strSObjectList));
        }
    }
}
*/
