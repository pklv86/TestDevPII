public with sharing class BatchUtility {
	public BatchUtility() {
		
	}

	public static void sendAsyncApexJobExceptionEmails(ID jobId){

		try
		{
			AsyncApexJob apexJob = [Select Id,Apexclass.Name, Status, NumberOfErrors, JobItemsProcessed,ExtendedStatus, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:jobId];
			// send email only on error
	        if(apexJob != null && apexJob.NumberOfErrors != null && apexJob.NumberOfErrors > 0)
			{
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String[] toAddresses = new String[] {apexJob.CreatedBy.Email};
				mail.setToAddresses(toAddresses);
				mail.setSubject(apexJob.Apexclass.Name +':'+ apexJob.Status);

				mail.setPlainTextBody('The batch apex job processed' + apexJob.TotalJobItems +
	            ' batches with '+ apexJob.NumberOfErrors + ' failures. Error caused by: '+apexJob.ExtendedStatus);

	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
		}
		catch (Exception e){
			
			System.debug('***** Error in sendAsyncApexJobExceptionEmails:' + e.getMessage());
		}
	}

	public static Boolean IsconcurrentjobsRunning(){

		return [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' )] > 5;
	}
}