/* 
 * Name: EnrollmentHandler
 * Type: Apex Class
 * Test Class: Covered under respective main class
 * Description:  This class handles the LDC Enrollment Process. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Kartheek Akkineni         02/05/2016       1. Initial Version created
 */
global with sharing class EnrollmentHandler {

    public static final string CONTRCT_ENROLL_QUERY='Select Id,Name,ContractNumber,AccountId,Account.RecordType.Name,Enrollment_Stage__c,Opportunity__c,StartDate,End_Date__c,Rate_Code__c,Account.Billing_Entity__c,'+
                                                    'Bill_Method__c from Contract where Enrollment_Stage__c=\'Ready to Enroll\' and ActivatedById!=null';
    public static final string LDC_ENROLL_QUERY='Select id,Name,Account__c,Account__r.Business_Account__c,LDC_Account_number__c,Account__r.IsPersonAccount,'+
                                                     'LDC_Vendor__c,LDC_Vendor__r.Utility_Code__c,Service_Territory__c,Bill_Cycle__c,LDC_Account_Status__c, '+  
                                                     'Account__r.Billing_Entity__c,Rate_Code__c,contract__c from LDC_Account__c ';
    public static final string Key_Score='_';
    public static final string LDC_ENROLL_STATUS='ACTIVE';
    //public static final string LDC_NEW_STATUS='NEW_ACCOUNT';
    public static final Set<string> LDC_NEW_STATUS=new Set<string> {'NEW_ACCOUNT','FINAL','REJECTED'};
    public static final string DASR_ENROLL_TYPE='GAAE';
    public static final string DASR_CHANGE_TYPE='GAAC';
    private static final string Bill_CYCLE_ERROR_MESSAGE='No Bill Cycle Data found for this Account with Key ';
    public static map<String,String> BillCycleErrorList = new map <String,String>();
    
    public class DASRBillErrorListSend{
        public list<DASR_Request__c> dasrsList;
        public map<String,String> LDCToBillCycleErrorMap;
        public integer LDCsProcessedCount;
    
    }
    
    public class EnrollmentException extends Exception {}
    

     /** =============================================
      * Description:  Method to populate DASR Date and Type on LDC's to Enroll
      ** ============================================= */
    public static DASRBillErrorListSend CreateDASRRequestforLDCs(List<LDC_Account__c> ldcList,Map<Id,Contract> cntrctMap){
        system.debug('*****ldcMapTOpopulateDate'+ldcList);
        Set<Id> vendorIds=new set<Id>();
        Set<Id> custIds=new Set<id>();
        Set<id> CntrctIds=new Set<id>();
        Set<Id> cldcIds=new set<Id>();
        for(LDC_Account__c ldc:ldcList){
            vendorIds.add(ldc.LDC_Vendor__c);
            custIds.add(ldc.Account__c);
            if(ldc.Account__r.IsPersonAccount)
                custIds.add(ldc.Account__r.Business_Account__c);
        }
        for(Contract cnt:cntrctMap.values())
            CntrctIds.add(cnt.id);
            
        for(Contract_LDC__c rec:[SELECT id,LDC_Account__c FROM Contract_LDC__c WHERE (Active__c = True  or Term_Start_Date__c > today) AND Contract__c in: CntrctIds]){
            cldcIds.add(rec.LDC_Account__c);
        }
        
        Map<string,Bill_Cycle_Date__c> vendorBillMap=new Map<string,Bill_Cycle_Date__c>(getBillcycleData(vendorIds));
 
        system.debug('****vendorBillMap***'+vendorBillMap);
        Map<Id,DASR_Request__c> enrldDasrMap=new Map<Id,DASR_Request__c>(getDASRRequestsOfLDCs(CntrctIds,DASR_ENROLL_TYPE));
        Map<Id,DASR_Request__c> enrldChangeDasrMap=new Map<Id,DASR_Request__c>(getDASRRequestsOfLDCs(CntrctIds,DASR_CHANGE_TYPE));
        List<DASR_Request__c> dasrList=new List<DASR_Request__c>();
        List<Contract_LDC__c> ldcCntrctList=new List<Contract_LDC__c>();
        List<Ldc_Account__C> LDCProccessedList = new List<Ldc_Account__C>();
        Boolean CustType;
        
        for(LDC_Account__c ldc:ldcList){
            Contract ct=(cntrctMap.containsKey(ldc.Account__c))?cntrctMap.get(ldc.Account__c):cntrctMap.get(ldc.Account__r.Business_Account__c);
            
            system.debug('Customer Record Type : '+ct.Account.RecordType.Name);
            CustType = false;
            if(ct.Account.RecordType.Name==ConstantUtility.CUST_MUNI_REC_TYPE ){ 
                CustType= true;
            }
                
            if(LDC_NEW_STATUS.contains(ldc.LDC_Account_Status__c) && !enrldDasrMap.containsKey(ldc.Id)){
               system.debug('***Enroll LDC Id :'+ldc.id+' Ldc Name :'+ldc.Name);
               LDCProccessedList.add(ldc);
                DASR_Request__c tempDASR = createEnrollDASR(ldc,vendorBillMap,ct,CustType);
                if(tempDASR != null){
                    dasrList.add(tempDASR);
                    //if(!cldcIds.contains(ldc.id))
                    ldcCntrctList.add(createContrcatLDC(ct,ldc,CustType));
                }
             }
                 
             if(ldc.LDC_Account_Status__c==LDC_ENROLL_STATUS && !enrldChangeDasrMap.containsKey(ldc.id)){
                system.debug('***Change LDC Id:'+ldc.id+' Ldc Name :'+ldc.Name);
                LDCProccessedList.add(ldc);
                DASR_Request__c tempDASR = createChangeDASR(ldc,vendorBillMap,ct,false);
                if(tempDASR != null){
                    dasrList.add(tempDASR);
                    if(!cldcIds.contains(ldc.id))
                        ldcCntrctList.add(createContrcatLDC(ct,ldc,false));
                }
            }
        } 

        If(!ldcCntrctList.isEmpty()) Database.upsert(ldcCntrctList,False);
       
        DASRBillErrorListSend DataReturn = new DASRBillErrorListSend();
       
        DataReturn.dasrsList = new List<DASR_REQUEST__c>();
        DataReturn.dasrsList.addall(dasrList);
        DataReturn.LDCToBillCycleErrorMap = new map <String,String>();
        DataReturn.LDCToBillCycleErrorMap.putAll(BillCycleErrorList);
        DataReturn.LDCsProcessedCount = LDCProccessedList.size();
        system.debug(BillCycleErrorList);
        return DataReturn;
    }
     
    public static Contract_LDC__c createContrcatLDC(Contract ct,LDC_Account__c ldc,Boolean IsMassMarket){

        system.debug('****Contrcat LDC to Create****'+ldc);
        system.debug('**** Contract of LDC  to Create****'+CT);
        Contract_LDC__c cntrctLdc=new Contract_LDC__c();
        cntrctLdc.Name=ct.id;
        cntrctLdc.Bill_Method__c = ct.Bill_Method__c;
        cntrctLdc.Contract__c=ct.Id;
        if(IsMassMarket && ldc.id==null)
            cntrctLdc.LDC_Account__r=new LDC_Account__c(External_Reference_ID__c=ldc.External_Reference_ID__c);
        else
            cntrctLdc.LDC_Account__c=ldc.Id;
        //SCR:1187 :commented below line to set Start date as null to prevent overlap untill GAAE/GAAC accepted and to prevent flow to lodestar
        //cntrctLdc.Term_Start_Date__c=getDatetimefromDate(ct.StartDate);
        cntrctLdc.Term_Stop_Date__c=getDatetimefromDate(ct.End_Date__c);
        cntrctLdc.Rate_Code__c=ct.Rate_Code__c;

         return cntrctLdc;
    }


    /** =============================================
        * Description:  Metod to create Contrcat LDC for Mass Market
      ** ============================================= */ 

    public static  Contract_LDC__c createMMarketContractLdc(Contract ct,LDC_Account__c ldc,Mass_Market__c mMarket){
        Contract_LDC__c cntrctLdc=new Contract_LDC__c();
        cntrctLdc=createContrcatLDC(ct,ldc,true);
        cntrctLdc.Enrollment_Type__c=mMarket.Enrollment_Type__c;
        cntrctLdc.Promo_Code__c=mMarket.Promo_Code__c;
        cntrctLdc.Enrollment_Start_Date__c=mMarket.Enrollment_Start_Date__c;
        return cntrctLdc;
    }


    public static DASR_Request__c createEnrollDASR(LDC_Account__c ldc,Map<string,Bill_Cycle_Date__c> vendorBillMap,Contract ct,Boolean IsMassMarket){
        system.debug('****New Enroll Request***'+ldc);   
        system.debug('****New Enroll Request***'+vendorBillMap);  
        
        string billCycle=(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE && (ldc.Bill_Cycle__c==null || ldc.Bill_Cycle__c==''))?'1':ldc.Bill_Cycle__c;
        DASR_Request__c drEnroll;
        
        Date CntrctDate = CheckMeterDate(ct.StartDate,IsMassMarket);
        system.debug('CheckMeterDate : '+CntrctDate);
        
        String billCyclekey=generateBillCycleKey(ldc.LDC_Vendor__r.Utility_Code__c,billCycle,CntrctDate);
        system.debug('***billCyclekey***'+billCyclekey);
        system.debug(+ct.Account.RecordType.Name +IsMassMarket);
        if(vendorBillMap.containskey(billCyclekey)){
            drEnroll=new DASR_Request__c();
            Bill_Cycle_Date__c billObj=vendorBillMap.get(billCyclekey);
            Integer daysdiff = Date.today().daysBetween(billObj.Meter_Read_Date__c);
            system.debug('checking days difference : '+daysdiff+' : '+billCyclekey);
            system.debug('checking days difference after month : '+Date.today().daysBetween((billObj.Meter_Read_Date__c).addmonths(-1)));
            system.debug('Test account : '+ldc.Account__r.Billing_Entity__c+'CNt : '+ct.Account.Billing_Entity__c);
            drEnroll.DASR_Type__c=DASR_ENROLL_TYPE;
            drEnroll.Contract__c = ct.Id;
            drEnroll.Dynegy_Initiated__c =true;
            if(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE)
                drEnroll.Billing_Entity__c = ct.Account.Billing_Entity__c;
            else
                drEnroll.Billing_Entity__c = ldc.Account__r.Billing_Entity__c;
            if(drEnroll.Billing_Entity__c == 'Dynegy'){
                if(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE) 
                    drEnroll.DASR_Submit_Date__c=system.now();
                else
                    drEnroll.DASR_Submit_Date__c=(Date.today().daysBetween(billObj.Meter_Read_Date__c) < 15)?system.now():((Date.today().daysBetween((billObj.Meter_Read_Date__c).addmonths(-1)) > 0)?getDatetimefromDate((billObj.Meter_Read_Date__c).addmonths(-1).adddays(1)):system.now());
                
                system.debug('DASR_Submit_Date__c : '+drEnroll.DASR_Submit_Date__c);
                
                if(IsMassMarket && ldc.id==null)
                    drEnroll.LDC_Account__r=new LDC_Account__c(External_Reference_ID__c=ldc.External_Reference_ID__c);
                else
                    drEnroll.LDC_Account__c=ldc.id;
                    
                daysdiff = Date.today().daysBetween(billObj.Meter_Read_Date__c);
                if(daysdiff <= 15){
                    billObj=vendorBillMap.get(generateBillCycleKey(ldc.LDC_Vendor__r.Utility_Code__c,billCycle,CheckMeterDate(CntrctDate.addmonths(1),IsMassMarket)));
                }
                if(billObj != null){
                    system.debug('******Check Date***'+billObj.Meter_Read_Date__c);
                    drEnroll.Change_Effective_Date__c=billObj.Meter_Read_Date__c;
                } else {
                    drEnroll.Change_Effective_Date__c = null;
                }
            }
            else if(drEnroll.Billing_Entity__c == 'CES'){
                if(daysdiff > 4)
                    drEnroll.DASR_Submit_Date__c = billObj.Meter_Read_Date__c.adddays(-4);
                else if (daysdiff < 4){
                    billObj=vendorBillMap.get(generateBillCycleKey(ldc.LDC_Vendor__r.Utility_Code__c,billCycle,CheckMeterDate(CntrctDate.addmonths(1),IsMassMarket)));
                    drEnroll.DASR_Submit_Date__c = billObj.Meter_Read_Date__c.adddays(-4);
                }
                else
                    drEnroll.DASR_Submit_Date__c=system.now();  
                drEnroll.Change_Effective_Date__c=billObj.Meter_Read_Date__c;
                system.debug('DASR_Submit_Date__c : '+drEnroll.DASR_Submit_Date__c+' : '+drEnroll.Change_Effective_Date__c);
                if(IsMassMarket && ldc.id==null)
                    drEnroll.LDC_Account__r=new LDC_Account__c(External_Reference_ID__c=ldc.External_Reference_ID__c);
                else
                    drEnroll.LDC_Account__c=ldc.id;
            }
        }
        
        else if(!vendorBillMap.containskey(billCyclekey) && IsMassMarket == true && ct.Account.RecordType.Name == ConstantUtility.CUST_MUNI_REC_TYPE && (ldc.Bill_Cycle__c == null || ldc.Bill_Cycle__c=='') )
        {
            drEnroll=new DASR_Request__c();
            System.debug('*****Test1*****'+drEnroll);
            drEnroll.DASR_Type__c=DASR_ENROLL_TYPE;
            drEnroll.Contract__c = ct.Id;
            drEnroll.Dynegy_Initiated__c = true;
            drEnroll.Billing_Entity__c = ldc.Account__r.Billing_Entity__c;
            drEnroll.DASR_Submit_Date__c = system.now();
            drEnroll.LDC_Account__c=ldc.id;
            drEnroll.Change_Effective_Date__c = system.today();
            System.debug('*****Test2*****'+drEnroll.LDC_Account__c);
        }
        
        else {
            system.debug('For Mass Market Check --> Is massmarket : '+IsMassMarket+' Contract customer Record type : '+ct.Account.RecordType.Name);
            if(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE)     
              throw new EnrollmentException(Bill_CYCLE_ERROR_MESSAGE+billCyclekey);
            BillCycleErrorList.put(ldc.ldc_account_number__c,billCyclekey);
            system.debug('****Exception on Creating Enroll DASR****'+Bill_CYCLE_ERROR_MESSAGE+billCyclekey);
        }   
        if(drEnroll != null)
            return drEnroll;
        else
            return null;
    }    
    
    public static DASR_Request__c createChangeDASR(LDC_Account__c ldc,Map<string,Bill_Cycle_Date__c> vendorBillMap,Contract ct,Boolean IsMassMarket){
        system.debug('****Change Request***');
        if(ldc.Rate_Code__c == ct.Rate_Code__c && ct.Account.RecordType.Name!=ConstantUtility.CUST_MASS_REC_TYPE && ldc.Service_Territory__c != 'ComEd-IL'){
            return null;
        }
        string billCycle=(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE && (ldc.Bill_Cycle__c==null || ldc.Bill_Cycle__c==''))?'1':ldc.Bill_Cycle__c;
        Utility_Business_Rules__c vndrRules=Utility_Business_Rules__c.getValues(ldc.Service_Territory__c);
        DASR_Request__c dasrChange;
        Date CntrctDate = CheckMeterDate(ct.StartDate,IsMassMarket);
        String billCyclekey=generateBillCycleKey(ldc.LDC_Vendor__r.Utility_Code__c,billCycle,CheckMeterDate(ct.StartDate,IsMassMarket));
        system.debug('***billCyclekey***'+billCyclekey);
        if(vendorBillMap.containskey(billCyclekey)){
            dasrChange=new DASR_Request__c();
            Bill_Cycle_Date__c billObj=vendorBillMap.get(billCyclekey);
            system.debug('***Change current Bill Cycle Date'+billObj);
            Integer daysdiff = Date.today().daysBetween(billObj.Meter_Read_Date__c);
           
            dasrChange.DASR_Type__c=DASR_CHANGE_TYPE;
            dasrChange.Contract__c = ct.Id;
            dasrChange.LDC_Account__c=ldc.Id;
            dasrChange.Dynegy_Initiated__c =true;
            if(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE)
                dasrChange.Billing_Entity__c = ct.Account.Billing_Entity__c;
            else
                dasrChange.Billing_Entity__c = ldc.Account__r.Billing_Entity__c;
            if(dasrChange.Billing_Entity__c == 'Dynegy'){
                system.debug('****Days Between Meter Read Date***'+Date.today().daysbetween(billObj.Meter_Read_Date__c));
                if(Date.today().daysbetween(billObj.Meter_Read_Date__c)>=Integer.valueOf(vndrRules.Window_Days__c)){
                    dasrChange.DASR_Submit_Date__c=getDatetimefromDate(billObj.Meter_Read_Date__c).adddays(Integer.valueOf(vndrRules.Days_in_Window__c));
                    dasrChange.Change_Effective_Date__c=billObj.Meter_Read_Date__c;
                }
                else{
                    //if(Date.today().daysbetween(billObj.Meter_Read_Date__c)>=Integer.valueOf(vndrRules.Days_up_to_Window__c))
                    if((Integer.valueOf(vndrRules.Days_up_to_Window__c) == 0) || (Date.today().daysbetween(billObj.Meter_Read_Date__c)>=Integer.valueOf(vndrRules.Days_up_to_Window__c)))
                        billObj=vendorBillMap.get(generateBillCycleKey(ldc.LDC_Vendor__r.Utility_Code__c,billCycle,billObj.Meter_Read_Date__c.addmonths(1)));
                    else
                        billObj=vendorBillMap.get(generateBillCycleKey(ldc.LDC_Vendor__r.Utility_Code__c,billCycle,billObj.Meter_Read_Date__c.addmonths(2)));
                    
                    system.debug('***Change Future Bill Cycle Date'+billObj);
                    
                    dasrChange.DASR_Submit_Date__c=(vndrRules.Days_Out_Window__c==0?System.now():getDatetimefromDate(billObj.Meter_Read_Date__c.addDays(Integer.valueof(vndrRules.Days_Out_Window__c))));
                    dasrChange.Change_Effective_Date__c=billObj.Meter_Read_Date__c;
                }
                if(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE) 
                    dasrChange.DASR_Submit_Date__c=system.now();
                if(ldc.Service_Territory__c == 'ComEd-IL'){
                    dasrChange.Integration_Status__c = 'Manually Fulfilled';
                    dasrChange.Accepted__c = true;
                    dasrChange.Change_Reason__c = 'Change ESP Rate Code';
                }
            }
            else if(dasrChange.Billing_Entity__c == 'CES'){
                if(daysdiff > 4)
                    dasrChange.DASR_Submit_Date__c = billObj.Meter_Read_Date__c.adddays(-4);
                else if (daysdiff < 4){
                    billObj=vendorBillMap.get(generateBillCycleKey(ldc.LDC_Vendor__r.Utility_Code__c,billCycle,CheckMeterDate(CntrctDate.addmonths(1),IsMassMarket)));
                    dasrChange.DASR_Submit_Date__c = billObj.Meter_Read_Date__c.adddays(-4);
                }
                else
                    dasrChange.DASR_Submit_Date__c=system.now();    
                dasrChange.Change_Effective_Date__c=billObj.Meter_Read_Date__c;
                system.debug('DASR_Submit_Date__c : '+dasrChange.DASR_Submit_Date__c+' : '+dasrChange.Change_Effective_Date__c);
            }
        }
        else{
            if(IsMassMarket && ct.Account.RecordType.Name==ConstantUtility.CUST_MASS_REC_TYPE)
                throw new EnrollmentException(Bill_CYCLE_ERROR_MESSAGE+billCyclekey);
            BillCycleErrorList.put(ldc.ldc_account_number__c,billCyclekey);
            system.debug('****Exception on Creating Change DASR****'+Bill_CYCLE_ERROR_MESSAGE+billCyclekey);
        }  
        if(dasrChange!= null)
            return dasrChange;
        else
            return null;
    }

    private static Date CheckMeterDate(Date CntrctDate,Boolean IsMassMarket){
        system.debug('CntrctDate : '+CntrctDate);
        Integer daysto = Date.today().daysbetween(CntrctDate);
        system.debug('checking days difference : '+daysto);
        
        if( CntrctDate<=Date.today()) //IsMassMarket &&
            return Date.today();
        else
            return CntrctDate;
    }

    
    private static Datetime getDatetimefromDate(Date mtrDate){
        try{
            return datetime.newInstance(mtrDate.year(), mtrDate.month(),mtrDate.day());
        }
        catch(System.Exception ex){
            return null;
        }
    }
     /** =============================================
        * Description:  Metod to get Bill Cycle Data of vendors
      ** ============================================= */ 

    public static Map<string,Bill_Cycle_Date__c> getBillcycleData(Set<Id> vendorIds){
        Map<string,Bill_Cycle_Date__c> vendorDataMap=new Map<string,Bill_Cycle_Date__c>();
        for(Bill_Cycle_Date__c bdata:[SELECT LDC_Vendor__c,Bill_Cycle__c, Meter_Read_Month__c, Meter_Read_Year__c,Bill_Cycle_Key__c,Meter_Read_Date__c 
                                        FROM Bill_Cycle_Date__c WHERE LDC_Vendor__c IN :vendorIds ]){

                vendorDataMap.put(bdata.Bill_Cycle_Key__c,bdata);
        }
        return vendorDataMap;
    }
     /** =============================================
        * Description:  Get Enroll DASR Requests
      ** ============================================= */ 

    private static Map<Id,DASR_Request__c> getDASRRequestsOfLDCs(Set<Id> CustIds,string dasrType){
        system.debug('***DASR Customer Ids***'+CustIds);
        Map<Id,DASR_Request__c> dasrMap=new Map<id,DASR_Request__c>();
        for(DASR_Request__c dsr:[Select Id,Name, DASR_Submit_Date__c, DASR_Type__c,LDC_Account__c,Contract__c,LDC_Account__r.Account__c  from DASR_Request__c 
                                    where Contract__c in :CustIds  and DASR_Type__c=:dasrType and rejected__c != true ]){
            
            dasrMap.put(dsr.LDC_Account__c,dsr);
        }
        return dasrMap;
    }


    
     /** =============================================
        * Description:  Metod to generate Bill Cycle Key which is used as Map Key to get Bill Cycle date of Vendors
      ** ============================================= */  
   
    private static string generateBillCycleKey(string vndrCode,string billCycle, Date ctDate){
        String MtrMonth=Datetime.newInstance(ctDate.year(), ctDate.month(),ctDate.day()).format('MMM').toUpperCase();
        string mtrYear=string.valueof(ctDate.year());
        system.debug('Before : '+billcycle);
        billcycle = billcycle != null ? string.valueof(integer.valueof(billcycle)):billcycle;
        system.debug('After : '+billcycle);

        return vndrCode+Key_Score+billCycle+Key_Score+MtrMonth+Key_Score+mtrYear;
    }

    /** =============================================
        * Description:  Metod to Execute Enrollment Batch Process
      ** ============================================= */  

    public static  void RunEnrollmentBatch(string cntrctId){
        Set<Id> muniIds=new Set<Id>();
        Set<Id> cniIds=new Set<id>();
        system.debug('******cntrctId****'+cntrctId);
        string cntrctquery=EnrollmentHandler.CONTRCT_ENROLL_QUERY;
        if(cntrctId!=null && cntrctId.trim()!=''){
            cntrctquery+=' and Id=:cntrctId';
        }
        system.debug('******cntrctquery****'+cntrctquery);
        List<Contract> cntrctList=Database.query(cntrctquery);
        Map<id,Contract> cntrctMap=new Map<id,Contract>() ; 
        for(Contract ct:CntrctList){
            if(ct.Account.RecordType.Name==ConstantUtility.CUST_MUNI_REC_TYPE  ){
                muniIds.add(ct.AccountId);
            }
            if(ct.Account.RecordType.Name==ConstantUtility.CUST_CNI_REC_TYPE ){
                cniIds.add(ct.Opportunity__c);
            }
            cntrctMap.put(ct.AccountId,ct);
        }
        
        if(!muniIds.IsEmpty()){
            BatchStartEnrollmentProcess muniAggBatch= new BatchStartEnrollmentProcess(muniIds,true,cntrctMap);
            if(!BatchUtility.IsconcurrentjobsRunning()){
                Database.executebatch(muniAggBatch,200); 
            }
            else{
                System.scheduleBatch(muniAggBatch, 'Re-Scheduled BatchMuniEnrollmentProcess @ '+Datetime.now(), 5);
            }
        }

        if(!cniIds.isEmpty()){
            Set<id> oppLdcIds=new set<Id>();
            for(Opportunity_LDC__c ldcOpp:[Select id,LDC_Account__c,Opportunity__c from Opportunity_LDC__c where Opportunity__c in :cniIds ])
                oppLdcIds.add(ldcOpp.LDC_Account__c);
            if(!oppLdcIds.isEmpty()){
                BatchStartEnrollmentProcess CNIBatch= new BatchStartEnrollmentProcess(oppLdcIds,false,cntrctMap);
                if(!BatchUtility.IsconcurrentjobsRunning()){
                    Database.executebatch(CNIBatch,200);
                }
                else{
                    System.scheduleBatch(CNIBatch, 'Re-Scheduled BatchCNIEnrollmentProcess @ '+Datetime.now(), 5);
                }
            }
        }
    }
 
    public static void ProcessEnrollment(){
        RunEnrollmentBatch('');
    }

    /** =============================================
        * Description:  Metod to Execute Enrollment Batch Process on Demand from Contract Button
      ** ============================================= */ 
    webService static String SetContractToEnroll(String CntrctId){
        String result='';
        if(!String.isBlank(CntrctId)){
            system.debug('*****CntrctId'+CntrctId);
            EnrollmentHandler.RunEnrollmentBatch(CntrctId);
            result='Enrollment Batch intiated Successfully';
        }       
        else{
            result = 'Invalid Contract ID for the selected Record. Please try again or contact administrator.';
        }
        return result;
    }

}