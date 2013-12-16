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
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ChatViewController ()
@end

@implementation ChatViewController
{
    UILabel *title;
    UIView *_textView;
    UITextView *textInput;
    UITableView *msgTable;
    UIView *moreView;
    
    UIButton *recordingBtn;
    UIButton *recordBtn;
    BOOL isRecording;
    UIButton *playBtn;
    UIButton *cameraBtn;
    
    NSString *chatLog;
    NSMutableArray *_data;
    NSTimer *timer;
    UILabel *timeLable;
    
    UIImage *sendImage;
    UIView *sendImageView;
    
    UIView *loadingView;
    
    MPMoviePlayerController *videoPlayer;
    UIWindow *backgroundWindow;
    
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
    NSURL *recordedFile;
    
    NSData *voiceData;
    
    NSString *queryTime;
    NSDate *queryDate;
    BOOL moreViewShow;
    
    CLLocationManager *locationManager;
}
@synthesize user;
@synthesize userImageData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isRecording = NO;
        
        //ALLOC GESTURE
        UITapGestureRecognizer *tapOnScreen = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textInputReturn)] autorelease];
        [self.view addGestureRecognizer:tapOnScreen];
        
        // 导航栏
        UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)] autorelease];
        [nav setBackgroundImage:[UIImage generateColorImage:[UIColor grayColor] size:nav.frame.size] forBarMetrics:UIBarMetricsDefault];
        title = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 70, 5, 140, 30)];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:20];
        title.backgroundColor = [UIColor clearColor];
        [nav addSubview:title];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.frame = CGRectMake(0, 5, 30, 30);
        [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        back.backgroundColor = [UIColor clearColor];
        [back addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backBtn = [[[UIBarButtonItem alloc] initWithCustomView:back] autorelease];
        
        UINavigationItem *navItem = [[[UINavigationItem alloc] init] autorelease];
        navItem.leftBarButtonItem = backBtn;
        [nav pushNavigationItem:navItem animated:NO];
        [self.view addSubview:nav];
        
        // 输入界面以及控件
        _textView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 60)];
        _textView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_textView];
        
        textInput = [[UITextView alloc] initWithFrame:CGRectMake(50, 10, SCREEN_WIDTH - 100, 40)];
        textInput.layer.cornerRadius = 3;
        textInput.layer.borderColor = [UIColor whiteColor].CGColor;
        textInput.layer.borderWidth = 1;
        textInput.backgroundColor = [UIColor whiteColor];
        textInput.font = [UIFont systemFontOfSize:20];
        textInput.returnKeyType = UIReturnKeySend;
        textInput.delegate = self;
        [_textView addSubview:textInput];
        
        recordingBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, SCREEN_WIDTH - 100, 40)];
        [recordingBtn setTitle:@"按住说话" forState:UIControlStateNormal];
        [recordingBtn setBackgroundImage:[UIImage generateColorImage:[UIColor grayColor] size:recordingBtn.frame.size] forState:UIControlStateNormal];
        recordingBtn.layer.borderWidth = 1;
        recordingBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [recordingBtn addTarget:self action:@selector(recording) forControlEvents:UIControlEventTouchDown];
        [recordingBtn addTarget:self action:@selector(sendVoice) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *moreBtn = [[[UIButton alloc] initWithFrame:CGRectMake(textInput.frame.origin.x + textInput.frame.size.width + 5, 10, 40, 40)] autorelease];
        moreBtn.backgroundColor = [UIColor clearColor];
        [moreBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(showAndDismissMoreView) forControlEvents:UIControlEventTouchUpInside];
        [_textView addSubview:moreBtn];
        
        recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
        recordBtn.backgroundColor = [UIColor clearColor];
        [recordBtn setImage:[UIImage imageNamed:@"mic.jpg"] forState:UIControlStateNormal];
        [recordBtn addTarget:self action:@selector(textOrRecord) forControlEvents:UIControlEventTouchUpInside];
        [_textView addSubview:recordBtn];
        
        // 聊天显示
        msgTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 120)];
        msgTable.dataSource = self;
        msgTable.delegate = self;
        msgTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:msgTable];
        
        NSDateFormatter *dateFormatter =[[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        queryDate = [[NSDate date] retain];
        queryTime = [[dateFormatter stringFromDate:queryDate] retain];
        
        timeLable = [[UILabel alloc] init];
        timeLable.textAlignment = NSTextAlignmentCenter;
        timeLable.textColor = [UIColor blackColor];
        timeLable.font = [UIFont systemFontOfSize:14];
        timeLable.text = queryTime;
        
        if (_refreshHeaderView == nil) {
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - msgTable.bounds.size.height, self.view.frame.size.width, msgTable.bounds.size.height)];
            view.delegate = self;
            [msgTable addSubview:view];
            _refreshHeaderView = view;
            [view release];
        }
        
        // 更多功能界面
        moreView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 20, SCREEN_WIDTH, 216)];
        moreView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:moreView];
        moreViewShow = NO;
        
        UIButton *imageBtn = [[[UIButton alloc] initWithFrame:CGRectMake(10, 10, (moreView.frame.size.height - 30) / 2, (moreView.frame.size.height - 30) / 2)] autorelease];
        imageBtn.backgroundColor = [UIColor clearColor];
        [imageBtn setImage:[UIImage imageNamed:@"image"] forState:UIControlStateNormal];
        [imageBtn addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:imageBtn];
        
        cameraBtn = [[[UIButton alloc] initWithFrame:CGRectMake(imageBtn.frame.origin.x + imageBtn.frame.size.width + 10, 10, (moreView.frame.size.height - 30) / 2, (moreView.frame.size.height - 30) / 2)] autorelease];
        [cameraBtn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        cameraBtn.backgroundColor = [UIColor clearColor];
        [cameraBtn addTarget:self action:@selector(cameraCapture) forControlEvents:UIControlEventTouchUpInside];    
        [moreView addSubview:cameraBtn];
        
        UIButton *locationBtn = [[[UIButton alloc] initWithFrame:CGRectMake(cameraBtn.frame.origin.x + cameraBtn.frame.size.width + 10, 10, (moreView.frame.size.height - 30) / 2, (moreView.frame.size.height - 30) / 2)] autorelease];
        locationBtn.backgroundColor = [UIColor clearColor];
        [locationBtn setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        [locationBtn addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:locationBtn];
        
        UIButton *videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, imageBtn.frame.origin.y + imageBtn.frame.size.height + 10, (moreView.frame.size.height - 30) / 2, (moreView.frame.size.height - 30) / 2)];
        videoBtn.backgroundColor = [UIColor clearColor];
        [videoBtn setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
        [videoBtn addTarget:self action:@selector(recordVideo) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:videoBtn];
        
    }
    return self;
}   
    
