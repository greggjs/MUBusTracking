//
//  ViewController.m
//  MU Bus
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+JTRevealSidebarV2.h"
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "SidebarViewController.h"
#import "NewViewController.h"
#import "JTRevealSidebarV2Delegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "BusService.h"
#import "RouteService.h"
#import "Bus.h"

#if EXPERIEMENTAL_ORIENTATION_SUPPORT
#import <QuartzCore/QuartzCore.h>
#endif

@interface ViewController (Private) <UITableViewDataSource, UITableViewDelegate, SidebarViewControllerDelegate>
@end

@implementation ViewController {
    GMSMapView *mapView_;
}

@synthesize leftSidebarViewController;
@synthesize rightSidebarView;
@synthesize leftSelectedIndexPath;
@synthesize label;
@synthesize respData = _respData;
NSURLConnection *apiTest;
NSURLConnection *getStops;
NSURLConnection *getRouteShape;
NSURLConnection *getRoutePositions;
NSURLConnection *getRouteColor;

- (id)init {
    self = [super init];
    return self;
}

- (void)loadView
{

    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.505034 longitude:-84.735832 zoom:13];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;

    //GMSMarker *marker = [[GMSMarker alloc]init];
    //marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    //marker.title = @"Sydney";
    //marker.snippet = @"Australia";
    //marker.map = mapView_;
     
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    // Add left sidebar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];
    // Add right sidebar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(revealRightSidebar:)];
    
    self.navigationItem.revealSidebarDelegate = self;
    //self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    
    // Make the bus web service call to get the location of a bus
    BusService *bs = [[BusService alloc] init];
    NSArray *buses = [bs getBuses];
    for(Bus *bus in buses){
        [self addBusToMapWithBus:bus];
    }
    
    // Make the route web service call to get the route coordinates
    RouteService *rs = [[RouteService alloc] init];
    NSArray *blueRouteCoordinates = [rs getRouteCoordinates];
    GMSPolyline *blueRoute= [self createRoute:blueRouteCoordinates];
    blueRoute.map = mapView_;
    blueRoute.strokeColor = [UIColor orangeColor];
    blueRoute.strokeWidth = 10.f;
    blueRoute.geodesic = YES;

    
    /*
    // Get bus location
    NSLog(@"viewDidLoad");
    self.respData = [NSMutableData data];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://bus.csi.miamioh.edu/mobileOld/jsonHandler.php?func=apiTest"]];
    apiTest = [[NSURLConnection alloc] initWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.respData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.respData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.respData length]);
    
    NSError *err = nil;
    NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:self.respData options:NSJSONReadingMutableLeaves error:&err];
    
    if (connection == apiTest) {
        for (id key in resp) {
            NSString *busId = (NSString *)[key objectForKey:@"busId"];
            NSString *latStr = (NSString *)[key objectForKey:@"lat"];
            CGFloat lat = (CGFloat)[latStr floatValue];
            NSString *lngStr = (NSString *)[key objectForKey:@"lng"];
            CGFloat lng = (CGFloat)[lngStr floatValue];
            NSLog(@"busId: %@ lat: %@ lng: %@", busId, latStr, lngStr);
        
            GMSMarker *marker = [[GMSMarker alloc]init];
            marker.position = CLLocationCoordinate2DMake(lat, lng);
            marker.title = busId;
            //marker.snippet = @"Late/Ontime?";
            marker.map = mapView_;
        
        }
    }
    */
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

#if EXPERIEMENTAL_ORIENTATION_SUPPORT

// Doesn't support rotating to other orientation at this moment
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _containerOrigin = self.navigationController.view.frame.origin;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.navigationController.view.layer.bounds       = (CGRect){-_containerOrigin.x, _containerOrigin.y, self.navigationController.view.frame.size};
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.navigationController.view.layer.bounds       = (CGRect){CGPointZero, self.navigationController.view.frame.size};
    self.navigationController.view.frame              = (CGRect){_containerOrigin, self.navigationController.view.frame.size};
    
    NSLog(@"%@", self);
}

- (NSString *)description {
    NSString *logMessage = [NSString stringWithFormat:@"ViewController {"];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t%@", self.view];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t%@", self.navigationController.view];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t%@", self.leftSidebarViewController.view];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t%@", self.rightSidebarView];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t%@", self.navigationController.navigationBar];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t <statusBarFrame> %@", NSStringFromCGRect([[UIApplication sharedApplication] statusBarFrame])];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t <applicationFrame> %@", NSStringFromCGRect([[UIScreen mainScreen] applicationFrame])];
    logMessage = [logMessage stringByAppendingFormat:@"\n\t <preferredViewFrame> %@", NSStringFromCGRect(self.navigationController.applicationViewFrame)];
    logMessage = [logMessage stringByAppendingFormat:@"\n}"];
    return logMessage;
}

#endif

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
    controller.view.backgroundColor = [UIColor clearColor];
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
    view.backgroundColor = [UIColor clearColor];
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
    cell.textLabel.textColor = [UIColor redColor];
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
    controller.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    controller.title = (NSString *)object;
    controller.leftSidebarViewController  = sidebarViewController;
    controller.leftSelectedIndexPath      = indexPath;
    
    //controller.label.text = [NSString stringWithFormat:@"Selected %@ from LeftSidebarViewController", (NSString *)object];
    sidebarViewController.sidebarDelegate = controller;
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
    
}

- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}

@end
