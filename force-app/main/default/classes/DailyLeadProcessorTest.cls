@isTest
private class DailyLeadProcessorTest {
    public static String CRON_EXP = '0 0 1 * * ?';
    @isTest static void testScheduledJob() {
        list<Lead> Leads = new list<Lead>();
       for (Integer i = 0; i < 200; i++) {
            Leads.add(new lead(Lastname='Dream force'+i, Company= 'test'));
        }
        insert Leads;
          
        Test.startTest();
            System.schedule('DailyLeadProcessor',CRON_EXP,new DailyLeadProcessor());
        Test.stopTest();     
    }    
}