#pragma mark - show/dismiss moreView    
- (void)showAndDismissMoreView  
{   
    if (moreViewShow) { 
        [UIView animateWithDuration:0.3 animations:^{   
            moreView.frame = CGRectOffset(moreView.frame, 0, 216);  
            moreViewShow = NO;  
                
            CGFloat yOffset = 216;  
            if (_textView.frame.origin.y == SCREEN_HEIGHT - 80) {   
                [textInput resignFirstResponder];   
                return ;    
            }   
                
            CGRect inputFieldRect = _textView.frame;    
            CGRect tableRect = msgTable.frame;  
                
            inputFieldRect.origin.y += yOffset; 
            tableRect.size.height += yOffset;   
            msgTable.frame = tableRect; 
            _textView.frame = inputFieldRect;   
            if (msgTable.contentSize.height > msgTable.frame.size.height) { 
                [msgTable setContentOffset:CGPointMake(0, msgTable.contentSize.height - msgTable.frame.size.height) animated:YES];  
            }   
        }]; 
    }   
    else {  
        if (isRecording) {  
            [self textOrRecord];    
        }   
        [UIView animateWithDuration:0.3 animations:^{   
            moreView.frame = CGRectOffset(moreView.frame, 0, -216); 
            moreViewShow = YES; 
            
            CGFloat yOffset = -216; 
            if (_textView.frame.origin.y == SCREEN_HEIGHT - 296 || _textView.frame.origin.y == SCREEN_HEIGHT - 296 - 24 * 1 || _textView.frame.origin.y == SCREEN_HEIGHT - 296 - 24 * 2) {
                [textInput resignFirstResponder];
                return ;
            }
            if (_textView.frame.origin.y == SCREEN_HEIGHT - 296 - 36 || _textView.frame.origin.y == SCREEN_HEIGHT - 296 - 36 - 24 * 1 || _textView.frame.origin.y == SCREEN_HEIGHT - 296 - 36 - 24 * 2) {
                [textInput resignFirstResponder];
                yOffset = 36;
            }
            
            CGRect inputFieldRect = _textView.frame;
            CGRect tableRect = msgTable.frame;
            
            inputFieldRect.origin.y += yOffset;
            tableRect.size.height += yOffset;
            msgTable.frame = tableRect;
            _textView.frame = inputFieldRect;
            if (msgTable.contentSize.height > msgTable.frame.size.height) {
                [msgTable setContentOffset:CGPointMake(0, msgTable.contentSize.height - msgTable.frame.size.height) animated:YES];
            }
        }];
    }
}

