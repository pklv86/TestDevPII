public class AdminRunController 
{
    public AdminRunController(){}
    public void RunEDIOutBoundBatch()
    {
        EDIOutBoundProcesBatch a = new EDIOutBoundProcesBatch();
        Database.executeBatch(a, 10);
    }
}