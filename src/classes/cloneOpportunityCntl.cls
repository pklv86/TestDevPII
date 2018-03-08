/*****************************************************************************************
Class :  cloneOpportunityCntl
Description : To clone opportunity LDC's along with opoortunity when clonned.
Version	Date			Author		Comments
1.0		9/11/2017		Prasad		Initial Version Created
******************************************************************************************/
public with sharing class cloneOpportunityCntl {
	
	public opportunity opp {get;set;}
	public opportunity newopp {get;set;}
	public ID oldOppId {get;set;}
	public boolean displayPopUp {get;set;}
  	public string selectedoption {get;set;}
  	
  	public list<selectoption> getsellist(){
		list<selectoption> options = new list<selectoption>();
		options.add(new selectoption('Yes','Yes'));
		options.add(new selectoption('No','No'));
		return options;
	}
	
	public cloneOpportunityCntl(ApexPages.StandardController controller){
		opp = (opportunity)controller.getrecord();
		oldOppId = opp.Id;
	}
	
	public pagereference saveopp(){
		pagereference pg;
		try{
			newopp = opp.clone(false,false,true,false);
			insert newopp;
		}
		catch(Exception e){
			ApexPages.addMessages(e); 
		}
		system.debug('Test oldID : '+oldoppId+' ID --> '+newopp.id);
		if(newopp.id != null && (newopp.type == 'C&I' || newopp.type == 'Small Business')){
			list<opportunity_ldc__c> oldclst= [select id,name,ldc_account__c,ldc_annual_usage__c,opportunity__c,rate_code__c from opportunity_ldc__c where opportunity__c =: oldoppId];
			if(!oldclst.isempty()){
				displayPopUp = true;
			    return null;
			}
			else{
				pg = new pagereference('/'+newopp.id);
				pg.setredirect(true);
				return pg;
			}
		}
		if(newopp.id != null && (newopp.type != 'C&I' || newopp.type != 'Small Business')){
			pg = new pagereference('/'+newopp.id);
			pg.setredirect(true);
			return pg;
		}
		else
			return null;
	}
	
	public pagereference createoppldc(){
		displayPopUp=false;
		pagereference clonepg;
		system.debug('Test oldID : '+oldoppId+' ID --> '+newopp.id);
		if(selectedoption == 'Yes'){
			list<opportunity_ldc__c> oldclst= [select id,name,ldc_account__c,ldc_annual_usage__c,opportunity__c,rate_code__c from opportunity_ldc__c where opportunity__c =: oldoppId];
			list<opportunity_ldc__c> oldclstnew = new list<opportunity_ldc__c>();
			for(opportunity_ldc__c oldc : oldclst){
				opportunity_ldc__c oppldc = new opportunity_ldc__c();
				oppldc = oldc.clone(false,false,true,false);
				oppldc.opportunity__c = newopp.id;
				oldclstnew.add(oppldc);
			}
			if(!oldclstnew.isempty()) insert oldclstnew;
		}
		clonepg = new pagereference('/'+newopp.id);
		clonepg.setredirect(true);
		return clonepg;
	}
	
	public pagereference savenewopp(){
		pagereference pg;
		try{
			newopp = opp.clone(false,false,true,false);
			insert newopp;
		}
		catch(Exception e){
			ApexPages.addMessages(e); 
		}
		system.debug('Test oldID : '+oldoppId+' ID --> '+newopp.id);
		
		if(newopp.id != null && (newopp.type == 'C&I' || newopp.type == 'Small Business')){
			list<opportunity_ldc__c> oldclst= [select id,name,ldc_account__c,ldc_annual_usage__c,opportunity__c,rate_code__c from opportunity_ldc__c where opportunity__c =: oldoppId];
			if(!oldclst.isempty()){
				displayPopUp = true;
			    return null;
			}
			else{
				pg = new pagereference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F'+newopp.id+'&save_new_url=%2F006%2Fe%3F');
				pg.setredirect(true);
				return pg;
			}
		}
		if(newopp.id != null && (newopp.type != 'C&I' || newopp.type != 'Small Business')){
			pg = new pagereference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F'+newopp.id+'&save_new_url=%2F006%2Fe%3F');
			pg.setredirect(true);
			return pg;
		}
		else
			return null;
		/*if(newopp.id != null){
			pg = new pagereference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F'+newopp.id+'&save_new_url=%2F006%2Fe%3F');
			pg.setredirect(true);
			return pg;
		}
		else
			return null;*/
	}
	
	public pagereference Cancel(){
		PageReference opptyPage = new ApexPages.StandardController(opp).view();
        opptyPage.setRedirect(true);
        return opptyPage;
	}
    
}