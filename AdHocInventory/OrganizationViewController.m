//
//  OrganizationViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 9/18/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "OrganizationViewController.h"
#import "InventoryDataManager.h"

@interface OrganizationViewController ()

@end

@implementation OrganizationViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setParseClassName:kPFOrganizationClassName];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDefaultBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)reset:(UIStoryboardSegue *)segue {
    //do stuff
}

- (PFTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"organization" forIndexPath:indexPath];
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@",object[kPFOrganizationNameKey]]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@, %@", object[kPFOrganizationCityKey],object[kPFOrganizationStateKey]]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewCell *newOrg = [tableView dequeueReusableCellWithIdentifier:@"addNew"];
    while (newOrg.contentView.gestureRecognizers.count) {
        [newOrg.contentView removeGestureRecognizer:[newOrg.contentView.gestureRecognizers objectAtIndex:0]];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewOrganization:)];
    [[newOrg contentView] addGestureRecognizer:tap];
    return [newOrg contentView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:NULL];
    return height;
}

- (void)showNewOrganization:(UIGestureRecognizer *)gesture {
    [self performSegueWithIdentifier:@"showNewOrganization" sender:self];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"selectedDismiss"]) {
        
        NSIndexPath *selectedIndexPath = [[self tableView] indexPathForSelectedRow];
        if (selectedIndexPath != nil)
        {
            PFObject *organization = [[self objects] objectAtIndex:[selectedIndexPath row]];
            [[InventoryDataManager sharedManager] addCurrentUserToOrganization:organization];
        }
    }
    else if ([[segue identifier] isEqualToString:@"showNewOrganization"])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newOrganizationAdded:)
                                                     name:kOrganizationAddedNotification object:nil];
    }
}

- (void)newOrganizationAdded:(NSNotification *)notification {
    [self performSegueWithIdentifier:@"selectedDismiss" sender:self];
}

@end
