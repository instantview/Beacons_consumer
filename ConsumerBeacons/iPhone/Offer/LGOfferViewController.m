//
//  LGOfferViewController.m
//  ConsumerBeacons
//
//  Created by Matt Richardson on 02/09/2014.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import "LGOfferViewController.h"
#import "UIColor+UIColorCategory.h"

@interface LGOfferViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSString *beaconID;

@end

@implementation LGOfferViewController

@synthesize scrollView;
@synthesize beaconID;

- (id)initWithBeaconId:(NSString *)beaconId
{
    self = [super init];
    
    if (self){
        [self setup];
    }
    
    self.beaconID = beaconID;
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
    
    // set the product image at the top
    UIImage *image = [UIImage imageNamed:@"samsung.jpg"];
    
    UIImageView *offerImage = [[UIImageView alloc] initWithImage:image];
    offerImage.frame = CGRectMake(0, 0, self.view.frame.size.width, 150);
    offerImage.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.scrollView addSubview:offerImage];
    
    UIView *contentView = [UIView new];
    contentView.frame = CGRectMake(0, 150, self.scrollView.frame.size.width, self.scrollView.frame.size.height - 150);
    contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *offerTitle = [UILabel new];
    offerTitle.frame = CGRectMake(20, 10, self.scrollView.frame.size.width - 40, 50);
    offerTitle.text = @"10% Off Samsung TV's";
    offerTitle.font = [UIFont boldSystemFontOfSize:20.0];
    
    [contentView addSubview:offerTitle];
    
    UITextView *offerDescription = [UITextView new];
    offerDescription.frame = CGRectMake(15, 55, self.scrollView.frame.size.width - 40, 200);
    offerDescription.text = @"Featuring intelligent Smart features, future-ready technology and a curved design that will take your breath away, the HU7200 will revolutionise the way that you watch TV. The natural curve is optimised for the viewing distance in your living room, which means that it provides a wider field of view and more natural viewing angles, drawing you into whatever's happening on screen.  The higher levels of contrast and fewer external light reflections mean that you can enjoy clear images, as the panel, processor and backlight work together to provide fluid images.";
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
