//
//  RouteService.h
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bus.h"
#import "Route.h"
#import "ColorService.h"
#import "math.h"


@interface RouteService : NSObject

-(NSArray*) getRouteWithName:(NSString*)route;
-(CLLocationCoordinate2D) determineWindowSizeWithRoute:(Route*)route withCooridnates:(NSArray*)retpoints;
@end
