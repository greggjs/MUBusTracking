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

@synthesize view;
@synthesize title;
@synthesize leftSidebarViewController;
@synthesize leftSelectedIndexPath;

- (id)init {
    self = [super init];
    self.view.backgroundColor = [UIColor clearColor];
    return self;
    NSLog(@"Called Default Constructor");
}

- (id)initWithRoutes:(NSArray*)route withCenter:(CLLocationCoordinate2D)center withZoom:(float)zoom {
    NSLog(@"Called Small Constructor");
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
    view.backgroundColor = [UIColor clearColor];

    _mapView_.settings.rotateGestures = NO;
    _mapView_.delegate = self;
    _mapView_.accessibilityElementsHidden = NO;

    NSLog(@"Created MapView and set the view to it");
    return self;
}

-(id)initWithRoutes:(NSArray*)route withBuses:(NSArray*)buses withName:(NSObject*)object withSidebar:(SidebarViewController*)sidebarViewController withIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"Called Large Constructor");
    self = [super init];
    _routes = route;
    _center = (indexPath.row == 0 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON):(indexPath.row > 0 && indexPath.row < [_routes count]+1 ? ((Route*)_routes[indexPath.row-1]).center:CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON)));
    _zoom = (indexPath.row == 0 ? MAIN_ZOOM :(indexPath.row > 0 && indexPath.row < [_routes count]+1 ? ((Route*)_routes[indexPath.row-1]).zoom:MAIN_ZOOM));
    _routeName = (indexPath.row == 0 ? @"ALL" :(indexPath.row > 0 && indexPath.row < [_routes count]+1 ? ((Route*)(_routes[indexPath.row-1])).name : @"Settings"));
    _favorites = (indexPath.row == 0 ? TRUE : FALSE);
    
    view.backgroundColor = [UIColor clearColor];
    title = (NSString *)object;
    leftSidebarViewController  = sidebarViewController;
    leftSelectedIndexPath      = indexPath;

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

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad Called from %@", self);
    self.view.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];
    NSLog(@"Button: %@", button);
    // Add left sidebar
    self.navigationItem.leftBarButtonItem = button;
    self.navigationItem.revealSidebarDelegate = self;
    self.view = _mapView_;
    NSLog(@"Size of routes: %i", [_routes count]);
}

-(void) viewDidAppear:(BOOL)animated {
    NSLog(@"Loading Bus Refresh...");
    [self checkBuses];
    _busRefresh = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkBuses) userInfo:nil repeats:YES];
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"Unloading Bus Refresh...");
    [_busRefresh invalidate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.label = nil;
}

#pragma mark - private methods

- (UIImage *)createColoredCircle:(UIColor *)routeColor withSize:(double) size
{
    //  Create rect to fit the image
    CGRect rect = CGRectMake(0, 0, size, size);
    //  Make the Borders from the rectangle
    CGRect borderRectBlackOut = CGRectInset(rect, 1, 1);
    CGRect borderRectWhite = CGRectInset(rect, 3, 3);
    CGRect borderRectBlackInner = CGRectInset(borderRectWhite, 2, 2);
    
    //  Create bitmap contect
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    //  Fill all context with route color
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, routeColor.CGColor);
    CGRect circlePoint = (CGRectMake(0, 0, size, size));
    CGContextFillEllipseInRect(context, circlePoint);
    
    //  Stroke white line
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextStrokeEllipseInRect(context, borderRectWhite);
    
    //  Stroke inner black line
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextStrokeEllipseInRect(context, borderRectBlackInner);
    
    //  Stroke outer black line
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextStrokeEllipseInRect(context, borderRectBlackOut);
    
    //  Create new image from the context
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    //  Release context
    UIGraphicsEndImageContext();
    
    return img;
}

-(void)addBusToMapWithBus:(Bus*)bus onMap:(GMSMapView*)map{
    // Add the Marker to the map
    CGFloat lat = (CGFloat)[bus.latitude floatValue];
    CGFloat lng = (CGFloat)[bus.longitude floatValue];
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(lat, lng);
    marker.title = bus.busID;
    marker.icon = [UIImage imageNamed:@"bus.png"];
    marker.map = map;
    bus.marker = marker;
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

-(void)plotStopsWithStops:(NSArray*)stops withRoute:(Route*)route onMap:(GMSMapView*)map{
    Stop *stop;
    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:_stops];
    for (int i=0; i< [stops count]; i++) {
        GMSMarker *marker = [[GMSMarker alloc]init];
        stop = [stops objectAtIndex:i];
        marker.position = stop.location;
        marker.title = stop.name;
        marker.icon = [self createColoredCircle: route.color withSize:22.0];
        marker.map = map;
        [arr addObject:stop];
    }
    _stops = [NSArray arrayWithArray:arr];
}

