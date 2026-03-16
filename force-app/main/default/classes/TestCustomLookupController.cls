public class TestCustomLookupController{

    //Search Account Fields
    @AuraEnabled
    public static List<SObJectResult> getResults(String value){
        
        list<Account> acclist = [SELECT Id,Name FROM Account];
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        if(acclist.size() > 0){
            for(Account acct:acclist){
                if(acct.Name.containsIgnoreCase(value.trim())){
                    sObjectResultList.add(new SObjectResult(acct.Name, acct.Id));
                }
            }
        }
        return sObjectResultList;
    }
    
    public class SObJectResult{
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp){
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}