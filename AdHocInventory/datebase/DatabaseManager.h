@class InventoryItem;

@interface DatabaseManager : NSObject
{
    
}

+(DatabaseManager *)sharedManager;

-(InventoryItem *)addItem:(NSString *)item category:(NSString *)category;
-(BOOL)sellItem:(InventoryItem *)item;

-(NSArray *)allInventoryItems;

@end
