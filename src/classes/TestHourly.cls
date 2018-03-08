global class TestHourly implements Database.stateful,Database.Batchable<sObject>{

    global final string carrystr;
    global final Integer carrynum;
    string st;
    integer nu;
 
    public testhourly(){
    
    }
    
    public testhourly(String str, Integer num){
    
        carrystr = str;
        carrynum = num;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        string s1 = carrystr+':'+carrynum;
        string query = 'select id,name from account limit 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.Batchablecontext bc,list<sobject> scope) {
        
        list<account> acclst = (list<sobject>)scope;
        st = carrystr;
        nu = carrynum;
        for(Account acc : acclst){
            nu++;
            st=carrystr+system.now();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    
        system.debug('Finishing....... Integer'+nu+' --> String : '+st);
        //TestHourlysch th = new Testhourlysch(strlst);
        TestHourlysch th = new TestHourlysch(st,nu,system.now());
        //Database.executeBatch(th,10);
    }

}