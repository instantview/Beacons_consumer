//
//  LGBeaconFinderViewController.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 02/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "LGBeaconFinderViewController.h"
#import "LGLoginViewController.h"
#import "LGOfferViewController.h"
#import "LGBeaconTableViewCell.h"
#import "UIColor+UIColorCategory.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LGBeaconFinderViewController () <CLLocationManagerDelegate, CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *detectedBeacons;
@property (nonatomic) NSMutableArray *offers;
@property (strong, nonatomic) CBCentralManager *bluetoothManager;



@end

@implementation LGBeaconFinderViewController

@synthesize activity;
@synthesize searchingLabel;
@synthesize detectedBeacons;
@synthesize tableView;
@synthesize offers;
@synthesize bluetoothManager;

NSString *const kUUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
NSString *const kDefaultBeaconIdentifier = @"com.instantview.beacons";

bool bluetoothEnabled = NO;

int const kCellHeight = 100;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        [self setup];
        [self setupBeaconFinding];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setup
{
	self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
																 queue:nil
															   options:nil];
	self.offers = [NSMutableArray new];
	self.detectedBeacons = [NSMutableArray new];
	
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"Discovered Offers";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
																			 style:UIBarButtonItemStyleDone
																			target:self
																			action:@selector(logout)];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0x333333"];
    self.searchingLabel.textColor = [UIColor colorWithHexString:@"0xEEEEEE"];
    self.activity.color = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)
												  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"0x333333"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([self.tableView respondsToSelector:@selector(separatorInset)])
    {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [self.view addSubview:self.tableView];
}

- (void)setupBeaconFinding
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]])
    {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString: kUUID];
        
        self.beaconRegion = [[CLBeaconRegion alloc]
                             initWithProximityUUID:self.proximityUUID
                             identifier: kDefaultBeaconIdentifier];
        self.beaconRegion.notifyEntryStateOnDisplay = NO;
        self.beaconRegion.notifyOnEntry = YES;
        self.beaconRegion.notifyOnExit = YES;
		
		if(IS_OS_8_OR_LATER) {
			[self.locationManager requestAlwaysAuthorization];
		}
		
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (void)bluetoothServiceUpdate
{
	BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
	
	if (!bluetoothEnabled || !locationAllowed)
	{
		[self displayMessage:@"Please enable bluetooth and location services."];
	}
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:region];
    //[self sendNotificationForMessage:@"Start monitoring..."];
    NSLog(@"Start monitoring...");
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed to monitor for region. Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed to range for beacons in region. Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //[self sendNotificationForMessage:@"Enter region"];
    NSLog(@"Enter region...");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    //[self sendNotificationForMessage:@"Exit region"];
    NSLog(@"Exit region...");
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable])
            {
                NSLog(@"Inside");
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
            break;
        case CLRegionStateOutside:
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable])
            {
                NSLog(@"Outside");
                //[self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
            }
        case CLRegionStateUnknown:
        default:
            NSLog(@"Default");
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
		didRangeBeacons:(NSArray *)beacons
			   inRegion:(CLBeaconRegion *)region
{
    NSLog(@"Total beacons: %d", [beacons count]);
    
    NSMutableArray *visibleBeacons = [NSMutableArray new];
    
    for(CLBeacon *beacon in beacons)
    {
        NSString *beaconID = [self createBeaconIDFromBeacon:beacon];
        
        [visibleBeacons addObject:beaconID];
		
		switch (beacon.proximity)
		{
			case CLProximityNear:
				NSLog(@"Near");
				break;
			case CLProximityImmediate:
				NSLog(@"Immediate");
				break;
			case CLProximityUnknown:
				NSLog(@"Unknown");
				break;
			case CLProximityFar:
				NSLog(@"Far");
				break;
		}
		
		if (beacon.proximity == CLProximityFar)
		{
			[self removeBeaconFromDictionary:beaconID];
		}
		
        if (![self.detectedBeacons containsObject:beaconID])
        {
			if (CLProximityNear == beacon.proximity || CLProximityImmediate == beacon.proximity)
			{
				[self addBeaconToDictionary:beaconID];
			}
        }
    }
    
    for (id key in self.detectedBeacons)
    {
        if(![visibleBeacons containsObject:key])
        {
            [self removeBeaconFromDictionary:key];
        }
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	bluetoothEnabled = ([central state] == CBCentralManagerStatePoweredOn) ? YES: NO;
	[self bluetoothServiceUpdate];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"%@", error);
	self.detectedBeacons = NULL;
	self.offers = NULL;
	
	[self.tableView reloadData];
	[self bluetoothServiceUpdate];
}

