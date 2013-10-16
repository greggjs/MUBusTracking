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
    NSString *urlString = @"http://bus.csi.miamioh.edu/mobile/jsonHandler.php?func=getRouteShape&route=";
    urlString = [urlString stringByAppendingString:bus.route];
    NSArray *ret = [self getRoute:urlString];
    return ret;
}

-(NSArray*)getRouteCoordinatesByColorString:(NSString *)color{
    //Create the request
    NSString *urlString = @"http://bus.csi.miamioh.edu/mobile/jsonHandler.php?func=getRouteShape&route=";
    urlString = [urlString stringByAppendingString:color];
    NSArray *ret = [self getRoute:urlString];
    return ret;
}

-(NSArray*)getAllRoutes {
    NSString *urlString = @"http://bus.csi.miamioh.edu/mymetroadmin/api/route/ALL";
    //Make the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response = [[NSURLResponse alloc] init];
    NSError *requestError = nil;
    NSData *adata = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: &requestError];
    
    //Handle the response
    if(adata){
        NSLog(@"%@ Response Success", urlString);
        
        NSError *parseError = nil;
        NSArray *resultsArray = [NSJSONSerialization JSONObjectWithData:adata options:kNilOptions error:&parseError];
        NSMutableArray *routes = [[NSMutableArray alloc] init];
        //NSMutableArray *points = [[NSMutableArray alloc] init];
        ColorService *cs = [[ColorService alloc] init];
        if(resultsArray){
            for (NSDictionary *items in resultsArray) {
                Route *temp = [Route alloc];
                temp.busID = (NSString*)[items objectForKey:@"name"];
                temp.name = (NSString*)[items objectForKey:@"longname"];
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
                temp.shape = [[NSArray alloc] initWithArray:points];
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

-(NSArray*)getRoute:(NSString *)urlString {
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
