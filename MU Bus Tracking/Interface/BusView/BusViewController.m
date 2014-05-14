//
//  BusViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 5/6/14.
//  Copyright (c) 2014 Jake Gregg. All rights reserved.
//

#import "BusViewController.h"

@interface BusViewController ()

@end

@implementation BusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithBus:(Bus *)bus {
    self = [super init];
    _bus = bus;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"Bus %@", _bus.busID];
    
    CGRect bounds = [[UIScreen mainScreen]bounds];
    self.view = [[BusView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height) andBus:_bus];
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
