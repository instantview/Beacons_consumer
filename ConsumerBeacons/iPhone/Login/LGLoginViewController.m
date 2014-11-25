//
//  LGLoginViewController.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 9/26/14.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import "LGLoginViewController.h"
#import "LGBeaconFinderViewController.h"
#import "LGRegisterViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIColor+UIColorCategory.h"
#import "Constants.h"
#import "AFNetworking.h"

@interface LGLoginViewController () <UITextFieldDelegate, MBProgressHUDDelegate> {
	MBProgressHUD *HUD;
}

@property (nonatomic) UITextField *inputEmail;
@property (nonatomic) UITextField *inputPassword;
@property (nonatomic) UILabel *messageText;
@property (nonatomic) UIButton *buttonLogin;

@end

@implementation LGLoginViewController

@synthesize inputEmail;
@synthesize inputPassword;
@synthesize messageText;
@synthesize buttonLogin;

NSString *const kInputEmailDefault = @"Email";
NSString *const kInputPasswordDefault = @"Password";

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
	
	[button setTitle:@"Need an account? Create one here" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:button];
	[self.view bringSubviewToFront:button];
	
	UIView *containerView = [UIView new];
	containerView.backgroundColor = [UIColor whiteColor];
	containerView.frame = CGRectMake((self.view.frame.size.width / 2) - 145, 80, 290, 150);
	containerView.layer.borderWidth = 1.0f;
	containerView.layer.borderColor = [UIColor colorWithHexString:@"0xEEEEEE"].CGColor;
	
	[self.view addSubview:containerView];
	
	self.messageText = [UILabel new];
	self.messageText.frame = CGRectMake((containerView.frame.size.width / 2) - 145, 20, 290, 30);
	self.messageText.font = [UIFont systemFontOfSize:14.0f];
	self.messageText.text = @"Add your details";
	self.messageText.textAlignment = NSTextAlignmentCenter;
	
	[containerView addSubview:self.messageText];
	
	// Email field
	self.inputEmail = [UITextField new];
	self.inputEmail.frame = CGRectMake((containerView.frame.size.width / 2) - 135, 70, 270, 30);
	self.inputEmail.borderStyle = UITextBorderStyleRoundedRect;
	self.inputEmail.text = kInputEmailDefault;
	self.inputEmail.font = [UIFont systemFontOfSize:14.0f];
	self.inputEmail.delegate = self;
	self.inputEmail.tag = 1;
	
	[containerView addSubview:self.inputEmail];
	
	// Password field
	self.inputPassword = [UITextField new];
	self.inputPassword.frame = CGRectMake((containerView.frame.size.width / 2) - 135, 110, 270, 30);
	self.inputPassword.borderStyle = UITextBorderStyleRoundedRect;
	self.inputPassword.text = kInputPasswordDefault;
	self.inputPassword.font = [UIFont systemFontOfSize:14.0f];
	self.inputPassword.delegate = self;
	self.inputPassword.tag = 2;
	
	[containerView addSubview:self.inputPassword];
	
	// Login button
	self.buttonLogin = [UIButton new];
	self.buttonLogin.frame = CGRectMake((self.view.frame.size.width / 2) - 145, 240, 290, 50);
	self.buttonLogin.backgroundColor = [UIColor yellowColor];
	self.buttonLogin.backgroundColor = [UIColor yellowColor];
	self.buttonLogin.layer.cornerRadius = 5.0f;
	self.buttonLogin.titleLabel.font = [UIFont systemFontOfSize:15.0f];
	
	[self.buttonLogin setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
	[self.buttonLogin setTitle:@"Login" forState:UIControlStateNormal];
	[self.buttonLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:self.buttonLogin];
	
}

- (IBAction)login:(id)sender
{
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Logging in...";
	HUD.delegate = self;
	
	[HUD show:YES];
	
	[self.inputEmail resignFirstResponder];
	[self.inputPassword resignFirstResponder];
	
	if ([self.inputEmail.text isEqualToString:kInputEmailDefault] || [self.inputEmail.text isEqualToString:@""])
	{
		[HUD hide:YES];
		[self setErrorMessageText:@"Please enter your email address"];
		return;
	}
	
	if (![self validEmail:self.inputEmail.text])
	{
		[HUD hide:YES];
		[self setErrorMessageText:@"Please enter a valid email address"];
		return;
	}
	
	if ([self.inputPassword.text isEqualToString:kInputPasswordDefault] || [self.inputPassword.text isEqualToString:@""])
	{
		[HUD hide:YES];
		[self setErrorMessageText:@"Please enter your password"];
		return;
	}

		NSLog(@"%@", kBaseAPIUrl);
		
		NSString *url = [NSString stringWithFormat:@"%@/user/UserLogin", kBaseAPIUrl];
		
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFJSONResponseSerializer serializer];
		
		NSDictionary *params = @{@"email" : self.inputEmail.text, @"password" : self.inputPassword.text};
		
		[manager POST:url
		   parameters:params
			  success:^(AFHTTPRequestOperation *operation, id responseObject){
				  
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

- (void)createAccount
{
	LGRegisterViewController *registerVC = [LGRegisterViewController new];
	[self presentViewController:registerVC animated:NO completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if ([textField.text isEqualToString:kInputEmailDefault] ||
		[textField.text isEqualToString:kInputPasswordDefault]){
		textField.text = @"";
	}
	
	if (textField.tag == 2){
		textField.secureTextEntry = YES;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if ([textField.text isEqualToString:@""]){
		
		if (textField.tag == 1){
			textField.text = kInputEmailDefault;
		}
		
		if (textField.tag == 2){
			textField.text = kInputPasswordDefault;
			textField.secureTextEntry = NO;
		}
		
	}
}

- (BOOL)validEmail:(NSString*) emailString
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

- (void)setErrorMessageText:(NSString *)errorMessage
{
	self.messageText.textColor = [UIColor redColor];
	self.messageText.text = errorMessage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.inputEmail resignFirstResponder];
	[self.inputPassword resignFirstResponder];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
}

@end
