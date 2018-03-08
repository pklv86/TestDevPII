<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Billing Group Sync</fullName>
        <active>false</active>
        <formula>ISCHANGED( Billing_Start_Date__c )  ||  ISCHANGED(Billing_Stop_Date__c ) ||  
ISCHANGED( Name )  || 
ISCHANGED( Pseudo_Contract__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
