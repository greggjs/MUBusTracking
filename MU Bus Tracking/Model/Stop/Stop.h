//
//  Stop.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/27/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Stop : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSString *stopsAt;
@property (nonatomic, strong) NSString *freq;
@end
