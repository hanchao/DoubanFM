//
//  FMViewController.h
//  DoubanFM
//
//  Created by chao han on 14-1-24.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "ChannelsViewController.h"
#import "EFCircularSlider.h"
#import "DOUAudioVisualizer.h"

@interface FMViewController : UIViewController<LoginViewControllerDelegate,ChannelsViewControllerDelegate>

//控件
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet DOUAudioVisualizer *audioVisualizerView;
@property (strong, nonatomic) IBOutlet UILabel *songTitle;
@property (strong, nonatomic) IBOutlet EFCircularSlider *progress;
@property (strong, nonatomic) IBOutlet UIButton *playing;
@property (strong, nonatomic) IBOutlet UIButton *love;
@property (strong, nonatomic) IBOutlet UIButton *trash;

//Core Data store
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (IBAction)playingAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)loveAction:(id)sender;

- (NSURL *)applicationDocumentsDirectory;

@end
