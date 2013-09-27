//
//  BusService.m
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "BusService.h"
#import "Bus.h"

@implementation BusService

-(NSArray*)getBusWithColor:(NSString*)color {
    NSString *urlString = @"http://bus.csi.miamioh.edu/mobile/jsonHandler.php?func=getBusPositions&route=";
    urlString = [urlString stringByAppendingString:color];
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
                [currentBus setRoute:[busDict objectForKey:@"routeId"]];
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

-(NSMutableArray*)getBuses{
    NSArray *BUS_COLORS = [NSArray arrayWithObjects:@"ORANGE", @"BLUE", @"YELLOW", @"GREEN", @"PURPLE", @"RED", nil];
    //Create the request
    NSMutableArray *buses = [[NSMutableArray alloc] init];
    int i = 0;
    while (i < 6) {
        NSArray *curr = [self getBusWithColor:(NSString *)[BUS_COLORS objectAtIndex:i]];
        [buses addObjectsFromArray:curr];
        i++;
    }
    return buses;
}
@end
