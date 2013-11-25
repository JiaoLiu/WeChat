//
//  registerViewController.m
//  WeChat
//
//  Created by Jiao Liu on 11/22/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "registerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utility.h"
#import <Parse/Parse.h>
#import "loginViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface registerViewController ()
{
    IBOutlet UITextField *nameInput;
    IBOutlet UITextField *pswInput;
    
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *registerBtn;
}

@end

@implementation registerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *Label = [[[UILabel alloc] init] autorelease];
    Label.frame = CGRectMake(SCREEN_WIDTH/2 -30, 20, 60, 30);
    Label.text = @"注册";
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

    
    registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, pswInput.frame.origin.y + pswInput.frame.size.height + 30, SCREEN_WIDTH/2 - 25, 40)];
    [registerBtn setBackgroundImage:[UIImage generateColorImage:[UIColor lightGrayColor] size:registerBtn.frame.size] forState:UIControlStateNormal];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTintColor:[UIColor whiteColor]];
    registerBtn.layer.cornerRadius = 3;
    [registerBtn addTarget:self action:@selector(newRegister) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:registerBtn];
    
    
    cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(registerBtn.frame.origin.x + registerBtn.frame.size.width + 10, registerBtn.frame.origin.y, SCREEN_WIDTH/2 - 25, 40)];
    [cancelBtn setBackgroundImage:[UIImage generateColorImage:[UIColor lightGrayColor] size:registerBtn.frame.size] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTintColor:[UIColor whiteColor]];
    cancelBtn.layer.cornerRadius = 3;
    [cancelBtn addTarget:self action:@selector(backToLogin) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:cancelBtn];;
	// Do any additional setup after loading the view.
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

- (void)backToLogin
{
    self.view.alpha = 0;
    loginViewController *loginView = [[[loginViewController alloc] init] autorelease];
    [self presentViewController:loginView animated:YES completion:^{
        [self.view removeFromSuperview];
    }];
}

- (void)newRegister
{
    if ([nameInput.text isEqualToString:@""] || [pswInput.text isEqualToString:@""]) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Notify" message:@"Plz input ID and password!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
    else
    {
        PFUser *user = [[PFUser alloc] init];
        user.username = nameInput.text;
        user.password = pswInput.text;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrat" message:@"success to register!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
                alert.tag = 100;
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"fail to register!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        switch (buttonIndex) {
            case 0:
                [self backToLogin];
                break;
                
            default:
                break;
        }
    }
}

- (void)dealloc {
    [nameInput release];
    [pswInput release];
    [registerBtn release];
    [cancelBtn release];
    [super dealloc];
}
@end
