trigger Buy_SellTrigger on Buy_Sell__c (after insert,after update) {

    map<id,decimal> stmap = new map<id,decimal>();
    if(trigger.isAfter){
       for(Buy_Sell__c rcd: trigger.new){
           if(rcd.Actions__c == 'Buy'){
                stmap.put(rcd.Stock__c,rcd.Price__c);
           }
       }
       if(!stmap.isEmpty()){
            list<Stock__c> stlist = [select id,Purchase__c from Stock__c where id in:stmap.keySet()];
            for(Stock__c st: stlist){
                st.Purchase__c = stmap.get(st.id);
            }
            update stlist;
       }
    }
}