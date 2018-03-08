/**
 * @version 1.0
 * @version 1.1 - Prasad - Modified Code for adding aggregator variables
 **/
global class EDIOutBoundProcesBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts
{
    String q;
    private List<String> errors;
    public set<Id> dsrIdsToProcess;
    
    public List<DASR_Request__c> lstDSRToUpdate;
    
    public List<LDC_Account__c> lstLDCAcctToUpdate;
    
    
    public EDIOutBoundProcesBatch(Set<Id> dsrIds)
    { 
        this.errors = new List<String>();
        dsrIdsToProcess = dsrIds;
        
        lstDSRToUpdate = new List<DASR_Request__c>();
        
        lstLDCAcctToUpdate = new List<LDC_Account__c>();
        
    } 
    public EDIOutBoundProcesBatch()
    { }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        Set<string> state = new set<string>();
        system.debug('Current Time : '+datetime.now().time());
        list<EDIOutbound__c> tlst = EDIOutbound__c.getall().values();
        for(EDIOutbound__c str : tlst){
            if(datetime.now().time().hour() == Integer.valueof(str.time__c) && datetime.now().time().minute() >= Integer.valueof(str.minute__c) && datetime.now().time().minute() <= Integer.valueof(str.minute1__c )){  //datetime.now().time().hour() == 17  && datetime.now().time().minute()
                system.debug('*******time in Custom Setting*******' +str.time__c);
                state.add(str.state__C);
            }
        }  
        system.debug('******All States******' +state); 
        
        q=ConstantUtility.getObjectFieldsQuery('DASR_Request__c') +' From DASR_Request__c where (Integration_Status__c = null OR Integration_Status__c  in (\'Pending\',\'Validation Failed\'))';
        //    Integration_Status__c = \'TEST\' 
        q+='AND DASR_Submit_Date__c !=null AND DASR_Submit_Date__c  <= TODAY AND DASR_Type__c  != null AND Dynegy_Initiated__c = true and Billing_Entity__c = \'Dynegy\'';
        q+=' and ldc_account__r.LDC_Vendor__r.Service_State__c In: state';
        if(dsrIdsToProcess != null && !dsrIdsToProcess.isEmpty())
        {
            q += ' and ID = :dsrIdsToProcess ';
        }
        q += ' order by Originator_Name__c,Recipient_Name__c, CreatedDate ASC ';
        //q = generateSOQLQuery('DASR_Request__c');
        System.debug('q=='+q);
        return Database.getQueryLocator(q);
    }   //public Database.QueryLocator start(Database.BatchableContext BC) 
    

    public void execute(Database.BatchableContext BC, List<Sobject> scope)
    {
        Map<String, Map<String, List<DASR_Request__c>>> mapSupplVendor = new Map<String, Map<String, List<DASR_Request__c>>>();
        //Map<String, Map<String, List<DASR_Request__c>>> mapSupplVendorEnroll = new Map<String, Map<String, List<DASR_Request__c>>>();
        Map<String, Map<String, List<DASR_Request__c>>> mapSupplVendorChange = new Map<String, Map<String, List<DASR_Request__c>>>();
        Map<String, Map<String, List<DASR_Request__c>>> mapSupplVendorDrop = new Map<String, Map<String, List<DASR_Request__c>>>();
        
        
        Map<String, List<DASR_Request__c>> mapVendDasr;
        
        List<DASR_Request__c> lDASRSumm;
        
        Set<String> sSuppDuns = new Set<String>(); 
        Set<String> sRecDuns = new Set<String>(); 
        
        
        Set<ID> sSupplIds = new Set<ID>();
        Set<ID> sLDCAcctIds = new Set<ID>();
        Set<ID> sMeterIds = new Set<ID>();
        Set<ID> sCustIds = new Set<ID>();
        Set<ID> sVendIds = new Set<ID>();
        Set<ID> sContractIds = new Set<ID>();
        
        List<DASR_Request__c> lToProcess = (List<DASR_Request__c>) scope;
        Integer totNumRecords = lToProcess.size();
        System.debug('\n totNumRecords='+totNumRecords);
        set<id> ldcidupdate = new set<id>();
        
        List<DASR_Request__c> lDASREnroll = new List<DASR_Request__c>(); 
        List<DASR_Request__c> lDASRChange = new List<DASR_Request__c>(); 
        List<DASR_Request__c> lDASRDrop = new List<DASR_Request__c>(); 
        //Added for Dynegy initiated GAAR
        List<DASR_Request__c> lDASRReinstate = new List<DASR_Request__c>(); 
        for(DASR_Request__c tSummary : lToProcess)
        {
            sSuppDuns.add(tSummary.Originator_DUNS__c);
            sRecDuns.add(tSummary.Recipient_DUNS__c);
            sLDCAcctIds.add(tSummary.LDC_Account__c);
            sContractIds.add(tSummary.Contract__c);
            //sMeterIds.add(tSummary.Meter_Reference__c);
            sSupplIds.add(tSummary.Supplier_ID__c );
            sCustIds.add(tSummary.Customer_Id__c);
            sVendIds.add(tSummary.Vendor_Id__c );
            
            if(tSummary.DASR_Type__c == EDIConstantUtil.DASR_TYPE_ENROL)
            {   
                lDASREnroll.add(tSummary);
                
            }
            else if(tSummary.DASR_Type__c == EDIConstantUtil.DASR_TYPE_CHANGE)
            {
                lDASRChange.add(tSummary);
                
            }
            else if(tSummary.DASR_Type__c == EDIConstantUtil.DASR_TYPE_DROP)
            {
                lDASRDrop.add(tSummary);    
            }
            //Added for Dynegy initiated GAAR
            else if(tSummary.DASR_Type__c == EDIConstantUtil.DASR_TYPE_REINSTAT)
            {
                lDASRReinstate.add(tSummary);
            }
        }
        System.debug('\n map=='+mapSupplVendor);
        string ldcQuery=ConstantUtility.getObjectFieldsQuery('LDC_Account__c') +',account__r.Aggregator_Code__c,Account__r.Muni_Agg_Type__c,account__r.RecordType.name,LDC_Vendor__r.Utility_Code__c From LDC_Account__c where id=:sLDCAcctIds' ;
        Map<Id,LDC_Account__c> ldcAccntMap = new Map<Id,LDC_Account__c>((List<LDC_Account__c>)Database.Query(ldcQuery));
        Set<Id> sLDCIds = new Set<Id>();
        Set<Id> sContIds = new Set<Id>();
        if(ldcAccntMap != null && !ldcAccntMap.isEmpty())
        {
            sLDCIds.addAll(ldcAccntMap.keySet());
        }
        
        string supplQuery=ConstantUtility.getObjectFieldsQuery('Supplier__c') +' From Supplier__c where id=:sSupplIds' ;
        Map<Id,Supplier__c> supplMap = new Map<Id,Supplier__c>((List<Supplier__c>)Database.Query(supplQuery));
        
        
        string meterQuery=ConstantUtility.getObjectFieldsQuery('Meter__c') +' ,Service_Point__r.LDC_Account_Number__c From Meter__c where Service_Point__r.LDC_Account_Number__c = :sLDCAcctIds' ;
        List<Meter__c> meterList = ((List<Meter__c>)Database.Query(meterQuery));
        Map<Id, List<Meter__c>> meterMap = new Map<Id,List<Meter__c>>();
        
        if(meterList != null && !meterList.isEmpty())
        {   
            List<Meter__c> myMeter;
            for(Meter__c tMeter : meterList)
            {
                myMeter = meterMap.get(tMeter.Service_Point__r.LDC_Account_Number__c);
                if(myMeter == null)
                {
                    myMeter = new List<Meter__c>();
                }
                myMeter.add(tMeter);
                
                meterMap.put(tMeter.Service_Point__r.LDC_Account_Number__c, myMeter);
            }
        }
        
        //Map<Id, List<Meter__c>> meterMap = new Map<Id,List<Meter__c>>(); 
        
        string custQuery=ConstantUtility.getObjectFieldsQuery('Account') +',Business_Account__r.Aggregator_Code__c,Business_Account__r.Muni_Agg_Type__c,Business_Account__r.RecordType.name From Account where id=:sCustIds' ;
        Map<Id,Account> custMap = new Map<Id,Account>((List<Account>)Database.Query(custQuery));
        
        /**
        string contractLDCQuery=ConstantUtility.getObjectFieldsQuery('Contract_LDC__c') +' From Contract_LDC__c where LDC_Account__c  =:sLDCIds' ;
        
        Map<Id,Contract_LDC__c> contractLDCMap = new Map<Id,Contract_LDC__c>((List<Contract_LDC__c>)Database.Query(contractLDCQuery));
        Map<Id, Set<Id>> mapLDCIdContId = new Map<Id, Set<Id>>();
        
        Set<Id> sLDContractId;
        if(contractLDCMap != null && !contractLDCMap.isEmpty())
        {
            for(Contract_LDC__c tCL : contractLDCMap.values())
            {
                sContIds.add(tCL.Contract__c);
                sLDContractId = mapLDCIdContId.get(tCL.LDC_Account__c);
                if(sLDContractId == null)
                {
                    sLDContractId = new Set<Id>();
                }
                sLDContractId.add(tCL.Contract__c);
                
                mapLDCIdContId.put(tCL.LDC_Account__c, sLDContractId);
            }
        }
        **/
        
        string contractQuery=ConstantUtility.getObjectFieldsQuery('Contract') +' From Contract where Id =:sContractIds' ;
        Map<Id,Contract> contractMap = new Map<Id,Contract>((List<Contract>)Database.Query(contractQuery));
        
        sContractIds = contractMap != null ? contractMap.keySet() : null;
        
        string contractTermQuery=ConstantUtility.getObjectFieldsQuery('Contract_Term__c') +' From Contract_Term__c where Contract__c =:sContractIds AND Contract__c != null ' ;
        List<Contract_Term__c> contractTermList = ((List<Contract_Term__c>)Database.Query(contractTermQuery));
        Map<Id, List<Contract_Term__c>> contractTermMap = new Map<Id,List<Contract_Term__c>>();
        
        if(contractTermList != null && !contractTermList.isEmpty())
        {   
            List<Contract_Term__c> myCT;
            for(Contract_Term__c tList : contractTermList)
            {
                myCT = contractTermMap.get(tList.Contract__c);
                if(myCT == null)
                {
                    myCT = new List<Contract_Term__c>();
                }
                myCT.add(tList);
                
                contractTermMap.put(tList.Contract__c, myCT);
            }
        }
        
        string vendorQuery=ConstantUtility.getObjectFieldsQuery('LDC_Vendor__c') +' From LDC_Vendor__c where Id =:sVendIds' ;
        Map<Id,LDC_Vendor__c> vendorMap = new Map<Id,LDC_Vendor__c>((List<LDC_Vendor__c>)Database.Query(vendorQuery));
        
        
        List<DASR_Request__c> lstToUpdate = new List<DASR_Request__c>();
        List<LDC_Account__c> lstLDCAcctToUpd = new List<LDC_Account__c>();
        LDC_Account__c tLDC;
        Map<String, List<DASR_Request__c>> mapTSuppDasr;
        //List<DASR_Request__c> lstVendDasr;
        List<DASR_Request__c> lstVendDasrInt = new List<DASR_Request__c>();
        List<DASR_Request__c> lstValErrorsDasr = new List<DASR_Request__c>();
        
        Integer trasnNumber = 0;
        
        //lstVendDasrInt = new List<DASR_Request__c>();
        //Validate outbound XML
        //Enroll messages in one group
        for(DASR_Request__c myDASR:lDASREnroll)
        {
            List<String> errList = EDIOutBoundProcesBatch.validateRequest(myDASR,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap);
            if(errList != null && !errList.isEmpty())
            {
                myDASR.Validation_Message__c  = String.join(errList, '\n');
                myDASR.Integration_Status__c  = 'Validation Failed';
                myDASR.Integration_Message__c = null;
                lstToUpdate.add(myDASR);
            }
            else
            {
                lstVendDasrInt.add(myDASR);
            }
        }
        if(lstVendDasrInt != null && !lstVendDasrInt.isEmpty())
        {
            trasnNumber+=1;
            System.debug('\n trasnNumber='+trasnNumber);
            
            String res = EDIOutboundHelper.sendDASRUpdates(lstVendDasrInt,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap,(lstVendDasrInt.size() * 7 + 2),lstVendDasrInt.size());
            
            lstToUpdate.addAll(populateRespnse(lstVendDasrInt, res));
            
            if(res == null || res.equalsIgnoreCase('DONE'))
            {
                for(DASR_Request__c tDR : lstVendDasrInt)
                {
                    tLDC = tDR.LDC_Account__c != null && ldcAccntMap.get(tDR.LDC_Account__c) != null ? ldcAccntMap.get(tDR.LDC_Account__c) : null;
                    if(tLDC != null)
                    {
                        tLDC.LDC_Account_Status__c = 'PENDING_ENROLLMENT' ;
                        if(!ldcidupdate.contains(tLDC.id))
                            {
                                ldcidupdate.add(tLDC.id);
                                lstLDCAcctToUpd.add(tLDC);
                            }
                    }
                }
            }
        }
        
        //Changes messages in one group
        lstVendDasrInt = new List<DASR_Request__c>();
        for(DASR_Request__c myDASR:lDASRChange)
        {
            List<String> errList = EDIOutBoundProcesBatch.validateRequest(myDASR,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap);
            if(errList != null && !errList.isEmpty())
            {
                myDASR.Validation_Message__c  = String.join(errList, '\n');
                myDASR.Integration_Status__c  = 'Validation Failed';
                myDASR.Integration_Message__c = null;
                lstToUpdate.add(myDASR);
            }
            else
            {
                lstVendDasrInt.add(myDASR);
            }
        }
        
        if(lstVendDasrInt != null && !lstVendDasrInt.isEmpty())
        {
            trasnNumber+=1;
            System.debug('\n trasnNumber='+trasnNumber);
            
            //TEMP Comment
            String res = EDIOutboundHelper.sendDASRUpdates(lstVendDasrInt,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap,totNumRecords,lstVendDasrInt.size());
            lstToUpdate.addAll(populateRespnse(lstVendDasrInt, res));
            //End of temp 
        }
        
        //Drop messages in one group
        lstVendDasrInt = new List<DASR_Request__c>();
        for(DASR_Request__c myDASR:lDASRDrop)
        {
            List<String> errList = EDIOutBoundProcesBatch.validateRequest(myDASR,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap);
            if(errList != null && !errList.isEmpty())
            {
                myDASR.Validation_Message__c  = String.join(errList, '\n');
                myDASR.Integration_Status__c  = 'Validation Failed';
                myDASR.Integration_Message__c = null;
                lstToUpdate.add(myDASR);
            }
            else
            {
                lstVendDasrInt.add(myDASR);
            }
        }
        if(lstVendDasrInt != null && !lstVendDasrInt.isEmpty())
        {
            trasnNumber+=1;
            System.debug('\n trasnNumber='+trasnNumber);
            
            String res = EDIOutboundHelper.sendDASRUpdates(lstVendDasrInt,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap,(lstVendDasrInt.size() * 7 + 2),lstVendDasrInt.size());
           
            lstToUpdate.addAll(populateRespnse(lstVendDasrInt, res));
        }
                        
        //Added for Dynegy GAAR 
        lstVendDasrInt = new List<DASR_Request__c>();
        for(DASR_Request__c myDASR:lDASRReinstate)
        {
            List<String> errList = EDIOutBoundProcesBatch.validateRequest(myDASR,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap);
            if(errList != null && !errList.isEmpty())
            {
                myDASR.Validation_Message__c  = String.join(errList, '\n');
                myDASR.Integration_Status__c  = 'Validation Failed';
                myDASR.Integration_Message__c = null;
                lstToUpdate.add(myDASR);
            }
            else
            {
                lstVendDasrInt.add(myDASR);
            }
        }
        if(lstVendDasrInt != null && !lstVendDasrInt.isEmpty())
        {
            trasnNumber+=1;
            System.debug('\n trasnNumber='+trasnNumber);
            
            String res = EDIOutboundHelper.sendDASRUpdates(lstVendDasrInt,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap,(lstVendDasrInt.size() * 7 + 2),lstVendDasrInt.size());
            
            lstToUpdate.addAll(populateRespnse(lstVendDasrInt, res));
        }

        System.debug('\n lstToUpdate='+lstToUpdate);
        database.update(lstToUpdate,false);
        database.update(lstLDCAcctToUpd, false);
        
    }
    public void finish(Database.BatchableContext BC)
    {       
        
        
    } 
    public static List<String> validateRequest(DASR_Request__c tDASR,Map<Id,LDC_Account__c> ldcAccntMap,Map<Id,Supplier__c> supplMap,Map<Id,LDC_Vendor__c > vendorMap,Map<Id, List<Meter__c>> meterMap,Map<Id,Account> custMap,Map<Id,Contract> contractMap, Map<Id, List<Contract_Term__c>> contractTermMap)
    {
        List<String> valErrors = new List<String>();
        LDC_Account__c tLDC;
        List<Meter__c> tMeter;
        Account tCustomer;
        Contract tContract;
        LDC_Vendor__c tVendor;
        Supplier__c tSupplier;
        List<Contract_Term__c> tContractTerms;
        List<Meter__c> tMeters;
        
        tCustomer = custMap.get(tDASR.Customer_Id__c);
        tVendor = vendorMap.get(tDASR.Vendor_Id__c );
        tSupplier = supplMap.get(tDASR.Supplier_ID__c);
        tLDC = ldcAccntMap != null && ldcAccntMap.containsKey(tDASR.LDC_Account__c) ? ldcAccntMap.get(tDASR.LDC_Account__c) : null;
        
        //TBD - Check the logic contract selection
        tContract = (contractMap != null && contractMap.containsKey(tDASR.Contract__c)) ? contractMap.get(tDASR.Contract__c) : null;
        tContractTerms = tContract != null && contractTermMap != null && contractTermMap.containsKey(tContract.Id) ? contractTermMap.get(tContract.Id) : null;
        
        tMeters = meterMap != null && tLDC != null ? meterMap.get(tLDC.Id) : null;
        String tranType = tDASR != null && tDASR.DASR_Type__c != null ? tDASR.DASR_Type__c : null;
        //TBD - Check for transaction type DASR TYPE = Enrollment
        if(tranType != null && tranType.equalsIgnoreCase('GAAE'))
        {
            valErrors = EDIOutboundMessageValidator.isValLDCFromSFDCEnrolMsg(tLDC, tCustomer,  tVendor, tMeters, tSupplier, tContract, tContractTerms,tDASR);
        }
        else if(tranType != null && tranType.equalsIgnoreCase('GAAD'))
        {
            valErrors = EDIOutboundMessageValidator.isValLDCFromSFDCDropMsg(tLDC, tCustomer,  tVendor, tMeters,  tSupplier, tContract, tContractTerms,tDASR);
        }
        else if(tranType != null && tranType.equalsIgnoreCase('GAAC'))
        {
            valErrors = EDIOutboundMessageValidator.isValLDCFromSFDCChngMsg(tLDC, tCustomer,  tVendor,tMeters,  tSupplier, tContract, tContractTerms,tDASR);
        }
        //Added for Dynegy Initiated GAAR
        else if(tranType != null && tranType.equalsIgnoreCase('GAAR'))
        {
            valErrors = EDIOutboundMessageValidator.isValLDCFromSFDCReinstateMsg(tLDC, tCustomer,  tVendor,tMeters,  tSupplier, tContract, tContractTerms,tDASR);
        }
        
        return valErrors;
    }
    public static List<DASR_Request__c> populateRespnse(List<DASR_Request__c> lstInpDAST, String msg)
    {
        if(lstInpDAST != null && !lstInpDAST.isEmpty())
        {
            for(DASR_Request__c tDASR : lstInpDAST)
            {
                if(msg !=null && msg.containsIgnoreCase('DONE'))
                { 
                    tDASR.Integration_Status__c   ='Waiting For Response';
                }
                else
                {   
                    tDASR.Integration_Status__c   = 'Failed ';
                }
                tDASR.Validation_Message__c = null;
                tDASR.Last_EDI_Update_Date__c = System.now();
                tDASR.Dynegy_Initiated__c = true;
                tDASR.Integration_Send_Date__c  = System.now();
                tDASR.Integration_Message__c  = msg;
            }
        }
        
        return lstInpDAST;
    }    
}