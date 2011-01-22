/**
 * SlideBox : a jQuery Plug-in
 *
 * Converts the specified DIV into a slideBox with support for preloading (offscreen) of any Flash/SWF content
 * Injects wrapper DIV with custom CSS to support these features and to "stick" to the bottom or top of the 
 * browser window (regardless of page scrolling).
 *
 * The DIV content can be anything desired, but some controls CSS IDs are 
 * expected (see lines 52-55). Current settings default to a "slide up from bottom"
 *
 *
 * 		Thomas Burleson <thomasburleson@gmail.com>
 * 		http://www.gridlinked.info
 *
 *
 * Sample usage in the HTML to make the <div id="drawer" /> into a slideBox
 *
 *       <!-- Dynamically grab latest jQuery scrips [based on your current browser] -->
 * 		 <script src="http://code.jquery.com/jquery-latest.js" type="text/javascript"></script>
 * 
 *       <script src="assets/slideBox/js/slideBox.js" type="text/javascript"></script>
 *
 *       <script>
 *			$(document).ready(function(){
 *				$("#drawer").slideBox({preload:false});
 *			});
 *       </script>
 * 
 * 	Released under no license, just use it where you want and when you want.
 *
 */
 
 // *********************************************************************************************
 // Protected wrapper method to auto "add" the slideBox() method to jQuery
 // *********************************************************************************************
 
 (function($){
	
	// ****************************************************
	// slideBox() method used
	// 
	// Attaches slideDown and slideUp behaviors to DIV areas
	// and also attaches click handlers to trigger the slide actions
	// 
	// ****************************************************

	$.fn.slideBox = function(params){
		
		// Define expected control/CSS ids; note these could be passed in with the "slideBox()" call
		// See slideContent.css for details on the divs and IDs expected in the DOM...
		
		var $panel 		= "div#panel";
		var $btnOpen    = "#open";
		var $btnClose   = "#close";
		var $btnToggle  = "#toggle a";

		// this == $("#drawer") which is set via $("#drawer").slideBox({preload:true});
		
		var $target     = $( this );  
		
		// Configure default CSS settings for the "wrapper" div that will be injected (line 95)
		// Then merge in parameters to allow user to override slide orientation; default == "bottom"
		
		var defaults = {
			bottom			: "0",   		
			position		: "fixed",   	
    		width			: "100%",
			"z-index"		:"999",
    		"text-align"	: "center",
    		"margin-left"	: "auto",
    		"margin-right"	: "auto",
    		autoFocus       : ""
		}	
		
		if ( params ) $.extend( defaults, params );	
			
		if ( defaults.slideFrom == "top" ) {
			// NOTE: this code expects that the user has inverted the tabs and CSS (for images)
			// to allow the "tab" to show BELOW the panel area instead of above it.
			defaults.top = defaults.bottom;
			
			// Now remove this key/value
			delete defaults.bottom;		
		}		
	
		// Create wrapper div with slideBox CSS. Add original content to the wrapper
		// Then inject/replace original with slideBox-wrapped content 
		
		var content  = $target.html();
		var $div     = $("<div id='slideBox'>");		
					
		$div.css(defaults);
		$div.html(content);
		
		$target.replaceWith($div);
		
        // Get actual references to DOM instances using CSS IDs 
        // NOTE: this must be done AFTER the replaceWith() call on line 

		$panel 		= $( $panel     );
		$btnOpen    = $( $btnOpen   );
		$btnClose   = $( $btnClose  );
		$btnToggle  = $( $btnToggle );


		// Now establish event handlers for the slideBox button actions
		
		var $expandFunc   = function() {	
			if (defaults.preload) {
				// Force changes CSS to cause browser to preload content
				// This CSS trickery is necessary/required to preload SWFs
				$panel.css("height", 0);
				$panel.css("visibility", "visible");				
				if ($panel.css("display") == "none") $panel.css("display",'');
				
				$panel.animate( 
								{height: defaults.height}, 
								{duration:1000} 
							  );  
			} else  {
				// Loading is performed WHEN the slideDown action "loads" content
				$panel.slideDown("slow");	
				
				var elemID = defaults.autoFocus ? defaults.autoFocus : "";
				if (elemID != '') setTimeout(function(){ $(elemID).focus(); }, 1200);
			}
			return false;	
		};		
		var $collapseFunc = function() {	
			if ( defaults.preload ) {
				$panel.animate(
					{height: "0px"}, 
					{
						duration:1000,
						complete:function() {
							// When done animating, hide it!
							$panel.css("visibility", "hidden");
						}
					});  
			} else  {
				$panel.slideUp("slow");		
			}
			return false;	
		};
		var $toggleFunc   = function() {	
			$btnToggle.toggle();		
			return false;	
		};
		
		// Assign click handlers
		
		$btnOpen.click  ( $expandFunc   );
		$btnClose.click ( $collapseFunc );
		$btnToggle.click( $toggleFunc   );
				
		// Now change the panel CSS settings [if needed] to force
		// preloading offscreen. 
		// !!Important for Flash SWFs
			
		defaults.preload |= ($panel.css("display") != "none");		
		if ( defaults.preload ) {	
							
			defaults.height  = !params.height ? $panel.css("height") : params.height;

			$panel.css( "height",     0        );
			$panel.css( "visibility", "hidden" );
			$panel.css( "display",    "block"  );			
		}
		
	};
	
})(jQuery);