@class InventoryItem;

@interface DatabaseManager : NSObject
{
    
}

+(DatabaseManager *)sharedManager;

-(InventoryItem *)addItem:(NSString *)item category:(NSString *)category;
-(NSArray *)allInventoryItems;

@end
