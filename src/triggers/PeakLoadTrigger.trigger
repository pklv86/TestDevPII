trigger PeakLoadTrigger on Peak_Load_Information__c (before insert, before update) {
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
        if(trigger.isBefore && trigger.isInsert) {
            Set<Id> DasrreqIdset = new Set<Id>();
            boolean isNoError = false; 
            for (Peak_Load_Information__c peakLoadInfoList: Trigger.new) {
                if(peakLoadInfoList.Load_Type__C == 'PLC' || peakLoadInfoList.Load_Type__C == 'NSPLC'){
                    DasrreqIdset.add(peakLoadInfoList.LDC_Account__C);
                }
            }
            system.debug('LDC Set : '+DasrreqIdset.size()+' : '+DasrreqIdset);
            List<Peak_Load_Information__c>peakLoadInfoListIns = new List<Peak_Load_Information__c>();
            peakLoadInfoListIns = [select id, name, start_date__c, EndDate__c, DASR_Request__c, Load_Type__C, LDC_Account__C, Load_value__c from Peak_Load_Information__c where LDC_Account__c in: DasrreqIdset and (Peak_Load_Information__c.Load_Type__c ='PLC' or  Peak_Load_Information__c.Load_Type__c ='NSPLC')];
            for(Peak_Load_Information__c peakLoadInfoList2: Trigger.new) {
                if(peakLoadInfoListIns.size()>0){
                    for(Peak_Load_Information__c peakLoadInfoObj: peakLoadInfoListIns){
                        if(peakLoadInfoObj.LDC_Account__c == peakLoadInfoList2.LDC_Account__c  &&  peakLoadInfoObj.load_type__c == peakLoadInfoList2.load_type__c && peakLoadInfoObj.start_date__c < peakLoadInfoList2.start_date__c &&  peakLoadInfoObj.enddate__c > peakLoadInfoList2.start_date__c){
                         //  system.debug('=====================first error============');
                             peakLoadInfoList2.addError('Record of type already exist in the time period',false);
                             break;
                        }
                        else if(peakLoadInfoList2.LDC_Account__c == peakLoadInfoObj.LDC_Account__c  && peakLoadInfoObj.load_type__c == peakLoadInfoList2.load_type__c && peakLoadInfoList2.start_date__c == peakLoadInfoObj.start_date__c ){
                         //  system.debug('=========== Second error===========');
                             peakLoadInfoList2.addError('Record of type already exist in the time period',false);
                             break;
                        }
                        else{
                             isNoError = true;
                        }
                    }  
                } 
            }
        }
    }
}