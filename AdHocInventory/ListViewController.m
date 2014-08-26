//
//  ListViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/13/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "ListViewController.h"
#import "InventoryDataManager.h"
#import "InventoryItem.h"
#import "BarcodeGenerator.h"
#import "ItemViewController.h"

@interface ListViewController ()

@property(strong,nonatomic)NSArray *dataArray;

@end

@implementation ListViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setParseClassName:kPFInventoryClassName];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // refreshData - load all inventory data into an array
    [self loadObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showItem"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        ItemViewController *controller = (ItemViewController *)navController.topViewController;
        PFObject *inventoryItem = [self objectAtIndexPath:indexPath];
        
        InventoryItem *item = [[InventoryItem alloc] initWithPFObject:inventoryItem];
        [controller setItem:item];
    }
}

- (PFQuery *)queryForTable;
{
    PFQuery *query = [PFQuery queryWithClassName:kPFInventoryClassName];
    [query whereKeyDoesNotExist:@"soldItem"];
    return query;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (PFTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"barcode" forIndexPath:indexPath];
    
    InventoryItem *item = [[InventoryItem alloc] initWithPFObject:object];
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@, %@",[item itemDescription],[item category]]];
    CIImage *qr =[BarcodeGenerator qrcodeImageForInventoryItem:item];
    [[cell imageView] setImage:[UIImage createNonInterpolatedUIImageFromCIImage:qr withScale:1.0]];
    return cell;
}

@end
