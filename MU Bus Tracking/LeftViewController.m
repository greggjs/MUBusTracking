//
//  LeftViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/27/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController () <JTRevealSidebarV2Delegate, UITableViewDataSource, UITableViewDelegate>
@end

@implementation LeftViewController {
    GMSMapView *mapView_;
}

- (void)loadView
{
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.508034 longitude:-84.741032 zoom:13];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Add left sidebar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];
    // Add right sidebar
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(revealRightSidebar:)];
    
    self.navigationItem.revealSidebarDelegate = self;
    
    // for when Mikey can use Xcode 5... iOS 7 bar
    // Color for Miami Red (in HEX: #CC0C2F
    ColorService *cs = [[ColorService alloc] init];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIColor blackColor],UITextAttributeTextShadowColor,nil];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [cs getColorFromHexString:@"CC0C2F"];
        
    } else {
        self.navigationController.navigationBar.tintColor = [cs getColorFromHexString:@"CC0C2F"];
    }
    /*
    for(Bus *bus in _buses){
        [self addBusToMapWithBus:bus];
    }
    */
    for (Route *r in _routes) {
        NSArray *curr = r.shape;
        GMSPolyline *routeLine = [self createRoute:curr];
        routeLine.map = mapView_;
        routeLine.strokeColor = r.color;
        routeLine.strokeWidth = 10.f;
        routeLine.geodesic = YES;
    }
    
    //[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkBuses) userInfo:nil repeats:YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.label = nil;
}


#pragma mark - private methods

-(void)addBusToMapWithBus:(Bus*)bus{
    // Add the Marker to the map
    CGFloat lat = (CGFloat)[bus.latitude floatValue];
    CGFloat lng = (CGFloat)[bus.longitude floatValue];
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(lat, lng);
    marker.title = bus.busID;
    marker.icon = [UIImage imageNamed:@"bus.png"];
    marker.map = mapView_;
}

-(GMSPolyline*)createRoute:(NSArray*) points{
    GMSMutablePath *path = [GMSMutablePath path];
    CLLocationCoordinate2D coordinate;
    
    for(int i =0; i < [points count]; i++){
        [[points objectAtIndex:i] getValue:&coordinate];
        [path addCoordinate:coordinate];
    }
    
    GMSPolyline *route = [GMSPolyline polylineWithPath:path];
    
    return route;
}

-(void)checkBuses {
    BusService *bs = [[BusService alloc]init];
    _buses = [bs getAllBuses];
    
    for(Bus *bus in _buses){
        [self addBusToMapWithBus:bus];
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


@implementation LeftViewController (Private)

#pragma mark SidebarViewControllerDelegate

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController setRevealedState:JTRevealedStateNo];
    
    LeftViewController *controller = [[LeftViewController alloc] init];
    controller.routes = _routes;
    //controller.buses = _buses;
    controller.view.backgroundColor = [UIColor clearColor];
    controller.title = (NSString *)object;
    controller.leftSidebarViewController  = sidebarViewController;
    controller.leftSelectedIndexPath      = indexPath;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.508034 longitude:-84.741032 zoom:13];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    controller.view = mapView_;
    
    sidebarViewController.sidebarDelegate = controller;
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
    if (indexPath.row==0)
        [self showAllBuses];
    else
        [self showBus:_routes[indexPath.row-1]];
}

-(void)showAllBuses {
    /*
    for(Bus *bus in _buses){
        [self addBusToMapWithBus:bus];
    }
    */
    for (Route *r in _routes) {
        NSArray *curr = r.shape;
        GMSPolyline *routeLine = [self createRoute:curr];
        routeLine.map = mapView_;
        routeLine.strokeColor = r.color;
        routeLine.strokeWidth = 10.f;
        routeLine.geodesic = YES;
    }
    
}

-(void)showBus:(Route *)route{
    /*BusService *bs = [[BusService alloc] init];
    NSArray *curr = [bs getBusOnRoute:route.name];
    if (curr) {
        for (Bus *bus in curr) {
            [self addBusToMapWithBus:bus];
        }
    }
    */
    //StopService *ss = [[StopService alloc] init];
    //NSArray *stops = [ss getStopCooridinates:colorStr];
    //[self plotStops:stops:colorStr];
    
    //RouteService *rs = [[RouteService alloc] init];
    NSArray *coords = route.shape;
    GMSPolyline *routeLine = [self createRoute:coords];
    routeLine.map = mapView_;
    routeLine.strokeColor = route.color;
    routeLine.strokeWidth = 10.f;
    routeLine.geodesic = YES;
}

- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}

@end
