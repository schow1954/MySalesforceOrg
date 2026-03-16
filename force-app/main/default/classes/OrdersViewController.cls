public class OrdersViewController{
    
    @AuraEnabled
    public static Opportunity getOrder(string oppid){
       try{
         Opportunity  rcd = [SELECT Id,Name,AccountId,Account.Name,Account_Address__c,Account_Address__r.Full_Address__c,
                            Account_Address__r.Contact_Name__c,Account_Address__r.Contact_Name__r.Name,Record_Type__c,
                            X3rd_Party_Account__c,X3rd_Party_Account__r.Name,Pricebook2Id,Pricebook2.Name,Arrival_Date__c,
                            Used_Bonus__c,Tax_Rate__c,Product_Category__c,IsUsed__c 
                            FROM Opportunity WHERE Id =: oppid];
         return rcd;
        }catch(Exception e){system.debug(e.getMessage());return null;}
    }
    
    @AuraEnabled
    public static list<OpportunityLineItem > getProducts(string oppid){
       list<OpportunityLineItem> items = new list<OpportunityLineItem>();
       try{
            items = [SELECT Id,Name,Product2Id,Product2.Name,Product2.ProductCode,UnitPrice,
                     Quantity,TotalPrice,GiftsNumber__c,TotalNumber__c,Description
                    FROM OpportunityLineItem WHERE OpportunityId =: oppid];
        }catch(Exception e){system.debug(e.getMessage());}
       return items;
    }
}