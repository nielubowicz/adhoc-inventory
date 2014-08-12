#import "DatabaseManager.h"
#import <sqlite3.h>

@interface DatabaseManager()

@property(nonatomic)sqlite3 *database;
@property(strong,nonatomic)NSString *databasePath;

@end

@implementation DatabaseManager

static char const *createInventoryTable = "CREATE TABLE IF NOT EXISTS inventory (ID INTEGER PRIMARY KEY AUTOINCREMENT, CategoryID SMALLINT, ItemID INTEGER, DateReceived DATE)";

static char const *createCategoryTable = "CREATE TABLE IF NOT EXISTS categories (CategoryID SMALLINT PRIMARY KEY AUTOINCREMENT, Label VARCHAR)";

static char const *createItemDescriptionTable = "CREATE TABLE IF NOT EXISTS itemdescriptions (ItemID INTEGER PRIMARY KEY AUTOINCREMENT, Label VARCHAR)";

+(id)sharedManager
{
    static DatabaseManager *sharedDatabaseManager = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        sharedDatabaseManager = [[self alloc] init];
    });
    
    return sharedDatabaseManager;
}

-(id)init
{
    if (self = [super init])
    {
        // Get the documents directory
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = dirPaths[0];
        
        // Build the path to the database file
        _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"inventory.db"]];
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath: _databasePath ] == NO)
        {
            const char *dbpath = [_databasePath UTF8String];
            if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
            {
                // init tables
                char *errMsg;
                if (sqlite3_exec(_database,createCategoryTable,NULL,NULL,&errMsg) != SQLITE_OK)
                {
                    NSLog(@"Error:%s running statement:%s",errMsg,createCategoryTable);
                }
                if(sqlite3_exec(_database,createItemDescriptionTable,NULL,NULL,&errMsg) != SQLITE_OK)
                {
                    NSLog(@"Error:%s running statement:%s",errMsg,createItemDescriptionTable);
                }
                if(sqlite3_exec(_database,createInventoryTable,NULL,NULL,&errMsg) != SQLITE_OK)
                {
                    NSLog(@"Error:%s running statement:%s",errMsg,createInventoryTable);
                }
                sqlite3_close(_database);
            }
            else
            {
                NSLog(@"Error creating opening or creating database");
            }
        }
    }
    return self;
}

-(void)dealloc
{
    // Should never be called, but just here for clarity really.
}
@end
