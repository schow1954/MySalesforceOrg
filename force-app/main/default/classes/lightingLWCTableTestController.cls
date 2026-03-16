public with sharing class lightingLWCTableTestController {
	//新建订单
    @AuraEnabled
    public static list<Opportunity> getData(){
        return [select Id,Name,Amount,CloseDate,Description from Opportunity limit 5];
    }
}