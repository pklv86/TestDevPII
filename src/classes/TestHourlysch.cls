global class TestHourlysch implements schedulable,database.stateful{
	
	global string carrystr;
    global Integer carrynum;
    global final datetime cdate;
	
	public TestHourlysch(){
		
	}
	
	public TestHourlysch(String str, Integer num,Datetime lastrun){
    	string JobName = 'Hourly Job test';
    	list<CronTrigger> ct = [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger WHERE CronJobDetail.Name =: JobName order by createddate desc limit 1];
    	string Jobid = (ct.size() > 0 && !ct.isempty())? ct[0].id : null;
    	
    	//list<string> strlst = new list<string>{str,string.valueof(num),string.valueof(lastrun)};   
    	Testhourlysch ts = new testhourlysch();
    	carrystr = str;
    	carrynum = num;
    	
    	Datetime dt =lastrun;
    	system.debug('Datetime'+dt+' : '+dt.minute()+' : '+dt.hour());
    	if(jobid != null && jobid != ''){
    		system.abortjob(Jobid);
    		dt =lastrun.addminutes(15);
    	//}
        String sch = ''+dt.second()+' '+dt.minute()+' '+dt.hour()+' '+dt.day()+' '+dt.month()+' ?';
        system.debug('Datetime'+dt+' : '+dt.minute()+' : '+dt.hour()+' SCH : '+sch);
        string newjobid = system.schedule(JobName,sch,ts);
    	}
    }
    
	global void execute(schedulableContext sc){
    
        string str;
        Integer num;
        system.debug('Start Variables : '+carrystr+' : '+carrynum);
        TestHourly th = new Testhourly(carrystr,carrynum);
        Database.executeBatch(th,10);
    }
	    
}