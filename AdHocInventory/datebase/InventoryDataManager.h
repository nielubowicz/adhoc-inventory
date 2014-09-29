@class InventoryItem;
@class PFObject;

@interface InventoryDataManager : NSObject

+(InventoryDataManager *)sharedManager;

-(void)addItem:(NSString *)itemDescription category:(NSString *)category notes:(NSString *)notes quantity:(NSUInteger)quantity; // async. Register for kInventoryItemAddedNotification notifications
-(void)sellItem:(InventoryItem *)item; // async. Register for kInventoryItemSoldNotification notifications
-(NSArray *)allCategories; // synchronous. 

-(void)addOrganization:(NSString *)organizationName city:(NSString *)cityName state:(NSString *)stateName; // async. Register for kOrganizationAddedNotification
-(void)addCurrentUserToOrganization:(PFObject *)organization; // async. Register for kOrganizationAddedNotification

FOUNDATION_EXPORT NSString *const kInventoryItemAddedNotification;
FOUNDATION_EXPORT NSString *const kInventoryItemSoldNotification;
FOUNDATION_EXPORT NSString *const kOrganizationAddedNotification;

@end
