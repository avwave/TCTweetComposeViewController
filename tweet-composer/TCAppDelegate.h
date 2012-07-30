//
//  TCAppDelegate.h
//  tweet-composer
//
//  Created by Philip Dow on 7/29/12.
//  Copyright (c) 2012 Philip Dow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCViewController;

@interface TCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TCViewController *viewController;

@end
