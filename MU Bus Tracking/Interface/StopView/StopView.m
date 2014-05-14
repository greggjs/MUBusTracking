//
//  StopView.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/6/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import "StopView.h"

@implementation StopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame andStop:(Stop *)stop {
    self = [self initWithFrame:frame];
    _stop = stop;
    
    _panoView_ = [[GMSPanoramaView alloc] initWithFrame:CGRectMake(0, 0, 280, 300)];
    UIView *pview = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 280, 300)];
    [pview addSubview:_panoView_];
    [self addSubview:pview];
    
    [_panoView_ moveNearCoordinate:_stop.location];
    
    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(20, 320, 280, 100)];
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    UILabel *freqLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 280, 50)];
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *getHours = [[NSDateFormatter alloc] init];
    getHours.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"HH" options:0 locale:[NSLocale currentLocale]];
    NSString *hours = [getHours stringFromDate:now];
    
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:now];
    NSInteger hour = [comps hour];

    infoLabel.text = [NSString stringWithFormat:@"Arrives Next at %d:%@", hour, _stop.stopsAt];
    infoLabel.textColor  = [UIColor darkTextColor];
    
    freqLabel.text = [NSString stringWithFormat:@"Arrives every %@ minutes", _stop.freq];
    infoLabel.textColor = [UIColor darkTextColor];
    
    [infoView addSubview:infoLabel];
    [infoView addSubview:freqLabel];
    [self addSubview:infoView];
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
