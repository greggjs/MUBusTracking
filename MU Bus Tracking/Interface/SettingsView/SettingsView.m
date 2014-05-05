//
//  SettingsView.m
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 2/24/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import "SettingsView.h"

@implementation SettingsView

@synthesize routes = _routes;

- (id)initWithFrame:(CGRect)frame andRoutes:(NSArray*)routes
{
    NSLog(@"Called SettingsView Ctor");
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"Self is there");
        // Initialization code
        _routes = routes;
        [self generateView];
    }
    return self;
}

-(void)generateView{
    self.backgroundColor = [UIColor whiteColor];
    
    // Location Services Switch
    UIView *locationServices = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 280, 40)];
    locationServices.backgroundColor = [UIColor whiteColor];
    locationServices.layer.cornerRadius = 5.f;
    locationServices.layer.borderColor = [UIColor lightGrayColor].CGColor;
    locationServices.layer.borderWidth = 0.5f;
    UISwitch *locationSwitch;
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        locationSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(220, 5, 40, 40)];
    }else {
        locationSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(190, 7, 40, 40)];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"location"]) {
        [locationSwitch setOn:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"location"];
    } else { //user default has bee assigned
        BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:@"location"];
        [locationSwitch setOn:state];
    }
    [locationSwitch addTarget:self action:@selector(changeLocationSettings:) forControlEvents:UIControlEventValueChanged];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, 40)];
    label.text = @"Location Services";
    label.textColor = [UIColor darkTextColor];
    [locationServices addSubview:label];
    [locationServices addSubview:locationSwitch];
    
    UIView *favLabelView = [[UIView alloc]initWithFrame:CGRectMake(20, 80, 280, 40)];
    favLabelView.backgroundColor = [UIColor whiteColor];
    favLabelView.layer.cornerRadius = 5.f;
    favLabelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    favLabelView.layer.borderWidth = 0.5f;
    
    UILabel *favLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, 40)];
    favLabel.text = @"Favorites";
    favLabel.textColor = [UIColor darkTextColor];
    CGFloat size = 20.f;
    [favLabel setFont:[UIFont boldSystemFontOfSize:size]];
    [favLabelView addSubview:favLabel];
    
    int routeHeight = 40*[_routes count];
    
    UIView *favorites = [[UIView alloc]initWithFrame:CGRectMake(20, 140, 280, 40*[_routes count])];
    favorites.backgroundColor = [UIColor whiteColor];
    favorites.layer.cornerRadius = 5.f;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:scrollView];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, routeHeight+230)];
    [scrollView addSubview:locationServices];
    [scrollView addSubview:favLabelView];
    [scrollView addSubview:favorites];
    [self generateLabelsOnView:favorites];
}

-(void)generateLabelsOnView:(UIView*)view {
    int i = 0;
    NSLog(@"Size of _routes: %i", [_routes count]);
    for (Route* route in _routes) {
        UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, i*40, 280, 40)];
        //subView.layer.cornerRadius = 5.f;
        subView.backgroundColor = [UIColor whiteColor];
        subView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        subView.layer.borderWidth = 0.5f;
        UILabel *favLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, 40)];
        favLabel.text = route.name;
        favLabel.textColor = [UIColor darkTextColor];
        FavSwitch *favSwitch;
        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if ([[ver objectAtIndex:0] intValue] >= 7) {
            favSwitch= [[FavSwitch alloc] initWithFrame:CGRectMake(220, 5, 40, 40) withRoute:route.name];
        } else {
            favSwitch= [[FavSwitch alloc] initWithFrame:CGRectMake(190, 7, 40, 40) withRoute:route.name];
        }
        //On first pass initialize all routes to favorites
        if([[NSUserDefaults standardUserDefaults] objectForKey:route.name] == nil){
            [favSwitch setOn:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:route.name];
        } else { //user default has bee assigned
            BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:route.name];
            [favSwitch setOn:state];
        }
        [favSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
        UIImage *image = [self imageWithColor:route.color andWidth:5 andHeight:30];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 5, 30)];
        imageView.image = image;
        [subView addSubview:imageView];
        [subView addSubview:favLabel];
        [subView addSubview:favSwitch];
        [view addSubview:subView];
        i++;
        NSLog(@"Made entry for %@", route.name);
    }
}


#pragma mark - private methods
- (UIImage *)imageWithColor:(UIColor *)color andWidth:(float)width andHeight:(float)height {
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void) setState:(FavSwitch*)sender{
    BOOL state = [sender isOn] ? YES : NO;
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:sender.route];
}

-(void) changeLocationSettings:(UISwitch*)sender {
    BOOL state = [sender isOn] ? YES : NO;
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:@"location"];
}


@end
