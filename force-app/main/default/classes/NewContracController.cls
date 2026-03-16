/**************************************************************************************************
 * Name: NewContracController
 * Object: CustomContract
 * Author: zhou
 * Create Date: 2019-9-9
***************************************************************************************************/
public class NewContracController{

    @AuraEnabled
    public Static CustomContract__c doInit(){
      CustomContract__c rcd = new CustomContract__c();
      rcd.ApplyUser__c = Userinfo.getFirstName()+' '+Userinfo.getLastName();
      rcd.ApplyUsers__c = Userinfo.getUserId();
      rcd.RequestDate__c = Date.today();
      rcd.RequestDepartment__c = [SELECT Id,Department FROM User WHERE Id =:Userinfo.getUserId()].Department;
      return rcd;
    }   

  	@AuraEnabled
    public Static String saveMethd(String contracts){
        CustomContract__c item = (CustomContract__c)JSON.deserialize(contracts, CustomContract__c.class);
        if(item.ContractAmountType__c == '1') item.ContractAmountType__c = '合同金额 <= RMB 300,000';
        if(item.ContractAmountType__c == '2') item.ContractAmountType__c = 'RMB 300,000 <= 合同金额 <= RMB 1,000,000';
        if(item.ContractAmountType__c == '3') item.ContractAmountType__c = '合同金额 > 1,000,000';
        try{
        	Database.insert(item);
        	return item.Id;
        }catch(Exception e){System.debug(e.getMessage());}
        return Null;
    }  
}