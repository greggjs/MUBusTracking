//
//  SettingsViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 10/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, SidebarViewControllerDelegate>


@end

@implementation SettingsViewController

-(id)initWithRoutes:(NSArray*)routes{
    self = [super init];
    _routes = routes;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Add left sidebar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];
    self.navigationItem.revealSidebarDelegate = self;
    
    // Location Services Switch
    UIView *locationServices = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 280, 40)];
    locationServices.backgroundColor = [UIColor whiteColor];
    locationServices.layer.cornerRadius = 5.f;
    locationServices.layer.borderColor = [UIColor lightGrayColor].CGColor;
    locationServices.layer.borderWidth = 0.5f;
    [self.view addSubview:locationServices];
    UISwitch *test = [[UISwitch alloc]initWithFrame:CGRectMake(220, 5, 40, 40)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, 40)];
    label.text = @"Location Services";
    label.textColor = [UIColor darkTextColor];
    [locationServices addSubview:label];
    [locationServices addSubview:test];
    
    UIView *favLabelView = [[UIView alloc]initWithFrame:CGRectMake(20, 80, 280, 40)];
    favLabelView.backgroundColor = [UIColor whiteColor];
    favLabelView.layer.cornerRadius = 5.f;
    favLabelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    favLabelView.layer.borderWidth = 0.5f;
    [self.view addSubview:favLabelView];
    UILabel *favLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, 40)];
    favLabel.text = @"Favorites";
    favLabel.textColor = [UIColor darkTextColor];
    CGFloat size = 20.f;
    [favLabel setFont:[UIFont boldSystemFontOfSize:size]];
    [favLabelView addSubview:favLabel];
    
    UIView *favorites = [[UIView alloc]initWithFrame:CGRectMake(20, 140, 280, 40*[_routes count])];
    favorites.backgroundColor = [UIColor whiteColor];
    favorites.layer.cornerRadius = 5.f;
    [self.view addSubview:favorites];
    [self generateLabelsOnView:favorites];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)generateLabelsOnView:(UIView*)view {
    int i = 0;
    NSLog(@"Size of _routes: %i", [_routes count]);
    for (Route* route in _routes) {
        UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, i*40, 280, 40)];
        //subView.layer.cornerRadius = 5.f;
        subView.backgroundColor = [UIColor whiteColor];
        subView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        subView.layer.borderWidth = 0.5f;
        UILabel *favLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, 40)];
        favLabel.text = route.name;
        favLabel.textColor = [UIColor darkTextColor];
        UISwitch *favSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 5, 40, 40)];
        [subView addSubview:favLabel];
        [subView addSubview:favSwitch];
        [view addSubview:subView];
        i++;
        NSLog(@"Made entry for %@", route.name);
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

-(void) displaySettings:(SidebarViewController*)sidebarViewController withName:(NSObject*)object withIndexPath:(NSIndexPath*)indexPath {
    SettingsViewController *controller = [[SettingsViewController alloc]init];
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


- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}


@end
