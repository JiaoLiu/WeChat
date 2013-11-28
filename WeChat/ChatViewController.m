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
#import "ChatCell.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ChatViewController ()
@end

@implementation ChatViewController
{
    UILabel *title;
    UIView *textView;
    UITextField *textInput;
    UITableView *msgTable;
    
    NSString *chatLog;
    NSMutableArray *_data;
    NSTimer *timer;
    UILabel *timeLable;
    
    UIImage *sendImage;
    UIView *sendImageView;
    
    UIView *loadingView;
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
        imageBtn.backgroundColor = [UIColor clearColor];
        [imageBtn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [imageBtn addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventTouchDown];
        [textView addSubview:imageBtn];
        
        msgTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 120)];
        msgTable.dataSource = self;
        msgTable.delegate = self;
        msgTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:msgTable];
       
        timeLable = [[UILabel alloc] init];
        timeLable.textAlignment = NSTextAlignmentCenter;
        timeLable.textColor = [UIColor blackColor];
        timeLable.font = [UIFont systemFontOfSize:14];
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

#pragma mark - loadMsgData
- (void)loadMsgData
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    PFQuery *query = [PFQuery queryWithClassName:chatLog];
    [query whereKey:@"date" hasPrefix:currentDate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (_data.count != objects.count) {
            [_data removeAllObjects];
            [_data addObjectsFromArray:objects];
            [msgTable reloadData];
            if (msgTable.contentSize.height > msgTable.frame.size.height) {
                [msgTable setContentOffset:CGPointMake(0, msgTable.contentSize.height - msgTable.frame.size.height) animated:YES];
            }
        }
    }];
}

#pragma mark - textInput delegate;
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textInput.text isEqualToString:@""] && ![chatLog isEqualToString:@""]) {
        [self showLoading];
        NSData *msgData = [textInput.text dataUsingEncoding:NSUTF8StringEncoding];
        PFObject *sendObjects = [PFObject objectWithClassName:chatLog];
        [sendObjects setObject:msgData forKey:@"msg"];
        [sendObjects setObject:[PFUser currentUser].username forKey:@"user"];
        [sendObjects setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"date"];
        [sendObjects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self dismissLoading];
            }
        }];
        textInput.text = @"";
        [self loadMsgData];
    }
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
    [msgTable setFrame:CGRectMake(msgTable.frame.origin.x, msgTable.frame.origin.y, msgTable.frame.size.width, msgTable.frame.size.height - keyboardFrame.size.height)];
    [UIView commitAnimations];
    if (msgTable.contentSize.height > msgTable.frame.size.height) {
        [msgTable setContentOffset:CGPointMake(0, msgTable.contentSize.height - msgTable.frame.size.height) animated:YES];
    }
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
    [msgTable setFrame:CGRectMake(msgTable.frame.origin.x, msgTable.frame.origin.y, msgTable.frame.size.width, msgTable.frame.size.height + keyboardFrame.size.height)];
    [UIView commitAnimations];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect beginKeyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
    
    CGRect inputFieldRect = textView.frame;
    CGRect tableRect = msgTable.frame;
    
    inputFieldRect.origin.y += yOffset;
    tableRect.size.height += yOffset;
    msgTable.frame = tableRect;
    [UIView animateWithDuration:duration animations:^{
        textView.frame = inputFieldRect;
    }];
    if (msgTable.contentSize.height > msgTable.frame.size.height) {
        [msgTable setContentOffset:CGPointMake(0, msgTable.contentSize.height - msgTable.frame.size.height) animated:YES];
    }
}

