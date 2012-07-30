//
//  TCTweetComposeViewController.m
//  tweet-composer
//
//  Created by Philip Dow on 7/29/12.
//  Copyright (c) 2012 Philip Dow. All rights reserved.
//

#import "TCTweetComposeViewController.h"

@interface TWTeetComposeRootViewController : UIViewController

// placeholder

@end

#pragma mark -

@interface TCTweetComposeViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
    // interface
    UITableViewCell *_accountCell;
    UITableViewCell *_messageCell;
    UIViewController *_controller;
    UITableView *_tableView;
    UIPickerView *_pickerView;
    
    // account
    ACAccountStore *_accountStore;
    NSArray *_accounts;
    NSInteger _selectedAccount;
    
    // tweet
    NSMutableArray *_images;
    NSMutableArray *_URLs;
    
    BOOL _isPresented;
    BOOL _sending;
}

- (UIViewController*) initializedRootViewController;
- (UITableViewCell*) accountCell;
- (UITableViewCell*) messageCell;

- (void) updateCharacterCount;
- (void) setImageViewHidden:(BOOL)hidden;

- (void) twitterAccounts:(void(^)(NSArray *accounts, NSError *error))handler;
- (void) performTwitterRequest:(TWRequest*)request;
- (void) postStatusUpdateWithMedia;
- (void) postStatusUpdate;

@end

#pragma mark -

@implementation TCTweetComposeViewController

+ (BOOL) canSendTweet
{
    // which seems to have access to underlying account info without having to
    // actually request access to it
    return [TWTweetComposeViewController canSendTweet];
}

- (id) initComposer
{
    return [super initWithRootViewController:[self initializedRootViewController]];
}

- (UIViewController*) initializedRootViewController
{
    TWTeetComposeRootViewController *controller = [[TWTeetComposeRootViewController alloc] init];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 200) style:UITableViewStylePlain];
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 216)];
    
    controller.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth); // fix
    
    controller.title = NSLocalizedString(@"Compose Tweet", @"");
    controller.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [controller.view addSubview:tableView];
    [controller.view addSubview:pickerView];
    
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send") style:UIBarButtonItemStyleDone target:self action:@selector(send:)];
    
    pickerView.hidden = YES;
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    _controller = controller;
    _pickerView = pickerView;
    _tableView = tableView;
    
    _images = [[NSMutableArray alloc] init];
    _URLs = [[NSMutableArray alloc] init];
    
    _accounts = [[NSArray alloc] init];
    _selectedAccount = NSNotFound;
    _isPresented = NO;
    _sending = NO;
        
    return controller;
}

- (UITableViewCell*) accountCell
{
    if (_accountCell) {
        return _accountCell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 44, 480)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 44/2-20/2, 70, 21)];
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(8+70, 44/2-20/2, 320-(70+8+36+8), 21)];
    UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(320-(36+8), 44/2-20/2, 36, 21)];
    
    count.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    count.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    count.textAlignment = UITextAlignmentRight;
    count.text = @"140";
    count.tag = 102;
    
    label.text = NSLocalizedString(@"Account:", @"Account:");
    label.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    
    field.delegate = self;
    field.tag = 101;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:field];
    [cell addSubview:label];
    [cell addSubview:count];
    
    _accountCell = cell;
    return cell;
}

