//
//  Route.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 10/10/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (strong, nonatomic)NSString *busID;
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSArray *stops;
@property (strong, nonatomic)NSArray *buses;
@property (strong, nonatomic)NSArray *shape;
@property (strong, nonatomic)UIColor *color;



@end
