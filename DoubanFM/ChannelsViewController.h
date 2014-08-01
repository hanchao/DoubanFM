//
//  ChannelsViewController.h
//  DoubanFM
//
//  Created by chao han on 14-2-4.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
@class ChannelsViewController;

@protocol ChannelsViewControllerDelegate <NSObject>

-(void)ChannelsViewControllerDidSelect:(ChannelsViewController *)controller didChannel:(Channel *)selectChannel;

@end

@interface ChannelsViewController : UITableViewController

@property (nonatomic,strong) id <ChannelsViewControllerDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *channels;

@end
