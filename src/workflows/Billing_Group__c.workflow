<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Stop_Date</fullName>
        <field>Stop_Date__c</field>
        <formula>contract__r.End_Date__c</formula>
        <name>Populate Stop Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Group</fullName>
        <field>Synchronized__c</field>
        <literalValue>0</literalValue>
        <name>Update Billing Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Billing Group Stop Date</fullName>
        <actions>
            <name>Populate_Stop_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK( Stop_Date__c ) || ISNULL( Stop_Date__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
