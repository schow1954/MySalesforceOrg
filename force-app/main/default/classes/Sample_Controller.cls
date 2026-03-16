public with sharing class Sample_Controller {
 
    @AuraEnabled(cacheable=true)
    public static List<Account> f_Get_Types(){
        try {
            List<Account> l_Types = new List<Account>();
             
            l_Types = [Select Id, Name from account]; // Can include multiple fields, 
            // You can also use any standard or custom object
            // You can get values from custom setting also.
             
            return l_Types;
        } catch (Exception e) {
            System.debug('Exception: '+e.getMessage());
            return null;
        }
    }
}