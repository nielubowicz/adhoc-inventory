#import "InventoryDataManager.h"
#import "InventoryItem.h"
#import "BarcodeGenerator.h"
#import <Parse/Parse.h>

@interface InventoryDataManager()

@property (strong,nonatomic) NSString *currentOrganizationName;

@end

@implementation InventoryDataManager

@synthesize currentOrganizationName;

NSString *const kInventoryItemAddedNotification = @"InventoryItemAddedNotification";
NSString *const kInventoryItemSoldNotification = @"InventoryItemSoldNotification";
NSString *const kOrganizationAddedNotification = @"OrganziationAddedNotification";
NSString *const kVolunteerApprovedNotification = @"VolunteerApprovedNotification";
NSString *const kEmployeeApprovedNotification = @"EmployeeApprovedNotification";
NSString *const kVolunteerDeniedNotification = @"VolunteerDeniedNotification";
NSString *const kEmployeeDeniedNotification = @"EmployeeDeniedNotification";

// TODO: Move this to Cloud code in Parse, probably

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
            @synchronized (self) {
                [self setCurrentOrganizationName:organizationName];
            }
            
            [allRolesQuery whereKey:@"name" containsString:self.currentOrganizationName];
            [allRolesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error != nil)
                {
                    NSLog(@"Could not find roles for %@, error: %@",self.currentOrganizationName, error);
                    return;
                }

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
// This method automatically creates the _Admin role for this organization
// The _Admin role will be able to make changes to organization rosters (admitting new employees, etc)
// as well as normal _Employee functions
// TODO: Resolve conflicts if someone registers for a duplicate organization / troll?
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
    
    @synchronized(self) {
        [self setCurrentOrganizationName:sanitizedName];
    }
    
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
            if (error != nil)
            {
                NSLog(@"Could not save administrator role for %@, error: %@",organization[kPFOrganizationSanitizedNameKey],error);
                return;
            }
            NSString *employeeRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kEmployeeRoleSuffix];
           
            // set up employee and volunteer Roles with public read access
            // and write access for Admin role
            PFACL *employeeACL = [PFACL ACL];
            [employeeACL setPublicReadAccess:YES];
            [employeeACL setWriteAccess:YES forRoleWithName:adminRoleName];
            PFRole *employeeRole = [PFRole roleWithName:employeeRoleName acl:employeeACL];
            [employeeRole.users addObject:currentUser];
            [employeeRole.roles addObject:adminRole];
            
            [employeeRole saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error != nil)
                {
                    NSLog(@"Could not save employee role for %@, error: %@",organization[kPFOrganizationSanitizedNameKey],error);
                    return;
                }
                NSString *volunteerRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kVolunteerRoleSuffix];
                
                PFACL *volunteerACL = [PFACL ACL];
                [volunteerACL setPublicReadAccess:YES];
                [volunteerACL setWriteAccess:YES forRoleWithName:adminRoleName];
                
                PFRole *volunteerRole = [PFRole roleWithName:volunteerRoleName acl:volunteerACL];
                [volunteerRole.roles addObject:employeeRole];
                [volunteerRole saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error != nil)
                    {
                        NSLog(@"Could not save volunteer role for %@, error: %@",organization[kPFOrganizationSanitizedNameKey],error);
                        return;
                    }
                    // create pending_ roles for this organization: employee and volunteer
                    // make them public readable and writable
                    NSString *pendingVolunteerRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kPendingVolunteerRoleSuffix];
                    PFACL *pendingVolunteerACL = [PFACL ACL];
                    [pendingVolunteerACL setPublicReadAccess:YES];
                    [pendingVolunteerACL setPublicWriteAccess:YES];
                    PFRole *pendingVolunteerRole = [PFRole roleWithName:pendingVolunteerRoleName acl:pendingVolunteerACL];
                    
                    NSString *pendingEmployeeRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kPendingEmployeeRoleSuffix];
                    PFACL *pendingEmployeeACL = [PFACL ACL];
                    [pendingEmployeeACL setPublicReadAccess:YES];
                    [pendingEmployeeACL setPublicWriteAccess:YES];
                    PFRole *pendingEmployeeRole = [PFRole roleWithName:pendingEmployeeRoleName acl:pendingEmployeeACL];
                    
                    [PFObject saveAllInBackground:@[pendingEmployeeRole,pendingVolunteerRole]];
                    [PFQuery clearAllCachedResults];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOrganizationAddedNotification object:organization];
                }];
            }];
        }];
    }];
}

