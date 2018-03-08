public with sharing class CESOutbound {
	
	public static list<dasr_request__c> dasrlst = new list<dasr_request__c>();
	//public string UName {get; set;}
	//public string UPass {get; set;}
    
    public CESOutbound(){
         
         //UName='dlpuser';
         //UPass='DLP!1test';
         dasrlst = [Select id,name,DASR_Type__c,DASR_Submit_Date__c,ID_18__c,Customer_Id__c,Integration_Status__c,ldc_account__c,Contract__c,
         					Change_Effective_Date__c,Drop_Date__c,Drop_Reason__c,Change_Reason__c,Change_Reason_Value__c,
         					ldc_account__r.account__r.lastname,ldc_account__r.account__r.firstname,ldc_account__r.account__r.PersonHomePhone,
 							ldc_account__r.account__r.PersonEmail,ldc_account__r.account__r.Aggregator_Code__c,ldc_account__r.account__c,
 							ldc_account__r.LDC_Account_Number__c,ldc_account__r.ESP_Account_Number__c,ldc_account__r.Service_Street_1__c,
 							ldc_account__r.Service_City__c,ldc_account__r.Service_State__c,ldc_account__r.Service_Postal_Code__c,
 							ldc_account__r.ldc_vendor__r.Utility_Code__c,ldc_account__r.Bill_Method__c,ldc_account__r.Rate_Code__c,
 							ldc_account__r.ldc_type__c,ldc_account__r.Interval_Usage__c,contract__r.StartDate,contract__r.End_Date__c,
 							contract__r.Contract_Counter_Signed_Date__c,contract__r.ContractTerm,contract__r.ContractNumber
 							 from dasr_request__c where ldc_account__r.Opt_out__c = false and Billing_Entity__c = 'CES'];
                                             
        if(!dasrlst.isempty()) BuildAttachment(dasrlst);
        
    }
        
    //@future(callout = true)
    public static void BuildAttachment(list<dasr_request__c> dasrsend){
    	    
        string Enrollheader = 'Utility,Customer Name,Utility Account Number,ESP Account Number,Service Address1,Service Address City, Service Address State Code,Service Addrress zip,'+
                        'Contract Effective Date, Bill Type, LDC Rate Code, State Sales Exempt,Account Type,Historical Usage Type,Submit Record,Date To Submit, '+
                        'Contact Phone,Contact Email,Contact Person,Company,Contact Address 1,Contact Address City,Contact Address State Code,Contact Address Zip,'+
                        'Contract Product,Contract Status,Sales Agent,Contract Channel,How Did You Hear From US,Commission,Commission Addl,ESP Bill Rate,Tax Rate, '+
                        'Customer Charge,Aggregator,Customer Name Key,CES Unique ID,Verification ID,Contract End Date,Custom Field 1,Custom Field 2,Custom Field 3,'+
                        'Custom Field 4,Custom Field 5,Custom Field 6,Custom Field 7,Custom Field 8,Custom Field 9, Custom Field 10,Net Meter,Organization,Subsidiary,'+
                        'Tax Exemption Effective Date,Mailing Address1,Mailing Address2,Mailing City,Mailing State,Mailing Zip,Contract Number,Contract Start Date,'+
                        'Contract Signed Date,Terms and Conditions,Contract Term,Evergreen Clause,Evergreen Duration,Broker Name,Service Address 2,'+
                        'Rate Code Pricing Option,Auto Bill Pay Indicator \r\n';
                        
        string Changeheader = 'Utility,Utility Account Number,Submit Record,Date To Submit,Change Effective Date,Change Type,Change Value,Change Value 2,Change Value 3 \r\n';
        string Dropheader = 'Utility,Utility Account Number,Date To Submit,Submit Record,Off Cycle Date,Drop Reason \r\n';
                        
        string Enrollfilecontent='';// = header;
        string Changefilecontent='';
        string Dropfilecontent='';
        string Enrollfilebody = '';
        string Changefilebody = '';
        string Dropfilebody = '';
        
        for(Dasr_request__c dasr : dasrsend){
        	
        	String submitdate = dasr.DASR_Submit_Date__c.month()+'/'+dasr.DASR_Submit_Date__c.day()+'/'+dasr.DASR_Submit_Date__c.year();
        	system.debug('submitdate : '+submitdate);
        	if(dasr.dasr_type__c == 'GAAE'){
        		string Enrollrecord = '';
            	Enrollrecord = '"'+dasr.ldc_account__r.ldc_vendor__r.Utility_Code__c+'","'+dasr.ldc_account__r.account__r.firstname+' '+dasr.ldc_account__r.account__r.lastname+
                            '","'+dasr.ldc_account__r.LDC_Account_Number__c+'","'+dasr.ldc_account__r.ESP_Account_Number__c+'","'+dasr.ldc_account__r.Service_Street_1__c+
                            '","'+dasr.ldc_account__r.Service_City__c+'","'+dasr.ldc_account__r.Service_State__c+'","'+dasr.ldc_account__r.Service_Postal_Code__c+
                            '","'+dasr.Change_Effective_Date__c+'","'+dasr.ldc_account__r.Bill_Method__c+'","'+dasr.ldc_account__r.Rate_Code__c+'","'+
                            '","'+dasr.ldc_account__r.ldc_type__c+'","'+dasr.ldc_account__r.Interval_Usage__c+'","1","'+submitdate+
                            '","'+dasr.ldc_account__r.account__r.PersonHomePhone+'","'+dasr.ldc_account__r.account__r.PersonEmail+'","","","","","","","","","","","","","'+
                            '","","","","'+dasr.ldc_account__r.account__r.Aggregator_Code__c+'","'+dasr.ldc_account__r.account__r.lastname.substring(0,4)+
                            '"," ","","'+dasr.contract__r.End_Date__c+'","","","","","","","","","","","","","","","","","","","","'+dasr.contract__r.ContractNumber+
                            '","'+dasr.contract__r.StartDate+'","'+dasr.contract__r.Contract_Counter_Signed_Date__c+'","","'+dasr.contract__r.ContractTerm+'","","","","","'+
                            '",""\r\n';
                            
            	Enrollfilecontent+= Enrollrecord.replaceAll('null','');
        	}
        	else if(dasr.dasr_type__c == 'GAAC'){
        		string Changerecord = '';
        		Changerecord = '"'+dasr.ldc_account__r.ldc_vendor__r.Utility_Code__c+'","'+dasr.ldc_account__r.LDC_Account_Number__c+'","1","'+submitdate+
        					   '","'+dasr.Change_Effective_Date__c+'","'+dasr.Change_Reason__c+'","'+dasr.Change_Reason_Value__c+'","",""\r\n';
        		
        		Changefilecontent+= Changerecord.replaceAll('null','');
        	}
        	else if(dasr.dasr_type__c == 'GAAD'){
        		string Droprecord = '';
        		Droprecord = '"'+dasr.ldc_account__r.ldc_vendor__r.Utility_Code__c+'","'+dasr.ldc_account__r.LDC_Account_Number__c+'","'+submitdate+
    						'","1","'+dasr.Drop_Date__c+'","'+dasr.Drop_Reason__c+'"\r\n';
        		
        		Dropfilecontent+= Droprecord.replaceAll('null','');
        	}
        }
        
        blob EnrollcsvBlob;
        blob ChangecsvBlob;
        blob DropcsvBlob;
        string Enrollcsvname = '';
        string Changecsvname = '';
        string Dropcsvname = '';
        list<Messaging.EmailFileAttachment> Attlst = new list<Messaging.EmailFileAttachment>();
        
        if(!string.isempty(Enrollfilecontent)){
        	Enrollfilebody = Enrollheader + Enrollfilecontent;
        	EnrollcsvBlob = Blob.valueOf(Enrollfilebody);
        	Enrollcsvname= string.valueof(system.now())+'-Enroll--CES.csv';
        	try{
	        	uploadFile(Enrollcsvname,EnrollcsvBlob);
	        }
	        catch(Exception e){
	        	system.debug('Exception is : '+e);
	        }
	        Messaging.EmailFileAttachment EnrollcsvAtt = new Messaging.EmailFileAttachment();
	        EnrollcsvAtt.setFileName(Enrollcsvname);
	        EnrollcsvAtt.setBody(EnrollcsvBlob);
	        Attlst.add(EnrollcsvAtt);
        }
        
        if(!string.isempty(Changefilecontent)){
        	Changefilebody = Changeheader + Changefilecontent;
        	ChangecsvBlob = Blob.valueOf(Changefilebody);
        	Changecsvname= string.valueof(system.now())+'-Change--CES.csv';
        	try{
	        	uploadFile(Changecsvname,ChangecsvBlob);
	        }
	        catch(Exception e){
	        	system.debug('Exception is : '+e);
	        }
	        Messaging.EmailFileAttachment ChangecsvAtt = new Messaging.EmailFileAttachment();
	        ChangecsvAtt.setFileName(Changecsvname);
	        ChangecsvAtt.setBody(ChangecsvBlob);
	        Attlst.add(ChangecsvAtt);
        }
        
        if(!string.isempty(Dropfilecontent)){
        	Dropfilebody = Dropheader + Dropfilecontent;
        	DropcsvBlob = Blob.valueOf(Dropfilebody);
        	Dropcsvname= string.valueof(system.now())+'-Drop--CES.csv';
        	try{
	        	uploadFile(Dropcsvname,DropcsvBlob);
	        }
	        catch(Exception e){
	        	system.debug('Exception is : '+e);
	        }
	        Messaging.EmailFileAttachment DropcsvAtt = new Messaging.EmailFileAttachment();
	        DropcsvAtt.setFileName(Dropcsvname);
	        DropcsvAtt.setBody(DropcsvBlob);
	        Attlst.add(DropcsvAtt);
        }
        
        
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'prasad.paladugu@dynegy.com'};//,'Phung.Nguyen@dynegy.com','Bao.Crabtree@dynegy.com'
        String subject ='CES Enrollment CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Enrollment CES CSV ');
        //for(Integer i=0 ; i< Attlst.size();i++){
        	email.setFileAttachments(attlst);
        //}
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
    }
    
    public static HTTPResponse uploadFile(string fileName, Blob fileContent){
    	system.debug('File Info : '+fileName);
    	
    	String boundary = '----'+String.valueOf(DateTime.now().getTime());
    	
    	/*String header = '--'+boundary + '\r\nContent-Disposition: form-data; name="ftpHost" \r\n\r\n';
    	
        header+='ftp://ftp.dlptest.com\r\n';
        header+= '--' + boundary;
		system.debug('Host : '+header);
        header+='\r\nContent-Disposition: form-data; name="UserName" \r\n\r\n';
        header+='dlpuser\r\n';
        header+= '--' + boundary;
		system.debug('UserName : '+header);
        header+='\nContent-Disposition: form-data; name="Password" \r\n\r\n';
        header+='DLP!1test\r\n';
        header+= '--' + boundary;
		system.debug('Password : '+header);
        header+='\nContent-Disposition: form-data; name="ftpDirectory" \r\n\r\n';
        header+='/24_Hour\r\n';   
		system.debug('Directory : '+header);
        header+= '--'+boundary+'\r\nContent-Disposition: form-data; name="file"; filename="'+fileName+'";\r\nContent-Type: application/octet-stream';
		system.debug('Header : '+header);
        String footer = '--'+boundary+'--';*/ 
        
        String header = '';
		header += '--'+boundary+'\r\n';
		header += 'Content-Disposition: form-data; name="Host"\r\n\r\nftp.dlptest.com\r\n';
		header += '--'+boundary+'\r\n';
		header += 'Content-Disposition: form-data; name="UserName"\r\n\r\ndlpuser\r\n';
		header += '--'+boundary+'\r\n';
		header += 'Content-Disposition: form-data; name="Password"\r\n\r\nDLP!1test\r\n';
		header += '--'+boundary+'\r\n';
		header += 'Content-Disposition: form-data; name="Directory"\r\n\r\n24_Hour\r\n';
		header += '--'+boundary+'\r\n';
		header += 'Content-Disposition: form-data; name="file"; filename="'+fileName+'";\r\nContent-Type: application/octet-stream';
		system.debug('Header : '+header);
        String footer = '--'+boundary+'--';
                   
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
		system.debug('headerEncoded : '+headerEncoded);
        while(headerEncoded.endsWith('='))
        {
          header+=' ';
          headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
          system.debug('headerEncoded : '+headerEncoded);
        }
        String bodyEncoded = EncodingUtil.base64Encode(fileContent);

        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());

         if(last4Bytes.endsWith('==')) {           
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;

            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
         } else if(last4Bytes.endsWith('=')) {           
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;

            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
		system.debug('setHeader --> multipart/form-data; boundary='+boundary);
        HttpRequest req = new HttpRequest();
        system.debug('endpoint : '+req.getEndpoint());
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setMethod('POST');
        req.setEndpoint('http://posttestserver.com/post.php?dir=watchdox');//http://posttestserver.com/post.php?dir=watchdox
        
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(60000);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug('====' + res.getBody());
        
        return res;
    	
    }
    
    public Pagereference Redirect(){
    	pagereference pg = new pagereference('ftp://ftp.dlptest.com');
        pg.setRedirect(true);
        return pg;

    }
}