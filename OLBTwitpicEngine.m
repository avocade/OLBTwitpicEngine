//
// OLBTwitpicEngine.m
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

#import "OLBTwitpicEngine.h"
#import "RegexKitLite.h"
#import "SynthesizeSingleton.h"

enum SendToTwitterAlertButtons {
	SendToTwitterAlertButton_Cancel = 0,
	SendToTwitterAlertButton_Send,
};

#define kTwitpicUploadURL @"https://twitpic.com/api/uploadAndPost"  // Note: This URL automatically posts to Twitter on upload
#define kTwitpicImageJPEGCompression 0.7  // Between 0.1 and 1.0, where 1.0 is the highest quality JPEG compression setting

@implementation OLBTwitpicEngine

@synthesize imageToSend = _imageToSend;
@synthesize twitterMsgTextField = _twitterMsgTextField;

SYNTHESIZE_SINGLETON_FOR_CLASS(OLBTwitpicEngine);  // Get this singleton-creation class from cocoawithlove.com

#pragma mark -
#pragma mark Show UIAlertView to input twitter message

- (void)presentTwitterMsgAlertWithImage:(UIImage *)theImage delegate:(id)theDelegate
{
	UIAlertView *alert = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	UITextField *emailTextField = nil;
	CGRect aRect;
	NSLog(@"presentAddTwitterMsgAlert");

	// Add delegate
	delegate = theDelegate;

	// Save the image to send
	self.imageToSend = theImage;

	// Standard error presentation (only OK button)
	alert = [[[UIAlertView alloc] initWithTitle:@"Send to Twitter"
										message:@"Add a Tweet message:\n\n\nNote: The image will be posted to Twitter via TwitPic."
									   delegate:self
							  cancelButtonTitle:@"Cancel"
							  otherButtonTitles:@"Send", nil ] autorelease];

	// Add text field
	aRect = CGRectMake(20, 75, 242, 22);
	emailTextField = [[[UITextField alloc] initWithFrame:aRect] autorelease];
	emailTextField.font = [UIFont boldSystemFontOfSize:16.0];
	emailTextField.backgroundColor = [UIColor whiteColor];
	emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	emailTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
	emailTextField.delegate = self;

	// Add as ivar
	self.twitterMsgTextField = emailTextField;

	// Set text from defaults
	emailTextField.text = [defaults valueForKey:kTwitpicMessage];

	// Add subview
	[alert addSubview:emailTextField];

	// Present alert
	[alert show];
}

#pragma mark TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	// From showUserEmailOnServerAlert
}

#pragma mark UIAlertview delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"alertView:clickedButtonAtIndex: %i", buttonIndex);
	NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *message = nil;
	NSString *username = nil;
	NSString *password = nil;

	if ([alertView.title isEqualToString:@"Send to Twitter"] )
	{
		if ([buttonTitle isEqualToString:@"Send"] )
		{
			// Set message, username and password from defaults
			//   otherwise throw up error
			username = [defaults stringForKey:@"twitpicUsername"];
			password = [defaults stringForKey:@"twitpicPassword"];

			if (username && password)
			{
				// Add in the loading indicator in place of the button
				[delegate twitpicEngine:self showTwitpicUploadActivityIndicator:YES];

				// Get the message from the textfield
				message = self.twitterMsgTextField.text;

				// Create OLBTwitpicEngine object with userCredentials dictionary and delegate to self
				[[OLBTwitpicEngine sharedOLBTwitpicEngine] uploadImageToTwitpic:self.imageToSend withMessage:message
																	   username:username password:password];
			}
			else
			{
				// Show UIAlertView, need to set username and password in Settings
				alertView = [[[UIAlertView alloc] initWithTitle:@"Couldn't Send to Twitter" message:@"Please enter a valid Twitter username and password in the Light Table Settings."
													   delegate:self cancelButtonTitle:@"I'll check"
											  otherButtonTitles:nil] autorelease];
				[alertView show];
			}
		}
	}
}

#pragma mark -
#pragma mark Send image to twitpic

- (void)uploadingDataWithURLRequest:(NSURLRequest *)urlRequest
{
	// Called on a separate thread; upload and handle server response
	NSHTTPURLResponse *urlResponse = nil;
	NSError			  *error = nil;
	NSString		  *responseString = nil;
	NSData			  *responseData = nil;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];		// Each thread must have its own NSAutoreleasePool

	[urlRequest retain];  // Retain since we autoreleased it before

	// Send the request
	urlResponse = nil;
	responseData = [NSURLConnection sendSynchronousRequest:urlRequest
										 returningResponse:&urlResponse
													 error:&error];
	responseString = [[NSString alloc] initWithData:responseData
										   encoding:NSUTF8StringEncoding];

	// Handle the error or success
	// If error, create error message and throw up UIAlertView
	NSLog(@"Response Code: %d", [urlResponse statusCode]);
	if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
	{
		NSLog(@"urlResultString: %@", responseString);

		NSString *match = [responseString stringByMatching:@"http[a-zA-Z0-9.:/]*"];  // Match the URL for the twitpic.com post
		NSLog(@"match: %@", match);

		// Send back notice to delegate
		[delegate twitpicEngine:self didUploadImageWithResponse:match];
	}
	else
	{
		NSLog(@"Error while uploading, got 400 error back or no response at all: %@", [urlResponse statusCode]);
		[delegate twitpicEngine:self didUploadImageWithResponse:nil];  // Nil should mean "upload failed" to the delegate
	}

	[pool release];
	[responseString release];
	[urlRequest release];
}

- (BOOL)uploadImageToTwitpic:(UIImage *)image withMessage:(NSString *)theMessage
					username:(NSString *)username password:(NSString *)password
{
	NSString			*stringBoundary, *contentType, *message, *baseURLString, *urlString;
	NSData				*imageData = nil;
	NSURL				*url = nil;
	NSMutableURLRequest *urlRequest = nil;
	NSMutableData		*postBody = nil;

	// Create POST request from message, imageData, username and password
	baseURLString	= kTwitpicUploadURL;
	urlString		= [NSString stringWithFormat:@"%@", baseURLString];
	url				= [NSURL URLWithString:urlString];
	urlRequest		= [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"POST"];

	// Set the params
	message		  = ([theMessage length] > 1) ? theMessage : kTwitpicMessageDefault;
	imageData	  = UIImageJPEGRepresentation(image, kTwitpicImageJPEGCompression);

	// Setup POST body
	stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	contentType    = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
	[urlRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];

	// Setting up the POST request's multipart/form-data body
	postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"source\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"lighttable"] dataUsingEncoding:NSUTF8StringEncoding]];  // So Light Table show up as source in Twitter post

	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:username] dataUsingEncoding:NSUTF8StringEncoding]];  // username

	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:password] dataUsingEncoding:NSUTF8StringEncoding]];  // password

	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:message] dataUsingEncoding:NSUTF8StringEncoding]];  // message

	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media\"; filename=\"%@\"\r\n", @"lighttable_twitpic_image.jpg" ] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/jpg\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];  // jpeg as data
	[postBody appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:imageData];  // Tack on the imageData to the end

	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[urlRequest setHTTPBody:postBody];

	// Spawn a new thread so the UI isn't blocked while we're uploading the image
  [NSThread detachNewThreadSelector:@selector(uploadingDataWithURLRequest:) toTarget:self withObject:urlRequest];

	return YES;  // TODO: Should raise exception on error
}

#pragma mark -
#pragma mark Misc

- (void)dealloc
{
	self.twitterMsgTextField = nil;
	self.imageToSend = nil;

  [super dealloc];
}

@end

