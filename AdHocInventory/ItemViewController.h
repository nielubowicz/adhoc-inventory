//
//  ItemViewController.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/15/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InventoryItem;

@interface ItemViewController : UIViewController

@property (nonatomic) InventoryItem *item;

@property (nonatomic) IBOutlet UILabel *categoryLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet UILabel *dateReceivedLabel;
@property (nonatomic) IBOutlet UIImageView *barcodeView;
@property (nonatomic) IBOutlet UIButton *sellButton;

-(IBAction)sellItem:(id)sender;

@end
