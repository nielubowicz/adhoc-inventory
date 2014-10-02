//
//  CategoryAnalyticsViewController.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 10/1/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <Parse/Parse.h>

@interface CategoryAnalyticsViewController : PFQueryTableViewController

@property (strong, nonatomic) PFQuery *analyticsQuery;
@property (strong, nonatomic) NSString *category;

@end
