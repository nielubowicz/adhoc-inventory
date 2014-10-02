//
//  BarcodeGenerator.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/12/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "BarcodeGenerator.h"
#import "InventoryItem.h"

@implementation BarcodeGenerator

static const char *formatString = "AdHocInventory ID:%s\nCat:%s\nDesc:%s";
static NSString *scanFormatString = @"AdHocInventory ID:";

+(CIImage *)qrcodeImageForInventoryItem:(InventoryItem *)item
{
    if (item == nil)
    {
        NSLog(@"Item for %s was nil", __PRETTY_FUNCTION__);
        return nil;
    }
    
    char buffer[64];
    sprintf(buffer,formatString,[[item inventoryID] cStringUsingEncoding:NSUTF8StringEncoding],[[item category] cStringUsingEncoding:NSUTF8StringEncoding],[[item itemDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
    
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

+(NSString *)inventoryIDForFormatString:(NSString *)str
{
    NSString *inventoryID;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    
    [scanner scanString:scanFormatString intoString:NULL];
    [scanner scanUpToString:@"\n" intoString:&inventoryID];
    
    return inventoryID;
}

@end
