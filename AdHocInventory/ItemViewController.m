//
//  ItemViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/15/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "ItemViewController.h"
#import "InventoryItem.h"
#import "BarcodeGenerator.h"

@interface ItemViewController ()

@end

@implementation ItemViewController

@synthesize item;

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
    
    [_categoryLabel setText:[item category]];
    [_descriptionLabel setText:[item description]];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE HH:mm, MM/d/yyyy"];
    [_dateReceivedLabel setText:[formatter stringFromDate:[item dateReceived]]];
    
    [_barcodeView setImage:[UIImage createNonInterpolatedUIImageFromCIImage:[BarcodeGenerator qrcodeImageForInventoryItem:item]
                                                                  withScale:1.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sellItem:(id)sender
{
    NSLog(@"Not implemented yet. Item will be removed from inventory table or otherwise marked.");
    [self performSegueWithIdentifier:@"dismiss" sender:_sellButton];

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