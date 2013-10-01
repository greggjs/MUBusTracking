//
//  ViewController.h
//  MU Bus
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIViewController+JTRevealSidebarV2.h"
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "SidebarViewController.h"
#import "NewViewController.h"
#import "JTRevealSidebarV2Delegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "BusService.h"
#import "RouteService.h"
#import "Bus.h"
#import "Stop.h"
#import "StopService.h"
#import "LeftViewController.h"
#import "JTRevealSidebarV2Delegate.h"

@class SidebarViewController;

@interface ViewController : UIViewController <JTRevealSidebarV2Delegate, UITableViewDelegate> {
#if EXPERIMENTAL_ORIENTATION_SUPPORT
    CGPoint _containerOrigin;
#endif
}

@property (nonatomic, strong) SidebarViewController *leftSidebarViewController;
@property (nonatomic, strong) UITableView *rightSidebarView;
@property (nonatomic, strong) NSIndexPath *leftSelectedIndexPath;
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) NSMutableData *respData;
@property (nonatomic, strong) NSString *currentRoute;
@end
