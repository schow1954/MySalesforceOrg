public with sharing class ContactController2 {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String accId) {
		List<Contact> data = [
            SELECT AccountId, Id, FirstName, LastName, Title, Phone, Email
            FROM Contact
            WHERE AccountId = :accId
            WITH SECURITY_ENFORCED
        ];
        return data;
    }
}