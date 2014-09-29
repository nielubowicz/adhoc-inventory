//
//  ParseDefinitions.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/22/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "ParseDefinitions.h"

#pragma mark InventoryItem Keys
NSString *const kPFInventoryClassName = @"InventoryItem";
NSString *const kPFInventorySoldClassName = @"SoldInventoryItem";
NSString *const kPFInventoryItemDescriptionKey = @"itemDescription";
NSString *const kPFInventoryCategoryKey = @"category";
NSString *const kPFInventoryObjectIdKey = @"objectId";
NSString *const kPFInventoryTSAddedKey = @"tsadded";
NSString *const kPFInventoryTSSoldKey = @"tssold";
NSString *const kPFInventoryQRCodeKey = @"qrcode";
NSString *const kPFInventorySoldItemKey = @"soldItem";
NSString *const kPFInventoryNotesKey = @"notes";
NSString *const kPFInventoryQuantityKey = @"quantity";

#pragma mark Organization and User Keys
NSString *const kPFOrganizationClassName = @"Organization";
NSString *const kPFOrganizationNameKey = @"name";
NSString *const kPFOrganizationSanitizedNameKey = @"sanitizedName";
NSString *const kPFOrganizationCityKey = @"city";
NSString *const kPFOrganizationStateKey = @"state";
NSString *const kPFOrganizationUserKey = @"organization";

#pragma mar User Role definitions
NSString *const kAdministratorRoleSuffix = @"_Administrator";
NSString *const kEmployeeRoleSuffix = @"_Employee";
NSString *const kVolunteerRoleSuffix = @"_Volunteer";