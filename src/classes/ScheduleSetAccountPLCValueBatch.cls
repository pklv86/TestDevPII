global class ScheduleSetAccountPLCValueBatch implements schedulable{
	global void execute(SchedulableContext sc){
        SetAccountPLCValueBatch b = new SetAccountPLCValueBatch();
        database.executebatch(b);
    }
}