
/**
 * Configure Spritely jQuery animations and Flash FeatureTour.
 */
 
(function (window, $) {

    window.animations = {
    
        start : function () {
            // Start the header animation and inject the Flash SWF                
            this.featureTour.init();
            this.sprites.init();    
                    
             // When Browser resizes, call the sprites.resize() function
             // Then immediate trigger to force update             
            $(window).resize( this.resize );
            window.animations.resize();   
                    
            return this;            
        },
        
        /**
         * During browser resize, position the Insertables title
         * and absolute position the Flash tour
         *
         */
        resize: function () {            
            var stageW  = $(window).width(),
                stageH  = $(window).height(),
                imgW    = 387,
                rPad    = 0,
                offsetY = (stageH - 375) / 2,
                offsetX = (stageW - 700) / 2;
            
            // Stick the title to the upper-right corner
            $("#title")
                .css('background-position', (stageW - imgW - rPad)  + 'px 50px')
                .css('visibility', 'visible');
            
            // Should we reposition the tour ?    
            // Align to integer pixels for best transparent rendering
            if ($("#tour").length) {
                
                $("#tour")
                  .css('position', 'absolute')
                  .css( { "left": Math.floor(offsetX) + "px", "top":Math.floor(offsetY)  + "px", "z-index":300  } );                        
            }
        },  
        
        // **********************************************************************
        //  Grouped functionality for sprites, featureTour, and validators
        // **********************************************************************
        
        sprites: {
                                    
            init: function () {
                
                $('#land')          .pan({fps: 12, speed: 0.2, dir: 'left', depth: 10 });                    
                $('#cloudMiddle')   .pan({fps: 12, speed: 0.15, dir: 'left', depth: 30 });
                $('#cloudBottom')   .pan({fps: 12, speed: 0.3,  dir: 'left', depth: 70 });
                
                var $target = $('#spout');
                $target                    
                    .css('visibility', 'visible')
                    .animate({ 
                                left : "75px",
                                opacity: "1.0"
                             }, 
                             { 
                                duration : 1000,
                                complete : function() {
                                      $target
                                        .pan({fps: 12, speed: 0.35, dir: 'right', depth: 50, constrained: { left:75, right:250 } })
                                        .active();                                        
                                    }
                             });
                             
                // Clicks/taps on any these elements cause the WaterSpout to animate/jump
                $('#stage').flyToTap({
                                        xOnly      : true, 
                                        el_to_move : $target
                                    });                             
            }
        },
        
        featureTour : {
            
            init : function () {
                /**
                 * Configure SWFObject for Flash injection
                 */
                var params = {
                    allowscriptaccess: "always",
                    allownetworking:"all",
                    quality : "high",
                    scale   : "noscale",
                    wmode   : "transparent",
                    bgcolor : "#424242"
                },
                flashvars = {
                    siteXML : "assets/xml/site.xml"
                },
                attributes = {
                    id      : "flashcontent",
                    name    : "flashcontent"
                };
                
                window.swfobject.embedSWF(  "assets/featureTour.swf", "flashcontent", 
                                            "700", "400", "10.0.0", 
                                            "http://cdn.insertables.com/expressInstall.swf", 
                                            flashvars, params, attributes);                
            }
        }
    };
    
    window.validations = {
            
            start : function () {
                // Set validation to fire on focusOut (blur) and wrap the input
                // fields in divs so the valid/invalid icon can be added...
                $("#txtUsername").blur(this.validateField);
                $("#txtEmail").blur(this.validateField);
                
                this.wrapField( "#txtEmail" );
                this.wrapField( "#txtUsername" );
                
                // inject new tooltip component and "connect" as shared tooltip to the images 
                $("#registration_form").append("<div id='tooltip' class='tooltip' style='display: none; visibility: visible; position: absolute; left:0px, top:0px;'></div>");                    
                $("validation_status").tooltip({
                                        tip     : "#tooltip",
                                        position: "center right", 
                                        opacity : 0.2,
                                        delay   : 0
                                    });
            },
            
            getFieldValues : function () {
                return { 
                        formID   : $("input#formID").val(),                     // NOTE: that the formID is required for Insertables
                           
                        username : $("input#txtUsername").val().toUpperCase(),
                        email    : $("input#txtEmail").val()
                       };      
            },
            
            wrapField : function (target) {                
        		// Create wrapper div so the image icon can be easily added/changed
        		// Then inject a HIDDEN image status element 
        		var elem  = "<div id='{id}_wrapper'></div>".supplant( {id : $(target).attr('id')} );        		
        		var divID = "#{id}_wrapper".supplant( {id : $(target).attr('id')} );        	
        		
        		$(target).wrap ( elem );
        		$(divID)
        		    .append ("<image id='validation_status' class='validation_status' src='http://cdn.insertables.com/images/slideBox/input_invalid.gif' style='display:none;' />")
        		    .find("#validation_status")
        		    .each( function(i,el){
        		          // Attach click handlers 
                          if (el && (el.id !== "")) {
                              $(el).click( function (ev) {
                                 // Hide the status icon and clear the text input field invalidation
                                 var $target = $(ev.currentTarget);                                 
                                 $target
                                    .parent().find("input").each( 
                                        function (i,field) {
                                            $(field).removeClass().addClass('field');
                                        });
                                 $target.fadeOut('slow');
                              });
                          }
                      });
        		

            },
            
            // Define validation to be used by BOTH the validation engine 
            // AND the submit process!
            validate : function () {
                var f1Valid = this.validateField($("#txtUsername"),false);
                var f2Valid = this.validateField($("#txtEmail"),false);
                var results = ( f1Valid && f2Valid );
                
                if (results == true) {
                    $('#prompt').hide();
                } 
                else {
                    var error  = "<p style='text-align:center; font-size:0.9em;'><span style='color:#FF0000;' >Error: </span>";
                        error += "<span style='color:#F8DCDB;'> All fields are required for proper Registration!</span><p>";
                        
                    $('#prompt')
                        .html( error )
                        .show();
                }
                
                return results;
            },
            
            validateField : function (context, forceValid) {
                if (typeof forceValid === "undefined") forceValid= true;
                
                var isValid      = true,        
                    txtToolTip   = "",
                    elem         = context.hasOwnProperty("currentTarget") ? $(context.currentTarget) : context,
                    skip         = forceValid && (elem.val() == "");
                
                    
                switch (elem.attr('id')) {
                    case "formID"     :         // should be a UUID
                    case "txtUsername":         // use a 'non-blank' expression
                        isValid = /\S+/.test(elem.val());   
                        txtToolTip = isValid ? "Accepted" : "Firstname and lastname are both required.";
                        break;                        
                    case "txtEmail"   :         // validate with an eMail expression                                             
                        isValid = /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test(elem.val());
                        txtToolTip = isValid ? "Accepted" : "A valid e-mail address is required.";
                        break;
                    default           :  
                        return false; 
                }
                
                // Update the image source and show it!
                elem.parent().find("#validation_status")
                    .each( 
                           function(i,el){
                              if (el && (el.id !== "")) {
                                  var pattern = isValid ? "input_invalid.gif" : "input_valid.gif";
                                  var val     = isValid ? "input_valid.gif"   : "input_invalid.gif";
                                  
                                  var src     = $(el).attr("src").replace(pattern,val);
                                  
                                  if (forceValid && skip) {
                                      $(el).hide();
                                  }
                                  else {
                                      $(el)
                                        .attr({
                                             "src"    : src,
                                             "display": ""
                                             })
                                        .show();
                                }
                                    
                              }
                           });

                if (skip == true) {

                    // Update the text shown in the tooltip area...
                    $('#registration_form #tooltip').html( txtToolTip );
                
                    // Clear the prompt area
                    // Update the CSS class attribute; defined in slideBox.css
                    if (isValid == true) {
                       $('#prompt').replaceWith( $("<label id='prompt'><br/></label>") );
                    }
                }
                
                elem.removeClass().addClass((isValid || (forceValid && skip)) ? 'field' : 'field_invalid');
               
               return isValid; 
            }               
             
    };
    
}(window, window.$));


