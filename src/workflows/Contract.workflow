<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contract_Status_Update</fullName>
        <description>Change the status to expired when the contract end date is passed</description>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>Contract Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Contract Status Update</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contract.End_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the Contract end date is passed the status is changed to expired</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_Status_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
