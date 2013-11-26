//
//  ChatViewController.m
//  WeChat
//
//  Created by Jiao Liu on 11/25/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utility.h"
#import "friendlistViewController.h"
#import <Parse/Parse.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ChatViewController ()
@end

@implementation ChatViewController
{
    UILabel *title;
    UIView *textView;
    UITextField *textInput;
    
    NSString *chatLog;
}
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)] autorelease];
        [nav setBackgroundImage:[UIImage generateColorImage:[UIColor grayColor] size:nav.frame.size] forBarMetrics:UIBarMetricsDefault];
        title = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 70, 5, 140, 30)];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:20];
        title.backgroundColor = [UIColor clearColor];
        [self performSelector:@selector(setTitle) withObject:nil afterDelay:0.5];
        [nav addSubview:title];
        
        UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
        logout.frame = CGRectMake(0, 5, 30, 30);
        logout.layer.borderWidth = 1;
        logout.layer.cornerRadius = 10;
        logout.layer.borderColor = [UIColor lightGrayColor].CGColor;
        logout.backgroundColor = [UIColor grayColor];
        [logout setTitle:@"<" forState:UIControlStateNormal];
        [logout addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem *logoutBtn = [[[UIBarButtonItem alloc] initWithCustomView:logout] autorelease];
        
        UINavigationItem *navItem = [[[UINavigationItem alloc] init] autorelease];
        navItem.leftBarButtonItem = logoutBtn;
        [nav pushNavigationItem:navItem animated:NO];
        [self.view addSubview:nav];
        
        textView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 60)];
        textView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:textView];
        
        textInput = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 60, 40)];
        textInput.layer.cornerRadius = 3;
        textInput.layer.borderColor = [UIColor whiteColor].CGColor;
        textInput.layer.borderWidth = 1;
        textInput.backgroundColor = [UIColor whiteColor];
        textInput.font = [UIFont systemFontOfSize:25];
        textInput.returnKeyType = UIReturnKeySend;
        textInput.delegate = self;
        [textView addSubview:textInput];
        
        UIButton *imageBtn = [[UIButton alloc] initWithFrame:CGRectMake(textInput.frame.origin.x + textInput.frame.size.width + 5, 10, 40, 40)];
        imageBtn.backgroundColor = [UIColor redColor];
        [textView addSubview:imageBtn];
    }
    return self;
}

#pragma mark -  back to friendlist
- (void)backToPrev
{
    self.view.alpha = 0;
    friendlistViewController *listView = [[[friendlistViewController alloc] init] autorelease];
    [self presentViewController:listView animated:YES completion:^{
        [self.view removeFromSuperview];
        user = nil;
    }];
}

#pragma mark - textInput delegate;
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textInput.text isEqualToString:@""]) {
        PFObject *sendObjects = [PFObject objectWithClassName:chatLog];
        [sendObjects setObject:textInput.text forKey:@"msg"];
        [sendObjects setObject:[PFUser currentUser].username forKey:@"user"];
        [sendObjects saveInBackground];
    }
    textInput.text = @"";
    [textInput resignFirstResponder];
    return YES;
}

- (void)keyboardShow :(NSNotification *)notify
{
    NSDictionary *info = [notify userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y - keyboardFrame.size.height, textView.frame.size.width, textView.frame.size.height)];
    [UIView commitAnimations];
}

- (void)keyboardDismiss: (NSNotification *)notify
{
    NSDictionary *info = [notify userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y + keyboardFrame.size.height, textView.frame.size.width, textView.frame.size.height)];
    [UIView commitAnimations];
}

#pragma mark - prepare for view
- (void)setTitle
{
    title.text = user;
    chatLog = [[NSString stringWithFormat:@"%@_%@",[PFUser currentUser].username,user] retain];
    NSString *temp = [NSString stringWithFormat:@"%@_%@",user,[PFUser currentUser].username];
    PFQuery *query = [[PFQuery alloc] initWithClassName:temp];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            chatLog = [temp retain];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismiss:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [super dealloc];
    [title release];
    [textView release];
    chatLog = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

@end
