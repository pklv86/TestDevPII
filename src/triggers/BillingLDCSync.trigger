trigger BillingLDCSync on Billing_Group_Ldc__c (before insert, after insert, after update) {
    
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
        system.debug('Test New : '+Trigger.new);
        system.debug('Test Old : '+Trigger.old);
        set<id> bgldcset = new set<id>();
        if(Trigger.isBefore && Trigger.isInsert){
            for (Billing_Group_Ldc__c bgldc : Trigger.new) {
                bgldcSet.add(bgldc.Billing_Group__c);
            }
        }
        else{
            for (Billing_Group_Ldc__c bgldc : Trigger.new) {
                if (Trigger.old != null && (Trigger.oldMap.get(bgldc.Id).Name != bgldc.Name || Trigger.oldMap.get(bgldc.Id).Billing_Start_Date__c  != bgldc.Billing_Start_Date__c  ||
                        Trigger.oldMap.get(bgldc.Id).Billing_Stop_Date__c  != bgldc.Billing_Stop_Date__c  || Trigger.oldMap.get(bgldc.Id).Pseudo_Contract__c  != bgldc.Pseudo_Contract__c )) {
                    bgldcSet.add(bgldc.Billing_Group__c);
                }
            }
        }
            
        list<Billing_Group__c> bglst = new list<Billing_Group__c>();
        for(Billing_Group__c bg : [select id,name,Synchronized__c from Billing_Group__c where id IN : bgldcset]){
            bg.Synchronized__c = false;
            bglst.add(bg);
        }
        
        if(!bglst.isempty()) update bglst;
    }
}