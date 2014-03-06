public class DataCategoryHelper {
    
    private String[] objects;
    private Map<String, String> mapNameToLabel = new Map<String, String>();
    public DataCategory[] topCategories = new List<DataCategory>();
    public static DataCategory[] allTopCategories;
    
    public DataCategoryHelper(String[] objs) {
        init(objs);
    }
    
    private void init(String[] objs) {
        objects = objs;
        for (DataCategory category : getCategories()) {
            mapNameToLabel.put(category.getName(), category.getLabel());
        } 
    }
    
    public Map<String, String> getNameToLabelMap() {
        return mapNameToLabel;
    }
    
    public String getLabel(String name) {
        return mapNameToLabel.get(name);
    }    
    
    public Boolean isChildCategoryOf(String child, String topLevel) {
        for (DataCategory category1 : getCategories()) {
            if (category1.getName() == topLevel) {
                for (DataCategory category2 : category1.getChildCategories()) {
                    if (category2.getName() == child) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    // Added Bikram 18 Jan 2013    
    public DataCategory[] getChildCategoryCustom(String topLevel) { 
        for (DataCategory category : getCategories()) {
            if (category.getName() == topLevel) {
                return category.getChildCategories();
            }
        }
        return null;
    }
    
    public DataCategory[] getChildCategoryCustomNew(String topLevel) { 
        if(DataCategoryHelper.allTopCategories == null){
            DataCategoryHelper.allTopCategories = getCategories();
        }
        for (DataCategory category : allTopCategories) {
            if (category.getName() == topLevel) {
                return category.getChildCategories();
            }
        }
        return null;
    }    
    //helper.getTopCategory(helper.getCategories(), 'Admin', 'All');
    
    public String getTopCategory (DataCategory[] dCatgs, String key, String top) {
        
        for (DataCategory category : dCatgs) {
            //System.Debug('NAMEOFCATEG'+category.getName());
            if (category.getName() == key) {
                return top;
            }
        }
        //System.Debug('SECOND');
        for (DataCategory category : dCatgs) {
            String topCateg = getTopCategory(getChildCategoryCustomNew(category.getName()), key, category.getLabel());
            if (topCateg != null) {
                return topCateg;
            }
        }        
        return null;       
    }
    
    
    public DataCategory[] getCategories() {
        DataCategory[] categories = new List<DataCategory>();
        
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        for (DescribeDataCategoryGroupResult singleResult : Schema.describeDataCategoryGroups(objects)) {
            DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
            pair.setSobject(singleResult.getSobject());
            pair.setDataCategoryGroupName(singleResult.getName());
            pairs.add(pair);
        }
     
        for (DescribeDataCategoryGroupStructureResult singleResult : Schema.describeDataCategoryGroupStructures(pairs, false)) {
            for (DataCategory category : getAllCategories(singleResult.getTopCategories())) {            
                categories.add(category);
                topCategories.add(category);
                
                for (DataCategory childCategory : category.getChildCategories()) {
                    categories.add(childCategory);
                    
                    for (DataCategory grandChildCategory : childCategory.getChildCategories()) {
                        categories.add(grandChildCategory);
                    }
                }
            }
        }

        return categories;
    }
    
    private DataCategory[] getAllCategories(DataCategory[] categories) {
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

    public static DataCategoryHelper getHelper(String[] objects) {
        return new DataCategoryHelper(objects);
    }

    public static DataCategoryHelper getHelper(String obj) {
        return new DataCategoryHelper(new String[] {obj});
    }

}