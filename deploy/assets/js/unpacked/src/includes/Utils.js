/**
 * Convenience method for tokenized replacements ();
 * provided by David Crockford @ http://javascript.crockford.com/remedial.html
 */
(function () {
    if ( !String.prototype.supplant ) {

        // Make sure the supplant() method is available!
        // Now supports dot notation for complex object value substitutions
        // e.e.   {foo.boo.moo.uff  ...}

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