- (NSString *)createBeaconIDFromBeacon:(CLBeacon *)beacon
{
    return [NSString stringWithFormat:@"%@-%d-%d",
                          [beacon.proximityUUID UUIDString],
                          [beacon.major integerValue],
                          [beacon.minor integerValue]];
}

- (void)addBeaconToDictionary:(NSString *)beaconID
{
	[self.detectedBeacons addObject:beaconID];
	
	NSString *url = [NSString stringWithFormat:@"%@/product/getProduct", kBaseAPIUrl];
	NSDictionary *params = @{@"UUID": beaconID};
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	
	[manager  GET:url
	   parameters:params
		  success:^(AFHTTPRequestOperation *operation, id responseObject){
			  
			  NSLog(@"Beacon info: %@", responseObject);
			  
			  NSDictionary *productInfo = @{
											@"imageURL" : responseObject[@"imageURL"],
											@"price" : responseObject[@"price"],
											@"productName" : responseObject[@"productName"]
											};
			  
			  [self getProductOffers:beaconID withProductInfo:productInfo];
			  
		  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			  NSLog(@"Error: %@", error);
		  }];
}

- (void)getProductOffers:(NSString *)beaconId
		 withProductInfo:(NSDictionary *)productInfo
{
	NSString *url = [NSString stringWithFormat:@"%@/offer/getProductOffersByUUID", kBaseAPIUrl];
	NSDictionary *params = @{@"beaconUUID": beaconId};
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	
	[manager  GET:url
	   parameters:params
		  success:^(AFHTTPRequestOperation *operation, id responseObject){
			  
			  NSLog(@"%@", responseObject);
			  
			  for (NSDictionary *offer in responseObject)
			  {
				  NSMutableDictionary *newOffer = [offer mutableCopy];
				  
				  [newOffer setValue:beaconId forKey:@"UUID"];
				  [newOffer setValue:productInfo[@"imageURL"] forKey:@"imageURL"];
				  [newOffer setValue:productInfo[@"productName"] forKey:@"productName"];
				  [newOffer setValue:productInfo[@"price"] forKey:@"price"];
				  
				  [self.offers addObject:newOffer];
			  }
			  
			  [self sendNotificationForMessage:@"You have discovered new offers."];
			  [self.tableView reloadData];
			  
		  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			  NSLog(@"Error: %@", error);
		  }];
}

- (void)removeBeaconFromDictionary:(NSString *)beaconID
{
	[self.detectedBeacons removeObject:beaconID];
	
	NSArray *offersCopy = [self.offers copy];
	
	for (int i=0; i<[offersCopy count]; i++)
	{
		NSDictionary *offer = [offersCopy objectAtIndex:i];
		
		if ([offer[@"UUID"] isEqualToString:beaconID])
		{
			NSLog(@"removing offer");
			[self.offers removeObjectAtIndex:i];
		}
	}
	
    [self.tableView reloadData];
}

- (void)sendNotificationForMessage:(NSString *)notificationText
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = notificationText;
    notification.fireDate = [NSDate date];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

# pragma mark - UITableView Delegates and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.hidden = (self.offers.count == 0) ? YES : NO;
    return self.offers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    
    LGBeaconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[LGBeaconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	NSDictionary *offer = [self.offers objectAtIndex:indexPath.row];
	
	cell.beaconName.text = offer[@"productName"];
	cell.offerStrapline.text = offer[@"title"];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsLayout];
    [cell setNeedsDisplay];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LGOfferViewController *offer = [[LGOfferViewController alloc] initWithBeacon:[self.offers objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:offer animated:YES];
}

- (void)logout
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:@"guid"];
	
	LGLoginViewController *login = [LGLoginViewController new];
	
	[self presentViewController:login animated:NO completion:nil];
}

- (void)displayMessage:(NSString *)message
{
	UIView *messageView = [UIView new];
	messageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
	messageView.backgroundColor = [UIColor whiteColor];
	messageView.layer.masksToBounds = NO;
	messageView.layer.shadowOffset = CGSizeMake(0, 4);
	messageView.layer.shadowRadius = 5;
	messageView.layer.shadowOpacity = 0.25;
	
	UILabel *messageLabel = [UILabel new];
	messageLabel.frame = CGRectMake(0, 0, messageView.frame.size.width, messageView.frame.size.height);
	messageLabel.text = message;
	messageLabel.textAlignment = NSTextAlignmentCenter;
	messageLabel.font = [UIFont boldSystemFontOfSize:12.0];
	
	[messageView addSubview:messageLabel];
	[self.view addSubview:messageView];
	[self performSelector:@selector(removeMessage:) withObject:messageView afterDelay:5];
}

- (void)removeMessage:(UIView *)messageView
{
	[messageView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
