/*
   09-03-11 vishals@grazitti.com
   Created Test class to increase code coverage.
*/
@isTest
private class TestDataCategoryHelper {
	
	static testmethod void TestHelper1(){
		List<String> objects = new List<String>{'KnowledgeArticleVersion', 'Question'};
		DataCategoryHelper helper = DataCategoryHelper.getHelper(objects);
		helper.getCategories();
		helper.getNameToLabelMap();
		helper.getLabel('Account');	
		Boolean isChild = helper.isChildCategoryOf('Question', 'KnowledgeArticleVersion');
		DataCategoryHelper helper1 = DataCategoryHelper.getHelper('Question');
	}
}