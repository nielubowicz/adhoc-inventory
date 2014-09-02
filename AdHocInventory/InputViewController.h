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

@interface InputViewController : UIViewController <PFSignUpViewControllerDelegate,PFLogInViewControllerDelegate>

@property (weak,nonatomic)IBOutlet HTAutocompleteTextField *category;
@property (weak,nonatomic)IBOutlet UITextField *description;
@property (weak,nonatomic)IBOutlet UITextField *notes;

-(IBAction)addItem:(id)sender;

@end
