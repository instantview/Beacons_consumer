//
//  LGBeaconTableViewCell.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 16/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import "LGBeaconTableViewCell.h"
#import "UIColor+UIColorCategory.h"

@implementation LGBeaconTableViewCell

@synthesize innerCell;
@synthesize beaconName;
@synthesize offerStrapline;

const int kCellSpacing = 10;
const int kCellHeight = 100;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setup
{
    self.backgroundColor = [UIColor colorWithHexString:@"0x333333"];
    
    self.innerCell = [UIView new];
    self.innerCell.frame = CGRectMake(10, 10, self.frame.size.width - kCellSpacing, kCellHeight - kCellSpacing);
    self.innerCell.center = CGPointMake(self.frame.size.width / 2, kCellHeight / 2);
    self.innerCell.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.innerCell];
    
    // add the offer title
    self.beaconName = [UILabel new];
    self.beaconName.frame = CGRectMake(25, 17, self.frame.size.width - 50, self.frame.size.height);
    self.beaconName.text = @"Mystery Offer";
    self.beaconName.textColor = [UIColor colorWithHexString:@"0x333333"];
    self.beaconName.font = [UIFont boldSystemFontOfSize:18.0];
    
    [self addSubview:self.beaconName];
    
    // add the offer description (one-liner)
    self.offerStrapline = [UILabel new];
    self.offerStrapline.frame = CGRectMake(25, 37, self.frame.size.width - 100, 50);
    self.offerStrapline.textColor = [UIColor colorWithHexString:@"0x777777"];
    self.offerStrapline.text = @"Featuring intelligent Smart features, future-ready ...";
    self.offerStrapline.font = [UIFont systemFontOfSize:12.0f];
    
    [self addSubview:self.offerStrapline];
    
    // Add the pulse icon to this cell
    [self addBeaconPulse];
}

- (void)addBeaconPulse
{
    // Pulse animation - a little eye candy...
    UIView *innerCircle = [UIView new];
    innerCircle.frame = CGRectMake(self.frame.size.width - 40, (kCellHeight / 2) - kCellSpacing, 20, 20);
    innerCircle.backgroundColor = [UIColor colorWithHexString:@"FFEE00"];
    innerCircle.layer.cornerRadius = 10;
    
    [self addSubview:innerCircle];
    
    UIView *view = [UIView new];
    view.frame = CGRectMake(self.frame.size.width - 40, (kCellHeight / 2) - kCellSpacing, 20, 20);
    view.layer.cornerRadius = 10;
    view.backgroundColor = [UIColor clearColor];
    view.layer.borderColor = [UIColor colorWithHexString:@"0xFFEE00"].CGColor;
    view.layer.borderWidth = 1.0;
    
    [self addSubview:view];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 1.0;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2.0];
    
    [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [view.layer addAnimation:scaleAnimation forKey:@"scale"];
    
    CABasicAnimation *fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = [NSNumber numberWithInt:1];
    fadeAnim.toValue = [NSNumber numberWithInt:0];
    fadeAnim.duration = 1.0;
    fadeAnim.repeatCount = HUGE_VAL;
    fadeAnim.autoreverses = NO;
    
    [view.layer addAnimation:fadeAnim forKey:@"opacity"];
}

- (void)prepareForReuse
{
    //[self addBeaconPulse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
