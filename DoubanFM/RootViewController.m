//
//  RootViewController.m
//  DoubanFM
//
//  Created by chao han on 14-7-31.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "RootViewController.h"
#import "RESideMenu.h"

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
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FMViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChannelsViewController"];
    self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
}
@end
