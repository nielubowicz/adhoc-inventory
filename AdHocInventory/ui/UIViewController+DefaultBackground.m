//
//  UIViewController+DefaultBackground.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 10/6/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "UIViewController+DefaultBackground.h"

@implementation UIViewController (DefaultBackground)

- (void) setDefaultBackground
{
    CGFloat width = 8.0f;
    CGRect rect = CGRectMake(0.0f, 0.0f, width, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.75 alpha:1.0] CGColor]);
    CGRect leftRect = CGRectMake(0.0f, 0.0f, width/2.0f, 1.0f);
    CGContextFillRect(context, leftRect);
    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.85 alpha:1.0] CGColor]);
    CGRect rightRect = CGRectMake(width/2.0f, 0.0f, width/2.0f, 1.0f);
    CGContextFillRect(context, rightRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *pattern = [UIColor colorWithPatternImage:image];
    [[self view] setBackgroundColor:pattern];
}

@end
