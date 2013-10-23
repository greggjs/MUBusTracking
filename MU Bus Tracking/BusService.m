//
//  BusService.m
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "BusService.h"
#import "Bus.h"

// Old link: bus.csi.miamioh.edu/mobile/jsonHandler.php?func=getBusPositions&route=

@implementation BusService

-(NSArray*)getBusWithRoute:(NSString*)route {
    NSString *urlString = @"http://bus.csi.muohio.edu/mymetroadmin/api/vehiclesOnRoute/";
    urlString = [urlString stringByAppendingString:route];
    NSLog(@"%@", urlString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"GET"];
    
    //Make the request
    NSURLResponse* response = [[NSURLResponse alloc] init];
    NSError *requestError = nil;
    NSData *adata = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: &requestError];
    
    //Handle the response
    if(adata){
        NSLog(@"Bus Response Success");
        
        NSError *parseError = nil;
        NSArray *resultsArray = [NSJSONSerialization JSONObjectWithData:adata options:kNilOptions error:&parseError];
        NSMutableArray *busArray = [[NSMutableArray alloc] init];
        
        if(resultsArray){
            for(NSDictionary *busDict in resultsArray){
                NSString *lat = [busDict objectForKey:@"latitude"];
                NSString *lng = [busDict objectForKey:@"longitude"];
                if (![lat isKindOfClass:[NSNull class] ] && ![lng isKindOfClass:[NSNull class]]) {
                    Bus *currentBus = [[Bus alloc] init];
                    [currentBus setBusID: [busDict objectForKey:@"vehicleId"]];
                    currentBus.latitude = (NSString*)lat;
                    currentBus.longitude = (NSString*)lng;
                    [currentBus setRoute:[busDict objectForKey:@"routeId"]];
                    [busArray addObject:currentBus];
                    NSLog(@"BUS: %@ %@", lat, lng);
                }
            }
        } else {
            NSLog(@"Parse error %@", requestError);
        }
        
        return [[NSArray alloc] initWithArray:busArray];
    } else {
        NSLog(@"Request error %@", requestError);
        return nil;
    }
}

@end
