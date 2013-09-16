//
//  ViewController.h
//  MU Bus
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTRevealSidebarV2Delegate.h"

#define EXPERIMENTAL_ORIENTATION_SUPPORT 1

@class SidebarViewController;

@interface ViewController : UIViewController <JTRevealSidebarV2Delegate, UITableViewDelegate> {
#if EXPERIMENTAL_ORIENTATION_SUPPORT
    CGPoint _containerOrigin;
#endif
}

@property (nonatomic, strong) SidebarViewController *leftSidebarViewController;
@property (nonatomic, strong) UITableView *rightSidebarView;
@property (nonatomic, strong) NSIndexPath *leftSelectedIndexPath;
@property (nonatomic, strong) UILabel     *label;

@end
