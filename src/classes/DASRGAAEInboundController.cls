public class DASRGAAEInboundController {
    
    public DASR_Request__c dasrRequest;
    public void procDASR() 
    {   
        EDIDataResetBatch batch = new EDIDataResetBatch();
        Database.executeBatch(batch, 1);
    }
    public DASRGAAEInboundController(ApexPages.StandardController stdController) 
    {
        this.dasrRequest = [select Id from DASR_Request__c where Id = :stdController.getId()];
    }
    
}