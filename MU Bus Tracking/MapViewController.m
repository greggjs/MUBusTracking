//
//  MapViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/27/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController (private) <UITableViewDataSource, UITableViewDelegate, SidebarViewControllerDelegate, GMSMapViewDelegate>
@end

@implementation MapViewController
    
- (id)init {
    self = [super init];
    return self;
}

- (id)initWithRoutes:(NSArray*)route withCenter:(CLLocationCoordinate2D)center withZoom:(float)zoom {
    self = [super init];
    _routes = route;
    _center = center;
    _zoom = zoom;
    return self;
}

- (void)loadView
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
    _mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView_.myLocationEnabled = YES;
    _mapView_.settings.rotateGestures = NO;
    _mapView_.delegate = self;
    self.view = _mapView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    
    // Add left sidebar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];
    self.navigationItem.revealSidebarDelegate = self;

    if (![_routeName isEqualToString:@"ALL"]) {
        _busRefresh = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkBuses) userInfo:nil repeats:YES];
    }
    NSLog(@"Size of routes: %i", [_routes count]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.label = nil;
}

#pragma mark - private methods

-(void)addBusToMapWithBus:(Bus*)bus onMap:(GMSMapView*)map{
    // Add the Marker to the map
    CGFloat lat = (CGFloat)[bus.latitude floatValue];
    CGFloat lng = (CGFloat)[bus.longitude floatValue];
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(lat, lng);
    marker.title = bus.busID;
    marker.icon = [UIImage imageNamed:@"bus.png"];
    bus.marker = marker;
    marker.map = map;
}

-(GMSPolyline*)createRouteWithPoints:(NSArray*) points{
    GMSMutablePath *path = [GMSMutablePath path];
    CLLocationCoordinate2D coordinate;
    
    for(int i =0; i < [points count]; i++){
        [[points objectAtIndex:i] getValue:&coordinate];
        [path addCoordinate:coordinate];
    }
    
    GMSPolyline *route = [GMSPolyline polylineWithPath:path];
    
    return route;
}

-(void)plotStopsWithStops:(NSArray*)stops withRoute:(NSString*)route onMap:(GMSMapView*)map{
    Stop *stop;
    for (int i=0; i< [stops count]; i++) {
        GMSMarker *marker = [[GMSMarker alloc]init];
        stop = [stops objectAtIndex:i];
        marker.position = stop.location;
        marker.title = stop.name;
        marker.icon = [UIImage imageNamed:@"busstop.png"];
        marker.map = map;
    }
}

-(void)checkBuses {
    if (![_buses isKindOfClass:[NSNull class] ]) {
        for (Bus *bus in _buses) {
            bus.marker.map = nil;
        }
    
        BusService *bs = [[BusService alloc]init];
        _buses = [bs getBusWithRoute:_routeName];
    
        for(Bus *bus in _buses){
            [self addBusToMapWithBus:bus onMap:_mapView_];
        }
    }
    
}

#pragma mark Action

- (void)revealLeftSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateLeft];
}

- (void)revealRightSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateRight];
}

#pragma mark JTRevealSidebarDelegate

// This is an examle to configure your sidebar view through a custom UIViewController
- (UIView *)viewForLeftSidebar {
    // Use applicationViewFrame to get the correctly calculated view's frame
    // for use as a reference to our sidebar's view
    CGRect viewFrame = self.navigationController.applicationViewFrame;
    UITableViewController *controller = self.leftSidebarViewController;
    if ( ! controller) {
        self.leftSidebarViewController = [[SidebarViewController alloc] init];
        self.leftSidebarViewController.sidebarDelegate = self;
        controller = self.leftSidebarViewController;
        controller.title = @"Routes";
        self.leftSidebarViewController.routes = _routes;
        
    }
    ColorService *cs = [[ColorService alloc] init];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.navigationController.navigationBar.barTintColor = [cs getColorFromHexString:APP_COLOR];
    //controller.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OpeH1.png"]]];
    controller.view.frame = CGRectMake(0, viewFrame.origin.y, 270, viewFrame.size.height);
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    return controller.view;
}

// Optional delegate methods for additional configuration after reveal state changed
- (void)didChangeRevealedStateForViewController:(UIViewController *)viewController {
    // Example to disable userInteraction on content view while sidebar is revealing
    if (viewController.revealedState == JTRevealedStateNo) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}

@end


@implementation MapViewController (Private)

