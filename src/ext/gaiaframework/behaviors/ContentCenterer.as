package ext.gaiaframework.behaviors
{
	import com.gaiaframework.api.IDisplayObject;
	import com.gaiaframework.api.IPage;
	import com.gaiaframework.assets.BitmapAsset;
	import com.gaiaframework.assets.MovieClipAsset;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * This class provides autoCentering behavior to the page content.
	 * When a RESIZE event is detected AND autoCenter is enabled, this 
	 * class will determine the content bounds and center within the page's stage area...
	 */
	public class ContentCenterer {
		
		/**
		 * Should the slide content be autoCentered
		 * @default True
		 */
		public var autoCenter : Boolean = false;
		
		
		
		public function ContentCenterer(target:IDisplayObject, owner:IPage ):void {
			this.target = target;
			this.page   = owner;
			
			page.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		
		/**
		 * Parse the slide XML attributes (if available) to determine the slide bounds
		 * and autoCenter settings. Then autoCenter the content if needed. 
		 */
		public function invalidate():void {
			parseAutoCenter();
			onResize();
		}
		
		
		/**
		 * When the SlidePage [extends MovieClip] is added to the stage, listen for resize
		 * and removeFromStage events. Then attempt to autoCenter the slide content.
		 *  
		 * @param event Event.ADDED_TO_STAGE 
		 */
		private function onAddedToStage(event:Event):void
		{
			page.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
			page.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			
			invalidate();
		}
		
		/**
		 * When the SlidePage [extends MovieClip] is removed to the stage, listen for future readds.
		 *  
		 * @param event Event.REMOVED_FROM_STAGE
		 */
		private function onRemovedFromStage(event:Event=null):void {
			page.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			if (stage != null) stage.removeEventListener(Event.RESIZE, onResize);
			
			page.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);			
		}
		
		/**
		 * When stage resizes, then conditionally autoCenter the slide content
		 */
		private function onResize(event:Event = null):void
		{			
			if (stage && content && autoCenter) {
				
				// NOTICE here we are adjusting the positioning (centering) the slide.content
				// The slide is which is a MovieClipAsset defined by an <asset /> tag of the <page /> xml node)
				// WE are NOT adjusting the <page /> instance (which is a PageAsset)
				
				content.x = (stage.stageWidth  - bounds.width)  / 2;
				content.y = (stage.stageHeight - bounds.height) / 2;
			}
		}
		
		// ********************************************************************
		//  Private Methods
		// ********************************************************************
		
		
		/**
		 * Get the "autoCenter" and boundingBox options from the site.xml <asset /> 
		 * XML properties.
		 */
		private function parseAutoCenter():void {
			if (page && target) {
				var node : XML = this.contentXML;
				if (content && node) {
					var explicitSizes : Boolean = node.@width != null;
					
					// Should we attempt to autoCenter the slide content in the slide area? 
					autoCenter = (String(node.@autoCenter) == "true");	
					
					// Since the slide content may vary in size (based on current frame in that slide's timeline)
					// if we want to autoCenter the entire slide, we must determine the bounding box size.			    
					bounds =  	explicitSizes                                                    ? 
								new Rectangle(0,0, Number(node.@width),Number(node.@height))     :
								new Rectangle(0,0, Number(content.width),Number(content.height)) ;
				}	
			}
		}	
		
		private function get stage():Stage {
			return page ? page["stage"] as Stage : null;
		}
		
		private function get content():DisplayObject {
			return (target is MovieClipAsset) 	?	MovieClipAsset(target).content 	:
				   (target is BitmapAsset)	  	?	BitmapAsset(target).content	 	: null;
		}
		
		private function get contentXML(): XML {
			return (target && Object(target).hasOwnProperty("node")) ? target["node"] as XML : null;
		}
		
		protected 	var page 	: IPage	 		 = null;
		protected   var target  : IDisplayObject = null;
		protected 	var bounds  : Rectangle 	 = null;
	}
		
}