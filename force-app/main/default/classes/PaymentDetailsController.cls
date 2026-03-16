/**************************************************************************************************
 * Name: PaymentDetailsController
 * Object: Expenses_Detail__c
 * Purpose: for payment details compt
 * Author: zhou
 * Create Date: 2019-9-17
***************************************************************************************************/
public class PaymentDetailsController{
    
    @AuraEnabled
    public Static List<Expenses_Detail__c> doInit(String recordId){
        if(String.isNotBlank(recordId)){
           List<Expenses_Detail__c> edlist = [SELECT Id,Name,Pcc_Code__c,VendorID__c,VendorID__r.Name,Vendor_Remark__c,
                                        Product_Codes__c,Payment_Object__c,Pay_Type__c,Expense_Projects__c,
                                        Payment__c,Address__c,Expense_Categories__c,Amount__c
                                        FROM Expenses_Detail__c WHERE Payment__c =:recordId];
            for(Expenses_Detail__c rcd:edlist){
                if(rcd.Payment_Object__c == '第三方供应商')rcd.Payment_Object__c = 'H3';
            }
            if(edlist.size()>0)return edlist;
        }
        return Null;
    }

    @AuraEnabled
    public Static String getAccounts(String accid){
        
        try{
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'data' => [SELECT Id,Name FROM Account WHERE Id = :accid][0]
            });
        }catch(Exception e){
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage()
            });
        }
    }
	/*
    @AuraEnabled
    public Static List<Map<String, String>> setProductCodes(){
        List<Map<String, String>> items = new List<Map<String, String>>();
        List<Product_Code__c> codelist = [SELECT Id,Name FROM Product_Code__c];
        Set<String> sets = new Set<String>();
        if(!codelist.isEmpty()){
            for(Product_Code__c rcd:codelist){
                sets.add(rcd.Name);
            }
            if(sets.size()>0){
                for(String str:sets){
                    items.add(new Map<String, String>{'value' => str, 'label' => str});
                }   
            }
        }
        if(!items.isEmpty()) return items;
        return Null;
    }*/

    @AuraEnabled
    public Static List<Map<String, String>> setPayType(){
        List<Map<String, String>> items = new List<Map<String, String>>();
        String[] strlist = Utilities.picklist_values('Expenses_Detail__c','Pay_Type__c');
        if(!strlist.isEmpty()){
            for(String str:strlist){
                items.add(new Map<String, String>{'value' => str, 'label' => str});
            }   
        }
        if(!items.isEmpty()) return items;
        return Null;
    }

    @AuraEnabled
    public Static List<Map<String, String>> setCategories(String cname){
        List<Map<String, String>> items = new List<Map<String, String>>();
        List<Expenses_Management__c> codelist;
        Set<String> sets = new Set<String>();
        if(String.isNotBlank(cname)){
            codelist = [SELECT Id,Name FROM Expenses_Management__c WHERE Expenses__c =:cname];
        }else{
            codelist = [SELECT Id,Name FROM Expenses_Management__c];
        }
        
        if(!codelist.isEmpty()){
            for(Expenses_Management__c rcd:codelist){
                sets.add(rcd.Name);
            }
            if(sets.size() > 0){
                for(String str:sets){
                    items.add(new Map<String, String>{'value' => str, 'label' => str});
                }
            }
        }
        if(!items.isEmpty()) return items;
        return Null;
    }

    @AuraEnabled
    public Static Map<String,List<Map<String, String>>> setProjects(){
        Map<String,List<Map<String, String>>> result = new Map<String,List<Map<String, String>>>();
        Set<String> setItems = new Set<String>();
        Set<String> setitms = new Set<String>();
        List<Expenses_Management__c> items = [SELECT Id,Name FROM Expenses_Management__c];
        if(!items.isEmpty()){
            for(Expenses_Management__c rcd:items){
                setItems.add(rcd.Name);
            }
            if(!setItems.isEmpty()){
                for(String s:setItems){
                    List<Map<String, String>> projitems = new List<Map<String, String>>();
                    List<Expenses_Management__c> projs = [SELECT Id,Expenses__c FROM Expenses_Management__c WHERE Name=:s];
                    if(!projs.isEmpty()){
                        for(Expenses_Management__c em:projs){
                            projitems.add(new Map<String, String>{'value' => em.Expenses__c, 'label' => em.Expenses__c});
                        }
                    }
                    result.put(s,projitems);
                }
            }
        }
        System.debug('result:  '+result);
        return result;
    }

    @AuraEnabled
    public Static List<String> setExpenses(String code){
        List<String> result = new List<String>();
        if(String.isNotBlank(code)){
            try{
                Expenses_Management__c rcd = [SELECT Id,Pcc_Code__c,Name,Expenses__c FROM Expenses_Management__c WHERE Pcc_Code__c =:code limit 1];
                result.add(rcd.Name);
                result.add(rcd.Expenses__c);
                return result;
            }catch(Exception e){System.debug(e.getMessage());}
        }
        return Null;
    }

    @AuraEnabled
    public Static List<Map<String, String>> getProjects(String categories,List<String> arrlist){
        List<Map<String, String>> result = new List<Map<String, String>>();
        Set<String> results = new Set<String>();
        if(String.isNotBlank(categories)){
                List<Expenses_Management__c> emlist = [SELECT Id,Pcc_Code__c,Name,Expenses__c FROM Expenses_Management__c WHERE Name =:categories];
                if(!emlist.isEmpty()){
                    for(Expenses_Management__c rcd:emlist){
                        results.add(rcd.Expenses__c);
                    }
                    if(!arrlist.isEmpty()){
                        for(String str:arrlist){
                            results.add(str);
                        }
                    }
                    if(!results.isEmpty()) {
                        for(String s:results){
                            result.add(new Map<String, String>{'value' => s, 'label' => s});
                        }
                    }
                }
                return result;
        }
        return Null;
    }

    @AuraEnabled
    public Static List<String> setPccCode(String projname){
        List<String> result = new List<String>();
        if(String.isNotBlank(projname)){
            try{
                Expenses_Management__c rcd = [SELECT Id,Name,Pcc_Code__c FROM Expenses_Management__c WHERE Expenses__c =:projname limit 1];
                result.add(rcd.Name);
                result.add(rcd.Pcc_Code__c);
                return result;
            }catch(Exception e){System.debug(e.getCause());}
        }
        return Null;
    }

    @AuraEnabled
    public Static Boolean doSaveMethd(String datas){ 
        if(String.isNotBlank(datas)){
            List<Expenses_Detail__c> items = (List<Expenses_Detail__c>)JSON.deserialize(datas, List<Expenses_Detail__c>.class);
            if(items.size()>0){
                for(Expenses_Detail__c rcd:items){
                    rcd.VendorID__r = NUll;
                    if(rcd.Payment_Object__c == '请选择') rcd.Payment_Object__c = Null;
                    if(rcd.Payment_Object__c == 'H3') rcd.Payment_Object__c = '第三方供应商';
                    if(rcd.Pay_Type__c == '请选择') rcd.Pay_Type__c = Null;
                    if(rcd.Expense_Categories__c == '请选择') rcd.Expense_Categories__c = Null;
                    if(rcd.Expense_Projects__c == '请选择') rcd.Expense_Projects__c = Null;
                }
                try{
                    Database.Upsert(items);
                    return true;
                }catch(Exception e){System.debug(e.getMessage());}
            }
        }
        return false;
    }

    @AuraEnabled
    public Static Boolean doDel(String pid){
        if(String.isNotBlank(pid)){
            try{
                Expenses_Detail__c item = [SELECT Id FROM Expenses_Detail__c WHERE Id =:pid];
                Database.delete(item);
                return true;
            }catch(Exception e){
                System.debug(e.getCause());
            }
        }
        return false;
    }
    
    @AuraEnabled
    public Static Boolean doNew(String recordId){
        Expenses_Detail__c rcd = new Expenses_Detail__c(Payment__c = recordId);
        try{Database.insert(rcd); return true;}catch(Exception e){System.debug(e.getMessage());}
        return false;
    }
}