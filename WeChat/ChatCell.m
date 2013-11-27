//
//  ChatCell.m
//  WeChat
//
//  Created by Jiao Liu on 11/26/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "ChatCell.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "UIImage+Utility.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@implementation ChatCell
{
    UILabel *inMsg;
    UILabel *outMsg;
    UIImageView *inImage;
    UIImageView *outImage;
    
    UIView *cellFrame;
}

- (void)setData:(NSDictionary *)data
{
    CGSize msgSize = [[data  objectForKey:@"msg"] sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 40, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if ([data objectForKey:@"image"] != nil ) {
        PFFile *image = (PFFile *)[data objectForKey:@"image"];
        [cellFrame setFrame:CGRectMake(0, 10, SCREEN_WIDTH, 160)];
        if ([[data objectForKey:@"user"] isEqualToString:[PFUser currentUser].username]) {
            outImage.image = [UIImage imageWithData:image.getData];
            [cellFrame addSubview:outImage];
        }
        else {
            inImage.image = [UIImage imageWithData:image.getData];
            [cellFrame addSubview:inImage];
        }
    }
    else
    {
        [cellFrame setFrame:CGRectMake(0, 10, SCREEN_WIDTH, msgSize.height)];
        if ([[data objectForKey:@"user"] isEqualToString:[PFUser currentUser].username]) {
            [outMsg setFrame:CGRectMake(20, 0, msgSize.width, msgSize.height)];
            outMsg.text = [data objectForKey:@"msg"];
            [cellFrame addSubview:outMsg];
        }
        else {
            [inMsg setFrame:CGRectMake(SCREEN_WIDTH - msgSize.width - 20, 0, msgSize.width, msgSize.height)];
            inMsg.text = [data objectForKey:@"msg"];
            [cellFrame addSubview:inMsg];
        }

    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellFrame = [[[UIView alloc] init] autorelease];
        [self addSubview:cellFrame];
        
        inMsg = [[[UILabel alloc] init] autorelease];
        [inMsg setTextAlignment:NSTextAlignmentRight];
        inMsg.font = [UIFont systemFontOfSize:20];
        inMsg.textColor = [UIColor blueColor];
        inMsg.numberOfLines = 0;
        
        outMsg = [[[UILabel alloc] init] autorelease];
        outMsg.textColor = [UIColor grayColor];
        [outMsg setTextAlignment:NSTextAlignmentLeft];
        outMsg.font = [UIFont systemFontOfSize:20];
        outMsg.numberOfLines = 0;
        
        inImage = [[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 130, 0, 120, 160)] autorelease];
        outImage = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 120, 160)] autorelease];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}   
@end