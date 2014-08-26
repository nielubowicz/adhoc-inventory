//
//  FirstViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/11/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "InputViewController.h"
#import "InventoryDataManager.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemAdded:) name:kInventoryItemAddedNotification object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)addItem:(id)sender
{
    InventoryDataManager *db = [InventoryDataManager sharedManager];

    if ([[description text] length] == 0)
    {
        return;
    }
    
    if ([[category text] length] == 0)
    {
        return;
    }
    
    [db addItem:[description text] category:[category text]];
    [description setText:@""];
    [category setText:@""];
    
    [description resignFirstResponder];
    [category resignFirstResponder];
}

-(void)itemAdded:(NSNotification *)notification
{
    InventoryItem *item = [notification object];
    CIImage *qrcode = [BarcodeGenerator qrcodeImageForInventoryItem:item];
    [barcode setImage:[UIImage createNonInterpolatedUIImageFromCIImage:qrcode withScale:1.0f]];
}

@end
