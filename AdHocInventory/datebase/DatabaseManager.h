@interface DatabaseManager : NSObject
{
    
}

+(DatabaseManager *)sharedManager;

-(NSUInteger)addItem:(NSString *)item category:(NSString *)category;

@end
