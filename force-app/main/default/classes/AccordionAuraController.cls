public class AccordionAuraController {
    @AuraEnabled
    public static List<Contact> getContacts(){
        List<Contact> contactList = new List<Contact>();
        for(Contact oCon : [SELECT Id, Name, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry From Contact LIMIT 10]){
           contactList.add(oCon); 
        }
        return contactList;
    }
}