- (UITableViewCell*) messageCell
{
    if (_messageCell) {
        return _messageCell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 480-44-44)];
    UITextView *field = [[UITextView alloc] initWithFrame:CGRectMake(8, 8, 320-(8+8), _tableView.frame.size.height - 44.0)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_tableView.frame.size.width-(64+8), 8, 64, 64)];
    
    field.contentInset = UIEdgeInsetsMake(-8,-8,-8,-8);
    field.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    field.showsHorizontalScrollIndicator = NO;
    field.showsVerticalScrollIndicator = NO;
    field.delegate = self;
    field.tag = 101;
    
    imageView.hidden = YES;
    imageView.tag = 102;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:imageView];
    [cell addSubview:field];
    
    _messageCell = cell;
    return cell;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    _accountCell = nil;
    _messageCell = nil;
    _controller = nil;
    _pickerView = nil;
    _tableView = nil;
    
    _accounts = nil;
    _accountStore = nil;
    
    _images = nil;
    _URLs = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[[self messageCell] viewWithTag:101] becomeFirstResponder];
    
    [self twitterAccounts:^(NSArray *accounts, NSError *error) {
        if (error) {
            // display the error
            NSLog(@"Error acquiring twitter accounts: %@",error);
            if ( self.completionHandler) {
                dispatch_async(dispatch_get_main_queue(),^{
                    self.completionHandler(TCTweetComposeViewControllerResultCancelled);
                });
            }
            return;
        }
        _accounts = accounts;
                
        // accounts should always be greater than 0, otherwise canSendTweet
        // returns false
        
        if ([_accounts count]>0) {
            _selectedAccount = 0;
            NSString *text = [NSString stringWithFormat:@"@%@",[[_accounts objectAtIndex:0] username]];
            [(UILabel*)[[self accountCell] viewWithTag:101] setText:text];
        }
        
        [_pickerView reloadAllComponents];
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    _isPresented = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Public API

- (BOOL)setInitialText:(NSString *)text;
{
    if (_isPresented) {
        return NO;
    }
    
    [(UITextView*)[[self messageCell] viewWithTag:101] setText:text];
    return YES;
}

- (BOOL)addImage:(UIImage *)image
{
    if (_isPresented) {
        return NO;
    }
    if ([_images count] >= 1) {
        return NO;
    }
    
    [_images addObject:image];
    [(UIImageView*)[[self messageCell] viewWithTag:102] setImage:image];
    [self setImageViewHidden:NO];
    [self updateCharacterCount];
    return YES;
}

- (BOOL)addURL:(NSURL *)url
{
    if (_isPresented) {
        return NO;
    }
    
    [_URLs addObject:url];
    [self updateCharacterCount];
    return YES;
}

- (BOOL)removeAllImages
{
    if (_isPresented) {
        return NO;
    }
    
    [_images removeAllObjects];
    [(UIImageView*)[[self messageCell] viewWithTag:102] setImage:nil];
    [self setImageViewHidden:YES];
    [self updateCharacterCount];
    return YES;
}

- (BOOL)removeAllURLs
{
    if (_isPresented) {
        return NO;
    }
    
    [_URLs removeAllObjects];
    return YES;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ( indexPath.row == 0 ) {
        cell = [self accountCell];
    } else if ( indexPath.row == 1) {
        cell = [self messageCell];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
    case 0:
        return 44.f;
        break;
    case 1:
        return tableView.frame.size.height - 44.0
        ;
        break;
    default:
        return 44.f;
        break;
    }
}

#pragma mark - Picker View Delegate and Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_accounts count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"@%@",[[_accounts objectAtIndex:row] username]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedAccount = row;
    [(UILabel*)[[self accountCell] viewWithTag:101] setText:[NSString stringWithFormat:@"@%@",[[_accounts objectAtIndex:row] username]]];
}

#pragma mark - Text Field / Text View Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _pickerView.hidden = NO;
    [[[self messageCell] viewWithTag:101] resignFirstResponder];
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateCharacterCount];
}

#pragma mark - Utilities

- (void) setImageViewHidden:(BOOL)hidden
{
    CGRect textFrame = CGRectMake(8, 8, 320-(8+8), _tableView.frame.size.height - 44.0);
    if (!hidden) textFrame.size.width -= (64);
    
    [[[self messageCell] viewWithTag:102] setHidden:hidden];
    [[[self messageCell] viewWithTag:101] setFrame:textFrame];
}

- (void) updateCharacterCount
{
    // seems a safe value for now, discover dynamically?
    // https://api.twitter.com/1/help/configuration.json
    
    static NSInteger kTwitterPicURLLength = 28;
    static NSInteger kTwitterURLLength = 28;
    static NSInteger kMaxTweetLength = 140;
    
    UITextView *textView = (UITextView*)[[self messageCell] viewWithTag:101];
    UILabel *field = (UILabel*)[[self accountCell] viewWithTag:102];
    
    NSInteger length, textLength;
    length = textLength = [textView.text length];
    length += ([_images count]*kTwitterPicURLLength);
    length += ([_URLs count]*kTwitterURLLength);
    NSInteger remaining = kMaxTweetLength - length;
    
    field.text = [NSString stringWithFormat:@"%i",remaining];
    if ( remaining < 0 ) {
        field.textColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
    } else {
        field.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    }
    
    _controller.navigationItem.rightBarButtonItem.enabled = (textLength!=0);
}

