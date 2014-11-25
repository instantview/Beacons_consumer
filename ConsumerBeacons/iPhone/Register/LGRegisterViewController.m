//
//  LGRegisterViewController.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 9/26/14.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import "LGRegisterViewController.h"
#import "LGBeaconFinderViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIColor+UIColorCategory.h"
#import "Constants.h"
#import "AFNetworking.h"

@interface LGRegisterViewController () <UITextFieldDelegate, MBProgressHUDDelegate> {
	MBProgressHUD *HUD;
}

@property (nonatomic) UITextField *inputEmail;
@property (nonatomic) UITextField *inputPassword;
@property (nonatomic) UITextField *inputName;
@property (nonatomic) UITextField *inputPhone;
@property (nonatomic) UILabel *messageText;
@property (nonatomic) UIButton *buttonLogin;

@end

@implementation LGRegisterViewController

@synthesize inputPassword;
@synthesize inputEmail;
@synthesize inputName;
@synthesize inputPhone;
@synthesize messageText;
@synthesize buttonLogin;

NSString *const kFormNameDefault = @"Full Name";
NSString *const kFormEmailDefault = @"Email";
NSString *const kFormPasswordDefault = @"Password";
NSString *const kFormPhoneDefault = @"Phone";

- (id)init
{
	self = [super init];
	
	if (self){
		[self setup];
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setup
{
	self.view.backgroundColor = [UIColor colorWithHexString:@"0x222222"];
	
	UIButton *button = [UIButton new];
	button.frame = CGRectMake((self.view.frame.size.width / 2) - 125, 20, 250, 40);
	button.tintColor = [UIColor greenColor];
	button.titleLabel.tintColor = [UIColor greenColor];
	button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
	
	[button setTitle:@"Already have an account? Login" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:button];
	[self.view bringSubviewToFront:button];
	
	UIView *containerView = [UIView new];
	containerView.backgroundColor = [UIColor whiteColor];
	containerView.frame = CGRectMake((self.view.frame.size.width / 2) - 145, 80, 290, 250);
	containerView.layer.borderWidth = 1.0f;
	containerView.layer.borderColor = [UIColor colorWithHexString:@"0xEEEEEE"].CGColor;
	
	[self.view addSubview:containerView];
	
	self.messageText = [UILabel new];
	self.messageText.frame = CGRectMake((containerView.frame.size.width / 2) - 145, 20, 290, 30);
	self.messageText.font = [UIFont systemFontOfSize:14.0f];
	self.messageText.text = @"Add your details";
	self.messageText.textAlignment = NSTextAlignmentCenter;
	
	[containerView addSubview:self.messageText];
	
	// Name field
	self.inputName = [UITextField new];
	self.inputName.frame = CGRectMake((containerView.frame.size.width / 2) - 135, 70, 270, 30);
	self.inputName.borderStyle = UITextBorderStyleRoundedRect;
	self.inputName.text = kFormNameDefault;
	self.inputName.font = [UIFont systemFontOfSize:14.0f];
	self.inputName.delegate = self;
	self.inputName.tag = 1;
	
	[containerView addSubview:self.inputName];
	
	// Email field
	self.inputEmail = [UITextField new];
	self.inputEmail.frame = CGRectMake((containerView.frame.size.width / 2) - 135, 110, 270, 30);
	self.inputEmail.borderStyle = UITextBorderStyleRoundedRect;
	self.inputEmail.text = kFormEmailDefault;
	self.inputEmail.font = [UIFont systemFontOfSize:14.0f];
	self.inputEmail.delegate = self;
	self.inputEmail.tag = 2;
	
	[containerView addSubview:self.inputEmail];
	
	// Phone field
	self.inputPhone = [UITextField new];
	self.inputPhone.frame = CGRectMake((containerView.frame.size.width / 2) - 135, 150, 270, 30);
	self.inputPhone.borderStyle = UITextBorderStyleRoundedRect;
	self.inputPhone.text = kFormPhoneDefault;
	self.inputPhone.font = [UIFont systemFontOfSize:14.0f];
	self.inputPhone.delegate = self;
	self.inputPhone.tag = 3;
	
	[containerView addSubview:self.inputPhone];
	
	// Password field
	self.inputPassword = [UITextField new];
	self.inputPassword.frame = CGRectMake((containerView.frame.size.width / 2) - 135, 190, 270, 30);
	self.inputPassword.borderStyle = UITextBorderStyleRoundedRect;
	self.inputPassword.text = kFormPasswordDefault;
	self.inputPassword.font = [UIFont systemFontOfSize:14.0f];
	self.inputPassword.delegate = self;
	self.inputPassword.tag = 4;
	
	[containerView addSubview:self.inputPassword];
	
	// Login button
	self.buttonLogin = [UIButton new];
	self.buttonLogin.frame = CGRectMake((self.view.frame.size.width / 2) - 145, 340, 290, 50);
	self.buttonLogin.backgroundColor = [UIColor yellowColor];
	self.buttonLogin.backgroundColor = [UIColor yellowColor];
	self.buttonLogin.layer.cornerRadius = 5.0f;
	self.buttonLogin.titleLabel.font = [UIFont systemFontOfSize:15.0f];
	
	[self.buttonLogin setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
	[self.buttonLogin setTitle:@"Create Account" forState:UIControlStateNormal];
	[self.buttonLogin addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:self.buttonLogin];
}

- (void)login
{
	[self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)createAccount
{
	[self showActivity];
	
	NSString *url = [NSString stringWithFormat:@"%@/user/RequestUserAccount", kBaseAPIUrl];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	
	NSDictionary *params = @{@"name" : self.inputName.text,
							 @"password" : self.inputPassword.text,
							 @"email" : self.inputEmail.text,
							 @"telephone" : self.inputPhone.text,
							 @"level": @"0"};
	
	[manager POST:url
	   parameters:params
		  success:^(AFHTTPRequestOperation *operation, id responseObject){
			  
			  NSLog(@"%@", responseObject);
			  
			  if ([responseObject objectForKey:@"guid"]){
				  
				  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				  [defaults setValue:responseObject[@"guid"] forKey:@"guid"];
				  
				  // When the login has been successful
				  LGBeaconFinderViewController *allBeacons = [[LGBeaconFinderViewController alloc] initWithNibName:@"BeaconFinder" bundle:nil];
				  
				  UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:allBeacons];
				  navigation.navigationBar.barTintColor = [UIColor colorWithHexString:@"0xFFEE00"];
				  navigation.navigationBar.translucent = YES;
				  
				  self.view.window.rootViewController = navigation;
				  
			  } else {
				  
				  NSLog(@"Couldn't log you in %@", responseObject[@"message"]);
				  
				  HUD.mode = MBProgressHUDModeText;
				  HUD.labelText =  [NSString stringWithFormat:@"Incorrect Login"];
				  HUD.detailsLabelText = @"Please try again.";
				  
				  [HUD hide:YES afterDelay:2];
				  
			  }
			  
		  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			  
			  HUD.mode = MBProgressHUDModeText;
			  HUD.labelText =  [NSString stringWithFormat:@"Server error"];
			  HUD.detailsLabelText = @"Please try again.";
			  
			  [HUD hide:YES afterDelay:2];
			  
			  NSLog(@"Failure: %@", error);
		  }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if ([textField.text isEqualToString:kFormEmailDefault] ||
		[textField.text isEqualToString:kFormNameDefault] ||
		[textField.text isEqualToString:kFormPhoneDefault] ||
		[textField.text isEqualToString:kFormPasswordDefault])
	{
		textField.text = @"";
	}
	
	if (textField.tag == 2){
		textField.keyboardType = UIKeyboardTypeEmailAddress;
	}
	
	if (textField.tag == 4){
		textField.secureTextEntry = YES;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if ([textField.text isEqualToString:@""]){
		
		if (textField.tag == 1){
			textField.text = kFormNameDefault;
		}
		
		if (textField.tag == 2){
			textField.text = kFormEmailDefault;
		}
		
		if (textField.tag == 3){
			textField.text = kFormPhoneDefault;
		}
		
		if (textField.tag == 4){
			textField.text = kFormPasswordDefault;
			textField.secureTextEntry = NO;
		}
	}
}

- (void)setErrorMessageText:(NSString *)errorMessage
{
	self.messageText.textColor = [UIColor redColor];
	self.messageText.text = errorMessage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// clear the keyboard with a touch on the screen
	[self.inputEmail resignFirstResponder];
	[self.inputPassword resignFirstResponder];
	[self.inputName resignFirstResponder];
	[self.inputPhone resignFirstResponder];
}

- (void)showActivity
{
	[self.view endEditing:YES];
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.mode = MBProgressHUDModeIndeterminate;
	
	[HUD show:YES];
}

- (void)hideActivity
{
	[HUD show:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
