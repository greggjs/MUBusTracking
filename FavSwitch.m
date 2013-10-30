//
//  FavSwitch.m
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 10/30/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "FavSwitch.h"

@implementation FavSwitch

- (id)initWithFrame:(CGRect)frame withRoute:(NSString *)route
{
    self = [super initWithFrame:frame];
    if (self) {
        _route = route;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
