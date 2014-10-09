//
//  PendingVolunteersViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 9/30/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "PendingVolunteersViewController.h"
#import "InventoryDataManager.h"

@implementation PendingVolunteersViewController

static PFQuery *userRelationQuery = nil;

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
    {
        [self setParseClassName:@"_User"];
        [[self tabBarItem] setTitle:@"Pending"];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"third.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDefaultBackground];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pendingVolunteerChanged:) name:kVolunteerApprovedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pendingVolunteerChanged:) name:kVolunteerDeniedNotification object:nil];
    
    PFQuery *queryRole = [PFRole query];
    [queryRole whereKey:@"users" containedIn:@[[PFUser currentUser]]];
    [queryRole whereKey:@"name" containsString:kAdministratorRoleSuffix];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        PFRole *adminRole = (PFRole *)object;
        NSString *organizationName = [[adminRole name] stringByReplacingOccurrencesOfString:kAdministratorRoleSuffix withString:@""];
        PFQuery *pendingQuery = [PFRole query];
        [pendingQuery whereKey:@"name" equalTo:[organizationName stringByAppendingString:kPendingVolunteerRoleSuffix]];
        [pendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            userRelationQuery = [[(PFRole *)object relationForKey:@"users"] query];
            [self loadObjects];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(PFQuery *)queryForTable
{
    return userRelationQuery;
}

- (void)pendingVolunteerChanged:(NSNotification *)notification
{
    [PFQuery clearAllCachedResults];
    [self loadObjects];
}

# pragma mark UITableView Methods
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"VolunteerHeader"];
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(header.contentView.frame.origin.x,
                             header.contentView.frame.size.height - 1,
                             header.contentView.frame.size.width,
                             1);
    layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    [[header.contentView layer] addSublayer:layer];
    
    return header.contentView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"VolunteerHeader"];
    return header.contentView.bounds.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"volunteerCell"];
    PFUser *user = [[self objects] objectAtIndex:indexPath.row];
    [[cell textLabel] setText:user[@"username"]];
    [[cell detailTextLabel] setText:@"Potential Volunteer"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // move this Volunteer from pending to a real Volunteer
    PFUser *approvedUser = [self.objects objectAtIndex:indexPath.row];
    [[InventoryDataManager sharedManager] addPendingVolunteerToOrganization:approvedUser];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PFUser *dismissedUser = [self.objects objectAtIndex:indexPath.row];
    [[InventoryDataManager sharedManager] removePendingVolunteer:dismissedUser];
}
@end
