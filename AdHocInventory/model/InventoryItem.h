//
//  InventoryItem.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/12/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InventoryItem : NSObject

@property(nonatomic)NSUInteger inventoryID;
@property(strong,nonatomic)NSString *category;
@property(strong,nonatomic)NSString *description;
@property(strong,nonatomic)NSDate *dateReceived;

@end
