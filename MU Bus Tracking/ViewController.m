//
//  ViewController.m
//  MU Bus
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (Private) <UITableViewDataSource, UITableViewDelegate, SidebarViewControllerDelegate, GMSMapViewDelegate>
@end

@implementation ViewController {
    GMSMapView *mapView_;
}

@synthesize leftSidebarViewController;
@synthesize rightSidebarView;
@synthesize leftSelectedIndexPath;
@synthesize label;

- (id)init {
    self = [super init];
    return self;
}

- (void)loadView
{
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:MAIN_LAT longitude:MAIN_LON zoom:MAIN_ZOOM];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    mapView_.settings.rotateGestures = NO;
    self.view = mapView_;
     
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setNeedsStatusBarAppearanceUpdate];
    self.view.backgroundColor = [UIColor clearColor];

    // Make the route web service call to get the route coordinates
    RouteService *rs = [[RouteService alloc] init];
    _routes = [rs getRouteWithName:@"ALL"];
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
        self.navigationController.navigationBar.barTintColor = [cs getColorFromHexString:APP_COLOR];
        self.navigationController.navigationBar.translucent = NO;
         
    } else {
        self.navigationController.navigationBar.tintColor = [cs getColorFromHexString:APP_COLOR];
    }
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    float stroke_width = 10.f;
    float alpha = 1.f;
    for (Route *r in _routes) {
        NSArray *curr = r.shape;
        GMSPolyline *routeLine = [self createRouteWithPoints:curr];
        routeLine.map = mapView_;
        const CGFloat *cArr = CGColorGetComponents(r.color.CGColor);
        UIColor *c = [UIColor colorWithRed:cArr[0] green:cArr[1] blue:cArr[2] alpha:alpha];
        alpha-= .10f;
        routeLine.strokeColor = c;
        routeLine.strokeWidth = stroke_width;
        //-=0.85f;
        routeLine.geodesic = YES;
    }

    _busRefresh = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkBuses) userInfo:nil repeats:YES];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    NSLog(@"Changing view controller style...");
    return UIStatusBarStyleLightContent;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.label = nil;
    self.rightSidebarView = nil;
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

-(void)checkBuses {
    for (Bus *bus in _buses) {
        bus.marker.map = nil;
    }
    BusService *bs = [[BusService alloc]init];
    _buses = [bs getBusWithRoute:@"ALL"];
    
    for(Bus *bus in _buses){
        [self addBusToMapWithBus:bus onMap:mapView_];
    }
    
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

#pragma mark Action

- (void)revealLeftSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateLeft];
}

- (void)revealRightSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateRight];
}

- (void)pushNewViewController:(id)sender {
    NewViewController *controller = [[NewViewController alloc] init];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.title = @"NewViewController";
    controller.label.text = @"Pushed NewViewController";
    [self.navigationController pushViewController:controller animated:YES];
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

// This is an examle to configure your sidebar view without a UIViewController
- (UIView *)viewForRightSidebar {
    // Use applicationViewFrame to get the correctly calculated view's frame
    // for use as a reference to our sidebar's view
    CGRect viewFrame = self.navigationController.applicationViewFrame;
    UITableView *view = self.rightSidebarView;
    if ( ! view) {
        view = self.rightSidebarView = [[UITableView alloc] initWithFrame:CGRectZero];
        view.dataSource = self;
        view.delegate   = self;
    }
    
    view.frame = CGRectMake(self.navigationController.view.frame.size.width - 270, viewFrame.origin.y, 270, viewFrame.size.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    return view;
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


@implementation ViewController (Private)

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_routes count] + 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ( ! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.rightSidebarView) {
        return @"Options";
    }
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController setRevealedState:JTRevealedStateNo];
    if (tableView == self.rightSidebarView) {
        self.label.text = [NSString stringWithFormat:@"Selected %d at RightSidebarView", indexPath.row];
    }
}

#pragma mark SidebarViewControllerDelegate

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController setRevealedState:JTRevealedStateNo];
    
    LeftViewController *controller = [[LeftViewController alloc] init];
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
    NSLog(@"Loaded new controller params");

    sidebarViewController.sidebarDelegate = controller;
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];

    if (indexPath.row==0)
        [self showAllRoutesOnMap:controller.mapView_]; // [self showFavorites];
    else if (indexPath.row==1)
        [self showAllRoutesOnMap:controller.mapView_];
    else if (indexPath.row > 1 && indexPath.row < [_routes count]+2)
        [self showBusWithRoute:_routes[indexPath.row-2] onMap:controller.mapView_];
    else
        [self showAllRoutesOnMap:controller.mapView_];
     // [self displaySettings]; Probably up higher... make a different type of view...;
}

-(void)showAllRoutesOnMap:(GMSMapView*)map {

    float alpha = 1.0f;
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
    
    NSArray *coords = route.shape;
    GMSPolyline *routeLine = [self createRouteWithPoints:coords];
    routeLine.map = map;
    routeLine.strokeColor = route.color;
    routeLine.strokeWidth = 10.f;
    routeLine.geodesic = YES;
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
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:MAIN_LAT longitude:MAIN_LON zoom:MAIN_ZOOM];
        [mapView_ animateToCameraPosition:camera];
    }
    
}
-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:MAIN_LAT longitude:MAIN_LON zoom:MAIN_ZOOM];
    [mapView_ animateToCameraPosition:camera];
}

@end
