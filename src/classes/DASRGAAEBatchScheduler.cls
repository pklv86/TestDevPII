global class DASRGAAEBatchScheduler implements Schedulable {

    global integer Size;
    global void execute(SchedulableContext sc)
    {
        system.debug('****Label***' + system.label.GaaeBatchSize);
        Size = integer.valueof(system.label.GaaeBatchSize);
        system.debug('****Size***' + Size );
        DASRGAAEBatch dASRGAAEBatch = new DASRGAAEBatch();
        Database.executeBatch(dASRGAAEBatch,Size );
    }
}