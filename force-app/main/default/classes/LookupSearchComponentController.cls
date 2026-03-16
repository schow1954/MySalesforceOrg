public class LookupSearchComponentController {
	@AuraEnabled
    public static List<SObJectResult> getResults(String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(Account acct : [Select Id,Name FROM Account WHERE Name LIKE: +'%'+value+'%']){
            sObjectResultList.add(new SObjectResult(acct.Name, acct.Id));
        }
        
        return sObjectResultList;
    	}
    
   		public class SObJectResult {
            @AuraEnabled
            public String recName;
            @AuraEnabled
            public Id recId;
            
            public SObJectResult(String recNameTemp, Id recIdTemp) {
                recName = recNameTemp;
                recId = recIdTemp;
            }
    	}
}