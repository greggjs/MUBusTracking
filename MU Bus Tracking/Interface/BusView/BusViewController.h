//
//  BusViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/6/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusView.h"
#import "Bus.h"
#import <Foundation/Foundation.h>

@interface BusViewController : UIViewController

@property (nonatomic, strong) Bus* bus;

- (id) initWithBus:(Bus*)bus;

@end
