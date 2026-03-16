public class testProcess{

    @InvocableMethod
    public static void method(list<string> oppid){
system.debug('11111111:   '+oppid);
        Opportunity opp = [select Id,name from Opportunity where Id In: oppid];
        opp.name = 'sougou';
        Update opp;
    
    }


}