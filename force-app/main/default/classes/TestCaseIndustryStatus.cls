public class TestCaseIndustryStatus {
	
    public static void setStatus(){
        lead data = [select id,Industry,TTSApp__EndDate__c,TTSApp__StartDate__c from lead where id = '00Q2v00001WaT5I'];
        data.Industry = 'Agriculture';
        data.TTSApp__StartDate__c = system.now();
        data.TTSApp__EndDate__c = system.now();
        Update data;
    }
}