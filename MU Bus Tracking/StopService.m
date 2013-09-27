//
//  StopService.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "StopService.h"
#import <CoreLocation/CoreLocation.h>

@implementation StopService

-(NSArray*)getStopCooridinates:(NSString *)color {
    //Create the request
    NSString *urlString = @"http://bus.csi.miamioh.edu/mobile/jsonHandler.php?func=getStops&route=";
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
                currentPoint.latitude = [[pointDict objectForKey:@"stop_lat"] doubleValue];
                currentPoint.longitude = [[pointDict objectForKey:@"stop_lon"] doubleValue];
                Stop *stop = [[Stop alloc] init];
                [stop setRoute:[pointDict objectForKey:@"route"]];
                [stop setLocation:currentPoint];
                [stop setName:[pointDict objectForKey:@"stop_name"]];
                
                [points addObject:stop];
                
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
