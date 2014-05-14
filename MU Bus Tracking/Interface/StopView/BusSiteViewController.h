//
//  BusSiteViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/14/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusSiteViewController : UIViewController

@property (nonatomic, strong) NSString* route;

-(id)initWithRoute:(NSString*)route;

@end
