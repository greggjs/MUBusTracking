//
//  BusView.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/6/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bus.h"

@interface BusView : UIView

@property (nonatomic, strong) Bus* bus;

-(id) initWithFrame:(CGRect)frame andBus:(Bus*)bus;

@end
