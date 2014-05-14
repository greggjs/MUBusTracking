//
//  BusView.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/6/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import "BusView.h"

@implementation BusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andBus:(Bus *)bus {
    self = [self initWithFrame:frame];
    _bus = bus;
    
    _panoView_ = [[GMSPanoramaView alloc] initWithFrame:CGRectMake(0, 0, 280, 300)];
    UIView *pview = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 280, 300)];
    [pview addSubview:_panoView_];
    [self addSubview:pview];
    CGFloat lat = (CGFloat)[_bus.latitude floatValue];
    CGFloat lng = (CGFloat)[_bus.longitude floatValue];
    [_panoView_ moveNearCoordinate:CLLocationCoordinate2DMake(lat, lng)];
    
    
    UIView *routeView = [[UIView alloc]initWithFrame:CGRectMake(20, 300, 300, 140)];
    UILabel *routeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 140)];
    routeLabel.text = [NSString stringWithFormat:@"Route: %@", _bus.route];
    routeLabel.textColor = [UIColor darkTextColor];
    [routeView addSubview:routeLabel];
    [self addSubview:routeView];
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
