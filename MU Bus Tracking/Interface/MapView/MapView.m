//
//  MapView.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 2/24/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import "MapView.h"

@implementation MapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithRoutes:(NSArray *)route withCenter:(CLLocationCoordinate2D)center withZoom:(float)zoom {
    self = [super init];
    _routes = route;
    _center = center;
    _zoom = zoom;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
    _mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"location"]) {
        _mapView_.myLocationEnabled = YES;
    } else {
        _mapView_.myLocationEnabled = NO;
    }
    _mapView_.settings.rotateGestures = NO;
    _mapView_.delegate = self;
    _mapView_.accessibilityElementsHidden = NO;
    self = _mapView_;

    return self;
}

- (id) initWithRoutes:(NSArray *)route withBuses:(NSArray *)buses withName:(NSObject *)object withSidebar:(SidebarViewController *)sidebarViewController withIndexPath:(NSIndexPath *)path {
    self = [super init];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
