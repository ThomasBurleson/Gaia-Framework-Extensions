# Namespace 'thunderbay.services'

Insertables :

    class Insertable    
        
        # --------------------------------------------------------------
        # Public Methods
        # --------------------------------------------------------------
    
        @post: (data, callback, url, locale) ->            
            if !callback? then url ?= callback                  
            url ?= 'http://tinyurl.com/28lddou'

            data = @buildData(data, locale)
        
            log(data)
            callback.apply(jQuery,[])
                        
            this

            # Given a DOM container element, find all the input
         # elements and build a map of the id/value pairs.
         #
         # @param elemID    String ID for the DOM element container
         # @result          Hashmap of all input field values
         
        @parseFormInputs : (elemID) ->
            results = { }
            jQuery(elemID).find('input').each (i, el) => 
                  if el? then results[el.name] = jQuery(el).val()                    
                
            results


        constructor : (global) ->
            jQuery = global
            
            # --------------------------------------------------------------
            # Public Properties
            # --------------------------------------------------------------
            
            # @someValue
            
            
            # --------------------------------------------------------------
            # Privileged Methods (accessible from public methods, access to private)
            # --------------------------------------------------------------
            
            # Given datasource 'fields' build an XML structure of all the fields;
            # where each field is represented in the format: <field name="">fieldValue</field> 
            #
            # NOTE: this method is called internally by post()
            #
            # @param fields    DOM element ID, callback function, or HashMap
            # @result          XML string representation expected by Insertables

            @buildData = (fields, locale = 'en_US') ->
                fields  = if (typeof fields is 'string') 
                            this.parseFormInputs(fields)
                          else 
                            if fields? then fields() else fields
                
                data = this.convert2JSON(fields)
                data.locale ?= 'en_US'
                
            #    templates = [
            #                 "<fields accountID='{accountID}' formID='{formID}' locale='{locale}'>",
            #                 "<field name='{id}'><![CDATA[{value}]]\></field>",
            #                 "</fields>"
            #                ]
                            
                results = "<fields accountID='#{data.accountID}' formID='#{data.formID}' locale='#{data.locale}'>"      # String(templates[0]).supplant(data)
                for it in data.fields
                    results += "<field name='#{it.id}'><![CDATA[ #{it.value} ]]\></field>"                              #  String(templates[1]).supplant(it)
                results += "</fields>"                                                                                  #  templates[2];
                
                results;

                  
            # --------------------------------------------------------------
            # Private Methods
            # --------------------------------------------------------------

            # Given a flat hashmap  of fields, convert to object of expected format
            # This object will be used with "supplant()" to quickly build formatted XML-string
            # output.                
            
            convert2JSON : (fields) ->
                results = { formID:"", accountID:"",  fields : [ ] }
                for key in fields
                    if (fields.hasOwnProperty(key))
                        switch key
                            when "formID"    then results.formID = fields[key]
                            when "accountID" then results.accountID = fields[key]
                            else
                                results.fields.push({ id : key, value : fields[key] })
                return results

            # --------------------------------------------------------------
            # Private properties
            # --------------------------------------------------------------
            
            jQuery = null
