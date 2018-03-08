trigger sendPostApprovalMail on Opportunity (after update) {

    if(TriggerHandler.firstRun) {
    	system.debug('Opp : '+trigger.new+':'+trigger.old);
        List<opportunity>OppList= [select id, owner.email, DOA_Approver__r.email, DOA_Approver__c, name, (select id, name, Notional_Value__c, opportunity__r.name from Dynagy_Quotes__r where Notional_Value__c > = 10000000) from opportunity where id in : trigger.new and DOA_Approved__c =: true];
        OrgWideEmailAddress[] owr = [select id from OrgWideEmailAddress where Address = 'retailintgservices@dynegy.com'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ; 
        List<DOA_Approval_Mail__c> mailAPP = DOA_Approval_Mail__c.getall().values();  
        List<string>appMailId = new List<string>();
        for(DOA_Approval_Mail__c doa: mailAPP){
            appMailId.add(doa.Doa_Email__c);
            appMailId.add(doa.Doa_Email2__c);
            appMailId.add(doa.Doa_Email3__c);
            appMailId.add(doa.Doa_Email4__c);
            appMailId.add(doa.Doa_Email5__c);
            appMailId.add(doa.Doa_Email6__c);
        }
        List<string> whomadd = new List<string>();
        for(Opportunity opp: OppList){
            system.debug('=============Trigger.newMap.get(opp.Id).DOA_Approval_Required__c=========='+Trigger.newMap.get(opp.Id).DOA_Approved__c );
            system.debug('=============Trigger.oldMap.get(opp.Id).DOA_Approval_Required__c=========='+Trigger.oldMap.get(opp.Id).DOA_Approved__c );
            if(Trigger.newMap.get(opp.Id).DOA_Approved__c == true && Trigger.oldMap.get(opp.Id).DOA_Approved__c == false){
                mail = new Messaging.SingleEmailMessage() ; 
                whomadd.add(opp.owner.email);
                if(opp.DOA_Approver__c != null){
                    whomadd.add(opp.DOA_Approver__r.email);
                    if(opp.DOA_Approver__r.email=='robert.c.flexon@dynegy.com'){
                        whomadd.addAll(appMailId);
                    }   
                }
                mail.setSubject('DOA Approved for Opportunity');
                String body = '<html dir=\'ltr\'>';
                body += 'DOA approval has been acquired for the Opportunity:';
                body += opp.name;
                body += '<br/><br/>Below is the list of approved Quotes related to the Opportunity';
                body += '<head><style type=\'text/css\'>P {margin-top:0;margin-bottom:0;}</style><style type=\'text/css\'>BODY {scrollbar-base-color:undefined;scrollbar-highlight-color:undefined;scrollbar-darkshadow-color:undefined;scrollbar-track-color:undefined;scrollbar-arrow-color:undefined}</style></head>';
                body += '<body style=\'background-color:undefined\' fpstyle=\'1\' ocsi=\'1\'><table border=\'1\' cellspacing=\'0\' cellpadding=\'0\' width=\'400\' height=\'350\'>';
                body += '<tbody><tr valign=\'top\'><th style=\'vertical-align:middle; height:50; text-align:left; background-color:grey\'>Action</th>';
                body += '<th style=\'vertical-align:middle; height:50; text-align:left; background-color:grey\'>RetailQuote</th>';
                body += '<th style=\'vertical-align:middle; height:50; text-align:left; background-color:grey\'>Notional Value</th>';
                body += '<th style=\'vertical-align:middle; height:50; text-align:left; background-color:grey\'>Approver Email</th></tr>';
                for(Retail_Quote__c ret: opp.Dynagy_Quotes__r){
                    system.debug('=============whomadd============'+whomadd);
                    body += '<tr valign=\'top\'><td style=\'color:#000000; font-size:10pt; background-color:#FFFFFF; font-family:arial\'> <a href="https://dynegy.my.salesforce.com/';
                    body += ret.id;
                    body += '">View</a></td><td style=\'color:#000000; font-size:10pt; background-color:#FFFFFF; font-family:arial\'>';
                    body += ret.name;
                    body += '</td></td><td style=\'color:#000000; font-size:10pt; background-color:#FFFFFF; font-family:arial; class:num\'>';
                    body += ret.Notional_Value__c;
                    body += '</td><td style=\'color:#000000; font-size:10pt; background-color:#FFFFFF; font-family:arial\'>';
                    body += opp.DOA_Approver__r.email;
                    body += '</td>';
                }
                body += '</tbody></table><br><br></body></html>';
             // mail.setSenderDisplayName('Retail Services');
                mail.setToAddresses(whomadd) ;
                if(owr.size()>0){ mail.setOrgWideEmailAddressid(owr.get(0).Id);}
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                TriggerHandler.firstRun = false;
            }
        }
        if(mails.size()>0){ 
        }
       // TriggerHandler.firstRun = false;
    }
}