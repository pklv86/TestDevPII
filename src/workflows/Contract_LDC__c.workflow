<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateLDCStatus</fullName>
        <field>IsSynchronized__c</field>
        <literalValue>0</literalValue>
        <name>UpdateLDCStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ContractLDCIntegration</fullName>
        <actions>
            <name>UpdateLDCStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISCHANGED(IsSynchronized__c )  = false &amp;&amp;  Active__c = true) || (ISCHANGED(IsSynchronized__c )  = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
