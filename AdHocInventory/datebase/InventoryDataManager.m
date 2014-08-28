#import "InventoryDataManager.h"
#import "InventoryItem.h"
#import "BarcodeGenerator.h"
#import <Parse/Parse.h>

@interface InventoryDataManager()

@end

@implementation InventoryDataManager

NSString *kInventoryItemAddedNotification = @"InventoryItemAddedNotification";
NSString *kInventoryItemSoldNotification = @"InventoryItemSoldNotification";

#pragma mark -
#pragma mark Singleton methods
+(id)sharedManager
{
    static InventoryDataManager *sharedManager = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(id)init
{
    if (self = [super init])
    {

    }
    return self;
}

-(void)dealloc
{
    // Should never be called, but just here for clarity really.
}

#pragma mark -
#pragma mark Data entry methods
-(void)addItem:(NSString *)itemDescription category:(NSString *)category notes:(NSString *)notes
{
    PFObject *inventoryItem = [PFObject objectWithClassName:kPFInventoryClassName];
    inventoryItem[kPFInventoryCategoryKey] = category;
    inventoryItem[kPFInventoryItemDescriptionKey] = itemDescription;
    inventoryItem[kPFInventoryNotesKey] = notes;
    inventoryItem[kPFInventoryTSAddedKey] = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    [inventoryItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil)
        {
            NSLog(@"There was an error adding PFObject:%@, err:%@",inventoryItem,error);
            return;
        }
        InventoryItem *item = [[InventoryItem alloc] initWithPFObject:inventoryItem];
        UIImage *qr = [UIImage createNonInterpolatedUIImageFromCIImage:[BarcodeGenerator qrcodeImageForInventoryItem:item]
                                                                                      withScale:1.0];
        inventoryItem[kPFInventoryQRCodeKey] = UIImagePNGRepresentation(qr);
        [item setQrCode:inventoryItem[kPFInventoryQRCodeKey]];
        [inventoryItem saveInBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:kInventoryItemAddedNotification object:item];
    }];
}

-(void)sellItem:(InventoryItem *)item
{
    PFQuery *query = [PFQuery queryWithClassName:kPFInventoryClassName];
    [query getObjectInBackgroundWithId:[[item inventoryID] description] block:^(PFObject *inventoryItem, NSError *error) {
        PFObject *soldItem = [PFObject objectWithClassName:kPFInventorySoldClassName];
        soldItem[kPFInventoryTSSoldKey] = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
        [soldItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil)
            {
                NSLog(@"There was an error selling PFObject:%@, err:%@",soldItem,error);
                return;
            }
            [inventoryItem setObject:soldItem forKey:kPFInventorySoldItemKey];
            [inventoryItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error != nil)
                {
                    NSLog(@"There was an error saving relation of PFObject soldItem:%@ to inventoryItem:%@, err:%@",soldItem,inventoryItem,error);
                    return;
                }
                InventoryItem *item = [[InventoryItem alloc] initWithPFObject:inventoryItem];
                [[NSNotificationCenter defaultCenter] postNotificationName:kInventoryItemSoldNotification object:item];
            }];
        }];
    }];
}

@end