#pragma mark - prepare for view
- (void)setTitle
{
    title.text = user;
    NSString *temp = [NSString stringWithFormat:@"%@_%@",user,[PFUser currentUser].username];
    PFQuery *query = [[PFQuery alloc] initWithClassName:temp];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            chatLog = [temp retain];
        }
        else {
            chatLog = [[NSString stringWithFormat:@"%@_%@",[PFUser currentUser].username,user] retain];
        }
    }];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadMsgData) userInfo:nil repeats:YES];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *msgStr = [[NSString alloc] initWithData:[[_data objectAtIndex:indexPath.row] objectForKey:@"msg"] encoding:NSUTF8StringEncoding];
    CGSize msgSize = [[NSString stringWithFormat:@"我：%@",msgStr] sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 40, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    NSString *cellId = [NSString stringWithFormat:@"MsgCell%ld",(long)indexPath.row];
    ChatCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setData:[_data objectAtIndex:indexPath.row]];
    
    if ([[_data objectAtIndex:indexPath.row] objectForKey:@"image"] != nil) {
        [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    }
    else {
        [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, msgSize.height + 20)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [textInput resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

#pragma mark - PickImage
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
        sendImage = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
        
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(120, 160));
        [sendImage drawInRect: CGRectMake(0, 0, 120, 160)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        /*// Upload image
        NSData *imageData = UIImagePNGRepresentation(smallImage);
        PFObject *imageObject = [PFObject objectWithClassName:chatLog];
        [imageObject setObject:imageData forKey:@"image"];
        [imageObject setObject:[PFUser currentUser].username forKey:@"user"];
        [imageObject setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"date"];
        [imageObject saveInBackground];*/
        if (!sendImageView) {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            sendImageView = [[UIView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT/2 - 120, SCREEN_WIDTH - 40, 240)];
            sendImageView.alpha = 0.7;
            sendImageView.layer.cornerRadius = 3;
            sendImageView.backgroundColor = [UIColor blackColor];
            [window addSubview:sendImageView];
            
            UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(sendImageView.frame.size.width/2 - 60, 10, 120, 160)] autorelease];
            imageView.image = smallImage;
            [sendImageView addSubview:imageView];
            
            UIButton *sendBtn = [[[UIButton alloc]initWithFrame:CGRectMake(10, 180, sendImageView.frame.size.width/2 - 15, 50)] autorelease];
            [sendBtn setBackgroundImage:[UIImage generateColorImage:[UIColor greenColor] size:sendBtn.frame.size] forState:UIControlStateNormal];
            [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
            sendBtn.layer.cornerRadius = 3;
            [sendBtn addTarget:self action:@selector(sendImage) forControlEvents:UIControlEventTouchUpInside];
            [sendImageView addSubview:sendBtn];
            
            UIButton *cancelBtn = [[[UIButton alloc]initWithFrame:CGRectMake(sendImageView.frame.size.width/2 + 5, 180, sendImageView.frame.size.width/2 - 15, 50)] autorelease];
            [cancelBtn setBackgroundImage:[UIImage generateColorImage:[UIColor greenColor] size:sendBtn.frame.size] forState:UIControlStateNormal];
            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
            cancelBtn.layer.cornerRadius = 3;
            [cancelBtn addTarget:self action:@selector(dismissSend) forControlEvents:UIControlEventTouchUpInside];
            [sendImageView addSubview:cancelBtn];

        }
    }];
}

- (void)sendImage
{
    if(sendImageView) {
        [UIView animateWithDuration:0.3 animations:^{
            sendImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [sendImageView removeFromSuperview];
            [sendImageView release];
            sendImageView = nil;
        }];
    }
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(120, 160));
    [sendImage drawInRect: CGRectMake(0, 0, 120, 160)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    [self showLoading];
     NSData *imageData = UIImagePNGRepresentation(smallImage);
     PFObject *imageObject = [PFObject objectWithClassName:chatLog];
     [imageObject setObject:imageData forKey:@"image"];
     [imageObject setObject:[PFUser currentUser].username forKey:@"user"];
     [imageObject setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"date"];
     [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (succeeded) {
             [self dismissLoading];
         }
     }];
}

- (void)dismissSend
{
    if(sendImageView) {
        [UIView animateWithDuration:0.3 animations:^{
            sendImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [sendImageView removeFromSuperview];
            [sendImageView release];
            sendImageView = nil;
        }];
    }
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
        label.text = @"发送中...";
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


#pragma mark - Other
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismiss:) name:UIKeyboardWillHideNotification object:nil];
    }
    _data = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSelector:@selector(setTitle) withObject:nil afterDelay:0.5];
    chatLog = [[NSString alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    [self dismissLoading];
}

-(void)dealloc
{
    [super dealloc];
    [title release];
    [textView release];
    [_data release];
    [timer release];
    [timeLable release];
    chatLog = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

@end