#pragma mark -  back to friendlist
- (void)backToPrev  
{   
    // avoid crash if isRealoading
    if (_reloading) {
        timer = [[NSTimer alloc] init];
    }
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
    PFQuery *query = [PFQuery queryWithClassName:chatLog];
    [query whereKey:@"date" greaterThanOrEqualTo:queryTime];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //NSLog(@"%d+++%d",_data.count, objects.count);
        if (_data.count != objects.count) {
            NSString *lastDate = [[[objects objectAtIndex:0] objectForKey:@"date"] substringToIndex:10];
            timeLable.text = lastDate;
            [_data removeAllObjects];
            [_data addObjectsFromArray:objects];
            [_data retain];
            [msgTable reloadData];
            if (msgTable.contentSize.height > msgTable.frame.size.height) {
                [msgTable setContentOffset:CGPointMake(0, msgTable.contentSize.height - msgTable.frame.size.height) animated:YES];
            }
        }
    }];
}

#pragma mark - textInput delegate
- (void)textInputReturn
{
    if (moreViewShow) {
        [self showAndDismissMoreView];
    }
    [textInput resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 将textView大小存起来
    CGRect textInputRect = textInput.frame;
    CGRect textViewRect = _textView.frame;
    CGRect tableRect = msgTable.frame;
    
    if ([text isEqualToString:@"\n"]) { // send btn
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
        [self textInputReturn];
        textInputRect.size.height = 40;
        textInput.frame = textInputRect;
        textViewRect.size.height = 60;
        textViewRect.origin.y = SCREEN_HEIGHT - 80;
        _textView.frame = textViewRect;
        tableRect.size.height = SCREEN_HEIGHT - 120;
        msgTable.frame = tableRect;
        return YES;
    }
    
    // 动态调整textView大小
    CGSize size = [textInput.text sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(textInput.frame.size.width , CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    //NSLog(@"%f-----%f",size.height,textInput.frame.size.height);
    if (size.height > textInput.frame.size.height - 16 && textInput.frame.size.height < 88) {
        textViewRect.size.height += 24;
        textViewRect.origin.y -= 24;
        _textView.frame = textViewRect;
        textInputRect.size.height += 24;
        textInput.frame = textInputRect;
        tableRect.size.height -= 24;
        msgTable.frame = tableRect;
    }
    if (textInput.frame.size.height > 40 && size.height < textInput.frame.size.height - 16) {
        textViewRect.size.height -= 24;
        textViewRect.origin.y += 24;
        _textView.frame = textViewRect;
        textInputRect.size.height -= 24;
        textInput.frame = textInputRect;
        tableRect.size.height += 24;
        msgTable.frame = tableRect;
    }
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
    [_textView setFrame:CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y - keyboardFrame.size.height, _textView.frame.size.width, _textView.frame.size.height)];
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
    [_textView setFrame:CGRectMake(_textView.frame.origin.x, _textView.frame.origin.y + keyboardFrame.size.height, _textView.frame.size.width, _textView.frame.size.height)];
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

    if (yOffset == -216 && moreViewShow) {
        moreView.frame = CGRectOffset(moreView.frame, 0, 216);
        moreViewShow = NO;
    }
    if ((yOffset == -216 && _textView.frame.origin.y == SCREEN_HEIGHT - 296 - 24 * 1 ) || (yOffset == -216 && _textView.frame.origin.y == SCREEN_HEIGHT - 296 - 24 * 2 ) || (yOffset == -216 && _textView.frame.origin.y == SCREEN_HEIGHT - 296) || (yOffset == 216 && moreViewShow)) {
        return;
    }
    if (yOffset == 252 && moreViewShow) {
        return;
    }
    
    CGRect inputFieldRect = _textView.frame;
    CGRect tableRect = msgTable.frame;
    
    inputFieldRect.origin.y += yOffset;
    tableRect.size.height += yOffset;
    msgTable.frame = tableRect;
    [UIView animateWithDuration:duration animations:^{
        _textView.frame = inputFieldRect;
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
    CGSize msgSize = [msgStr sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 70, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
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
        if (msgSize.height != 0) {
            [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, msgSize.height + 30)];
        }
        else{
            [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        }
    }
    
    if ([[[_data objectAtIndex:indexPath.row] objectForKey:@"user"] isEqualToString:[PFUser currentUser].username]) {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, cell.frame.size.height - 45, 40, 40)] autorelease];
        if ([[PFUser currentUser] objectForKey:@"image"] == nil || [[[PFUser currentUser] objectForKey:@"image"] isEqualToData:[NSData dataWithBytes:nil length:0]]) {
            imageView.image = [UIImage imageNamed:@"Mushroom"];
        }
        else imageView.image = [UIImage imageWithData:[[PFUser currentUser] objectForKey:@"image"]];
        [cell addSubview:imageView];
        
        if ([[_data objectAtIndex:indexPath.row] objectForKey:@"voice"] != nil || [[_data objectAtIndex:indexPath.row] objectForKey:@"video"] != nil) {
            playBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 20, 100, 30)];
            [playBtn setTitle:@"播放" forState:UIControlStateNormal];
            playBtn.tag = indexPath.row;
            playBtn.backgroundColor = [UIColor greenColor];
            playBtn.layer.cornerRadius = 5;
            playBtn.layer.borderWidth = 1;
            playBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            if ([[_data objectAtIndex:indexPath.row] objectForKey:@"voice"] != nil) {
                [playBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            }
            [cell addSubview:playBtn];
        }
    }
    else {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, cell.frame.size.height - 45, 40, 40)] autorelease];
        if (userImageData == nil || [userImageData isEqualToData:[NSData dataWithBytes:nil length:0]]) {
            imageView.image = [UIImage imageNamed:@"Mushroom"];
        }
        else imageView.image = [UIImage imageWithData:userImageData];
        [cell addSubview:imageView];
        
        if ([[_data objectAtIndex:indexPath.row] objectForKey:@"voice"] != nil || [[_data objectAtIndex:indexPath.row] objectForKey:@"video"] != nil) {
            PFFile *voice = [[_data objectAtIndex:indexPath.row] objectForKey:@"voice"];
            voiceData = [voice.getData retain];
            playBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 160, 20, 100, 30)];
            [playBtn setTitle:@"播放" forState:UIControlStateNormal];
            playBtn.tag = indexPath.row;
            playBtn.backgroundColor = [UIColor blueColor];
            playBtn.layer.cornerRadius = 5;
            playBtn.layer.borderWidth = 1;
            playBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            if ([[_data objectAtIndex:indexPath.row] objectForKey:@"voice"] != nil) {
                [playBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            }
            [cell addSubview:playBtn];
        }
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    msgTable.tableHeaderView = timeLable;
    return timeLable;
}

