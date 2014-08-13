//
//  FirstViewController.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/11/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController

@property (strong,nonatomic)IBOutlet UITextField *category;
@property (strong,nonatomic)IBOutlet UITextField *description;

-(IBAction)addItem:(id)sender;

@end
