//
//  LGLoginViewController.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 9/3/14.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "LGLoginViewController.h"
#import "LGBeaconFinderViewController.h"

@interface LGLoginViewController () <MBProgressHUDDelegate, UITextFieldDelegate>{
	MBProgressHUD *HUD;
}

@end

@implementation LGLoginViewController

@synthesize containerView;
@synthesize message;
@synthesize inputPassword;
@synthesize inputEmail;

NSString *const kDefaultEmail = @"Email";
NSString *const kDefaultPassword = @"Password";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inputEmail.delegate = self;
    self.inputPassword.delegate = self;
}

- (void)setup
{
	self.view.backgroundColor = [UIColor colorWithRed:(247/255.0)
												green:(247/255.0)
												 blue:(247/255.0)
												alpha:1];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Textfield didxbegin editing...");
    
	if (textField.tag == 1 && [textField.text isEqualToString:kDefaultEmail])
	{
        NSLog(@"Removing contents of email field");
		textField.text = @"";
	}
	
	if (textField.tag == 2 && [textField.text isEqualToString:kDefaultPassword])
	{
        NSLog(@"Removing contents of password field");
		textField.secureTextEntry = YES;
		textField.text = @"";
	}
    
    [self animateTextField:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField.tag == 1 && [textField.text isEqualToString:@""])
	{
		textField.text = kDefaultEmail;
	}
	
	if (textField.tag == 2 && [textField.text isEqualToString:@""])
	{
		textField.secureTextEntry = NO;
		textField.text = kDefaultPassword;
	}
    
    [self animateTextField:NO];
}

- (IBAction)login:(id)sender
{
	if ([inputEmail.text isEqualToString:kDefaultEmail] || [inputEmail.text isEqualToString:@""])
	{
		[self setErrorMessage:@"Please enter your email address"];
	}
	
	if (![self isValidEmail:inputEmail.text])
	{
		[self setErrorMessage:@"Please enter a valid email address"];
	}
	
	if ([inputPassword.text isEqualToString:@""] || [inputPassword.text isEqualToString:kDefaultPassword])
	{
		[self setErrorMessage:@"Please enter your password"];
	}
	
	[self showLoginActivity];
	
	if (![self validLogin])
	{
		[self hideLoginActivity];
        [self setErrorMessage:@"Incorrect login. Please try again."];
		
        self.containerView.hidden = NO;
	}
	else
	{
		LGBeaconFinderViewController *beaconFinder = [[LGBeaconFinderViewController alloc] initWithNibName:@"BeaconFinder" bundle:nil];
		
		UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:beaconFinder];
		navigation.navigationBar.backgroundColor = [UIColor blueColor];
        navigation.navigationBar.translucent = NO;
		
		self.view.window.rootViewController = navigation;
	}
	
}

- (BOOL)isValidEmail:(NSString*) emailString
{
    if([emailString length]==0)
    {
        return NO;
    }
	
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
	
    if (regExMatches == 0) {
        return NO;
    }
	
    return YES;
}

- (void)showLoginActivity
{
	[self.view endEditing:YES];
	
    // Update the view to reflect the login process happening
    self.containerView.hidden = YES;
	
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
	
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeIndeterminate;
	
    [HUD show:YES];
}

- (void)hideLoginActivity
{
	[HUD show:NO];
}

- (BOOL)validLogin
{
	return YES;
}

- (void) animateTextField:(BOOL)up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)setErrorMessage:(NSString *)errorMessage
{
	self.message.textColor = [UIColor redColor];
	self.message.text = errorMessage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
