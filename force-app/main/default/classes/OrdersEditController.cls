public class OrdersEditController{
    
    //新建订单
    @AuraEnabled
    public static Opportunity getOrder(){
        Opportunity opp = new Opportunity();
        string pname = [SELECT Id,Name FROM Profile WHERE Id =: Userinfo.getProfileId()].Name;
        string headerstr;
        /*
        //if(string.isNotBlank(pname) && pname == 'Partner Community User'){
        if(string.isNotBlank(pname) && pname == 'System Administrator'){
            //客户下单
            //string accid = [SELECT Id,Name,AccountId FROM Contact WHERE OwnerId =: Userinfo.getUserId()].AccountId;//客户账户和客户关系
            string accid = [SELECT Id FROM Account WHERE OwnerId =: Userinfo.getUserId()].Id;
            list<Opportunity> orderlist = [SELECT Id,Name,Account.Name FROM Opportunity WHERE AccountId =: accid order by CreatedDate DESC];
            headerstr = orderlist[0].Account.Name+'-'+string.valueOf(Date.today().Year())+'-';
            Integer ye = Integer.valueOf(orderlist[0].Name.split('-')[1]);
            Integer num = Integer.valueOf(orderlist[0].Name.split('-')[2]);
            if(ye == Date.today().Year()){
                if(num <9){
                    headerstr += '00'+string.valueOf(num+1);
                }
                if(num >=9 && num < 99){
                    headerstr += '0'+string.valueOf(num+1);
                }
                if(num >99){
                    headerstr += string.valueOf(num+1);
                }
            }else{headerstr += '001';}
        }
        */
        if(string.isNotBlank(pname) && pname == 'NC Sales'){
            //业务代理下单
        }
        opp.Name = '85度C-2020-002';
        //opp.Name = headerstr;
        return opp;
    }
    
    //初始化产品列表
    @AuraEnabled
    public static list<OpportunityLineItem> getEditProducts(string oppid){
        list<OpportunityLineItem> products = new list<OpportunityLineItem>();
        try{
            products = [SELECT Id,name,Product2Id,Product2.Name,Product2.ProductCode,UnitPrice,
                     Quantity,TotalPrice,GiftsNumber__c,TotalNumber__c,Description
                        FROM OpportunityLineItem WHERE OpportunityId =: oppid];
        }catch(exception e){
            system.debug(e.getMessage());
        } 
        return products;
    }
    
    //编辑订单
    @AuraEnabled
    public static Opportunity getOrder2(string oppid){
        Opportunity opp = new Opportunity();
        if(string.isNotBlank(oppid)){
            try{
                opp = [SELECT Id,Name,Record_Type__c,AccountId,X3rd_Party_Account__c
                           ,Price_Book__c,Product_Category__c,Tax_Rate__c,Used_Bonus__c
                           FROM Opportunity WHERE Id =: oppid];                
            }catch(exception e){system.debug(e.getCause());}
        }
        return opp;
    }
    
    //获取客户
    @AuraEnabled
    public Static List<Map<String,String>> getAccounts(){
        
        List<Map<String, String>> items = new List<Map<String, String>>();
        List<Account> acclist;
        map<string,string> maps = new map<string,string>();
        //acclist = [SELECT Id,Name FROM Account WHERE ERP_Account_No__c <> null limit 20];
        acclist = [SELECT Id,Name FROM Account limit 20];
        string pname = [SELECT Id,Name FROM Profile WHERE Id =: Userinfo.getProfileId()].Name;
        if(string.isNotBlank(pname) && pname == 'Partner Community User'){
            //客户下单
            //string accid = [SELECT Id,AccountId FROM Contact WHERE Id =: Userinfo.getUserId()].AccountId;
            //acclist = [SELECT Id,Name FROM Account WHERE ERP_Account_No__c <> null And Id =: accid];
        }
        if(string.isNotBlank(pname) && pname == 'NC Sales'){
            //业务代理下单
            
        }
        if(!acclist.isEmpty()){
            for(Account rcd:acclist){
                maps.put(rcd.Id,rcd.name);
            }
            if(maps.size() > 0){
                for(String str:maps.keySet()){items.add(new Map<String,String>{'value' => str, 'label' => maps.get(str)});}
            }
        }
        return items;
    }
    
    //获取客户地址
    @AuraEnabled
    public static list<Account_Address__c> getAddress(String accid){
        
       list<Account_Address__c> data = new list<Account_Address__c>();
       try{
           if(string.isNotBlank(accid)){
               data = [SELECT Id,Name,Full_Address__c,Contact_Name__r.Name,Checkbox__c 
                            FROM Account_Address__c WHERE Account__c =:accid And Detail_Address__c <> null];
           } 
        }catch(Exception e){system.debug(e.getMessage());}
        return data;
    }
    
    //获取净价支援户
    @AuraEnabled
    public Static List<Map<String,String>> getAccount(string accid){
        
        List<Map<String, String>> items = new List<Map<String, String>>();
        map<string,string> maps = new map<string,string>();
        List<Account> acclist = [SELECT Id,Name FROM Account WHERE ERP_Account_No__c <> null And Related_Distributor__c =: accid];
        if(!acclist.isEmpty()){
            for(Account rcd:acclist){
                maps.put(rcd.Id,rcd.name);
            }
            if(maps.size() > 0){
                for(String str:maps.keySet()){items.add(new Map<String,String>{'value' => str, 'label' => maps.get(str)});}
            }
        }
        return items;
    }
    
    //获取非可用产品列表
    @AuraEnabled
    public static list<PricebookEntry> getProducts(string pricebookid){
        
       list<PricebookEntry> items = new list<PricebookEntry>();
       if(string.isNotBlank(pricebookid)){
            try{
                items = [SELECT Id,Name,Product2Id,Product2.Name,Product2.ProductCode,UnitPrice,Disabled__c,
                         Quantity__c,Checkbox__c,Description__c,TotalPrice__c,GiftsNumber__c,TotalNumber__c 
                        FROM PricebookEntry WHERE Pricebook2Id =:pricebookid];
            }catch(Exception e){system.debug(e.getMessage());}
       }
       return items;
    }
    
    //获取可用产品列表
    @AuraEnabled
    public static list<PricebookEntry> getProducts2(string pid,string cate,string rate){
        
       list<PricebookEntry> items = new list<PricebookEntry>();
       list<PricebookEntry> temp = new list<PricebookEntry>();
       list<PricebookEntry> result = new list<PricebookEntry>();
       if(string.isNotBlank(pid)){
           try{
               items = [SELECT Id,Name,Product2Id,Product2.Name,Product2.ProductCode,UnitPrice,Disabled__c,
                        Quantity__c,Checkbox__c,Description__c,TotalPrice__c,GiftsNumber__c,TotalNumber__c,
                        Tax_Rate__c,Product_Category__c
                        FROM PricebookEntry WHERE Pricebook2Id =:pid];
           }catch(Exception e){system.debug(e.getMessage());}
           if(string.isNotBlank(cate) && string.isNotBlank(rate)){
               try{
                    temp = [SELECT Id,Name,Disabled__c FROM PricebookEntry WHERE Pricebook2Id =:pid And Tax_Rate__c =:rate And Product_Category__c =: cate];
                }catch(Exception e){system.debug(e.getMessage());}
           }
           if(items.size() >0){
               if(temp.size() > 0){
                   for(PricebookEntry p: items){
                       for(PricebookEntry pe:temp){
                           if(p.Id == pe.Id){p.Disabled__c = true;}
                       }
                   }
               }
               for(PricebookEntry pb: items){
                   if(pb.Disabled__c == true){
                       result.add(pb);
                   }
               }
               for(PricebookEntry pb: items){
                   if(pb.Disabled__c == false){
                       result.add(pb);
                   }
               }
           }
       }
       return result;
    }
    
    //获取价格档
    @AuraEnabled
    public static List<Map<String,String>> getPricebooks(string accid,string ordertype){

        List<Map<String, String>> items = new List<Map<String, String>>();
        List<Pricebook2> plist = new List<Pricebook2>();
        List<Account_Price_Book__c> aplist = new List<Account_Price_Book__c>();
        map<string,string> maps = new map<string,string>();
        if(string.isNotBlank(accid) && string.isNotBlank(ordertype)){
            if(ordertype == '一般订单'){
                string typeName;
                try{
                    typeName = [SELECT Id,recordtype.Name FROM account WHERE id =:accid].recordtype.Name;
                }catch(Exception e){system.debug(e.getMessage());}
                if(string.isNotBlank(typeName) && typeName == 'Distributor'){
                    plist = [SELECT Id,Name FROM Pricebook2 WHERE IsStandard = true];
                }else{
                    aplist = [SELECT Id,Price_Book__c,Price_Book__r.Name FROM Account_Price_Book__c WHERE Account__c =:accid And Active__c = true];
                }
            }else{
                aplist = [SELECT Id,Price_Book__c,Price_Book__r.Name FROM Account_Price_Book__c WHERE Account__c =:accid And Active__c = true];
            }
            if(plist.size() > 0){
                for(Pricebook2 p:plist){maps.put(p.Id,p.Name);}
                if(maps.size() > 0){
                    for(String str:maps.keySet()){items.add(new Map<String,String>{'value' => str, 'label' => maps.get(str)});}
                }
            }
            if(aplist.size() > 0){
                for(Account_Price_Book__c p:aplist){
                    if(string.isNotBlank(p.Price_Book__c))maps.put(p.Price_Book__c,p.Price_Book__r.Name);
                }
                if(maps.size() > 0){
                    for(String str:maps.keySet()){items.add(new Map<String,String>{'value' => str, 'label' => maps.get(str)});}
                }
            }
        }else{return null;}
       return items;
    }
    
    //订单保存
    @AuraEnabled
    public static string saveMethod(string opp,string pdt,string mode){
        string oppid;
        if(string.isNotBlank(opp) && string.isNotBlank(pdt)){

            Opportunity record = (Opportunity)JSON.deserialize(opp, Opportunity.class);
            list<OpportunityLineItem> lineItems = new list<OpportunityLineItem>();
            list<PricebookEntry> pblist = (list<PricebookEntry>)JSON.deserialize(pdt, list<PricebookEntry>.class);
            if(mode == 'New'){
                //if(record.Record_Type__c == '一般订单'){record.RecordTypeId = '0129D000000f1ZfQAI';}
                //if(record.Record_Type__c == '净价支援户订单'){record.RecordTypeId = '0129D000000f1ZpQAI';}
                //if(record.Record_Type__c == '促销订单'){record.RecordTypeId = '0129D000000f1ZkQAI';}
                record.StageName = 'New Order';
                record.CloseDate = Date.today().addDays(20); //关闭时间规则
                Insert record;
                oppid = record.Id;
                for(PricebookEntry p: pblist){
                    OpportunityLineItem ol = new OpportunityLineItem();
                    ol.OpportunityId = oppid;
                    ol.Product2Id = p.Product2Id;
                    ol.TotalPrice = p.TotalPrice__c;
                    ol.UnitPrice = p.UnitPrice;
                    ol.Quantity = p.Quantity__c;
                    if(string.valueOf(p).contains('Description__c'))ol.Description = p.Description__c;
                    lineItems.add(ol);
                }
                Insert lineItems;
            }
            if(mode == 'Edit'){}
        }
       //return '0069D000004EEPUQA4';
       return oppid;
    }
}