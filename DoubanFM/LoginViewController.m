//
//  LoginViewController.m
//  DoubanFM
//
//  Created by chao han on 14-2-4.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface LoginViewController ()

@end

@implementation LoginViewController{
    User *user;
    MBProgressHUD *HUD;
}

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
    
    HUD = [MBProgressHUD new];
    [self.view addSubview:HUD];
    
    user = [User sharedUser];
    self.nameText.text = user.email;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [self.nameText becomeFirstResponder];
    }else if (indexPath.section == 1){
        [self.passwordText becomeFirstResponder];
    }
}

#pragma mark - Action method

- (IBAction)loginAction:(id)sender {
    if (self.nameText.text.length != 0 && self.passwordText.text.length != 0) {
        [self loginWithName:self.nameText.text password:self.passwordText.text];
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"登入失败" message:@"请输入邮件和密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)TextField_DidEndOnExit:(UITextField *)sender{
    if (sender.tag == 100) {
        [self.passwordText becomeFirstResponder];
    }else if (sender.tag == 200){
        [self.passwordText resignFirstResponder];
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Login method
-(void)loginWithName:(NSString *)name password:(NSString *)password{
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = NSLocalizedString(@"登入中", nil);
    [HUD show:YES];
    
    NSString *url=@"http://www.douban.com/j/app/login";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSMutableDictionary *loginParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name",
                                          @"100",@"version",name,@"email",password,@"password",nil];
    
    [manager POST:url parameters:loginParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *loginMess=(NSDictionary *)responseObject;
        [HUD hide:YES];
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
        [HUD hide:YES];
        NSLog(@"[getLogin]Network connect failure:error--->%@",error);
    }];
}

@end