#pragma mark - User Actions

- (IBAction)cancel:(id)sender
{
    if (self.completionHandler) {
        dispatch_async(dispatch_get_main_queue(),^{
            self.completionHandler(TCTweetComposeViewControllerResultCancelled);
        });
    }
}

- (IBAction)send:(id)sender
{
    if (_sending) {
        return;
    }
    
    if ([_images count] == 0) {
        [self postStatusUpdate];
    } else {
        [self postStatusUpdateWithMedia];
    }
    
    _sending = YES;
}

#pragma mark - Twitter Acounts and API

- (void) postStatusUpdateWithMedia
{
    // https://dev.twitter.com/docs/ios/posting-images-using-twrequest
    static NSString * kMediaStatusUpdateURLString = @"https://upload.twitter.com/1/statuses/update_with_media.json";
    
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:kMediaStatusUpdateURLString] parameters:nil requestMethod:TWRequestMethodPOST];
    
    // Add the data of the image with the correct parameter name, "media[]"
    for (NSUInteger i = 0; i < [_images count]; i++ ) {
        NSData *imageData = UIImagePNGRepresentation([_images objectAtIndex:i]);
        NSString *name = @"media[]";
        [request addMultiPartData:imageData withName:name type:@"multipart/form-data"];
    }
    
    //  Add the data of the status as parameter "status"
    NSString *status = [(UITextView*)[[self messageCell] viewWithTag:101] text];
    
    // append URLs
    for ( NSURL *URL in _URLs ) {
        status = [status stringByAppendingFormat:@" %@", [URL absoluteString]];
    }
    
    [request addMultiPartData:[status dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"multipart/form-data"];
    
    request.account = [_accounts objectAtIndex:_selectedAccount];
    [self performTwitterRequest:request];
}

- (void) postStatusUpdate
{
    static NSString * kStatusUpdateURLString = @"https://api.twitter.com/1/statuses/update.json";
    
    //  Add the data of the status as parameter "status"
    NSString *status = [(UITextView*)[[self messageCell] viewWithTag:101] text];
    
    // append URLs
    for ( NSURL *URL in _URLs ) {
        status = [status stringByAppendingFormat:@" %@", [URL absoluteString]];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:status forKey:@"status"];
    
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:kStatusUpdateURLString] parameters:params requestMethod:TWRequestMethodPOST];
    
    request.account = [_accounts objectAtIndex:_selectedAccount];
    [self performTwitterRequest:request];
}

- (void) performTwitterRequest:(TWRequest*)request
{
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ( error ) {
            NSLog(@"Error performing twitter request: %@", error);
        } else {
            NSStringEncoding responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)[urlResponse textEncodingName]));
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:responseEncoding];
            
            NSLog(@"%@", [urlResponse allHeaderFields]);
            NSLog(@"%@", responseString);
        }
        
        if ( self.completionHandler) {
            dispatch_async(dispatch_get_main_queue(),^{
                self.completionHandler(TCTweetComposeViewControllerResultDone);
            });
        }
    }];
}

- (void) twitterAccounts:(void(^)(NSArray *accounts, NSError *error))handler
{
    // First, we need to obtain the account instance for the user's Twitter account
    // Account store is an instance variable because it apparently needs to be
    // kept around.
    
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //  Request access from the user for access to his Twitter accounts
    //  This method is not guaranteed to call into the block on the main thread
    
    [_accountStore requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            
            if (handler) {
                dispatch_async(dispatch_get_main_queue(),^{
                    handler(nil,error);
                });
            }
        }
        else {
            // Grab the available accounts
            NSArray *twitterAccounts = [_accountStore accountsWithAccountType:twitterAccountType];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(),^{
                    handler(twitterAccounts,nil);
                });
            }
        }
    }];
}

@end

#pragma mark -

@implementation TWTeetComposeRootViewController

// placeholder

@end
