//
//  ChannelsViewController.m
//  DoubanFM
//
//  Created by chao han on 14-2-4.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "ChannelsViewController.h"
#import "Channel.h"
#import "User.h"

@interface ChannelsViewController ()

@end

@implementation ChannelsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setChannels:(NSMutableArray *)channels
//{
//    self.channels = channels;
//    self.tableView.reloadData;
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"频道";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Channels"];
    Channel *channel=[self.channels objectAtIndex:indexPath.row];
    cell.textLabel.text=channel.name;
    
    //cell.frame = CGRectMake(0,0,40,40);
    
    if ([channel.channel_id isEqualToString:[User sharedUser].channel_id])
    {
        cell.backgroundColor = [UIColor colorWithRed:0.684f green:0.867f blue:0.739f alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark - UITableViewDelegate method
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Channel *channel=[self.channels objectAtIndex:indexPath.row];
    [self.delegate ChannelsViewControllerDidSelect:self didChannel:channel];
    [self.tableView reloadData];
}

@end
