/*****************************************************************************************************
* Gaia Framework for Adobe Flash ©2007-2009
* Author: Steven Sacks
*
* blog: http://www.stevensacks.net/
* forum: http://www.gaiaflashframework.com/forum/
* wiki: http://www.gaiaflashframework.com/wiki/
* 
* By using the Gaia Framework, you agree to keep the above contact information in the source code.
* 
* Gaia Framework for Adobe Flash is released under the GPL License:
* http://www.opensource.org/licenses/gpl-2.0.php 
*****************************************************************************************************/

package pages
{
	import com.gaiaframework.templates.AbstractPreloader;
	import com.gaiaframework.api.Gaia;
	import com.gaiaframework.events.*;
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	public class CustomPreloader extends MovieClip
	{
		public var loaded_amount:TextField;
		public var spinner      :MovieClip;
		
		public function CustomPreloader()
		{
			super();
			alpha = 0;
			visible = false;
			mouseEnabled = mouseChildren = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		public function transitionIn():void
		{
		    onResize();
			TweenMax.to(this, .1, {autoAlpha:1});
		}
		public function transitionOut():void
		{
			TweenMax.to(this, .1, {autoAlpha:0});
		}
		public function onProgress(event:AssetEvent):void
		{
			//trace("spinner ="+spinner);
			//trace("loaded_amount ="+loaded_amount);
			
			// if bytes, don't show if loaded = 0, if not bytes, don't show if perc = 0
			// the reason is because all the files might already be loaded so no need to show preloader
			visible = event.bytes ? (event.loaded > 0) : (event.perc > 0);
			
			if (visible == true) spinner.play();
			else                 spinner.stop();
			
			// multiply perc (0-1) by 100 and round for overall 
			loaded_amount.text = Math.round(event.perc * 100) + "%";
			
			// individual asset percentage (0-1) multiplied by 100 and round for display
			//var assetPerc:int = Math.round(event.asset.percentLoaded * 100) || 0;			
		}
		private function onResize(event:Event = null):void
		{
		    if (Gaia.api != null) {
			    x = (Gaia.api.getWidth() - width) / 2;
			    y = (Gaia.api.getHeight() - height) / 2;
		    }
		}
	}
}
