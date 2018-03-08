/* Code Changes for Bill Cycle update FOr REFBF chaitanya 
*/
trigger InsertUpdatePeakLdInfo on Account_Exception__c(after insert){
    Boolean hasAccess = true;
    String Usr = Label.Bypass_Users;
    list<string> UsrLst = Usr.split(';');
    for(string str : UsrLst){
        if(UserInfo.getName() == str){
            hasAccess = false;
            system.debug('------------------------ Bypassed User ------------------------');
        }
    }
    
    if(hasAccess){     
        Set<Id> DasrreqIdset = new Set<Id>();
        map<id,string> LDCaccountBillcycle = new map<id,string>();
        set<id> ldcset = new set<id>();
        map<id,ldc_account__c> updateldcmap = new map<id,ldc_account__c>();
        map<id,contract_ldc__c> cldcmap = new map<id,contract_ldc__c>();
        boolean isInsertOrUpdate;
        boolean isErrororNot;
        list<Dasr_Request__c>DasrRequestList = new list<Dasr_Request__c>();
        Dasr_Request__c DasrRequestObj = new Dasr_Request__c();
        Peak_Load_Information__c peakLoadinfo = new Peak_Load_Information__c();
        list<Peak_Load_Information__c> peakLoadinfoListIns = new list<Peak_Load_Information__c>();
        list<Peak_Load_Information__c>peakLoadInfoList = new list<Peak_Load_Information__c>();
        list<Peak_Load_Information__c>peakLoadList = new list<Peak_Load_Information__c>();
        list<Peak_Load_Information__c> plclst = new list<Peak_Load_Information__c>();
        map<id,List<Peak_Load_Information__c>> mapldc = new map<id,list<Peak_Load_Information__c>>();
        list<Account_Exception__c> aelst = new list<Account_Exception__c>();
        map<id, Account_Exception__c>AccountExcepMap = new map<id, Account_Exception__c>([select id, Reason_Code__c, DASR_Request__c, LDC_Account__c, 
        			DASR_Request__r.change_Effective_Date__c, DASR_Request__r.Capacity_Obligation__c, DASR_Request__r.Transmission_Obligation_Quantity__c,
        			DASR_Request__r.DASR_Type__c,DASR_Request__r.LDC_bill_Cycle__c,Most_Recent__c,LDC_Account__r.Ldc_account_status__c from Account_Exception__c
        			 where id in: Trigger.new]);
        			
        for (Account_Exception__c AccountExcepObj: Trigger.new) {
            if((AccountExcepObj.Reason_Code__c == 'AMTKC' || AccountExcepObj.Reason_Code__c == 'AMTKZ') && AccountExcepMap.get(AccountExcepObj.id).DASR_Request__r.DASR_Type__c == 'GAAC'){
                DasrreqIdset.add(AccountExcepObj.LDC_Account__C);
                } 
            if(AccountExcepObj.Reason_Code__c == 'REFBF' && AccountExcepMap.get(AccountExcepObj.id).DASR_Request__r.DASR_Type__c == 'GAAC')
                    LDCaccountBillcycle.put(AccountExcepObj.LDC_Account__C,AccountExcepMap.get(AccountExcepObj.id).DASR_Request__r.LDC_bill_Cycle__c);
        }
        
        if(LDCaccountBillcycle.size()>0){
            for(id id1 : LDCaccountBillcycle.keyset() ){
                if(LDCaccountBillcycle.get(id1) != null && LDCaccountBillcycle.get(id1) != ''){
                    String ldcBillCycle = LDCaccountBillcycle.get(id1) != null ? LDCaccountBillcycle.get(id1) : null ;
                    string BC1 =  ldcBillCycle!=null ? ldcBillCycle.replaceAll('[^0-9]', '') : null; 
                    string BC2 =  BC1 != null ? BC1.replaceFirst('^0+','') : null;
                    if(BC2 != null){
	                    ldc_account__c ldc1 = new ldc_account__c();
	                    ldc1.id = id1;
	                    ldc1.Bill_Cycle__c = BC2 != null && BC2.length() > 2 ? BC2.substring(0,2) : (BC2 != null ? BC2: null) ;
	                    updateldcmap.put(id1,ldc1);
                    }
                }
            }               
        }

        system.debug('\n DasrreqIdset :'+DasrreqIdset);
        system.debug('\n AccountExcepMap :'+AccountExcepMap); 
        peakLoadInfoList = [select id, name, start_date__c, EndDate__c, DASR_Request__c, Load_Type__C, LDC_Account__C, Load_value__c from Peak_Load_Information__c where LDC_Account__C in: DasrreqIdset and (Load_Type__c ='PLC' or  Load_Type__c ='NSPLC')];
        for(Peak_Load_Information__c plc:peakLoadInfoList){
            peakLoadList.add(plc);
            mapldc.put(plc.ldc_account__c, peakLoadList);
        }
        system.debug('\n peakLoadInfoList :'+peakLoadInfoList);
        if(AccountExcepMap.size()>0){
            for(Id recid : AccountExcepMap.keySet()){
                if((AccountExcepMap.get(recid).Reason_Code__c == 'AMTKC' || AccountExcepMap.get(recid).Reason_Code__c == 'AMTKZ') && AccountExcepMap.get(recid).DASR_Request__r.DASR_Type__c == 'GAAC'){
                    peakLoadinfo = new Peak_Load_Information__c();
                    isInsertOrUpdate = false;
                    isErrororNot = false;                   
                    plclst = mapldc.get(AccountExcepMap.get(recid).LDC_Account__c);
                    if(plclst == null){
                        plclst = new list<peak_load_information__C>();
                        isErrororNot = true;
                    }
                    else{
                        for(Peak_Load_Information__c peakLoadInfoObj: plclst){
                           if((AccountExcepMap.get(recid).Reason_Code__c == 'AMTKC' && peakLoadInfoObj.Load_Type__C == 'PLC') || AccountExcepMap.get(recid).Reason_Code__c == 'AMTKZ' && peakLoadInfoObj.Load_Type__C == 'NSPLC'){
                                if((AccountExcepMap.get(recid).DASR_Request__c ==  peakLoadInfoObj.DASR_Request__c) && (AccountExcepMap.get(recid).LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (AccountExcepMap.get(recid).DASR_Request__r.change_Effective_Date__c > peakLoadInfoObj.start_date__c) && (AccountExcepMap.get(recid).DASR_Request__r.change_Effective_Date__c < peakLoadInfoObj.EndDate__c)){
                                    isInsertOrUpdate = true;
                                    break;
                                }else if((AccountExcepMap.get(recid).DASR_Request__c ==  peakLoadInfoObj.DASR_Request__c) && (AccountExcepMap.get(recid).LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (AccountExcepMap.get(recid).DASR_Request__r.change_Effective_Date__c == peakLoadInfoObj.start_date__c)){
                                    isInsertOrUpdate = true;
                                    break;
                                }
                                else if((AccountExcepMap.get(recid).LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (AccountExcepMap.get(recid).DASR_Request__r.change_Effective_Date__c > peakLoadInfoObj.start_date__c) && (AccountExcepMap.get(recid).DASR_Request__r.change_Effective_Date__c < peakLoadInfoObj.EndDate__c)){
                                    isInsertOrUpdate = true;
                                    break;
                                }else if((AccountExcepMap.get(recid).LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (AccountExcepMap.get(recid).DASR_Request__r.change_Effective_Date__c == peakLoadInfoObj.start_date__c)){
                                    isInsertOrUpdate = true;
                                    break;
                                }
                                else{
                                    isErrororNot = true;  
                                }
                            }
                            else{
                                
                            }
                        }
                    }
                    system.debug('\n isInsertOrUpdate :'+isInsertOrUpdate);
                    system.debug('\n isErrororNot :'+isErrororNot);
                    if(isInsertOrUpdate){
                        DasrRequestObj = new Dasr_Request__c();
                        DasrRequestObj.id = AccountExcepMap.get(recid).DASR_Request__c;
                        DasrRequestObj.Integration_Status__c = 'Validation Failed';
                     // DasrRequestObj.Validation_Failed__c = true;
                        DasrRequestObj.Validation_Message__c = 'Review Required';
                     // DasrRequestObj.Dynegy_Initiated__c = true;
                        DasrRequestList.add(DasrRequestObj);
                    }
                    else{                                 
                        peakLoadInfo.start_date__C = AccountExcepMap.get(recid).DASR_Request__r.change_Effective_Date__c;
                        if(AccountExcepMap.get(recid).Reason_Code__c == 'AMTKC'){
                            if(peakLoadInfo.start_date__C.month()>5 ){
                                String end1 = (peakLoadInfo.start_date__C.year() + 1)+'0531';
                                peakLoadInfo.EndDate__c = IntegrationUtil.convertStringToDate(end1);
                                system.debug('\n peakLoadInfo.EndDate__c :'+peakLoadInfo.EndDate__c);   
                            }
                            else{
                                String end2 = peakLoadInfo.start_date__C.year()+'0531';
                                peakLoadInfo.EndDate__c = IntegrationUtil.convertStringToDate(end2);
                                system.debug('\n peakLoadInfo.EndDate__c :'+peakLoadInfo.EndDate__c);
                            }
                            peakLoadInfo.Load_Type__C = 'PLC';
                            peakLoadinfo.Load_value__c = AccountExcepMap.get(recid).DASR_Request__r.Capacity_Obligation__c;
                        }
                        if(AccountExcepMap.get(recid).Reason_Code__c == 'AMTKZ'){
                            peakLoadInfo.Load_Type__C = 'NSPLC';
                            if(peakLoadInfo.start_date__C.month()>=1 ){
                                String end3 = peakLoadInfo.start_date__C.year()+'1231';
                                peakLoadInfo.EndDate__c = IntegrationUtil.convertStringToDate(end3);
                                system.debug('\n peakLoadInfo.EndDate__c :'+peakLoadInfo.EndDate__c);
                            }
                            else{ 
                            }
                            peakLoadinfo.Load_value__c = AccountExcepMap.get(recid).DASR_Request__r.Transmission_Obligation_Quantity__c;
                         }
                         ldcset.add(AccountExcepMap.get(recid).LDC_Account__c);
                         peakLoadInfo.LDC_Account__C = AccountExcepMap.get(recid).LDC_Account__C;
                         peakLoadinfo.Dasr_request__c = AccountExcepMap.get(recid).DASR_Request__c;
                         peakLoadinfoListIns.add(peakLoadinfo);
                         mapldc.put(peakLoadInfo.LDC_Account__C,peakLoadinfoListIns);
                    }
                }
                
                /*if(AccountExcepMap.get(recid).Reason_Code__c == 'DTM150' && AccountExcepMap.get(recid).ldc_account__r.ldc_account_status__c != 'PENDING_ENROLLMENT'){
                	system.debug('Most recent : '+AccountExcepMap.get(recid).Most_Recent__c);
                	AccountExcepMap.get(recid).Most_Recent__c = false;
            		aelst.add(AccountExcepMap.get(recid));
                }*/
            }
            system.debug('\n peakLoadinfoListIns :'+peakLoadinfoListIns);
            system.debug('\n FINAL mapldc :'+mapldc);
            if(peakLoadinfoListIns.size()>0){
              TriggerHandler.changeDASR = false;       
                upsert peakLoadinfoListIns;
                for(contract_ldc__c cldc : [select id,name,term_start_date__c,term_stop_date__c,issynchronized__c,ldc_account__c from contract_ldc__c where ldc_account__c IN : ldcset
                                                and term_start_date__c!= null order by ldc_account__c,term_start_date__c desc]){
                    if(!cldcmap.containskey(cldc.ldc_account__c))
                        cldcmap.put(cldc.ldc_account__c,cldc);
                }
            }
            
            list<contract_ldc__c> cldclst = new list<contract_ldc__c>();
            for(contract_ldc__c cldc : cldcmap.values()){
                cldc.issynchronized__c = false;
                cldclst.add(cldc);
            }
            if(!cldclst.isempty()) update cldclst;
            
            if(DasrRequestList.size()>0){
                Set<Dasr_request__c> DasrRequestSet = new Set<Dasr_request__c>();
                DasrRequestSet.addall(DasrRequestList);
                DasrRequestList = new List <Dasr_request__c>();
                DasrRequestList.addall(DasrRequestSet);
                update DasrRequestList;      
            }
        }

		//if(!aelst.isempty()) update aelst;    
	   	if(!updateldcmap.isempty())
	        update updateldcmap.values();
    }
}