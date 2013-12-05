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
    UITextField *nameInput;
    UITextField *pswInput;
    UITextField *emailInput;
    
    UIButton *cancelBtn;
    UIButton *registerBtn;
    
    UIView *loadingView;
    
    UIButton *IDImage;
    NSData *imageData;
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
    //[self.view addSubview:idLable];
    
    nameInput = [[UITextField alloc] initWithFrame:CGRectMake(90, Label.frame.origin.y + Label.frame.size.height + 30, SCREEN_WIDTH - 100, 30)];
    nameInput.layer.borderWidth = 1;
    nameInput.font = [UIFont systemFontOfSize:19];
    nameInput.layer.borderColor = [UIColor grayColor].CGColor;
    nameInput.layer.cornerRadius = 3;
    nameInput.delegate = self;
    nameInput.placeholder = @" 用户名";
    [self.view addSubview:nameInput];
    
    
    UILabel *pwdLable = [[[UILabel alloc] init] autorelease];
    pwdLable.frame = CGRectMake(10, idLable.frame.origin.y + idLable.frame.size.height + 10, 80, 30);
    pwdLable.text = @"密码 :";
    //[self.view addSubview:pwdLable];
    
    pswInput = [[UITextField alloc] initWithFrame:CGRectMake(90, pwdLable.frame.origin.y, SCREEN_WIDTH - 100, 30)];
    pswInput.layer.borderWidth = 1;
    pswInput.font = [UIFont systemFontOfSize:19];
    pswInput.layer.borderColor = [UIColor grayColor].CGColor;
    pswInput.layer.cornerRadius = 3;
    pswInput.delegate = self;
    pswInput.secureTextEntry = YES;
    pswInput.placeholder = @" 密码";
    [self.view addSubview:pswInput];
    
    UILabel *emailLabel =[[[UILabel alloc] init] autorelease];
    emailLabel.frame = CGRectMake(10, pwdLable.frame.origin.y + pwdLable.frame.size.height + 10, 80, 30);
    emailLabel.text = @"Email :";
    //[self.view addSubview:emailLabel];
    
    emailInput = [[UITextField alloc] initWithFrame:CGRectMake(90, emailLabel.frame.origin.y, SCREEN_WIDTH - 100, 30)];
    emailInput.layer.borderWidth = 1;
    emailInput.font = [UIFont systemFontOfSize:19];
    emailInput.layer.borderColor = [UIColor grayColor].CGColor;
    emailInput.layer.cornerRadius = 3;
    emailInput.delegate = self;
    emailInput.placeholder = @" Email";
    emailInput.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:emailInput];
    
    registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, emailLabel.frame.origin.y + emailLabel.frame.size.height + 30, SCREEN_WIDTH/2 - 25, 40)];
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
    [self.view addSubview:cancelBtn];
    
    IDImage = [[UIButton alloc] initWithFrame:CGRectMake(10, Label.frame.origin.y + Label.frame.size.height + 30, 75, 100)];
    [IDImage setTitle:@"＋" forState:UIControlStateNormal];
    [IDImage setBackgroundImage:[UIImage generateColorImage:[UIColor lightGrayColor] size:IDImage.frame.size] forState:UIControlStateNormal];
    IDImage.titleLabel.font = [UIFont systemFontOfSize:40];
    [IDImage addTarget:self action:@selector(showSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:IDImage];
    
    imageData = [[NSData alloc] init];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [emailInput resignFirstResponder];
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
    NSString *name = [nameInput.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    nameInput.text = name;
    
    if ([nameInput.text isEqualToString:@""] || [pswInput.text isEqualToString:@""] || name == nil || pswInput.text == nil) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Notify" message:@"Plz input ID and password!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
    else
    {
        [self showLoading];
        PFUser *user = [[PFUser alloc] init];
        user.username = nameInput.text;
        user.password = pswInput.text;
        user.email = emailInput.text;
        user[@"image"] = imageData;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self dismissLoading];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrat" message:@"success to register!" delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
                alert.tag = 100;
                [alert show];
            }
            else {
                [self dismissLoading];
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
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 60)] autorelease];
        label.text = @"注册中...";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [loadingView addSubview:label];
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

#pragma mark - PickImage
- (void)showSheet :(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photos", @"Camera", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self pickImage];
    }
    if (buttonIndex == 1) {
        [self cameraCapture];
    }
}

- (void)cameraCapture
{
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.delegate = self;
    imagepicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagepicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:imagepicker animated:YES completion:^{
    }];
}

- (void)pickImage
{
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.delegate = self;
    imagepicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepicker animated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *sendImage = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(75, 100));
        [sendImage drawInRect: CGRectMake(0, 0, 75, 100)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [IDImage setImage:smallImage forState:UIControlStateNormal];
        imageData = [UIImagePNGRepresentation(smallImage) retain];
    }];
}


- (void)dealloc {
    [nameInput release];
    [pswInput release];
    [emailInput  release];
    [registerBtn release];
    [cancelBtn release];
    [IDImage release];
    [imageData release];
    [super dealloc];
}
@end
