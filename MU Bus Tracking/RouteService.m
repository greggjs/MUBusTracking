//
//  RouteService.m
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "RouteService.h"
#import <CoreLocation/CoreLocation.h>

@implementation RouteService


-(NSArray*)getRouteWithName:(NSString *)route {
    NSString *urlString = @"http://bus.csi.miamioh.edu/mymetroadmin/api/route/";
    urlString = [urlString stringByAppendingString:route];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"GET"];
    
    //Make the request
    NSURLResponse* response = [[NSURLResponse alloc] init];
    NSError *requestError = nil;
    NSData *adata = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: &requestError];
    
    //Handle the response
    if(adata){
        NSLog(@"%@ Response Success", urlString);
        
        NSError *parseError = nil;
        NSArray *resultsArray = [NSJSONSerialization JSONObjectWithData:adata options:kNilOptions error:&parseError];
        NSMutableArray *routes = [[NSMutableArray alloc] init];
        ColorService *cs = [[ColorService alloc] init];
        if(resultsArray){
            for (NSDictionary *items in resultsArray) {
                Route *temp = [Route alloc];
                temp.name = (NSString*)[items objectForKey:@"name"];
                temp.longname = (NSString*)[items objectForKey:@"longname"];
                NSString *hexColor = (NSString*)[items objectForKey:@"color"];
                temp.color = [cs getColorFromHexString:hexColor];
                
                NSData *nested = [(NSString*)[items objectForKey:@"shape"] dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *points = [NSJSONSerialization JSONObjectWithData:nested options:kNilOptions error:&parseError];
                NSMutableArray *retpoints = [[NSMutableArray alloc] init];
                if (points) {
                    for(NSDictionary *pointDict in points){
                        CLLocationCoordinate2D currentPoint;
                        currentPoint.latitude = [[pointDict objectForKey:@"lat"] doubleValue];
                        currentPoint.longitude = [[pointDict objectForKey:@"lng"] doubleValue];
                        [retpoints addObject:[NSValue valueWithBytes:&currentPoint objCType:@encode(CLLocationCoordinate2D)]];
                    }
                }
                
                temp.shape = [[NSArray alloc] initWithArray:retpoints];
                temp.center = [self determineWindowSizeWithRoute:temp withCooridnates:retpoints];
                [routes addObject:temp];
            }
        } else {
            NSLog(@"Parse error %@", requestError);
        }
        
        return [[NSArray alloc] initWithArray:routes];
    } else {
        NSLog(@"Request error %@", requestError);
        return nil;
    }
    
}

-(CLLocationCoordinate2D) determineWindowSizeWithRoute:(Route*)route withCooridnates:(NSArray*)retpoints{
    CLLocationCoordinate2D temp;
    [[retpoints objectAtIndex:0]getValue:&temp];
    CLLocationCoordinate2D top_left = temp;
    //NSLog(@"%f, %f", top_left.latitude, top_left.longitude);
    CLLocationCoordinate2D top_right = temp;
    CLLocationCoordinate2D bottom_left = temp;
    CLLocationCoordinate2D bottom_right = temp;
    CLLocationCoordinate2D  p1, p2, center;
    //NSLog(@"top_left has: %f, %f", top_left.latitude, top_left.longitude);
    route.shape = [[NSArray alloc] initWithArray:retpoints];
    for (int i = 1; i < [route.shape count]; i++) {
        CLLocationCoordinate2D curr;
        [[retpoints objectAtIndex:i]getValue:&curr];
        if (curr.latitude > top_left.latitude
            && curr.longitude < top_left.longitude) {
            top_left = curr;
        } if (curr.latitude < bottom_right.latitude
              && curr.longitude > bottom_right.longitude) {
            bottom_right = curr;
        } if (curr.latitude < top_right.latitude
              && curr.longitude > top_right.longitude) {
            top_right = curr;
            
        } if (curr.latitude < bottom_left.latitude
              && curr.longitude < bottom_left.longitude) {
            bottom_left = curr;
        }
    }
    if (top_left.latitude < bottom_left.latitude) {
        p1 = bottom_left;
        p2 = top_right;
    } else {
        p1 = top_left;
        p2 = bottom_right;
    }
    center.latitude = (p1.latitude+p2.latitude)/2;
    center.longitude = (p1.longitude+p2.longitude)/2;
    
    float west = p1.longitude;
    float east = p2.longitude;
    float angle = east - west;
    
    if (angle < 0)
        angle += 360.0;
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize size = CGSizeMake(screen.size.width * scale, screen.size.height * scale);
    route.zoom = floor(log(size.width*360/angle/256)/0.693)-0.75;
    //NSLog(@"%f", log(size.width*360/angle/256));
    NSLog(@"%f, %f, %f", center.latitude, center.longitude, route.zoom);
    return center;
}
@end
