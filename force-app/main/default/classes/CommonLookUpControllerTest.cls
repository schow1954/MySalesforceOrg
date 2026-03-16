@isTest
private class CommonLookUpControllerTest {
    static testMethod void testMethod1() {
    	Account a1 = new Account();
    	a1.Name = 'test1';
    	insert a1;
    	Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = a1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
    	Test.startTest();
        CommonLookUpController.RetrieveWrapper wrapper = new CommonLookUpController.RetrieveWrapper();
        wrapper.retrieveKeyword = 'test';
        wrapper.searchGroup = 'ALL FIELDS';
        wrapper.objName2FieldMap = new Map<String,String>{'Account'=>'Name','Contact'=>'Name'};
        List<CommonLookUpController.SearchResultWrapper> resultList = CommonLookUpController.search(wrapper);
        system.assertEquals(1, resultList.size());
        Test.stopTest();
    }
}