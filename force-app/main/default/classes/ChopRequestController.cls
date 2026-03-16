/**************************************************************************************************
 * Name: ChopRequestController
 * Object: Chop_Request
 * Author: zhou
 * Create Date: 2019-9-11
***************************************************************************************************/
public class ChopRequestController{

    @AuraEnabled
    public Static Company_Chop__c doInitMethod(String rid){
      try{
        Company_Chop__c rcd = [SELECT Id,Name,Contract_Management__c,Contract_Management__r.Name,
        Contract_Types__c,Contract_Type__c,Remark__c,Files_Content__c,
        Files_Types__c,Files_Type__c,Legal_Entity__c,Apply_User__c,
        Apply_Department__c,Apply_Date__c,Seal_Type__c,Certification_Doc__c
        FROM Company_Chop__c WHERE Id =:rid];
        return rcd;
      }catch(Exception e){System.debug(e.getMessage());}
      return Null;
    }   

    @AuraEnabled
    public static String getContracts(String contid)
    {
        try{
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'data' => [SELECT Id,Name FROM CustomContract__c WHERE Id = :contid][0]
            });
        }catch(Exception e){
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage()
            });
        }
    }

    @AuraEnabled
    public Static Boolean doSaveMethod(String reqt){
       Company_Chop__c item = (Company_Chop__c)JSON.deserialize(reqt, Company_Chop__c.class);
       try{
           Database.Update(item);
           return true;
       }catch(Exception e){System.debug(e.getMessage());}
       return false;
    }  
}