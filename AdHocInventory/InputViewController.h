//
//  FirstViewController.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/11/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class HTAutocompleteTextField;

@interface InputViewController : UIViewController <PFSignUpViewControllerDelegate,PFLogInViewControllerDelegate,UITextFieldDelegate>

@property (weak,nonatomic)IBOutlet HTAutocompleteTextField *category;
@property (weak,nonatomic)IBOutlet UITextField *itemDescription;
@property (weak,nonatomic)IBOutlet UITextField *notes;
@property (weak,nonatomic)IBOutlet UIStepper *quantityStepper;
@property (weak,nonatomic)IBOutlet UILabel *quantity;

- (IBAction)addItem:(id)sender;
- (IBAction)handleSingleTap:(id)sender;
- (IBAction)updateQuantity:(UIStepper *)sender;

- (IBAction)logout:(id)sender;
@end
