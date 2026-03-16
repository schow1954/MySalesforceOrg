public with sharing class GoodsController {

       public List<GOODS__c> goodsList{get;set;}

       public List<SelectOption> goodsTypes = new List<SelectOption>();



       public GOODS__c goods{get;set;}

       public Boolean isStatus{get;set;}

       public String goodsName{get;set;}

       public String goodsType{get;set;}

       public Decimal goodsPriceStart{get;set;}

       public Decimal goodsPriceEnd{get;set;}

       public String goodsDescribe{get;set;}



       public GoodsController() {
           goodsList = new List<GOODS__c>();
           refreshData();
       }




       public List<selectOption> getTypeNames() {
           goodsTypes.clear();
        goodsTypes.add(new SelectOption('手机','手机'));
        goodsTypes.add(new SelectOption('家用','家用'));
           return goodsTypes;
       }


       //刷新数据作用
       public void refreshData() {
           Boolean isStatus = true;
           String goodsQueryString = 'SELECT   GoodsBrand__c,'+
                                      'GoodsDescribe__c,GoodsName__c, GoodsType__c, GoodsPrice__c,'+
                                       '  Id FROM Goods__c where IsDeleted = false limit 100';
           goodsList = Database.query(goodsQueryString);
       }

       public void save() {
           try {
               upsert goodsList;
           } catch(DmlException e) {
               ApexPages.addMessages(e);
           }
       }

       public void deleteGoods() {
           Id id = ApexPages.currentPage().getParameters().get('goodsId');
           Database.delete(id);
           refreshData();
       }

       public void add() {
           if(goodsList == null) {
               goodsList = new List<GOODS__c>();
           }
           GOODS__c goods2 = new GOODS__c();
           System.debug('-----------goodsList------------------'+goodsList);
           if(goodsList.size() == 0) {
               goodsList.add(goods2);
           } else {
               goodsList.add(0,goods2);
           }
       }

       public void query() {
           String goodsSql = 'SELECT GoodsBrand__c,'+
                              'GoodsDescribe__c,GoodsName__c , GoodsType__c, GoodsPrice__c,'+
                               ' Id FROM GOODS__c where IsDeleted = false ';
           if(goodsName.length() >0) {
               goodsName = '%' + goodsName + '%';
               goodsSql += ' and GoodsName__c like :goodsName ';
           }
           if(goodsType.length() > 0) {
               goodsType = '%' + goodsType + '%';
               goodsSql += ' and GoodsType__c like :goodsType';
           }
           if(goodsDescribe.length() > 0) {
               goodsDescribe = '%' + goodsDescribe + '%';
               goodsSql += ' and GoodsDescribe__c like :goodsDescribe';
           }

           if(String.valueOf(goodsPriceStart).length()>0) {
               goodsSql += ' and GoodsPrice__c >= :goodsPriceStart';
           }
           if(String.valueOf(goodsPriceEnd).length()>0) {
               goodsSql += ' and GoodsPrice__c <= :goodsPriceEnd';
           }
           goodsSql += ' limit 100';
           goodsList = Database.query(goodsSql);
           goodsName = goodsName.remove('%');
           goodsDescribe = goodsDescribe.remove('%');
           goodsType = goodsType.remove('%');
       }}