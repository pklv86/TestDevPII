/*  
 *This Class contains utility methods that are used by different classes  
 *in the Org  
 **/  
 public class DynegyCommonUtils{  
    
    public static String generateRandomString(Integer len) {
	    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	    String randStr = '';
	    string tempstr = 'TR';
	    string str='';
	    while (randStr.length() < len) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
	       randStr += chars.substring(idx, idx+1);
	    }
	    system.debug('randStr : '+randStr);
	    if(randStr.startsWithIgnoreCase(tempstr)){
	    	str=randStr.substring(2,randstr.length());
	    	randStr = generateRandomString(str,15);
	    }
	    
	    return randStr; 
	}
	
	public static String generateRandomString(String str, Integer len) {
	    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	    while (str.length() < len) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
	       str += chars.substring(idx, idx+1);
	    }
	    system.debug('String : '+str);
	    return str;
	}
	
 }