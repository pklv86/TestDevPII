global class scheduleBatchEnrollmentProcess implements Schedulable{

  	global void execute(SchedulableContext con){
	
		EnrollmentHandler.ProcessEnrollment();

	}
}