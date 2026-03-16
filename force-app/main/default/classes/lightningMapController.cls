public with sharing class lightningMapController {
    @AuraEnabled
    public static list<accountLocationWrapper> getLocation(){
        list<accountLocationWrapper> lstALW = new list<accountLocationWrapper>();
        /*Query accounts records with billing address information */  
        for(account acc : [Select Name,description, BillingCountry, BillingCity, BillingPostalCode, BillingStreet, BillingState
                           From Account
                           Where BillingCountry != null
                           And BillingCity != null
                           limit 10]){
                               // first create "locationDetailWrapper" instance and set appropriate values
                               locationDetailWrapper oLocationWrap = new locationDetailWrapper();
                               oLocationWrap.Street = acc.BillingStreet;
                               oLocationWrap.PostalCode = acc.BillingPostalCode;
                               oLocationWrap.City = acc.BillingCity;
                               oLocationWrap.State = acc.BillingState;
                               oLocationWrap.Country = acc.BillingCountry;
                               
                               // create "accountLocationWrapper" instance, set values and add to final list. 
                               accountLocationWrapper oWrapper = new accountLocationWrapper();
                               oWrapper.icon = 'utility:location'; 
                               oWrapper.title = acc.Name;
                               oWrapper.description = acc.description;
                               oWrapper.location = oLocationWrap;
                               
                               lstALW.add(oWrapper);
                           }
        // retrun the "accountLocationWrapper" list
        return lstALW;
    }
    /* wrapper class to store required properties for "lightning:map" component' */ 
    public class accountLocationWrapper{
        @AuraEnabled public string icon{get;set;} 
        @AuraEnabled public string title{get;set;} 
        @AuraEnabled public string description{get;set;} 
        @AuraEnabled public locationDetailWrapper location{get;set;} 
    }
    /* sub wrapper class to store location details for "accountLocationWrapper" location property.*/ 
    public class locationDetailWrapper{
        @AuraEnabled public string Street{get;set;}
        @AuraEnabled public string PostalCode{get;set;}
        @AuraEnabled public string City{get;set;}
        @AuraEnabled public string State{get;set;}
        @AuraEnabled public string Country{get;set;}
    }
}