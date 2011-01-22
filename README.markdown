This repository contains sample code that demonstrates super easy, custom slideshows using GAIA. Deployed use of the repository can be seen at [Insertables Smart Forms](http://www.insertables.com). This repository also contains [customized extensions] for the [Gaia Framework](http://www.gaiaflashframework.com/).

### Summary 

The Gaia framework provides loading mechanisms, caching, preloader, and slide transitions, deeplinking, SEO, and context menu for global navigations for rich content. Developers and designers can create individual, complex slides with Flash CS then quickly build a slide show with this framework. Slides can be simple content such as images or complex slides with LARGE content and complex internal interactions. 

### Outline

This repository contains the FlashBuilder project along with the Flash CS5 FLA files. 

* Custom slide content is constructed in the *./slides/slides<xxx>.fla* master files... output is in *./deploy/assets/slides* [no Document classes]

* Custom preloader is defined *./lib/preload.fla* [Docment class is 'pages.Preloader']

* The slide container is defined by *./lib/slides.fla* [Document class is 'ext.gaiaframework.templates.SlidePage']

* *Main.as* class is compiled and deployed by the Flashbuilder IDE and provides debugging and iterative compiles for developers.  

* Greensock library that provides TweenLite and TweenMax for Gaia transitions

* Gaia core framework

### Custom Extensions 

Custom extensions include the:

- [SlidePage](https://github.com/ThomasBurleson/Gaia-Framework-Extensions/blob/master/src/ext/gaiaframework/templates/SlidePage.as):  Document class used to build *slides.fla*; has AS3 logic to manage slide content.
- [PageFlow](ext.gaiaframework.slides.*):  Singleton class used to parse site.xml to determine slide workflow.
- [ContentCenterer](ext.gaiaframework.behaviors.*):  Behavior class used to auto center slide content (if desired)
- [TimeLinkHooks](ext.gaiaframework.behaviors.*):  Behavior class used to inject framescripts in SWF slides (used for Gaia transitions)

### History:

- 12/26/2010: Initial check-in


## Open-Source License

Code is released under a BSD License:
http://www.opensource.org/licenses/bsd-license.php

Copyright (c) 2008, Adobe Systems Incorporated
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.