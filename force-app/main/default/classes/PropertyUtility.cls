public class PropertyUtility{

    public static void newListedProperties(){
        list<Property__c> newPropList = [select id,Name, Broker__r.Email__c,Days_On_Market__c from Property__c where Days_On_Market__c <= 30 ];
        for(Property__c p:newPropList){
            string propEmail = p.Name + ' : '+p.Broker__r.Email__c;
            system.debug(propEmail);
        }
    }
}