public class Test_Page_Controller{

    public String TerritoryCode {get;set;}
    public String inputProvinceName {get;set;}
    public String inputCityName{get;set;}
    
    public List<SelectOption> getTerritoryList(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Account.Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
        }    
        return options;
    }   
    public List<SelectOption> getProvinceList(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Account.Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
        }    
        return options;
    }
    public List<SelectOption> getCityList(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Account.Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
        }    
        return options;
    }   
    
    public void getCitysBaseProvince(){
      System.debug('get');
    }
    
    public PageReference SearchClear(){
      return null;
    }
    
    public void SearchAction(){  
         
    }
}