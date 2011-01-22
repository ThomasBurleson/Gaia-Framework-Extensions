/**
 * Convenience method for tokenized replacements ();
 * provided by David Crockford @ http://javascript.crockford.com/remedial.html
 */
 /*
(function () {
    if ( !String.prototype.supplant ) {

        // Make sure the supplant() method is available!
        // Now supports dot notation for complex object value substitutions
        // e.e.   {foo.boo.moo.uff  ...}
        var _hasProp = Object.prototype.hasOwnProperty; 
        
        String.prototype.supplant = function (o) {
            return this.replace( /\{([^{}]*)\}/g,
                                 function(a, b) {
                                    var p = b.split('.'),
                                        r = o;

                                    // Descend the property chain "b" to resolve the end-chain value
                                    try {
                                        for (var s in p) {
                                            if (_hasProp.call(p,s)) {
                                                r = r[p[s]]; 
                                            }
                                        }
                                    }
                                    catch (e) { r = a; }

                                    return (typeof r === 'string' || typeof r === 'number') ? r : a;
                                });
        };
    }
}());
*/
            
(function (global, undefined) {
    
    var UNDEFINED    = "undefined",
        OBJECT       = "object";

    if (typeof global.insertables      === UNDEFINED)   { global.insertables = {};  }
    if (typeof global.insertables.post !== UNDEFINED)   { return;                   }    // Insertables already defined, so quit
        
    var insertables = (function () {
        var jQuery              = global.$;                             // cache alias reference to jQuery

        if ( !jQuery ) return false;        // jQuery (1.3.2 or greater) must ALREADY be loaded !!!       

        var defaultURL_POST     = "http://tinyurl.com/28lddou";         // tinyURL( http://insertables.strakersoftware.com/insertables/app_templates/objects/remotegateway/flexFormDataSubmission.cfm )            
        var Insertables         = { 
                                    jQuery:global.$,                    // cache alias reference to jQuery 
                                    _domain:global.document.domain      // Use the correct document accordingly with window argument (sandbox) 
                                  };
                
        // ************************************************************************
        // Define methods post() method to convert data fields to xml and submit
        // to an Insertables server. The 'success' callback function can be defined explicitly or as part of the
        // the data object.
        // ************************************************************************    
        
        Insertables.fn = Insertables.prototype = {
            
            jQuery: global.$,
                
            /**
             * Post the datasource 'data; to the Insertables persistent storage. This
             * allows HTML forms to be posted to the Insertables site.
             *
             * @param data      Datasoure (string, function, object) that represents the form fields to be posted
             * @param callback  Function that will be invoked upon "successful" completion of the post (may be null)
             * @param url       String URL that will be used to HTTP POST (if NULL, then defaultURL_POST will be used)
             */
            post: function (data, callback, url, locale) {  
                var jQuery = this.jQuery;
                                              
                // Callback could be an attribute of data; e.g. data == { success:function(){} }
                // Assign default URL if needed..                    
                if ( !jQuery.isFunction(callback) ) {                    
                    url = url || callback;                    
                }
                url = url || defaultURL_POST;  
                 
                // Assign the callback func from the "success" method passed in the data
                if (!callback && (typeof data === "object") && data.hasOwnProperty("success")) {
                    callback = data.success;
                }
                
                
                data = this.buildSubmitData( data, locale );
                //global.console.log("Insertables.post( "+data+ " )" );
                
                // @FIXME: Get the Cross-domain posting to work; for now simulate a response
                callback();                  
                return jQuery;                                
                
                // Use jQuery to post the XML string asynchronously...
                //return jQuery.post( url, buildSubmitData_JSON(data,locale || 'en_US'), callback, "json" );
            },
           
            /**
             * Given datasource 'fields' build an XML structure of all the fields;
             * where each field is represented in the format: <field name="">fieldValue</field> 
             *
             * NOTE: this method is called internally by post()
             *
             * @param fields    DOM element ID, callback function, or HashMap
             * @result          XML string representation expected by Insertables
             */

            buildSubmitData : function (fields, locale) {                  
                // Get associative ARRAY of all input fields + required fields (accountID, formID)
                
                fields          = (typeof fields === 'string')  ? this.parseFormInputs(fields)    :
                                  jQuery.isFunction(fields)     ? fields()                        : fields;
                                  
                var data        = this.convert2JSON( fields  );
                    data.locale = locale || "en_US";
                
                //  Cannot use E4X solution since it is NOT Compatible with Google Chrome or IE Browsers; 
                var templates = [
                                    "<fields accountID='{accountID}' formID='{formID}' locale='{locale}'>",
                                    "<field name='{id}'><![CDATA[{value}]]\></field>",
                                    "</fields>"
                                ];

                // Build the XML string representation expected!
                var results = String(templates[0]).supplant(data);
                    for (var j=0;j<data.fields.length;j++) {
                        results += String(templates[1]).supplant( data.fields[j] );                     
                    }
                    results += String(templates[2]); 
                
                return results;
            },
                       
            /**
              * Given a flat hashmap  of fields, convert to object of expected format
              * This object will be used with "supplant()" to quickly build formatted XML-string
              * output.
              */
             convert2JSON : function (fields) {
                 var results = { formID:"", accountID:"",  fields : [ ] };

                 for (var key in fields) {
                     if (fields.hasOwnProperty(key)) {
                       switch (key){
                           case "formID"    :   
                               results.formID = fields[key];      
                               break;
                           case "accountID" :   
                               results.accountID = fields[key];     
                               break;
                           default          :
                               results.fields.push({
                                                     id : key, 
                                                     value : fields[key]
                                                   });
                               break;
                       }                    
                   }
                 }                

                 return results;
             },

             /**
             * Given a DOM container element, find all the input
             * elements and build a map of the id/value pairs.
             *
             * @param elemID    String ID for the DOM element container
             * @result          Hashmap of all input field values
             */
             
            parseFormInputs : function (elemID) {
                var results = { };

                   jQuery(elemID)
                       .find("input")
                       .each( 
                           function(i,el){
                              if (el && (el.id !== "")) {
                                  results[el.name] = $(el).val(); 
                              }
                           });
            
                return results;
            }        
        };    
        
        // Make sure the Cross-Domain AJAX features are loaded!
        // NOTE: Requires FLASH so may not work on mobile devices
        // See http://flxhr.flensed.com/
        (function () {
            if ( !jQuery.flXHRproxy ) {
                //jQuery.getScript("http://cdn.insertables.com/js/xdomain/flXHR.js");

                // NOTE: below is only needed when developer wants to associate a particular set of 
                //       flXHR options with a specific unique URL (or partial URL)
                //       Also requires the jQuery XHR Registry Plugin @ http://plugins.jquery.com/project/XHR
                // jQuery.geScript("http://cdn.insertables.com/js/xdomain/jquery.flXHRproxy.js");
            }
        }());

            
        // Expose insertables "instance" to the global object
        return (global.insertables = global.$insertables = Insertables);
    }());
      
})(window);
