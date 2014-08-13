@interface DatabaseManager : NSObject
{
    
}

+(DatabaseManager *)sharedManager;

-(void)addItem:(NSString *)item category:(NSString *)category;

@end
