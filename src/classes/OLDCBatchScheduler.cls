global class OLDCBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc)
    {
        OLDCBatch oLDCBatch = new OLDCBatch();
        Database.executeBatch(oLDCBatch, 200);
    }
}