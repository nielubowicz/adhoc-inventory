@class InventoryItem;

@interface InventoryDataManager : NSObject

+(InventoryDataManager *)sharedManager;

-(void)addItem:(NSString *)item category:(NSString *)category; // asynchronous. Register for kInventoryItemAddedNotification notifications
-(void)sellItem:(InventoryItem *)item; // asynchronous. Register for kInventoryItemSoldNotification notifications

FOUNDATION_EXPORT NSString const *kInventoryItemAddedNotification;
FOUNDATION_EXPORT NSString const *kInventoryItemSoldNotification;

@end
