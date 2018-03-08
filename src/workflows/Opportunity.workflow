<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_alert_credit_department</fullName>
        <ccEmails>RetailCredit@dynegy.com</ccEmails>
        <description>Email to alert credit department</description>
        <protected>false</protected>
        <recipients>
            <recipient>Credit_Department</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dynegy_Email_Templates/Email_for_Credit_Check_New</template>
    </alerts>
    <fieldUpdates>
        <fullName>Pricing_Type_Field_Update</fullName>
        <field>Pricing_Type__c</field>
        <literalValue>Initial</literalValue>
        <name>Pricing Type Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Email_Sent_for_Credit_Check</fullName>
        <field>Email_Sent_for_Credit_Check__c</field>
        <literalValue>1</literalValue>
        <name>Update Email Sent for Credit Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Pricing_Type</fullName>
        <field>Pricing_Type__c</field>
        <literalValue>Refresh</literalValue>
        <name>Update Pricing Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email sent to Credit Check</fullName>
        <actions>
            <name>Email_to_alert_credit_department</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Email_Sent_for_Credit_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Credit_Check_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Email_Sent_for_Credit_Check__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Trigger an email to Credit department when &quot;Credit Check Required&quot; field is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Pricing Type Update</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Refresh_Expiration_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update the pricing type field at opportunity if the refresh expiration date is passed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Pricing_Type_Field_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.Refresh_Expiration_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
