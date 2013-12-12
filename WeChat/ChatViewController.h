//
//  ChatViewController.h
//  WeChat
//
//  Created by Jiao Liu on 11/25/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface ChatViewController : UIViewController <UIAlertViewDelegate,UITableViewDataSource,UITextViewDelegate,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,EGORefreshTableHeaderDelegate>
{
    NSString *user;
    NSData *userImageData;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSData *userImageData;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