#pragma mark - PickImage/Video
- (void)recordVideo
{
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.allowsEditing = YES;
    videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    videoPicker.videoQuality = UIImagePickerControllerQualityType640x480;
    
    NSArray *sourceTypes =
    [UIImagePickerController availableMediaTypesForSourceType:videoPicker.sourceType];
    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ]){
        NSLog(@"Can't save videos");
    }
    [self presentModalViewController:videoPicker animated:YES];
    [videoPicker release];
}

- (void)cameraCapture
{
    [self textInputReturn];
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.delegate = self;
    imagepicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagepicker animated:YES completion:^{
    }];
    [imagepicker release];
}

- (void)pickImage
{
    [self textInputReturn];
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.delegate = self;
    imagepicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepicker animated:YES completion:^{
    }];
    [imagepicker release];
}
    
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        // video type
        if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            [self showLoading];
            PFFile *file = [PFFile fileWithData:[NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]]];
            PFObject *videoObject = [PFObject objectWithClassName:chatLog];
            [videoObject setObject:file forKey:@"video"];
            [videoObject setObject:[PFUser currentUser].username forKey:@"user"];
            [videoObject setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"date"];
            [videoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self dismissLoading];
                }
                else {
                    [self dismissLoading];
                }
            }];
            return;
        }
        sendImage = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(120, 160));
        [sendImage drawInRect: CGRectMake(0, 0, 120, 160)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (!sendImageView) {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            sendImageView = [[UIView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT/2 - 120, SCREEN_WIDTH -  40, 240)];
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
            
            UIButton *cancelBtn = [[[UIButton alloc]initWithFrame:CGRectMake(sendImageView.frame.size.width/2 + 5,  180, sendImageView.frame.size.width/2 - 15, 50)] autorelease];
            [cancelBtn setBackgroundImage:[UIImage generateColorImage:[UIColor greenColor] size:sendBtn.frame.size  ] forState:UIControlStateNormal];
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

#pragma mark - sendVoice
- (void)textOrRecord
{
    if (isRecording)
    {
        isRecording = NO;
        [recordingBtn removeFromSuperview];
        [_textView addSubview:textInput];
        [recordBtn setImage:[UIImage imageNamed:@"mic.jpg"] forState:UIControlStateNormal];
        [textInput becomeFirstResponder];
    }
    else
    {
        isRecording = YES;
        [self textInputReturn];
        [textInput removeFromSuperview];
        [_textView addSubview:recordingBtn];
        [recordBtn setImage:[UIImage imageNamed:@"Text"] forState:UIControlStateNormal];
    }
}

- (void)recording
{
    [self viewWillDisappear:YES];
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:nil error:nil];
    [recorder prepareToRecord];
    [recorder record];
    //NSLog(@"%@",[NSData dataWithContentsOfURL:recordedFile]);
}

- (void)sendVoice
{
    [recorder stop];
    [self showLoading];
    PFFile *file = [PFFile fileWithData:[NSData dataWithContentsOfURL:recordedFile]];
    PFObject *voiceObject = [PFObject objectWithClassName:chatLog];
    [voiceObject setObject:file forKey:@"voice"];
    [voiceObject setObject:[PFUser currentUser].username forKey:@"user"];
    [voiceObject setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"date"];
    [voiceObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self dismissLoading];
        }
        else {
            [self dismissLoading];
        }
    }];
    [self viewWillAppear:YES];
}

