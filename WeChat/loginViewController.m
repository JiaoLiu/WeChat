//
//  ViewController.m
//  WeChat
//
//  Created by Jiao Liu on 11/22/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "loginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utility.h"
#import <Parse/Parse.h>
#import "registerViewController.h"
#import "friendlistViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface loginViewController ()
{
    UITextField *nameInput;
    UITextField *pswInput;
    
    UILabel *queryPwdLabel;
    
    UIButton *loginBtn;
    UIButton *registerBtn;
    
    UIView *loadingView;
}

@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *Label = [[[UILabel alloc] init] autorelease];
    Label.frame = CGRectMake(SCREEN_WIDTH/2 -30, 20, 60, 30);
    Label.text = @"登录";
    Label.textAlignment = NSTextAlignmentCenter;
    Label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:Label];
    
    
    UILabel *idLable = [[[UILabel alloc] init] autorelease];
    idLable.frame = CGRectMake(10, Label.frame.origin.y + Label.frame.size.height + 30, 80, 30);
    idLable.text = @"用户名 :";
    [self.view addSubview:idLable];
    nameInput = [[UITextField alloc] initWithFrame:CGRectMake(90, Label.frame.origin.y + Label.frame.size.height + 30, SCREEN_WIDTH - 100, 30)];
    nameInput.layer.borderWidth = 1;
    nameInput.font = [UIFont systemFontOfSize:19];
    nameInput.layer.borderColor = [UIColor grayColor].CGColor;
    nameInput.layer.cornerRadius = 3;
    nameInput.delegate = self;
    [self.view addSubview:nameInput];
    
    
    UILabel *pwdLable = [[[UILabel alloc] init] autorelease];
    pwdLable.frame = CGRectMake(10, idLable.frame.origin.y + idLable.frame.size.height + 10, 80, 30);
    pwdLable.text = @"密码 :";
    [self.view addSubview:pwdLable];
    
    pswInput = [[UITextField alloc] initWithFrame:CGRectMake(90, pwdLable.frame.origin.y, SCREEN_WIDTH - 100, 30)];
    pswInput.layer.borderWidth = 1;
    pswInput.font = [UIFont systemFontOfSize:19];
    pswInput.layer.borderColor = [UIColor grayColor].CGColor;
    pswInput.layer.cornerRadius = 3;
    pswInput.delegate = self;
    pswInput.secureTextEntry = YES;
    [self.view addSubview:pswInput];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] init] autorelease];
    [tap addTarget:self action:@selector(queryPwd)];
    
    queryPwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, pwdLable.frame.origin.y + pwdLable.frame.size.height + 5, 60, 20)];
    queryPwdLabel.text = @"找回密码";
    queryPwdLabel.font = [UIFont systemFontOfSize:15];
    queryPwdLabel.textAlignment = NSTextAlignmentRight;
    queryPwdLabel.userInteractionEnabled = YES;
    [queryPwdLabel addGestureRecognizer:tap];
    [self.view addSubview:queryPwdLabel];
    // 下划线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, queryPwdLabel.frame.size.height - 1, 60, 1)];
    line.backgroundColor = [UIColor grayColor];
    [queryPwdLabel addSubview:line];
    
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, queryPwdLabel.frame.origin.y + queryPwdLabel.frame.size.height + 20, SCREEN_WIDTH/2 - 25, 40)];
    [loginBtn setBackgroundImage:[UIImage generateColorImage:[UIColor lightGrayColor] size:loginBtn.frame.size] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTintColor:[UIColor whiteColor]];
    loginBtn.layer.cornerRadius = 3;
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:loginBtn];
    

    registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(loginBtn.frame.origin.x + loginBtn.frame.size.width + 10, loginBtn.frame.origin.y, SCREEN_WIDTH/2 - 25, 40)];
    [registerBtn setBackgroundImage:[UIImage generateColorImage:[UIColor lightGrayColor] size:loginBtn.frame.size] forState:UIControlStateNormal];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTintColor:[UIColor whiteColor]];
    registerBtn.layer.cornerRadius = 3;
    [registerBtn addTarget:self action:@selector(newRegister) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:registerBtn];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [nameInput resignFirstResponder];
    [pswInput resignFirstResponder];
    return YES;
}

- (void)login
{
    NSString *name = [nameInput.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    nameInput.text = name;
    if ([nameInput.text isEqualToString:@""] || [pswInput.text isEqualToString:@""] || name == nil || pswInput.text == nil) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Notify" message:@"Plz input ID and password!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
    else
    {
        [self showLoading];
        [PFUser logInWithUsernameInBackground:nameInput.text password:pswInput.text block:^(PFUser *user, NSError *error) {
            if (error != nil) {
                [self dismissLoading];
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Notify" message:@"fail to login!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
                [alert show];
            }
         else {
             [self dismissLoading];
             self.view.alpha = 0;
             friendlistViewController *listView = [[[friendlistViewController alloc] init] autorelease];
             [self presentViewController:listView animated:YES completion:^{
                 [self.view removeFromSuperview];
             }];
         }
        }];
    }
}

- (void)newRegister
{
    self.view.alpha = 0;
    registerViewController *registerView = [[[registerViewController alloc] init] autorelease];
    [self presentViewController:registerView animated:YES completion:^{
        [self.view removeFromSuperview];
    }];
    
}

- (void)dealloc {
    [nameInput release];
    [pswInput release];
    [loginBtn release];
    [registerBtn release];
    [queryPwdLabel release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissLoading];
    
}

#pragma mark - show Loading
- (void)showLoading
{
    if (!loadingView) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT / 2 - 30, 80,  60)];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.7;
        loadingView.layer.cornerRadius = 3;
        [window addSubview:loadingView];
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 30, 80, 30)] autorelease];
        label.text = @"登录中";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [loadingView addSubview:label];
        
        UIActivityIndicatorView *activityIdc = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)] autorelease];
        [activityIdc setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [activityIdc startAnimating];
        [loadingView addSubview:activityIdc];
    }
}

- (void)dismissLoading
{
    if (loadingView) {
        [UIView animateWithDuration:0.3 animations:^{
            loadingView.alpha = 0;
        } completion:^(BOOL finished) {
            [loadingView removeFromSuperview];
            [loadingView release];
            loadingView = nil;
        }];
        
    }
}

#pragma mark - queryPwd
- (void)queryPwd
{
    [nameInput resignFirstResponder];
    NSString *name = [nameInput.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    nameInput.text = name;
    if ([nameInput.text isEqualToString:@""] || name == nil) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Notify" message:@"Plz input ID" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
    else {
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"_User"];
        [query whereKey:@"username" equalTo:name];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                if ([[objects objectAtIndex:0] objectForKey:@"email"]) {
                    [PFUser requestPasswordResetForEmailInBackground:[[objects objectAtIndex:0] objectForKey:@"email"]];
                }
                else {
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"抱歉" message:@"你没有注册邮箱，所以无法重置密码！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
                    [alert show];
                }
            }
            else {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"注意" message:@"帐号没注册！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
                [alert show];
            } 
        }];
    }
}
@end
