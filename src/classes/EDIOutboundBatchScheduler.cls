/***************************************************************************
//
// Description    : Scheduler class for EDIOutBoundProcesBatch
//                  To Schedule : Run Daily

//***************************************************************************/
global class EDIOutboundBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) 
    {
        EDIOutBoundProcesBatch oppBatch = new EDIOutBoundProcesBatch();
        database.executebatch(oppBatch,200);
    }
}