#pragma mark - playVoice
- (void)playVoice :(id)sender
{
    PFFile *voice = [[_data objectAtIndex:[sender tag]] objectForKey:@"voice"];
    voiceData = [voice.getData retain];
    player = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
    [player play];
}

#pragma mark - playVideo
- (void)playVideo :(id)sender
{
    PFFile *video = [[_data objectAtIndex:[sender tag]] objectForKey:@"video"];
    NSData *videoData = [video.getData retain];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myMovie.mp4"];
    
    [videoData writeToFile:path atomically:YES];
    NSURL *movieUrl = [NSURL fileURLWithPath:path];
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
    videoPlayer.controlStyle = MPMovieControlStyleFullscreen;
    //videoPlayer.view.transform = CGAffineTransformConcat(videoPlayer.view.transform, CGAffineTransformMakeRotation(M_PI_2));
    backgroundWindow = [[UIApplication sharedApplication] keyWindow];
    [videoPlayer.view setFrame:backgroundWindow.frame];
    [backgroundWindow addSubview:videoPlayer.view];
    [videoPlayer play];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(MovieEnd) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)MovieEnd
{
    [backgroundWindow removeFromSuperview];
    [videoPlayer.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

#pragma mark - sendLocation
 - (void)sendLocation
{
    locationManager = [[CLLocationManager alloc] init] ;
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 100;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation != nil) {
        [locationManager stopUpdatingLocation];
    }
    //CLLocationCoordinate2D loc = [newLocation coordinate];
    //float longitude = loc.longitude;
    //float latitude = loc.latitude;
    CLGeocoder *geoCoder = [[[CLGeocoder alloc] init] autorelease];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSString *locString = [[[NSString alloc] init] autorelease];
        if (placemark.thoroughfare != nil) {
            locString = [NSString stringWithFormat:@"我在: %@,%@,%@", placemark.country,placemark.administrativeArea, placemark.thoroughfare];
        }
        if (![locString isEqualToString:@""] && ![chatLog isEqualToString:@""])
        {
            [self showLoading];
            NSData *msgData = [locString dataUsingEncoding:NSUTF8StringEncoding];
            PFObject *sendObjects = [PFObject objectWithClassName:chatLog];
            [sendObjects setObject:msgData forKey:@"msg"];
            [sendObjects setObject:[PFUser currentUser].username forKey:@"user"];
            [sendObjects setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"date"];
            [sendObjects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self dismissLoading];
                }
            }];
        }
    }];
    [self textInputReturn];
}

