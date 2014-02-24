//
//  ColorService.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 10/14/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorService : NSObject

-(UIColor*) getColorFromHexString:(NSString*)color;

@end
