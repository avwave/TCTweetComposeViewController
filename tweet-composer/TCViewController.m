//
//  TCViewController.m
//  tweet-composer
//
//  Created by Philip Dow on 7/29/12.
//  Copyright (c) 2012 Philip Dow. All rights reserved.
//

#import "TCViewController.h"
#import "TCTweetComposeViewController.h"

@interface TCViewController ()

@end

@implementation TCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)sendTweet:(id)sender
{
    if (![TCTweetComposeViewController canSendTweet]) {
        NSLog(@"Cannot send tweets, no account set up");
        return;
    }
    
    TCTweetComposeViewController *twitter = [[TCTweetComposeViewController alloc] initComposer];
    [twitter addURL:[NSURL URLWithString:@"http://compass.getsprouted.com/newsletter"]];
    //[twitter addImage:[UIImage imageNamed:@"Icon.png"]];
    
    twitter.completionHandler = ^(TCTweetComposeViewControllerResult result) {
        [self dismissModalViewControllerAnimated:YES];
    };
    
    [self presentModalViewController:twitter animated:YES];
}

@end
