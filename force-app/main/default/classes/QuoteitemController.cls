public class QuoteitemController{
    
    @AuraEnabled
    public static list<QuoteLineItem> getQuoteLineItems(string oppid){
       list<QuoteLineItem> data = new list<QuoteLineItem>();
       try{
            data = [SELECT id,Description,UnitPrice,Product2Id,Product2.Name,Product2.ProductCode,TotalPrice,GiftsNumber__c,TotalNumber__c,Quantity,Subtotal FROM QuoteLineItem WHERE Quote.OpportunityId =: oppid];
        }catch(Exception e){system.debug(e.getMessage());}
       return data;
    }
    
    @AuraEnabled
    public static Integer countRecords(string oppid){
       Integer num;
       try{
            num = [SELECT count() FROM QuoteLineItem WHERE Quote.OpportunityId =: oppid];
        }catch(Exception e){system.debug(e.getMessage());}
       return num;
    }
}