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

+(NKDBarcode *)barcodeForInventoryID:(NSString *)inventoryID;
+(UIImage *)barcodeImageForInventoryID:(NSString *)inventoryID;
+(NSString *)inventoryIDForBarcode:(NKDBarcode *)barcode;
+(NSString *)inventoryIDForFormatString:(NSString *)str shortFormat:(BOOL)isShort;
+(CIImage *)qrcodeImageForInventoryItem:(InventoryItem *)item;

@end
