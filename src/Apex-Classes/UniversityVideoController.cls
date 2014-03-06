public class UniversityVideoController extends MarketoBaseController {

	public UniversityVideoController(){}
	
	public String getUrl() {
		String currentPageUrl = ApexPages.currentPage().getUrl();
		return currentPageUrl;				
	}
	
	public String getSource(){
		String src = ApexPages.currentPage().getParameters().get('src');
		return src;
	}
	
	public String getVideoTitle(){
		String videoTitle = ApexPages.currentPage().getParameters().get('video_title');
		return videoTitle;		
	}
	
	public String getCategoryTitle(){
		String categoryTitle = ApexPages.currentPage().getParameters().get('category_title');
		return categoryTitle;		
	}	
}