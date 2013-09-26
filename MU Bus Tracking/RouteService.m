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

-(NSArray*)getRouteCoordinates:(Bus *)bus{
    //Create the request
    NSString *urlString = @"http://bus.csi.miamioh.edu/mobileOld/jsonHandler.php?func=getRouteShape&route=";
    urlString = [urlString stringByAppendingString:bus.route];
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
        NSMutableArray *points = [[NSMutableArray alloc] init];
        
        if(resultsArray){
            for(NSDictionary *pointDict in resultsArray){
                
                CLLocationCoordinate2D currentPoint;
                currentPoint.latitude = [[pointDict objectForKey:@"lat"] doubleValue];
                currentPoint.longitude = [[pointDict objectForKey:@"lng"] doubleValue];
                
                [points addObject:[NSValue valueWithBytes:&currentPoint objCType:@encode(CLLocationCoordinate2D)]];
                
            }
        } else {
            NSLog(@"Parse error %@", requestError);
        }
        
        return [[NSArray alloc] initWithArray:points];
    } else {
        NSLog(@"Request error %@", requestError);
        return nil;
    }
    
}

-(NSArray*)getRouteCoordinatesByColor:(NSString *)color{
    //Create the request
    NSString *urlString = @"http://bus.csi.miamioh.edu/mobileOld/jsonHandler.php?func=getRouteShape&route=";
    urlString = [urlString stringByAppendingString:color];
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
        NSMutableArray *points = [[NSMutableArray alloc] init];
        
        if(resultsArray){
            for(NSDictionary *pointDict in resultsArray){
                
                CLLocationCoordinate2D currentPoint;
                currentPoint.latitude = [[pointDict objectForKey:@"lat"] doubleValue];
                currentPoint.longitude = [[pointDict objectForKey:@"lng"] doubleValue];
                
                [points addObject:[NSValue valueWithBytes:&currentPoint objCType:@encode(CLLocationCoordinate2D)]];
                
            }
        } else {
            NSLog(@"Parse error %@", requestError);
        }
        
        return [[NSArray alloc] initWithArray:points];
    } else {
        NSLog(@"Request error %@", requestError);
        return nil;
    }
    
}
@end
