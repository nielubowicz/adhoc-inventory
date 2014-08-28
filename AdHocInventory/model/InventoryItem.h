//
//  InventoryItem.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/12/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFObject;

@interface InventoryItem : NSObject

-(id)initWithPFObject:(PFObject *)object;

@property(strong,nonatomic)NSString *inventoryID;
@property(strong,nonatomic)NSString *category;
@property(strong,nonatomic)NSString *itemDescription;
@property(strong,nonatomic)NSString *notes;
@property(strong,nonatomic)NSDate *dateReceived;
@property(strong,nonatomic)NSDate *dateSold;

@property(strong,nonatomic)UIImage *qrCode;

@end
