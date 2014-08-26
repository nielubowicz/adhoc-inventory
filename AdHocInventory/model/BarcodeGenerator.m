//
//  BarcodeGenerator.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/12/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "BarcodeGenerator.h"
#import <NKDCode128Barcode.h>
#import <UIImage-NKDBarcode.h>
#import "InventoryItem.h"

@implementation BarcodeGenerator

static const char *longFormatString = "Repurpose Project ID:%u\nCat:%s\nDesc:%s";
static const char *shortFormatString = "Repurpose,%u";

+(NKDBarcode *)barcodeForInventoryID:(NSUInteger)inventoryID
{
    char buffer[64];
    sprintf(buffer,shortFormatString,inventoryID);
    
    NKDBarcode *barcode = [[NKDCode128Barcode alloc] initWithContent:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]
                                                       printsCaption:YES];
    
    return barcode;
}

+(CIImage *)qrcodeImageForInventoryItem:(InventoryItem *)item
{
    if (item == nil)
    {
        NSLog(@"Item for %s was nil", __PRETTY_FUNCTION__);
        return nil;
    }
    
    char buffer[64];
    sprintf(buffer,longFormatString,[item inventoryID],[[item category] cStringUsingEncoding:NSUTF8StringEncoding],[[item description] cStringUsingEncoding:NSUTF8StringEncoding]);
    
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

+(UIImage *)barcodeImageForInventoryID:(NSUInteger)inventoryID
{
    char buffer[64];
    sprintf(buffer,shortFormatString,inventoryID);
    NKDBarcode *barcode = [[NKDCode128Barcode alloc] initWithContent:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]
                                                       printsCaption:YES];
    
    return [UIImage imageFromBarcode:barcode];
}

+(NSUInteger)inventoryIDForBarcode:(NKDBarcode *)barcode
{
    NSString *barcodeString = [barcode content];
    NSUInteger inventoryID = atoi([barcodeString UTF8String]);
    return inventoryID;
}

+(NSUInteger)inventoryIDForFormatString:(NSString *)str shortFormat:(BOOL)isShort
{
    NSUInteger inventoryID;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    NSString  *formatString = (isShort ? @"Repurpose:" : @"Repurpose Project ID:");
    
    [scanner scanString:formatString intoString:NULL];
    [scanner scanHexInt:&inventoryID];
    
    return inventoryID;
}

@end
