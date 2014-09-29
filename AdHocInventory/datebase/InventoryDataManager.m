#import "InventoryDataManager.h"
#import "InventoryItem.h"
#import "BarcodeGenerator.h"
#import <Parse/Parse.h>

@interface InventoryDataManager()

@end

@implementation InventoryDataManager

NSString *const kInventoryItemAddedNotification = @"InventoryItemAddedNotification";
NSString *const kInventoryItemSoldNotification = @"InventoryItemSoldNotification";
NSString *const kOrganizationAddedNotification = @"OrganziationAddedNotification";

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
    PFQuery *employeeQuery = [PFRole query];
    [employeeQuery whereKey:@"users" containedIn:@[[PFUser currentUser]]];
    [employeeQuery whereKey:@"name" containsString:kVolunteerRoleSuffix];
    [employeeQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object == nil || error != nil)
        {
            NSLog(@"The getFirstObject request failed.");
            return;
        }
        
        PFObject *inventoryItem = [PFObject objectWithClassName:kPFInventoryClassName];
        inventoryItem[kPFInventoryCategoryKey] = category;
        inventoryItem[kPFInventoryItemDescriptionKey] = itemDescription;
        inventoryItem[kPFInventoryNotesKey] = notes;
        inventoryItem[kPFInventoryTSAddedKey] = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
        inventoryItem[kPFInventoryQuantityKey] = [NSNumber numberWithUnsignedInt:quantity];
        
        // get the employee role for this user, and give them read and write (temp) access
        // temp write access is necessary to save QR code, which is dependent on the objectId (and a save)
        PFRole *volunteerRole = (PFRole *)object;
        PFACL *ACL = [PFACL ACL];
        [ACL setReadAccess:YES forRole:volunteerRole];
        [ACL setWriteAccess:YES forRole:volunteerRole];
        [inventoryItem setACL:ACL];
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
            
            PFQuery *allRolesQuery = [PFRole query];
            NSString *organizationName = [[volunteerRole name] stringByReplacingOccurrencesOfString:kVolunteerRoleSuffix withString:@""];
            [allRolesQuery whereKey:@"name" containsString:organizationName];
            [allRolesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFACL *ACL = [inventoryItem ACL];
                
                // remove write access from Volunteer role
                // enable write access for Employee/Admin role
                [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PFRole *role = (PFRole *)obj;
                    if ([role.name hasSuffix:kVolunteerRoleSuffix]) {
                        [ACL setReadAccess:YES forRole:role];
                        [ACL setWriteAccess:NO forRole:role];
                    }
                    else if ([role.name hasSuffix:kEmployeeRoleSuffix]) {
                        [ACL setReadAccess:YES forRole:role];
                        [ACL setWriteAccess:YES forRole:role];
                    }
                }];
                
                [inventoryItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [PFQuery clearAllCachedResults];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kInventoryItemAddedNotification object:item];
                }];
            }];
        }];
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
        
        // make sure user is at least an employee to be able to sell the item
        PFQuery *queryRole = [PFRole query];
        [queryRole whereKey:@"users" containedIn:@[[PFUser currentUser]]];
        [queryRole whereKey:@"name" containsString:kEmployeeRoleSuffix];
        [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object == nil || error != nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
                                                                message:@"You aren't allowed to do that"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
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
                        NSLog(@"There was an error adding PFObject:%@ to relationship, err:%@",inventoryItem,error);
                        return;
                    }
                    
                    InventoryItem *item = [[InventoryItem alloc] initWithPFObject:inventoryItem];
                    [PFQuery clearAllCachedResults];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kInventoryItemSoldNotification object:item];
                }];
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

