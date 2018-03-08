trigger BillingGroupPseudo on Billing_Group__c (after insert,after update) {

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
        system.debug('Test : '+Trigger.new);
        set<id> bgset = new set<id>();
        set<id> cntset = new set<id>();
        for(Billing_Group__c bg : Trigger.new){
            bgset.add(bg.account__c);
            cntset.add(bg.contract__c);
        }
        list<Billing_Group__c> bglst = [select id,name,account__c,contract__c,Pseudo_Contract__c from Billing_Group__c where account__c IN : bgset and contract__c IN : cntset order by createddate desc];
        string str='';
        Integer BGCount = 0;
        if(bglst.size()>1){
            str = bglst[1].Pseudo_Contract__c; 
            try{
                BGCount = Integer.valueof(str.substringAfterLast('_'));
            }
            catch(Exception e){
                system.debug('Exception : '+e);
            }
        }
        
        list<Billing_Group__c> bglstupdate = new list<Billing_Group__c>();
        bgset = new set<id>();
        for(Billing_Group__c bg : Trigger.new){
            if(bg.Pseudo_Contract__c == null || bg.Pseudo_Contract__c == ''){
                Billing_Group__c bgtemp = new Billing_Group__c();
                BGCount++;
                bgtemp.Pseudo_Contract__c = bg.Contract_Number__c+'_'+bg.Name+'_'+BGCount; 
                bgtemp.id = bg.id;
                bgtemp.Synchronized__c = false;
                bglstupdate.add(bgtemp);
                bgset.add(bg.id);
            }
            
            if (Trigger.isAfter && Trigger.isUpdate){
                if(Trigger.oldMap.get(bg.Id).Name != bg.Name || Trigger.oldMap.get(bg.Id).contract__c != bg.contract__c ||
                    	Trigger.oldMap.get(bg.Id).Group_Address_Line1__c != bg.Group_Address_Line1__c || 
                    	Trigger.oldMap.get(bg.Id).Group_Address_Line2__c != bg.Group_Address_Line2__c ||
                    	Trigger.oldMap.get(bg.Id).Group_Address_Line3__c != bg.Group_Address_Line3__c || 
                    	Trigger.oldMap.get(bg.Id).Group_City__c != bg.Group_City__c || Trigger.oldMap.get(bg.Id).Start_Date__c  != bg.Start_Date__c || 
                    	Trigger.oldMap.get(bg.Id).Stop_Date__c != bg.Stop_Date__c){
                    Billing_Group__c bgtemp = new Billing_Group__c();
                    bgtemp.id = bg.id;
                    bgtemp.Synchronized__c = false; 
                    bglstupdate.add(bgtemp);  
                    bgset.add(bg.id); 
                }
            }
        }  
        
        if(!bglstupdate.isempty())
            upsert bglstupdate;  
        
        list<Billing_Group_Ldc__c> bgldclst = [select id,Synchronized__c from Billing_Group_Ldc__c where Billing_Group__c IN : bgset and Synchronized__c = true];
        for(Billing_Group_Ldc__c bgldc : bgldclst){
            bgldc.Synchronized__c = false;
        }
        if(!bgldclst.isempty())
            upsert bgldclst; 
        
    } 
}