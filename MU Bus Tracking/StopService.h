//
//  StopService.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bus.h"
#import "Stop.h"

@interface StopService : NSObject

-(NSArray*) getStopCooridinates:(NSString*)route;

@end
