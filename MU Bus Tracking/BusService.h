//
//  BusService.h
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusService : NSObject

-(NSArray*) getAllBuses;
-(NSArray*) getBusOnRoute:(NSString*)route;
@end
