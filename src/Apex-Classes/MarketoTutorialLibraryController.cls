public with sharing class MarketoTutorialLibraryController {
	// Variables
	Map<String, Tutorial__kav> mapTutorials;
	Map<String, String> mapCategories;
	public DataCategory topCategory{get;set;}
	public List<TutorialWrapper> listTutorials{get;set;}
	
	public List<TutorialWrapper> listTutorialsMLM{get;set;}	// list of tutorials of type Marketo Lead Management
	public List<TutorialWrapper> listTutorialsRev{get;set;}	// list of tutorials of type Revenue Cycle Analytics
	public List<TutorialWrapper> listTutorialsAdmin{get;set;}	// list of tutorials of type Marketo Admin
	// 3 different set of Top level tutorials in above types
	Set<String> setMLM = new Set<String>{'Create_and_Manage_a_Program', 'Create_and_manage_an_Event','Report_on_a_Program_or_Event'};
	Set<String> setRev = new Set<String>{'Understand_Program_Reporting_Analysis'};
	Set<String> setAdmin = new Set<String>{'Create_Custom_Channels_Tags'};
	
	Map<String, Set<String>> mapAllCats = new Map<String, Set<String>>();
	Map<String, String> mapChildToParent = new Map<String, String>();
	
	/**
	 * Constructor
	 */
	public MarketoTutorialLibraryController(){
		// get all tutorial hierarchy
		getHierarchy();
		mapTutorials = new Map<String, Tutorial__kav>();
		mapCategories = new Map<String, String>();
		listTutorials = new List<TutorialWrapper>(); 
		
		listTutorialsMLM = new List<TutorialWrapper>(); 
		listTutorialsRev = new List<TutorialWrapper>(); 
		listTutorialsAdmin = new List<TutorialWrapper>(); 
		
		// Iterating over all top level categories
		for (DataCategory grandChildCategory : topCategory.getChildCategories()) {
			mapTutorials.put(grandChildCategory.getName(), null);
			mapCategories.put(grandChildCategory.getName(), grandChildCategory.getLabel());
			Set<String> temp = new Set<String>();
			for(DataCategory child : grandChildCategory.getChildCategories()){
				temp.add(child.getname());
				mapChildToParent.put(child.getname(),grandChildCategory.getName() );
			}
			mapAllCats.put(grandChildCategory.getName(), temp);
		}
		
		System.debug('===========before mapTutorials============'+mapTutorials);
		// debugging
		for(String s : mapChildToParent.keyset()){
			System.debug('===========child :'+s+'=======parent====='+mapChildToParent.get(s));
		}
		
		// Querying all tutorials
		List<Tutorial__kav> listTuts = Database.query('select id,knowledgeArticleId, PublishStatus, sort_order__c, title,UrlName,(select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Tutorial__kav where publishstatus=\'Online\' with data category Articles__c below Tutorials__c order by sort_order__c asc');
		Set<String> tutorialNames = new Set<String>();
		
		// Iterating over tutorials to match with corresponding categories
		for(Tutorial__kav tut : listTuts){
			system.debug('==========tut======='+tut);
			system.debug('==========tut.DataCategorySelections======='+tut.DataCategorySelections);
			if(tut.DataCategorySelections != null && tut.DataCategorySelections.size() > 0){
				for(Tutorial__DataCategorySelection dc : tut.DataCategorySelections){
					if(mapChildToParent.containsKey(dc.DataCategoryName)){
						system.debug('======dc.DataCategoryName==='+dc.DataCategoryName);
						system.debug('======mapChildToParent.get(dc.DataCategoryName)==='+mapChildToParent.get(dc.DataCategoryName));
						mapTutorials.put(mapChildToParent.get(dc.DataCategoryName), tut);
						break;
					}
				} // end of inner for-loop
			} // end of if 
		}// end of for-loop
		
		Map<Integer, String> mpSortOrderToTut = new Map<Integer, String>();
        Map<String, Integer> mpTutToSortOrder = new Map<String, Integer>(); 
        
        // Querying sort order of all tutorials
        for(Tutorial_Order__c  curr:Database.query('Select Id, name, sort_order__c from Tutorial_Order__c')){
        	mpSortOrderToTut.put(Integer.valueOf(curr.sort_order__c), curr.Name);
        	mpTutToSortOrder.put(curr.Name, Integer.valueOf(curr.sort_order__c));
        }
        
		System.debug('===========after mapTutorials============'+mapTutorials);
		TutorialWrapper wrapper;
		
		// creating wrapper objects
		for(string st : mapTutorials.keyset()){
			wrapper = new TutorialWrapper();
			wrapper.tutorialName = mapCategories.get(st);
			wrapper.tutorial = mapTutorials.get(st);
			listTutorials.add(wrapper);
			if(setMLM.contains(st)){
				if(wrapper.tutorialName.equalsIgnoreCase('Create and Manage a Program')){
					wrapper.order = '1';
				}else if(wrapper.tutorialName.equalsIgnoreCase('Create & Manage an Event')){
					wrapper.order = '2';
				}else if(wrapper.tutorialName.equalsIgnoreCase('Create a WebEx Event')){
					wrapper.order = '3';
				}else if(wrapper.tutorialName.equalsIgnoreCase('Report on a Program or Event')){
					wrapper.order = '4';
				}
				listTutorialsMLM.add(wrapper);
			}else if(setRev.contains(st)){
				wrapper.order = '1';
				listTutorialsRev.add(wrapper);
			}else if(setAdmin.contains(st)){
				if(wrapper.tutorialName.equalsIgnoreCase('Create Custom Channels & Tags')){
					wrapper.order = '1';
				}else if(wrapper.tutorialName.equalsIgnoreCase('Manage Event Partners')){
					wrapper.order = '2';
				}
				listTutorialsAdmin.add(wrapper);
			}
		}
		
		//List<String> listTemp = new list<String>
		
	}
	
	// Wrapper class
	public class TutorialWrapper{
		public Tutorial__kav tutorial{get;set;}
		public String tutorialName{get;set;}
		public String order{get;set;}
	}
	
	/**
     * Function to get the full hierarchy of tutorials.
     */
	public void getHierarchy(){
    	List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
		for (DescribeDataCategoryGroupResult singleResult : Schema.describeDataCategoryGroups(new String[]{'KnowledgeArticleVersion'})) {
			DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
			pair.setSobject(singleResult.getSobject());
			pair.setDataCategoryGroupName(singleResult.getName());
			pairs.add(pair);
		}
     	
		for(DescribeDataCategoryGroupStructureResult singleResult : Schema.describeDataCategoryGroupStructures(pairs, false)) {
			for (DataCategory category : getAllCategories(singleResult.getTopCategories())) {  
				system.debug('================='+category); 
				if(category.getName() == 'Tutorials'){
					//system.debug('===========childern=====' + category.getChildCategories());
					topCategory = category;
					for (DataCategory childCategory : category.getChildCategories()) {
						//system.debug('===========selectedCats=====' + selectedCats);
						system.debug('===========childCategory=====' + childCategory);     
						//topCategory = childCategory;
					}
				}         
			}
		}
    }
    
    /**
     * Function to fetch all categories.
     * @param categories
     * @return DataCategory[]
     */
    public DataCategory[] getAllCategories(DataCategory[] categories) {
		if (categories.isEmpty()) {
			return new DataCategory[]{};
		}
		DataCategory[] categoriesClone = categories.clone();
		DataCategory category = categories.clone()[0];
		DataCategory[] allCategories = new DataCategory[] {category};
		categoriesClone.remove(0);
		categoriesClone.addAll(category.getChildCategories());
		return categoriesClone;
	}
}