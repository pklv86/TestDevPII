<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Move_To_DASR_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>DASR_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Move To DASR Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Utility Initiated Request Complete</fullName>
        <actions>
            <name>Move_To_DASR_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>DASR_Request__c.Integration_Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>DASR_Request__c.Dynegy_Initiated__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This Workflow will execute whenever a Utility initiated DASR Request comes back as completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
