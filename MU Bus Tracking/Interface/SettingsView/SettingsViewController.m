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

@synthesize view;
@synthesize title;
@synthesize leftSidebarViewController;
@synthesize leftSelectedIndexPath;

-(id)initWithRoutes:(NSArray*)routes{
    self = [super init];
    _routes = routes;
    return self;
}

-(id)initWithRoutes:(NSArray *)routes withBuses:(NSArray *)buses withName:(NSObject *)object withSidebar:(SidebarViewController *)sidebarViewController withIndexPath:(NSIndexPath *)indexPath {
    self = [super init];
    _routes = routes;
    _buses = buses;
    _routeName = (indexPath.row == 0 ? @"ALL" :(indexPath.row > 0 && indexPath.row < [_routes count]+1 ? ((Route*)(_routes[indexPath.row-1])).name : @"Settings"));
    _center = (indexPath.row == 0 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON):(indexPath.row > 0 && indexPath.row < [_routes count]+1 ? ((Route*)_routes[indexPath.row-1]).center:CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON)));
    _zoom = (indexPath.row == 0 ? MAIN_ZOOM :(indexPath.row > 0 && indexPath.row < [_routes count]+1 ? ((Route*)_routes[indexPath.row-1]).zoom:MAIN_ZOOM));
    [_busRefresh invalidate];
    
    view.backgroundColor = [UIColor clearColor];
    title = (NSString *)object;
    leftSidebarViewController  = sidebarViewController;
    leftSelectedIndexPath      = indexPath;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add a settings view to the controller
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] < 7) {
        CGRect bounds = [[UIScreen mainScreen]bounds];
        _settings = [[SettingsView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height) andRoutes:_routes];
        self.view = _settings;
    } else {
        _settings = [[SettingsView alloc]initWithFrame:self.view.bounds andRoutes:_routes];
        [self.view addSubview:_settings];

    }
    NSLog(@"Self: %@ SettingsView: %@", self.view, _settings);
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Add left sidebar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];
    self.navigationItem.revealSidebarDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    MapViewController *controller = [[MapViewController alloc]initWithRoutes:_routes withBuses:_buses withName:object withSidebar:sidebarViewController withIndexPath:indexPath];
    sidebarViewController.sidebarDelegate = controller;
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
    
    if (indexPath.row < [_routes count] +1) {
        if (indexPath.row==0)
            [controller showFavorites:controller.mapView_]; // [self showFavorites];
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


@end
