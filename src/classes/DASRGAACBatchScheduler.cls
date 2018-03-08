global class DASRGAACBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc)
    {
        DASRGAACBatch dASRGAACBatch = new DASRGAACBatch();
        Database.executeBatch(dASRGAACBatch, 20);
    }
}