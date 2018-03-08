<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Duplicate_Check</fullName>
        <field>Unique_Utility_Name_LDC_Number__c</field>
        <formula>LDC_Account_Number__c  &amp;  LDC_Vendor__c</formula>
        <name>Duplicate Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAccount</fullName>
        <field>LodeStar_Integration_Status__c</field>
        <literalValue>Not Synchronized</literalValue>
        <name>UpdateAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateLDCAccountStatusFinal</fullName>
        <description>This field update will change the LDC Account Status to FINAL</description>
        <field>LDC_Account_Status__c</field>
        <literalValue>FINAL</literalValue>
        <name>UpdateLDCAccountStatusFinal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateParentAccount</fullName>
        <description>Update the Parent Account of an LDC_Account__c record and set the LodeStar_Integration_Status__c to &apos;Not Synchronized&apos;</description>
        <field>LodeStar_Integration_Status__c</field>
        <literalValue>Not Synchronized</literalValue>
        <name>UpdateParentAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Check Duplicate Value</fullName>
        <actions>
            <name>Duplicate_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LDC_Account__c.Unique_Utility_Name_LDC_Number__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <description>LDC Number and Utility Name must be unique</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LDC_LodeStarIntegration</fullName>
        <actions>
            <name>UpdateAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>update Account of an LDC so that synchronization will be triggered</description>
        <formula>( ISCHANGED(Bill_Cycle__c) || ISCHANGED(Service_Street_1__c) || ISCHANGED(LDC_Account_Number__c) || ISCHANGED(Utility_Rate_Class__c) || ISCHANGED(LDC_Account_Status__c) || ISCHANGED(Bill_Method__c) || ISCHANGED(Interval_Usage__c) || ISCHANGED(LDC_End_Date__c) || ISCHANGED(LDC_Vendor__c) ||  ISCHANGED( Billing_Group__c ) ) &amp;&amp; Enrolled__c = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
