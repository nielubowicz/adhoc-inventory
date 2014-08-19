//
//  DismissSegue.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/18/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
