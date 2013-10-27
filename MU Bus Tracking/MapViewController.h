//
//  MapViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/27/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "UIViewController+JTRevealSidebarV2.h"
#import "JTRevealSidebarV2Delegate.h"
#import "BusService.h"
#import "RouteService.h"
#import "Bus.h"
#import "Stop.h"
#import "StopService.h"
#import "SidebarViewController.h"
#import "ColorService.h"
#import "SettingsViewController.h"

@interface MapViewController : UIViewController<JTRevealSidebarV2Delegate, UITableViewDelegate, GMSMapViewDelegate>{
}

@property (nonatomic, strong) UILabel       *label;
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

-(id)initWithRoutes:(NSArray*)route withCenter:(CLLocationCoordinate2D)center withZoom:(float)zoom;
-(GMSPolyline*)createRouteWithPoints:(NSArray*) points;
@end