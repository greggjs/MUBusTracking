//
//  BusService.m
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "BusService.h"
#import "Bus.h"
#define BUS_URL @"http://bus.csi.miamioh.edu/mobileOld/jsonHandler.php?func=apiTest"

@implementation BusService

-(NSArray*)getBuses{
    //Create the request
    NSString *urlString = BUS_URL;
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
                Bus *currentBus = [[Bus alloc] init];
                [currentBus setBusID: [busDict objectForKey:@"busId"]];
                [currentBus setLatitude:[busDict objectForKey:@"lat"]];
                [currentBus setLongitude:[busDict objectForKey:@"lng"]];
                
                [busArray addObject:currentBus];
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