# pragma mark Adding New Users
// adds the current user to _PendingEmployee and _PendingVolunteer roles
// which are later verified by the Admin to become _Employee and _Volunteer roles
-(void)addCurrentUserToOrganization:(PFObject *)organization {
    // get current user
    PFUser *currentUser = [PFUser currentUser];
    
    // and then add them to the pending employee and volunteer roles
    NSString *volunteerRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kPendingVolunteerRoleSuffix];
    
    PFQuery *volunteerRoleQuery = [PFRole query];
    [volunteerRoleQuery whereKey:@"name" equalTo:volunteerRoleName];
    [volunteerRoleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error != nil)
        {
            NSLog(@"Could not find volunteer role for %@, error: %@",organization[kPFOrganizationSanitizedNameKey],error);
            return;
        }
        
        PFRole *volunteerRole = (PFRole *)object;
        [volunteerRole.users addObject:currentUser];
        
        NSString *employeeRoleName = [organization[kPFOrganizationSanitizedNameKey] stringByAppendingString:kPendingEmployeeRoleSuffix];
        
        PFQuery *employeeRoleQuery = [PFRole query];
        [employeeRoleQuery whereKey:@"name" equalTo:employeeRoleName];
        [employeeRoleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error != nil)
            {
                NSLog(@"Could not find employee role for %@, error: %@",organization[kPFOrganizationSanitizedNameKey],error);
                return;
            }
            
            PFRole *employeeRole = (PFRole *)object;
            [employeeRole.users addObject:currentUser];
            
            [PFObject saveAllInBackground:@[volunteerRole,employeeRole] block:^(BOOL succeeded, NSError *error) {
                [PFQuery clearAllCachedResults];
                [[NSNotificationCenter defaultCenter] postNotificationName:kOrganizationAddedNotification object:organization];
            }];
        }];
    }];
}

// The _Volunteer role will not have write privileges beyond data entry
// So they will not be able to sell Items
- (void)addPendingVolunteerToOrganization:(PFUser *)approvedUser
{
    // move this Volunteer from pending to a real Volunteer
    PFQuery *pendingRole = [PFRole query];
    [pendingRole whereKey:@"users" containedIn:@[approvedUser]];
    [pendingRole whereKey:@"name" containsString:kPendingVolunteerRoleSuffix];
    [pendingRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object == nil || error != nil) {
            NSLog(@"There was a problem: err,%@",error);
            return;
        }
        
        PFRole *pendingVolunteer = (PFRole *)object;
        [[pendingVolunteer users] removeObject:approvedUser];
        
        @synchronized(self) {
            if (self.currentOrganizationName == nil)
            {
                [self setCurrentOrganizationName:[[pendingVolunteer name] stringByReplacingOccurrencesOfString:kPendingVolunteerRoleSuffix withString:@""]];
            }
        }
        PFQuery *volunteerRoleQuery = [PFRole query];
        [volunteerRoleQuery whereKey:@"name" equalTo:[self.currentOrganizationName stringByAppendingString:kVolunteerRoleSuffix]];
        
        [volunteerRoleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error != nil)
            {
                NSLog(@"Could not find volunteer role for %@, error: %@",self.currentOrganizationName,error);
                return;
            }
            PFRole *newVolunteer = (PFRole *)object;
            [newVolunteer.users addObject:approvedUser];
            
            [PFObject saveAllInBackground:@[pendingVolunteer,newVolunteer] block:^(BOOL succeeded, NSError *error) {
                [PFQuery clearAllCachedResults];
                [[NSNotificationCenter defaultCenter] postNotificationName:kVolunteerApprovedNotification object:approvedUser];
            }];
        }];
    }];
}

