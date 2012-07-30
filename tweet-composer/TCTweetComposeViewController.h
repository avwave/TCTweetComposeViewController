//
//  TCTweetComposeViewController.h
//  tweet-composer
//
//  Created by Philip Dow on 7/29/12.
//  Copyright (c) 2012 Philip Dow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

enum TCTweetComposeViewControllerResult {
   TCTweetComposeViewControllerResultCancelled,
   TCTweetComposeViewControllerResultDone
};
typedef enum TCTweetComposeViewControllerResult TCTweetComposeViewControllerResult;

typedef void (^TCTweetComposeViewControllerCompletionHandler)(TCTweetComposeViewControllerResult result);

@interface TCTweetComposeViewController : UINavigationController

@property (nonatomic,copy) TCTweetComposeViewControllerCompletionHandler completionHandler;

/*  Returns NO if no Twitter accounts have been set up or if access to the Twitter
    API has been denied or turned off for this application
*/

+ (BOOL)canSendTweet;

/*  Use initComposer instead of init
    Avoids some weird internal infinite recursion loop when using init
*/

- (id) initComposer;

/*  The following methods must be called prior to showing the tweet composer
    From the documentation:
    Although you may perform Twitter requests on behalf of the user, you cannot append text, images, or URLs to tweets without the user’s knowledge. Hence, you can set the initial text and other content before presenting the tweet to the user but cannot change the tweet after the user views it. All of the methods used to set the content of the tweet return a Boolean value. The methods return NO if the content doesn’t fit in the tweet or if the view was already presented to the user and the tweet can no longer be changed.
*/

/*  It is only possible to add a single image at this time, and the method will
    return NO if you attempt to add more than one.
*/

- (BOOL)setInitialText:(NSString *)text;
- (BOOL)addImage:(UIImage *)image;
- (BOOL)addURL:(NSURL *)url;

- (BOOL)removeAllImages;
- (BOOL)removeAllURLs;

@end
