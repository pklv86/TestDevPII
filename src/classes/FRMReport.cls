/* 
 * Name: FRMReport
 * Type: Apex Class
 * Test Class: FRMReportTest
 * Description:  This class is to collect data from different object in Salesforce and group them into a single object for sending a report. 
 * Change History:
 *=====================================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu              11/22/2016       1. Initial Version created
 * 2.0         Prasad Paladugu              03/27/2017       1. Updated the flow of contracts
                                                             2. Enhanced Functionality To Muni-Agg Customers also
 * 3.0         Prasad Paladugu              05/09/2017       1. Enhance C&I Customer to Opportunity Level
 * 4.0         Prasad Paladugu              06/15/2017       1. Enhance Functionality to support IL- MuniAgg
 */
 
global class FRMReport implements system.schedulable,Database.stateful,Database.Batchable<sObject> {
    
    public static final Set<string> Acc_Rec=new Set<string> {'Muni Agg Customer','Muni Agg Individual Customer','Mass Market Offer'};
    list<FRM_Report__c> FRMinsert;
    global map<string,list<FRM_Report__c>> frmMap;
    global set<id> frmset;
    
    public FRMReport(){
    
    }
    
    global void execute(SchedulableContext SC){
        
        FRMReport frmbatch = new FRMReport();
        Database.executeBatch(frmbatch,100);
        
    }
    
    global Database.QueryLocator Start(Database.BatchableContext bc){
        
        frmset = new set<id>();
        //set<id> cntID = new set<id>{'80015000000te2a','80015000000te39','80015000000te5A','80015000000tfSj','80015000000tiwv','80015000000tkNE','80015000000tkNn','80015000000PD8G','80015000000tm8U','80015000000PCwF'};
        //and id IN: cntID  and account.recordtype.name NOT IN : Acc_Rec status != \'Draft\' and and id = \'80015000000VhUD\'and Retail_Quote__c != null
        
        string cntQuery = constantUtility.getObjectFieldsQuery('Contract')+',account.recordtype.name,owner.name,account.name,createdby.name,retail_quote__r.Include_In_TMF__c From contract where activateddate <= today order by accountid,status DESC,contractnumber,createddate'; 
        system.debug('Query : '+cntQuery);
        return Database.getQueryLocator(cntQuery);
    }
    
    global void execute(Database.BatchableContext bc,list<sObject> scope){
        
        list<contract> cntlst = (list<contract>)scope;
        set<id> cntSet = new set<id>();
        set<string> cntSetstr = new set<string>();
        set<id> accSet = new set<id>();
        set<id> oppSet = new set<id>();
        set<id> quoSet = new set<id>();
        map<id,map<string,list<Contract>>>  cmap = new map<id,map<string,list<contract>>>();
        for(Contract cnt : cntlst){
        	map<string,list<contract>> statusmap = new map<string,list<contract>>();
            list<contract> ctlst = new list<contract>();
            cntSet.add(cnt.id);
            cntsetstr.add(cnt.contractnumber);
            oppSet.add(cnt.Opportunity__c);
            quoSet.add(cnt.Retail_Quote__c);
            
            if(accset.contains(cnt.AccountId) && cnt.account.recordtype.name == 'Muni Agg Customer'){
            	statusmap = cmap.get(cnt.AccountId);
            	ctlst = new list<contract>();
            	if(statusmap.containskey(cnt.status)){
            		ctlst = statusmap.get(cnt.status);
            	}
                ctlst.add(cnt);
                statusmap.put(cnt.status,ctlst);
                cmap.put(cnt.AccountId,statusmap);
            }
            else{
                accSet.add(cnt.AccountId);
                if(cnt.account.recordtype.name == 'Muni Agg Customer')
	                ctlst.add(cnt);
	                statusmap.put(cnt.status,ctlst);
                	cmap.put(cnt.AccountId,statusmap);
            }
        }
        system.debug('Muni-Agg Cnt Map : '+cmap);
        set<id> cntRemove = new set<id>();
        set<string> cntstr = new set<string>();
        
        for(ID mapID : cmap.keyset()){
        	map<string,list<contract>> tempstmap = cmap.get(mapID);
    		list<contract> tempAcnt = new list<contract>();
    		list<contract> tempECcnt = new list<contract>();
    		//list<contract> tempcnt = new list<contract>();
        	boolean actcnt = false;
        	boolean hasInclude = false;
        	
        	for(string sts : tempstmap.keyset()){
        		if(sts == 'Activated')
        			actcnt = true;
    			list<contract> tcnt = tempstmap.get(sts);
    			for(contract ct : tcnt){
    				if(ct.retail_quote__r.Include_In_TMF__c == true)
    					hasInclude = true;
    			}
        	}
        	
        	if(hasInclude){
        		for(string sts : tempstmap.keyset()){
        			list<contract> tcnt = tempstmap.get(sts);
        			for(contract ct : tcnt){
	    				if(ct.retail_quote__r.Include_In_TMF__c != true)
	    					cntRemove.add(ct.id);
	    			}
	        	}
        	}
        	else{
	        	for(string sts : tempstmap.keyset()){
	        		if(actcnt && sts == 'Activated')
	        			tempAcnt = tempstmap.get('Activated');
	    			else{
	    				tempECcnt = (tempstmap.get('Expired') != null) ? tempstmap.get('Expired') : new list<contract>();
	    				if(tempstmap.get('Cancelled') != null){
	    					tempECcnt.addAll(tempstmap.get('Cancelled'));
	    				}
	    			}
	        	}
	        	
	        	if(actcnt && tempAcnt.size() > 1){
	        		cntRemove.addAll(calculateMuniaggCnt(tempAcnt));
	        	}
	        	if(!actcnt && tempECcnt.size() > 1){
	        		cntRemove.addAll(calculateMuniaggCnt(tempECcnt));
	        	}
	        	if(actcnt && tempECcnt.size() >= 1){
	        		for(contract ctemp :  tempECcnt)
	        			cntRemove.add(ctemp.id);
	        	}
        	}
        }
        
        system.debug('To Remmove List : '+cntRemove.size()+' : '+cntRemove+' : '+cntstr);
        system.debug('Before Removing from scope : '+cntlst.size());
        /*for(Integer i=cntlst.size()-1;i>=0;--i){
            if(cntRemove.contains(cntlst[i].id)){
                system.debug('Excluding muniagg contract : '+cntlst[i]);
                cntlst.remove(i);
            }
        }*/
        system.debug('After Removing from scope : '+cntlst.size());
        
        system.debug('Lists sizes Cnt : '+cntSet.size()+' Acc : '+accSet.size()+' Opp : '+oppSet.size()+' Quote : '+quoSet.size());
        system.debug('Acc Set : '+accSet);
        system.debug('CNT : '+cntsetstr);
        string quoQuery = constantutility.getObjectFieldsQuery('Retail_Quote__c')+' From Retail_Quote__c where id IN: quoset';
        transient map<id,Retail_Quote__c>quoMap = new map<id,Retail_Quote__c>((list<Retail_Quote__c>)Database.query(quoQuery));
        
        string oppQuery = 'Select id,name,accountid,LDC_Individual_Info__c From opportunity where id IN: oppset';
        transient map<id,opportunity>oppMap = new map<id,opportunity>((list<opportunity>)Database.query(oppQuery));
        
        string accQuery = 'select id,LDC_Individual_Info__c,BillingState From account where id IN: accset';//or business_account__c IN: accset
        transient map<id,account>accMap = new map<id,account>((list<account>)Database.query(accQuery));
        transient list<account> acclst = Database.query(accquery);
        
        string proQuery = 'Select id,name,productcode,isActive From product2 where isactive=true';
        map<id,product2>proMap = new map<id,product2>((list<product2>)Database.query(proQuery));
        
        frmMap = new map<string,list<FRM_Report__c>>();
        list<FRM_Report__c> frminnerlst;
        string frmQuery = constantUtility.getObjectFieldsQuery('FRM_Report__c')+' From FRM_Report__c where Contr_Agree_Num__c IN : cntsetstr';
        for(FRM_Report__c frm : Database.query(frmQuery)){
            frminnerlst = new list<FRM_Report__c>();
            system.debug('frmMap check : '+frmMap.size()+' : '+frm.FRM_Profile__c+' : '+frmMap.get(frm.Contr_Agree_Num__c));
            if(frmMap.containskey(frm.Contr_Agree_Num__c)){
                frminnerlst = frmMap.get(frm.Contr_Agree_Num__c);
                frminnerlst.add(frm);
            }
            else{
                 frminnerlst.add(frm);
             }
            frmMap.put(frm.Contr_Agree_Num__c,frminnerlst);
        }
        system.debug('Test : '+frmMap.size()+' : '+frmMap);
        //frminnerlst.clear();
        
        FRMinsert = new list<FRM_Report__c>();
        for(Contract cnt : cntlst){
            FRM_Report__c frm = new FRM_Report__c();
            
            Boolean hasQuote = (quomap.get(cnt.Retail_Quote__c) != null) ? true : false;
            Boolean hasOppty = (oppmap.get(cnt.opportunity__c) != null) ? true : false;
            Integer contractDays = cnt.StartDate.daysBetween(cnt.End_Date__c);

            system.debug('FRM Default Values : '+frm);
            Boolean strfound = false;
            Boolean doOnce = false;
            if(cnt.account.recordtype.name == 'C&I Customer'){
                if(hasOppty){
                    string str = oppMap.get(cnt.opportunity__c).LDC_Individual_Info__c;
                    list<string> strlst = str != null ? str.split(';') : new list<string>();
                    if(strlst.size() > 1){
                        for(string s : strlst){
                            strfound = false;
                            FRM_Report__c frmclone = new FRM_Report__c(); 
                            string instr = s.deleteWhitespace();
                            if(frmMap.get(cnt.contractnumber) != null){
                                frminnerlst = new list<FRM_Report__c>();
                                frminnerlst = frmMap.get(cnt.contractnumber);
                                system.debug('Multi C&I : '+frminnerlst.size()+' : '+frminnerlst);
                                for(FRM_Report__c  frminner : frminnerlst){
                                    system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr.substringBefore(':'));
                                    if(frminner.FRM_Profile_Zone__c == instr.substringBefore(':')){
                                        frmclone = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                        strfound = true;
                                    }
                                }
                                if(!strfound){
                                	frm = new FRM_Report__c();
                                    frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                                }
                            }
                            else{
                            	frm = new FRM_Report__c();
                                frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                            }
                            frmclone.FRM_Profile_Zone__c = instr.substringBefore(':');
                            frmclone.FRM_Profile__c = (frmclone.FRM_Profile_Zone__c.substringAfter('-') == 'null') ? instr.substringBefore('-') : instr.substringBefore(':');
                            frmclone.NSPLC_Kw_Transaction__c = (instr.substringBetween('NSPLCkw<','>') != null) ? Decimal.valueof(instr.substringBetween('NSPLCkw<','>')) : 0; 
                            frmclone.PLC_Kw_Transaction__c = (instr.substringBetween('Capacity<','>') != null) ? Decimal.valueof(instr.substringBetween('Capacity<','>')) : 0;
                            frmclone.Tot_Priced_Mwh__c = (instr.substringBetween('Totprice<','>') != null) ? (Decimal.valueof(instr.substringBetween('Totprice<','>'))/365000)*contractDays : 0;
                            frmclone.ADU_Exp_Mwhs__c = (instr.substringBetween('Acctadu<','>') != null) ? Decimal.valueof(instr.substringBetween('Acctadu<','>'))*0.001 : 0;
                            frmclone.Utility_Rate_Class__c = (frmclone.FRM_Profile__c == 'null' || frmclone.FRM_Profile__c.startswith('N/A') || string.isBlank(frmclone.FRM_Profile__c)) ? instr.substringBetween('Rateclass<','>') : null;
                            frmclone.LDC_Vendor__c = (instr.substringBetween('Vendor<','>') != null) ? instr.substringBetween('Vendor<','>') : null;
                            FRMinsert.add(frmclone);        
                        }
                    }
                    else if(strlst.size() == 1){
                        string instr = strlst[0].deleteWhitespace();
                        if(frmMap.get(cnt.contractnumber) != null){
                            frminnerlst = new list<FRM_Report__c>();
                            frminnerlst = frmMap.get(cnt.contractnumber);
                            system.debug('Single C&I : '+frminnerlst.size()+' : '+frminnerlst);
                            for(FRM_Report__c  frminner : frminnerlst){
                                system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr.substringBefore(':'));
                                if(frminner.FRM_Profile_Zone__c == instr.substringBefore(':')){
                                    frm = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                    strfound = true;
                                }
                            }
                            if(!strfound){
                            	frm = new FRM_Report__c();
                                frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                            }
                        }
                        else{
                        	frm = new FRM_Report__c();
                            frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                        }
                        frm.FRM_Profile_Zone__c = instr.substringBefore(':');
                        frm.FRM_Profile__c = (frm.FRM_Profile_Zone__c.substringAfter('-') == 'null') ? instr.substringBefore('-') : instr.substringBefore(':');
                        frm.NSPLC_Kw_Transaction__c = (instr.substringBetween('NSPLCkw<','>') != null) ? Decimal.valueof(instr.substringBetween('NSPLCkw<','>')) : 0;  
                        frm.PLC_Kw_Transaction__c = (instr.substringBetween('Capacity<','>') != null) ? Decimal.valueof(instr.substringBetween('Capacity<','>')) : 0;
                        frm.Tot_Priced_Mwh__c = (instr.substringBetween('Totprice<','>') != null) ? (Decimal.valueof(instr.substringBetween('Totprice<','>'))/365000)*contractDays : 0;
                        frm.ADU_Exp_Mwhs__c = (instr.substringBetween('Acctadu<','>') != null) ? Decimal.valueof(instr.substringBetween('Acctadu<','>'))*0.001 : 0;
                        frm.Utility_Rate_Class__c = (frm.FRM_Profile__c == 'null' || frm.FRM_Profile__c.startswith('N/A') || string.isBlank(frm.FRM_Profile__c)) ? instr.substringBetween('Rateclass<','>') : null;
                        frm.LDC_Vendor__c = (instr.substringBetween('Vendor<','>') != null) ? instr.substringBetween('Vendor<','>') : null;
                        FRMinsert.add(frm);     
                    }
                }
                else{
                    string str = accMap.get(cnt.accountid).LDC_Individual_Info__c;
                    list<string> strlst = str != null ? str.split(';') : new list<string>();
                    if(strlst.size() > 1){
                        for(string s : strlst){
                            strfound = false;
                            FRM_Report__c frmclone = new FRM_Report__c(); 
                            string instr = s.deleteWhitespace();
                            if(frmMap.get(cnt.contractnumber) != null){
                                frminnerlst = new list<FRM_Report__c>();
                                frminnerlst = frmMap.get(cnt.contractnumber);
                                system.debug('Multi C&I : '+frminnerlst.size()+' : '+frminnerlst);
                                for(FRM_Report__c  frminner : frminnerlst){
                                    system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr.substringBefore(':'));
                                    if(frminner.FRM_Profile_Zone__c == instr.substringBefore(':')){
                                        frmclone = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                        strfound = true;
                                    }
                                }
                                if(!strfound){
                                	frm = new FRM_Report__c();
                                    frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                                }
                            }
                            else{
                            	frm = new FRM_Report__c();
                                frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                            }
                            frmclone.FRM_Profile_Zone__c = instr.substringBefore(':');
                            frmclone.FRM_Profile__c = (frmclone.FRM_Profile_Zone__c.substringAfter('-') == 'null') ? instr.substringBefore('-') : instr.substringBefore(':');
                            frmclone.NSPLC_Kw_Transaction__c = (instr.substringBetween('NSPLCkw<','>') != null) ? Decimal.valueof(instr.substringBetween('NSPLCkw<','>')) : 0; 
                            frmclone.PLC_Kw_Transaction__c = (instr.substringBetween('Capacity<','>') != null) ? Decimal.valueof(instr.substringBetween('Capacity<','>')) : 0;
                            frmclone.Tot_Priced_Mwh__c = (instr.substringBetween('Totprice<','>') != null) ? (Decimal.valueof(instr.substringBetween('Totprice<','>'))/365000)*contractDays : 0;
                            frmclone.ADU_Exp_Mwhs__c = (instr.substringBetween('Acctadu<','>') != null) ? Decimal.valueof(instr.substringBetween('Acctadu<','>'))*0.001 : 0;
                            frmclone.Utility_Rate_Class__c = (frmclone.FRM_Profile__c == 'null' || frmclone.FRM_Profile__c.startswith('N/A') || string.isBlank(frmclone.FRM_Profile__c)) ? instr.substringBetween('Rateclass<','>') : null;
                            frmclone.LDC_Vendor__c = (instr.substringBetween('Vendor<','>') != null) ? instr.substringBetween('Vendor<','>') : null;
                            FRMinsert.add(frmclone);        
                        }
                    }
                    else if(strlst.size() == 1){
                        string instr = strlst[0].deleteWhitespace();
                        if(frmMap.get(cnt.contractnumber) != null){
                            frminnerlst = new list<FRM_Report__c>();
                            frminnerlst = frmMap.get(cnt.contractnumber);
                            system.debug('Single C&I : '+frminnerlst.size()+' : '+frminnerlst);
                            for(FRM_Report__c  frminner : frminnerlst){
                                system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr.substringBefore(':'));
                                if(frminner.FRM_Profile_Zone__c == instr.substringBefore(':')){
                                    frm = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                    strfound = true;
                                }
                            }
                            if(!strfound){
                            	frm = new FRM_Report__c();
                                frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                            }
                        }
                        else{
                        	frm = new FRM_Report__c();
                            frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                        }
                        frm.FRM_Profile_Zone__c = instr.substringBefore(':');
                        frm.FRM_Profile__c = (frm.FRM_Profile_Zone__c.substringAfter('-') == 'null') ? instr.substringBefore('-') : instr.substringBefore(':');
                        frm.NSPLC_Kw_Transaction__c = (instr.substringBetween('NSPLCkw<','>') != null) ? Decimal.valueof(instr.substringBetween('NSPLCkw<','>')) : 0;  
                        frm.PLC_Kw_Transaction__c = (instr.substringBetween('Capacity<','>') != null) ? Decimal.valueof(instr.substringBetween('Capacity<','>')) : 0;
                        frm.Tot_Priced_Mwh__c = (instr.substringBetween('Totprice<','>') != null) ? (Decimal.valueof(instr.substringBetween('Totprice<','>'))/365000)*contractDays : 0;
                        frm.ADU_Exp_Mwhs__c = (instr.substringBetween('Acctadu<','>') != null) ? Decimal.valueof(instr.substringBetween('Acctadu<','>'))*0.001 : 0;
                        frm.Utility_Rate_Class__c = (frm.FRM_Profile__c == 'null' || frm.FRM_Profile__c.startswith('N/A') || string.isBlank(frm.FRM_Profile__c)) ? instr.substringBetween('Rateclass<','>') : null;
                        frm.LDC_Vendor__c = (instr.substringBetween('Vendor<','>') != null) ? instr.substringBetween('Vendor<','>') : null;
                        FRMinsert.add(frm);     
                    }
                }
            }
            else if (cnt.account.recordtype.name == 'Mass Market Offer'){
                string str = accMap.get(cnt.accountid).LDC_Individual_Info__c;
                list<string> strlst = str != null ? str.split(';') : new list<string>();
                if(strlst.size() > 1){
                    for(string s : strlst){
                        strfound = false;
                        FRM_Report__c frmclone = new FRM_Report__c();
                        string instr = s.deleteWhitespace();
                        if(frmMap.get(cnt.contractnumber) != null){
                            frminnerlst = new list<FRM_Report__c>();
                            frminnerlst = frmMap.get(cnt.contractnumber);
                            system.debug('Multi MM : '+frminnerlst.size()+' : '+frminnerlst);
                            for(FRM_Report__c  frminner : frminnerlst){
                                system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr.substringBefore(':'));
                                if(frminner.FRM_Profile_Zone__c == instr.substringBefore(':')){
                                    frmclone = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                    strfound = true;
                                }
                            }
                            if(!strfound){
                            	frm = new FRM_Report__c();
                                frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                            }
                        }
                        else{
                        	frm = new FRM_Report__c();
                            frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                        }
                        frmclone.FRM_Profile_Zone__c = instr.substringBefore(':');
                        frmclone.FRM_Profile__c = (frmclone.FRM_Profile_Zone__c.substringAfter('-') == 'null') ? instr.substringBefore('-') : instr.substringBefore(':');
                        frmclone.NSPLC_Kw_Transaction__c = (instr.substringBetween('NSPLCkw<','>') != null) ? Decimal.valueof(instr.substringBetween('NSPLCkw<','>')) : 0; 
                        frmclone.PLC_Kw_Transaction__c = (instr.substringBetween('Capacity<','>') != null) ? Decimal.valueof(instr.substringBetween('Capacity<','>')) : 0;
                        frmclone.Tot_Priced_Mwh__c = (instr.substringBetween('Totprice<','>') != null) ? (Decimal.valueof(instr.substringBetween('Totprice<','>'))/365000)*contractDays : 0;
                        frmclone.ADU_Exp_Mwhs__c = (instr.substringBetween('Acctadu<','>') != null) ? Decimal.valueof(instr.substringBetween('Acctadu<','>'))*0.001 : 0;
                        frmclone.Utility_Rate_Class__c = (frmclone.FRM_Profile__c == 'null' || frmclone.FRM_Profile__c.startswith('N/A') || string.isBlank(frmclone.FRM_Profile__c)) ? instr.substringBetween('Rateclass<','>') : null;
                        frmclone.LDC_Vendor__c = (instr.substringBetween('Vendor<','>') != null) ? instr.substringBetween('Vendor<','>') : null;
                        FRMinsert.add(frmclone);        
                    }
                }
                else if(strlst.size() == 1){
                    string instr = strlst[0].deleteWhitespace();
                    if(frmMap.get(cnt.contractnumber) != null){
                        frminnerlst = new list<FRM_Report__c>();
                        frminnerlst = frmMap.get(cnt.contractnumber);
                        system.debug('Single MM : '+frminnerlst.size()+' : '+frminnerlst);
                        for(FRM_Report__c  frminner : frminnerlst){
                            system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr.substringBefore(':'));
                            if(frminner.FRM_Profile_Zone__c == instr.substringBefore(':')){
                                frm = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                strfound = true;
                            }
                        }
                        if(!strfound){
                        	frm = new FRM_Report__c();
                            frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                        }
                    }
                    else{
                    	frm = new FRM_Report__c();
                        frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                    }
                    frm.FRM_Profile_Zone__c = instr.substringBefore(':');
                    frm.FRM_Profile__c = (frm.FRM_Profile_Zone__c.substringAfter('-') == 'null') ? instr.substringBefore('-') : instr.substringBefore(':');
                    frm.NSPLC_Kw_Transaction__c = (instr.substringBetween('NSPLCkw<','>') != null) ? Decimal.valueof(instr.substringBetween('NSPLCkw<','>')): 0;  
                    frm.PLC_Kw_Transaction__c = (instr.substringBetween('Capacity<','>') != null) ? Decimal.valueof(instr.substringBetween('Capacity<','>')) : 0;
                    frm.Tot_Priced_Mwh__c = (instr.substringBetween('Totprice<','>') != null) ? (Decimal.valueof(instr.substringBetween('Totprice<','>'))/365000)*contractDays : 0;
                    frm.ADU_Exp_Mwhs__c = (instr.substringBetween('Acctadu<','>') != null) ? Decimal.valueof(instr.substringBetween('Acctadu<','>'))*0.001 : 0;
                    frm.Utility_Rate_Class__c = (frm.FRM_Profile__c == 'null' || frm.FRM_Profile__c.startswith('N/A') || string.isBlank(frm.FRM_Profile__c)) ? instr.substringBetween('Rateclass<','>') : null;
                    frm.LDC_Vendor__c = (instr.substringBetween('Vendor<','>') != null) ? instr.substringBetween('Vendor<','>') : null;
                    FRMinsert.add(frm);     
                }
            }
            else if(cnt.account.recordtype.name == 'Muni Agg Customer'){
                string str= (hasQuote == true) ? quoMap.get(cnt.retail_quote__c).Muniagg_Profiling__c : null;
                list<string> strlst = (str != null) ? str.split(';') : new list<string>();
                if(strlst.size() > 1){
                    for(string s : strlst){
                        strfound = false;
                        FRM_Report__c frmclone = new Frm_report__c();
                        list<string> slst = (s != null) ? s.split(',') : new list<string>();
                        string instr = slst[0].deleteWhitespace();
                        if(frmMap.get(cnt.contractnumber) != null){
                            frminnerlst = new list<FRM_Report__c>();
                            frminnerlst = frmMap.get(cnt.contractnumber);
                            system.debug('Multi Muni : '+frminnerlst.size()+' : '+frminnerlst);
                            for(FRM_Report__c  frminner : frminnerlst){
                                system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr);
                                if(frminner.FRM_Profile_Zone__c == 'null' && !doOnce){
                                    frmclone = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                    doOnce = true;
                                    strfound = true;
                                }
                                else if(frminner.FRM_Profile_Zone__c == instr && !doOnce){
                                    frmclone = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                    strfound = true;
                                }
                            }
                            if(!strfound){
                            	frm = new FRM_Report__c();
                                frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                            }
                        }
                        else{
                        	frm = new FRM_Report__c();
                            frmclone = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                        }
                        frmclone.FRM_Profile_Zone__c = slst[0];  
                        frmclone.FRM_Profile__c = slst[0].substringBeforeLast('-');
                        frmclone.NSPLC_Kw_Transaction__c = quoMap.get(cnt.Retail_Quote__c).Aggregate_PLC__c; 
                        frmclone.Tot_Priced_Mwh__c = quoMap.get(cnt.retail_quote__c).Total_Priced_MWH__c;
                        frmclone.ADU_Exp_Mwhs__c = Decimal.valueof(slst[1].deleteWhitespace());
                        FRMinsert.add(frmclone);
                    }
                }
                else if(strlst.size() == 1){
                    list<string> slst = (strlst[0] != null) ? strlst[0].split(',') : new list<string>();
                    string instr = slst[0].deleteWhitespace();
                    if(frmMap.get(cnt.contractnumber) != null){
                        frminnerlst = new list<FRM_Report__c>();
                        frminnerlst = frmMap.get(cnt.contractnumber);
                        system.debug('Single Muni : '+frminnerlst.size()+' : '+frminnerlst);
                        for(FRM_Report__c  frminner : frminnerlst){
                            system.debug('Check equal : '+frminner.FRM_Profile_Zone__c+' : '+instr);
                            if(frminner.FRM_Profile_Zone__c == instr || frminner.FRM_Profile_Zone__c == 'null'){
                                frm = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                                strfound = true;
                            }
                        }
                        if(!strfound){
                        	frm = new FRM_Report__c();
                            frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                        }
                    }
                    else{
                    	frm = new FRM_Report__c();
                        frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                    }
                    
                    frm.FRM_Profile_Zone__c = slst[0];
                    frm.FRM_Profile__c = slst[0].substringBeforeLast('-');
                    frm.NSPLC_Kw_Transaction__c = quoMap.get(cnt.Retail_Quote__c).Aggregate_PLC__c; 
                    frm.Tot_Priced_Mwh__c = quoMap.get(cnt.retail_quote__c).Total_Priced_MWH__c;
                    frm.ADU_Exp_Mwhs__c = Decimal.valueof(slst[1].deleteWhitespace());
                    FRMinsert.add(frm);
                }
                else{
                	system.debug('CHeck : '+strlst+' Contract Number : '+cnt.contractnumber);
                	system.debug('CHeck : '+frmMap.get(cnt.contractnumber));
                    if(frmMap.get(cnt.contractnumber) == null){
                    	frm = new FRM_Report__c();
                    	frm = cloneDeal(frm,cnt,oppmap,quomap,promap,cntRemove);
                        frm.FRM_Profile__c = Null;
                        frm.FRM_Profile_Zone__c = Null;
                        frm.NSPLC_Kw_Transaction__c = (hasQuote == true) ? quoMap.get(cnt.Retail_Quote__c).Aggregate_PLC__c : null;
                        frm.Tot_Priced_Mwh__c = 0.0;
                        frm.ADU_Exp_Mwhs__c = 0.0;
                        FRMinsert.add(frm);
                    }
                    else{
                    	FRM_Report__c frmclone = new Frm_report__c();
                    	frminnerlst = new list<FRM_Report__c>();
                        frminnerlst = frmMap.get(cnt.contractnumber);
                        system.debug('FRM Clone : '+frminnerlst);
                    	for(frm_report__c frminner : frminnerlst){
                    		if(frminner.FRM_Profile_Zone__c == Null)
                    			frmclone = cloneDeal(frminner,cnt,oppmap,quomap,promap,cntRemove);
                    	}
                        frmclone.NSPLC_Kw_Transaction__c = (hasQuote == true) ? quoMap.get(cnt.Retail_Quote__c).Aggregate_PLC__c : null;
                        FRMinsert.add(frmclone);
                    }
                }
            }
        }
        system.debug('list : '+FRMinsert);

        if(!FRMinsert.isempty()){
            upsert FRMinsert;
        }
    }
    
    global void finish(Database.BatchableContext bc){
    
        if(FRMinsert == null)
            FRMinsert = new list<FRM_Report__c>();
        Integer CIOH = 0;
        Integer MMOH = 0;
        Integer MuOH = 0;
        Integer CIIL = 0;
        Integer MMIL = 0;
        Integer MuIL = 0;
        Integer TotOH = 0;
        Integer TotIL = 0;
        Integer Total = 0;
        for(FRM_Report__c frm : [select id,Cust_Type__c,cust_code__c,state__c from FRM_Report__c where createddate = today]){ // or lastmodifieddate = today
            system.debug('FRM Report : '+frm);
            if(frm.Cust_Type__c == 'C&I'){
                if(frm.state__c == 'OH')
                    CIOH++;
                else
                    CIIL++;
            }
            else if(frm.cust_code__c == 'Mass Market'){
                 if(frm.state__c == 'OH')
                    MMOH++;
                else
                    MMIL++;
            }
            else{
                if(frm.state__c == 'OH')
                    MuOH++;
                else
                    MuIL++;
            }
        }
        TotOH = CIOH + MMOH + MuOH;
        TotIL = CIIL + MMIL + MuIL;
        Total = TotOH + TotIL;
        
        string res='<table border="1"><tr><th>Customer Type</th><th>Ohio Deals</th><th>Illinois Deals</th><th></th></tr><br/>';
        res+='<tr><td>C&I Customers</td><td>'+CIOH+'</td><td>'+CIIL+'</td></tr><br/>';
        res+='<tr><td>Mass Market  </td><td>'+MMOH+'</td><td>'+MMIL+'</td></tr><br/>';
        res+='<tr><td>Muni-Agg  </td><td>'+MuOH+'</td><td>'+MuIL+'</td></tr><br/>';
        res+='<tr><td>Total Contracts</td><td>'+TotOH+'</td><td>'+TotIL+'</td></tr><br/>';
        res+='</table><pre><b>';
        res+='<br/>         ----------------';
        res+='<br/>             '+Total+'   ';
        res+='<br/>         ----------------</b></pre>';
        string mailerslst = label.TMF_Mailers;
        list<string> mailerstr = mailerslst.split(';');
        list<user> usr = [select id,name,email from user where name IN : mailerstr];
        list<string> mailers = new list<string>();
        for(User U : Usr){
            mailers.add(u.email);
        }
        mailerslst = label.TMF_Email_List;
        list<string> email = mailerslst.split(';');
        mailers.addAll(email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailers);
        mail.setSubject('TMF Report for '+system.now().format('dd-MMM yyyy'));
        mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 
        mail.setHtmlBody('The FRM Report is generated with following and we will be available shortly \n<br/>'+res+'<br/> ');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
        
        FRMDeleter frmdel = new FRMDeleter();
        Database.executeBatch(frmdel,2000);
    }
    
    public static string getSTerritory(string st){
        string sTerritory ='';
        
        if(st == 'AMIL.AEM.IL' || st == 'Ameren-IL')
            sTerritory ='Ameren-IL';    
        else if(st == 'COMED' || st == 'ComEd-IL')
            sTerritory ='ComEd-IL';
        else if(st == 'DEOK_RESID_AGG' || st == 'DEOHIO')
            sTerritory ='DEOHIO';
        else if(st == 'FEOH_RESID_AGG' || st == 'FEOHIO')
            sTerritory ='FEOHIO';
        else if(st == 'AEPOHIO_RESID_AGG' || st == 'AEPOHIO')
            sTerritory ='AEPOHIO';
        else if(st == 'DAY_RESID_AGG' || st == 'DAYTON')
            sTerritory ='DAYTON';
        else if(st == 'APS_RESID_AGG')
            sTerritory ='APS';
        else
            sTerritory ='';
            
        system.debug('IN STR : '+st+' --> OUT STR : '+sTerritory);
        
        return sTerritory;
    }
    
    public static frm_report__c cloneDeal(Frm_report__c frm, Contract cnt, map<id,opportunity> oppMap, map<id,Retail_Quote__c> quoMap, map<id,product2> proMap, set<id> cntRemove){
		
		Boolean hasQuote = (quomap.get(cnt.Retail_Quote__c) != null) ? true : false;
        Boolean hasOppty = (oppmap.get(cnt.opportunity__c) != null) ? true : false;
        
        if(cntRemove.contains(cnt.id) && !(hasquote && quomap.get(cnt.Retail_Quote__c).Include_In_TMF__c))
        	frm.Reconcile__c = true;
    	else
    		frm.Reconcile__c = false;
        
        if(cnt.status == 'Activated')
            frm.Risk_Approval__c = 'APPROVED';
        else if(cnt.status == 'Draft')
            frm.Risk_Approval__c = 'ENTRY';
        else if(cnt.status == 'Cancelled')
            frm.Risk_Approval__c = 'VOID';
        else if(cnt.status == 'Expired')
            frm.Risk_Approval__c = 'EXPIRED';
            
        if(cnt.account.recordtype.name == 'C&I Customer'){  
            frm.Cust_Code__c = cnt.opportunity__c;
            frm.Cust_Name__c = (oppMap.get(cnt.opportunity__c) != null) ? oppMap.get(cnt.opportunity__c).name : cnt.account.name;
            frm.Cust_Name__c = (frm.Cust_Name__c.length() < 120) ? frm.Cust_Name__c : frm.Cust_Name__c.subString(0,119);
            frm.Cust_Type__c = 'C&I';
        }
        else if (cnt.account.recordtype.name == 'Mass Market Offer'){
            frm.Cust_Code__c = 'Mass Market';
            frm.Cust_Name__c = cnt.account.name;
            frm.Cust_Type__c = 'Residential';
        }
        else if (cnt.account.recordtype.name == 'Muni Agg Customer'){
            frm.Cust_Code__c = 'Muni-Agg';
            frm.Cust_Name__c = cnt.account.name;
            frm.Cust_Type__c = 'Residential';
        }
        
        if(cnt.service_territory__c == null && cnt.createdby.Name == 'RM_CONV'){
            frm.State__c = 'OH';
            frm.Vol_Rec_Prod_Type__c = (hasQuote == true && quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c != null) ? quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c : 'OH - RPS Compliant';
            frm.Book_Name__c = 'DESE-Retail-Accrual';
        }
        else if(cnt.service_territory__c == null && cnt.createdby.Name == 'IA_CONV'){
            frm.State__c = 'IL';
            frm.Vol_Rec_Prod_Type__c = (hasQuote == true && quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c != null) ? quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c : 'IL - RPS Compliant';
            frm.Book_Name__c = 'DES-Retail-Accrual';
        }
        else if(cnt.service_territory__c != null && cnt.service_territory__c.contains('-IL')){
            frm.State__c = 'IL';
            frm.Vol_Rec_Prod_Type__c = (hasQuote == true && quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c != null) ? quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c : 'IL - RPS Compliant';
            frm.Book_Name__c = (cnt.service_territory__c.contains('Comed-IL')) ? 'DES-Retail-Accrual' : 'IPH-Retail-Accrual'; 
        }
        else if(cnt.service_territory__c != null && cnt.service_territory__c.contains('- MA')){
            frm.State__c = '';
            /*frm.Vol_Rec_Prod_Type__c = (hasQuote == true && quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c != null) ? quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c : 'IL - RPS Compliant';
            frm.Book_Name__c = (cnt.service_territory__c.contains('Comed-IL')) ? 'DES-Retail-Accrual' : 'IPH-Retail-Accrual'; */
            system.debug('MA Contracts');
        }
        else if(cnt.service_territory__c != null && cnt.service_territory__c.contains('- PA')){
            frm.State__c = '';
            /*frm.Vol_Rec_Prod_Type__c = (hasQuote == true && quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c != null) ? quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c : 'IL - RPS Compliant';
            frm.Book_Name__c = (cnt.service_territory__c.contains('Comed-IL')) ? 'DES-Retail-Accrual' : 'IPH-Retail-Accrual'; */
            system.debug('PA Contracts');
        }
        else if(cnt.service_territory__c != null){
            frm.State__c = 'OH';
            frm.Vol_Rec_Prod_Type__c = (hasQuote == true && quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c != null) ? quomap.get(cnt.Retail_Quote__c).Voluntary_REC_Generator_Type__c : 'OH - RPS Compliant';
            frm.Book_Name__c = 'DESE-Retail-Accrual'; 
        }
        
        frm.Contr_Agree_Num__c = cnt.ContractNumber;
        frm.Entry_Date_Time__c = cnt.createddate;
        frm.Delivery_Point__c = cnt.Service_Territory__c;
        //system.debug('Test Product : '+quomap.get(cnt.Retail_Quote__c).product__c);
        string proname = (hasQuote == true) ? promap.get(quomap.get(cnt.Retail_Quote__c).product__c).Name : (!string.isBlank(cnt.Product_Name__c)) ? cnt.Product_Name__c : null;
        
        if(proname != null && proname.startsWith('FP'))
            frm.Prod_Type__c = 'FULL REQUIREMENTS';
        else if(proname != null && proname.startsWith('BI'))
            frm.Prod_Type__c = 'BLOCK';
        else if(proname != null && proname.startsWith('PCTG'))
            frm.Prod_Type__c = 'PCT_ENERGY';
        else
            frm.Prod_Type__c = '';
            
        frm.Product_Name__c = proname;
        frm.Date_Start__c = cnt.StartDate;
        frm.Date_End__c = cnt.End_Date__c;
        Integer contractDays = cnt.StartDate.daysBetween(cnt.End_Date__c);
        frm.Term_Months__c = cnt.ContractTerm;
        frm.Trade_Date__c = date.valueof(cnt.Contract_Counter_Signed_Date__c);
        frm.Trader_ID__c = cnt.owner.name;
        
        if(cnt.RPS__c > 0)
            frm.RPS_Applicable__c = 'Yes';
        if(cnt.Vol_Rec__c > 0)
            frm.Vol_Rec__c = 'Yes';
            
        if(hasQuote){
            frm.Tot_REC_Pctg__c = (quoMap.get(cnt.Retail_Quote__c).Voluntary_REC__c > 0)? (quoMap.get(cnt.Retail_Quote__c).Voluntary_REC__c)/100 : 0;
            frm.PLC_Kw_Transaction__c = quoMap.get(cnt.Retail_Quote__c).Aggregate_PLC__c;
            frm.Energy__c = quoMap.get(cnt.Retail_Quote__c).Energy__c;
            frm.Swing__c = ((quoMap.get(cnt.Retail_Quote__c).Swing__c != null) ? quoMap.get(cnt.Retail_Quote__c).Swing__c : 0 )+((quoMap.get(cnt.Retail_Quote__c).Shaping__c != null) ? quoMap.get(cnt.Retail_Quote__c).Shaping__c : 0);
            frm.Basis__c = quoMap.get(cnt.Retail_Quote__c).Basis__c;
            frm.Capacity__c = quoMap.get(cnt.Retail_Quote__c).Capacity__c;
            frm.Dist_Loss__c = quoMap.get(cnt.Retail_Quote__c).Utility_Loss__c;
            frm.UCB_POR__c = quoMap.get(cnt.Retail_Quote__c).UCB_POR__c;
            frm.Margin__c = ((quoMap.get(cnt.Retail_Quote__c).Contract_Margin__c != null) ? quoMap.get(cnt.Retail_Quote__c).Contract_Margin__c : 0)+((quoMap.get(cnt.Retail_Quote__c).Contract_Index_Margin__c != null) ? quoMap.get(cnt.Retail_Quote__c).Contract_Index_Margin__c : 0);
            frm.ISO_ARR__c = quoMap.get(cnt.Retail_Quote__c).ISO_ARR__c;
            frm.ISO_FTR__c = quoMap.get(cnt.Retail_Quote__c).ISO_FTR__c;
            frm.ISO_NITS__c = quoMap.get(cnt.Retail_Quote__c).ISO_NITS__c;
            frm.ISO_Losses__c = quoMap.get(cnt.Retail_Quote__c).ISO_Losses__c;
            frm.ISO_Ancill__c = quoMap.get(cnt.Retail_Quote__c).ISO_Ancillaries__c;
            frm.ISO_SSR_RMR__c = quoMap.get(cnt.Retail_Quote__c).ISO_SSR_RMR__c;
            frm.ISO_Admin__c = quoMap.get(cnt.Retail_Quote__c).ISO_Admin__c;
            frm.Consult_Fee__c = quoMap.get(cnt.Retail_Quote__c).Broker_Fee__c !=  null ? quoMap.get(cnt.Retail_Quote__c).Broker_Fee__c : quoMap.get(cnt.Retail_Quote__c).Agent_Fee__c;
            frm.Muni_Fee__c = quoMap.get(cnt.Retail_Quote__c).Muni_Fee__c;
            frm.Mktg_Misc_Fee__c = quoMap.get(cnt.Retail_Quote__c).Default_Risk__c;
            frm.RPS__c = quoMap.get(cnt.Retail_Quote__c).RPS__c;
            frm.Tax__c = quoMap.get(cnt.Retail_Quote__c).Tax__c;
            frm.Total_Fixed__c = quoMap.get(cnt.Retail_Quote__c).Quote_Price__c;
            frm.Pct_Energy_Fixed__c = quoMap.get(cnt.Retail_Quote__c).Energy_Fixed__c;
            frm.Utility_Settlement_Zone__c = quoMap.get(cnt.Retail_Quote__c).Utility_Settlement_Zone__c;
            string st = (quoMap.get(cnt.Retail_Quote__c).Utility_Settlement_Zone__c != null) ? quoMap.get(cnt.Retail_Quote__c).Utility_Settlement_Zone__c : cnt.service_territory__c;
            frm.service_territory__c = getSTerritory(st); 
        }
        else{
            frm.Tot_REC_Pctg__c = (cnt.Voluntary_Rec_Percent__c > 0)? (cnt.Voluntary_Rec_Percent__c)/100 : 0;
            frm.PLC_Kw_Transaction__c = null;
            frm.Energy__c = cnt.Energy__c;
            frm.Swing__c = ((cnt.Swing__c != null) ? cnt.Swing__c : 0) + ((cnt.Shaping__c != null) ? cnt.Shaping__c : 0);
            frm.Basis__c = cnt.Basis__c;
            frm.Capacity__c = cnt.Capacity__c;
            frm.Dist_Loss__c = cnt.Utility_Loss__c;
            frm.UCB_POR__c = cnt.UCB_POR__c;
            frm.Margin__c = ((cnt.Contract_Margin__c != null) ? cnt.Contract_Margin__c : 0)+((cnt.Contract_Index_Margin__c != null) ? cnt.Contract_Index_Margin__c : 0);
            frm.ISO_ARR__c = cnt.ISO_ARR__c;
            frm.ISO_FTR__c = cnt.ISO_FTR__c;
            frm.ISO_NITS__c = cnt.ISO_NITS__c;
            frm.ISO_Losses__c = cnt.ISO_Losses__c;
            frm.ISO_Ancill__c = cnt.ISO_Ancillaries__c;
            frm.ISO_SSR_RMR__c = cnt.ISO_SSR_RMR__c;
            frm.ISO_Admin__c = cnt.ISO_Admin__c;
            frm.Consult_Fee__c = cnt.Broker_Fee__c !=  null ? cnt.Broker_Fee__c : cnt.Agent_Fee__c;
            frm.Muni_Fee__c = cnt.Muni_Fee__c;
            frm.Mktg_Misc_Fee__c = cnt.Default_Risk__c;
            frm.RPS__c = cnt.RPS__c;
            frm.Tax__c = cnt.Tax__c;
            frm.Total_Fixed__c = null;
            frm.Pct_Energy_Fixed__c = null;
            frm.service_territory__c = cnt.service_territory__c; 
        }
        return frm;
    }
    
    public static set<id> calculateMuniaggCnt(list<contract> tCnt){
    	integer cntnum =0;
    	set<id> cnSet = new set<id>();
    	list<contract> cntrlst = new list<contract>();
		for(Integer i=0;i<tCnt.size();i++){
			string str = tCnt[i].contractnumber;
            str = str.substring(2,str.length());
            integer cnum = integer.valueof(str);
            system.debug('cnt Number : '+cnum+' --> cntnum : '+cntnum);
            if(cntnum == 0)
                cntnum = cnum;
            if(cntnum < cnum){
                cntnum = cnum;
                if(tCnt[i].service_territory__c != null && tCnt[i].service_territory__c.contains('-IL')){
                	if(tCnt[i].opportunity__c != null || tCnt[i].retail_quote__c != null || tCnt[i].Vol_Rec__c != null ){
                		if((tCnt[i-1].opportunity__c != null || tCnt[i-1].retail_quote__c != null) && (tCnt[i-1].Vol_Rec__c != null && tCnt[i-1].Vol_Rec__c ==0)
                			&& tCnt[i].Vol_Rec__c > 0){
                				
                			cntrlst.add(tcnt[i-1]);
                			cnSet.add(tCnt[i].id);
                		}
            			else
            				cnSet.add(tCnt[i-1].id);
                	}
            		else
            			cnSet.add(tCnt[i-1].id);
                }
            	else
            		cnSet.add(tCnt[i-1].id);
            }
		}
		
		if(cntrlst.size()>1){
			system.debug('Populate Muni-Agg : '+cntrlst);
			cntnum =0;
			for(Integer i=0;i<cntrlst.size();i++){
				string str = cntrlst[i].contractnumber;
				str = str.substring(2,str.length());
	            integer cnum = integer.valueof(str);
	            system.debug('cnt Number : '+cnum+' --> cntnum : '+cntnum);
	            if(cntnum == 0)
	                cntnum = cnum;
				if(cntnum < cnum){
               		cntnum = cnum;
               		cnSet.add(cntrlst[i-1].id);
				}
			}
		}
		return cnset;
    }
}