//
//  LeftViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/27/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "UIViewController+JTRevealSidebarV2.h"
#import "JTRevealSidebarV2Delegate.h"

@interface LeftViewController : UIViewController

@property (nonatomic, strong) UILabel       *label;
@property (nonatomic, strong) UITableView   *rightSidebarView;

@end
