//
//  UIViewController+DefaultBackground.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 10/6/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "UIViewController+DefaultBackground.h"

@implementation UIViewController (DefaultBackground)

static const UIColor *lightColor = nil;
static const UIColor *darkColor = nil;

- (void) setDefaultBackground
{
    if (lightColor == nil) {
        lightColor = [UIColor colorWithRed:255/255.0 green:237/255.0 blue:229/255.0 alpha:1.0];
    }
    
    if (darkColor == nil) {
        darkColor = [UIColor colorWithRed:242/255.0 green:226/255.0 blue:210/255.0 alpha:1.0];
    }

    CGFloat width = 8.0f;
    CGRect rect = CGRectMake(0.0f, 0.0f, width, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [lightColor CGColor]);
    CGRect leftRect = CGRectMake(0.0f, 0.0f, width/2.0f, 1.0f);
    CGContextFillRect(context, leftRect);
    
    CGContextSetFillColorWithColor(context, [darkColor CGColor]);
    CGRect rightRect = CGRectMake(width/2.0f, 0.0f, width/2.0f, 1.0f);
    CGContextFillRect(context, rightRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *pattern = [UIColor colorWithPatternImage:image];
    [[self view] setBackgroundColor:pattern];
}

@end
