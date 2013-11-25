//
//  UIImage+Utility.m
//  Demo
//
//  Created by Jiao Liu on 11/20/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

+ (UIImage *)generateColorImage:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImage;
}

@end