- (void)removePendingVolunteer:(PFUser *)deniedUser
{
    PFQuery *pendingRole = [PFRole query];
    [pendingRole whereKey:@"users" containedIn:@[deniedUser]];
    [pendingRole whereKey:@"name" containsString:kPendingVolunteerRoleSuffix];
    [pendingRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object == nil || error != nil) {
            NSLog(@"There was a problem: err,%@",error);
            return;
        }
        
        PFRole *pendingVolunteer = (PFRole *)object;
        [[pendingVolunteer users] removeObject:deniedUser];
        
        [pendingVolunteer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil)
            {
                NSLog(@"Could not save pending volunteer role for %@, error: %@",deniedUser,error);
                return;
            }
            
            [deniedUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@"There was an error deleting user: %@", deniedUser);
                    return;
                }
                
                [PFQuery clearAllCachedResults];
                [[NSNotificationCenter defaultCenter] postNotificationName:kVolunteerDeniedNotification object:nil];
            }];
        }];
    }];
}

// The _Employee role will have write privileges to data but not users
// So they will be able to sell Items but not admit new employees or other administrative roles
// _Employee role is a child of _Volunteer Role, so the user only needs to be added to _Employee Role
- (void)addPendingEmployeeToOrganization:(PFUser *)approvedUser
{
    PFQuery *pendingRole = [PFRole query];
    [pendingRole whereKey:@"users" containedIn:@[approvedUser]];
    [pendingRole whereKey:@"name" containsString:kPendingEmployeeRoleSuffix];
    [pendingRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object == nil || error != nil) {
            NSLog(@"There was a problem: err,%@",error);
            return;
        }
        
        PFRole *pendingEmployee = (PFRole *)object;
        [[pendingEmployee users] removeObject:approvedUser];
        @synchronized(self) {
            if (self.currentOrganizationName == nil)
            {
                [self setCurrentOrganizationName:[[pendingEmployee name] stringByReplacingOccurrencesOfString:kPendingEmployeeRoleSuffix withString:@""]];
            }
        }
        
        PFQuery *pendingVolunteerRole = [PFRole query];
        [pendingVolunteerRole whereKey:@"users" containedIn:@[approvedUser]];
        [pendingVolunteerRole whereKey:@"name" containsString:kPendingVolunteerRoleSuffix];
        [pendingVolunteerRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error != nil)
            {
                NSLog(@"Could not find pending volunteer role for %@, error: %@",approvedUser,error);
                return;
            }
            PFRole *pendingVolunteer = (PFRole *)object;
            [[pendingVolunteer users] removeObject:approvedUser];
            
            PFQuery *employeeRoleQuery = [PFRole query];
            [employeeRoleQuery whereKey:@"name" equalTo:[self.currentOrganizationName stringByAppendingString:kEmployeeRoleSuffix]];
            
            [employeeRoleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (error != nil)
                {
                    NSLog(@"Could not find employee role for %@, error: %@",self.currentOrganizationName,error);
                    return;
                }
                PFRole *newEmployee = (PFRole *)object;
                [newEmployee.users addObject:approvedUser];
                
                [PFObject saveAllInBackground:@[pendingEmployee,newEmployee,pendingVolunteer] block:^(BOOL succeeded, NSError *error) {
                    [PFQuery clearAllCachedResults];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEmployeeApprovedNotification object:approvedUser];
                }];
            }];
        }];
    }];
}

- (void)removePendingEmployee:(PFUser *)deniedUser
{
    PFQuery *pendingRole = [PFRole query];
    [pendingRole whereKey:@"users" containedIn:@[deniedUser]];
    [pendingRole whereKey:@"name" containsString:kPendingEmployeeRoleSuffix];
    [pendingRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object == nil || error != nil) {
            NSLog(@"There was a problem: err,%@",error);
            return;
        }
        
        PFRole *pendingEmployee = (PFRole *)object;
        [[pendingEmployee users] removeObject:deniedUser];
        
        [pendingEmployee saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [PFQuery clearAllCachedResults];
            [deniedUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@"There was an error deleting user: %@", deniedUser);
                    return;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kEmployeeDeniedNotification object:nil];
            }];
        }];
    }];
}

#pragma mark Removing Current users
// TODO: Remove current employees and volunteers from the system - remember to delete both for current employees

@end
