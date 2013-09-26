//
//  BusService.m
//  MU Bus Tracking
//
//  Created by Pete, Michael Kalial on 9/26/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "BusService.h"
#import "Bus.h"
#define API_URL @"http://bus.csi.miamioh.edu/mobileOld/jsonHandler.php?func=apiTest"
#define BLUE_URL @"http://bus.csi.miamioh.edu/mobileOld/jsonHandler.php?func=getBusPositions&route=BLUE"

@implementation BusService

-(NSArray*)getBuses{
    NSArray *BUS_COLORS = [NSArray arrayWithObjects:@"ORANGE", @"BLUE", @"YELLOW", @"GREEN", @"PURPLE", @"RED", nil];
    //Create the request
    int i = 0;
    while (i < 6) {
        NSString *urlString = @"http://bus.csi.miamioh.edu/mobileOld/jsonHandler.php?func=getBusPositions&route=";
        urlString = [urlString stringByAppendingString:(NSString *)[BUS_COLORS objectAtIndex:i]];
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
                    NSString *busId = (NSString *)[busDict objectForKey:@"busIDd"];
                    NSString *lat = (NSString *)[busDict objectForKey:@"lat"];
                    NSString *lon = (NSString *)[busDict objectForKey:@"lon"];
                    NSString *route = (NSString *)[busDict objectForKey:@"route"];

                    [busArray addObject:currentBus];
                    NSLog(@"Bus Added: %@ %@ %@ %@",busId,lat,lon,route);
                }
            } else {
                NSLog(@"Parse error %@", requestError);
            }
        
            return [[NSArray alloc] initWithArray:busArray];
        } else {
            NSLog(@"Request error %@", requestError);
            return nil;
        }
        i++;
    }
    
}
@end
