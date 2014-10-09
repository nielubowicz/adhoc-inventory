//
//  NewOrganizationViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 9/18/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "NewOrganizationViewController.h"
#import "InventoryDataManager.h"
#import "HTAutocompleteManager.h"

@interface NewOrganizationViewController ()

@end

@implementation NewOrganizationViewController

@synthesize name;
@synthesize city;
@synthesize state;

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
    
    [self setDefaultBackground];
    [state setAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    [state setAutocompleteType:HTAutocompleteTypeUSState];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addOrganization:(id)sender
{
    // TODO: verify inputs
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newOrganizationAdded:)
                                                 name:kOrganizationAddedNotification object:nil];
    // add organization
    [[InventoryDataManager sharedManager] addOrganization:[name text]
                                                     city:[city text]
                                                    state:[state text]];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
}

- (IBAction)handleSingleTap:(id)sender
{
    [[[self view] subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj resignFirstResponder];
    }];
}

- (void)newOrganizationAdded:(NSNotification *)notification
{
    [self performSegueWithIdentifier:@"dismissItem" sender:self];
}

@end
