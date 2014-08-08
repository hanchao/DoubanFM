//
//  FMViewController.m
//  DoubanFM
//
//  Created by chao han on 14-1-24.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "FMViewController.h"
#import "AFNetworking.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"
#import "Track.h"
#import "LoginViewController.h"
#import "Channel.h"
#import "ChannelsViewController.h"
#import "User.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

@interface FMViewController ()

@end

@implementation FMViewController{
    NSMutableArray *tracks;
    DOUAudioStreamer *streamer;
    Track *prevTrack;
    Track *currentTrack;
    NSMutableArray *channels;
    User *user;
}

@synthesize managedObjectContext =__managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAllValue];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)initAllValue{
    //初始化所有值
 
    tracks=[NSMutableArray array];
    
    self.progress.trackTintColor = [UIColor colorWithRed:0.884f green:0.867f blue:0.839f alpha:0.3f];
    self.progress.progressTintColor = [UIColor colorWithRed:0.584f green:0.967f blue:0.739f alpha:1.0f];
    self.progress.thicknessRatio = 0.03f;
    self.progress.roundedCorners = YES;
    
    //设置音乐进度条
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    
    self.songTitle.text = @"";
    [self.songTitle setNumberOfLines:0];
    self.songTitle.lineBreakMode = UILineBreakModeWordWrap;
    
    self.playing.hidden = YES;
    
    //歌曲图片以圆形呈现
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 125;
    
    self.playing.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    self.playing.layer.masksToBounds = YES;
    self.playing.layer.cornerRadius = 20;
    
    //歌曲图片增加单击事件
    UITapGestureRecognizer *singTapHidden=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
    [self.audioVisualizerView addGestureRecognizer:singTapHidden];
    
    //获取用户信息
    user = [User sharedUser];
    [self.navigationItem setTitle:user.user_name];
    
    //重新登陆
    if (user.email.length != 0 && user.password.length != 0) {
        [self loginName:user.email password:user.password];
    }
    
    //频道列表
    [self getChannels];
    
    //自动播放
    [self next];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Tracks methods

-(void)getTracks{
    NSString *url=@"http://douban.fm/j/app/radio/people";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    if (user.channel_id.length == 0) {
        user.channel_id = @"1";
    }
    NSMutableDictionary *songParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"n",@"type",user.channel_id,@"channel",nil];
    
    if (prevTrack !=  nil) {
        [songParameters setObject:@"p" forKey:@"type"];
        [songParameters setObject:prevTrack.sid forKey:@"sid"];
    }
    
    if (user.isLogin) {
        [songParameters setObject:user.user_id forKey:@"user_id"];
        [songParameters setObject:user.expire forKey:@"expire"];
        [songParameters setObject:user.token forKey:@"token"];
    }
    
    NSLog(@"get new tracks , current channel is %@",[songParameters objectForKey:@"channel"]);
    [manager GET:url parameters:songParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseSongs=[responseObject objectForKey:@"song"];

        for (NSDictionary *song in responseSongs) {
            //依次赋值给track
            Track *track=[[Track alloc] init];
            track.artist=[song objectForKey:@"artist"];
            track.title=[song objectForKey:@"title"];
            track.albumTitle=[song objectForKey:@"albumtitle"];
            track.sid=[song objectForKey:@"sid"];
            track.url=[NSURL URLWithString:[song objectForKey:@"url"]];
            track.picture=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[song objectForKey:@"picture"]]]];
            track.isLike=[[song objectForKey:@"like"] boolValue];
            
            [tracks addObject:track];
        }
        
        NSLog(@"get %d tracks",tracks.count);

        //如果当前没歌，自动播放
        if (currentTrack == nil) {
            [self playNextTrack];
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[getTracks]Network connect failure:error--->%@",error);
    }];
}

-(BOOL)playNextTrack{
    [self removeObserverForStreamer];
    if (tracks.count == 0) {
        return NO;
    }
    currentTrack =[tracks firstObject];
    [tracks removeObject:currentTrack];
    streamer=[DOUAudioStreamer streamerWithAudioFile:currentTrack];
    [streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self progressChange];
    NSString *title=[NSString stringWithFormat:@"%@\n%@",currentTrack.title,currentTrack.artist];
    [self.songTitle setText:title];
    self.love.selected = currentTrack.isLike;
    [self.imageView setImage:[currentTrack picture]];
    self.playing.hidden = YES;
    [streamer play];
    
    [self configNowPlayingInfoCenter];
    
    NSLog(@"play %@-%@",currentTrack.title,currentTrack.artist);
    
    return YES;
}

-(void)removeObserverForStreamer{
    if (streamer != nil) {
        [streamer removeObserver:self forKeyPath:@"status"];
        streamer=nil;
    }
}

