public class OrderViewController{
    
    /*
    * 初始化简档
    */
    @AuraEnabled
    public static String getProfile(){
      Profile p =[Select Id,Name From Profile where Id =:Userinfo.getProfileId()];
      return p.Name;
    }
    
    /*
    * 初始化订单
    */
    @AuraEnabled
    public static Opportunity getOrder(string oppid){
       try{
         Opportunity  rcd = [SELECT Id,Name,AccountId,Account.Name,Account_Address__c,Account_Address__r.Full_Address__c,Amount,
                            Account_Address__r.Contact_Name__c,Account_Address__r.Contact_Name__r.Name,
                            X3rd_Party_Account__c,X3rd_Party_Account__r.Name,Pricebook2Id,Pricebook2.Name,Arrival_Date__c,Description
                            ,Product_Category__c,Payment_Method__c,Account_No__c,Ordering_Type__c,Customer_PO_Number__c  
                            FROM Opportunity WHERE Id =: oppid];
         return rcd;
        }catch(Exception e){system.debug(e.getMessage());return null;}
    }
    
    /*
    * 初始化产品列表
    */
    @AuraEnabled
    public static list<OpportunityLineItem> getProducts(string oppid){
       list<OpportunityLineItem> items = new list<OpportunityLineItem>();
       try{
            items = [SELECT Id,Name,Product2Id,Product2.Name,Product2.ProductCode,UnitPrice,Gift_Control__r.Target_Amount__c,
                     Quantity,TotalPrice,GiftsNumber__c,TotalNumber__c,Description,Tax_Rate__c,Gift_X_Y__c,Measurement__c 
                    FROM OpportunityLineItem WHERE OpportunityId =: oppid];
        }catch(Exception e){system.debug(e.getMessage());}
       return items;
    }
}