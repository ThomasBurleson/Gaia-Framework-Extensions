/*****************************************************************************************************
* Gaia Framework for Adobe Flash ©2007-2009
* Author: Thomas Burleson
*
* blog: http://www.gridlinked.info/
* forum: http://www.gaiaflashframework.com/forum/
* wiki: http://www.gaiaflashframework.com/wiki/
* 
* By using the Gaia Framework, you agree to keep the above contact information in the source code.
* 
* Gaia Framework for Adobe Flash is released under the GPL License:
* http://www.opensource.org/licenses/gpl-2.0.php 
*****************************************************************************************************/

package ext.gaiaframework.slides {
    
    import flash.system.Security;
	import com.gaiaframework.api.*;
	import com.gaiaframework.assets.*;
	import com.gaiaframework.events.*;
	import com.gaiaframework.templates.AbstractPage;
	import com.gaiaframework.utils.AssetFilter;
	import com.greensock.TweenMax;
	
	import ext.gaiaframework.behaviors.ContentCenterer;
	import ext.gaiaframework.behaviors.TimeLineHooks;
	
	import flash.display.*;
	import flash.events.*;
	
	import utils.string.supplant;
	
	/**
	 * This class provides base functionality to quickly create Slide shows with GAIA.
	 * 
	 * The Gaia framework will provide the loading mechanisms, caching, preloader, and page transition controls, deepLinking, SEO, and context menu
	 * for global navigations. This makes it VERY easy to create complex slides with LARGE content and complex internal interactions.
	 * 
	 * SlidePages are focused on showing a single SWF or Image asset and auto-connecting the Gaia transitions with the SWF transition phases.
	 * Timeline hooks for frame scripts, autoCentering, and timeline actionscript are all supported.
	 *  
	 *      Each slide is responsible for the animations used within itself; during the transitionIn, idle, and transitionOut phases.
	 *      Each slides is INDEPENDENT of the other slides.
	 *      Developers may create slide content of ANY complexity...
	 * 
	 * NOTE: Some conventions must be followed for SlidePage instances:
	 *
	 *          1) Slide content must have both an "in" and an "out" frame to support gotoAndPlay()
	 *             Each slide should have a blank frame 1 with stop() code... this way the SlidePage will gotoAndPlay("in") properly
	 *          2) Slide content must dispatch "inComplete" and "outComplete" notifications when their
	 *             custom animation is finished
	 *          3) Slides must dispatch a 'goNext' or 'gotoPage' event to request GAIA to transition to
	 *             the some other slide.
	 *          4) Jumps to other slides do NOT have to be SlidePage instances. So mixed content can be aggregated.
	 *
	 *    This code is manipulating the MovieClipAsset or the BitmapAsset of the PageAsset. 
	 *    Adjust your site.xml to define your slides as pages. Load the slide content as a SWF asset
	 *
	 *    Sample siteXML.xml:
	 * 
	 *			<site title="Insertables: %PAGE%" menu="true">
	 *			  
	 *			  <slides>
	 *			    <workflow>
	 *			      <flow id="slide1" next="nav/slide2"   previous="" />
	 *			      <flow id="slide2" next="nav/slide3"   previous="nav/slide1" />
	 *			      <flow id="slide3" next="nav/slide4"   previous="nav/slide2" />
	 *			      <flow id="slide4" next="nav/slide2"   previous="nav/slide3" />
	 *			    </workflow>
	 *			  </slides>
	 *			  
	 *			  <page id="nav" title="Nav" src="assets/nav.swf" depth="top" menu="false" bytes="4341">
	 *			    <page id="slide4" title="Thanks" src="assets/slides.swf" bytes="71600"  menu="false" >
	 *			      <asset src="assets/slides/slide4.jpg" id="slide4_content" width="770" height="205" autoCenter="true" bytes="2641"  />
	 *			    </page>
	 *			    <page id="slide1" title="Tour Insertables" src="assets/slides.swf" bytes="71600" menu="true" seo="true" seoBytes="2086">
	 *			      <asset src="assets/slides/slide1.swf" id="slide1_content"  autoCenter="true" width="600" height="400" bytes="129438"  />
	 *			    </page>
	 *			    <page id="slide2" title="Multi-page Web Forms" src="assets/slides.swf" bytes="71600" menu="true" >
	 *			      <asset src="assets/slides/slide2.swf" id="slide2_content"  autoCenter="true" width="600" height="400" bytes="119839"  />
	 *			    </page>
	 *			    <page id="slide3" title="Multi-lingual Web Forms" src="assets/slides.swf" bytes="71600" menu="true" >
	 *			      <asset src="assets/slides/slide3.swf" id="slide3_content"  autoCenter="true" width="600" height="400" bytes="122251"  />
	 *			    </page>
	 *			  </page>
	 *			  
	 *			</site>
	 *
	 *    Notice how each of the <page /> nodes above uses a slides.swf as the slide container? The slides.swf is a build of slides.fla which
	 *    uses a FLA Document class to be a instance of ext.gaiaframework.templates.SlidePage (or its subclass)
	 * 
	 * 	  Developers should also specify a <workflow /> node to define the page flows within the slide show.  The <workflow /> settings are parsed
	 *    by the PageFlow singleton.
	 *
	 */	 
	 
	public class SlideBase extends AbstractPage {

		
		/**
		 * Should the SWF content have framescripts added to
		 * auto detect in, out, inComplete, and outComplete events?
		 *  
		 * @param val True to inject timeline frame scripts
		 */		
		public function set hookFrames(val:Boolean):void {
			_hookFrames = val;
		}
		
		/**
		 * Accessor to content instance; which may be a MovieClipAsset (swf)
		 * or a BitmapAsset (image). 
		 *  
		 * @return DisplayObjectAsset instance or null 
		 */
		public function get content():DisplayObjectAsset {
			return (swf || image);
		}
		
		
		/**
		 * Get 1st slide child MovieClipAsset instance (MovieClipAsset).
		 * The specific instance is based on how the asset is identified in the site.xml
		 * e.g. 
		 * 		<page id="slide1" title="Tour Insertables" src="assets/slides.swf" menu="true" seo="true" seoBytes="2086">
		 *			<asset src="assets/slides/slide1.swf" id="slide1_content"  autoCenter="true" width="600" height="400"  />
		 *		</page>
		 */
		public function get swf() : MovieClipAsset {
			if (_slide == null) {
				// The slide is either the Page itself or the first SWF asset/content
				var allSWFs : Object = page ? AssetFilter.getSWF(assets) : null;				
				var mcAsset : *      = (allSWFs && allSWFs.hasOwnProperty(slideName)) ? allSWFs[this.slideName] : null; 
				
				_slide = mcAsset && mcAsset.content ? mcAsset as MovieClipAsset : null;
				
				validatedFrames();
			}
			
			return _slide;
		}
		
		/**
		 * Get 1st slide child BitmapAsset instance.
		 * The specific instance is based on how the asset is identified in the site.xml
		 * e.g. 
		 * 		<page id="slide1" title="Tour Insertables" src="assets/slides.swf" menu="true" seo="true" seoBytes="2086">
		 *			<asset src="assets/slides/slide4.jpg" id="slide4_content" width="770" height="205" autoCenter="true" />
		 *		</page>
		 */
		public function get image() : BitmapAsset {
			if (_image == null) {
				// The slide is either the Page itself or the first SWF asset/content
				var allImgs  : Object = page ? AssetFilter.getImage(assets) : null;				
				var imgAsset : *      = (allImgs && allImgs.hasOwnProperty(slideName)) ? allImgs[this.slideName] : null; 
				
				_image =  imgAsset && imgAsset.content ? imgAsset as BitmapAsset : null;
			}
			
			return _image;
		}
		
		// ********************************************************************
		//  Constructor
		// ********************************************************************
		
		public function SlideBase() {
			super();			
			// Since slides are intended to be deployed as self-contained SWFs;
            // each slide should open full access for scripting by loading SWF.
            Security.allowDomain("*");
		}
		
		// ********************************************************************
		//  GAIAI Methods to support page/slide transitions
		// ********************************************************************
		
		
		/**
		 * GAIA is requesting that this slide perform a transitionIn (immediate or animated)
		 * and respond with notification when the transition is finished.
		 */
		override public function transitionIn():void  {
			super.transitionIn();   // Dispatches the "transitionIn" started event
			
			if ( showContent() != true ) {
				transitionInComplete();
			}
		}
		
		/**
		 * GAIA is requesting that this slide perform a transitionOut (immediate or animated)
		 * and respond with notification when the transition is finished.
		 */
		override public function transitionOut():void {			
		    terminateIn();
		    		    
	        super.transitionOut();   // Dispatches the "transitionOut" started event
	        		          
			if ( hideContent() != true ) {
				transitionOutComplete();	
			}
			
	    }
		
		
		// ********************************************************************
		//  Event Handlers to support slide navigation
		// ********************************************************************
		
		/**
		* Go to the "next" slide in the sequence
		*/
		protected function onGoNext(e:Event):void {			
			e.preventDefault();
			e.stopImmediatePropagation();

			PageFlow.instance.goNext(page.id);
		}
		
		
		/**
		 *  This event handler allows slide content to "jump" to any arbitrary 
		 *  slide in the slideShow.
		 *  @FIXME: must determine how to indicate the destination page/branch
		 */
		protected function onGotoPage(e:Event):void {
		    // @TODO: not yet implemented
		}
		
		/**
		 * Announce to GAIA the completion of the transition requests
		 */
		 protected function onComplete(e:Event):void {
			switch(e.type) {
				case "inComplete":
				{
					swf.removeEventListener(e.type,onComplete);					
					dispatchEvent(new PageEvent(PageEvent.TRANSITION_IN_COMPLETE));
					
					break;
				}
				case "outComplete":
				{
					swf.removeEventListener(e.type,onComplete);					
					dispatchEvent(new PageEvent(PageEvent.TRANSITION_OUT_COMPLETE));

					break;
				}
			}
		}
		 
		/**
		 * For static image content, mouse clicks autoNavigate to the next slide.
		 */
		protected function onSlideClick(event:MouseEvent):void {
			
			onGoNext(event);
		}		
		
		// ********************************************************************
		//  Protected Methods
		// ********************************************************************

		protected function showContent():Boolean {
			var results : Boolean = _performingIn || (swf != null)  || (image != null);
			
			_autoCenter ||= new ContentCenterer(swf || image, this);

			if (swf != null) {
				
				if (_hookFrames || (swf.node.@hookFrames == "true")) {
					// Do we need to add TimeLine frame script hooks to this movieClip?
					_hooks ||= new TimeLineHooks(swf, onComplete);
				}
				
				_autoCenter.invalidate();
				
				// Handle default behaviors for complex, timeline or AS3 SWFs
				
				swf.addEventListener("goNext",onGoNext,false,0,true);				
				swf.addEventListener("inComplete",onComplete, false, 0, true);								
				
				swf.gotoAndPlay("in");	     // each swf content needs an "in" frame						
				swf.visible = true;            // GAIA hides the slide upon load and before transitionIn
				
			} else if (image != null) {
				
				_autoCenter.invalidate();					
				
				image.visible = true;
				image.alpha   = 0;
				TweenMax.to(image, 0.5, {alpha:1, onComplete:transitionInComplete});
				
				// Since bitMaps are not mouse-sensitive (not Sprites)
				stage.addEventListener(MouseEvent.MOUSE_DOWN,onSlideClick,false,0,true);
			}
			
			_performingIn = results;
			
			return results;
		}
		
		protected function hideContent():Boolean {
			var results : Boolean = (swf || image);
			
			if (swf != null) {

				swf.addEventListener("outComplete",onComplete, false, 0, true);
				swf.gotoAndPlay("out");		    // each slide content needs an "out" frame
				
			} else if (image != null) {
				
				TweenMax.to(image, 0.2, {alpha:0, onComplete:transitionOutComplete});
				stage.removeEventListener(MouseEvent.MOUSE_DOWN,onSlideClick);
			}
			
			return results;
		}
		
		// ********************************************************************
		//  Private Methods
		// ********************************************************************

        /**
         * If we need to interrupt the transitionIn and immediately transitionOut,
         * then stop the slide play, force announce transitionInComplete to GAIA. 
         */
        private function terminateIn():void {
		    if (swf && _performingIn) {
		        swf.stop();
		        
		        onComplete(new Event("inComplete"));
		        _performingIn = false;
		        
		    }
        }		
		
		
		/**
		 * Check and validate that SWF content has the required "in" and "out" frame labels;
		 * required for gotoAndPlay() calls in the transitionIn() and transitionOut() methods above! 
 		 *
		 * @return Boolean true in the minimum frame labels are available  
		 */
		private function validatedFrames():Boolean {
			var msg      : String = "WARNING! SWF {id} is missing either the 'in' or 'out' frameLabels. Transitions will not work properly!"; 
			var frames 	 : int    = 0; 
			
			if (_slide != null) {
				for each (var it:FrameLabel in _slide.content.currentLabels) {
					switch(it.name) {
						case "in"	:	frames = frames | 2;	break;
						case "out"	:   frames = frames | 8;	break;
					}
				}
				
				
				if (frames != 10) trace(supplant(msg,{id:slideName}));
			}
			
			return (frames == 10);
		}
		
		// ********************************************************************
		//  Protected Accessors
		// ********************************************************************

		/**
		 * Grabs the name of the 1st SWF or Bitmap asset found/loaded; 
		 * since the pageAsset is a slidePage instance wrapper only.
		 */
		protected function get slideName():String {
		    // Defaults to the page ID
		    var sName : String = this.page.id;
		    
		    if (page && assets) {
		        for (var key:* in assets) {
		            if ((assets[key] is MovieClipAsset) || (assets[key] is BitmapAsset)) {
		                // Or uses the 1st MovieClipAsset ID
		                sName = key;
		                break;
		            }
		        }
		    }
            return sName;
		}
		
		
		// ********************************************************************
		//  Protected Attributes
		// ********************************************************************

		
		protected var _autoCenter     : ContentCenterer = null;
		protected var _hooks		  : TimeLineHooks  	= null;
		protected var _hookFrames	  : Boolean         = false;
		
		protected var _flow			  : PageFlow        = null;
		
		protected var _slide          : MovieClipAsset 	= null;
		protected var _image          : BitmapAsset		= null;
		
		protected var _performingIn   : Boolean        	= false;   
		
	}
}


