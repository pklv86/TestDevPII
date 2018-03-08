trigger updateMeterObject on Vendor_Meter_Exception__c(after insert)
{
       
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
        list<Meter__c> MeterobjInsert = new list<Meter__c>();
        SET<ID> IDSET = NEW SET<ID>();
        final set<string> Reason_codes = new set<string>{'REFNH','REFTZ','REFPR','REFLO','NM1MQ','REF4P','REFLF','REFMT','REFTU','REFIX','NM1MR'};
        //'REFSV',
        final set<string> Meter_Types = new set<string>{'KHMON','KH015','KH030','KH060','COMBO'};
        final set<string> Reason_codes1 = new set<string>{'NM1MA','NM1MX'};
        

        map<id,Vendor_Meter__c> mapOfVendorMeter = new map<id,Vendor_Meter__c>();   
        map<string,Vendor_Meter__c> mapOfVendorMeter1 = new map<string,Vendor_Meter__c>();
        Map<string,string> mapofLDCaccount = new map<string,string>();
        map<id,Vendor_Meter__c> mapofDasr= new map<id,Vendor_Meter__c>(); 
        map<string,Meter__c> mapOfMeterObjALL = new map<string,Meter__c>();
        map<String,Meter__c> mapOfMeterObjOther  = new map<String,Meter__c>(); 
         
        
        map<id,id> mapofservicepoint = new map<id,id>();
        
        map<id,Vendor_Meter_Exception__c> mapofvmE= new map<id,Vendor_Meter_Exception__c>();
        map<string,Vendor_Meter_Exception__c> mapofDasrRequest = new map<string,Vendor_Meter_Exception__c>();
        map<string,Meter__c> mapofmeter = new map<string,Meter__c>();
        map<String,Vendor_Meter__c> mapofvendormtr = new map<string,Vendor_Meter__c>();
        
        set<id> dasrRequestIDs = new set<id>();
        map<string,Vendor_Meter_Exception__c> mapofvendormtrexp = new map<string,Vendor_Meter_Exception__c>();
        
        for(Vendor_Meter_Exception__c excRecords : trigger.new)
            {
                //for incoming vendor meter exception, find out matching vendor meter
                //using dasr request
                list<id> lstServiceIds = new list<id>();
                
                mapofDasrRequest.put(excRecords.DASR_Request__c,excRecords);
                mapofvmE.put(excRecords.LDC_Account__c,excRecords);
                mapofvendormtrexp.put(excRecords.Meter_Number__c,excRecords);
                dasrRequestIDs.add(excRecords.DASR_Request__c);
            }
            
        if(mapofDasrRequest.size()>0)
            {
                //using the dasr req id find out the correspoding vendor meter
                for(Vendor_Meter__c vendorMeterObj : [select LDC_Meter_Cycle__c,LDC_Rate_Class__c,Change_effective_date__C,LDC_Rate_Subclass__c,Load_Profile_Description__c,
                                                        Meter_Type_Code__c,Old_Meter_Number__c,Meter_Maintenance_Code__c,Meter_Multiplier_Quantity__c,
                                                        Number_Of_Dials_Quantity__c,Time_Of_Use_Metering__c,Distribution_Loss_Factor__c,Meter_Service_Voltage__c,
                                                        DASR_Request__c,Meter_Number__c,ESP_Rate_Code__c,LDC_Account__c from Vendor_Meter__c where 
                                                        DASR_Request__c IN : mapofDasrRequest.keySet()])
                    {
                        if((vendorMeterObj.Meter_Number__c == 'ALL') && (vendorMeterObj.Meter_Number__c == mapofDasrRequest.get(vendorMeterObj.DASR_Request__c).Meter_Number__c) && Meter_Types.Contains(VendorMeterObj.Meter_Type_Code__c))
                            {
                                //if the meter number matches , then we need to store the LDC_Account__c to query the 
                                mapOfVendorMeter.put(vendorMeterObj.LDC_Account__c,vendorMeterObj);
                                
                            }
                            
                          else if(!mapOfVendorMeter.containskey(vendorMeterObj.LDC_Account__c) && (vendorMeterObj.Meter_Number__c == 'ALL') && (vendorMeterObj.Meter_Number__c == mapofDasrRequest.get(vendorMeterObj.DASR_Request__c).Meter_Number__c)&& !Meter_Types.Contains(VendorMeterObj.Meter_Type_Code__c))
                             {
                                //if the meter number matches , then we need to store the LDC_Account__c to query the 
                                mapOfVendorMeter.put(vendorMeterObj.LDC_Account__c,vendorMeterObj);
                                
                            }
                            
                    }
            }
        if(mapofvendormtrexp.size()>0)
            {  
                for(Vendor_Meter__c vendorMeterObj : [select LDC_Meter_Cycle__c,LDC_Rate_Class__c,Change_effective_date__C,LDC_Rate_Subclass__c,Load_Profile_Description__c,
                                                        Meter_Type_Code__c,Old_Meter_Number__c,Meter_Maintenance_Code__c,Meter_Multiplier_Quantity__c,
                                                        Number_Of_Dials_Quantity__c,Time_Of_Use_Metering__c,Distribution_Loss_Factor__c,Meter_Service_Voltage__c,
                                                        DASR_Request__c,Meter_Number__c,ESP_Rate_Code__c,LDC_Account__c from Vendor_Meter__c where 
                                                        (Meter_Number__c IN : mapofvendormtrexp.keySet())and DASR_Request__c IN : mapofDasrRequest.keySet()])
                    {
                        system.debug('*****'+(mapofvendormtrexp.get(vendorMeterObj.Meter_Number__c).Dasr_Request__c));
                        if ((vendorMeterObj.Dasr_Request__c == mapofvendormtrexp.get(vendorMeterObj.Meter_Number__c).Dasr_Request__c) && Meter_Types.Contains(VendorMeterObj.Meter_Type_Code__c) && vendorMeterObj.Meter_Number__c != 'ALL')// && Reason_codes1.contains(mapofvendormtrexp.get(vendorMeterObj.Meter_Number__c).Reason_Code__c) )
                            {
                                mapOfVendorMeter1.put(vendorMeterObj.Meter_Number__c,vendorMeterObj);
                                mapofLDCaccount.put(vendorMeterObj.Meter_Number__c,vendorMeterObj.LDC_Account__c);
                                //mapofDasr.put(vendorMeterObj.DASR_Request__c,vendorMeterObj);
                                mapofvendormtr.put(vendorMeterObj.Meter_Number__c,vendorMeterObj);
                                
                            } 
                            
                        else if (!mapOfVendorMeter1.containskey(vendorMeterObj.Meter_Number__c) && (vendorMeterObj.Dasr_Request__c == mapofvendormtrexp.get(vendorMeterObj.Meter_Number__c).Dasr_Request__c) && !Meter_Types.Contains(VendorMeterObj.Meter_Type_Code__c) && vendorMeterObj.Meter_Number__c != 'ALL')
                            {
                                mapOfVendorMeter1.put(vendorMeterObj.Meter_Number__c,vendorMeterObj);
                                mapofLDCaccount.put(vendorMeterObj.Meter_Number__c,vendorMeterObj.LDC_Account__c);
                                //mapofDasr.put(vendorMeterObj.DASR_Request__c,vendorMeterObj);
                                mapofvendormtr.put(vendorMeterObj.Meter_Number__c,vendorMeterObj);
                                
                            }     
                    
                    
                    /*if(vendorMeterObj.Dasr_Request__c == mapofvendormtrexp.get(vendorMeterObj.Meter_Number__c).Dasr_Request__c)
                        {
                            //if the meter number matches , then we need to store the LDC_Account__c to query the 
                            //mapofvendormtr.put(vendorMeterObj.Meter_Number__c,vendorMeterObj);
                        }*/
                    }       
            }
             system.debug('**** Reason code is KHMON' + mapOfVendorMeter1);
        if(mapOfVendorMeter.size()>0)
           {  
                //use the LDC account id on Service_Point to query the Meter__c
                for(Meter__c meterObj : [select Meter_Number__c,Load_Profile__c,id,Service_Point__r.LDC_Account_Number__c,LDC_Rate_Class__c,LDC_Meter_Cycle__c,Start_date__C,LDC_Rate_Subclass__c,Load_Profile_Description__c,Meter_Type_Code__c,Meter_Multiplier_Quantity__c,Number_Of_Dials_Quantity__c,Time_Of_Use_Metering__c,Distribution_Loss_Factor__c,Meter_Service_Voltage__c from Meter__c where (Service_Point__r.LDC_Account_Number__c IN : mapOfVendorMeter.keyset()) ])
                    {
                        system.debug('*********' + (mapOfVendorMeter.get(meterObj.Service_Point__r.LDC_Account_Number__c).Meter_Number__c));
                        mapOfMeterObjALL.put(meterObj.Meter_Number__c,meterObj);
                        //mapOfMeterObjOther.put(meterObj.Service_Point__r.LDC_Account_Number__c,meterObj);
                    }
            }
        if(mapofvendormtr.size()>0)
            { 
                for(Meter__c meterObj : [select Meter_Number__c,id,Load_Profile__c,Service_Point__r.LDC_Account_Number__c,LDC_Rate_Class__c,LDC_Meter_Cycle__c,Start_date__C,LDC_Rate_Subclass__c,Load_Profile_Description__c,Meter_Type_Code__c,Meter_Multiplier_Quantity__c,Number_Of_Dials_Quantity__c,Time_Of_Use_Metering__c,Distribution_Loss_Factor__c,Meter_Service_Voltage__c from Meter__c where (Meter_number__c IN : mapofvendormtr.keyset()) ])
                    {
                       system.debug('*********' + (mapOfVendorMtr.get(meterObj.Meter_Number__c).Meter_Number__c));
                       if(meterObj.Service_Point__r.LDC_Account_Number__c == mapofvendormtr.get(meterObj.Meter_Number__c).LDC_Account__c)
                            mapOfMeterObjOther.put(meterObj.Meter_number__c,meterObj);
                    }
                System.debug('**********mapOfVendorMtr/'+mapOfVendorMtr);           
            }  

        if(mapofLDCaccount.size()>0)
            {
                for(Service_Point__c serv : [select id,LDC_Account_Number__c from Service_Point__c  where LDC_Account_Number__c in: mapofLDCaccount.values()])
                    {
                        mapofservicepoint.put(serv.LDC_Account_Number__c,serv.id);
                    }
            }
            System.debug('****servicepoints****'+mapofservicepoint);
            
        for(Vendor_Meter_Exception__c excRecords : trigger.new)
            {
                    
                if(excRecords.Meter_Number__c =='ALL' && mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Number__c == 'ALL' && Reason_codes.contains(excRecords.Reason_Code__c) )
                    {
                        
                        for(meter__c meterObj : mapOfMeterObjALL.values())
                            {
                                system.debug('**** Reason code is ALL');
                                system.debug('**** ID meterObj' + meterObj.id);
                                if(excRecords.Reason_Code__c == 'REFTZ'){
                                    
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.LDC_Meter_Cycle__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).LDC_Meter_Cycle__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).LDC_Meter_Cycle__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).LDC_Meter_Cycle__c; 
                                    
                                }
                                else if(excRecords.Reason_Code__c == 'REFNH'){  
                                      if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.LDC_Rate_Class__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).LDC_Rate_Class__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).LDC_Rate_Class__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).LDC_Rate_Class__c;                     
                                }
                                else if(excRecords.Reason_Code__c == 'REFPR'){       
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.LDC_Rate_Subclass__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).LDC_Rate_Subclass__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).LDC_Rate_Subclass__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).LDC_Rate_Subclass__c;  
                                    
                                }
                                else if(excRecords.Reason_Code__c == 'REFLO'){   
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Load_Profile__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Load_Profile_Description__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Load_Profile__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Load_Profile_Description__c; 
                                    
                                }
                                else if(excRecords.Reason_Code__c == 'NM1MQ'){ 
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Meter_Type_Code__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Type_Code__c;
                                    meterObj.Meter_Multiplier_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Multiplier_Quantity__c;
                                    meterObj.Number_Of_Dials_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Number_Of_Dials_Quantity__c;
                                    meterObj.Time_Of_Use_Metering__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Time_Of_Use_Metering__c;
                                    meterObj.Meter_Maintenance_Code__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Maintenance_Code__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else{
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Type_Code__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Type_Code__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Multiplier_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Multiplier_Quantity__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Number_Of_Dials_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Number_Of_Dials_Quantity__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Time_Of_Use_Metering__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Time_Of_Use_Metering__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Maintenance_Code__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Maintenance_Code__c; 
                                   }
                                }
                                else if(excRecords.Reason_Code__c == 'REF4P'){  
                                       if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Meter_Multiplier_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Multiplier_Quantity__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Multiplier_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Multiplier_Quantity__c; 
                              
                                }
                                else if(excRecords.Reason_Code__c == 'REFLF'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Distribution_Loss_Factor__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Distribution_Loss_Factor__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Distribution_Loss_Factor__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Distribution_Loss_Factor__c; 
                                   
                                }
                                /*else if(excRecords.Reason_Code__c == 'REFSV'){
                                    newMeterObj.id = meterObj.id;
                                    newMeterObj.Meter_Service_Voltage__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Service_Voltage__c;
                                }
                                */
                               else if(excRecords.Reason_Code__c =='REFMT'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Meter_Type_Code__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Type_Code__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Type_Code__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Type_Code__c; 
                                    
                                }
                               else if(excRecords.Reason_Code__c == 'REFTU'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Time_Of_Use_Metering__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Time_Of_Use_Metering__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Time_Of_Use_Metering__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Time_Of_Use_Metering__c; 
                                    
                                }
                               else if(excRecords.Reason_Code__c== 'REFIX'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Number_Of_Dials_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Number_Of_Dials_Quantity__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Number_Of_Dials_Quantity__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Number_Of_Dials_Quantity__c; 
                                    
                                } 
                                else if(excRecords.Reason_Code__c == 'NM1MR'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.End_Date__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Change_effective_date__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).End_Date__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Change_effective_date__c; 
                                    
                                }
                                
                               
                                system.debug('**********mapofmeters/'+mapofmeter);
                              
                            }
                    }
                    
                    //system.debug('**********mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Number__c/'+mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Number__c);
                    system.debug('******mapOfMeterObjALL****/'+mapOfMeterObjALL);
                    system.debug('**********mapOfVendorMeter/'+mapOfVendorMeter);      
                    system.debug('**********mapOfVendorMtr/'+mapOfVendorMtr);   

                    
                for(meter__c meterObj : mapOfMeterObjOther.values())
                    {
                            
                        if(meterObj.Meter_Number__c  == excRecords.Meter_Number__c && Reason_codes.contains(excRecords.Reason_Code__c))
                            {
                                system.debug('**** Reason code is ALL');
                                system.debug('**** ID meterObj' + meterObj.id);
                                if(excRecords.Reason_Code__c == 'REFTZ'){
                                    
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.LDC_Meter_Cycle__c = mapofvendormtr.get(excRecords.Meter_Number__c).LDC_Meter_Cycle__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).LDC_Meter_Cycle__c= mapofvendormtr.get(excRecords.Meter_Number__c).LDC_Meter_Cycle__c; 
                                    
                                }
                                else if(excRecords.Reason_Code__c == 'REFNH'){  
                                      if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.LDC_Rate_Class__c= mapofvendormtr.get(excRecords.Meter_Number__c).LDC_Rate_Class__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).LDC_Rate_Class__c= mapofvendormtr.get(excRecords.Meter_Number__c).LDC_Rate_Class__c;                     
                                }
                                else if(excRecords.Reason_Code__c == 'REFPR'){       
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.LDC_Rate_Subclass__c= mapofvendormtr.get(excRecords.Meter_Number__c).LDC_Rate_Subclass__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).LDC_Rate_Subclass__c= mapofvendormtr.get(excRecords.Meter_Number__c).LDC_Rate_Subclass__c;  
                                    
                                }
                                else if(excRecords.Reason_Code__c == 'REFLO'){   
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Load_Profile__c= mapofvendormtr.get(excRecords.Meter_Number__c).Load_Profile_Description__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Load_Profile__c= mapofvendormtr.get(excRecords.Meter_Number__c).Load_Profile_Description__c; 
                                    
                                }
                                else if(excRecords.Reason_Code__c == 'NM1MQ'){ 
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Meter_Type_Code__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Type_Code__c;
                                    meterObj.Meter_Multiplier_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Multiplier_Quantity__c;
                                    meterObj.Number_Of_Dials_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Number_Of_Dials_Quantity__c;
                                    meterObj.Time_Of_Use_Metering__c= mapofvendormtr.get(excRecords.Meter_Number__c).Time_Of_Use_Metering__c;
                                    meterObj.Meter_Maintenance_Code__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Maintenance_Code__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else{
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Type_Code__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Type_Code__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Multiplier_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Multiplier_Quantity__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Number_Of_Dials_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Number_Of_Dials_Quantity__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Time_Of_Use_Metering__c= mapofvendormtr.get(excRecords.Meter_Number__c).Time_Of_Use_Metering__c; 
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Maintenance_Code__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Maintenance_Code__c; 
                                   }
                                }
                                else if(excRecords.Reason_Code__c == 'REF4P'){  
                                       if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Meter_Multiplier_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Multiplier_Quantity__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Multiplier_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Multiplier_Quantity__c; 
                              
                                }
                                else if(excRecords.Reason_Code__c == 'REFLF'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Distribution_Loss_Factor__c= mapofvendormtr.get(excRecords.Meter_Number__c).Distribution_Loss_Factor__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Distribution_Loss_Factor__c= mapofvendormtr.get(excRecords.Meter_Number__c).Distribution_Loss_Factor__c; 
                                   
                                }
                                /*else if(excRecords.Reason_Code__c == 'REFSV'){
                                    newMeterObj.id = meterObj.id;
                                    newMeterObj.Meter_Service_Voltage__c= mapOfVendorMeter.get(excRecords.LDC_Account__c).Meter_Service_Voltage__c;
                                }
                                */
                               else if(excRecords.Reason_Code__c =='REFMT'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Meter_Type_Code__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Type_Code__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Meter_Type_Code__c= mapofvendormtr.get(excRecords.Meter_Number__c).Meter_Type_Code__c; 
                                    
                                }
                               else if(excRecords.Reason_Code__c == 'REFTU'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Time_Of_Use_Metering__c= mapofvendormtr.get(excRecords.Meter_Number__c).Time_Of_Use_Metering__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Time_Of_Use_Metering__c= mapofvendormtr.get(excRecords.Meter_Number__c).Time_Of_Use_Metering__c; 
                                    
                                }
                               else if(excRecords.Reason_Code__c== 'REFIX'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.Number_Of_Dials_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Number_Of_Dials_Quantity__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).Number_Of_Dials_Quantity__c= mapofvendormtr.get(excRecords.Meter_Number__c).Number_Of_Dials_Quantity__c; 
                                    
                                } 
                                else if(excRecords.Reason_Code__c == 'NM1MR'){
                                    if (mapofmeter.containsKey(meterObj.Meter_Number__c) == false) {  
                                    meterObj.End_Date__c= mapofvendormtr.get(excRecords.Meter_Number__c).Change_effective_date__c;
                                    mapofmeter.put(meterObj.Meter_Number__c,meterObj);
                                    }
                                   else
                                    mapofmeter.get(meterObj.Meter_Number__c).End_Date__c= mapofvendormtr.get(excRecords.Meter_Number__c).Change_effective_date__c; 
                                 }   
                                system.debug('**********mapofmeters/'+mapofmeter);
                               
                                
                            }
                    }
            }
            
            if(mapOfVendorMeter1.size()>=0)
                {
                    Meter__c meterRec;
                    for(string meter : mapOfVendorMeter1.keyset())
                        {
                            
                            if((mapofvendormtrexp.get(mapOfVendorMeter1.get(meter).Meter_Number__c).Reason_Code__c) == 'NM1MX')
                                {
                                    system.debug('*******meternumberNM1MX******'+meter);
                                    meterRec = new Meter__c();
                                    meterRec.Service_Point__c = mapofservicepoint.get(mapOfVendorMeter1.get(meter).LDC_Account__c);
                                    meterRec.Meter_Number__c = mapOfVendorMeter1.get(meter).Meter_Number__c ;
                                    meterRec.Old_Meter_Number__c= mapOfVendorMeter1.get(meter).Old_Meter_Number__c;
                                    meterRec.Load_Profile__c = mapOfVendorMeter1.get(meter).Load_Profile_Description__c ;
                                    meterRec.LDC_Rate_Class__c= mapOfVendorMeter1.get(meter).LDC_Rate_Class__c;
                                    meterRec.LDC_Meter_Cycle__c= mapOfVendorMeter1.get(meter).LDC_Meter_Cycle__c;
                                    meterRec.LDC_Rate_Subclass__c= mapOfVendorMeter1.get(meter).LDC_Rate_Subclass__c;
                                    meterRec.Meter_Type_Code__c= mapOfVendorMeter1.get(meter).Meter_Type_Code__c;
                                    meterRec.Meter_Multiplier_Quantity__c= mapOfVendorMeter1.get(meter).Meter_Multiplier_Quantity__c;
                                    meterRec.Number_Of_Dials_Quantity__c= mapOfVendorMeter1.get(meter).Number_Of_Dials_Quantity__c;
                                    meterRec.Time_Of_Use_Metering__c= mapOfVendorMeter1.get(meter).Time_Of_Use_Metering__c;
                                    meterRec.Meter_Maintenance_Code__c= mapOfVendorMeter1.get(meter).Meter_Maintenance_Code__c;
                                    meterRec.Start_Date__c = mapOfVendorMeter1.get(meter).change_effective_date__C;
                                    
                                    if( meterRec.Service_Point__c != null && meterRec.Meter_Number__c != null)
                                    MeterobjInsert.add(meterRec);
                                }
                           if((mapofvendormtrexp.get(mapOfVendorMeter1.get(meter).Meter_Number__c).Reason_Code__c) == 'NM1MA')
                                {
                                    system.debug('*******meternumberNM1MA******'+meter);
                                    meterRec = new Meter__c(); 
                                    meterRec.Service_Point__c = mapofservicepoint.get(mapOfVendorMeter1.get(meter).LDC_Account__c);
                                    meterRec.Meter_Number__c = mapOfVendorMeter1.get(meter).Meter_Number__c ;  
                                    meterRec.Load_Profile__c = mapOfVendorMeter1.get(meter).Load_Profile_Description__c ;
                                    meterRec.LDC_Rate_Class__c= mapOfVendorMeter1.get(meter).LDC_Rate_Class__c;
                                    meterRec.LDC_Meter_Cycle__c= mapOfVendorMeter1.get(meter).LDC_Meter_Cycle__c;
                                    meterRec.LDC_Rate_Subclass__c = mapOfVendorMeter1.get(meter).LDC_Rate_Subclass__c;
                                    meterRec.Meter_Type_Code__c= mapOfVendorMeter1.get(meter).Meter_Type_Code__c;
                                    meterRec.Meter_Multiplier_Quantity__c= mapOfVendorMeter1.get(meter).Meter_Multiplier_Quantity__c;
                                    meterRec.Number_Of_Dials_Quantity__c= mapOfVendorMeter1.get(meter).Number_Of_Dials_Quantity__c;
                                    meterRec.Time_Of_Use_Metering__c= mapOfVendorMeter1.get(meter).Time_Of_Use_Metering__c;
                                    meterRec.Meter_Maintenance_Code__c= mapOfVendorMeter1.get(meter).Meter_Maintenance_Code__c; 
                                    meterRec.Start_Date__c = mapOfVendorMeter1.get(meter).change_effective_date__C;
                                    if( meterRec.Service_Point__c != null && meterRec.Meter_Number__c != null)
                                    MeterobjInsert.add(meterRec);             
                                }
                            
                        }
                }
                 system.debug('****NM1MA and NM1MX*****' +MeterobjInsert);
            

            if(!MeterobjInsert.isempty())
                {
                    system.debug('*******MeterObj****'+MeterobjInsert);
                    insert MeterobjInsert;
                }
            if(!mapofmeter.isempty())
                {
                    system.debug('*******update***mapofmeters/'+mapofmeter);
                    update mapofmeter.values();
                }
            
    }
}