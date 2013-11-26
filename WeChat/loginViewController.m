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
    
    UIButton *loginBtn;
    UIButton *registerBtn;
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
    
    
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, pswInput.frame.origin.y + pswInput.frame.size.height + 30, SCREEN_WIDTH/2 - 25, 40)];
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
	// Do any additional setup after loading the view, typically from a nib.
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
    if ([nameInput.text isEqualToString:@""] || [pswInput.text isEqualToString:@""]) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Notify" message:@"Plz input ID and password!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
    else
    {
        [PFUser logInWithUsernameInBackground:nameInput.text password:pswInput.text block:^(PFUser *user, NSError *error) {
            if (error != nil) {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Notify" message:@"fail to login!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
                [alert show];
            }
         else {
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
    [super dealloc];
}
@end
