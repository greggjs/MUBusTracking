//
//  MapView.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 2/24/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
#import "SidebarViewController.h"

@interface MapView : UIView

@property (nonatomic, strong) NSArray* routes;
@property (nonatomic, strong) NSArray* buses;
@property (nonatomic, strong) NSArray* stops;
@property (nonatomic, strong) NSString* routeName;
@property (nonatomic) CLLocationCoordinate2D center;
@property (nonatomic) float zoom;
@property (nonatomic, strong) GMSMapView *mapView_;
@property (nonatomic) BOOL favorites;

- (id)initWithRoutes:(NSArray*)route withCenter:(CLLocationCoordinate2D)center withZoom:(float)zoom;
-(id)initWithRoutes:(NSArray*)route withBuses:(NSArray*)buses withName:(NSObject*)object withSidebar:(SidebarViewController*)sidebarViewController withIndexPath:(NSIndexPath*)path;

@end
