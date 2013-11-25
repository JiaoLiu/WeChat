//
//  AppDelegate.h
//  WeChat
//
//  Created by Jiao Liu on 11/22/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "loginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    loginViewController *loginView;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic , readonly) loginViewController *loginView;

@end
