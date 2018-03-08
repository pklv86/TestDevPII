global class PricingResponseWebService{

    webservice static ServiceResponse ResponseProcess(PricingResponse request) {
      ServiceResponse res = new ServiceResponse();  
        if(request == null){
            res.status=ConstantUtility.STATUS_SUCCESS;
            res.MessageDesc = 'No request Found'; 
           return res;  
        }
        System.Debug('Response for pricing *****' + request.rtQuoteLst );
         Database.SaveResult[] results;
            List<string> errorResults=new List<string>();
        /*Account accnt;
        if(request.customer.accId!=null && ConstantUtility.IsSobjectType('Account',request.customer.accId)){ 
            accnt=(Account)ConstantUtility.getObject('Account', Label.AcntQueryFields,request.customer.accId);
            if(accnt!=null){
                if(accnt.name != null && string.isBlank(accnt.name))
                 accnt.name = request.customer.accname;
                 
            }
        }*/
         Opportunity opp;
         String opptyId = request.customer.OppId;
         System.debug('****request.customer.OppId: ' + request.customer.OppId);
        if(request.customer.OppId!=null && ConstantUtility.IsSobjectType('Opportunity',opptyId)){
            opp=(opportunity)ConstantUtility.getObject('Opportunity', Label.OppQueryFields, request.customer.oppId);
            if(opp!=null){
               if(request.customer.oppType != null && !string.isBlank(request.customer.oppType)){
                opp.Type = request.customer.oppType;
              }
            opp.Refresh_Expiration_Date__c = request.customer.refreshExpirationDate;
            System.debug(' **** Pricing Type Value:' );
            if(opp.recordType.name == 'Standard Opportunity')
                opp.Pricing_Type__c = 'Refresh';
            }
        }
            
        // Get Retail Quotes to Update
        String rtqQuery=ConstantUtility.getObjectFieldsQuery('Retail_Quote__c')+',recordType.name FROM Retail_Quote__c WHERE Opportunity__c = :opptyId';
        Map<id,Retail_Quote__c> rtQuoteMap = new Map<id,Retail_Quote__c>((List<Retail_Quote__c>)Database.Query(rtqQuery));
        List<Product2> prodLst = [select id,name,productcode from Product2];
        System.debug('RTQuote Map : : ' +  rtQuoteMap );  
        for(RetailQuote rq : request.rtQuoteLst){
            System.Debug(' For loop for quotes : :' + rtQuoteMap.containsKey(rq.rtQuoteId) );
            if(rtQuoteMap != null && rtQuoteMap.containsKey(rq.rtQuoteId)){
                 Retail_Quote__c rq1 = rtQuoteMap.get(rq.rtQuoteId);
          //       rq1.name = rq.name;    
                 rq1.Energy__c = rq.Energy;
                 rq1.Basis__c = rq.Basis;
                 rq1.Shaping__c = rq.Shaping;
                 rq1.Swing__c = rq.Swing;
                 rq1.Contract_Margin__c= rq.Margin;
                 rq1.Contract_Index_Margin__c= rq.Index_Margin;
                 rq1.Capacity__c = rq.Capacity;
                 rq1.Utility_Loss__c = rq.Utility_Loss;
                 rq1.ISO_NITS__c = rq.ISO_NITS;
                 rq1.ISO_Other_Trans__c = rq.ISO_Other_Trans;
                 rq1.ISO_ARR__c = rq.ISO_ARR;
                 rq1.ISO_Ancillaries__c = rq.ISO_Ancillaries;
                 rq1.ISO_Losses__c = rq.ISO_Losses;
                 rq1.ISO_Op_Reserve_RSG__c = rq.ISO_Op_Reserve_RSG;
                 rq1.ISO_Cost_Recovery__c = rq.ISO_Cost_Recovery;
                 rq1.ISO_Inadvertant__c = rq.ISO_Inadvertant;
                 rq1.ISO_SSR_RMR__c = rq.ISO_SSR_RMR;
                 rq1.ISO_Admin__c = rq.ISO_Admin;
                 rq1.ISO_FTR__c = rq.ISO_FTR;
                 rq1.RPS__c = rq.RPS ;
                 
                 rq1.Total_Priced_KWH__c = rq.Total_Priced_KWH;
                 rq1.Total_Priced_MWH__c = rq.Total_Priced_MWH;
                 rq1.Quote_Index_Name__c = rq.Quote_Index_Name;
                 rq1.Quote_Index_Adder_Total__c = rq.Quote_Index_Adder_Total;
                 
                 rq1.Vol_Rec__c = rq.Vol_Rec;
                 rq1.Contract_Broker_Fee__c = rq.Broker_Fee;
                 rq1.Contract_Municipality_Fee__c= rq.Municipality_Fee;
                 rq1.Contract_Marketing_Cost__c= rq.Marketing_Cost;
                 rq1.Default_Risk__c = rq.Default_Risk;
                 rq1.UCB_POR__c = rq.UCB_POR;
                 rq1.Holding_Cost__c = rq.Holding_Cost;
                 rq1.Tax__c = rq.Tax;
                 rq1.Contract_Energy_On_PK__c = rq.Contract_Energy_On_PK;
                 rq1.Contract_Energy_Off_PK__c = rq.Contract_Energy_Off_PK;
                 rq1.Contract_Capacity__c = rq.Contract_Capacity;
                 rq1.Contract_Utility_Loss__c = rq.Contract_Utility_Loss;
                 rq1.Contract_Transmission__c = rq.Contract_Transmission;
                 rq1.Contract_Ancillary_Services__c = rq.Contract_Ancillary_Services;
                 rq1.Contract_RPS__c = rq.Contract_RPS;
                 rq1.Contract_Voluntary_Rec__c = rq.Contract_Voluntary_Rec;
                 
                 rq1.ALL_IN_Price__c = rq.ALL_IN_Price;
                 rq1.Quote_Index_Adder_Total_Per_KWH__c = rq.Quote_Index_Adder_Total_Per_KWH;
                 
                 rq1.Contract_Index_adder__c = rq.Contract_Index_adder;
                 rq1.Contract_On_PK_Block_Size__c = rq.Contract_On_PK_Block_Size;
                 rq1.Contract_Off_PK_Block_Size__c = rq.Contract_Off_PK_Block_Size;
                 rq1.Contract_Energy__c = rq.Contract_Energy;
                 rq1.Contract_Vol_Rec__c = rq.Contract_Vol_Rec;
                 rq1.Contract_Vol_Rec_Product__c = rq.Contract_Vol_Rec_Product;
                 rq1.Pricing_Method__c = rq.Pricing_Method;
                 rq1.Price_Complete_Date_Time__c = rq.Price_Complete_Date_Time;
                 rq1.Pricing_Analyst__c = rq.Pricing_Analyst;
                 rq1.Pricing_Notes__c = rq.Pricing_Notes;
                 rq1.Notional_Value__c = rq.Notional_Value;
                 rq1.X60_Day_Max_Exposure__c = rq.X60_Day_Max_Exposure;
                 rq1.Tier_Level__c = rq.Tier_Level;
                 rq1.Aggregate_PLC__c = rq.Aggregate_PLC;
                 rq1.Quote_Price__c = rq.Quote_Price;
                 rq1.Quote_Price_KWH__c = rq.Quote_Price_KWH;
                 rq1.Request_Status__c = rq.Request_Status;
                 rq1.Pricing_valid_Date_Time__c = rq.Pricing_valid_Date_Time;
                System.Debug('****Request Status **** :' + rq.Request_Status);
                System.Debug('****Basis**** :' + rq.Basis);
                System.Debug('***Energy***** :' + rq.Energy);
                     
            }    
        }
        System.Debug('LDC Account List : ' + request.ldcAccLst);
        // Get LDC Accounts to Update
        Set<id> ldcAccIdLst = new Set<Id>();
        Map<id,LDC_Account__c> ldcAccntMap = new Map<id,LDC_Account__c>();
        If(request.ldcAccLst != null) {
            for(LDCAccount ldcAcc : request.ldcAccLst)
                ldcAccIdLst.add(ldcAcc.ldaccountId); 
            string ldcQuery=ConstantUtility.getObjectFieldsQuery('LDC_Account__c') +' From LDC_Account__c where id=:ldcAccIdLst' ;
            ldcAccntMap = new Map<id,LDC_Account__c>((List<LDC_Account__c>)Database.Query(ldcQuery));
            
            for(LDCAccount ldcAcc : request.ldcAccLst){
                if(ldcAccntMap != null && ldcAccntMap.containsKey(ldcAcc.ldaccountId)){
                    system.debug('Test LDC Account : '+ldcAcc);
                    LDC_Account__c ldcAcc1 = ldcAccntMap.get(ldcAcc.ldaccountId);
                    ldcAcc1.Utility_Zone__c = (ldcAcc.Utility_Zone != null)? ldcAcc.Utility_Zone : ldcAcc1.Utility_Zone__c;
                    ldcAcc1.Bill_Cycle__c = (ldcAcc.Bill_Cycle != null)? ldcAcc.Bill_Cycle : ldcAcc1.Bill_Cycle__c;
                    ldcAcc1.Supply_Voltage__c = (ldcAcc.Supply_Voltage != null)? ldcAcc.Supply_Voltage : ldcAcc1.Supply_Voltage__c;
                    ldcAcc1.Delivery_Voltage__c = (ldcAcc.Delivery_Voltage != null)? ldcAcc.Delivery_Voltage : ldcAcc1.Delivery_Voltage__c;
                    ldcAcc1.Utility_Rate_Class__c = (ldcAcc.Utility_Rate_Class != null)? ldcAcc.Utility_Rate_Class : ldcAcc1.Utility_Rate_Class__c;
                    ldcAcc1.Capacity_PLC1__c = (ldcAcc.Capacity_PLC1 != null)? ldcAcc.Capacity_PLC1 : ldcAcc1.Capacity_PLC1__c;
                    ldcAcc1.Capacity_PLC1_Start_Date__c = (ldcAcc.Capacity_PLC1_Start_Date != null)? ldcAcc.Capacity_PLC1_Start_Date : ldcAcc1.Capacity_PLC1_Start_Date__c;
                    ldcAcc1.Capacity_PLC1_End_Date__c = (ldcAcc.Capacity_PLC1_End_Date != null)? ldcAcc.Capacity_PLC1_End_Date : ldcAcc1.Capacity_PLC1_End_Date__c;
                    ldcAcc1.Capacity_PLC2__c = (ldcAcc.Capacity_PLC2 != null)? ldcAcc.Capacity_PLC2 : ldcAcc1.Capacity_PLC2__c;
                    ldcAcc1.Capacity_PLC2_Start__c = (ldcAcc.Capacity_PLC2_Start != null)? ldcAcc.Capacity_PLC2_Start : ldcAcc1.Capacity_PLC2_Start__c;
                    ldcAcc1.Capacity_PLC2_End__c = (ldcAcc.Capacity_PLC2_End != null)? ldcAcc.Capacity_PLC2_End :  ldcAcc1.Capacity_PLC2_End__c;
                    ldcAcc1.NSPL1_KW__c = (ldcAcc.NSPL1_KW != null)? ldcAcc.NSPL1_KW : ldcAcc1.NSPL1_KW__c;
                    ldcAcc1.NSPL1_Start_Date__c = (ldcAcc.NSPL1_Start_Date != null)? ldcAcc.NSPL1_Start_Date : ldcAcc1.NSPL1_Start_Date__c;
                    ldcAcc1.NSPL1_End_Date__c = (ldcAcc.NSPL1_End_Date != null)? ldcAcc.NSPL1_End_Date : ldcAcc1.NSPL1_End_Date__c;
                    ldcAcc1.NSPL2_KW__c = (ldcAcc.NSPL2_KW != null)? ldcAcc.NSPL2_KW : ldcAcc1.NSPL2_KW__c;
                    ldcAcc1.NSPL2_Start_Date__c = (ldcAcc.NSPL2_Start_Date != null)? ldcAcc.NSPL2_Start_Date : ldcAcc1.NSPL2_Start_Date__c;
                    ldcAcc1.NSPL2_End_Date__c = (ldcAcc.NSPL2_End_Date != null)? ldcAcc.NSPL2_End_Date : ldcAcc1.NSPL2_End_Date__c;
                    ldcAcc1.Acct__c = (ldcAcc.Acct != null)? ldcAcc.Acct : ldcAcc1.Acct__c;
                    ldcAcc1.Acct_Annual_Usage__c = (ldcAcc.Acct_Annual_Usage != null)? ldcAcc.Acct_Annual_Usage : ldcAcc1.Acct_Annual_Usage__c;
                    ldcAcc1.On_PK_Kwh__c = (ldcAcc.On_PK_Kwh != null)? ldcAcc.On_PK_Kwh : ldcAcc1.On_PK_Kwh__c;
                    ldcAcc1.Off_Pk_Kwh__c = (ldcAcc.Off_Pk_Kwh != null)? ldcAcc.Off_Pk_Kwh : ldcAcc1.Off_Pk_Kwh__c;
                    ldcAcc1.Pctg_On_Peak__c = (ldcAcc.Pctg_On_Peak != null)? ldcAcc.Pctg_On_Peak : ldcAcc1.Pctg_On_Peak__c;
                    ldcAcc1.Pctg_Off_PK__c = (ldcAcc.Pctg_Off_PK != null)? ldcAcc.Pctg_Off_Pk : ldcAcc1.Pctg_Off_Pk__c;
                    ldcAcc1.Max_Demand__c = (ldcAcc.Max_Demand != null)? ldcAcc.Max_Demand : ldcAcc1.Max_Demand__c;
                    ldcAcc1.Acct_ADU__c = (ldcAcc.Acct_ADU != null)? ldcAcc.Acct_ADU : ldcAcc1.Acct_ADU__c;
                    ldcAcc1.Load_Retrieval_Date__c = (ldcAcc.Load_Retrieval_Date != null)? ldcAcc.Load_Retrieval_Date : ldcAcc1.Load_Retrieval_Date__c;
                    ldcAcc1.Eligible_Switch_Date__c = (ldcAcc.Eligible_Switch_Date != null)? ldcAcc.Eligible_Switch_Date : ldcAcc1.Eligible_Switch_Date__c;
                    ldcAcc1.AMI_Meter__c = (ldcAcc.AMI_Meter != null)? ldcAcc.AMI_Meter : ldcAcc1.AMI_Meter__c;
                    ldcAcc1.Supply_Group__c = (ldcAcc.Supply_Group != null)? ldcAcc.Supply_Group : ldcAcc1.Supply_Group__c;
                    ldcAcc1.Load_Factor_Energy__c = (ldcAcc.Load_Factor_Energy != null)? ldcAcc.Load_Factor_Energy : ldcAcc1.Load_Factor_Energy__c;
                    ldcAcc1.PLC_Load_Factor__c = (ldcAcc.PLC_Load_Factor != null)? ldcAcc.PLC_Load_Factor : ldcAcc1.PLC_Load_Factor__c;
                    ldcAcc1.NSPL_Load_Factor__c = (ldcAcc.NSPL_Load_Factor != null)? ldcAcc.NSPL_Load_Factor : ldcAcc1.NSPL_Load_Factor__c;
                    ldcAcc1.Load_Days__c = (ldcAcc.Load_Days != null)? ldcAcc.Load_Days : ldcAcc1.Load_Days__c;
                    ldcAcc1.Load_Data_Acquisition_Type__c = (ldcAcc.Load_Data_Acquisition_Type != null)? ldcAcc.Load_Data_Acquisition_Type : ldcAcc1.Load_Data_Acquisition_Type__c;
                    ldcAcc1.Data_Utility_Link__c = (ldcAcc.Data_Utility_Link != null)? ldcAcc.Data_Utility_Link : ldcAcc1.Data_Utility_Link__c; 
                    ldcAcc1.FRM_Profile__c = (ldcAcc.FRM_Profile != null)? ldcAcc.FRM_Profile : ldcAcc1.FRM_Profile__c;
                    ldcAcc1.Interval_Data_Ordered__c = (ldcAcc.Interval_Data_Ordered != null)? ldcAcc.Interval_Data_Ordered : ldcAcc1.Interval_Data_Ordered__c;
                    ldcAcc1.Service_Street_1__c = (ldcAcc.Service_Street_1 != null)? ldcAcc.Service_Street_1 : ldcAcc1.Service_Street_1__c;
                    ldcAcc1.Service_Street_2__c = (ldcAcc.Service_Street_2 != null)? ldcAcc.Service_Street_2 : ldcAcc1.Service_Street_2__c;
                    ldcAcc1.Service_City__c = (ldcAcc.Service_City != null)? ldcAcc.Service_City : ldcAcc1.Service_City__c;
                    ldcAcc1.Service_County__c = (ldcAcc.Service_County != null)? ldcAcc.Service_County : ldcAcc1.Service_County__c;
                    ldcAcc1.Service_State__c = (ldcAcc.Service_State != null)? ldcAcc.Service_State : ldcAcc1.Service_State__c;
                    ldcAcc1.Service_Postal_Code__c = (ldcAcc.Service_Postal_Code != null)? ldcAcc.Service_Postal_Code : ldcAcc1.Service_Postal_Code__c;
                }     
            } 
         }
    
        try{
              if(ldcAccntMap != null && ldcAccntMap.values().size() >0){
              	 TriggerHandler.pricingUpdate = false; 
              	 update ldcAccntMap.values();
              }
                            
             //  Database.update(ldcAccntMap.values(),false);
   
              if(rtQuoteMap != null && rtQuoteMap.values().size() >0)  
                  Update rtQuoteMap.values();  //Database.update(rtQuoteMap.values(),false);
                    
              if(opp != null)
                 update opp; //  Database.update(opp,false);
     
              /*if(accnt != null)
                Update accnt; */ //Database.update(accnt,false);
            
                res.status=ConstantUtility.STATUS_SUCCESS;
                res.MessageDesc ='Response Processed Successfully'; 
               
           }
           catch(Exception e){
               res.status=ConstantUtility.STATUS_Failure;
               res.MessageDesc = 'Exception'+e.getMessage(); 
               system.debug('Exception::'+e.getStackTraceString());
           }
        
       return res; 
        
    }
 
    
   global class PricingResponse{
       Webservice Customer customer {get; set;}
       Webservice List<RetailQuote> rtQuoteLst {set;get;}
       Webservice List<LDCAccount> ldcAccLst {set;get;}
   }

  global class Customer{

      Webservice id accid;
      webservice String accName;
      Webservice id oppid ;
      Webservice date refreshExpirationDate ;
      Webservice String oppType ;
      Webservice String Workbook_Location ;
  //    Webservice id cdid ;
        
  }

  global Class RetailQuote{

      Webservice id oppid ;
      Webservice id rtQuoteId ;
      Webservice decimal Energy ;
      Webservice decimal Basis ;
      Webservice decimal Shaping ;
      Webservice decimal Swing ;
      Webservice decimal Margin ;
      Webservice decimal Index_Margin ;
      Webservice decimal Capacity;
      Webservice decimal Utility_Loss;
      Webservice decimal ISO_NITS ;
      Webservice decimal ISO_Other_Trans ;
      Webservice decimal ISO_ARR ;
      Webservice decimal ISO_Ancillaries ;
      Webservice decimal ISO_Losses ;
      Webservice decimal ISO_Op_Reserve_RSG ;
      Webservice decimal ISO_Cost_Recovery ;
      Webservice decimal ISO_Inadvertant ;
      Webservice decimal ISO_SSR_RMR ;
      Webservice decimal ISO_Admin ;
      Webservice decimal ISO_FTR ;
      Webservice decimal RPS ;
      //Added new fields for missing information
      Webservice decimal ALL_IN_Price ;
      Webservice decimal Total_Priced_MWH ;
      Webservice decimal Quote_Index_Adder_Total ;
      Webservice String Quote_Index_Name ;
      Webservice String Quote_Index_Adder_Total_Per_KWH;
      Webservice decimal Total_Priced_KWH;
      
      Webservice decimal Vol_Rec ;
      Webservice decimal Broker_Fee ;
      Webservice decimal Municipality_Fee ;
      Webservice decimal Marketing_Cost ;
      Webservice decimal Default_Risk ;
      Webservice decimal UCB_POR ;
      Webservice decimal Holding_Cost ;
      Webservice decimal Tax ;
      Webservice String Contract_Energy_On_PK ;
      Webservice String Contract_Energy_Off_PK ;
      Webservice String Contract_Capacity;
      Webservice String Contract_Utility_Loss;
      Webservice String Contract_Transmission;
      Webservice String Contract_Ancillary_Services ;
      Webservice String Contract_RPS;
      Webservice String Contract_Voluntary_REC ;
      Webservice String Contract_Index_adder;
      Webservice String Contract_On_PK_Block_Size;
      Webservice String Contract_Off_PK_Block_Size;
      Webservice String Contract_Energy;
      Webservice String Contract_Vol_Rec;
      Webservice String Contract_Vol_Rec_Product ;
      Webservice String Pricing_Method ;
      Webservice DateTime Price_Complete_Date_Time ;
      Webservice String Pricing_Analyst ;
      Webservice String Pricing_Notes ;
      Webservice decimal Notional_Value ;
      Webservice decimal X60_Day_Max_Exposure ;
      Webservice String Tier_Level ;
      Webservice Decimal Aggregate_PLC;
      Webservice Decimal Quote_Price;
      Webservice decimal Quote_Price_KWH;
      Webservice String Request_Status ;
      Webservice DateTime Pricing_valid_Date_Time ;
          
  }

   global Class LDCAccount{

      Webservice id ldaccountId ;
      Webservice String LDC_Account_Utility ;
      Webservice String Utility_Zone ;
      Webservice string Bill_Cycle;
      Webservice string Supply_Voltage ;
      Webservice string Delivery_Voltage ;
      Webservice string Utility_Rate_Class;
      Webservice decimal Capacity_PLC1 ;
      Webservice date Capacity_PLC1_Start_Date ;
      Webservice date Capacity_PLC1_End_Date ;
      Webservice decimal Capacity_PLC2 ;
      Webservice date Capacity_PLC2_Start ;
      Webservice date Capacity_PLC2_End ;
      Webservice decimal NSPL1_KW ;
      Webservice date NSPL1_Start_Date ;
      Webservice date NSPL1_End_Date ;
      Webservice decimal NSPL2_KW ;
      Webservice date NSPL2_Start_Date ;
      Webservice date NSPL2_End_Date ;
      Webservice String Acct ;
      Webservice decimal Acct_Annual_Usage ;
      Webservice decimal On_PK_Kwh ;
      Webservice decimal Off_PK_Kwh ;
      Webservice decimal Pctg_On_Peak ;
      Webservice decimal Pctg_Off_PK ;
      Webservice decimal Max_Demand ;
      Webservice decimal Acct_ADU ;
      Webservice date Load_Retrieval_Date ;
      Webservice date Eligible_Switch_Date ;
      Webservice string AMI_Meter;
      Webservice string Supply_Group;
      Webservice decimal Load_Factor_Energy ;
      Webservice decimal PLC_Load_Factor ;
      Webservice decimal NSPL_Load_Factor ;
      Webservice decimal Load_Days ;
      Webservice String Load_Data_Acquisition_Type ;
      Webservice String Data_Utility_Link ;
      Webservice String FRM_Profile ;
      Webservice boolean Interval_Data_Ordered ;
      Webservice string Service_Street_1;
      Webservice string Service_Street_2;
      Webservice string Service_City;
      Webservice string Service_State;
      Webservice string Service_Postal_Code;
      Webservice string Service_County;
     
   }

   global class ServiceResponse {
        
        webservice String Status;
        webservice string MessageDesc;
       
    }    
}