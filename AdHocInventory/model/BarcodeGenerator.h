//
//  BarcodeGenerator.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/12/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NKDBarcode;
@class InventoryItem;

@interface BarcodeGenerator : NSObject

+(NKDBarcode *)barcodeForInventoryID:(NSUInteger)inventoryID;
+(UIImage *)barcodeImageForInventoryID:(NSUInteger)inventoryID;
+(NSUInteger)inventoryIDForBarcode:(NKDBarcode *)barcode;
+(NSUInteger)inventoryIDForFormatString:(NSString *)str shortFormat:(BOOL)isShort;
+(CIImage *)qrcodeImageForInventoryItem:(InventoryItem *)item;

@end
