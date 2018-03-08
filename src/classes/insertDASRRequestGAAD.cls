global class insertDASRRequestGAAD implements Database.batchable<sObject>{
    String query;
    global insertDASRRequestGAAD(){}
    global insertDASRRequestGAAD(String q) {
       query = q;
   }
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select LDC_Account__c, DASR_Type__c, Most_Recent_GAAD__c, Contract__c, Integration_Status__C, LDC_Account__r.LDC_Account_Status__c, LDC_Account__r.opt_out__c, LDC_Account__r.LDC_Vendor__r.Service_State__c, change_effective_date__c from DASR_Request__c where (LDC_Account__r.opt_out__c = true and LDC_Account__r.LDC_Vendor__r.Service_State__c LIKE \'%IL%\' and (Integration_Status__C = \'Waiting For Response\' or Integration_Status__C = \'Complete\') and DASR_Type__c = \'GAAE\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<string, DASR_Request__c>dasrRecMap = new Map<string, DASR_Request__c>();
   //   Map<string, DASR_Request__c>dasrRecMapforGAAD = new Map<string, DASR_Request__c>();
        Map<string, LDC_Account__c>ldcAccountMap = new Map<string, LDC_Account__c>();
   //   Map<string, Contract_LDC__c>contractLdcMap = new Map<string, Contract_LDC__c>();
        set<string> ldcAccountIdSet = new set<string>();
        set<string> checkForAccountStatus = new set<string>();
        Map<string, boolean>boolMap = new Map<string, boolean>();
        set<string>addaccountId = new set<string>();
        List<DASR_Request__c> accountIdForAccountStatus = new List<DASR_Request__c>();
        for(sobject s : scope){
            ldcAccountIdSet.add(String.valueOf(s.get('LDC_Account__c')));
            if(String.valueOf(s.get('DASR_Type__c')) == 'GAAE'){
                checkForAccountStatus.add(String.valueOf(s.get('LDC_Account__c')));
            }
        }
        List<LDC_Account__c> ldcAccountList = [select id, opt_out__c, LDC_Account_Status__c from LDC_Account__c where id in: ldcAccountIdSet];
        List<DASR_Request__c> DASRtyGAADList = [select id, ldc_Account__c, LDC_Account__r.LDC_Account_Status__c, Drop_Date__c from DASR_Request__c where LDC_Account__c in: ldcAccountIdSet and DASR_Type__c ='GAAD'];
           
        for(LDC_Account__c ldc : ldcAccountList){
            ldcAccountMap.put(ldc.id,ldc);
        }
        
        for(DASR_Request__c dar : DASRtyGAADList){
            boolMap.put(dar.Ldc_Account__c,true);
        }
        
        List<DASR_Request__c> dasrList = new List<DASR_Request__c>();
        DASR_Request__c dasrObj;
        for(sobject s : scope){
            if(!boolMap.containskey(String.valueOf(s.get('LDC_Account__c')))){
                if(!addaccountId.contains(String.valueOf(s.get('LDC_Account__c')))){
                    if(ldcAccountMap.get(String.valueOf(s.get('LDC_Account__c'))).opt_out__c == true && (String.valueOf(s.get('Integration_Status__C')) == 'Waiting For Response' || String.valueOf(s.get('Integration_Status__C')) == 'Complete') && String.valueOf(s.get('DASR_Type__c')) == 'GAAE'){
                        Date dt = date.today();
                        Date dt1 = date.valueOf(s.get('change_effective_date__c'));
                        System.debug('==================dt value=================' +dt);
                        System.debug('==================dt1 value=================' +dt1);
                        Integer dte = dt.daysBetween(dt1);
                        System.debug('==================dte value=================' +dte);
                        if(dte>=5){
                            addaccountId.add(String.valueOf(s.get('LDC_Account__c')));
                            dasrObj = new DASR_Request__c();
                            dasrObj.DASR_Type__c = 'GAAD'; 
                            dasrObj.LDC_Account__c = String.valueOf(s.get('LDC_Account__c'));
                            dasrObj.Contract__c = String.valueOf(s.get('Contract__c'));
                        //  dasrObj.Contract__c = contractLdcMap.get(s.get('LDC_Account__c'));
                        //  dasrObj.Drop_Reason__c = null;
                        //  dasrObj.Drop_Reason_Description__c = null;
                            dasrObj.DASR_Submit_Date__c = date.today();
                            dasrObj.Drop_Date__c= date.today();
                            dasrObj.billing_Entity__c ='Dynegy';
                            dasrObj.Dynegy_Initiated__c = true;
                            dasrList.add(dasrObj);
                        }
                     }
                  }
               } 
          }
          insert dasrList;
    }   
    global void finish(Database.BatchableContext BC){
    }   
}