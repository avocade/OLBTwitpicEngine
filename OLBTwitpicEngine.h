//
// OLBTwitpicEngine.h
// ----------------------------------------------------------------------
// Controller class for uploading a UIImage to TwitPic.com and post to Twitter.com.
// This procedure automatically posts to the Twitter account specified.
//
// License
// ----------------------------------------------------------------------
// This code is offered under the MIT License.
//
// Copyright (c) 2008-2012 Oskar Boethius Lissheim (@avocade on Twitter)
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// ----------------------------------------------------------------------

#import <UIKit/UIKit.h>

@protocol OLBTwitpicEngineDelegate;

#define kTwitpicMessage @"twitpicMessage"
#define kTwitpicMessageDefault @"Here's my new image (made on my iPhone):"

@interface OLBTwitpicEngine : NSObject <UITextViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	@private
	id<OLBTwitpicEngineDelegate> delegate;
	UIImage *_imageToSend;
	UITextField *_twitterMsgTextField;
}

@property (retain) UIImage *imageToSend;
@property (retain) UITextField *twitterMsgTextField;

+ (OLBTwitpicEngine *)sharedOLBTwitpicEngine;
- (BOOL)uploadImageToTwitpic:(UIImage *)image withMessage:(NSString *)theMessage username:(NSString *)username password:(NSString *)password;
- (void)presentTwitterMsgAlertWithImage:(UIImage *)theImage delegate:(id)theDelegate;

@end

@protocol OLBTwitpicEngineDelegate <NSObject>
- (void)twitpicEngine:(OLBTwitpicEngine *)engine didUploadImageWithResponse:(NSString *)response;
- (void)twitpicEngine:(OLBTwitpicEngine *)engine showTwitpicUploadActivityIndicator:(BOOL)showActivityIndicator;
@end

