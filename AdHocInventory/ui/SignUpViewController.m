//
//  SignUpViewController.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/29/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "SignUpViewController.h"
#import "HTAutocompleteManager.h"
#import "HTAutocompleteTextField.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

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
    
    [[self signUpView] setLogo:logo];
    
    HTAutocompleteTextField *email = [[HTAutocompleteTextField alloc] initWithFrame:[[[self signUpView] emailField] frame]];
    [email setAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    [email setAutocompleteType:HTAutocompleteTypeEmail];
    [email setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email",@"Signup - email placeholder text")
                                                                    attributes:@{NSForegroundColorAttributeName: [self.signUpView.emailField.attributedPlaceholder attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL]}]];

//  [email setTextAlignment:NSTextAlignmentCenter]; until the bug in HTAutoComplete is resolved, just use left align
    [email setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [email setTextColor:[self.signUpView.emailField textColor]];
    [email.layer setShadowColor:[self.signUpView.emailField.layer shadowColor]];
    [email.layer setShadowOffset:[self.signUpView.emailField.layer shadowOffset]];
    [email.layer setShadowOpacity:[self.signUpView.emailField.layer shadowOpacity]];
    [email.layer setShadowRadius:[self.signUpView.emailField.layer shadowRadius]];
    
    [[[self signUpView] emailField] removeFromSuperview];
    [[self signUpView] setValue:email forKey:@"emailField"];
    [[self signUpView] addSubview:email];
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
