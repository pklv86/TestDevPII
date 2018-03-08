/* 
 * Name: BillingLDC
 * Type: Apex Class
 * Test Class: BillingLDCTest
 * Description:  Allows Selecting Multiple LDC Accounts Under Account for Group Billing. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu              12/21/2016       1. Initial Version created
 */
 
public with sharing class BillingLDC {
    
    public String selectionId{get;set;}
    public ApexPages.StandardSetController setCon;
    public Set<Id> selectedIds;
    public Billing_Group__c BillingRec;
    public boolean resetHeader {get; set;}
    public boolean groupbtn {get; set;}
    public boolean currentCnt {get; set;}
    
    public BillingLDC(){
    	Integer pageSize = 40;
        system.debug('Test : '+ApexPages.currentPage().getParameters().get('BGID'));
        list<Billing_Group__c > bgrp = [select id,name,account__c from Billing_Group__c where id =: ApexPages.currentPage().getParameters().get('BGID') ];
        if(!bgrp.isempty()){
            BillingRec = bgrp[0];
            selectedIds= new Set<Id>();
            groupbtn=true;
            setcon = new ApexPages.StandardSetController([select id,name,ldc_account_number__c,Account_Type_Code__c,billing_group__c,(Select Active__c, Contract__c, Term_Start_Date__c, Term_Stop_Date__c, IsSynchronized__c From Contract_LDCS__r order by createddate desc) from ldc_account__c where account__c =: BillingRec.account__c and id IN (select ldc_account__c from contract_ldc__c where ldc_account__r.account__c  =: BillingRec.account__c)]);//and Billing_Group__c = null 
            setCon.setpageNumber(1);
            setCon.setPageSize(pageSize);
            if(setCon.getResultSize() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No LDC Accounts available to Group'));
            }       
        }
        else{
            if(ApexPages.currentPage().getParameters().get('UBGID') != null){
                bgrp = [select id,name,account__c from Billing_Group__c where id =: ApexPages.currentPage().getParameters().get('UBGID') ];
                if(!bgrp.isempty()){
                    BillingRec = bgrp[0];
                    selectedIds= new Set<Id>();
                    groupbtn=false;
                    setcon = new ApexPages.StandardSetController([select id,name,ldc_account_number__c,Account_Type_Code__c,billing_group__c,(Select Active__c, Contract__c, Term_Start_Date__c, Term_Stop_Date__c, IsSynchronized__c From Contract_LDCS__r order by createddate desc) from ldc_account__c where account__c =: BillingRec.account__c and Billing_Group__c =: BillingRec.id and id IN (select ldc_account__c from contract_ldc__c where ldc_account__r.account__c  =: BillingRec.account__c) ]);
                    setCon.setpageNumber(1);
          			setCon.setPageSize(pageSize);
                    if(setCon.getResultSize() == 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No LDC Accounts available to Ungroup'));
                    }       
                }
            }
            else{
                BillingRec = null;
            }
        }
    }
    
    public PageReference addAccounts() {
    	
        Billing_Group__c bg = [Select id,name,contract__c,contract__r.End_Date__c,contract__r.startDate From Billing_Group__c where id =: BillingRec.id];
        system.debug('Billing Group : '+bg);
        currentCnt = (bg.contract__r.startdate < Date.today()) ? true : false;
        system.debug('current Cnt : '+currentCnt);
        
        if(bg.contract__r.end_date__c <= Date.today()){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Contract is Expired. Contract EndDate : '+bg.contract__r.end_date__c));
        	return null;
    	}
    	
        List<ldc_account__c> ldclst = new List<ldc_account__c>();
        map<id,ldc_account__c>ldcMap = new map<id,ldc_account__c>();
        map<id,id> ldcbgmap = new map<id,id>();
        for(ldc_account__c ldc : [select id,billing_group__c,account_type_code__c from ldc_account__c where id IN : selectedIds]){   
            if(currentCnt){
            	if(ldc.billing_group__c != null)
            		ldcbgmap.put(ldc.id,ldc.billing_group__c);
            	ldc.Billing_Group__c = BillingRec.id;
            }
            ldc.Account_Type_Code__c = 'RETAIL_FRIEND';
            ldclst.add(ldc);  
            ldcmap.put(ldc.id,ldc);                      
        }
        system.debug('Updating List: ' + ldclst);
        system.debug('Updating Billing Group : '+ldcbgmap);
        if(!ldclst.isEmpty()){
            update ldclst;
            
            list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
            map<id,Billing_Group_Ldc__c> bgldcmap = new map<id,Billing_Group_Ldc__c>();
            for(Billing_Group_Ldc__c bgldcloop : [select id,ldc_account__c,billing_group__c,Billing_Start_Date__c,Billing_Stop_Date__c,synchronized__c
            										 from Billing_Group_Ldc__c where ldc_account__c IN : selectedIds]){
				if(!bgldcmap.containskey(bgldcloop.ldc_account__c)){ 	
					ID bgid = ldcbgmap.get(bgldcloop.ldc_account__c);
					if(bgid == bgldcloop.billing_group__c)
						bgldcmap.put(bgldcloop.ldc_account__c,bgldcloop);
				}
			}
			system.debug('Upsert Map BGLDC : '+bgldcmap);
            
            for(ID mapid : ldcmap.keyset()){
                Billing_Group_Ldc__c bgldc = new Billing_Group_Ldc__c();
                bgldc.LDC_Account__c = mapid;
                bgldc.Billing_Group__c = BillingRec.id;
                if(currentCnt)
                	bgldc.Billing_Start_Date__c = DateTime.newInstance(Date.Today(),Time.newInstance(0,0,0,0));
            	else
                	bgldc.Billing_Start_Date__c = DateTime.newInstance(bg.contract__r.startDate,Time.newInstance(0,0,0,0));
                bgldc.Billing_Stop_Date__c = (DateTime.newInstance((bg.contract__r.End_Date__c).adddays(1),Time.newInstance(0,0,0,0))).addseconds(-1);
                bgldclst.add(bgldc);
                
                if(bgldcmap.containskey(mapid)){
                	Billing_Group_Ldc__c innerbgldc = bgldcmap.get(mapid);
                	innerbgldc.Billing_Stop_Date__c = DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(0,0,0,0)).addseconds(-1);
                	innerbgldc.synchronized__c = false;
                	bgldclst.add(innerbgldc);
                }
            }
            
            if(!bgldclst.isempty()) upsert bgldclst;
        }
        
        if(BillingRec == null) return new PageReference('/');
        return BGRedirect();
    }
    
     public PageReference delAccounts() {
        List<ldc_account__c> ldclst = new List<ldc_account__c>();
        system.debug('Test : '+selectedIds);
        for(ID selId : selectedIds){   
            ldc_account__c ldc = new ldc_account__c();
            ldc.id = selId;
            ldc.Billing_Group__c = null;
            ldc.Account_Type_Code__c = 'RETAIL_STANDALONE';
            ldclst.add(ldc);                        
        }
        system.debug('Updating List: ' + ldclst);
        if(!ldclst.isEmpty()){
            update ldclst;
            
            string bgldcQuery = 'Select id,name,LDC_Account__c,ldc_account_number__c,Billing_Stop_Date__c,Synchronized__c From Billing_Group_Ldc__c where ldc_account__c IN: ldclst and Billing_Stop_Date__c > today';
            map<id,Billing_Group_Ldc__c>bgldcMap = new map<id,Billing_Group_Ldc__c>((list<Billing_Group_Ldc__c>)Database.query(bgldcQuery));
            
            list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
            for(ID mapid : bgldcmap.keyset()){
                Billing_Group_Ldc__c bgldc = new Billing_Group_Ldc__c();
                bgldc.id = mapid;
                bgldc.Synchronized__c = false;
                bgldc.Billing_Stop_Date__c = (DateTime.newInstance(Date.Today().adddays(1),Time.newInstance(0,0,0,0))).addseconds(-1);
                bgldclst.add(bgldc);
            }
            
            if(!bgldclst.isempty()) update bgldclst;
        }
        
        if(BillingRec == null) return new PageReference('/');
        return BGRedirect();
    }
    
    private PageReference BGRedirect(){
        PageReference BGPage = new ApexPages.StandardController(BillingRec).view();
        BGPage.setRedirect(true);
        return BGPage;
    }
    
    public PageReference cancel() { 
        if(BillingRec == null) return new PageReference('/');   
        return BGRedirect();
    }
    
    public void addSelectedId(){
        if(selectionId != null && selectionId != ''){
            system.debug('Adding To Set : ' + selectionId);
            selectedIds.add(selectionId);
            setHeaderValue();
         }
        else{
            system.debug('Iterating Over Current Record set');
            for(sObject so : setCon.getRecords()){
                LDC_Account__c a = (LDC_Account__c)so;
                system.debug('Checking for : ' + a.Id); 
                if(!selectedIds.contains(a.Id)){
                    system.debug('Adding : ' + a.Id + ' TO : '+selectedIds);
                    selectedIds.add(a.Id);
                }
                else{
                    system.debug('SET : ' + selectedIds + ' Allready Has : '+a.id);
                }
            }
        }
        system.debug('Selection Set : ' + selectedIds);  
    }

    public void removeSelectedId(){
    	system.debug('Test : '+selectedIds);
        if(selectionId != null && selectionId != ''){
            system.debug('Removing From Set : ' + selectionId);
            selectedIds.remove(selectionId);
            setHeaderValue();
        }
        else{
            system.debug('Iterating Over Current Record set');
            for(sObject so : setCon.getRecords()){
                LDC_Account__c a = (LDC_Account__c)so;
                system.debug('Checking for : ' + a.Id); 
                if(!selectedIds.contains(a.Id)){
                    system.debug('SET : ' + selectedIds + ' Do Not Have : '+a.id + ' Ignoring.....');
                }
                else{
                    system.debug('SET : ' + selectedIds + ' Has : '+a.id + ' Removing this');
                    selectedIds.remove(a.id);
                }
            }
        }
        system.debug('Selection Set : ' + selectedIds);
    }
    
    public Integer getSelectedCount(){
        return selectedIds.size();
    }
    
    public Integer getPageNumber(){
        return setCon.getPageNumber();
    }
 
    public Integer getTotalPages(){
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
 
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    public Boolean getHasPrevious(){
        return setCon.getHasPrevious();
    }
 
    public Boolean getHasNext(){
        return setCon.getHasNext();
    }
 
    public void doNext(){
        if(setCon.getHasNext()){
            setCon.next();            
            setHeaderValue();
        }
    }
 
    public void doPrevious(){
        if(setCon.getHasPrevious()){
            setCon.previous();        
            setHeaderValue();
        }
    }
    
    public void setHeaderValue(){
        resetHeader = true;
        for(sObject so : setCon.getRecords()){
            LDC_Account__c a = (LDC_Account__c)so;              
            if(!selectedIds.contains(a.Id)){
                resetHeader = false;
                break;      
            }
        }
    }
    
    public List<ldcAccountWrapper> getLDCAccounts(){
 
        List<ldcAccountWrapper> lstLDCAccWrapper = new List<ldcAccountWrapper>();
        for(sObject so : setCon.getRecords()){
            LDC_Account__c a = (LDC_Account__c)so;
            ldcAccountWrapper ldcWapper = new ldcAccountWrapper(a,false);
            if(selectedIds.contains(a.Id)){
                ldcWapper.IsSelected=true;
            }
            else{
                ldcWapper.IsSelected=false;
            }
            lstLDCAccWrapper.add(ldcWapper);
            system.debug('Check Size of map : '+lstLDCAccWrapper.size());
        }
        return lstLDCAccWrapper;
    }
    
    public with sharing class ldcAccountWrapper{
 
        public LDC_Account__c ldcAcc{get;set;}
        public Boolean IsSelected{get;set;}
 
        public ldcAccountWrapper(LDC_Account__c a, Boolean s){
            ldcAcc=a;
            IsSelected=s;
        }
 
    }
}