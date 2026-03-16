@isTest
public class AccountProcessorTest {
    @isTest static void test(){
        list<Id> accids = new list<Id>();
        Account acc = new Account(
        Name = 'test',
        Number_of_Contacts__c = 0);
        insert acc;
        accids.add(acc.Id);
        Contact cont = new Contact(Lastname = 'test',AccountId = acc.id);
        Insert cont;
        Test.startTest();
        AccountProcessor.countContacts(accids);
        Test.stopTest();
    }
}