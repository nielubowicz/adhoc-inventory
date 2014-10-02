//
//  AnalyticsOverviewViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 9/30/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "AnalyticsOverviewViewController.h"
#import "InventoryDataManager.h"
#import "CategoryAnalyticsViewController.h"

@interface AnalyticsOverviewViewController ()
{
    NSArray *categories;
}

@end

@implementation AnalyticsOverviewViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedString(@"Analytics",@"Analytics title - used for back button")];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor magentaColor];
    [refreshControl addTarget:self action:@selector(updateTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    // this is a hack
    // need to figure out how to order categories by group
    // except PFQuery's don't allow group-by statements
    
    // Parse recommends using cloud functions, but i need to look into how those are written/deployed and monitored (may be limited number of requests)
    categories = [[InventoryDataManager sharedManager] allCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (void)updateTable
{
    [self.refreshControl endRefreshing];
    categories = [[InventoryDataManager sharedManager] allCategories];
    [[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return categories.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"Most Popular Categories",@"Most popular categories section header");
            break;
        case 1:
            title = NSLocalizedString(@"Most Items Sold",@"Most items sold section header");
            break;
        case 2:
            title = NSLocalizedString(@"Most Money Generated",@"Most money generated section header");
            break;
        case 3:
            title = NSLocalizedString(@"Most Items Sold",@"Most items sold section header");
            break;
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    [[cell textLabel] setText:[categories objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get category for this row and query for this section
    // and feed that to Most XXXX in YYYY Category
    PFQuery *query = [PFQuery queryWithClassName:kPFInventoryClassName];
    [query includeKey:kPFInventorySoldItemKey];

    switch (indexPath.section) {
        case 0:
            // most popular
            [query orderByAscending:[kPFInventorySoldItemKey stringByAppendingFormat:@".%@",kPFInventoryTSSoldKey]];
            break;
        case 1:
            // most sold items
            [query orderByAscending:[kPFInventorySoldItemKey stringByAppendingFormat:@".%@",kPFInventoryTSSoldKey]];
            break;
        case 2:
            // most expensive stuff
            [query orderByAscending:[kPFInventorySoldItemKey stringByAppendingFormat:@".%@",kPFInventoryTSSoldKey]];
            break;
        case 3:
            // shortest shelf life
            [query orderByAscending:[kPFInventorySoldItemKey stringByAppendingFormat:@".%@",kPFInventoryTSSoldKey]];
            break;
        default:
            break;
    }
    [query whereKey:kPFInventoryCategoryKey equalTo:[categories objectAtIndex:indexPath.row]];
    
    CategoryAnalyticsViewController *categoryVC = [[CategoryAnalyticsViewController alloc] init];
    [categoryVC setCategory:[categories objectAtIndex:indexPath.row]];
    [categoryVC setTitle:categoryVC.category];
    [categoryVC setAnalyticsQuery:query];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:categoryVC];
    [self presentViewController:navController animated:YES completion:nil];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

@end
