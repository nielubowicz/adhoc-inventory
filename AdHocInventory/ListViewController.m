//
//  ListViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/13/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "ListViewController.h"
#import "DatabaseManager.h"
#import "InventoryItem.h"
#import "BarcodeGenerator.h"

@interface ListViewController ()

@property(strong,nonatomic)NSArray *dataArray;

@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // refreshData - load all inventory data into an array
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Data methods
- (void)refreshData
{
    _dataArray = [[DatabaseManager sharedManager] allInventoryItems];
    [[self tableView] reloadData];    
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [_dataArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"barcode" forIndexPath:indexPath];
    InventoryItem *item = [_dataArray objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@, %@",[item description],[item category]]];
    [[cell imageView] setImage:[BarcodeGenerator generateBarcodeForInventoryID:[item inventoryID]]];
    return cell;
}

@end
