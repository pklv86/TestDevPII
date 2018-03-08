global class EDIInboundWebService 
{
    
    Static String RESP_QUALIFIER ='2';
    Static String REQ_QUALIFIER ='1';
    webservice static EDIInboundResponse processRequest(EDIInboundRequest CTG_Document) {
        EDIInboundResponse res = new EDIInboundResponse();  
        if(CTG_Document == null || CTG_Document.CTG_Transaction == null || CTG_Document.CTG_Transaction.isEmpty()){
            res.status=ConstantUtility.STATUS_SUCCESS;
            res.MessageDesc = 'No request Found'; 
            return res;  
        }
        String origDuns;
        String origDunName;
        String recDuns;
        String recDunName;
        if(CTG_Document != null && CTG_Document.Document_Info != null &&  CTG_Document.Document_Info.Document_ID !=null )
        {
            origDuns = CTG_Document.Document_Info.Originator_DUNS;
            origDunName = CTG_Document.Document_Info.Originator_Name;
            recDuns = CTG_Document.Document_Info.Recipient_DUNS;
            recDunName = CTG_Document.Document_Info.Recipient_Name;
        }
        Set<String> sLDCNumber = new Set<String>();
        TransactionInfo vTranInfo = null;
        
        List<CTGTransactionInfo> lEnrollInbndReq = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lChangeInbndReq = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lDropInbndReq = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lGAAHInbndReq = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lGAARInbndReq = new List<CTGTransactionInfo>();
        
        List<CTGTransactionInfo> lEnrollInbndRespSuc = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lChangeInbndResSuc = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lDropInbndRespSuc = new List<CTGTransactionInfo>();        
        List<CTGTransactionInfo> lReinstatInbndRespSuc = new List<CTGTransactionInfo>();
        
        List<CTGTransactionInfo> lEnrollInbndRespFail = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lChangeInbndResFail = new List<CTGTransactionInfo>();
        List<CTGTransactionInfo> lDropInbndRespFail = new List<CTGTransactionInfo>(); 
        List<CTGTransactionInfo> lReinstatInbndRespFail = new List<CTGTransactionInfo>();
        
        Map<String, String> mapDasrReqIdSendTransId = new Map<String, String>();
        
        //Bindu: included to store Dasrs not found in Salesforce to send response back
        Map<String, String> OrgTransIdNotFound = new Map<String, String>();

        Set<String> sDASRReqId = new Set<String>();
        
        boolean vResp;
        boolean vReq;
        AccountInfo tAcInfo;
        String tranType;
        String inOutBound;
        String sucFailBound;
        Map<String,LDC_Account__c> mapLDCAcctsToUpdate = new Map<String, LDC_Account__c>();
        if(CTG_Document != null && CTG_Document.CTG_Transaction != null && !CTG_Document.CTG_Transaction.isEmpty())
        {
            for(CTGTransactionInfo tempTran: CTG_Document.CTG_Transaction)
            {
                vTranInfo = tempTran.Transaction_Info;
                if(vTranInfo != null)
                {
                    sDASRReqId.add(vTranInfo.Originating_Transaction_ID);
                    if(vTranInfo != null && vTranInfo.Originating_Transaction_ID != null)
                    {
                        mapDasrReqIdSendTransId.put(vTranInfo.Originating_Transaction_ID.toUpperCase(), vTranInfo.Sender_Transaction_ID );
                    
                    }
                    tranType = vTranInfo.Action_ID != null ? vTranInfo.Action_ID : null;
                    inOutBound = vTranInfo.Transaction_Qualifier != null ? vTranInfo.Transaction_Qualifier : null;
                    sucFailBound = vTranInfo.Response_Qualifier != null ? vTranInfo.Response_Qualifier : null;
                    //Response to requests initiated from SFDC
                    if(tranType != null && tranType == EDIConstantUtil.DASR_TYPE_ENROL && inOutBound != null && inOutBound == RESP_QUALIFIER)
                    {
                        if(sucFailBound != null && sucFailBound == '1')
                        {
                            lEnrollInbndRespSuc.add(tempTran);   
                        }
                        else if(sucFailBound != null && sucFailBound == '2')
                        {
                            lEnrollInbndRespFail.add(tempTran);                            
                        }
                        
                    }
                    else if(tranType != null && tranType ==EDIConstantUtil.DASR_TYPE_CHANGE && inOutBound != null && inOutBound == RESP_QUALIFIER)
                    {
                        if(sucFailBound != null && sucFailBound == '1')
                        {
                            lChangeInbndResSuc.add(tempTran);   
                        }
                        else if(sucFailBound != null && sucFailBound == '2')
                        {
                            lChangeInbndResFail.add(tempTran);                            
                        }
                    }
                    else if(tranType != null && tranType == EDIConstantUtil.DASR_TYPE_DROP && inOutBound != null && inOutBound == RESP_QUALIFIER)
                    {
                        if(sucFailBound != null && sucFailBound == '1')
                        {
                            lDropInbndRespSuc.add(tempTran);   
                        }
                        else if(sucFailBound != null && sucFailBound == '2')
                        {
                            lDropInbndRespFail.add(tempTran);                            
                        }
                    }
                    //Added for Dynegy Initiated GAAR
                    else if(tranType != null && tranType == EDIConstantUtil.DASR_TYPE_REINSTAT && inOutBound != null && inOutBound == RESP_QUALIFIER)
                    {
                        if(sucFailBound != null && sucFailBound == '1')
                        {
                            lReinstatInbndRespSuc.add(tempTran);   
                        }
                        else if(sucFailBound != null && sucFailBound == '2')
                        {
                            lReinstatInbndRespFail.add(tempTran);                            
                        }
                    }
                    
                    //Brand new inbound requests to SFDC
                    if(tranType != null && tranType == EDIConstantUtil.DASR_TYPE_ENROL && inOutBound != null && inOutBound == REQ_QUALIFIER)
                    {
                        lEnrollInbndReq.add(tempTran);
                    }
                    else if(tranType != null && tranType ==EDIConstantUtil.DASR_TYPE_CHANGE && inOutBound != null && inOutBound == REQ_QUALIFIER)
                    {
                        lChangeInbndReq.add(tempTran);
                    }
                    else if(tranType != null && tranType ==EDIConstantUtil.DASR_TYPE_REINSTAT && inOutBound != null && inOutBound == REQ_QUALIFIER)
                    {
                        lGAARInbndReq.add(tempTran);
                    }
                    else if(tranType != null && tranType == EDIConstantUtil.DASR_TYPE_DROP && inOutBound != null && inOutBound == REQ_QUALIFIER)
                    {
                        lDropInbndReq.add(tempTran);
                        system.debug('loop');
                    }
                    else if(tranType != null && tranType == EDIConstantUtil.DASR_TYPE_HISTORY)
                    {
                        lGAAHInbndReq.add(tempTran);
                    }                    
                }    
                else
                {
                    //Ignore transaction info
                    continue;
                }
                //One CTG_Transaction message will have one account
                tAcInfo = tempTran.Account;
                if(tAcInfo != null)
                {
                    System.debug('\n tAcInfo.LDC_Account_Number='+tAcInfo.LDC_Account_Number);

                    sLDCNumber.add(tAcInfo.LDC_Account_Number);
                    sLDCNumber.add(tAcInfo.SDP_Number);
                    
                }
            }
        }
        
        string ldcQuery=ConstantUtility.getObjectFieldsQuery('LDC_Account__c') +' From LDC_Account__c where LDC_Account_Number__c=:sLDCNumber AND LDC_Account_Number__c != null ' ;
        Set<Id> sLDCIds = new Set<Id>();
        Map<Id,LDC_Account__c> ldcAccntMap = new Map<Id,LDC_Account__c>((List<LDC_Account__c>)Database.Query(ldcQuery));
        System.debug('\n ldcAccntMap='+ldcAccntMap);
        Map<String,LDC_Account__c> ldcNumAccntMap = new Map<String,LDC_Account__c>();
        if(ldcAccntMap != null && ldcAccntMap.size() > 0)
        {
            for(LDC_Account__c tLDC : ldcAccntMap.values())
            {
                ldcNumAccntMap.put(tLDC.LDC_Account_Number__c, tLDC);
                sLDCIds.add(tLDC.Id);
            }   
        }
        system.debug('****LDCID******'+sLDCIds);
        //Included For updating the LDC vendor mainly for AMeren Rate ZOnes I,II,and III
        string ldcvendorquery = ConstantUtility.getObjectFieldsQuery('LDC_Vendor__c') +' From LDC_Vendor__c ';
        Map<Id,LDC_Vendor__c> ldcvenmap = new map<Id,LDC_Vendor__c>((List<LDC_Vendor__c>)Database.Query(ldcvendorquery));
        system.debug('\n ldcvenmap='+ldcvenmap);
        Map<String,Id> LDCVendorMap = new Map<String,Id>();
            for (LDC_Vendor__c tven : ldcvenmap.values())
            {
                if(tven.name.length()>7){
                LDCVendorMap.put(tven.name.substring(7).toUpperCase(),tven.Id);}
            }
        system.debug('\n LDCVendorMap='+LDCVendorMap);
        //Completed
        
        string contractLDCQuery=ConstantUtility.getObjectFieldsQuery('Contract_LDC__c') +' From Contract_LDC__c where LDC_Account__c  =:sLDCIds' ;
        
        Map<Id,Contract_LDC__c> contractLDCMap = new Map<Id,Contract_LDC__c>((List<Contract_LDC__c>)Database.Query(contractLDCQuery));
        Map<Id, List<Contract_LDC__c>> mapLDCIdContId = new Map<Id, List<Contract_LDC__c>>();
        
        List<Contract_LDC__c> lLDContractLDC;
        Set<Id> sContIds = new Set<Id>();
        if(contractLDCMap != null && !contractLDCMap.isEmpty())
        {  
            for(Contract_LDC__c tCL : contractLDCMap.values())
            {
                sContIds.add(tCL.Contract__c);
                lLDContractLDC = mapLDCIdContId.get(tCL.LDC_Account__c);
                if(lLDContractLDC == null)
                {
                    lLDContractLDC = new List<Contract_LDC__c>();
                }
                lLDContractLDC.add(tCL);
                mapLDCIdContId.put(tCL.LDC_Account__c, lLDContractLDC);
            }
        }
        
        System.debug('\n sLDCIds='+sLDCIds);
        system.debug('dasr ID set : '+sDASRReqId);
        string dasrReQuery=ConstantUtility.getObjectFieldsQuery('DASR_Request__c') +' From DASR_Request__c where LDC_Account__c  =:sLDCIds and (Id=:sDASRReqId OR ID_18__c = :sDASRReqId)' ;
        system.debug('Formed DASR query : '+dasrRequery);
        Map<Id,DASR_Request__c> dasrReqMap = new Map<Id,DASR_Request__c>((List<DASR_Request__c>)Database.Query(dasrReQuery));
        System.debug('\n dasrReqMap='+dasrReqMap);
        
        Map<String,DASR_Request__c> dasr18IDReqMap = new Map<String,DASR_Request__c>();
        Map<String,DASR_Request__c> dasrIDReqMap = new Map<String,DASR_Request__c>();
        String id15;
        if(dasrReqMap != null && !dasrReqMap.isEmpty())
        {
            for(DASR_Request__c tDR : dasrReqMap.values())
            {
                dasr18IDReqMap.put(tDR.ID_18__c.toUpperCase(), tDR);
                id15 =tDR.Id;
                dasrIDReqMap.put(id15.substring(0,15), tDR);
            }
        } 
        System.debug('\n dasr18IDReqMap='+dasr18IDReqMap);
            
        string servPntQuery=ConstantUtility.getObjectFieldsQuery('Service_Point__c') +'  From Service_Point__c where LDC_Account_Number__c = :sLDCIds' ;
        List<Service_Point__c> servPntList = ((List<Service_Point__c>)Database.Query(servPntQuery));
        
        Map<Id, Service_Point__c> mapLDCServPoint = new Map<Id, Service_Point__c>();
        if(servPntList != null && !servPntList.isEmpty())
        {  
            for(Service_Point__c tServPoint : servPntList)
            {
                mapLDCServPoint.put(tServPoint.LDC_Account_Number__c, tServPoint);
            }
        }
        System.debug('\n retrive service point ='+mapLDCServPoint);
        string meterQuery=ConstantUtility.getObjectFieldsQuery('Meter__c') +' ,Service_Point__r.LDC_Account_Number__c From Meter__c where Service_Point__r.LDC_Account_Number__c = :sLDCIds' ;
        List<Meter__c> meterList = ((List<Meter__c>)Database.Query(meterQuery));
        Map<Id, List<Meter__c>> meterMap = new Map<Id,List<Meter__c>>();
        
        if(meterList != null && !meterList.isEmpty())
        {   
            List<Meter__c> myMeter;
            for(Meter__c tMeter : meterList)
            {
                myMeter = meterMap.get(tMeter.Service_Point__r.LDC_Account_Number__c);
                if(myMeter == null)
                {
                    myMeter = new List<Meter__c>();
                }
                myMeter.add(tMeter);
                
                meterMap.put(tMeter.Service_Point__r.LDC_Account_Number__c, myMeter);
            }
        }
        System.debug('\n retrive meter ='+meterMap);
        
        String nDasrReqId;
        String nLDCAcctNum;
        DASR_Request__c tDASRReq;
        LDC_Account__c tLDCAcct;
        LDC_Account__c tLDCAcctById;
        
        //List of dasr request to upsert
        List<DASR_Request__c> lDASRToUpsert = new List<DASR_Request__c>();

        //List of vendor meter to upsert
        List<Vendor_Meter__c> lVendMeterToUpsert = new List<Vendor_Meter__c >();

        //List of vendor meter exception to upsert
        List<Vendor_Meter_Exception__c> lVendMeterExctToUpsert = new List<Vendor_Meter_Exception__c>();
        
        //List of Account Exception to upsert
        List<Account_Exception__c> lAccExcpToUpsert = new List<Account_Exception__c>(); 
        
        Map<Id, List<Vendor_Meter__c >> mapIdListVendMet = new Map<Id, List<Vendor_Meter__c >>();
        Map<Id, List<Vendor_Meter_Exception__c >> mapIdListVendMetExct = new Map<Id, List<Vendor_Meter_Exception__c >>();
        Map<Id, List<Account_Exception__c>> mapIdListAccExcp = new Map<Id, List<Account_Exception__c>>();
        
        List<Contract_LDC__c> lContLDCToUpsert = new List<Contract_LDC__c>(); 
        //List of ldc account to update
        List<LDC_Account__c> lLDCAcctsToUp = new List<LDC_Account__c>();
        
        //List of service point to insert
        List<Service_Point__c> lServPointToInsert = new List<Service_Point__c>();
 
        //List of Meter to update
        List<Meter__c> lMetersToUp = new List<Meter__c>();
        List<Meter__c> lMeterToUpsert = new List<Meter__c>();
        
        List<Meter__c> lMetersToSend;
        Map<String, Meter__c> mapMetrNumMeter = new Map<String, Meter__c>();
        Map<String, List<Meter__c>> mapLDCListMeter = new Map<String, List<Meter__c>>();
        Map<String, List<Meter__c>> mapLDCListMeterUp = new Map<String, List<Meter__c>>();
        List<Contract_LDC__c> lContLDCs;
        
        Service_Point__c myServPoint;
        String esbTransId;
        
        //Process all enrollment success response
        if(lEnrollInbndRespSuc != null && !lEnrollInbndRespSuc.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lEnrollInbndRespSuc)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                
                System.debug('\n tAcInfo='+tAcInfo);
                
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n nDasrReqId='+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n aa dasrIDReqMap='+dasrIDReqMap);
                System.debug('\n aa tDASRReq='+tDASRReq);
                
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n 11 tDASRReq='+tDASRReq);
                //Bindu:To store not processed Transaction info 
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //Bindu: SCR 1104:included if loop to avoid nullpointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c  = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    
                    System.debug('\n 22 tDASRReq='+tDASRReq);
                    
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;

                    System.debug('\n tLDCAcctById='+tLDCAcctById);
                    myServPoint = mapLDCServPoint != null && mapLDCServPoint.containsKey(tLDCAcctById.Id) ? mapLDCServPoint.get(tLDCAcctById.Id) : new Service_Point__c();
                    lMetersToSend = meterMap != null ? meterMap.get(tLDCAcctById.Id) : null;
                    System.debug('\n lMetersToSend='+lMetersToSend);
                    
                    mapMetrNumMeter = lMetersToSend != null ? EDIInboundHelper.mapMeterByMtrNum(lMetersToSend) : new Map<String, Meter__c>();
                    System.debug('\n mapMetrNumMeter='+mapMetrNumMeter);
                    lContLDCs = mapLDCIdContId != null ? mapLDCIdContId.get(tLDCAcctById.Id) : new List<Contract_LDC__c>();
                    System.debug('\n before is condition='+lContLDCs);
                }
                if(tDASRReq != null && tLDCAcctById != null)
                {   
                    EDIInboundHelper.processInboundEnrollSuccess(tempTran, tDASRReq, tLDCAcctById,mapMetrNumMeter, myServPoint, lContLDCs, LDCVendorMap);
                    lDASRToUpsert.add(tDASRReq);
                    System.debug('\n returned tLDCAcctById='+tLDCAcctById);
                    lLDCAcctsToUp.add(tLDCAcctById);
                    System.debug('\n myServPoint='+myServPoint);
                    if(lContLDCs != null && lContLDCs.size() > 0)
                    {
                        lContLDCToUpsert.addAll(lContLDCs);
                    }
                    
                    if(myServPoint != null && myServPoint.id == null)
                    {
                        lServPointToInsert.add(myServPoint);
                        mapLDCListMeter.put(tLDCAcctById.Id, mapMetrNumMeter.values());
                    }else
                    {
                        mapLDCListMeterUp.put(tLDCAcctById.Id, mapMetrNumMeter.values());            
                    }
                }
            }
        }
        
        //Process all enrollment failure response
        if(lEnrollInbndRespFail != null && !lEnrollInbndRespFail.isEmpty())
        {
            
            for(CTGTransactionInfo tempTran: lEnrollInbndRespFail)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n nDasrReqId='+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n aa dasrIDReqMap='+dasrIDReqMap);
                System.debug('\n aa tDASRReq='+tDASRReq);
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n 11 tDASRReq='+tDASRReq);
                //Bindu:To store not processed Transaction info 
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //Bindu: SCR 1104:included if loop to avoid nullpointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    
                    System.debug('\n 22 tDASRReq='+tDASRReq);
                    
                    
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;
                    System.debug('\n 44 tDASRReq='+tDASRReq);
                    System.debug('\n 55 tLDCAcctById='+tLDCAcctById);
                }
                if(tDASRReq != null && tLDCAcctById != null)
                {
                    System.debug('\n xxx processInboundEnrollFail');
                    EDIInboundHelper.processInboundEnrollFail(tempTran, tDASRReq, tLDCAcctById);
                    lDASRToUpsert.add(tDASRReq);
                    lLDCAcctsToUp.add(tLDCAcctById);
                }
            }
        }
        
        //Process all Reinstate success response
        if(lReinstatInbndRespSuc != null && !lReinstatInbndRespSuc.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lReinstatInbndRespSuc)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                System.debug('\n======== tAcInfo========'+tAcInfo);
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n======== nDasrReqId========'+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n======== aa dasrIDReqMap========'+dasrIDReqMap);
                System.debug('\n======== aa tDASRReq========='+tDASRReq);
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n======== 11 tDASRReq========='+tDASRReq);
                //To store not processed Transaction info
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //loop to avoid null pointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    System.debug('\n======= 22 tDASRReq======'+tDASRReq);
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n======= 33 nLDCAcctNum======='+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;
                }
                if(tDASRReq != null && tLDCAcctById != null)
                {
                    EDIInboundHelper.processInboundReinstateSuccess(tempTran, tDASRReq, tLDCAcctById);
                    lDASRToUpsert.add(tDASRReq);
                 // lLDCAcctsToUp.add(tLDCAcctById);
                }
            }
        }
        
        //Process all Reinstate Fail response
        if(lReinstatInbndRespFail != null && !lReinstatInbndRespFail.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lReinstatInbndRespFail)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                System.debug('\n======== tAcInfo========'+tAcInfo);
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n======== nDasrReqId========'+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n======== aa dasrIDReqMap========'+dasrIDReqMap);
                System.debug('\n======== aa tDASRReq========'+tDASRReq);
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n======== 11 tDASRReq========'+tDASRReq);
                //To store not processed Transaction info
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //loop to avoid null pointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    System.debug('\n========= 22 tDASRReq========'+tDASRReq);
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n========= 33 nLDCAcctNum========'+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;
                }
                if(tDASRReq != null && tLDCAcctById != null)
                {
                    EDIInboundHelper.processInboundReinstateFail(tempTran, tDASRReq, tLDCAcctById);
                    lDASRToUpsert.add(tDASRReq);
                 // lLDCAcctsToUp.add(tLDCAcctById);
                }
            }
        }
        
        //Process all change success response
        if(lChangeInbndResSuc != null && !lChangeInbndResSuc.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lChangeInbndResSuc)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                
                System.debug('\n tAcInfo='+tAcInfo);
                
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n nDasrReqId='+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n aa dasrIDReqMap='+dasrIDReqMap);
                System.debug('\n aa tDASRReq='+tDASRReq);
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n 11 tDASRReq='+tDASRReq);
                //Bindu:To store not processed Transaction info 
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //Bindu: SCR 1104:included if loop to avoid nullpointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    
                    System.debug('\n 22 tDASRReq='+tDASRReq);
                    
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;

                    System.debug('\n tLDCAcctById='+tLDCAcctById);
                    myServPoint = mapLDCServPoint != null && mapLDCServPoint.containsKey(tLDCAcctById.Id) ? mapLDCServPoint.get(tLDCAcctById.Id) : new Service_Point__c();
                    lMetersToSend = meterMap != null ? meterMap.get(tLDCAcctById.Id) : null;
                    System.debug('\n lMetersToSend='+lMetersToSend);
                    
                    mapMetrNumMeter = lMetersToSend != null ? EDIInboundHelper.mapMeterByMtrNum(lMetersToSend) : new Map<String, Meter__c>();
                    System.debug('\n mapMetrNumMeter='+mapMetrNumMeter);
                    lContLDCs = mapLDCIdContId != null ? mapLDCIdContId.get(tLDCAcctById.Id) : new List<Contract_LDC__c>();
                    System.debug('\n before is condition='+lContLDCs);
                }
                if(tDASRReq != null && tLDCAcctById != null)
                {
                    EDIInboundHelper.processInboundChngSuccess(tempTran, tDASRReq, tLDCAcctById,mapMetrNumMeter, myServPoint);
                    lDASRToUpsert.add(tDASRReq);
                    if(tDASRReq.Change_Effective_Date__c == null || tDASRReq.Change_Effective_Date__c <= System.today())
                    {
                        //TEMP-Donot update ldc account
                        //lLDCAcctsToUp.add(tLDCAcctById);
                    }
                }
            }
        }
        
        //Process all change failure response
        if(lChangeInbndResFail != null && !lChangeInbndResFail.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lChangeInbndResFail)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                
                System.debug('\n tAcInfo='+tAcInfo);
                
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n nDasrReqId='+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n aa dasrIDReqMap='+dasrIDReqMap);
                System.debug('\n aa tDASRReq='+tDASRReq);
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n 11 tDASRReq='+tDASRReq);
                //Bindu:To store not processed Transaction info 
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //Bindu: SCR 1104:included if loop to avoid nullpointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    
                    System.debug('\n 22 tDASRReq='+tDASRReq);
                    
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;

                    System.debug('\n tLDCAcctById='+tLDCAcctById);
                    myServPoint = mapLDCServPoint != null && mapLDCServPoint.containsKey(tLDCAcctById.Id) ? mapLDCServPoint.get(tLDCAcctById.Id) : new Service_Point__c();
                    lMetersToSend = meterMap != null ? meterMap.get(tLDCAcctById.Id) : null;
                    System.debug('\n lMetersToSend='+lMetersToSend);
                    
                    mapMetrNumMeter = lMetersToSend != null ? EDIInboundHelper.mapMeterByMtrNum(lMetersToSend) : new Map<String, Meter__c>();
                    System.debug('\n mapMetrNumMeter='+mapMetrNumMeter);
                    lContLDCs = mapLDCIdContId != null ? mapLDCIdContId.get(tLDCAcctById.Id) : new List<Contract_LDC__c>();
                    System.debug('\n before is condition='+lContLDCs);
                }
                if(tDASRReq != null && tLDCAcctById != null)
                {
                    EDIInboundHelper.processInboundChngFail(tempTran, tDASRReq, tLDCAcctById);
                    lDASRToUpsert.add(tDASRReq);
                    //lLDCAcctsToUp.add(tLDCAcctById);
                }
            }
        }
        
        //Process all drop success response
        if(lDropInbndRespSuc != null && !lDropInbndRespSuc.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lDropInbndRespSuc)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                
                System.debug('\n tAcInfo='+tAcInfo);
                
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n nDasrReqId='+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n aa dasrIDReqMap='+dasrIDReqMap);
                System.debug('\n aa tDASRReq='+tDASRReq);
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n 11 tDASRReq='+tDASRReq);
                //Bindu:To store not processed Transaction info 
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //Bindu: SCR 1104:included if loop to avoid nullpointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    
                    System.debug('\n 22 tDASRReq='+tDASRReq);
                    
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;
                }
                
                if(tDASRReq != null && tLDCAcctById != null)
                {
                    EDIInboundHelper.processInboundDropSuccess(tempTran, tDASRReq, tLDCAcctById);
                    lDASRToUpsert.add(tDASRReq);
                    //lLDCAcctsToUp.add(tLDCAcctById);
                }
            }
        }
        
        //Process all drop failure response
        if(lDropInbndRespFail != null && !lDropInbndRespFail.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lDropInbndRespFail)
            {
                vTranInfo = tempTran.Transaction_Info;
                tAcInfo = tempTran.Account;
                
                System.debug('\n tAcInfo='+tAcInfo);
                
                nDasrReqId = vTranInfo != null && vTranInfo.Originating_Transaction_ID != null ? vTranInfo.Originating_Transaction_ID : null;
                System.debug('\n nDasrReqId='+nDasrReqId);
                tDASRReq = dasr18IDReqMap != null && nDasrReqId != null ? dasr18IDReqMap.get(nDasrReqId.toUpperCase()) : null;
                System.debug('\n aa dasrIDReqMap='+dasrIDReqMap);
                System.debug('\n aa tDASRReq='+tDASRReq);
                tDASRReq = tDASRReq == null && dasrIDReqMap != null ? dasrIDReqMap.get(nDasrReqId) : tDASRReq;
                System.debug('\n 11 tDASRReq='+tDASRReq);
                //Bindu:To store not processed Transaction info 
                if(tDASRReq == null )
                {
                    OrgTransIdNotFound.put(nDasrReqId,tAcInfo != null ? tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim():tAcInfo.SDP_Number.trim(): null);
                }
                //Bindu: SCR 1104:included if loop to avoid nullpointer exception if record not found
                if(tDASRReq != null)
                {
                    tDASRReq.Sender_Transaction_Id__c = tDASRReq != null && mapDasrReqIdSendTransId != null && mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) != null ? mapDasrReqIdSendTransId.get(tDASRReq.Id_18__c.toUpperCase()) : null;
                    
                    System.debug('\n 22 tDASRReq='+tDASRReq);
                    
                    nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                    System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                    tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                    tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(tDASRReq.LDC_Account__c) : null;
                }
                
                if(tDASRReq != null && tLDCAcctById != null)
                {
                    EDIInboundHelper.processInboundDropFail(tempTran, tDASRReq, tLDCAcctById);
                    lDASRToUpsert.add(tDASRReq);
                    //lLDCAcctsToUp.add(tLDCAcctById);
                }
            }
        }
        
        String sendTransId;
        List<Meter__c> tMeterList;
        Service_Point__c tServPoint;
        
        //Process all incoming change requests
        if(lChangeInbndReq != null && !lChangeInbndReq.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lChangeInbndReq)
            {
                vTranInfo = tempTran.Transaction_Info;
                
                sendTransId = vTranInfo != null && vTranInfo.Sender_Transaction_ID != null ? vTranInfo.Sender_Transaction_ID : null;
                
                tAcInfo = tempTran.Account;
                nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null &&  !string.isBlank(tAcInfo.LDC_Account_Number) ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;

                tDASRReq = new DASR_Request__c();
                tDASRReq.Sender_Transaction_Id__c = sendTransId;
                
                if(tLDCAcct != null)
                {
                    lVendMeterToUpsert = new List<Vendor_Meter__c>();
                    lVendMeterExctToUpsert = new List<Vendor_Meter_Exception__c >();
                    lAccExcpToUpsert = new List<Account_Exception__c>(); 
                    
                    tMeterList = new List<Meter__c>();
                    tServPoint = new Service_Point__c();
                    tDASRReq.LDC_Account__c = tLDCAcct.Id;
                    //EDIInboundHelper.processInboundChangeReq1(tempTran, tDASRReq, tLDCAcct,tMeterList,null);
                    EDIInboundHelper.processInboundChangeReq(tempTran, tDASRReq, tLDCAcct,tMeterList,tServPoint, lVendMeterToUpsert,lVendMeterExctToUpsert,lAccExcpToUpsert);
                    mapIdListVendMet.put(tLDCAcct.Id,lVendMeterToUpsert);
                    mapIdListVendMetExct.put(tLDCAcct.Id,lVendMeterExctToUpsert);
                    mapIdListAccExcp.put(tLDCAcct.Id,lAccExcpToUpsert);
                    lDASRToUpsert.add(tDASRReq);

                }
            }
        }
        
        //Process all incoming reinstatement requests
        if(lGAARInbndReq != null && !lGAARInbndReq.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lGAARInbndReq)
            {
                vTranInfo = tempTran.Transaction_Info;
                
                sendTransId = vTranInfo != null && vTranInfo.Sender_Transaction_ID != null ? vTranInfo.Sender_Transaction_ID : null;
                
                tAcInfo = tempTran.Account;
                nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null && !string.isBlank(tAcInfo.LDC_Account_Number)? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;

                tDASRReq = new DASR_Request__c();
                tDASRReq.Sender_Transaction_Id__c = sendTransId;
                
                if(tLDCAcct != null)
                {
                    lVendMeterToUpsert = new List<Vendor_Meter__c>();
                    lVendMeterExctToUpsert = new List<Vendor_Meter_Exception__c >();
                    tMeterList = new List<Meter__c>();
                    tServPoint = new Service_Point__c();
                    tDASRReq.LDC_Account__c = tLDCAcct.Id;
                    EDIInboundHelper.processInboundReinstateReq(tempTran, tDASRReq, tLDCAcct,tMeterList,tServPoint, lVendMeterToUpsert,lVendMeterExctToUpsert);

                    lDASRToUpsert.add(tDASRReq);

                }
            }
        }
        //Process all incoming drop requests
        if(lDropInbndReq != null && !lDropInbndReq.isEmpty())
        {
            for(CTGTransactionInfo tempTran: lDropInbndReq)
            {
                vTranInfo = tempTran.Transaction_Info;
                
                sendTransId = vTranInfo != null && vTranInfo.Sender_Transaction_ID != null ? vTranInfo.Sender_Transaction_ID : null;
                
                tAcInfo = tempTran.Account;
                //System.debug('\n 33 tAcInfo  ='+tAcInfo.LDC_Account_Number.length()+string.isBlank(tAcInfo.LDC_Account_Number));
                
          nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null &&  !string.isBlank(tAcInfo.LDC_Account_Number)  ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
           
                    System.debug('\n 33 nLDCAcctNum='+nLDCAcctNum);
                tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                //tLDCAcctById = tDASRReq != null && tDASRReq.LDC_Account__c != null ? ldcAccntMap.get(nDasrReqId) : null;
                tDASRReq = new DASR_Request__c();
                tDASRReq.Sender_Transaction_Id__c = sendTransId;
                
                
                if(tLDCAcct != null)
                {
                    tMeterList = new List<Meter__c>();
                    tServPoint = new Service_Point__c();
                    tDASRReq.LDC_Account__c = tLDCAcct.Id;
                    //EDIInboundHelper.processInboundChangeReq1(tempTran, tDASRReq, tLDCAcct,tMeterList,null);
                    EDIInboundHelper.processInboundDropReq(tempTran, tDASRReq, tLDCAcct,tMeterList,tServPoint, new List<Vendor_Meter__c>());
                    lDASRToUpsert.add(tDASRReq);

                }
            }
        }
        
        //Process all incoming history requests
        if(lGAAHInbndReq != null && !lGAAHInbndReq.isEmpty())
        {
            
            for(CTGTransactionInfo tempTran: lGAAHInbndReq)
            {
                vTranInfo = tempTran.Transaction_Info;
                
                sendTransId = vTranInfo != null && vTranInfo.Sender_Transaction_ID != null ? vTranInfo.Sender_Transaction_ID : null;
                
                tAcInfo = tempTran.Account;
                nLDCAcctNum = tAcInfo != null && tAcInfo.LDC_Account_Number != null &&  !string.isBlank(tAcInfo.LDC_Account_Number)  ? tAcInfo.LDC_Account_Number.trim() : tAcInfo.SDP_Number.trim(); 
                tLDCAcct = ldcNumAccntMap != null && nLDCAcctNum != null && ldcNumAccntMap.containsKey(nLDCAcctNum) ? ldcNumAccntMap.get(nLDCAcctNum) : null;
                tDASRReq = new DASR_Request__c();
                tDASRReq.Sender_Transaction_Id__c = sendTransId;
                
                if(tLDCAcct != null)
                {
                    tMeterList = new List<Meter__c>();
                    tServPoint = new Service_Point__c();
                    tDASRReq.LDC_Account__c = tLDCAcct.Id;
                    EDIInboundHelper.processInboundHistoryReq(tempTran, tDASRReq, tLDCAcct,tMeterList,tServPoint, new List<Vendor_Meter__c>());
                    lDASRToUpsert.add(tDASRReq);
                }
            }
        }
        System.debug('\n lServPointToInsert='+lServPointToInsert);
        System.debug('\n lLDCAcctsToUp='+lLDCAcctsToUp);
        
        try{
            List<String> errList = new List<String>();
            
            System.debug('\n lServPointToInsert='+lServPointToInsert);
            
            if(lServPointToInsert != null && lServPointToInsert.size() > 0)
            {
                System.debug('\n lServPointToInsert.size()='+lServPointToInsert.size());
                //insert lServPointToInsert;
                 System.debug('\n before insert lServPointToInsert='+lServPointToInsert);
                //Insert service point
                Database.SaveResult[] srServPntList = database.insert(lServPointToInsert, false);
                errList.addAll(IntegrationUtil.collectErrors(srServPntList));
            }
            
            List<Meter__c> lTempMeter;
            List<Meter__c> lstMetUp;
            System.debug('\n 22 lServPointToInsert='+lServPointToInsert);
            //Process all meters that need to be upserted
            if(lServPointToInsert != null && lServPointToInsert.size() > 0)
            {
                for(Service_Point__c tSP : lServPointToInsert)
                {
                    lTempMeter = mapLDCListMeter != null ? mapLDCListMeter.get(tSP.LDC_Account_Number__c) : null;
                    if(lTempMeter != null && lTempMeter.size() > 0)
                    {
                        for(Meter__c tMet : lTempMeter)
                        {
                            tMet.Service_Point__c  = tSP.Id; 
                            lMeterToUpsert.add(tMet);
                        }
                    }
                    lstMetUp = mapLDCListMeterUp != null ? mapLDCListMeterUp.get(tSP.LDC_Account_Number__c) : new List<Meter__c>();
                    
                }
            }
            System.debug('\n mapLDCListMeterUp='+mapLDCListMeterUp);
            List<List<Meter__c>> llMeter = mapLDCListMeterUp != null ? mapLDCListMeterUp.values() : new List<List<Meter__c>>();
            for(List<Meter__c> x: llMeter)
            {
                lMeterToUpsert.addAll(x);
            }
            System.debug('\n lMeterToUpsert='+lMeterToUpsert);
            
            upsert lMeterToUpsert;
            //Database.UpsertResult[] srMeterList = database.upsert(lMeterToUpsert, false);
            //errList.addAll(IntegrationUtil.collectUpsertErrors(srMeterList));
            TriggerHandler.EDIUpdate=false;
           
            System.debug('\n lContLDCToUpsert='+lContLDCToUpsert);
            Database.SaveResult[] srContLDCList = database.update(lContLDCToUpsert, false);
            errList.addAll(IntegrationUtil.collectErrors(srContLDCList));
            
            System.debug('\n lLDCAcctsToUp='+lLDCAcctsToUp);
            Database.SaveResult[] srList = database.update(lLDCAcctsToUp, false);
            errList.addAll(IntegrationUtil.collectErrors(srList));
            
            System.debug('\n lDASRToUpsert='+lDASRToUpsert);
            Database.UpsertResult[] srUpList = database.upsert(lDASRToUpsert, false);
            errList.addAll(IntegrationUtil.collectUpsertErrors(srUpList));
            
            List<Vendor_Meter__c> lVendMetInsert = EdiInboundHelper.assignDASRRequest(mapIdListVendMet,lDASRToUpsert);
            List<Vendor_Meter_Exception__c> lVendMetExctInsert = EdiInboundHelper.assignMetExctDASRRequest(mapIdListVendMetExct,lDASRToUpsert);
            List<Account_Exception__c> lAccExcpInsert = EdiInboundHelper.assignAccExcpDASRREquest(mapIdListAccExcp,lDASRToUpsert);
            
            Database.SaveResult[] srVendMetList = database.insert(lVendMetInsert, false);
            errList.addAll(IntegrationUtil.collectErrors(srVendMetList));

            Database.SaveResult[] srVendMetExctList = database.insert(lVendMetExctInsert, false);
            errList.addAll(IntegrationUtil.collectErrors(srVendMetExctList));
            
            Database.SaveResult[] srAccExcpList = database.insert(lAccExcpInsert, false);
            errlist.addAll(IntegrationUtil.collectErrors(srAccExcpList));
            
            res.status= errList != null && !errList.isEmpty() ? ConstantUtility.STATUS_Failure : ConstantUtility.STATUS_SUCCESS;
            res.MessageDesc = errList != null && !errList.isEmpty() ? 'Response Failed:' : 'Response Processed Successfully:'; 
            res.MessageDesc += errList;
            //Bindu:SCR 1104 append not processed transactions to msg       
            if(OrgTransIdNotFound != null && OrgTransIdNotFound.size() > 0)     
            {                       
                res.MessageDesc += '\n List of Originating_Transaction_IDs not found in SF'+ OrgTransIdNotFound;        
            }
            res.TechnicalDesc = !errList.isEmpty() ? errList: null;
        }
        catch(Exception e){
            res.status=ConstantUtility.STATUS_Failure;
            res.MessageDesc = 'Exception'+e.getMessage(); 
        }
        
        return res; 
        
    }
    
    
    global class EDIInboundRequest{
        Webservice DocumentInfo Document_Info {get; set;}
        Webservice List<CTGTransactionInfo> CTG_Transaction {get; set;}
        Webservice TrailerInfo Trailer {get; set;}
        
    }
    
    global class CTGTransactionInfo{
        Webservice TransactionInfo Transaction_Info {get; set;}
        Webservice List<OrganizationInfo> Organization {get; set;}
        Webservice List<CustomerInfo> Customer {get; set;}
        Webservice AccountInfo Account {get; set;}
        Webservice List<AccountExceptionInfo> Account_Exception_Info {get; set;}
        Webservice List<MeterInfo> Meter {get; set;}
        Webservice List<MeterExceptionInfo> Meter_Exception_Info {get; set;}
        
    }
    global class DocumentInfo{
        
        Webservice String Document_ID;
        webservice String Document_Date;
        Webservice String Document_Time ;
        Webservice String Originator_DUNS ;
        Webservice String Originator_Name ;
        Webservice String Recipient_DUNS ;
        Webservice String Recipient_Name ;
        Webservice String Version_Number ;
    }
    global class TransactionInfo{
        
        Webservice String Sender_Transaction_ID;
        webservice String Transaction_Date;
        Webservice String Transaction_Time ;
        Webservice String Sender_DUNS ;
        Webservice String Sender_Name ;
        Webservice String Receiver_DUNS ;
        Webservice String Receiver_Name ;
        Webservice String Originating_Transaction_ID ;
        Webservice String Line_Transaction_ID ;
        //Changes for IL 
        Webservice String Transaction_Type_Code ;
        //Changes for IL
        Webservice String Action_ID ;
        Webservice String Commodity ;
        Webservice String Transaction_Qualifier ;
        Webservice String Response_Qualifier ;
    }
    global class OrganizationInfo{
        
        Webservice String Sender_Transaction_ID;
        webservice String Organization_Identifier_Code;
        Webservice String Organization_DUNS ;
        Webservice String Organization_Name ;
        
    }
    
    global class CustomerInfo{
        
        Webservice String Sender_Transaction_ID;
        webservice String Name_Qualifier;
        Webservice String Customer_Name ;
        Webservice String Contact_Function_Qualifier;
        Webservice String Customer_Contact_Name;
        Webservice String Address_Line_1 ;
        // Newly added SCR 1289
        Webservice String Address_Line_2 ;
        Webservice String Phone_Number ;
        //Newly added fields SCR 1289  
        Webservice String City_Name ;
        Webservice String State_Province_Code ;
        Webservice String Postal_Code_Zip ;
        Webservice String Country_Code ;
        
    }
    
    global class AccountInfo
    {
        
        Webservice String Sender_Transaction_ID;
        webservice String ESP_Account_Number;
        webservice String LDC_Account_Number;
        webservice String OLD_LDC_Account_Number;
        webservice String Drop_Reason_Code;
        //NEw
        webservice String Drop_Reason_Description;
        webservice String Service_End_Date;
        //End new
        //Added for SCR 1304 and IL Changes
        Webservice string Special_Meter_Configuration ;  
        Webservice string Current_Budget_Billing_Status ;
        Webservice string Supply_Group ;
        Webservice string Interval_Level_Indicator;
        Webservice string Service_Relationship ;
        Webservice string Payment_Arrangement_Code ;
        Webservice string Eligible_Switch_Date ;
        Webservice string CP_Node ;
        Webservice string Standard_Point_Location_Code ;
        Webservice string Drop_Type_Code;
        Webservice String Number_Of_Months_Requested ;
        Webservice string POR_Group ;
        Webservice string Secondary_Service_Historical_Usage_Request_Code ;
        Webservice string Secondary_Service_Offcycle_Enrollment_Request_Code ;
        Webservice string Special_Meter_Read_Date ;
        //Added for SCR 1304 and IL Changes
        
        webservice String Secondary_Service_Summary_Interval_Request_Code;
        Webservice Decimal Budget_Amount ;
        Webservice Decimal Capacity_Obligation_Quantity ;
        Webservice String Contract_Effective_Date ;
        Webservice String Contract_Effective_Time ;
        Webservice String Service_Start_Date ;
        Webservice String Change_Effective_Date ;
        Webservice String Change_Effective_Time ;
        Webservice String Contract_Effective_Time_Zone ;
        webservice String LDC_Bill_Cycle;
        webservice String SDP_Number;
        webservice String LDC_Budget_Billing_Status;
        //Webservice Integer Capacity_Obligation_Quantity ;
        Webservice Decimal Transmission_Obligation_Quantity ;
        Webservice Decimal Number_Of_Months_Calculated_Usage_Quantity ;
        Webservice Decimal Peak_Demand_Usage_Quantity;
        Webservice Decimal Total_KWH_Quantity ;
        Webservice String Aggregator ;
        Webservice String Bill_Presenter ;
        Webservice String Bill_Calculator ;
        Webservice String XML_File_Name ;
        
    }
    
    global class AccountExceptionInfo{
        
        Webservice String Sender_Transaction_ID;
        webservice String Reason_Code;
        Webservice String Reason_Description ;
        Webservice String Exception_Type_Code ;
        
    }
    global class MeterInfo{
        
        Webservice String Sender_Transaction_ID;
        webservice String Meter_Number;
        webservice String Old_Meter_Number;
        webservice String Load_Profile_Description;
        webservice String LDC_Rate_Class;
        webservice String LDC_Rate_Subclass;
        webservice String LDC_Meter_Cycle;
        webservice String Meter_Type_Code;
        webservice Decimal Meter_Multiplier_Quantity;
        webservice String Number_Of_Dials_Quantity;
        webservice String Time_Of_Use_Metering;
        Webservice String ESP_Rate_Code ;
        Webservice String Meter_Maintenance_Code ;
        //Added for SCR 1304 and IL changes
        Webservice String Meter_Service_Voltage ;
        Webservice Decimal Distribution_Loss_Factor ;
        Webservice string SDP_Number;
        Webservice String Type_Of_Service_Indicator ;
        Webservice String Advanced_Metering_Indicator ;
        Webservice String Delivery_Voltage ;
        Webservice String Supply_Voltage ;
        Webservice String LDC_Rate_Class_Description ;
        Webservice String Meter_Role ;
        Webservice string Measurement_Reference_Code ;
        //Added for SCR 1304 and IL Changes
    }
    global class MeterExceptionInfo{
        
        Webservice String Sender_Transaction_ID;
        webservice String Reason_Code;
        Webservice String Exception_Level ;
        Webservice String Exception_Type_Code ;
        Webservice String Meter_Number ;
        Webservice String Exception_Key ;
        Webservice String Meter_Exc_Sequence ;
        Webservice String Reason_Description ;
    }
    
    global class TrailerInfo{
        Webservice String Document_ID;
        webservice Integer Records_Generated;
        Webservice Integer Transaction_Count ;
    }
    global class EDIInboundResponse {
        
        webservice String Status;
        webservice string MessageDesc;
        webservice List<string> TechnicalDesc;
        
    }       
}