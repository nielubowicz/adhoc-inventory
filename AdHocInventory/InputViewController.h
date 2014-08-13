//
//  FirstViewController.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/11/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputViewController : UIViewController

@property (strong,nonatomic)IBOutlet UITextField *category;
@property (strong,nonatomic)IBOutlet UITextField *description;
@property (strong,nonatomic)IBOutlet UIImageView *barcode;

-(IBAction)addItem:(id)sender;

@end
