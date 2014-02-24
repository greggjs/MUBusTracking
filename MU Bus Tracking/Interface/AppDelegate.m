//
//  AppDelegate.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/15/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [GMSServices provideAPIKey:@"AIzaSyDNufTl_3_h50bJ3fbbiGWxLaff_TSy3aU"];
    
    // Override point for customization after application launch.
    RouteService *rs = [[RouteService alloc] init];
    NSArray *routes = [rs getRouteWithName:@"ALL"];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON);
    
    MapViewController *controller = [[MapViewController alloc]initWithRoutes:routes withCenter:center withZoom:MAIN_ZOOM];
    controller.routeName = @"ALL";
    controller.favorites = TRUE;
    controller.title = @"Favorites";
    [controller showFavorites:controller.mapView_];
    
    for (Route *r in controller.routes) {
        if([[NSUserDefaults standardUserDefaults] objectForKey:r.name] == nil){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:r.name];
        }
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    // Create nav bar based on iPhone version.
    ColorService *cs = [[ColorService alloc] init];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        navController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIColor blackColor],UITextAttributeTextShadowColor,nil];
        navController.navigationBar.tintColor = [UIColor whiteColor];
        navController.navigationBar.barTintColor = [cs getColorFromHexString:APP_COLOR];
        navController.navigationBar.translucent = NO;

    } else {
        navController.navigationBar.tintColor = [cs getColorFromHexString:APP_COLOR];
    }
    navController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.window.rootViewController = navController;
    
    [self.window makeKeyAndVisible];
    
    NSLog(@"AppDelegate finished params");
   
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
