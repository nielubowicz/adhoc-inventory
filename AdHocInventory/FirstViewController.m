//
//  FirstViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/11/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "FirstViewController.h"
#import "DatabaseManager.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize description;
@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)addItem:(id)sender
{
    DatabaseManager *db = [DatabaseManager sharedManager];

    [db addItem:[description text] category:[category text]];
    [description setText:@""];
    [category setText:@""];
    
    [description resignFirstResponder];
    [category resignFirstResponder];
}

@end
