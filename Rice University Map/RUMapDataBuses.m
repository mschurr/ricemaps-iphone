//
//  RUMapDataBuses.m
//  Rice University Map
//
//  Created by Matthew Schurr on 1/29/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import "RUMapDataBuses.h"
#import "NetworkActivityManager.h"

@interface RUMapDataBuses()
@property (strong, nonatomic) NSArray *busLocations;
@property BOOL monitoringActive;
@end

@implementation RUMapDataBuses

#define API_ENDPOINT_BUSES @"http://bus.rice.edu/json/buses.php"
#define API_ENDPOINT_ROUTES @"http://bus.rice.edu/json/routes.php"
#define API_INTERVAL 5

- (id) init
{
    self = [super init];
    
    if(self) {
        self.monitoringActive = NO;
    }
    
    return self;
}

- (void) startMonitoring
{
    self.monitoringActive = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("RUMapDataBuses", NULL);
    dispatch_async(queue, ^{
        while(self.monitoringActive) {
            [self updateBusLocations];
            [NSThread sleepForTimeInterval: API_INTERVAL];
        }
    });
}

- (void) stopMonitoring
{
    self.monitoringActive = NO;
}

- (void) updateBusLocations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NetworkActivityManager standardNetworkActivityManager] registerNetworkActivity];
    });
    
    NSLog(@"Updating Bus Location");
    NSError *error;
    NSURL *url = [NSURL URLWithString: API_ENDPOINT_BUSES];
    NSURLRequest *request = [NSURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 3.0];
    NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: &error];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NetworkActivityManager standardNetworkActivityManager] unregisterNetworkActivity];
    });
    
    if(!response)
        return;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: response options: 0 error: NULL];
    
    if(json) {
        NSArray *locations = [json objectForKey: @"d"];
        self.busLocations = locations;
        [self didChangeValueForKey: @"busLocations"];
    }
}

@end
