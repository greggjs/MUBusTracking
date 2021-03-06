//
//  Bus.h
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface Bus : NSObject

@property (nonatomic, strong) NSString *busID;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) GMSMarker *marker;

@end
