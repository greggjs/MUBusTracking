//
//  FavSwitch.h
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 10/30/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavSwitch : UISwitch

@property (nonatomic, strong) NSString *route;

-(id)initWithFrame:(CGRect)frame withRoute:(NSString*)route;

@end
