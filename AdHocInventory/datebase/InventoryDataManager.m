#import "DatabaseManager.h"
#import <sqlite3.h>
#import "InventoryItem.h"

@interface DatabaseManager()

@property(nonatomic)sqlite3 *database;
@property(strong,nonatomic)NSString *databasePath;

@end

@implementation DatabaseManager

#pragma mark Queries
static char const *createInventoryTable = "CREATE TABLE IF NOT EXISTS inventory (ID INTEGER PRIMARY KEY AUTOINCREMENT, CategoryID INTEGER, ItemID INTEGER, TSReceived DATETIME DEFAULT (strftime('%s', 'now')));";

static char const *createSoldInventoryTable = "CREATE TABLE IF NOT EXISTS soldinventory (ID INTEGER PRIMARY KEY, CategoryID INTEGER, ItemID INTEGER, TSReceived DATETIME, TSSold DATETIME DEFAULT (strftime('%s', 'now')));";

static char const *createCategoryTable = "CREATE TABLE IF NOT EXISTS categories (CategoryID INTEGER PRIMARY KEY AUTOINCREMENT, Label VARCHAR);";

static char const *createItemDescriptionTable = "CREATE TABLE IF NOT EXISTS itemdescriptions (ItemID INTEGER PRIMARY KEY AUTOINCREMENT, Description VARCHAR);";

