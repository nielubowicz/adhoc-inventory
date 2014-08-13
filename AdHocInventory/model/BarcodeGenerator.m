//
//  BarcodeGenerator.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/12/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "BarcodeGenerator.h"
#import "NKDCode128Barcode.h"
#import "UIImage-NKDBarcode.h"

@implementation BarcodeGenerator

+(UIImage *)generateBarcodeForInventoryID:(NSUInteger)inventoryID
{
    NKDBarcode *barcode = [[NKDCode128Barcode alloc] initWithContent:[NSString stringWithFormat:@"%u",inventoryID]
                                                       printsCaption:YES];
    
    return [UIImage imageFromBarcode:barcode];
}

@end
