//
//  BusSiteViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/14/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import "BusSiteViewController.h"

@interface BusSiteViewController ()

@end

@implementation BusSiteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithRoute:(NSString*)route {
    
    self = [super init];
    _route = route;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect bounds = [[UIScreen mainScreen]bounds];
    UIWebView *website = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    NSArray *data = [[NSArray alloc] initWithObjects:@"oxford-and-miami-university-service-route-u1", @"u2", @"u3", @"u4", @"u5", @"u6", @"U7-Walmart-Flyer", @"U8-North-South-Loop", nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"U1", @"U2", @"U3", @"U4", @"U5", @"U6", @"U7", @"U8", nil];
    NSDictionary *webDict = [[NSDictionary alloc]initWithObjects:data forKeys:keys];
    NSString *websiteURL = @"http://www.butlercountyrta.com/schedules-maps/miami-university/";
    @try {
        websiteURL = [websiteURL stringByAppendingString:(NSString*)[webDict objectForKey:_route]];
    } @catch( NSException *err) {
        NSLog(@"Exception caught: No key for %@", _route);
        //websiteURL = @"http://www.butlercountyrta.com/schedules-maps/miami-university/";
    }
    [website loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:websiteURL]]];
    [self.view addSubview:website];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
