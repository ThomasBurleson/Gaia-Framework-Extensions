package ext.gaiaframework.behaviors
{
	
	import com.gaiaframework.api.IMovieClip;
	
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import utils.string.supplant;
	
	/**
	 *  Class works great to add hooks to movieclip timelines for inComplete and outComplete
	 *  frames. These hooks allow the GAIA transitionIn and transitionOut actions to work properly.
	 *
	 * 	This class would be needed if the SWF content has the appropriate frameLabels and NO timeline actionscript that
	 *  dispatches inComplete or outComplete events to the SlidePage [required to integrate with Gaia transition processes].
	 *
	 *  NOTE: that if the SWF has an associated Document class then any TimeLine actionscript will NOT be available upon instantiation.   
	 *  
	 */
	public class TimeLineHooks {
		
		/**
		 * Constructor  
		 */
		public function TimeLineHooks(slide:IMovieClip, callbacks:Function) {
			target 			= slide;
			completeFunc	= callbacks;
			
			addFrameHandlers();
		}
		
		/**
		 * Check and validate that all four (4) frame labels are present
		 * within the PageAsset movieClip 
		 * @return 
		 * 
		 */
		public function validatedFrames():Boolean {
			var frames : int = 0; 
			
			if (content != null) {
				for each (var it:FrameLabel in content.currentLabels) {
					switch(it.name) {
						case IN				:	frames = frames | 2;	break;
						case IN_COMPLETE	:	frames = frames | 4;	break;
						case OUT			:   frames = frames | 8;	break;
						case OUT_COMPLETE	:   frames = frames | 16;	break;
					}
				}
				
				if (frames != 30) trace(supplant(INVALID_FRAMES,target));
			}
			
			return (frames == 30);
		}
		
		// ********************************************************************
		//  Event Handlers
		// ********************************************************************
		
		/**
		 * A frame hook was triggered, if it is an <xxx>Complete label, then auto-dispatch
		 * such an event so the SlidePage is triggered. 
		 * 
		 */
		protected function onEnterFrameMarker(event:Event=null):void {
			switch(content.currentLabel) {
				case IN_COMPLETE	:
				case OUT_COMPLETE	: 
				{
					content.stop();
					break;
				}
			}
			
			content.dispatchEvent(new Event(content.currentLabel));			
		}
		
		
		// ********************************************************************
		//  Protected Methods
		// ********************************************************************
		
			
		/**
		 * Since the timeline actionscript may not be available in the Movieclip instance,
		 * attach custom handlers to specific frames in the movieClip: 'in, inComplete, out, outComplete'
		 * These handlers will auto-dispatch an inComplete or outComplete event when that frame is entered. 
		 */
		protected function addFrameHandlers():void {
			if (content != null) {
				for each (var it:FrameLabel in content.currentLabels) {
					// zero-based frame counters...
					MovieClip(content).addFrameScript(it.frame-1,this.onEnterFrameMarker);
				}
				
				validatedFrames();
				
				content.addEventListener(IN_COMPLETE,completeFunc,false,0,true);
				content.addEventListener(OUT_COMPLETE,completeFunc,false,0,true);
				
				// Try to go to the 1st frame... which should ideally be blank!
				content.gotoAndStop(1);
			}
		}
		
		protected function get content():MovieClip {
			return target ? target.content : null;
		}
		
		// ********************************************************************
		//  Protected Attributes
		// ********************************************************************
		
		
		protected var completeFunc 	: Function = null;
		protected var target 		: IMovieClip = null;	
		
		static private const IN 		  : String = "in";
		static private const OUT		  : String = "out";
		static private const IN_COMPLETE  : String = "inComplete";
		static private const OUT_COMPLETE : String = "outComplete";
		
		static private const INVALID_FRAMES : String = "WARNING! TimeLineHooks {id} is missing 1 or more required frameLabels: 'in, inComplete, out, outComplete'";
		
	}
}