#pragma mark -
#pragma mark Singleton methods
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
                if(sqlite3_exec(_database,createSoldInventoryTable,NULL,NULL,&errMsg) != SQLITE_OK)
                {
                    NSLog(@"Error:%s running statement:%s",errMsg,createSoldInventoryTable);
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

#pragma mark -
#pragma mark Data entry methods
-(InventoryItem *)addItem:(NSString *)itemDescription category:(NSString *)category
{
    const char *dbpath = [_databasePath UTF8String];

    if (sqlite3_open(dbpath, &_database) != SQLITE_OK)
    {
        NSLog(@"Could not open database");
        return 0;
    }
    
    // find category ID
    NSUInteger result = SQLITE_OK;
    sqlite3_stmt    *statement;

    NSString *querySQL = [NSString stringWithFormat:
                          @"SELECT CategoryID, Label FROM categories WHERE Label LIKE \"%@\";", category];
    
    int categoryID = -1;
    const char *query_stmt = [querySQL UTF8String];
    
    result = sqlite3_prepare_v2(_database,
                                query_stmt, -1, &statement, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            categoryID = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    // find the category ID
    // if category not found, create it
    if (categoryID < 0)
    {
        querySQL = [NSString stringWithFormat:@"INSERT INTO categories (Label) VALUES (\"%@\");",category];
        const char *query_stmt = [querySQL UTF8String];
        
        result = sqlite3_prepare_v2(_database,
                                               query_stmt, -1, &statement, NULL);
        if (result != SQLITE_OK)
        {
            NSLog(@"Error inserting category with Label:%@",category);
            sqlite3_close(_database);
            return 0;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);

        querySQL = [NSString stringWithFormat:
                              @"SELECT CategoryID, Label FROM categories WHERE Label LIKE \"%@\";", category];
        
        query_stmt = [querySQL UTF8String];
        
        result = sqlite3_prepare_v2(_database,
                                    query_stmt, -1, &statement, NULL);
        if (result == SQLITE_OK)
        {
            result = sqlite3_step(statement);
            if (result == SQLITE_ROW)
            {
                categoryID = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
    }
    
    // find item ID
    int itemID = -1;
    querySQL = [NSString stringWithFormat:
                @"SELECT ItemID, Description FROM itemdescriptions WHERE Description LIKE \"%@\";", itemDescription];
    
    query_stmt = [querySQL UTF8String];
    
    result = sqlite3_prepare_v2(_database,
                                query_stmt, -1, &statement, NULL);
    if (result == SQLITE_OK)
    {
        result = sqlite3_step(statement);
        if (result == SQLITE_ROW)
        {
            itemID = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    
    // if item not found, create it
    if (itemID < 0)
    {
        querySQL = [NSString stringWithFormat:@"INSERT INTO itemdescriptions (Description) VALUES (\"%@\");",itemDescription];
        query_stmt = [querySQL UTF8String];
        
        result = sqlite3_prepare_v2(_database,
                                    query_stmt, -1, &statement, NULL);
        if (result != SQLITE_OK)
        {
            NSLog(@"Error inserting item with description:%@",itemDescription);
            sqlite3_close(_database);
            return 0;
        }
        sqlite3_step(statement);
        sqlite3_finalize(statement);

        querySQL = [NSString stringWithFormat:
                    @"SELECT ItemID, Description FROM itemdescriptions WHERE Description LIKE \"%@\";", itemDescription];
        
        query_stmt = [querySQL UTF8String];
        
        result = sqlite3_prepare_v2(_database,
                                    query_stmt, -1, &statement, NULL);
        if (result == SQLITE_OK)
        {
            result = sqlite3_step(statement);
            if (result == SQLITE_ROW)
            {
                itemID = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
    }
    
    // create inventory item
    querySQL = [NSString stringWithFormat:@"INSERT INTO inventory (CategoryID,ItemID) VALUES (%d,%d);",categoryID,itemID];
    query_stmt = [querySQL UTF8String];
    
    result = sqlite3_prepare_v2(_database,
                                query_stmt, -1, &statement, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Error inserting inventory item");
        sqlite3_close(_database);
        return 0;
    }
    
    sqlite3_step(statement);
    sqlite3_finalize(statement);   

    // get new autoincremented ID from database
    querySQL = [NSString stringWithFormat:@"SELECT MAX(ID) FROM inventory"];
    query_stmt = [querySQL UTF8String];
    
    result = sqlite3_prepare_v2(_database,
                                query_stmt, -1, &statement, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Error retrieving inventory item");
        sqlite3_close(_database);
        return 0;
    }
    
    sqlite3_step(statement);
    NSUInteger inventoryID = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    
    InventoryItem *item = [[InventoryItem alloc] init];
    [item setInventoryID:inventoryID];
    [item setCategory:category];
    [item setDescription:itemDescription];
    return item;
}

-(BOOL)sellItem:(InventoryItem *)item
{
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_database) != SQLITE_OK)
    {
        NSLog(@"Could not open database");
        return NO;
    }
    
    sqlite3_stmt    *statement;
    NSUInteger inventoryID = [item inventoryID];
    
    NSUInteger categoryID,descriptionID;
    long long tsreceived;
    
    // get category and description IDs
    NSString *querySQL = [NSString stringWithFormat:@"SELECT CategoryID, ItemID, TSReceived FROM inventory WHERE ID = %d", inventoryID];
    
    const char *query_stmt = [querySQL UTF8String];
    
    NSUInteger result = sqlite3_prepare_v2(_database,
                                query_stmt, -1, &statement, NULL);
    if (result == SQLITE_OK)
    {
        result = sqlite3_step(statement);
        if (result == SQLITE_ROW)
        {
            categoryID = sqlite3_column_int(statement, 0);
            descriptionID = sqlite3_column_int(statement, 1);
            tsreceived = sqlite3_column_int64(statement,2);
        }
        sqlite3_finalize(statement);
    }

    sqlite3_exec(_database, "BEGIN TRANSACTION;", NULL, NULL, NULL);
    
    // insert into soldinventory (inventoryID,categoryID,descriptionID,tsreceived)
    querySQL = [NSString stringWithFormat:@"INSERT INTO soldinventory (ID, CategoryID, ItemID,TSReceived) VALUES (%d,%d,%d,%lld)", inventoryID,categoryID,descriptionID,tsreceived];
    query_stmt = [querySQL UTF8String];
    
    result = sqlite3_exec(_database,query_stmt, NULL, &statement, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Failed to insert into soldinventory with error: %s", sqlite3_errmsg(_database));
        return NO;
    }
    
    // delete from inventory
    querySQL = [NSString stringWithFormat:@"DELETE FROM inventory WHERE ID = %d", inventoryID];
    query_stmt = [querySQL UTF8String];
    
    result = sqlite3_exec(_database,query_stmt, NULL, &statement, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Failed to delete from inventory with error: %s", sqlite3_errmsg(_database));
        return NO;
    }
    
    result = sqlite3_exec(_database, "COMMIT TRANSACTION;", NULL, NULL, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Transaction failed to commit with error: %s", sqlite3_errmsg(_database));
        return NO;
    }
    
    return YES;
}

-(NSArray *)allInventoryItems
{
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_database) != SQLITE_OK)
    {
        NSLog(@"Could not open database");
        return 0;
    }
    
    NSMutableArray *inventory = [[NSMutableArray alloc] init];
    
    NSString *querySQL = [NSString stringWithFormat:@"SELECT ID,Label,Description,TSReceived FROM inventory JOIN categories USING (categoryID) JOIN itemdescriptions USING (itemID)"];
    
    const char *query_stmt = [querySQL UTF8String];
    sqlite3_stmt *statement;

    NSUInteger result = sqlite3_prepare_v2(_database,
                                           query_stmt, -1, &statement, NULL);
    if (result == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            @autoreleasepool {
                InventoryItem *item = [[InventoryItem alloc] init];
                [item setInventoryID:sqlite3_column_int(statement, 0)];
                [item setCategory:[NSString stringWithUTF8String:sqlite3_column_text(statement,1)]];
                [item setDescription:[NSString stringWithUTF8String:sqlite3_column_text(statement,2)]];
                [item setDateReceived:[NSDate dateWithTimeIntervalSince1970:sqlite3_column_int64(statement,3)]];
                [inventory addObject:item];
            }
        }
        sqlite3_finalize(statement);
    }
    
    return inventory;
}
@end
