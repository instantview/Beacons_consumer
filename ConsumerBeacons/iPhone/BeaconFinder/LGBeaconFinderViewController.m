//
//  LGBeaconFinderViewController.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 02/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LGBeaconFinderViewController.h"
#import "LGOfferViewController.h"
#import "LGBeaconTableViewCell.h"
#import "UIColor+UIColorCategory.h"

@interface LGBeaconFinderViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableDictionary *detectedBeacons;

@end

@implementation LGBeaconFinderViewController

@synthesize activity;
@synthesize searchingLabel;
@synthesize detectedBeacons;
@synthesize tableView;

NSString *const kUUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
NSString *const kDefaultBeaconIdentifier = @"com.instantview.beacons";

int const kBeaconCellHeight = 100;

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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"Discovered Offers";
    
    self.detectedBeacons = [NSMutableDictionary new];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0x333333"];
    self.searchingLabel.textColor = [UIColor colorWithHexString:@"0xEEEEEE"];
    self.activity.color = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
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
        self.beaconRegion.notifyEntryStateOnDisplay = YES;
        self.beaconRegion.notifyOnEntry = YES;
        self.beaconRegion.notifyOnExit = YES;
        
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //[self.locationManager requestStateForRegion:self.beaconRegion];
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
    NSLog(@"Enter region...");
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
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
                [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
            }
        case CLRegionStateUnknown:
        default:
            NSLog(@"Default");
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"Total beacons: %d", [beacons count]);
    
    NSMutableArray *visibleBeacons = [NSMutableArray new];
    
    for(CLBeacon *beacon in beacons)
    {
        NSString *beaconID = [self createBeaconIDFromBeacon:beacon];
        
        [visibleBeacons addObject:beaconID];
        
        if (![self.detectedBeacons objectForKey:beaconID])
        {
            [self addBeaconToDictionary:beaconID];
            [self sendNotificationForMessage:@"You have discovered a new offer!" withBeaconId:beaconID];
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

- (NSString *)createBeaconIDFromBeacon:(CLBeacon *)beacon
{
    return [NSString stringWithFormat:@"%@|%d|%d",
                          [beacon.proximityUUID UUIDString],
                          [beacon.major integerValue],
                          [beacon.minor integerValue]];
}

- (void)addBeaconToDictionary:(NSString *)beaconID
{
    [self.detectedBeacons setObject:@"10% Off Samsung TV's" forKey:beaconID];
    [self.tableView reloadData];
}

- (void)removeBeaconFromDictionary:(NSString *)beaconID
{
    [self.detectedBeacons removeObjectForKey:beaconID];
    [self.tableView reloadData];
}

- (void)sendNotificationForMessage:(NSString *)notificationText withBeaconId:(NSString *)beaconId
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = notificationText;
    notification.userInfo = [NSDictionary dictionaryWithObject:beaconId forKey:@"beaconId"];
    notification.fireDate = [NSDate date];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

# pragma mark - UITableView Delegates and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int total = [self.detectedBeacons count];
    
    self.tableView.hidden = (total == 0) ? YES : NO;
    
    return total;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBeaconCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    
    LGBeaconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[LGBeaconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *keys = [self.detectedBeacons allKeys];
    NSString *key = [keys objectAtIndex:indexPath.row];
    NSString *beaconName = [self.detectedBeacons objectForKey:key];
    
    cell.beaconName.text = beaconName;
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
    NSArray *keys = [self.detectedBeacons allKeys];
    NSString *key = [keys objectAtIndex:indexPath.row];
    
    NSLog(@"Key: %@", key);
    LGOfferViewController *offer = [[LGOfferViewController alloc] initWithBeaconId:key];
    
    [self.navigationController pushViewController:offer animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
