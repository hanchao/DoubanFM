//
//  LoginViewController.h
//  DoubanFM
//
//  Created by chao han on 14-2-4.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@interface LoginViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginAction:(id)sender;
- (IBAction)TextField_DidEndOnExit:(UITextField *)sender;

@end
