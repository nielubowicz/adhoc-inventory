//
//  CategoryAnalyticsViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 10/1/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "CategoryAnalyticsViewController.h"

@interface CategoryAnalyticsViewController ()

@end

@implementation CategoryAnalyticsViewController

@synthesize analyticsQuery;
@synthesize category;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setDefaultBackground];
    [self setParseClassName:kPFInventoryClassName];
    [self setTitle:category];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    return [self analyticsQuery];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
