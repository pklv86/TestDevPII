/*****************************************Dynegy*************************************************************************************
 * Name: Contracttriggerhandler                                                                                                     *
 * Type: Apex Class                                                                                                                 *
 * Test Class:contracttrigger_test                                                                                                  *
 * Description:  This process is used for creating Contract Terms when the contract is Activated.                                   *                                            
 * Change History:                                                                                                                  *
 *==================================================================================================================================*
 * Version     Author                       Date             Description                                                            *
 * 1.0         Mounika Duggirala            02/26/2017      Initial Version created                                                 *                            
 ************************************************************************************************************************************/
Public class Contracttriggerhandler{
    
    public void createcontracttermsforFP_ONE(contract cont){
        
        list<Contract_Term__c > contracttermsforfpone=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN=new Contract_Term__c();
            TXMN.Term_Type__c='TXMN';
            TXMN.Term_Category__c='STANDARD_BHVONLY';
            TXMN.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN.Value_String__c='KWH';
            TXMN.Contract__c=cont.id;
            contracttermsforfpone.add(TXMN);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX=new Contract_Term__c();
            TAX.Term_Type__c='TAX';
            TAX.Term_Category__c='STANDARD_BHVONLY';
            TAX.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX.Value_String__c='KWH';
            TAX.Contract__c=cont.id;
            contracttermsforfpone.add(TAX);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec=new Contract_Term__c();
            Rec.Term_Type__c='REC';
            Rec.Term_Category__c='STANDARD_BHVONLY';
            Rec.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec.Value_String__c='KWH';
            Rec.Contract__c=cont.id;
            contracttermsforfpone.add(Rec);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT=new Contract_Term__c();
            BFCT.Term_Type__c='CNSLT_FEE';
            BFCT.Term_Category__c='STANDARD_BHVONLY';
            BFCT.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT.Value_String__c= bDescription+','+'KWH';
            BFCT.Contract__c=cont.id;
            system.debug('BFCT: '+BFCT);
            contracttermsforfpone.add(BFCT);
        }
        if(cont.Contract_Municipality_Fee__c!=null && cont.Contract_Municipality_Fee__c>0 && (cont.Bill_Method__c=='Rate Ready'||cont.Bill_Method__c=='Bill Ready' )){
            Contract_Term__c MFCT=new Contract_Term__c();
            MFCT.Term_Type__c='MUNI_FEE';
            MFCT.Term_Category__c='STANDARD_BHVONLY';
            MFCT.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT.Value_String__c='KWH';
            MFCT.Contract__c=cont.id;
            system.debug('MFCT: '+MFCT);
            contracttermsforfpone.add(MFCT);
        }           
        Contract_Term__c AFCT = adminfee(cont);
        if(AFCT.Contract_Term_Value__c!=null && AFCT.Contract_Term_Value__c > 0)
            contracttermsforfpone.add(AFCT);
           
        insert contracttermsforfpone;
    }
    
    public void createcontracttermsforFP_ONE_PT_C(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONE_PT_C=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN1=new Contract_Term__c();
            TXMN1.Term_Type__c='TXMN';
            TXMN1.Term_Category__c='STANDARD_BHVONLY';
            TXMN1.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN1.Value_String__c='KWH';
            TXMN1.Contract__c=cont.id;
            contracttermsforFP_ONE_PT_C.add(TXMN1);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec1=new Contract_Term__c();
            Rec1.Term_Type__c='REC';
            Rec1.Term_Category__c='STANDARD_BHVONLY';
            Rec1.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec1.Value_String__c='KWH';
            Rec1.Contract__c=cont.id;
            contracttermsforFP_ONE_PT_C.add(Rec1);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX1=new Contract_Term__c();
            TAX1.Term_Type__c='TAX';
            TAX1.Term_Category__c='STANDARD_BHVONLY';
            TAX1.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX1.Value_String__c='KWH';
            TAX1.Contract__c=cont.id;
            system.debug('TAX1: '+TAX1);
            contracttermsforFP_ONE_PT_C.add(TAX1);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT1=new Contract_Term__c();
            BFCT1.Term_Type__c='CNSLT_FEE';
            BFCT1.Term_Category__c='STANDARD_BHVONLY';
            BFCT1.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT1.Value_String__c= bDescription+','+'KWH';
            BFCT1.Contract__c=cont.id;
            system.debug('BFCT1: '+BFCT1);
            contracttermsforFP_ONE_PT_C.add(BFCT1);
        }
        Contract_Term__c AFCT1 = adminfee(cont);
        if(AFCT1.Contract_Term_Value__c!=null && AFCT1.Contract_Term_Value__c > 0)
            contracttermsforFP_ONE_PT_C.add(AFCT1);
            
        insert contracttermsforFP_ONE_PT_C;
    }  
     
    public void createcontracttermsforFP_MULT(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_MULT=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN2=new Contract_Term__c();
            TXMN2.Term_Type__c='TXMN';
            TXMN2.Term_Category__c='STANDARD_CHARGE';
            TXMN2.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN2.Value_String__c='KWH';
            TXMN2.Contract__c=cont.id;
            contracttermsforFP_MULT.add(TXMN2);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec2=new Contract_Term__c();
            Rec2.Term_Type__c='REC';
            Rec2.Term_Category__c='STANDARD_CHARGE';
            Rec2.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec2.Value_String__c='KWH';
            Rec2.Contract__c=cont.id;
            contracttermsforFP_MULT.add(Rec2);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX2=new Contract_Term__c();
            TAX2.Term_Type__c='TAX';
            TAX2.Term_Category__c='STANDARD_BHVONLY';
            TAX2.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX2.Value_String__c='KWH';
            TAX2.Contract__c=cont.id;
            contracttermsforFP_MULT.add(TAX2);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT2=new Contract_Term__c();
            BFCT2.Term_Type__c='CNSLT_FEE';
            BFCT2.Term_Category__c='STANDARD_BHVONLY';
            BFCT2.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT2.Value_String__c= bDescription+','+'KWH';
            BFCT2.Contract__c=cont.id;
            contracttermsforFP_MULT.add(BFCT2);
        }
        Contract_Term__c AFCT2 = adminfee(cont);
        if(AFCT2.Contract_Term_Value__c!=null && AFCT2.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT.add(AFCT2);
            
        insert contracttermsforFP_MULT;
    }   
      
    public void createcontracttermsforFP_MULT_PT_L(contract cont){
        
        
        list<Contract_Term__c > contracttermsforFP_MULT_PT_L=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN3=new Contract_Term__c();
            TXMN3.Term_Type__c='TXMN';
            TXMN3.Term_Category__c='STANDARD_CHARGE';
            TXMN3.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN3.Value_String__c='KWH';
            TXMN3.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_L.add(TXMN3);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec3=new Contract_Term__c();
            Rec3.Term_Type__c='REC';
            Rec3.Term_Category__c='STANDARD_CHARGE';
            Rec3.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec3.Value_String__c='KWH';
            Rec3.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_L.add(Rec3);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX3=new Contract_Term__c();
            TAX3.Term_Type__c='TAX';
            TAX3.Term_Category__c='STANDARD_BHVONLY';
            TAX3.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX3.Value_String__c='KWH';
            TAX3.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_L.add(TAX3);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT3=new Contract_Term__c();
            BFCT3.Term_Type__c='CNSLT_FEE';
            BFCT3.Term_Category__c='STANDARD_BHVONLY';
            BFCT3.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT3.Value_String__c= bDescription+','+'KWH';
            BFCT3.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_L.add(BFCT3);
        }
        Contract_Term__c AFCT3 = adminfee(cont);
        if(AFCT3.Contract_Term_Value__c!=null && AFCT3.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT_PT_L.add(AFCT3);
            
        insert contracttermsforFP_MULT_PT_L;
    }  
     
    public void createcontracttermsforFP_MULT_PT_C(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_MULT_PT_C=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN4=new Contract_Term__c();
            TXMN4.Term_Type__c='TXMN';
            TXMN4.Term_Category__c='STANDARD_CHARGE';
            TXMN4.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN4.Value_String__c='KWH';
            TXMN4.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_C.add(TXMN4);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec4=new Contract_Term__c();
            Rec4.Term_Type__c='REC';
            Rec4.Term_Category__c='STANDARD_CHARGE';
            Rec4.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec4.Value_String__c='KWH';
            Rec4.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_C.add(Rec4);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX4=new Contract_Term__c();
            TAX4.Term_Type__c='TAX';
            TAX4.Term_Category__c='STANDARD_BHVONLY';
            TAX4.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX4.Value_String__c='KWH';
            TAX4.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_C.add(TAX4);
        }
       if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT4=new Contract_Term__c();
            BFCT4.Term_Type__c='CNSLT_FEE';
            BFCT4.Term_Category__c='STANDARD_BHVONLY';
            BFCT4.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT4.Value_String__c= bDescription+','+'KWH';
            BFCT4.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_C.add(BFCT4);
        }
        Contract_Term__c AFCT4= adminfee(cont);
        if(AFCT4.Contract_Term_Value__c!=null && AFCT4.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT_PT_C.add(AFCT4);
        
        insert contracttermsforFP_MULT_PT_C;
    } 
    
    public void createcontracttermsforFP_MULT_PT_T(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_MULT_PT_T=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN5=new Contract_Term__c();
            TXMN5.Term_Type__c='TXMN';
            TXMN5.Term_Category__c='PASSTHRU_TXMN';
            TXMN5.Contract_Term_Value__c = 0;
            TXMN5.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_T.add(TXMN5);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec5=new Contract_Term__c();
            Rec5.Term_Type__c='REC';
            Rec5.Term_Category__c='STANDARD_CHARGE';
            Rec5.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec5.Value_String__c='KWH';
            Rec5.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_T.add(Rec5);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX5=new Contract_Term__c();
            TAX5.Term_Type__c='TAX';
            TAX5.Term_Category__c='STANDARD_BHVONLY';
            TAX5.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX5.Value_String__c='KWH';
            TAX5.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_T.add(TAX5);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT5=new Contract_Term__c();
            BFCT5.Term_Type__c='CNSLT_FEE';
            BFCT5.Term_Category__c='STANDARD_BHVONLY';
            BFCT5.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT5.Value_String__c= bDescription+','+'KWH';
            BFCT5.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_T.add(BFCT5);
        }
        Contract_Term__c AFCT5= adminfee(cont);
        if(AFCT5.Contract_Term_Value__c!=null && AFCT5.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT_PT_T.add(AFCT5);
        
        insert contracttermsforFP_MULT_PT_T;
    }  
    
    public void createcontracttermsforFP_MULT_PT_CL(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_MULT_PT_CL=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN6=new Contract_Term__c();
            TXMN6.Term_Type__c='TXMN';
            TXMN6.Term_Category__c='STANDARD_CHARGE';
            TXMN6.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN6.Value_String__c='KWH';
            TXMN6.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CL.add(TXMN6);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec6=new Contract_Term__c();
            Rec6.Term_Type__c='REC';
            Rec6.Term_Category__c='STANDARD_CHARGE';
            Rec6.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec6.Value_String__c='KWH';
            Rec6.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CL.add(Rec6);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX6=new Contract_Term__c();
            TAX6.Term_Type__c='TAX';
            TAX6.Term_Category__c='STANDARD_BHVONLY';
            TAX6.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX6.Value_String__c='KWH';
            TAX6.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CL.add(TAX6);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT6=new Contract_Term__c();
            BFCT6.Term_Type__c='CNSLT_FEE';
            BFCT6.Term_Category__c='STANDARD_BHVONLY';
            BFCT6.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT6.Value_String__c= bDescription+','+'KWH';
            BFCT6.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CL.add(BFCT6);
        }
        Contract_Term__c AFCT6= adminfee(cont);
        if(AFCT6.Contract_Term_Value__c!=null && AFCT6.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT_PT_CL.add(AFCT6);
        
        insert contracttermsforFP_MULT_PT_CL;
    } 
    
    public void createcontracttermsforFP_MULT_PT_CLT(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_MULT_PT_CLT=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN7=new Contract_Term__c();
            TXMN7.Term_Type__c='TXMN';
            TXMN7.Term_Category__c='PASSTHRU_TXMN';
            TXMN7.Contract_Term_Value__c = 0;
            TXMN7.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CLT.add(TXMN7);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec7=new Contract_Term__c();
            Rec7.Term_Type__c='REC';
            Rec7.Term_Category__c='STANDARD_CHARGE';
            Rec7.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec7.Value_String__c='KWH';
            Rec7.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CLT.add(Rec7);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX7=new Contract_Term__c();
            TAX7.Term_Type__c='TAX';
            TAX7.Term_Category__c='STANDARD_BHVONLY';
            TAX7.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX7.Value_String__c='KWH';
            TAX7.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CLT.add(TAX7);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT7=new Contract_Term__c();
            BFCT7.Term_Type__c='CNSLT_FEE';
            BFCT7.Term_Category__c='STANDARD_BHVONLY';
            BFCT7.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT7.Value_String__c= bDescription+','+'KWH';
            BFCT7.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CLT.add(BFCT7);
        }
        Contract_Term__c AFCT7= adminfee(cont);
        if(AFCT7.Contract_Term_Value__c!=null && AFCT7.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT_PT_CLT.add(AFCT7);
        
        insert contracttermsforFP_MULT_PT_CLT;
    }  
    
    public void createcontracttermsforFP_MULT_PT_LT(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_MULT_PT_LT=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN8=new Contract_Term__c();
            TXMN8.Term_Type__c='TXMN';
            TXMN8.Term_Category__c='PASSTHRU_TXMN';
            TXMN8.Contract_Term_Value__c = 0;
            TXMN8.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_LT.add(TXMN8);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec8=new Contract_Term__c();
            Rec8.Term_Type__c='REC';
            Rec8.Term_Category__c='STANDARD_CHARGE';
            Rec8.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec8.Value_String__c='KWH';
            Rec8.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_LT.add(Rec8);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT8=new Contract_Term__c();
            BFCT8.Term_Type__c='CNSLT_FEE';
            BFCT8.Term_Category__c='STANDARD_BHVONLY';
            BFCT8.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT8.Value_String__c= bDescription+','+'KWH';
            BFCT8.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_LT.add(BFCT8);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX8=new Contract_Term__c();
            TAX8.Term_Type__c='TAX';
            TAX8.Term_Category__c='STANDARD_BHVONLY';
            TAX8.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX8.Value_String__c='KWH';
            TAX8.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_LT.add(TAX8);
        }
        Contract_Term__c AFCT8= adminfee(cont);
        if(AFCT8.Contract_Term_Value__c!=null && AFCT8.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT_PT_LT.add(AFCT8);
        
        insert contracttermsforFP_MULT_PT_LT;
    }
    
    public void createcontracttermsforFP_MULT_PT_CT(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_MULT_PT_CT=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN9=new Contract_Term__c();
            TXMN9.Term_Type__c='TXMN';
            TXMN9.Term_Category__c='PASSTHRU_TXMN';
            TXMN9.Contract_Term_Value__c = 0;
            TXMN9.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CT.add(TXMN9);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec9=new Contract_Term__c();
            Rec9.Term_Type__c='REC';
            Rec9.Term_Category__c='STANDARD_CHARGE';
            Rec9.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec9.Value_String__c='KWH';
            Rec9.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CT.add(Rec9);
        }
        if(cont.Contract_Broker_Fee__c!=null && cont.Contract_Broker_Fee__c>0 && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT9=new Contract_Term__c();
            BFCT9.Term_Type__c='CNSLT_FEE';
            BFCT9.Term_Category__c='STANDARD_BHVONLY';
            BFCT9.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT9.Value_String__c= bDescription+','+'KWH';
            BFCT9.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CT.add(BFCT9);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX9=new Contract_Term__c();
            TAX9.Term_Type__c='TAX';
            TAX9.Term_Category__c='STANDARD_BHVONLY';
            TAX9.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX9.Value_String__c='KWH';
            TAX9.Contract__c=cont.id;
            contracttermsforFP_MULT_PT_CT.add(TAX9);
        }
        Contract_Term__c AFCT9= adminfee(cont);
        if(AFCT9.Contract_Term_Value__c!=null && AFCT9.Contract_Term_Value__c > 0)
            contracttermsforFP_MULT_PT_CT.add(AFCT9);
        
        insert contracttermsforFP_MULT_PT_CT;
    }  
    
    public void createcontracttermsforFP_ONOFF(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN10=new Contract_Term__c();
            TXMN10.Term_Type__c='TXMN';
            TXMN10.Term_Category__c='STANDARD_CHARGE';
            TXMN10.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN10.Value_String__c='KWH';
            TXMN10.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(TXMN10);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec10=new Contract_Term__c();
            Rec10.Term_Type__c='REC';
            Rec10.Term_Category__c='STANDARD_CHARGE';
            Rec10.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec10.Value_String__c='KWH';
            Rec10.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(Rec10);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX10=new Contract_Term__c();
            TAX10.Term_Type__c='TAX';
            TAX10.Term_Category__c='STANDARD_BHVONLY';
            TAX10.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX10.Value_String__c='KWH';
            TAX10.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(TAX10);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT10=new Contract_Term__c();
            BFCT10.Term_Type__c='CNSLT_FEE';
            BFCT10.Term_Category__c='NOTBILLED';
            BFCT10.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT10.Value_String__c= bDescription+','+'KWH';
            BFCT10.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(BFCT10);
        }
        if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT01a=new Contract_Term__c();
            BFCT01a.Term_Type__c='ENERGY';
            BFCT01a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT01a.Contract_Term_Value__c=0;
             BFCT01a.Value_String__c='null';
            BFCT01a.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(BFCT01a);
        
            Contract_Term__c BFCT01b=new Contract_Term__c();
            BFCT01b.Term_Type__c='ONPK_ENERGY';
            BFCT01b.Term_Category__c='NOTBILLED';
            system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string abc = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (abc.startswith('$'))
            abc = abc.removeStart('$');
            BFCT01b.Contract_Term_Value__c= decimal.valueof(abc);
            BFCT01b.Value_String__c='ONPK_KWH';
            BFCT01b.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(BFCT01b);
       
            Contract_Term__c BFCT01c=new Contract_Term__c();
            BFCT01c.Term_Type__c='OFFPK_ENERG';
            BFCT01c.Term_Category__c='NOTBILLED';
            string abc1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (abc1.startswith('$'))
            abc1 = abc1.removeStart('$');
            BFCT01c.Contract_Term_Value__c= decimal.valueof(abc1);
            BFCT01c.Value_String__c='OFFPK_KWH';
            BFCT01c.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(BFCT01c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT01=new Contract_Term__c();
            BFCT01.Term_Type__c='ONPK_ENERGY';
            BFCT01.Term_Category__c='STANDARD_CHARGE';
            BFCT01.Value_String__c='ONPK_KWH';      
            string abc1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (abc1.startswith('$'))
            abc1 = abc1.removeStart('$');
            BFCT01.Contract_Term_Value__c= decimal.valueof(abc1);
            BFCT01.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(BFCT01);
        
            Contract_Term__c BFCT011=new Contract_Term__c();
            BFCT011.Term_Type__c='OFFPK_ENERGY';
            BFCT011.Term_Category__c='STANDARD_CHARGE';
            BFCT011.Value_String__c='OFFPK_KWH';      
            string abc2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (abc2.startswith('$'))
            abc2 = abc2.removeStart('$');
            BFCT011.Contract_Term_Value__c= decimal.valueof(abc2);
            BFCT011.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(BFCT011);
        }

        if(cont.Contract_Municipality_Fee__c!=null && cont.Contract_Municipality_Fee__c>0)
        {            
            Contract_Term__c MFCT10=new Contract_Term__c();
            MFCT10.Term_Type__c='MUNI_FEE';
            MFCT10.Term_Category__c='STANDARD_BHVONLY';
            MFCT10.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT10.Value_String__c='KWH';
            MFCT10.Contract__c=cont.id;
            contracttermsforFP_ONOFF.add(MFCT10);
        }
                     
        Contract_Term__c AFCT10= adminfee(cont);
        if(AFCT10.Contract_Term_Value__c!=null && AFCT10.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF.add(AFCT10);
        insert contracttermsforFP_ONOFF;
    } 
    
    public void createcontracttermsforFP_ONOFF_PT_C(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF_PT_C=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN11=new Contract_Term__c();
            TXMN11.Term_Type__c='TXMN';
            TXMN11.Term_Category__c='STANDARD_CHARGE';
            TXMN11.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN11.Value_String__c='KWH';
            TXMN11.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(TXMN11);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec11=new Contract_Term__c();
            Rec11.Term_Type__c='REC';
            Rec11.Term_Category__c='STANDARD_CHARGE';
            Rec11.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec11.Value_String__c='KWH';
            Rec11.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(Rec11);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX11=new Contract_Term__c();
            TAX11.Term_Type__c='TAX';
            TAX11.Term_Category__c='STANDARD_BHVONLY';
            TAX11.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX11.Value_String__c='KWH';
            TAX11.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(TAX11);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT11=new Contract_Term__c();
            BFCT11.Term_Type__c='CNSLT_FEE';
            BFCT11.Term_Category__c='NOTBILLED';
            BFCT11.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT11.Value_String__c= bDescription+','+'KWH';
            BFCT11.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(BFCT11);
        }
         if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT02a=new Contract_Term__c();
            BFCT02a.Term_Type__c='ENERGY';
            BFCT02a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT02a.Contract_Term_Value__c=0;
             BFCT02a.Value_String__c='null';
            BFCT02a.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(BFCT02a);
        
            Contract_Term__c BFCT02b=new Contract_Term__c();
            BFCT02b.Term_Type__c='ONPK_ENERGY';
            BFCT02b.Term_Category__c='NOTBILLED';
            system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string ptc = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptc.startswith('$'))
            ptc = ptc.removeStart('$');
            BFCT02b.Contract_Term_Value__c= decimal.valueof(ptc);
            BFCT02b.Value_String__c='ONPK_KWH';
            BFCT02b.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(BFCT02b);
        
            Contract_Term__c BFCT02c=new Contract_Term__c();
            BFCT02c.Term_Type__c='OFFPK_ENERG';
            BFCT02c.Term_Category__c='NOTBILLED';
            string ptc1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptc1.startswith('$'))
            ptc1 = ptc1.removeStart('$');
            BFCT02c.Contract_Term_Value__c= decimal.valueof(ptc1);
            BFCT02c.Value_String__c='OFFPK_KWH';
            BFCT02c.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(BFCT02c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT02=new Contract_Term__c();
            BFCT02.Term_Type__c='ONPK_ENERGY';
            BFCT02.Term_Category__c='STANDARD_CHARGE';
             BFCT02.Value_String__c='ONPK_KWH';      
            string ptc1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptc1.startswith('$'))
            ptc1 = ptc1.removeStart('$');
            BFCT02.Contract_Term_Value__c= decimal.valueof(ptc1);
            BFCT02.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(BFCT02);
            
            Contract_Term__c BFCT022=new Contract_Term__c();
            BFCT022.Term_Type__c='OFFPK_ENERGY';
            BFCT022.Term_Category__c='STANDARD_CHARGE';
            BFCT022.Value_String__c='OFFPK_KWH';      
            string ptc2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptc2.startswith('$'))
            ptc2 = ptc2.removeStart('$');
            BFCT022.Contract_Term_Value__c= decimal.valueof(ptc2);
            BFCT022.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(BFCT022);
        }

        if(cont.Contract_Municipality_Fee__c!=null && cont.Contract_Municipality_Fee__c>0){            
            Contract_Term__c MFCT11=new Contract_Term__c();
            MFCT11.Term_Type__c='MUNI_FEE';
            MFCT11.Term_Category__c='STANDARD_BHVONLY';
            MFCT11.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT11.Value_String__c='KWH';
            MFCT11.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_C.add(MFCT11);
        }             
        Contract_Term__c AFCT11= adminfee(cont);
        if(AFCT11.Contract_Term_Value__c!=null && AFCT11.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF_PT_C.add(AFCT11);
        
        insert contracttermsforFP_ONOFF_PT_C;
    } 
    
    public void createcontracttermsforFP_ONOFF_PT_L(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF_PT_L=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN12=new Contract_Term__c();
            TXMN12.Term_Type__c='TXMN';
            TXMN12.Term_Category__c='STANDARD_CHARGE';
            TXMN12.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN12.Value_String__c='KWH';
            TXMN12.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(TXMN12);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec12=new Contract_Term__c();
            Rec12.Term_Type__c='REC';
            Rec12.Term_Category__c='STANDARD_CHARGE';
            Rec12.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec12.Value_String__c='KWH';
            Rec12.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(Rec12);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX12=new Contract_Term__c();
            TAX12.Term_Type__c='TAX';
            TAX12.Term_Category__c='STANDARD_BHVONLY';
            TAX12.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX12.Value_String__c='KWH';
            TAX12.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(TAX12);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT12=new Contract_Term__c();
            BFCT12.Term_Type__c='CNSLT_FEE';
            BFCT12.Term_Category__c='NOTBILLED';
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT12.Value_String__c= bDescription+','+'KWH';
            BFCT12.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            BFCT12.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(BFCT12);
        }
         if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT03a=new Contract_Term__c();
            BFCT03a.Term_Type__c='ENERGY';
            BFCT03a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT03a.Contract_Term_Value__c=0;
            BFCT03a.Value_String__c='null';
            BFCT03a.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(BFCT03a);
       
            Contract_Term__c BFCT03b=new Contract_Term__c();
            BFCT03b.Term_Type__c='ONPK_ENERGY';
            BFCT03b.Term_Category__c='NOTBILLED';
            system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string ptl = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if(ptl.startswith('$'))
            ptl = ptl.removeStart('$');
            BFCT03b.Contract_Term_Value__c= decimal.valueof(ptl);
            BFCT03b.Value_String__c='ONPK_KWH';
            BFCT03b.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(BFCT03b);
            
            Contract_Term__c BFCT03c=new Contract_Term__c();
            BFCT03c.Term_Type__c='OFFPK_ENERG';
            BFCT03c.Term_Category__c='NOTBILLED';
            string ptl1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptl1.startswith('$'))
            ptl1 = ptl1.removeStart('$');
            BFCT03c.Contract_Term_Value__c= decimal.valueof(ptl1);
            BFCT03c.Value_String__c='OFFPK_KWH';
            BFCT03c.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(BFCT03c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT03=new Contract_Term__c();
            BFCT03.Term_Type__c='ONPK_ENERGY';
            BFCT03.Term_Category__c='STANDARD_CHARGE';
            BFCT03.Value_String__c='ONPK_KWH';      
            string ptl1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptl1.startswith('$'))
            ptl1 = ptl1.removeStart('$');
             BFCT03.Contract_Term_Value__c= decimal.valueof(ptl1);
            BFCT03.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(BFCT03);
        
            Contract_Term__c BFCT033=new Contract_Term__c();
            BFCT033.Term_Type__c='OFFPK_ENERGY';
            BFCT033.Term_Category__c='STANDARD_CHARGE';
            BFCT033.Value_String__c='OFFPK_KWH';      
            string ptl2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptl2.startswith('$'))
            ptl2 = ptl2.removeStart('$');
            BFCT033.Contract_Term_Value__c= decimal.valueof(ptl2);
            BFCT033.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(BFCT033);
        }

        if(cont.Contract_Municipality_Fee__c!=null && cont.Contract_Municipality_Fee__c>0){            
            Contract_Term__c MFCT12=new Contract_Term__c();
            MFCT12.Term_Type__c='MUNI_FEE';
            MFCT12.Term_Category__c='STANDARD_BHVONLY';
            MFCT12.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT12.Value_String__c='KWH';
            MFCT12.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_L.add(MFCT12);
        }             
        Contract_Term__c AFCT12= adminfee(cont);
        if(AFCT12.Contract_Term_Value__c!=null && AFCT12.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF_PT_L.add(AFCT12);
        
        insert contracttermsforFP_ONOFF_PT_L;
    }   
     
    public void createcontracttermsforFP_ONOFF_PT_T(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF_PT_T=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN13=new Contract_Term__c();
            TXMN13.Term_Type__c='TXMN';
            TXMN13.Term_Category__c='PASSTHRU_TXMN';
            TXMN13.Contract_Term_Value__c = 0;
            TXMN13.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(TXMN13);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec13=new Contract_Term__c();
            Rec13.Term_Type__c='REC';
            Rec13.Term_Category__c='STANDARD_CHARGE';
            Rec13.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec13.Value_String__c='KWH';
            Rec13.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(Rec13);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX13=new Contract_Term__c();
            TAX13.Term_Type__c='TAX';
            TAX13.Term_Category__c='STANDARD_BHVONLY';
            TAX13.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX13.Value_String__c='KWH';
            TAX13.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(TAX13);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT13=new Contract_Term__c();
            BFCT13.Term_Type__c='CNSLT_FEE';
            BFCT13.Term_Category__c='NOTBILLED';
            BFCT13.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT13.Value_String__c= bDescription+','+'KWH';
            BFCT13.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(BFCT13);
        }
         if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT04a=new Contract_Term__c();
            BFCT04a.Term_Type__c='ENERGY';
            BFCT04a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT04a.Contract_Term_Value__c=0;
             BFCT04a.Value_String__c='null';
            BFCT04a.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(BFCT04a);
  
            Contract_Term__c BFCT04b=new Contract_Term__c();
            BFCT04b.Term_Type__c='ONPK_ENERGY';
            BFCT04b.Term_Category__c='NOTBILLED';
            system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string ptt = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptt.startswith('$'))
            ptt = ptt.removeStart('$');
            BFCT04b.Contract_Term_Value__c= decimal.valueof(ptt);
            BFCT04b.Value_String__c='ONPK_KWH';
            BFCT04b.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(BFCT04b);
        
            Contract_Term__c BFCT04c=new Contract_Term__c();
            BFCT04c.Term_Type__c='OFFPK_ENERG';
            BFCT04c.Term_Category__c='NOTBILLED';
            string ptt1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptt1.startswith('$'))
            ptt1 = ptt1.removeStart('$');
            BFCT04c.Contract_Term_Value__c= decimal.valueof(ptt1);
            BFCT04c.Value_String__c='OFFPK_KWH';
            BFCT04c.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(BFCT04c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT04=new Contract_Term__c();
            BFCT04.Term_Type__c='ONPK_ENERGY';
            BFCT04.Term_Category__c='STANDARD_CHARGE';
            BFCT04.Value_String__c='ONPK_KWH';      
            string ptt1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptt1.startswith('$'))
            ptt1 = ptt1.removeStart('$');
             BFCT04.Contract_Term_Value__c= decimal.valueof(ptt1);
            BFCT04.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(BFCT04);
       
            Contract_Term__c BFCT044=new Contract_Term__c();
            BFCT044.Term_Type__c='OFFPK_ENERGY';
            BFCT044.Term_Category__c='STANDARD_CHARGE';
            BFCT044.Value_String__c='OFFPK_KWH';      
            string ptt2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptt2.startswith('$'))
            ptt2 = ptt2.removeStart('$');
            BFCT044.Contract_Term_Value__c= decimal.valueof(ptt2);
            BFCT044.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(BFCT044);
        }

        if(cont.Contract_Municipality_Fee__c!=null&& cont.Contract_Municipality_Fee__c>0){            
            Contract_Term__c MFCT13=new Contract_Term__c();
            MFCT13.Term_Type__c='MUNI_FEE';
            MFCT13.Term_Category__c='STANDARD_BHVONLY';
            MFCT13.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT13.Value_String__c='KWH';
            MFCT13.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_T.add(MFCT13);
        }             
        Contract_Term__c AFCT13= adminfee(cont);
        if(AFCT13.Contract_Term_Value__c!=null && AFCT13.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF_PT_T.add(AFCT13);
        
        insert contracttermsforFP_ONOFF_PT_T;
    }      
    
    public void createcontracttermsforFP_ONOFF_PT_CL(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF_PT_CL=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN14=new Contract_Term__c();
            TXMN14.Term_Type__c='TXMN';
            TXMN14.Term_Category__c='STANDARD_CHARGE';
            TXMN14.Contract_Term_Value__c = cont.ISO_NITS__c != null ? ((cont.ISO_NITS__c)/1000) : 0;
            TXMN14.Value_String__c='KWH';
            TXMN14.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(TXMN14);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX14=new Contract_Term__c();
            TAX14.Term_Type__c='TAX';
            TAX14.Term_Category__c='STANDARD_BHVONLY';
            TAX14.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX14.Value_String__c='KWH';
            TAX14.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(TAX14);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec14=new Contract_Term__c();
            Rec14.Term_Type__c='REC';
            Rec14.Term_Category__c='STANDARD_CHARGE';
            Rec14.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec14.Value_String__c='KWH';
            Rec14.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(Rec14);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT14=new Contract_Term__c();
            BFCT14.Term_Type__c='CNSLT_FEE';
            BFCT14.Term_Category__c='NOTBILLED';
            BFCT14.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT14.Value_String__c= bDescription+','+'KWH';          
            BFCT14.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(BFCT14);
        }
        
       if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT05a=new Contract_Term__c();
            BFCT05a.Term_Type__c='ENERGY';
            BFCT05a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT05a.Contract_Term_Value__c=0;
            BFCT05a.Value_String__c='null';
            BFCT05a.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(BFCT05a);
            
            Contract_Term__c BFCT05b=new Contract_Term__c();
            BFCT05b.Term_Type__c='ONPK_ENERGY';
            BFCT05b.Term_Category__c='NOTBILLED';
            system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string ptcl = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptcl.startswith('$'))
            ptcl = ptcl.removeStart('$');
            BFCT05b.Contract_Term_Value__c= decimal.valueof(ptcl);
            BFCT05b.Value_String__c='ONPK_KWH';
            BFCT05b.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(BFCT05b);
        
            Contract_Term__c BFCT05c=new Contract_Term__c();
            BFCT05c.Term_Type__c='OFFPK_ENERG';
            BFCT05c.Term_Category__c='NOTBILLED';
            string ptcl1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptcl1.startswith('$'))
            ptcl1 = ptcl1.removeStart('$');
            BFCT05c.Contract_Term_Value__c= decimal.valueof(ptcl1);
            BFCT05c.Value_String__c='OFFPK_KWH';
            BFCT05c.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(BFCT05c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT05=new Contract_Term__c();
            BFCT05.Term_Type__c='ONPK_ENERGY';
            BFCT05.Term_Category__c='STANDARD_CHARGE';
            BFCT05.Value_String__c='ONPK_KWH';      
            string ptcl1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptcl1.startswith('$'))
            ptcl1 = ptcl1.removeStart('$');
            BFCT05.Contract_Term_Value__c= decimal.valueof(ptcl1);
            BFCT05.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(BFCT05);
       
            Contract_Term__c BFCT055=new Contract_Term__c();
            BFCT055.Term_Type__c='OFFPK_ENERGY';
            BFCT055.Term_Category__c='STANDARD_CHARGE';
            BFCT055.Value_String__c='OFFPK_KWH';      
            string ptcl2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptcl2.startswith('$'))
            ptcl2 = ptcl2.removeStart('$');
            BFCT055.Contract_Term_Value__c= decimal.valueof(ptcl2);
            BFCT055.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(BFCT055);
        }

        if(cont.Contract_Municipality_Fee__c!=null){            
            Contract_Term__c MFCT14=new Contract_Term__c();
            MFCT14.Term_Type__c='MUNI_FEE';
            MFCT14.Term_Category__c='STANDARD_BHVONLY';
            MFCT14.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT14.Value_String__c='KWH';
            MFCT14.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CL.add(MFCT14);
        }             
        Contract_Term__c AFCT14= adminfee(cont);
        if(AFCT14.Contract_Term_Value__c!=null && AFCT14.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF_PT_CL.add(AFCT14);
        
        insert contracttermsforFP_ONOFF_PT_CL;
    }   
    
    public void createcontracttermsforFP_ONOFF_PT_CLT(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF_PT_CLT=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN15=new Contract_Term__c();
            TXMN15.Term_Type__c='TXMN';
            TXMN15.Term_Category__c='PASSTHRU_TXMN';
            TXMN15.Contract_Term_Value__c = 0;
            TXMN15.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(TXMN15);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX15=new Contract_Term__c();
            TAX15.Term_Type__c='TAX';
            TAX15.Term_Category__c='STANDARD_BHVONLY';
            TAX15.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX15.Value_String__c='KWH';
            TAX15.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(TAX15);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec15=new Contract_Term__c();
            Rec15.Term_Type__c='REC';
            Rec15.Term_Category__c='STANDARD_CHARGE';
            Rec15.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec15.Value_String__c='KWH';
            Rec15.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(Rec15);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT15=new Contract_Term__c();
            BFCT15.Term_Type__c='CNSLT_FEE';
            BFCT15.Term_Category__c='NOTBILLED';
            BFCT15.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT15.Value_String__c= bDescription+','+'KWH';
            BFCT15.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(BFCT15);
        }
        if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT06a=new Contract_Term__c();
            BFCT06a.Term_Type__c='ENERGY';
            BFCT06a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT06a.Contract_Term_Value__c=0;
             BFCT06a.Value_String__c='null';
            BFCT06a.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(BFCT06a);
        
            Contract_Term__c BFCT06b=new Contract_Term__c();
            BFCT06b.Term_Type__c='ONPK_ENERGY';
            BFCT06b.Term_Category__c='NOTBILLED';
             system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string ptclt = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptclt.startswith('$'))
            ptclt = ptclt.removeStart('$');
            BFCT06b.Contract_Term_Value__c= decimal.valueof(ptclt);
            BFCT06b.Value_String__c='ONPK_KWH';
            BFCT06b.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(BFCT06b);
       
            Contract_Term__c BFCT06c=new Contract_Term__c();
            BFCT06c.Term_Type__c='OFFPK_ENERG';
            BFCT06c.Term_Category__c='NOTBILLED';
            string ptclt1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptclt1.startswith('$'))
            ptclt1 = ptclt1.removeStart('$');
            BFCT06c.Contract_Term_Value__c= decimal.valueof(ptclt1);
            BFCT06c.Value_String__c='OFFPK_KWH';
            BFCT06c.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(BFCT06c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT06=new Contract_Term__c();
            BFCT06.Term_Type__c='ONPK_ENERGY';
            BFCT06.Term_Category__c='STANDARD_CHARGE';
            BFCT06.Value_String__c='ONPK_KWH';      
            string ptclt1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptclt1.startswith('$'))
            ptclt1 = ptclt1.removeStart('$');
            BFCT06.Contract_Term_Value__c= decimal.valueof(ptclt1);
            BFCT06.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(BFCT06);
        
            Contract_Term__c BFCT066=new Contract_Term__c();
            BFCT066.Term_Type__c='OFFPK_ENERGY';
            BFCT066.Term_Category__c='STANDARD_CHARGE';
            BFCT066.Value_String__c='OFFPK_KWH';      
            string ptclt2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptclt2.startswith('$'))
            ptclt2 = ptclt2.removeStart('$');
            BFCT066.Contract_Term_Value__c= decimal.valueof(ptclt2);
            BFCT066.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(BFCT066);
        }

        if(cont.Contract_Municipality_Fee__c!=null){            
            Contract_Term__c MFCT15=new Contract_Term__c();
            MFCT15.Term_Type__c='MUNI_FEE';
            MFCT15.Term_Category__c='STANDARD_BHVONLY';
            MFCT15.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT15.Value_String__c='KWH';
            MFCT15.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CLT.add(MFCT15);
        }             
        Contract_Term__c AFCT15= adminfee(cont);
        if(AFCT15.Contract_Term_Value__c!=null && AFCT15.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF_PT_CLT.add(AFCT15);
        
        insert contracttermsforFP_ONOFF_PT_CLT;
    } 
    
    public void createcontracttermsforFP_ONOFF_PT_LT(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF_PT_LT=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN16=new Contract_Term__c();
            TXMN16.Term_Type__c='TXMN';
            TXMN16.Term_Category__c='PASSTHRU_TXMN';
            TXMN16.Contract_Term_Value__c = 0;
            TXMN16.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(TXMN16);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX16=new Contract_Term__c();
            TAX16.Term_Type__c='TAX';
            TAX16.Term_Category__c='STANDARD_BHVONLY';
            TAX16.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX16.Value_String__c='KWH';
            TAX16.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(TAX16);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec16=new Contract_Term__c();
            Rec16.Term_Type__c='REC';
            Rec16.Term_Category__c='STANDARD_CHARGE';
            Rec16.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec16.Value_String__c='KWH';
            Rec16.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(Rec16);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT16=new Contract_Term__c();
            BFCT16.Term_Type__c='CNSLT_FEE';
            BFCT16.Term_Category__c='NOTBILLED';
            BFCT16.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT16.Value_String__c= bDescription+','+'KWH';
            BFCT16.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(BFCT16);
        }
       if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT07a=new Contract_Term__c();
            BFCT07a.Term_Type__c='ENERGY';
            BFCT07a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT07a.Contract_Term_Value__c=0;
             BFCT07a.Value_String__c='null';
            BFCT07a.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(BFCT07a);
       
            Contract_Term__c BFCT07b=new Contract_Term__c();
            BFCT07b.Term_Type__c='ONPK_ENERGY';
            BFCT07b.Term_Category__c='NOTBILLED';
            system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string ptlt = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptlt.startswith('$'))
            ptlt = ptlt.removeStart('$');
            BFCT07b.Contract_Term_Value__c= decimal.valueof(ptlt);
            BFCT07b.Value_String__c='ONPK_KWH';
            BFCT07b.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(BFCT07b);
       
            Contract_Term__c BFCT07c=new Contract_Term__c();
            BFCT07c.Term_Type__c='OFFPK_ENERG';
            BFCT07c.Term_Category__c='NOTBILLED';
            string ptlt1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptlt1.startswith('$'))
            ptlt1 = ptlt1.removeStart('$');
            BFCT07c.Contract_Term_Value__c= decimal.valueof(ptlt1);
            BFCT07c.Value_String__c='OFFPK_KWH';
            BFCT07c.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(BFCT07c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT07=new Contract_Term__c();
            BFCT07.Term_Type__c='ONPK_ENERGY';
            BFCT07.Term_Category__c='STANDARD_CHARGE';
            BFCT07.Value_String__c='ONPK_KWH';      
            string ptlt1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptlt1.startswith('$'))
            ptlt1 = ptlt1.removeStart('$');
            BFCT07.Contract_Term_Value__c= decimal.valueof(ptlt1);
            BFCT07.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(BFCT07);
            
            Contract_Term__c BFCT077=new Contract_Term__c();
            BFCT077.Term_Type__c='OFFPK_ENERGY';
            BFCT077.Term_Category__c='STANDARD_CHARGE';
            BFCT077.Value_String__c='OFFPK_KWH';      
            string ptlt2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptlt2.startswith('$'))
            ptlt2 = ptlt2.removeStart('$');
            BFCT077.Contract_Term_Value__c= decimal.valueof(ptlt2);
            BFCT077.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(BFCT077);
        }

        if(cont.Contract_Municipality_Fee__c!=null){            
            Contract_Term__c MFCT16=new Contract_Term__c();
            MFCT16.Term_Type__c='MUNI_FEE';
            MFCT16.Term_Category__c='STANDARD_BHVONLY';
            MFCT16.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT16.Value_String__c='KWH';
            MFCT16.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_LT.add(MFCT16);
        }             
        Contract_Term__c AFCT16= adminfee(cont);
        if(AFCT16.Contract_Term_Value__c!=null && AFCT16.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF_PT_LT.add(AFCT16);

        insert contracttermsforFP_ONOFF_PT_LT;
    }   
     
    public void createcontracttermsforFP_ONOFF_PT_CT(contract cont){
        
        list<Contract_Term__c > contracttermsforFP_ONOFF_PT_CT=new list<Contract_Term__c >();
        if(cont.Service_Territory__c.contains('-IL')){
            Contract_Term__c TXMN17=new Contract_Term__c();
            TXMN17.Term_Type__c='TXMN';
            TXMN17.Term_Category__c='PASSTHRU_TXMN';
            TXMN17.Contract_Term_Value__c = 0;
            TXMN17.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(TXMN17);
        }
        if((cont.Service_Territory__c.contains('OHIO')) || (cont.Service_Territory__c.contains('DAYTON')) ){
            Contract_Term__c TAX17=new Contract_Term__c();
            TAX17.Term_Type__c='TAX';
            TAX17.Term_Category__c='STANDARD_BHVONLY';
            TAX17.Contract_Term_Value__c = cont.Tax__c!= null ? ((cont.Tax__c)/1000) : 0;
            TAX17.Value_String__c='KWH';
            TAX17.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(TAX17);
        }
        if(cont.Vol_Rec__c>0){
            Contract_Term__c Rec17=new Contract_Term__c();
            Rec17.Term_Type__c='REC';
            Rec17.Term_Category__c='STANDARD_CHARGE';
            Rec17.Contract_Term_Value__c=cont.Vol_Rec__c/1000;
            Rec17.Value_String__c='KWH';
            Rec17.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(Rec17);
        }
        if(cont.Contract_Broker_Fee__c!=null && (Cont.Opportunity__r.Referral_Broker__c!=null || Cont.Referral_Broker__c!=null)){
            Contract_Term__c BFCT17=new Contract_Term__c();
            BFCT17.Term_Type__c='CNSLT_FEE';
            BFCT17.Term_Category__c='NOTBILLED';
            BFCT17.Contract_Term_Value__c=cont.Contract_Broker_Fee__c/1000;
            Contract contract =[select id,Opportunity__r.Referral_Broker__r.description,Referral_Broker__r.description,Referral_Broker__c from contract where id =:cont.id];
            string bDescription = (string.isBlank(contract.Referral_Broker__c)) ? contract.Opportunity__r.Referral_Broker__r.description : contract.Referral_Broker__r.description;
            BFCT17.Value_String__c= bDescription+','+'KWH';
            BFCT17.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(BFCT17);
        }
      if(cont.Contract_Broker_Fee__c!=null ){
            Contract_Term__c BFCT08a=new Contract_Term__c();
            BFCT08a.Term_Type__c='ENERGY';
            BFCT08a.Term_Category__c='ON_OFFPK_ENERGY_CNSLT_FEE';
            BFCT08a.Contract_Term_Value__c=0;
             BFCT08a.Value_String__c='null';
            BFCT08a.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(BFCT08a);
      
            Contract_Term__c BFCT08b=new Contract_Term__c();
            BFCT08b.Term_Type__c='ONPK_ENERGY';
            BFCT08b.Term_Category__c='NOTBILLED';
            system.debug('Test : '+Cont.Retail_Quote__r.Contract_Energy_On_PK__c+' : '+(!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !=''));
            string ptct = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptct.startswith('$'))
            ptct = ptct.removeStart('$');
            BFCT08b.Contract_Term_Value__c= decimal.valueof(ptct);
            BFCT08b.Value_String__c='ONPK_KWH';
            BFCT08b.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(BFCT08b);
       
            Contract_Term__c BFCT08c=new Contract_Term__c();
            BFCT08c.Term_Type__c='OFFPK_ENERG';
            BFCT08c.Term_Category__c='NOTBILLED';
            string ptct1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptct1.startswith('$'))
            ptct1 = ptct1.removeStart('$');
            BFCT08c.Contract_Term_Value__c= decimal.valueof(ptct1);
            BFCT08c.Value_String__c='OFFPK_KWH';
            BFCT08c.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(BFCT08c);
        }
          else if(cont.Contract_Broker_Fee__c==null ){
            Contract_Term__c BFCT08=new Contract_Term__c();
            BFCT08.Term_Type__c='ONPK_ENERGY';
            BFCT08.Term_Category__c='STANDARD_CHARGE';
            BFCT08.Value_String__c='ONPK_KWH';      
            string ptct1 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_On_PK__c) && Cont.Retail_Quote__r.Contract_Energy_On_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_On_PK__c) : '0' ;
            if (ptct1.startswith('$'))
            ptct1 = ptct1.removeStart('$');
            BFCT08.Contract_Term_Value__c= decimal.valueof(ptct1);
            BFCT08.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(BFCT08);
      
            Contract_Term__c BFCT088=new Contract_Term__c();
            BFCT088.Term_Type__c='OFFPK_ENERGY';
            BFCT088.Term_Category__c='STANDARD_CHARGE';
            BFCT088.Value_String__c='OFFPK_KWH';      
            string ptct2 = (!string.isblank(Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) && Cont.Retail_Quote__r.Contract_Energy_Off_PK__c !='') ? (Cont.Retail_Quote__r.Contract_Energy_Off_PK__c) : '0' ;
            if (ptct2.startswith('$'))
            ptct2 = ptct2.removeStart('$');
            BFCT088.Contract_Term_Value__c= decimal.valueof(ptct2);
            BFCT088.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(BFCT088);
        }

        if(cont.Contract_Municipality_Fee__c!=null){            
            Contract_Term__c MFCT17=new Contract_Term__c();
            MFCT17.Term_Type__c='MUNI_FEE';
            MFCT17.Term_Category__c='STANDARD_BHVONLY';
            MFCT17.Contract_Term_Value__c=cont.Contract_Municipality_Fee__c/1000;
            MFCT17.Value_String__c='KWH';
            MFCT17.Contract__c=cont.id;
            contracttermsforFP_ONOFF_PT_CT.add(MFCT17);
        }             
        Contract_Term__c AFCT17= adminfee(cont);
        if(AFCT17.Contract_Term_Value__c!=null && AFCT17.Contract_Term_Value__c > 0)
            contracttermsforFP_ONOFF_PT_CT.add(AFCT17);
        
        insert contracttermsforFP_ONOFF_PT_CT;
    }  
    public Contract_term__c AdminFee(Contract c){
        
        Contract_Term__c ct=new Contract_Term__c();
        if(c.Contract_Marketing_Cost__c !=null)
            ct.Contract_Term_Value__c=c.Contract_Marketing_Cost__c/1000;
        if(c.Default_Risk__c!=null){
            if(ct.Contract_Term_Value__c!=null){
                ct.Contract_Term_Value__c+=c.Default_Risk__c/1000;
            }
            else {
                ct.Contract_Term_Value__c=c.Default_Risk__c/1000;
            }
        }
        if(c.Holding_Cost__c!=null){
            if(ct.Contract_Term_Value__c!=null) {
                ct.Contract_Term_Value__c+=c.Holding_Cost__c/1000;
            }
            else {
                ct.Contract_Term_Value__c=c.Holding_Cost__c/1000;
            }
        }
        ct.Term_Type__c='ADMIN';
        ct.Term_Category__c='STANDARD_BHVONLY';
        ct.Value_String__c='KWH';
        ct.Contract__c=c.id;
        return ct;
    }
                                                                                                                                                            
}