//
//  LGOfferViewController.h
//  ConsumerBeacons
//
//  Created by Matt Richardson on 02/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGOfferViewController : UIViewController

@property (strong, nonatomic) NSDictionary *offerInfo;

- (id)initWithBeacon:(NSDictionary *)beacon;

@end
