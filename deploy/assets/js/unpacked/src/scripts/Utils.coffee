# Make sure the supplant() method is available!
# Now supports dot notation for complex object value substitutions
# e.e.   {foo.boo.moo.uff  ...}

String::supplant = (o) ->
    this.replace  /\{([^{}]*)\}/g, (a, b) ->
            p = b.split('.')
            r = o

            # Descend the property chain "b" to resolve the end-chain value
            try 
                for own s of p  
                    r = r[p[s]]
             catch e 
                r = a

             return if (r is 'string') or (r is 'number') then r else a
             # return `(r === 'string') || (r ==='number') ? r : a`