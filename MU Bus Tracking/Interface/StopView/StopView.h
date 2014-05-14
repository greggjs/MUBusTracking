//
//  StopView.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/6/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stop.h"
#import "BusSiteViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface StopView : UIView

@property (nonatomic, strong) Stop* stop;
@property (nonatomic, strong) GMSPanoramaView *panoView_;
@property (nonatomic, strong) UINavigationController* navController;

-(id) initWithFrame:(CGRect)frame andStop:(Stop*)stop;

@end
