//
//  PendingEmployeesViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 9/29/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "PendingEmployeesViewController.h"
#import "InventoryDataManager.h"

@implementation PendingEmployeesViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pendingEmployeeChanged:) name:kEmployeeApprovedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pendingEmployeeChanged:) name:kEmployeeDeniedNotification object:nil];
    
    PFQuery *queryRole = [PFRole query];
    [queryRole whereKey:@"users" containedIn:@[[PFUser currentUser]]];
    [queryRole whereKey:@"name" containsString:kAdministratorRoleSuffix];
    [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        PFRole *adminRole = (PFRole *)object;
        NSString *organizationName = [[adminRole name] stringByReplacingOccurrencesOfString:kAdministratorRoleSuffix withString:@""];
        PFQuery *pendingQuery = [PFRole query];
        [pendingQuery whereKey:@"name" equalTo:[organizationName stringByAppendingString:kPendingEmployeeRoleSuffix]];
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

- (void)pendingEmployeeChanged:(NSNotification *)notification
{
    [PFQuery clearAllCachedResults];
    [self loadObjects];
}

# pragma mark UITableView Methods
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"EmployeeHeader"];
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
    UITableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"EmployeeHeader"];
    return header.contentView.bounds.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"employeeCell"];
    PFUser *user = [[self objects] objectAtIndex:indexPath.row];
    [[cell textLabel] setText:user[@"username"]];
    [[cell detailTextLabel] setText:@"Potential Employee"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // move this Employee from pending to a real Employee
    PFUser *approvedUser = [self.objects objectAtIndex:indexPath.row];
    [[InventoryDataManager sharedManager] addPendingEmployeeToOrganization:approvedUser];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PFUser *dismissedUser = [self.objects objectAtIndex:indexPath.row];
    [[InventoryDataManager sharedManager] removePendingEmployee:dismissedUser];
}

@end
