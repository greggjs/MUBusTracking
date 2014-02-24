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
    SettingsView *settings = [[SettingsView alloc]initWithFrame:self.view.bounds andRoutes:_routes];
    [self.view addSubview:settings];
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
        FavSwitch *favSwitch;
        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if ([[ver objectAtIndex:0] intValue] >= 7) {
            favSwitch= [[FavSwitch alloc] initWithFrame:CGRectMake(220, 5, 40, 40) withRoute:route.name];
        } else {
            favSwitch= [[FavSwitch alloc] initWithFrame:CGRectMake(190, 7, 40, 40) withRoute:route.name];
        }
        //On first pass initialize all routes to favorites
        if([[NSUserDefaults standardUserDefaults] objectForKey:route.name] == nil){
            [favSwitch setOn:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:route.name];
        } else { //user default has bee assigned
            BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:route.name];
            [favSwitch setOn:state];
        }
        [favSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
        UIImage *image = [self imageWithColor:route.color andWidth:5 andHeight:30];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 5, 30)];
        imageView.image = image;
        [subView addSubview:imageView];
        [subView addSubview:favLabel];
        [subView addSubview:favSwitch];
        [view addSubview:subView];
        i++;
        NSLog(@"Made entry for %@", route.name);
    }
}
#pragma mark - private methods
- (UIImage *)imageWithColor:(UIColor *)color andWidth:(float)width andHeight:(float)height {
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void) setState:(FavSwitch*)sender{
    BOOL state = [sender isOn] ? YES : NO;
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:sender.route];
}

-(void) changeLocationSettings:(UISwitch*)sender {
    BOOL state = [sender isOn] ? YES : NO;
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:@"location"];
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
    
    [_busRefresh invalidate];
    _busRefresh = nil;
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
    
    if (indexPath.row < [_routes count] +1) {
        if (indexPath.row==0)
            [controller showFavorites:controller.mapView_]; // [self showFavorites];
        else if (indexPath.row > 0 && indexPath.row < [_routes count]+1)
            [controller showBusWithRoute:_routes[indexPath.row-1] onMap:controller.mapView_];
    }
    else
        [controller displaySettings:sidebarViewController withName:object withIndexPath:indexPath];
}

- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}


@end
