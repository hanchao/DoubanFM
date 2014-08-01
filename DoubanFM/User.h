//
//  User.h
//  DoubanFM
//
//  Created by chao han on 14-2-9.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;

@property (nonatomic) BOOL isLogin;

@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * expire;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * user_name;

@property (nonatomic, retain) NSString * channel_id;

+ (User *)sharedUser;

-(void) save;
-(void) load;

@end