#pragma mark - Channels method
-(void)getChannels{
    NSString *url=@"http://douban.fm/j/app/radio/channels";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    if (channels != nil) {
        channels = nil;
    }
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseChannels=[responseObject objectForKey:@"channels"];
        channels=[NSMutableArray array];
        for (NSDictionary *dicChannels in responseChannels) {
            //依次赋值给channel
            Channel *channel=[[Channel alloc] init];
            channel.name=[dicChannels objectForKey:@"name"];
            NSInteger channel_id = [[dicChannels objectForKey:@"channel_id"] intValue];
            channel.channel_id = [NSString stringWithFormat:@"%d",channel_id];
            [channels addObject:channel];
        }
        
        UIViewController *leftViewController = self.sidePanelController.leftPanel;
        if ([leftViewController isKindOfClass:[ChannelsViewController class]]){
            ChannelsViewController *chvc=(ChannelsViewController *)leftViewController;
            chvc.channels=channels;
            [chvc.tableView reloadData];
            chvc.delegate=self;
        }
            
        NSLog(@"get Channels success");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[getChannels]Network connect failure:error--->%@",error);
    }];
}

#pragma mark - ChannelsViewControllerDelegate method
-(void)ChannelsViewControllerDidSelect:(ChannelsViewController *)controller didChannel:(Channel *)selectChannel{
    NSLog(@"channel_id--->name:%@--->%@",selectChannel.channel_id,selectChannel.name);
    if (user.channel_id != selectChannel.channel_id) {
        user.channel_id = selectChannel.channel_id;
        [user save];
        
        prevTrack = nil;
        currentTrack = nil;
        
        [tracks removeAllObjects];
        
        // 自动播放
        [self next];
    }
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.sidePanelController showCenterPanelAnimated:YES];
}

#pragma mark - Login method
-(void)loginName:(NSString *)name password:(NSString *)password{
    
    NSString *url=@"http://www.douban.com/j/app/login";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSMutableDictionary *loginParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name",
                     @"100",@"version",name,@"email",password,@"password",nil];
    
    [manager POST:url parameters:loginParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *loginMess=(NSDictionary *)responseObject;
        
        if ( [[[loginMess objectForKey:@"r"] stringValue] isEqualToString:@"0"] ) {
            //登陆成功
            user.isLogin = YES;
            user.email = name;
            user.password = password;
            
            user.user_id = [loginMess objectForKey:@"user_id"];
            user.expire = [loginMess objectForKey:@"expire"];
            user.token = [loginMess objectForKey:@"token"];
            user.user_name = [loginMess objectForKey:@"user_name"];
            [user save];
            
            [self.navigationItem setTitle:user.user_name];

            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"login success");
            
        }else if ( [[[loginMess objectForKey:@"r"] stringValue] isEqualToString:@"1"] ){
            //登陆失败
            user.isLogin = NO;

            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"登入失败" message:[NSString stringWithFormat:@"%@",[loginMess objectForKey:@"err"]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"login failure");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //网络连接失败
        user.isLogin = NO;
        NSLog(@"[getLogin]Network connect failure:error--->%@",error);
    }];
}

#pragma mark - LoginViewControllerDelegate method

-(void)loginViewControllerDidCancel:(LoginViewController *)controller{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loginViewControllerDidSave:(LoginViewController *)controller{
    if (controller.nameText.text.length != 0 && controller.passwordText.text.length != 0) {
        [self loginName:controller.nameText.text password:controller.passwordText.text];
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"登入失败" message:@"请输入邮件和密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - KVO delegate method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"] ) {
        if ([streamer status] == DOUAudioStreamerFinished){
            [self performSelector:@selector(finishAction:)
                         onThread:[NSThread mainThread]
                       withObject:nil
                    waitUntilDone:NO];
        }
    }
}

-(void)progressChange{
    if (streamer.duration == 0.0) {
        [self.progress setProgress:0.0f animated:YES];
    }else{
        [self.progress setProgress:[streamer currentTime] / [streamer duration] animated:YES];
    }
    [self configNowPlayingInfoCenter];
}



#pragma mark - action method

- (IBAction)menuAction:(id)sender{
    [self.sidePanelController showLeftPanelAnimated:YES];
}

/*
 DOUAudioStreamerPlaying,
 DOUAudioStreamerPaused,
 DOUAudioStreamerIdle,
 DOUAudioStreamerFinished,
 DOUAudioStreamerBuffering,
 DOUAudioStreamerError
 */
- (IBAction)playingAction:(id)sender {
    [self playOrPause];
}

