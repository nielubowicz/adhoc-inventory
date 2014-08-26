//
//  InventoryItem.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/12/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "InventoryItem.h"
#import <Parse/PFObject.h>

@interface InventoryItem()

@end

@implementation InventoryItem

-(id)initWithPFObject:(PFObject *)object
{
    if (self = [super init])
    {
        [self setCategory:object[kPFInventoryCategoryKey]];
        [self setItemDescription:object[kPFInventoryItemDescriptionKey]];
        [self setInventoryID:[object objectId]];
        
        if ([object[kPFInventoryTSAddedKey] longLongValue] > 0)
        {
            [self setDateReceived:[NSDate dateWithTimeIntervalSince1970:[object[kPFInventoryTSAddedKey] longLongValue]]];
        }
        
        if ([object[kPFInventoryTSSoldKey] longLongValue] > 0)
        {
            [self setDateSold:[NSDate dateWithTimeIntervalSince1970:[object[kPFInventoryTSSoldKey] longLongValue]]];
        }
        
    }
    return self;
}

@synthesize inventoryID;
@synthesize category;
@synthesize itemDescription;
@synthesize dateReceived;
@synthesize dateSold;

@end
