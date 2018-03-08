<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_alert_to_notify_user_when_a_quote_has_been_generated_with_Price_Complet</fullName>
        <description>Email to alert to notify user when a quote has been generated with Price Complete Status</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Dynegy_Email_Templates/Price_Complete_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Quote_Expired</fullName>
        <field>Request_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Quote Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_Record</fullName>
        <description>Unlock record for editing.</description>
        <field>Locked__c</field>
        <literalValue>0</literalValue>
        <name>Unlock Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_and_Term</fullName>
        <field>Unique_Product_with_Term__c</field>
        <formula>Opportunity__c  &amp;  Product__c   &amp;  TEXT(Term__c)</formula>
        <name>Update Product and Term</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Request_Status__c</field>
        <literalValue>New</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Expire Quote</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Retail_Quote__c.Request_Status__c</field>
            <operation>equals</operation>
            <value>Pricing Complete</value>
        </criteriaItems>
        <description>Expire Quote based on Price Valid Date time</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Quote_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Unlock_Record</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Retail_Quote__c.Pricing_Valid_Date_Time__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Price Complete notification</fullName>
        <actions>
            <name>Email_to_alert_to_notify_user_when_a_quote_has_been_generated_with_Price_Complet</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Retail_Quote__c.Request_Status__c</field>
            <operation>equals</operation>
            <value>Pricing Complete</value>
        </criteriaItems>
        <description>Send an email to owner of quote record when &quot;Price Complete&quot; status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Request Status When Cloned</fullName>
        <actions>
            <name>Update_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Request Status to New when we clone an existing record</description>
        <formula>AND(ISCLONE(), RecordType.Name = &apos;Indicative&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
