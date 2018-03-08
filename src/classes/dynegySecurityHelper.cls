/* 
 * Name: dynegySecurityHelper
 * Type: Apex Class
 * Test Class: NA
 * Description: This class is used to set security header. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti        01/21/2016       1. Initial Version created
 */
public with sharing class dynegySecurityHelper {
    public class UsernameToken {
        public UsernameToken(String username, String password) {
            this.Username = username;
            this.Password = password;
        }
        public String Username;
        public String Password;
        private String[] Username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'Username','Password'};

    }

    public class SecurityHeader {       
        public SecurityHeader(String username, String password) {
            this.UsernameToken = new dynegySecurityHelper.UsernameToken(username, password);
        }
        public String wsuNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd';              
        public dynegySecurityHelper.UsernameToken UsernameToken;
        private String[] UsernameToken_type_info = new String[]{'UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','UsernameToken','1','1','false'};
        private String[] wsuNamespace_att_info = new String[]{'xmlns:wsu'};               
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'UsernameToken'};
    }

}