public class colorPicklistController{
@AuraEnabled
   public static list <contact> fetchContact(){
        
         List <contact> returnConList = new List < contact > ();
 
         for (contact c: [SELECT firstName, LastName, Department,LeadSource from contact where LeadSource<>null Limit 20]) {
            returnConList.add(c);
          }
         return returnConList;
      
   }
}