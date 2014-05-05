//
//  SettingsViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 10/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "UIViewController+JTRevealSidebarV2.h"
#import "JTRevealSidebarV2Delegate.h"
#import "SidebarViewController.h"
#import "MapViewController.h"
#import "FavSwitch.h"
#import "SettingsView.h"

@interface SettingsViewController : UIViewController<JTRevealSidebarV2Delegate, UITableViewDelegate>

@property (nonatomic, strong) SidebarViewController   *leftSidebarViewController;
@property (nonatomic, strong) NSIndexPath *leftSelectedIndexPath;
@property (nonatomic, strong) NSArray* routes;
@property (nonatomic, strong) NSArray* buses;
@property (nonatomic, strong) NSArray* stops;
@property (nonatomic, strong) NSString* routeName;
@property (nonatomic, strong) NSTimer* busRefresh;
@property (nonatomic) CLLocationCoordinate2D center;
@property (nonatomic) float zoom;
@property (nonatomic, strong) GMSMapView *mapView_;
@property (nonatomic, strong) SettingsView *settings;

-(id)initWithRoutes:(NSArray*)routes;
-(id)initWithRoutes:(NSArray*)routes withBuses:(NSArray*)buses withName:(NSObject*)object withSidebar:(SidebarViewController*)sidebarViewController withIndexPath:(NSIndexPath*)indexPath;

@end