- (IBAction)nextAction:(id)sender {

    [self next];
    
    //seed skip message
    if (prevTrack != nil){
        NSString *skipURL=@"http://douban.fm/j/app/radio/people";
        NSMutableDictionary *skipParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"s",@"type",@"4",@"channel",nil];
        [skipParameters setObject:prevTrack.sid forKey:@"sid"];
        if (user.isLogin) {
            [skipParameters setObject:user.user_id forKey:@"user_id"];
            [skipParameters setObject:user.expire forKey:@"expire"];
            [skipParameters setObject:user.token forKey:@"token"];
        }
        AFHTTPSessionManager *skipManager=[AFHTTPSessionManager manager];
        [skipManager GET:skipURL parameters:skipParameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"skip is success");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error%@",error);
        }];
    }

}

- (IBAction)finishAction:(id)sender {
    
    [self next];
    
    //seed end message
    if (prevTrack != nil){
        NSString *endURL=@"http://douban.fm/j/app/radio/people";
        NSMutableDictionary *endParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"s",@"type",@"4",@"channel",nil];
        [endParameters setObject:prevTrack.sid forKey:@"sid"];
        if (user.isLogin) {
            [endParameters setObject:user.user_id forKey:@"user_id"];
            [endParameters setObject:user.expire forKey:@"expire"];
            [endParameters setObject:user.token forKey:@"token"];
        }
        AFHTTPSessionManager *endManager=[AFHTTPSessionManager manager];
        [endManager GET:endURL parameters:endParameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"end is success");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error%@",error);
        }];
    }
}

- (IBAction)loveAction:(id)sender {
    
    if (currentTrack != nil){
        NSString *loveURL=@"http://douban.fm/j/app/radio/people";
        NSMutableDictionary *loveParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"r",@"type",@"4",@"channel",nil];
        [loveParameters setObject:currentTrack.sid forKey:@"sid"];
        if (user.isLogin) {
            [loveParameters setObject:user.user_id forKey:@"user_id"];
            [loveParameters setObject:user.expire forKey:@"expire"];
            [loveParameters setObject:user.token forKey:@"token"];
        }
        AFHTTPSessionManager *loveManager=[AFHTTPSessionManager manager];
        [loveManager GET:loveURL parameters:loveParameters success:^(NSURLSessionDataTask *task, id responseObject) {
            self.love.selected = YES;
            NSLog(@"Love is success");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error%@",error);
        }];
    }
}

- (IBAction)trashAction:(id)sender {
    if (currentTrack != nil) {
        NSString *trashURL=@"http://douban.fm/j/app/radio/people";
        NSMutableDictionary *trashParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"b",@"type",@"4",@"channel",nil];
        [trashParameters setObject:currentTrack.sid forKey:@"sid"];
        if (user.isLogin) {
            [trashParameters setObject:user.user_id forKey:@"user_id"];
            [trashParameters setObject:user.expire forKey:@"expire"];
            [trashParameters setObject:user.token forKey:@"token"];
        }
        AFHTTPSessionManager *trashManager=[AFHTTPSessionManager manager];
        [trashManager GET:trashURL parameters:trashParameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [self next];
            NSLog(@"trash is success");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error%@",error);
        }];
    }
}

- (void)next{
    self.love.selected = NO;
    
    prevTrack = currentTrack;
    currentTrack = nil;

    if(![self playNextTrack])
    {
        // 没有歌了，加载新的吧
        [self getTracks];
    }
}

- (void)playOrPause{
    if ([streamer status] == DOUAudioStreamerPaused || [streamer status] == DOUAudioStreamerIdle) {
        [streamer play];
        self.playing.hidden = YES;
    }else{
        [streamer pause];
        self.playing.hidden = NO;
    }
}

#pragma mark - segue method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ChannelsViewController *viewController=(ChannelsViewController *)segue.destinationViewController;
    
    if ([viewController isKindOfClass:[LoginViewController class]]) {
        LoginViewController *loginvc=(LoginViewController *)viewController;
        loginvc.delegate=self;
    }else if ([viewController isKindOfClass:[ChannelsViewController class]]){
        ChannelsViewController *chvc=(ChannelsViewController *)viewController;
        chvc.channels=channels;
        [chvc.tableView reloadData];
        chvc.delegate=self;
    }
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrPause];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self next];
                break;
                
            default:
                break;
        }
    }
}

- (void) configNowPlayingInfoCenter{
    // 更新锁屏信息
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];
        
        if(currentTrack != nil){
            MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage: [currentTrack picture] ];
            
            [ songInfo setObject: currentTrack.title forKey:MPMediaItemPropertyTitle ];
            [ songInfo setObject: currentTrack.artist forKey:MPMediaItemPropertyArtist ];
            [ songInfo setObject: currentTrack.albumTitle forKey:MPMediaItemPropertyAlbumTitle ];
            [ songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork ];
            
            [songInfo setObject:[NSNumber numberWithDouble:[streamer duration]] forKey:MPMediaItemPropertyPlaybackDuration];
            [songInfo setObject:[NSNumber numberWithDouble:[streamer currentTime]] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            
            [ [MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo ];
        }
    }
}

@end
