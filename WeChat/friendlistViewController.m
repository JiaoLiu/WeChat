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

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface friendlistViewController ()
{
    UITableView *friendlistTable;
    NSMutableArray *data;
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
        logout.layer.borderWidth = 1;
        logout.layer.cornerRadius = 10;
        logout.layer.borderColor = [UIColor lightGrayColor].CGColor;
        logout.backgroundColor = [UIColor grayColor];
        [logout setTitle:@"X" forState:UIControlStateNormal];
        [logout addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem *logoutBtn = [[[UIBarButtonItem alloc] initWithCustomView:logout] autorelease];
        
        UINavigationItem *navItem = [[[UINavigationItem alloc] init] autorelease];
        navItem.rightBarButtonItem = logoutBtn;
        [nav pushNavigationItem:navItem animated:NO];
        [self.view addSubview:nav];
        
        friendlistTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40)] autorelease];
        friendlistTable.dataSource = self;
        friendlistTable.delegate = self;
        friendlistTable.rowHeight = 60;
        [self.view addSubview:friendlistTable];
        
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

- (void)logout
{
    [PFUser logOut];
    self.view.alpha = 0;
    loginViewController *loginView = [[[loginViewController alloc] init] autorelease];
    [self presentViewController:loginView animated:YES completion:^{
        [self.view removeFromSuperview];
    }];
}

- (void)loadFriendData
{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"_User"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [data addObjectsFromArray:objects];
        NSLog( @"%@",objects);
        [friendlistTable reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"FrindCell%ld",(long)indexPath.row];
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    UILabel *namelabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 40)] autorelease];
    namelabel.text = [[data objectAtIndex:indexPath.row] objectForKey:@"username"];
    [cell.contentView addSubview:namelabel];
    return cell;
}

@end
