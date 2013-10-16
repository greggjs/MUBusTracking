//
//  ViewController.m
//  MU Bus
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (Private) <UITableViewDataSource, UITableViewDelegate, SidebarViewControllerDelegate>
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

    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.508034 longitude:-84.736832 zoom:13.7];
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
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIColor blackColor],UITextAttributeTextShadowColor,nil];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
         
    } else {
        self.navigationController.navigationBar.tintColor = [UIColor redColor];
    }
    
    // Make the bus web service call to get the location of a bus
    BusService *bs = [[BusService alloc] init];
    // Make the route web service call to get the route coordinates
    RouteService *rs = [[RouteService alloc] init];
    NSMutableArray *buses = [bs getBuses];
    NSMutableArray *routes = [rs getAllRoutes];
    NSLog(@"Adding buses to map...");

    for(Bus *bus in buses){
        [self addBusToMapWithBus:bus];
    }
    
    for (Route *r in routes) {
        GMSPolyline *routeLine = [self createRoute:r.shape];
        routeLine.map = mapView_;
        routeLine.strokeColor = r.color;
        routeLine.strokeWidth = 10.f;
        routeLine.geodesic = YES;
    }
    // TEST CODE //
    /*
    NSArray *BUS_COLORS = [NSArray arrayWithObjects:@"ORANGE", @"BLUE", @"YELLOW", @"GREEN", @"PURPLE", @"RED", nil];
    for (NSString *bus in BUS_COLORS) {
        NSArray *coords = [rs getRouteCoordinatesByColorString:bus];
        GMSPolyline *routeLine = [self createRoute:coords];
        routeLine.map = mapView_;
        routeLine.strokeColor = [self getRouteColor:bus];
        routeLine.strokeWidth = 10.f;
        routeLine.geodesic = YES;
    }
     */
    // END TEST CODE //

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.label = nil;
    self.rightSidebarView = nil;
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

-(void)plotStops:(NSArray*)stops:(NSString*)colorStr{
    Stop *stop;
    for (int i=0; i< [stops count]; i++) {
        GMSMarker *marker = [[GMSMarker alloc]init];
        stop = [stops objectAtIndex:i];
        marker.position = stop.location;
        marker.title = stop.name;
        marker.icon = [UIImage imageNamed:@"busstop.png"];
        marker.map = mapView_;
    }
}

-(UIColor*)getRouteColor:(NSString *)busColor {
    if ([busColor isEqualToString:@"ORANGE"]) {
        return [UIColor orangeColor];
    } else if ([busColor isEqualToString:@"BLUE"]) {
        return [UIColor blueColor];
    } else if ([busColor isEqualToString:@"GREEN"]) {
        return [UIColor greenColor];
    } else if ([busColor isEqualToString:@"YELLOW"]) {
        return [UIColor yellowColor];
    } else if ([busColor isEqualToString:@"RED"]) {
        return [UIColor redColor];
    } else if ([busColor isEqualToString:@"PURPLE"]) {
        return [UIColor purpleColor];
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
    }
    
    controller.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OpeH1.png"]]];
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
    return 5;
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
    
    ViewController *controller = [[ViewController alloc] init];
    controller.view.backgroundColor = [UIColor clearColor];
    controller.title = (NSString *)object;
    controller.leftSidebarViewController  = sidebarViewController;
    controller.leftSelectedIndexPath      = indexPath;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.508034 longitude:-84.736832 zoom:13.7];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    controller.view = mapView_;
    //controller.label.text = [NSString stringWithFormat:@"Selected %@ from LeftSidebarViewController", (NSString *)object];
    
    sidebarViewController.sidebarDelegate = controller;
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
    switch (indexPath.row) {
        case 0:
            [self showAllBuses];
            break;
        case 1:
            [self showBus:[UIColor orangeColor]:@"ORANGE"];
            break;
        case 2:
            [self showBus:[UIColor redColor]:@"RED"];
            break;
        case 3:
            [self showBus:[UIColor purpleColor]:@"PURPLE"];
            break;
        case 4:
            [self showBus:[UIColor greenColor]:@"GREEN"];
            break;
        case 5:
            [self showBus:[UIColor yellowColor]:@"YELLOW"];
            break;
        case 6:
            [self showBus:[UIColor blueColor]:@"BLUE"];
            break;
        default:
            [self showBus:[UIColor orangeColor]:@"ORANGE"];
            break;
    }
}

-(void)showAllBuses {
    // Make the bus web service call to get the location of a bus
    BusService *bs = [[BusService alloc] init];
    // Make the route web service call to get the route coordinates
    RouteService *rs = [[RouteService alloc] init];
    NSArray *buses = [bs getBuses];
    for(Bus *bus in buses){
        [self addBusToMapWithBus:bus];
    }
    
    // TEST CODE //
    NSArray *BUS_COLORS = [NSArray arrayWithObjects:@"ORANGE", @"BLUE", @"YELLOW", @"GREEN", @"PURPLE", @"RED", nil];
    for (NSString *bus in BUS_COLORS) {
        NSArray *coords = [rs getRouteCoordinatesByColorString:bus];
        GMSPolyline *routeLine = [self createRoute:coords];
        routeLine.map = mapView_;
        routeLine.strokeColor = [self getRouteColor:bus];
        routeLine.strokeWidth = 10.f;
        routeLine.geodesic = YES;
    }
    
}

-(void)showBus:(UIColor *)color:(NSString *)colorStr{
    BusService *bs = [[BusService alloc] init];
    NSArray *curr = [bs getBuses];
    if (curr) {
                for (Bus *bus in curr) {
            [self addBusToMapWithBus:bus];
        }
    }
    
    StopService *ss = [[StopService alloc] init];
    NSArray *stops = [ss getStopCooridinates:colorStr];
    [self plotStops:stops:colorStr];
    
    RouteService *rs = [[RouteService alloc] init];
    NSArray *coords = [rs getRouteCoordinatesByColorString:colorStr];
    GMSPolyline *routeLine = [self createRoute:coords];
    routeLine.map = mapView_;
    routeLine.strokeColor = color;
    routeLine.strokeWidth = 10.f;
    routeLine.geodesic = YES;
}

- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}

@end