#pragma mark - show Loading
- (void)showLoading
{
    if (!loadingView) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT / 2 - 30, 80,   60)];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.7;
        loadingView.layer.cornerRadius = 3;
        [window addSubview:loadingView];
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 30, 80, 30)] autorelease];
        label.text = @"发送中";
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

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    [self viewWillDisappear:YES];
    NSDateFormatter *dateFormatter =[[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    queryDate = [[NSDate dateWithTimeInterval: -24*60*60 sinceDate:queryDate] retain];
    queryTime = [[dateFormatter stringFromDate:queryDate] retain];
	_reloading = YES;
    
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:msgTable];
	[self viewWillAppear:YES];
    
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - Other    
- (void)viewDidLoad 
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:   UIKeyboardWillChangeFrameNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:  UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismiss:) name:   UIKeyboardWillHideNotification object:nil];
    }
    [self performSelector:@selector(setTitle) withObject:nil afterDelay:2];
    chatLog = [[NSString alloc] init];
    _data = [[NSMutableArray alloc] init];
    
    recordedFile = [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]] retain];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadMsgData) userInfo:nil repeats:YES];
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
    [_textView release];
    [_data release];
    [timer release];
    [timeLable release];
    [recordBtn release];
    [recordingBtn release];
    [player release];
    [recorder release];
    [playBtn release];
    [_refreshHeaderView release];
    [moreView release];
    [locationManager release];
    [videoPlayer release];
    [backgroundWindow release];
    recordedFile = nil;
    chatLog = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

@end
