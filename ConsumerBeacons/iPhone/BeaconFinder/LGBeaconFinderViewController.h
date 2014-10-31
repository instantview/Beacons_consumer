//
//  LGBeaconFinderViewController.h
//  ConsumerBeacons
//
//  Created by Matt Richardson on 02/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGBeaconFinderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *searchingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
