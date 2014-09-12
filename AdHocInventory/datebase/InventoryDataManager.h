@class InventoryItem;

@interface InventoryDataManager : NSObject

+(InventoryDataManager *)sharedManager;

-(void)addItem:(NSString *)itemDescription category:(NSString *)category notes:(NSString *)notes quantity:(NSUInteger)quantity; // asynchronous. Register for kInventoryItemAddedNotification notifications
-(void)sellItem:(InventoryItem *)item; // asynchronous. Register for kInventoryItemSoldNotification notifications
-(NSArray *)allCategories; // synchronous. 

FOUNDATION_EXPORT NSString *const kInventoryItemAddedNotification;
FOUNDATION_EXPORT NSString *const kInventoryItemSoldNotification;

@end
