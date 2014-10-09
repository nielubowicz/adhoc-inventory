//
//  FirstViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/11/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "InputViewController.h"
#import "OrganizationViewController.h"
#import "InventoryDataManager.h"
#import "BarcodeGenerator.h"
#import "InventoryItem.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"
#import "UIView+Toast.h"
#import "HTAutocompleteManager.h"
#import "HTAutocompleteTextField.h"
#import "PendingEmployeesViewController.h"

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize category;
@synthesize itemDescription;
@synthesize notes;
@synthesize quantity;
@synthesize quantityStepper;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDefaultBackground];
    
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemAdded:) name:kInventoryItemAddedNotification object:nil];
    
    [category setAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    [category setAutocompleteType:HTAutocompleteTypeCategory];
    
    [self updateQuantity:quantityStepper];
    [[[self view] subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[HTAutocompleteTextField class]])
        {
            CALayer *layer = obj.layer;
            layer.cornerRadius = 1.0f;
            layer.borderColor = [UIColor lightTealColor].CGColor;
            layer.borderWidth = 2.0f;
        }
    }];
    
    if ([PFUser currentUser] != nil) {
        PFQuery *queryRole = [PFRole query];
        [queryRole whereKey:@"users" containedIn:@[[PFUser currentUser]]];
        [queryRole whereKey:@"name" containsString:kAdministratorRoleSuffix];
        [queryRole getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object == nil || error != nil) {
                NSLog(@"Not admin, won't show new stuff");
                return;
            }
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            
            // add Pending Employees / Volunteers
            UIViewController *pending = [sb instantiateViewControllerWithIdentifier:@"pendingEmployees"];
            [self.tabBarController performSelectorOnMainThread:@selector(setViewControllers:)
                                                    withObject:[[[self tabBarController] viewControllers] arrayByAddingObject:pending]
                                                 waitUntilDone:YES];
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![PFUser currentUser]) { // No user logged in
        [self presentLoginViewController];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)reset:(UIStoryboardSegue *)segue {
    //do stuff
}

#pragma mark -
- (void)presentLoginViewController {
    UILabel *logo = [UILabel new];
    [logo setBackgroundColor:[UIColor clearColor]];
    [logo setText:@"AdHoc Inventory"];
    [logo setTextColor:[UIColor colorWithWhite:0.90 alpha:1.0]];
    [logo setShadowColor:[UIColor colorWithWhite:0.25 alpha:0.5]];
    [logo setShadowOffset:CGSizeMake(0,2)];
    [logo setFont:[UIFont systemFontOfSize:32.0f]];
    [logo sizeToFit];
    
    // Create the log in view controller
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [[logInViewController logInView] setLogo:logo];
    
    UILabel *logo2 = [UILabel new];
    [logo2 setBackgroundColor:[UIColor clearColor]];
    [logo2 setText:@"AdHoc Inventory"];
    [logo2 setTextColor:[UIColor colorWithWhite:0.90 alpha:1.0]];
    [logo2 setShadowColor:[UIColor colorWithWhite:0.25 alpha:0.5]];
    [logo2 setShadowOffset:CGSizeMake(0,2)];
    [logo2 setFont:[UIFont systemFontOfSize:32.0f]];
    [logo2 sizeToFit];
    
    // Create the sign up view controller
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    [[signUpViewController signUpView] setLogo:logo2];
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (IBAction)logout:(id)sender {
    if ([PFUser currentUser]) {
        [PFQuery clearAllCachedResults];
        [PFUser logOut];
        [self presentLoginViewController];
    }
}

#pragma mark PFLoginViewControllerDelegate methods
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"Login missing infomation - Alert title")
                                message:NSLocalizedString(@"Make sure you fill out all of the information!",@"Login missing infomation - Message")
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK",@"Alert - accept")
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Incorrect Credentials",@"Login failed - Alert title")
                                message:NSLocalizedString(@"The username or password you entered is incorrect.",@"Login failed - Message")
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"OK",@"Alert - accept")
                      otherButtonTitles:nil] show];
    
    [[[logInController logInView] usernameField] setClearButtonMode:UITextFieldViewModeAlways];
    [[[logInController logInView] passwordField] setClearButtonMode:UITextFieldViewModeAlways];
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PFSignupViewControllerDelegate methods
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"Signup missing infomation - Alert title")
                                    message:NSLocalizedString(@"Make sure you fill out all of the information!",@"Signup missing infomation - Message")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK",@"Alert - accept")
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        // then prompt user for their organization. the first user per organization will be the de facto admin
        [self performSegueWithIdentifier:@"showOrganizations" sender:self];
    }];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - 
#pragma mark UI / Keyboard methods
- (IBAction)handleSingleTap:(id)sender
{
    [[[self view] subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj resignFirstResponder];
    }];
}

- (IBAction)updateQuantity:(UIStepper *)sender
{
    [quantity setText:[NSString stringWithFormat:NSLocalizedString(@"Quantity: %d",@"Quantity string"),(int)[sender value]]];
}

#pragma mark -
#pragma mark Add item methods
- (IBAction)addItem:(id)sender
{
    InventoryDataManager *db = [InventoryDataManager sharedManager];

    if ([[itemDescription text] length] == 0)
    {
        return;
    }
    
    if ([[category text] length] == 0)
    {
        return;
    }
    
    [db addItem:[itemDescription text] category:[category text] notes:[notes text] quantity:(uint)[quantityStepper value]];
    
    [[[self view] subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UITextField class]])
        {
            [(UITextField *)obj setText:@""];
            [obj resignFirstResponder];
        }
    }];
}

- (void)itemAdded:(NSNotification *)notification
{
    InventoryItem *item = [notification object];
    [self.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"Added %@",@"Item added Toast message - Description"),[item itemDescription]]
                duration:3.0
                position:@"bottom"
                   title:[NSString stringWithFormat:NSLocalizedString(@"%@:", @"Item added Toast Title - Category"), [item category]]
                   image:[item qrCode]];
 
}

@end
