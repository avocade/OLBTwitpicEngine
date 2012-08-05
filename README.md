OLBTwitpicEngine
================

### A Twitter relic from ye olde iOS 2.0 days

OLBTwitpicEngine is a simple controller class for uploading a UIImage to TwitPic.com and post
a message containing it to Twitter.

Legacy
------

This class was created back in 2008 when the iPhone was new and hot,
and Twitter apps -- and especially Twitter frameworks -- were nonexistent.
Though I haven't used this class for a few years, my strong feeling is that it won't
work at all partly due to Twitter's full switch to `OAuth2` (which is great), which this code doesn't
support.

Of course nowadays you wouldn't want to use classes like this at all. The built-in `Twitter.framework`
in iOS 5+ is what's fresh, and uses Twitter's own image hosting
service. (TwitPic was the hot thing back then, believe you me.) This class is merely offered for
historical curiosity.

**Disclaimer**: This code reflects a tiny part of my output mid-2008, when I was a
few months in to using the Cocoa Touch frameworks. It
hasn't been changed since then--apart from being somewhat cleaned up for presentation--and doesn't
have much of the structure or API usage I would utilize today.
Please don't hold it against me :)

Usage
-----

1. Import the `OLBTwitpicEngine.h` header file into your controller class.

1. Download and import the `RegexKitLite` library and its
dependencies ([get it here](ttp://regexkit.sourceforge.net/RegexKitLite/)).
It's used for parsing the TwitPic post URL from the XML response we get back.

1. Get and import the singleton macro from
[Cocoa with love](http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html).
This is a simple macro for generating a single version of the
OLBTwitpicEngine object to be shared.

1. Set the `delegate` in your Controller and implement the `OLBTwitpicEngineDelegate` protocol.

1. Call the `uploadImageToTwitpic:withMessage:username:password:` method and
send along the `UIImage`, the user's Twitter `username` and `password`, as well as
the `message` text to post alongside the TwitPic link in the final tweet.

1. Respond to the `delegate` method callback when the thread is done uploading (or has failed doing so).

1. Profit!

License
-------

This code is offered under the MIT License.

Copyright (c) 2008-2012 Oskar Boethius Lissheim ([@avocade](http:/twitter.com/avocade) on Twitter).

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

