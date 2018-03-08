global class LDCinfo implements Database.Batchable<sObject>,Database.Stateful,System.Schedulable {
    
    //global final set<id> ldcset;
    global final set<id> accset;
    //global final string ObjName;
    global map<id,map<string,cusWrapper>> accldcstrmap;
    global map<id,map<string,cusWrapper>> oppldcstrmap;
    global decimal CapacitySum;
    public cusWrapper cwrapper {get;set;}
    
    global void execute (SchedulableContext sc){
        system.debug('Executing through Schedulable Context .........');
        set<id> setacc = new set<id>();
        for(ldc_account__c ldc : [select id,account__c,account__r.business_account__c from ldc_account__c where Is_Record_updated__c = true ]){
            if(ldc.account__r.business_account__c != null)
                setacc.add(ldc.account__r.business_account__c);
            else
                setacc.add(ldc.account__c);
        }
        if(!setacc.isempty()){
            LDCInfo ldc = new LDCinfo(setacc);
            Database.executeBatch(ldc,500);
        }
    }
    
    public LDCinfo(set<id> setacc){
        accset = setacc;
    }
    
    public LDCinfo(){
    }
    
    /*public LDCinfo(set<id> setacc, string obj){
        accset = setacc;
        ObjName = obj;
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'select id,name,account__c,account__r.business_account__c,Capacity_PLC1__c,Capacity_PLC2__c,Acct_ADU__c,On_PK_Kwh__c,Off_Pk_Kwh__c,NSPL1_KW__c,NSPL2_KW__c,FRM_Profile__c'
                      +',Utility_Zone__c,Utility_Rate_Class__c,Is_Record_updated__c,ldc_vendor__r.name from ldc_account__c ';// and FRM_Profile__c != null';
        /*if(ObjName == null)
            query+= 'where id IN : ldcset order by account__c';
        else*/
            query+= 'where account__c IN : accset or account__r.business_account__c IN : accset order by account__r.business_account__c';
        return database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, list<sObject> scope){
        
        list<ldc_account__c> ldclst = (list<ldc_account__c>)scope;
        map<id,list<ldc_account__c>> accldcmap = new map<id,list<ldc_account__c>>();
        set<id> ldcset =new set<id>();
        for(ldc_account__c ldc : ldclst){
            list<ldc_account__c> templdc = new list<ldc_account__c>();
            if(ldc.account__r.business_account__c != null){
                if(accldcmap.containskey(ldc.account__r.business_account__c)){
                    templdc = accldcmap.get(ldc.account__r.business_account__c);
                }   
                templdc.add(ldc);
                accldcmap.put(ldc.account__r.business_account__c,templdc);
            }
            else{
                if(accldcmap.containskey(ldc.account__c)){
                    templdc = accldcmap.get(ldc.account__c);
                }   
                templdc.add(ldc);
                accldcmap.put(ldc.account__c,templdc);
                ldcset.add(ldc.id);
            }
        }
        
        list<opportunity_ldc__c> oldclst = [select id,opportunity__c,ldc_account__c,ldc_account__r.Acct_ADU__c,ldc_account__r.NSPL1_KW__c,ldc_account__r.Capacity_PLC1__c,
                                                ldc_account__r.On_PK_Kwh__c,ldc_account__r.Off_PK_Kwh__c,ldc_account__r.FRM_Profile__c,ldc_account__r.Utility_Zone__c,
                                                ldc_account__r.Capacity_PLC2__c,ldc_account__r.NSPL2_KW__c,ldc_account__r.Utility_Rate_Class__c,ldc_account__r.ldc_vendor__r.name
                                                 from opportunity_ldc__c where ldc_account__c IN : ldcset and opportunity__c IN (select id from opportunity)];
        set<id> oppset = new set<id>();
        map<id,list<ldc_account__c>> oldcmap = new map<id,list<ldc_account__c>>();
        for(opportunity_ldc__c oldc : oldclst){
            list<ldc_account__c> idlst = new list<ldc_account__c>();
            if(oldcmap.containskey(oldc.opportunity__c)){
                idlst.addAll(oldcmap.get(oldc.opportunity__c));
            }
            idlst.add(oldc.ldc_account__r);
            oldcmap.put(oldc.opportunity__c,idlst);
        }
        system.debug('OLDC Map : '+oldcmap.size()+' : '+oldcmap);
        if(accldcstrmap == null)
            accldcstrmap = new map<id,map<string,cusWrapper>>();
        if(oppldcstrmap == null)
            oppldcstrmap = new map<id,map<string,cusWrapper>>();
            
        for(ID mapid : accldcmap.keySet()){
            map<string,cusWrapper> promap = new map<string,cusWrapper>();
            list<ldc_account__c> innerldc = accldcmap.get(mapid);
            if(accldcstrmap.get(mapid) != null)
                promap = accldcstrmap.get(mapid);
            for(ldc_account__c ldc : innerldc){
              //  CapacitySum += (ldc.Capacity_PLC1__c != null) ? ldc.Capacity_PLC1__c : 0.0;
              // system.debug('========Sum==========='+CapacitySum);
                //if(ObjName == null)
                cwrapper = new cusWrapper();
                string str = ldc.FRM_Profile__c+'-'+ldc.Utility_Zone__c;
                system.debug('Promap : '+promap.size()+' : '+promap);
                if(promap.containskey(str)){
                    cwrapper = promap.get(str);
                    cwrapper.Acctadu+= (ldc.Acct_ADU__c != null) ? ldc.Acct_ADU__c : 0.0;
                    cwrapper.NSPLCkw+= (ldc.NSPL1_KW__c != null) ? ldc.NSPL1_KW__c : ((ldc.NSPL2_KW__c != null) ? ldc.NSPL2_KW__c : 0.0);
                    cwrapper.CapacityPLC+= (ldc.Capacity_PLC1__c != null) ? ldc.Capacity_PLC1__c : 0.0;
                    cwrapper.Capacity+= (ldc.Capacity_PLC1__c != null) ? ldc.Capacity_PLC1__c : ((ldc.Capacity_PLC2__c != null) ? ldc.Capacity_PLC2__c : 0.0);
                    cwrapper.totprice+= ((ldc.On_PK_Kwh__c != null) ? ldc.On_PK_Kwh__c : 0.0) + ((ldc.Off_PK_Kwh__c != null) ? ldc.Off_PK_Kwh__c : 0.0);
                    cwrapper.TotAccounts++;
                }
                else{
                    cwrapper = new cusWrapper();
                    cwrapper.Acctadu = (ldc.Acct_ADU__c != null) ? ldc.Acct_ADU__c : 0.0;
                    cwrapper.NSPLCkw = (ldc.NSPL1_KW__c != null) ? ldc.NSPL1_KW__c : ((ldc.NSPL2_KW__c != null) ? ldc.NSPL2_KW__c : 0.0);
                    cwrapper.CapacityPLC = (ldc.Capacity_PLC1__c != null) ? ldc.Capacity_PLC1__c : 0.0;
                    cwrapper.Capacity= (ldc.Capacity_PLC1__c != null) ? ldc.Capacity_PLC1__c : ((ldc.Capacity_PLC2__c != null) ? ldc.Capacity_PLC2__c : 0.0);
                    cwrapper.Totprice = ((ldc.On_PK_Kwh__c != null) ? ldc.On_PK_Kwh__c : 0.0) + ((ldc.Off_PK_Kwh__c != null) ? ldc.Off_PK_Kwh__c : 0.0);
                    cwrapper.TotAccounts = 1;
                }
                cwrapper.Vendor = ldc.ldc_vendor__r.name;
                cwrapper.Rateclass = ldc.Utility_Rate_Class__c;                     
                promap.put(str,cwrapper);
            }
            accldcstrmap.put(mapid,promap);
        }
        system.debug('Check : '+accldcstrmap.size()+' : '+accldcstrmap);
        
        list<account> acclst = new list<account>();
        //if(ObjName == null){
        for(account a : [select id,LDC_Individual_Info__c from account where id IN : accldcstrmap.keyset()]){
            a.LDC_Individual_Info__c = '';
            acclst.add(a);
        }
        if(!acclst.isempty())update acclst;
        //}
        acclst = new list<account>();
        system.debug('Acc size : '+acclst.size());
        for(ID mapid : accldcstrmap.keyset()){
        //  CapacitySum = 0;
            map<string,cusWrapper> cwrapmap = accldcstrmap.get(mapid);
            system.debug('cwrapmap : '+mapid+' : '+cwrapmap);
            account acc = new account();
            acc.CustomerPLC__c = 0;
            for(string str : cwrapmap.keyset()){
                if(acc.LDC_Individual_Info__c == null)
                    acc.LDC_Individual_Info__c = str+':';
                else
                    acc.LDC_Individual_Info__c+= str+':';
                    
                acc.LDC_Individual_Info__c+= 'Acctadu<'+cwrapmap.get(str).Acctadu+'>';
                acc.LDC_Individual_Info__c+= 'NSPLCkw<'+cwrapmap.get(str).NSPLCkw+'>';
                acc.LDC_Individual_Info__c+= 'Capacity<'+cwrapmap.get(str).Capacity+'>';
                acc.LDC_Individual_Info__c+= 'Totprice<'+cwrapmap.get(str).Totprice+'>';
                acc.LDC_Individual_Info__c+= 'Rateclass<'+cwrapmap.get(str).Rateclass+'>';
                acc.LDC_Individual_Info__c+= 'Vendor<'+cwrapmap.get(str).Vendor+'>';
                acc.LDC_Individual_Info__c+= 'TotAccounts<'+cwrapmap.get(str).TotAccounts+'>; \n';
                
                if(cwrapmap.containsKey(str) && cwrapmap.get(str).CapacityPLC != null){      
                    acc.CustomerPLC__c += cwrapmap.get(str).CapacityPLC;
                }                                                            
            }           
            acc.id = mapid;
         // acc.CustomerPLC__c = CapacitySum;
            system.debug('====CustomerPLC===='+acc.customerPLC__c);
            acclst.add(acc);
        }
        
        system.debug('Test check : '+acclst.size()+' : '+acclst);
        if(!acclst.isempty())update acclst;   
        
        /********************* C&I accounts at Opportunity Level  ***********************/
        for(ID mapid : oldcmap.keySet()){
            map<string,cusWrapper> promap = new map<string,cusWrapper>();
            list<ldc_account__c> innerldc = oldcmap.get(mapid);
            if(oppldcstrmap.get(mapid) != null)
                promap = oppldcstrmap.get(mapid);
            for(ldc_account__c ldc : innerldc){
                //if(ObjName == null)
                cwrapper = new cusWrapper();
                string str = ldc.FRM_Profile__c+'-'+ldc.Utility_Zone__c;
                system.debug('Promap : '+promap.size()+' : '+promap);
                if(promap.containskey(str)){
                    cwrapper = promap.get(str);
                    cwrapper.Acctadu+= (ldc.Acct_ADU__c != null) ? ldc.Acct_ADU__c : 0.0;
                    cwrapper.NSPLCkw+= (ldc.NSPL1_KW__c != null) ? ldc.NSPL1_KW__c : ((ldc.NSPL2_KW__c != null) ? ldc.NSPL2_KW__c : 0.0);
                    cwrapper.Capacity+= (ldc.Capacity_PLC1__c != null) ? ldc.Capacity_PLC1__c : ((ldc.Capacity_PLC2__c != null) ? ldc.Capacity_PLC2__c : 0.0);
                    cwrapper.totprice+= ((ldc.On_PK_Kwh__c != null) ? ldc.On_PK_Kwh__c : 0.0) + ((ldc.Off_PK_Kwh__c != null) ? ldc.Off_PK_Kwh__c : 0.0);
                    cwrapper.TotAccounts++;
                }
                else{
                    cwrapper = new cusWrapper();
                    cwrapper.Acctadu = (ldc.Acct_ADU__c != null) ? ldc.Acct_ADU__c : 0.0;
                    cwrapper.NSPLCkw = (ldc.NSPL1_KW__c != null) ? ldc.NSPL1_KW__c : ((ldc.NSPL2_KW__c != null) ? ldc.NSPL2_KW__c : 0.0);
                    cwrapper.Capacity= (ldc.Capacity_PLC1__c != null) ? ldc.Capacity_PLC1__c : ((ldc.Capacity_PLC2__c != null) ? ldc.Capacity_PLC2__c : 0.0);
                    cwrapper.Totprice = ((ldc.On_PK_Kwh__c != null) ? ldc.On_PK_Kwh__c : 0.0) + ((ldc.Off_PK_Kwh__c != null) ? ldc.Off_PK_Kwh__c : 0.0);
                    cwrapper.TotAccounts = 1;
                }
                cwrapper.Vendor = ldc.ldc_vendor__r.name;
                cwrapper.Rateclass = ldc.Utility_Rate_Class__c;                     
                promap.put(str,cwrapper);
            }
            oppldcstrmap.put(mapid,promap);
        }
        system.debug('Check Opp level: '+oppldcstrmap.size()+' : '+oppldcstrmap);  
        
        list<opportunity> opplst = new list<opportunity>();
        for(opportunity o : [select id,LDC_Individual_Info__c from opportunity where id IN : oppldcstrmap.keyset()]){
            o.LDC_Individual_Info__c = '';
            opplst.add(o);
        }
        if(!opplst.isempty())update opplst;

        opplst = new list<opportunity>();
        system.debug('Opp size : '+opplst.size());
        for(ID mapid : oppldcstrmap.keyset()){
            map<string,cusWrapper> cwrapmap = oppldcstrmap.get(mapid);
            system.debug('cwrapmap : '+mapid+' : '+cwrapmap);
            opportunity opp = new opportunity();
            for(string str : cwrapmap.keyset()){
                if(opp.LDC_Individual_Info__c == null)
                    opp.LDC_Individual_Info__c = str+':';
                else
                    opp.LDC_Individual_Info__c+= str+':';
                    
                opp.LDC_Individual_Info__c+= 'Acctadu<'+cwrapmap.get(str).Acctadu+'>';
                opp.LDC_Individual_Info__c+= 'NSPLCkw<'+cwrapmap.get(str).NSPLCkw+'>';
                opp.LDC_Individual_Info__c+= 'Capacity<'+cwrapmap.get(str).Capacity+'>';
                opp.LDC_Individual_Info__c+= 'Totprice<'+cwrapmap.get(str).Totprice+'>';
                opp.LDC_Individual_Info__c+= 'Rateclass<'+cwrapmap.get(str).Rateclass+'>';
                opp.LDC_Individual_Info__c+= 'Vendor<'+cwrapmap.get(str).Vendor+'>';
                opp.LDC_Individual_Info__c+= 'TotAccounts<'+cwrapmap.get(str).TotAccounts+'>; \n';
            }
            opp.id = mapid;
            opplst.add(opp);
        }
        if(!opplst.isempty())update opplst;
        
        for(ldc_account__c ldc : ldclst){
            ldc.Is_Record_updated__c = false;
        }  
        if(!ldclst.isempty()){
            TriggerHandler.firstRun=false;
            update ldclst;
        } 
    }
    
    global void finish (Database.BatchableContext bc){
        
    }
    
    public class cusWrapper{
        public decimal Acctadu {get;set;}
        public decimal NSPLCkw {get;set;}
        public decimal Capacity {get;set;}
        public decimal CapacityPLC {get;set;}
        public decimal Totprice {get;set;}
        public string Rateclass {get;set;}
        public string Vendor {get;set;}
        public integer TotAccounts {get;Set;}
        
        public cusWrapper(){
            
        }
        
        public cusWrapper(decimal adu,decimal nsplc, decimal plc, decimal CusPLC, decimal tot, string rclass, string vnd, integer acc){
            Acctadu = adu;
            NSPLCkw = nsplc;
            Capacity = plc;
            CapacityPLC = CusPLC;
            Totprice = tot;
            Rateclass = rclass;
            Vendor = vnd;
            TotAccounts = acc;
            
        }
    }
}