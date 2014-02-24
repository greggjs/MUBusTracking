//
//  SettingsView.h
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 2/24/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "FavSwitch.h"
#import "SidebarViewController.h"

@interface SettingsView : UIView

@property (nonatomic, strong) NSArray* routes;

- (id)initWithFrame:(CGRect)frame andRoutes:(NSArray*)routes;
@end
