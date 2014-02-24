//
//  SidebarViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Bus.h"
#import "BusService.h"
#import "RouteService.h"
#import "Route.h"

@protocol SidebarViewControllerDelegate;

@interface SidebarViewController : UITableViewController
@property (nonatomic, assign) id <SidebarViewControllerDelegate> sidebarDelegate;
@property (nonatomic, strong) NSArray* routes;
@end

@protocol SidebarViewControllerDelegate <NSObject>

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController;

@end
