global class DASRGAADBatchScheduler implements Schedulable {


    global integer Size;
    global void execute(SchedulableContext sc)
        {
            system.debug('****Label***' + system.label.GaadBatchSize);
            Size = integer.valueof(system.label.GaadBatchSize);
            system.debug('****Size***' + Size );
            DASRGAADBatch dASRGAADBatch = new DASRGAADBatch();
            Database.executeBatch(dASRGAADBatch,size);
        }
}