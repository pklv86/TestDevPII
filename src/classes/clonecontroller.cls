public with sharing class clonecontroller {
		
	public boolean displayPopUp {get;set;}
	public string selectedoption {get;set;}
	private final Opportunity opty;	
	private final ID oppid;
	
	public list<selectoption> getsellist(){
		list<selectoption> options = new list<selectoption>();
		options.add(new selectoption('Yes','Yes'));
		options.add(new selectoption('No','No'));
		return options;
	}
	
	public clonecontroller(){
		//displayPopUp=true;	
		oppId = apexpages.currentPage().getparameters().get('ID');
		system.debug('Test : '+apexpages.currentPage().getparameters().get('ID')+' IDIDIDIDID : '+oppid);	
		
		if(oppId != null){
           if(label.OppCloneQueryFields != null && label.OppCloneQueryFields !=''){
              this.opty = (Opportunity)ConstantUtility.getObject('Opportunity',label.OppCloneQueryFields,oppId);
           }
           else{
              this.opty = (Opportunity)ConstantUtility.getObject('Opportunity','Id:Name:Refresh_Expiration_Date__c:Executable_Quote_Generated__c',oppId);   
           }
           
           if(opty.type == 'C&I' || opty.type == 'Small Business'){
 			  displayPopUp=true;	          			
           }
        }
		system.debug('Selected option : '+selectedoption);
	}
	
	public pagereference cloneProcess(){
		displayPopUp=false;
		pagereference clonepg;
		
		if(selectedoption == 'Yes'){
			list<opportunity_ldc__c> ldclst= [select id,name,ldc_account__c,ldc_annual_usage__c,opportunity__c,rate_code__c from opportunity_ldc__c where opportunity__c =: oppId];
			clonepg = new pagereference('/'+oppId+'/e?clone=1&retURL=%2F'+oppId+'&00N5B000000gKZK='+oppId);
		}
		else{
			clonepg = new pagereference('/'+oppId+'/e?clone=1&00N5B000000gKZK='+oppId);
		}
		clonepg.setredirect(true);
		return clonepg;
		//return null;
	}
    
}