#pragma mark -
#pragma mark Organization and User methods
-(void)addOrganization:(NSString *)organizationName city:(NSString *)cityName state:(NSString *)stateName {
    PFObject *organization =  [PFObject objectWithClassName:kPFOrganizationClassName];
    [organization setObject:organizationName forKey:kPFOrganizationNameKey];
    
    NSRange lcEnglishRange;
    lcEnglishRange.location = (unsigned int)'A';
    lcEnglishRange.length = 26;
    
    NSRange ucEnglishRange;
    ucEnglishRange.location = (unsigned int)'a';
    ucEnglishRange.length = 26;
    
    NSRange numberRange;
    numberRange.location = (unsigned int)'0';
    numberRange.length = 10;
    
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet characterSetWithCharactersInString:@" -_"];
    [charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithRange:lcEnglishRange]];
    [charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithRange:ucEnglishRange]];
    [charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithRange:numberRange]];
    
    // sanitize to only allow [A-z][0-9][ -_]
    NSString *sanitizedName = [[organizationName componentsSeparatedByCharactersInSet:[charSet invertedSet]] componentsJoinedByString:@""];
    [organization setObject:organizationName forKey:kPFOrganizationNameKey];
    [organization setObject:sanitizedName forKey:kPFOrganizationSanitizedNameKey];
    [organization setObject:cityName forKey:kPFOrganizationCityKey];
    [organization setObject:stateName forKey:kPFOrganizationStateKey];
    
    PFACL *orgACL = [PFACL ACL];
    [orgACL setPublicReadAccess:YES];
    [organization setACL:orgACL];
    
    [organization saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFUser *currentUser = [PFUser currentUser];
        NSString *adminRoleName = [sanitizedName stringByAppendingString:kAdministratorRoleSuffix];
        
        PFACL *adminACL = [PFACL ACL];
        [adminACL setPublicReadAccess:YES];
        PFRole *adminRole = [PFRole roleWithName:adminRoleName acl:adminACL];
        [adminRole.users addObject:currentUser];
        
        [adminRole saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // user added to organization
            if (error != nil) {
                return;
            }
            NSString *employeeRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kEmployeeRoleSuffix];
           
            // set up employee and volunteer Roles with public read access
            // and write access for Admin role
            PFACL *employeeACL = [PFACL ACL];
            [employeeACL setPublicReadAccess:YES];
            [employeeACL setPublicWriteAccess:YES];
            //            [employeeACL setWriteAccess:YES forRoleWithName:adminRoleName];
            PFRole *employeeRole = [PFRole roleWithName:employeeRoleName acl:employeeACL];
            [employeeRole.users addObject:currentUser];
            [employeeRole.roles addObject:adminRole];
            
            [employeeRole saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error != nil) {
                    return;
                }
                NSString *volunteerRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kVolunteerRoleSuffix];
                
                PFACL *volunteerACL = [PFACL ACL];
                [volunteerACL setPublicReadAccess:YES];
                [volunteerACL setPublicWriteAccess:YES];
                //            [volunteerACL setWriteAccess:YES forRoleWithName:adminRoleName];
                
                PFRole *volunteerRole = [PFRole roleWithName:volunteerRoleName acl:volunteerACL];
                [volunteerRole.users addObject:currentUser];
                [volunteerRole.roles addObject:employeeRole];
                [volunteerRole saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [PFQuery clearAllCachedResults];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOrganizationAddedNotification object:organization];
                }];
            }];
        }];
    }];
}

-(void)addCurrentUserToOrganization:(PFObject *)organization {

    bool addAsEmployee = NO;
    // get current user
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *volunteerRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kVolunteerRoleSuffix];
    
    PFQuery *volunteerRoleQuery = [PFRole query];
    [volunteerRoleQuery whereKey:@"name" equalTo:volunteerRoleName];
    [volunteerRoleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error != nil) {
            return;
        }
        
        PFRole *volunteerRole = (PFRole *)object;
        [volunteerRole.users addObject:currentUser];
        
        [volunteerRole saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // user added to organization
            if (error != nil) {
                return;
            }
            
            if (addAsEmployee) {
                NSString *employeeRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kEmployeeRoleSuffix];
                
                PFQuery *employeeRoleQuery = [PFRole query];
                [employeeRoleQuery whereKey:@"name" equalTo:employeeRoleName];
                [employeeRoleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (error != nil) {
                        return;
                    }
                    
                    PFRole *employeeRole = (PFRole *)object;
                    [employeeRole.users addObject:currentUser];
                    
                    [employeeRole saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        // user added to organization
                        if (error != nil) {
                            return;
                        }
                        
                        [PFQuery clearAllCachedResults];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kOrganizationAddedNotification object:organization];
                    }];
                }];
            }
        }];
    }];
    

}

@end
