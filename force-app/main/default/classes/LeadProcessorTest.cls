@isTest
public class LeadProcessorTest {
    @testSetup static void setup(){
        Lead l = new Lead(lastname = 'test',LeadSource = 'Email', Company='test');
        Insert l;
    }
    @isTest static void test(){
        Test.startTest();
        	LeadProcessor lp = new LeadProcessor();
        	Database.executeBatch(lp,200);
        Test.stopTest();
    }
}