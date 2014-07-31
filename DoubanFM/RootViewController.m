//
//  RootViewController.m
//  DoubanFM
//
//  Created by chao han on 14-7-31.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "RootViewController.h"

#import "FMViewController.h"
#import "LoginViewController.h"
#import "ChannelsViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    ChannelsViewController *leftViewController = (ChannelsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ChannelsViewController"];
    UINavigationController *centerViewController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CenterViewController"];
    
    FMViewController *fmViewController = (FMViewController *)centerViewController.topViewController;
    
    leftViewController.delegate = fmViewController;

    
    [self setLeftPanel:leftViewController];
    [self setCenterPanel:centerViewController];

}
@end
