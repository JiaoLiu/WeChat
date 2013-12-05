//
//  friendlistViewController.m
//  WeChat
//
//  Created by Jiao Liu on 11/22/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "friendlistViewController.h"
#import "loginViewController.h"
#import "UIImage+Utility.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "ChatViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface friendlistViewController ()
{
    UITableView *friendlistTable;
    NSMutableArray *data;
    
    UIView *loadingView;
    NSMutableDictionary *dic;
}

@end

@implementation friendlistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)] autorelease];
        [nav setBackgroundImage:[UIImage generateColorImage:[UIColor grayColor] size:nav.frame.size] forBarMetrics:UIBarMetricsDefault];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 30, 5, 60, 30)];
        title.text = @"用户";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:20];
        title.backgroundColor = [UIColor clearColor];
        [nav addSubview:title];
        
        UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
        logout.frame = CGRectMake(0, 5, 30, 30);
        [logout setImage:[UIImage imageNamed:@"logout.jpg"] forState:UIControlStateNormal];
        logout.backgroundColor = [UIColor clearColor];
        [logout addTarget:self action:@selector(alertLogout) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *logoutBtn = [[[UIBarButtonItem alloc] initWithCustomView:logout] autorelease];
        
        UINavigationItem *navItem = [[[UINavigationItem alloc] init] autorelease];
        navItem.rightBarButtonItem = logoutBtn;
        [nav pushNavigationItem:navItem animated:NO];
        [self.view addSubview:nav];
        
        friendlistTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 60)] autorelease];
        friendlistTable.dataSource = self;
        friendlistTable.delegate = self;
        friendlistTable.rowHeight = 60;
        [self.view addSubview:friendlistTable];
        
        
        data = [[NSMutableArray alloc] init];
        
        [self loadFriendData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissLoading];
}

#pragma mark - logout
- (void)alertLogout
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Are you sure to logout?" delegate:self cancelButtonTitle:@"Logout" otherButtonTitles:@"Cancel", nil];
    alert.delegate = self;
    alert.tag = 100;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        switch (buttonIndex) {
            case 0:
                [self logout];
                break;    
            default:
                break;
        }
    }
}

- (void)logout
{
    [PFUser logOut];
    self.view.alpha = 0;
    loginViewController *loginView = [[[loginViewController alloc] init] autorelease];
    [self presentViewController:loginView animated:YES completion:^{
        [self.view removeFromSuperview];
    }];
}

#pragma mark - LoadUser
- (void)loadFriendData
{
    [self showLoading];
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"_User"];
    [query addAscendingOrder:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [data addObjectsFromArray:objects];
        for (int i = 0; i < data.count; i++) {
            if ([[[data objectAtIndex:i] objectForKey:@"username"] isEqualToString: [PFUser currentUser].username]) {
                [data removeObjectAtIndex:i];
            }
        }
        // 按A-Z分组
        dic = [[[NSMutableDictionary alloc] init] autorelease];
        for (int i = 0; i < 26; i ++) {
            NSMutableArray *temp = [[[NSMutableArray alloc] init] autorelease];
            for (int j = 0; j < data.count; j ++ ) {
                const char *cstr = [[[data objectAtIndex:j] objectForKey:@"username"] UTF8String];
                if (cstr[0] == 'A' + i || cstr [0] == 'a' + i) {
                    [temp addObject:[data objectAtIndex:j]];
                }
                [temp retain];
            }
            [dic setObject:temp forKey:[NSString stringWithFormat:@"%c",'A' + i]];
            [dic retain];
        }
        // 分＃组
        NSMutableArray *temp = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < data.count; i ++) {
            const char *cstr = [[[data objectAtIndex:i] objectForKey:@"username"] UTF8String];
            if (!((cstr[0] >= 'A' && cstr [0] <= 'Z') || (cstr[0] >= 'a' && cstr [0] <= 'z'))) {
                [temp addObject:[data objectAtIndex:i]];
            }
            [temp retain];
        }
        [dic setObject:temp forKey:@"#"];
        [dic retain];
    
        [friendlistTable reloadData];
        [self dismissLoading];
    }];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 27;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 26) {
        return [[dic objectForKey:@"#"] count];
    }
    return [[dic objectForKey:[NSString stringWithFormat:@"%c",'A' + section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"FrindCell%ld",(long)indexPath.row];
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    UILabel *namelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 40)];
    //namelabel.text = [[data objectAtIndex:indexPath.row] objectForKey:@"username"];
    if (indexPath.section == 26) {
        namelabel.text = [[[dic objectForKey:@"#"] objectAtIndex:indexPath.row] objectForKey:@"username"];
    }
    else {
        namelabel.text = [[[dic objectForKey:[NSString stringWithFormat:@"%c",'A' + indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"username"];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    //UIImage *icon = [UIImage imageWithData:[[data objectAtIndex:indexPath.row] objectForKey:@"image"]];
    UIImage *icon = [[[UIImage alloc] init] autorelease];
    if (indexPath.section == 26) {
        icon = [UIImage imageWithData:[[[dic objectForKey:@"#"] objectAtIndex:indexPath.row] objectForKey:@"image"]];
    }
    else
    {
        icon = [UIImage imageWithData:[[[dic objectForKey:[NSString stringWithFormat:@"%c",'A' + indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"image"]];
    }
    imageView.image = icon;
    if (icon != nil) {
        [namelabel setFrame:CGRectMake(60, 10, SCREEN_WIDTH - 70, 40)];
        [cell addSubview:imageView];
    }
    
    [cell addSubview:namelabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *user = [[[NSString alloc] init] autorelease];
    NSData *imageData = [[[NSData alloc] init] autorelease];
    if (indexPath.section == 26) {
        user = [[[dic objectForKey:@"#"] objectAtIndex:indexPath.row] objectForKey:@"username"];
        imageData = [[[dic objectForKey:@"#"] objectAtIndex:indexPath.row] objectForKey:@"image"];
    }
    else
    {
        user = [[[dic objectForKey:[NSString stringWithFormat:@"%c",'A' + indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"username"];
        imageData = [[[dic objectForKey:[NSString stringWithFormat:@"%c",'A' + indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"image"];
    }
    
    ChatViewController *chatView = [[[ChatViewController alloc] init] autorelease];
    self.view.alpha = 0;
    [self presentViewController:chatView animated:YES completion:^{
        chatView.user = [user retain];
        chatView.userImageData = [imageData retain];
        [self.view removeFromSuperview];
    }];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *charArray = [NSMutableArray array];
    for (int i = 0; i < 26; i++) {
        char c = 65 + i;
        NSString* s = [NSString stringWithFormat:@"%c", c];
        s = [s uppercaseString];
        
        [charArray addObject:s];
    }
    
    [charArray addObject:@"#"];
    
    return [NSArray arrayWithArray:charArray];
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
        label.text = @"加载中...";
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

@end
