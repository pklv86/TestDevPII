global class schedulableDASRInsertGAAD implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        insertDASRRequestGAAD b = new insertDASRRequestGAAD(); 
        database.executebatch(b);
    }
}