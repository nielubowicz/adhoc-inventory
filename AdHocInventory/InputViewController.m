//
//  FirstViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/11/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "InputViewController.h"
#import "DatabaseManager.h"
#import "BarcodeGenerator.h"
#import "InventoryItem.h"

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize description;
@synthesize category;
@synthesize barcode;

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

    NSUInteger inventoryID = [db addItem:[description text] category:[category text]];
    [description setText:@""];
    [category setText:@""];
    
    [description resignFirstResponder];
    [category resignFirstResponder];
    
    [barcode setImage:[BarcodeGenerator generateBarcodeForInventoryID:inventoryID]];
}

@end