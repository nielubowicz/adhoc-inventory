@class InventoryItem;
@class PFObject;
@class PFUser;

@interface InventoryDataManager : NSObject

+ (InventoryDataManager *)sharedManager;

- (void)addItem:(NSString *)itemDescription category:(NSString *)category notes:(NSString *)notes quantity:(NSUInteger)quantity; // async. Register for kInventoryItemAddedNotification notifications
- (void)sellItem:(InventoryItem *)item; // async. Register for kInventoryItemSoldNotification notifications
- (NSArray *)allCategories; // synchronous.

- (void)addOrganization:(NSString *)organizationName city:(NSString *)cityName state:(NSString *)stateName; // async. Register for kOrganizationAddedNotification
- (void)addCurrentUserToOrganization:(PFObject *)organization;    // async. Register for kOrganizationAddedNotification
- (void)addPendingVolunteerToOrganization:(PFUser *)approvedUser; // async. Register for kVolunteerApprovedNotification
- (void)addPendingEmployeeToOrganization:(PFUser *)approvedUser;  // async. Register for kEmployeeApprovedNotification
- (void)removePendingVolunteer:(PFUser *)deniedUser; // async. Register for kVolunteerDeniedNotification
- (void)removePendingEmployee:(PFUser *)deniedUser;  // async. Register for kEmployeeDeniedNotification

FOUNDATION_EXPORT NSString *const kInventoryItemAddedNotification;
FOUNDATION_EXPORT NSString *const kInventoryItemSoldNotification;
FOUNDATION_EXPORT NSString *const kOrganizationAddedNotification;
FOUNDATION_EXPORT NSString *const kVolunteerApprovedNotification;
FOUNDATION_EXPORT NSString *const kEmployeeApprovedNotification;
FOUNDATION_EXPORT NSString *const kVolunteerDeniedNotification;
FOUNDATION_EXPORT NSString *const kEmployeeDeniedNotification;

@end
