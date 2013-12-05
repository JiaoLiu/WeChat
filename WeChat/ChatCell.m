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
    UIImageView *bubbleImage;
    
    UIView *cellFrame;
}

- (void)setData:(NSDictionary *)data
{
    NSString *msgStr = [[NSString alloc] initWithData:[data objectForKey:@"msg"] encoding:NSUTF8StringEncoding];
    CGSize msgSize = [msgStr sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 70, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if ([data objectForKey:@"image"] != nil ) {
        [cellFrame setFrame:CGRectMake(0, 10, SCREEN_WIDTH, 160)];
        if ([[data objectForKey:@"user"] isEqualToString:[PFUser currentUser].username]) {
            outImage.image = [UIImage imageWithData:[data objectForKey:@"image"]];
            [cellFrame addSubview:outImage];
        }
        else {
            inImage.image = [UIImage imageWithData:[data objectForKey:@"image"]];
            [cellFrame addSubview:inImage];
        }
    }
    else
    {
        [cellFrame setFrame:CGRectMake(0, 10, SCREEN_WIDTH, msgSize.height)];
        if ([[data objectForKey:@"user"] isEqualToString:[PFUser currentUser].username]) {
            if (msgStr.length > 0) {
                bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
            }
            [outMsg setFrame:CGRectMake(60, 0, msgSize.width, msgSize.height)];
            bubbleImage.frame = CGRectMake(60 - 10,  - 4, outMsg.frame.size.width + 20, outMsg.frame.size.height + 15);
            outMsg.text = msgStr;
            [cellFrame addSubview:bubbleImage];
            [cellFrame addSubview:outMsg];
        }
        else {
            if (msgStr.length > 0) {
                bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
            }
            [inMsg setFrame:CGRectMake(SCREEN_WIDTH - msgSize.width - 60, 0, msgSize.width, msgSize.height)];
             bubbleImage.frame = CGRectMake(inMsg.frame.origin.x - 8,  - 4, inMsg.frame.size.width + 20, inMsg.frame.size.height + 15);
            inMsg.text = msgStr;
            [cellFrame addSubview:bubbleImage];
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
        [inMsg setTextAlignment:NSTextAlignmentLeft];
        inMsg.font = [UIFont systemFontOfSize:17];
        inMsg.textColor = [UIColor blueColor];
        inMsg.backgroundColor = [UIColor clearColor];
        inMsg.numberOfLines = 0;
        
        outMsg = [[[UILabel alloc] init] autorelease];
        outMsg.textColor = [UIColor grayColor];
        [outMsg setTextAlignment:NSTextAlignmentLeft];
        outMsg.font = [UIFont systemFontOfSize:17];
        outMsg.backgroundColor = [UIColor clearColor];
        outMsg.numberOfLines = 0;
        
        inImage = [[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 180, 0, 120, 160)] autorelease];
        outImage = [[[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 120, 160)] autorelease];
        
        bubbleImage = [[[UIImageView alloc] init] autorelease];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}   
@end