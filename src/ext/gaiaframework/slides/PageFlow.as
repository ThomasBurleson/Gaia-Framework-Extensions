package ext.gaiaframework.slides
{
	import com.gaiaframework.api.Gaia;
	
	import flash.utils.Dictionary;

	public class PageFlow
	{
		// *********************************************
		// Static Accessor
		// *********************************************

		static public function get instance():PageFlow {
			if (_instance == null) {
				_instance = new PageFlow(new ConstructorLock);
			}
			return _instance;
		}
		static private var _instance : PageFlow = null; 
		
		
		// *********************************************
		// Constructor 
		// *********************************************

		public function PageFlow(lock:ConstructorLock) {
			buildWorkflow( Gaia.api.getSiteXML() );			
		}

		// *********************************************
		// Navigation methods 
		// *********************************************
		
		public function goNext( currentStep:String ):void {
			var flow : FlowItem = workflow[currentStep] as FlowItem;
			if (flow != null) {
				Gaia.api.goto(flow.next);
			}
		}
		
		public function goBack( currentStep:String ):void {
			var flow : FlowItem = workflow[currentStep] as FlowItem;
			if (flow != null) {
				Gaia.api.goto(flow.prev);
			}
		}
		
		// *********************************************
		// Protected Methods
		// *********************************************
		
		/**
		 *  Gather the site workflow definitions from the site.xml
		 *  Below is a sample xml:
		 * 
		 *   <slides>
    	 *   	<workflow>
      	 *   		<flow id="slide1" next="nav/slide2"   previous="" />
      	 *   		<flow id="slide2" next="nav/slide3"   previous="nav/slide1" />
      	 *   		<flow id="slide3" next="nav/slide4"   previous="nav/slide2" />
      	 *   		<flow id="slide4" next="nav/slide2"   previous="nav/slide3" />
      	 *   	</workflow>
       	 *   </slides>
		 * 
		 */
		protected function buildWorkflow( site:XML ):void {
			for each (var flow:XML in site.slides.workflow.flow) {
				workflow[ String(flow.@id) ] = new FlowItem(flow);
			}
		}
		
		protected var workflow : Dictionary = new Dictionary();
		
	}
}




class ConstructorLock { }

class FlowItem {
	
	public var id 	:	String = "";
	public var next :	String = "";
	public var prev :   String = "";
	
	public function FlowItem(flow:XML) {
		if (flow != null) {
			id 		= flow.@id;
			next 	= flow.@next;
			prev    = flow.@previous;
		}	
	}
}