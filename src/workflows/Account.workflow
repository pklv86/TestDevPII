<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Short_Code</fullName>
        <field>Short_Code__c</field>
        <formula>MID(Id, 3, 15)</formula>
        <name>Populate Short Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAccountLSIntegrationStatus</fullName>
        <description>This Step will update the LodeStar Integration Status on the Account Record</description>
        <field>LodeStar_Integration_Status__c</field>
        <literalValue>Not Synchronized</literalValue>
        <name>UpdateAccountLSIntegrationStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account_LodeStarIntegration</fullName>
        <actions>
            <name>UpdateAccountLSIntegrationStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This Workflow rule is designed to set LodeStar Integration Status on the Account</description>
        <formula>(ISCHANGED( Name ) || ISCHANGED( Short_Code__c ) || ISCHANGED( BillingAddress ) || ISCHANGED( Business_Account__c)) &amp;&amp; RecordType.DeveloperName != &apos;ABC&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
