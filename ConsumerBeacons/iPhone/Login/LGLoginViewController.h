//
//  LGLoginViewController.h
//  ConsumerBeacons
//
//  Created by Matt Richardson on 9/3/14.
//  Copyright (c) 2014 Legendary Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGLoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) IBOutlet UITextField *inputEmail;
@property (strong, nonatomic) IBOutlet UITextField *inputPassword;

- (IBAction)login:(id)sender;

@end
