//
//  NewOrganizationViewController.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 9/18/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTAutocompleteTextField;

@interface NewOrganizationViewController : UIViewController

@property(weak,nonatomic) IBOutlet UITextField *name;
@property(weak,nonatomic) IBOutlet UITextField *city;
@property(weak,nonatomic) IBOutlet HTAutocompleteTextField *state;


- (IBAction)handleSingleTap:(id)sender;

@end