#pragma mark SidebarViewControllerDelegate

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController setRevealedState:JTRevealedStateNo];
    if (indexPath.row < [_routes count] +2) {
        MapViewController *controller = [[MapViewController alloc] init];
        controller.routes = _routes;
        controller.buses = _buses;
        controller.routeName = (indexPath.row == 0 ? @"ALL" :(indexPath.row==1 ? @"ALL" : (indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)(_routes[indexPath.row-2])).name : @"Settings")));
        controller.center = (indexPath.row == 0 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON):(indexPath.row==1 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON) :(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).center:CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON))));
        controller.zoom = (indexPath.row == 0 ? MAIN_ZOOM :(indexPath.row==1 ? MAIN_ZOOM:(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).zoom:MAIN_ZOOM)));
        [_busRefresh invalidate];
        _busRefresh = nil;
        
        controller.view.backgroundColor = [UIColor clearColor];
        controller.title = (NSString *)object;
        controller.leftSidebarViewController  = sidebarViewController;
        controller.leftSelectedIndexPath      = indexPath;

        sidebarViewController.sidebarDelegate = controller;
        [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
        if (indexPath.row==0)
            [self showAllRoutesOnMap:controller.mapView_]; // [self showFavorites];
        else if (indexPath.row==1)
            [self showAllRoutesOnMap:controller.mapView_];
        else if (indexPath.row > 1 && indexPath.row < [_routes count]+2)
            [self showBusWithRoute:_routes[indexPath.row-2] onMap:controller.mapView_];
    }
    else
        [self displaySettings:sidebarViewController withName:object withIndexPath:indexPath];
        //[self showAllRoutesOnMap:controller.mapView_];
}

-(void)showAllRoutesOnMap:(GMSMapView*)map {
    float alpha = 1.f;
    for (Route *r in _routes) {
        NSArray *curr = r.shape;
        GMSPolyline *routeLine = [self createRouteWithPoints:curr];
        routeLine.map = map;
        const CGFloat *cArr = CGColorGetComponents(r.color.CGColor);
        UIColor *c = [UIColor colorWithRed:cArr[0] green:cArr[1] blue:cArr[2] alpha:alpha];
        alpha-= .10f;
        routeLine.strokeColor = c;
        routeLine.strokeWidth = 10.f;
        routeLine.geodesic = YES;
    }
    
}

-(void)showBusWithRoute:(Route *)route onMap:(GMSMapView*)map{
    BusService *bs = [[BusService alloc] init];
    NSArray *curr = [bs getBusWithRoute:route.name];
    if (curr) {
        for (Bus *bus in curr) {
            [self addBusToMapWithBus:bus onMap:map];
        }
    }
    
    StopService *ss = [[StopService alloc] init];
    NSArray *stops = [ss getStopsWithRoute:route.name];
    [self plotStopsWithStops:stops withRoute:route.name onMap:map];
    
    //RouteService *rs = [[RouteService alloc] init];
    NSArray *coords = route.shape;
    GMSPolyline *routeLine = [self createRouteWithPoints:coords];
    routeLine.map = map;
    routeLine.strokeColor = route.color;
    routeLine.strokeWidth = 10.f;
    routeLine.geodesic = YES;
}

-(void) displaySettings:(SidebarViewController*)sidebarViewController withName:(NSObject *)object withIndexPath:(NSIndexPath*)indexPath {
    SettingsViewController *controller = [[SettingsViewController alloc]initWithRoutes:_routes];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.title = (NSString *)object;
    controller.leftSidebarViewController  = sidebarViewController;
    controller.leftSelectedIndexPath      = indexPath;
    controller.routes = _routes;
    controller.buses = _buses;
    controller.routeName = (indexPath.row == 0 ? @"ALL" :(indexPath.row==1 ? @"ALL" : (indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)(_routes[indexPath.row-2])).name : @"Settings")));
    controller.center = (indexPath.row == 0 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON):(indexPath.row==1 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON) :(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).center:CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON))));
    controller.zoom = (indexPath.row == 0 ? MAIN_ZOOM :(indexPath.row==1 ? MAIN_ZOOM:(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).zoom:MAIN_ZOOM)));
    [_busRefresh invalidate];
    _busRefresh = nil;
    sidebarViewController.sidebarDelegate = controller;

    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
}

- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}

# pragma mark GMSMapViewDelegate

-(void)mapView:(GMSMapView*)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didBeginDraggingMarker");
}

-(void)mapView:(GMSMapView*)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    float dLat= 0.025f, dLon = 0.025f;
    if (position.zoom < 12.9 || position.target.latitude > MAIN_LAT + dLat
        || position.target.latitude < MAIN_LAT - dLat || position.target.longitude < MAIN_LON - dLon ||
        position.target.longitude > MAIN_LON + dLon) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
        [_mapView_ animateToCameraPosition:camera];
    }
    
}
-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
    [_mapView_ animateToCameraPosition:camera];
}

@end