# TCTweetComposeViewController

## Overview

TCTweetComposeViewController is a drop in replacement for TWTweetComposeViewController. There are a number of problems with the built in tweet composer:

- It is ugly
- It does not preview links
- It's just so damn ugly

TCTweetComposeViewController solves the main problem by emulating the clean interface of the built in email message composer while preserving the functionality of the built in tweet composer.

Because it is a drop in replacement, it is easy to add it to an existing project and it will be simple to remove if the built in tweet composer later changes.

## Usage

All you need to do is change the view controller class and the type on the completion handler, or replace TW with TC. That's it.

Built in code looks like this in your app:

	TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
	[twitter addImage:icon];
	[twitter addURL:URL];
	[twitter setInitialText:text];
	twitter.completionHandler = ^(TWTweetComposeViewControllerResult result){
		[self dismissModalViewControllerAnimated:YES];
	};
	[self presentModalViewController:twitter animated:YES];

Our drop in replacement code looks like this:

	TCTweetComposeViewController *twitter = [[TCTweetComposeViewController alloc] init];
	[twitter addImage:icon];
	[twitter addURL:URL];
	[twitter setInitialText:text];
	twitter.completionHandler = ^(TCTweetComposeViewControllerResult result){
		[self dismissModalViewControllerAnimated:YES];
	};
	[self presentModalViewController:twitter animated:YES];

## Limitations

- Only supports Portrait orientation
- Only works on the iPhone. Might work on iPad, hasn't been tested
- Only supports a single image upload at a time
- Does not support optional location data

These limitations are probably temporary and could be fixed with a bit more coding.

## License

BSD style license

Copyright (C) 2012 Philip Dow / Sprouted. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.