<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_on_Deployment</fullName>
        <description>Notification on Deployment</description>
        <protected>false</protected>
        <recipients>
            <field>EmailId_for_Notification__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Release_Management/Notification_After_Deployment</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Notification_Email_Id</fullName>
        <field>EmailId_for_Notification__c</field>
        <formula>Environment__r.EmailId_for_Notification__c</formula>
        <name>Update Notification Email Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Notification for Activity Details</fullName>
        <actions>
            <name>Notification_on_Deployment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Notification_Email_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>DeploymentDetails__c.Status__c</field>
            <operation>equals</operation>
            <value>Success,Failure</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
