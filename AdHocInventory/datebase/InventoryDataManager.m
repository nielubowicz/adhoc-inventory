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
-(void)addItem:(NSString *)itemDescription category:(NSString *)category notes:(NSString *)notes quantity:(NSUInteger)quantity;
{
    PFObject *inventoryItem = [PFObject objectWithClassName:kPFInventoryClassName];
    inventoryItem[kPFInventoryCategoryKey] = category;
    inventoryItem[kPFInventoryItemDescriptionKey] = itemDescription;
    inventoryItem[kPFInventoryNotesKey] = notes;
    inventoryItem[kPFInventoryTSAddedKey] = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    inventoryItem[kPFInventoryQuantityKey] = [NSNumber numberWithUnsignedInt:quantity];
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
        [item setQrCode:qr];
        [inventoryItem saveInBackground];
        [PFQuery clearAllCachedResults];
        [[NSNotificationCenter defaultCenter] postNotificationName:kInventoryItemAddedNotification object:item];
    }];
}

-(void)sellItem:(InventoryItem *)item
{
    PFQuery *query = [PFQuery queryWithClassName:kPFInventoryClassName];
    [query getObjectInBackgroundWithId:[[item inventoryID] description] block:^(PFObject *inventoryItem, NSError *error) {
        if (error != nil)
        {
            NSLog(@"There was an error retrieving PFObject for objectID:%@, err:%@",[item inventoryID],error);
            return;
        }
        
        PFObject *soldItem = [PFObject objectWithClassName:kPFInventorySoldClassName];
        soldItem[kPFInventoryTSSoldKey] = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
        
        [soldItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil)
            {
                NSLog(@"There was an error selling PFObject:%@, err:%@",soldItem,error);
                return;
            }
            PFRelation *soldItemRelation = [inventoryItem relationForKey:kPFInventorySoldItemKey];
            [soldItemRelation addObject:soldItem];
            
            NSUInteger currentAvailableQuantity = [inventoryItem[kPFInventoryQuantityKey] unsignedIntegerValue];
            inventoryItem[kPFInventoryQuantityKey] = [NSNumber numberWithUnsignedInt:--currentAvailableQuantity];
            
            [inventoryItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error != nil)
                {
                    NSLog(@"There was an error selling PFObject:%@, err:%@",soldItem,error);
                    return;
                }
                
                InventoryItem *item = [[InventoryItem alloc] initWithPFObject:inventoryItem];
                [PFQuery clearAllCachedResults];
                [[NSNotificationCenter defaultCenter] postNotificationName:kInventoryItemSoldNotification object:item];
            }];
        }];
    }];
}

-(NSArray *)allCategories
{
    PFQuery *query = [PFQuery queryWithClassName:kPFInventoryClassName];
    [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
    NSArray *reqQuery = [query findObjects];
    return [reqQuery valueForKeyPath:[@"@distinctUnionOfObjects." stringByAppendingString:kPFInventoryCategoryKey]];
}

@end
