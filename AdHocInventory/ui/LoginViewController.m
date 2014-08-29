//
//  LoginViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/28/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *logo = [UILabel new];
    [logo setText:@"AdHoc Inventory"];
    [logo setTextColor:[UIColor colorWithWhite:0.90 alpha:1.0]];
    [logo setShadowColor:[UIColor colorWithWhite:0.25 alpha:0.5]];
    [logo setShadowOffset:CGSizeMake(0,2)];
    [logo setFont:[UIFont systemFontOfSize:32.0f]];
    [logo sizeToFit];
    
    [[self logInView] setLogo:logo];
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

@end
