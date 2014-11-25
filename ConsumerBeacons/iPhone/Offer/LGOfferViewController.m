//
//  LGOfferViewController.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 02/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "LGOfferViewController.h"
#import "UIColor+UIColorCategory.h"

@interface LGOfferViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSString *beaconID;

@end

@implementation LGOfferViewController

@synthesize scrollView;
@synthesize beaconID;
@synthesize offerInfo;

- (id)initWithBeacon:(NSDictionary *)beacon
{
    self = [super init];
    
	if (self){
		
		self.offerInfo = beacon;
		self.beaconID = [beacon objectForKey:@"UUID"];
		
        [self setup];
    }
	
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)setup
{
    self.scrollView = [UIScrollView new];
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 500);
    
    [self.view addSubview:self.scrollView];
    
    self.navigationItem.title = @"Offer";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"0x333333"];
	
	UIImageView *offerImage = [[UIImageView alloc] init];
    offerImage.frame = CGRectMake(0, 0, self.view.frame.size.width, 150);
    offerImage.contentMode = UIViewContentModeScaleAspectFill;
	
	NSString *url = [self.offerInfo objectForKey:@"imageURL"];
	
	if (![url isKindOfClass:[NSNull class]])
	{
		[offerImage setImageWithURL:[NSURL URLWithString:url]
						  placeholderImage:nil];
	}
	
	offerImage.backgroundColor = [UIColor blackColor];
	
    [self.scrollView addSubview:offerImage];
	
	// format the price correctly
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	NSString *priceString = [numberFormatter stringFromNumber:[self.offerInfo objectForKey:@"price"]];
	
	UILabel *offerPrice = [UILabel new];
	offerPrice.frame = CGRectMake(self.view.frame.size.width - 100, 120, 100, 30);
	offerPrice.backgroundColor = [UIColor blackColor];
	offerPrice.textAlignment = NSTextAlignmentCenter;
	offerPrice.textColor = [UIColor whiteColor];
	offerPrice.text = priceString;
	offerPrice.font = [UIFont boldSystemFontOfSize:18.0];
	
	[offerImage addSubview:offerPrice];
	
    UIView *contentView = [UIView new];
    contentView.frame = CGRectMake(0, 150, self.scrollView.frame.size.width, self.scrollView.frame.size.height - 150);
    contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *offerTitle = [UILabel new];
    offerTitle.frame = CGRectMake(20, 10, self.scrollView.frame.size.width - 40, 50);
    offerTitle.text = [self.offerInfo objectForKey:@"title"];
    offerTitle.font = [UIFont boldSystemFontOfSize:20.0];
    
    [contentView addSubview:offerTitle];
	
	UILabel *offerStrapline = [UILabel new];
	offerStrapline.frame = CGRectMake(20, 50, self.scrollView.frame.size.width - 40, 30);
	offerStrapline.text = [self.offerInfo objectForKey:@"strapLine"];
	offerStrapline.font = [UIFont boldSystemFontOfSize:14.0];
	
	[contentView addSubview:offerStrapline];
    
    UITextView *offerDescription = [UITextView new];
    offerDescription.frame = CGRectMake(15, 85, self.scrollView.frame.size.width - 40, 200);
    offerDescription.text = [self.offerInfo objectForKey:@"description"];
    offerDescription.textColor = [UIColor colorWithHexString:@"0x555555"];
    offerDescription.editable = NO;
    offerDescription.selectable = YES;
	
    [contentView addSubview:offerDescription];
    
    [self.scrollView addSubview:contentView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
