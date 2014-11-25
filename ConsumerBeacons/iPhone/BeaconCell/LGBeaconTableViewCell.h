//
//  LGBeaconTableViewCell.h
//  ConsumerBeacons
//
//  Created by Matt Richardson on 16/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGBeaconTableViewCell : UITableViewCell

@property (strong, nonatomic) UIView *innerCell;
@property (strong, nonatomic) UILabel *beaconName;
@property (strong, nonatomic) UILabel *offerStrapline;

@end