-(void)checkBuses {
    if (![_buses isKindOfClass:[NSNull class] ]) {
        for (Bus *bus in _buses) {
            bus.marker.map = nil;
        }
    }
    BusService *bs = [[BusService alloc]init];
    if (_favorites) {
        NSMutableArray *favBuses = [[NSMutableArray alloc]init];
        for (Route *r in _routes) {
            BOOL isFav = [[NSUserDefaults standardUserDefaults] boolForKey:r.name];
            if (isFav) {
                NSArray *currBuses = [bs getBusWithRoute:r.name];
                [favBuses addObjectsFromArray:currBuses];
            }
        }
        _buses = [[NSArray alloc] initWithArray:favBuses];
    } else {
        _buses = [bs getBusWithRoute:_routeName];
    }
    for(Bus *bus in _buses){
        [self addBusToMapWithBus:bus onMap:_mapView_];
    }
    
}

-(void)showFavorites:(GMSMapView*)map {
    float alpha = 1.f;
    StopService *ss = [[StopService alloc] init];
    for (Route *r in _routes) {
        BOOL isFav = [[NSUserDefaults standardUserDefaults] boolForKey:r.name];
        if(isFav){
            NSArray *curr = r.shape;
            GMSPolyline *routeLine = [self createRouteWithPoints:curr];
            routeLine.map = map;
            const CGFloat *cArr = CGColorGetComponents(r.color.CGColor);
            UIColor *c = [UIColor colorWithRed:cArr[0] green:cArr[1] blue:cArr[2] alpha:alpha];
            alpha-= .10f;
            routeLine.strokeColor = c;
            routeLine.strokeWidth = 10.f;
            routeLine.geodesic = YES;
            
            NSArray *stops = [ss getStopsWithRoute:r.name];
            [self plotStopsWithStops:stops withRoute:r onMap:map];
        }
    }
}

-(void)showBusWithRoute:(Route *)route onMap:(GMSMapView*)map{
    
    StopService *ss = [[StopService alloc] init];
    NSArray *stops = [ss getStopsWithRoute:route.name];
    [self plotStopsWithStops:stops withRoute:route onMap:map];
    
    //RouteService *rs = [[RouteService alloc] init];
    NSArray *coords = route.shape;
    GMSPolyline *routeLine = [self createRouteWithPoints:coords];
    routeLine.map = map;
    routeLine.strokeColor = route.color;
    routeLine.strokeWidth = 10.f;
    routeLine.geodesic = YES;
}

-(void) displaySettings:(SidebarViewController*)sidebarViewController withName:(NSObject *)object withIndexPath:(NSIndexPath*)indexPath {
    SettingsViewController *controller = [[SettingsViewController alloc]initWithRoutes:_routes withBuses:_buses withName:object withSidebar:sidebarViewController withIndexPath:indexPath];
    
    sidebarViewController.sidebarDelegate = controller;
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] < 7) {
        [controller viewDidLoad];
    }
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
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
    MapViewController *controller = [[MapViewController alloc] initWithRoutes:_routes withBuses:_buses withName:object withSidebar:sidebarViewController withIndexPath:indexPath];
    
    sidebarViewController.sidebarDelegate = controller;
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
    
    if (indexPath.row < [_routes count]+1) {
        
        if (indexPath.row==0)
            [controller showFavorites:controller.mapView_];
        else if (indexPath.row > 0 && indexPath.row < [_routes count]+1)
            [controller showBusWithRoute:_routes[indexPath.row-1] onMap:controller.mapView_];
        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        
        if ([[ver objectAtIndex:0] intValue] < 7) {
            [controller viewDidLoad];
        }
    }
    else {
        [controller displaySettings:sidebarViewController withName:object withIndexPath:indexPath];
        return;
    }
    
    
}


- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}

# pragma mark GMSMapViewDelegate

-(void)mapView:(GMSMapView*)mapView didTapMarker:(GMSMarker *)marker {
    NSLog(@"Tapped marker");
    NSLog(@"Marker: %@", marker);
    BOOL foundBus = NO;
    for (Bus *b in _buses) {
        if (marker.title == b.busID) {
            foundBus = YES;
            BusViewController *bvc = [[BusViewController alloc]initWithBus:b];
            [self.navigationController pushViewController:bvc animated:YES];
        }
    }
    if (foundBus == NO) {
        for (Stop* s in _stops) {
            if (marker.title == s.name) {
                NSLog(@"stop route: %@", s.route);
                StopViewController *stc = [[StopViewController alloc]initWithStop:s];
                stc.navController = self.navigationController;
                [self.navigationController pushViewController:stc animated:YES];
                return;
            }
        }
    }

    
}

-(void)mapView:(GMSMapView*)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didBeginDraggingMarker");
}

-(void)mapView:(GMSMapView*)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    float dLat= 0.025f, dLon = 0.025f;
    if (position.zoom < 12.9 || position.target.latitude > _center.latitude + dLat
        || position.target.latitude < _center.latitude - dLat || position.target.longitude < _center.longitude - dLon ||
        position.target.longitude > _center.longitude + dLon) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
        [_mapView_ animateToCameraPosition:camera];
    }
    
}
-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
    [_mapView_ animateToCameraPosition:camera];
    NSLog(@"Zoomed to %f lat %f lon %f zoom", _center.latitude, _center.longitude, _zoom);
}

@end
