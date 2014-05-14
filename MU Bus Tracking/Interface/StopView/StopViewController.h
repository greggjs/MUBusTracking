//
//  StopViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/6/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopView.h"
#import "Stop.h"

@interface StopViewController : UIViewController

@property (nonatomic, strong) Stop* stop;

-(id) initWithStop:(Stop*)stop;

@end
