//
//  LGAppDelegate.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 02/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import "UIColor+UIColorCategory.h"
#import "LGAppDelegate.h"
#import "LGBeaconFinderViewController.h"
#import "LGOfferViewController.h"
#import "LGLoginViewController.h"

@implementation LGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	
	if ([self isLoggedIn])
	{
        UIViewController *mainViewController = [UIViewController new];
        
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        
        if (notification)
        {
            NSLog(@"Picked up a local notification");
            NSString *beaconId = [notification.userInfo objectForKey:@"beaconId"];
            mainViewController = [[LGOfferViewController alloc] initWithBeaconId:beaconId];
        }
        else
        {
            NSLog(@"Couldn't find a local notification");
            mainViewController = [[LGBeaconFinderViewController alloc] initWithNibName:@"BeaconFinder" bundle:nil];
        }
		
		UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:mainViewController];
        navigation.navigationBar.barTintColor = [UIColor colorWithHexString:@"0xFFEE00"];
        navigation.navigationBar.translucent = YES;
        //navigation.navigationBar.tintColor = [UIColor blackColor];
        // navigation.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        
		self.window.rootViewController = navigation;
	}
	else
	{
		LGLoginViewController *login = [[LGLoginViewController alloc] initWithNibName:@"Login" bundle:nil];
		self.window.rootViewController = login;
	}
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)isLoggedIn
{
    return YES;
    
	NSUserDefaults *standardDefaults = [[NSUserDefaults alloc] init];
	
	if (standardDefaults)
	{
		if ([standardDefaults objectForKey:@"guid"])
		{
			return YES;
		}
	}
	
	return NO;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Received notification: %@", notification);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
