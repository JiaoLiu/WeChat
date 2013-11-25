//
//  AppDelegate.m
//  WeChat
//
//  Created by Jiao Liu on 11/22/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import "loginViewController.h"

@implementation AppDelegate
@synthesize loginView;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"oiwE05WPJsNJuUw0P2zD3DeMGlAs0T2WgZHBGRiu" clientKey:@"xfhAuxDp577F5JX5at1zh6FoPwct6M7acX8lGISp"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notify" message:@"No Internet Connection!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
    loginView = [[loginViewController alloc] init];
    self.window.rootViewController = loginView;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notify" message:@"No Internet Connection!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
